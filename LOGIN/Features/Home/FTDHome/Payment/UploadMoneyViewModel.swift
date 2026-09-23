import Foundation
import Observation

@Observable
@MainActor
final class UploadMoneyViewModel {

    enum PaymentType { case offlineRequest, instantTopUp }

    enum OfflineTab: CaseIterable, Hashable {
        case bank, cash, cheque

        var title: String {
            switch self {
            case .bank:   return String(localized: "Bank")
            case .cash:   return String(localized: "Cash")
            case .cheque: return String(localized: "Cheque")
            }
        }

        var depositType: String {
            switch self {
            case .bank:   return "Online Transfer"
            case .cash:   return "Cash"
            case .cheque: return "Cheque"
            }
        }

        var submitTitle: String {
            switch self {
            case .bank:   return String(localized: "Submit Bank Topup")
            case .cash:   return String(localized: "Submit Cash Request")
            case .cheque: return String(localized: "Submit Cheque Request")
            }
        }
    }

    enum Phase {
        case loading
        case loaded
        case submitting
        case success(referenceNo: String, message: String)
        case failure(String)
    }

    struct AlertItem {
        let title: String
        let message: String
    }

    // MARK: - State

    private(set) var phase: Phase = .loading
    private(set) var uploadMoneyData: UploadMoneyData?
    var alertItem: AlertItem?

    var paymentType: PaymentType = .offlineRequest
    var selectedTab: OfflineTab = .bank
    var selectedBankId: String?

    var amount: String = ""
    var transferDate: Date? = Date()
    var utrId: String = ""
    var remark: String = ""
    var chequeDrawnBank: String = ""
    var chequeNo: String = ""

    private(set) var isNimbblPresented = false
    private(set) var nimbblOrderData: CreatePaymentOrderData?
    private var wasManuallyDismissed = false
    private var nimbblTimeoutTask: Task<Void, Never>?

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Derived

    var walletBalance: String {
        guard let raw = uploadMoneyData?.bookingBalance,
              !raw.isEmpty,
              let value = Double(raw) else { return "₹0" }
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_IN")
        f.numberStyle = .currency
        f.currencySymbol = "₹"
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "₹\(raw)"
    }

    var pendingCount: String {
        uploadMoneyData?.pendingData.first?.count ?? "0"
    }

    var pendingAmount: String {
        guard let raw = uploadMoneyData?.pendingData.first?.amount,
              let value = Double(raw) else { return "0" }
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_IN")
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? raw
    }

    var uploadTimingsText: String {
        guard let t = uploadMoneyData?.uploadTimings else { return "" }
        return "(\(t.startTime) to \(t.endTime))"
    }

    var specialMessage: String { uploadMoneyData?.specialMessage ?? "" }
    var cashDailyLimit: String { uploadMoneyData?.cashDailyLimit ?? "" }

    var walletBalanceAmount: String {
        walletBalance.hasPrefix("₹") ? String(walletBalance.dropFirst()) : walletBalance
    }

    var transferDateFormatted: String? {
        guard let date = transferDate else { return nil }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_IN")
        f.dateFormat = "dd-MMM-yyyy"
        return f.string(from: date)
    }

    func bankLogoURL(_ bank: BankItem) -> URL? {
        FTDImageURL.bankLogo(bank.bankLogo)
    }

    var currentBanks: [BankItem] {
        guard let data = uploadMoneyData else { return [] }
        switch selectedTab {
        case .bank:   return data.bankList.bank.filter   { $0.showBank   == "1" }
        case .cash:   return data.bankList.cash.filter   { $0.showCash   == "1" }
        case .cheque: return data.bankList.cheque.filter { $0.showCheque == "1" }
        }
    }

    var selectedBank: BankItem? {
        currentBanks.first { $0.bankId == selectedBankId }
    }

    var isLoading: Bool {
        switch phase { case .loading, .submitting: return true; default: return false }
    }

    var loadingMessage: String {
        switch phase {
        case .loading:    return String(localized: "Loading...")
        case .submitting: return String(localized: "Submitting request...")
        default:          return ""
        }
    }

    func remark(for bank: BankItem) -> String? {
        switch selectedTab {
        case .bank:   return bank.bankRemarks
        case .cash:   return bank.cashRemarks
        case .cheque: return bank.chequeRemarks
        }
    }

    func isDisabled(_ bank: BankItem) -> Bool {
        return false
    }

    func payMethod(for bank: BankItem) -> String {
        switch selectedTab {
        case .bank:   return bank.bankPayMethod
        case .cash:   return bank.cashPayMethod
        case .cheque: return bank.chequePayMethod
        }
    }

    // MARK: - Actions

    func fetchData() async {
        phase = .loading
        do {
            let data = try await authManager.fetchUploadMoney()
            uploadMoneyData = data
            autoSelectFirstBank()
            phase = .loaded
        } catch {
            phase = .failure(error.localizedDescription)
        }
    }

    func selectTab(_ tab: OfflineTab) {
        selectedTab = tab
        autoSelectFirstBank()
        transferDate = Date()
        utrId = ""
        remark = ""
        chequeDrawnBank = ""
        chequeNo = ""
    }

    func selectBank(_ bank: BankItem) {
        guard !isDisabled(bank) else { return }
        selectedBankId = bank.bankId
    }

    func submitOfflineRequest() async {
        guard let bank = selectedBank else {
            setAlert(String(localized: "Please select a bank."))
            return
        }
        let trimmed = amount.trimmingCharacters(in: .whitespaces)
        guard let amountInt = Int(trimmed), amountInt >= 10 else {
            setAlert(String(localized: "Please enter an amount of at least ₹10."))
            return
        }
        guard let selectedDate = transferDate else {
            setAlert(String(localized: "Please select a transfer date."))
            return
        }
        if selectedTab == .bank {
            guard !utrId.trimmingCharacters(in: .whitespaces).isEmpty else {
                setAlert(String(localized: "Please enter the UTR ID."))
                return
            }
        }
        guard !remark.trimmingCharacters(in: .whitespaces).isEmpty else {
            setAlert(String(localized: "Please enter a remark."))
            return
        }
        if selectedTab == .cheque {
            guard !chequeDrawnBank.trimmingCharacters(in: .whitespaces).isEmpty else {
                setAlert(String(localized: "Please enter the bank name the cheque is drawn on."))
                return
            }
            guard !chequeNo.trimmingCharacters(in: .whitespaces).isEmpty else {
                setAlert(String(localized: "Please enter the cheque number."))
                return
            }
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let request = UploadMoneyRequest(
            depositType: selectedTab.depositType,
            payMethod: payMethod(for: bank),
            transferAmount: trimmed,
            transferDate: df.string(from: selectedDate),
            transactionId: utrId.isEmpty ? nil : utrId,
            chequeDrawnBank: chequeDrawnBank.isEmpty ? nil : chequeDrawnBank,
            chequeNo: chequeNo.isEmpty ? nil : chequeNo,
            remarks: remark.isEmpty ? nil : remark
        )
        phase = .submitting
        do {
            let result = try await authManager.submitUploadMoneyRequest(request)
            phase = .success(referenceNo: result.referenceNo, message: result.message)
        } catch {
            setAlert(error.localizedDescription)
            phase = .loaded
        }
    }

    func initiateInstantTopUp() async {
        let trimmed = amount.trimmingCharacters(in: .whitespaces)
        guard let amountInt = Int(trimmed), amountInt >= 10 else {
            setAlert(String(localized: "Please enter an amount of at least ₹10."))
            return
        }
        phase = .submitting
        do {
           // print("[STEP 1 REQUEST] create_payment_order → {\"transfer_amount\": \(amountInt)}")
            let orderData = try await authManager.createPaymentOrder(amount: amountInt)
            //logStep1Response(orderData)
            guard let token = orderData.paymentToken, !token.isEmpty else {
                throw NetworkError.serverError(String(localized: "Invalid payment token received."))
            }
            let orderId = extractOrderId(from: token)
           // print("[TOKEN] sub_merchant_id: \(extractTokenClaim("sub_merchant_id", from: token) ?? "nil")")
            guard !orderId.isEmpty else {
               // print("[STEP 2 ERROR] payment_token JWT is missing order_id — token may be malformed or expired")
                throw NetworkError.serverError(String(localized: "Payment token is invalid (missing order ID)."))
            }
           // print("[STEP 2] Nimbbl checkout will open with order_id: \(orderId)")
            wasManuallyDismissed = false
            nimbblOrderData = orderData
            isNimbblPresented = true
            phase = .loaded
            startNimbblSessionTimeout()
        } catch {
           // print("[STEP 1 ERROR] create_payment_order → \(error.localizedDescription)")
            setAlert(error.localizedDescription)
            phase = .loaded
        }
    }

    func handleNimbblSuccess(payload: [String: Any]) async {
       // print("[STEP 3 RESPONSE] Nimbbl callback → success: \(jsonString(from: payload))")
        // Capture before dismissNimbblCheckout() clears nimbblOrderData.
        let referenceId = nimbblOrderData?.referenceId
        let invoiceId   = nimbblOrderData?.invoiceId
        dismissNimbblCheckout()
        phase = .submitting
        do {
            var mutablePayload = payload
            if var order = mutablePayload["order"] as? [String: Any] {
                let base = AppConfiguration.apiBaseURL.absoluteString.trimmingCharacters(in: ["/"])
                order["shopfront_domain"] = "\(base)/book/b2b/money-management"
                mutablePayload["order"] = order
            }
            var body: [String: Any] = [
                "event_type": "globalHandleCheckoutResponse",
                "payload": mutablePayload
            ]
            if let referenceId { body["reference_id"] = referenceId }
            if let invoiceId   { body["invoice_id"]   = invoiceId }
            let bodyData = try JSONSerialization.data(withJSONObject: body)
            let serverMessage = try await authManager.confirmPayment(bodyData: bodyData, isJSON: true)
           // print("[STEP 4 RESPONSE] payment_checkout → success")
            await authManager.refreshBalance()
            let displayMessage = serverMessage ?? String(localized: "Payment of ₹\(amount) completed successfully!")
            phase = .success(referenceNo: "", message: displayMessage)
        } catch {
            //print("[STEP 4 ERROR] payment_checkout → \(error.localizedDescription)")
            // Payment was captured by Nimbbl but confirmation to FTD failed.
            // Tell the agent explicitly so they don't retry and risk a duplicate charge.
            setAlert(title: String(localized: "Payment Received"), String(localized: "Your payment was processed but confirmation failed. If your balance is not updated in a few minutes, please contact support."))
            phase = .loaded
        }
    }

    func handleNimbblFailure(payload: [String: Any]) {
       // print("[STEP 3 RESPONSE] Nimbbl callback → failure: \(jsonString(from: payload))")
        // If the user already manually dismissed, ignore late cancellation callbacks from Nimbbl.
        guard !wasManuallyDismissed else { return }
        dismissNimbblCheckout()
        let raw = payload["message"] as? String ?? ""
        let message = raw.isEmpty ? String(localized: "Payment was not completed.") : raw
        setAlert(title: String(localized: "Payment Failed"), message)
        phase = .loaded
    }

    func handleNimbblDismiss() {
        //print("[STEP 3 DISMISSED] Nimbbl checkout closed by user without completing payment")
        wasManuallyDismissed = true
        dismissNimbblCheckout()
    }

    func retry() {
        Task { await fetchData() }
    }

    func reset() {
        paymentType = .offlineRequest
        selectedTab = .bank
        amount = ""
        transferDate = Date()
        utrId = ""
        remark = ""
        chequeDrawnBank = ""
        chequeNo = ""
        alertItem = nil
    }

    // MARK: - Private

    private func autoSelectFirstBank() {
        selectedBankId = currentBanks.first { !isDisabled($0) }?.bankId
    }

    private func setAlert(title: String = String(localized: "Error"), _ message: String) {
        alertItem = AlertItem(title: title, message: message)
    }

    private func dismissNimbblCheckout() {
        nimbblTimeoutTask?.cancel()
        nimbblTimeoutTask = nil
        isNimbblPresented = false
        nimbblOrderData = nil
    }

    private func startNimbblSessionTimeout() {
        nimbblTimeoutTask?.cancel()
        nimbblTimeoutTask = Task { [weak self] in
            do {
                // 5 minutes — covers slow 3DS/OTP pages; also auto-recovers from
                // iPad deep-link freezes where UPI apps are not installed.
                try await Task.sleep(for: .seconds(300))
            } catch {
                return // cancelled by success / failure / explicit dismiss
            }
            guard let self, self.isNimbblPresented else { return }
            self.wasManuallyDismissed = true
            self.dismissNimbblCheckout()
            self.setAlert(title: String(localized: "Session Expired"), String(localized: "Payment session timed out. Please try again."))
        }
    }

    private func logStep1Response(_ orderData: CreatePaymentOrderData) {
        let values: [String: Any] = [
            "transfer_amount": orderData.transferAmount ?? NSNull(),
            "payment_token": orderData.paymentToken ?? NSNull(),
            "reference_id": orderData.referenceId ?? NSNull(),
            "invoice_id": orderData.invoiceId ?? NSNull()
        ]
        print("[STEP 1 RESPONSE] create_payment_order → \(jsonString(from: values))")
    }

    private func extractTokenClaim(_ key: String, from token: String) -> String? {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return nil }
        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while payload.count % 4 != 0 { payload.append("=") }
        guard let data = Data(base64Encoded: payload),
              let claims = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return claims[key].map { "\($0)" }
    }

    private func extractOrderId(from token: String) -> String {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return "" }
        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while payload.count % 4 != 0 { payload.append("=") }
        guard let data = Data(base64Encoded: payload),
              let claims = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let orderId = claims["order_id"] as? String else { return "" }
        return orderId
    }

    private func jsonString(from object: Any) -> String {
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: data, encoding: .utf8) else {
            return String(describing: object)
        }
        return string
    }
}
