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

    // MARK: - State

    private(set) var phase: Phase = .loading
    private(set) var uploadMoneyData: UploadMoneyData?
    var alertMessage: String?

    var paymentType: PaymentType = .offlineRequest
    var selectedTab: OfflineTab = .bank
    var selectedBankId: String?

    var amount: String = ""
    var transferDate: Date = Date()
    var utrId: String = ""
    var remark: String = ""
    var chequeDrawnBank: String = ""
    var chequeNo: String = ""

    private(set) var isNimbblPresented = false
    private(set) var nimbblOrderData: CreatePaymentOrderData?

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Derived

    var walletBalance: String {
        guard let raw = authManager.currentUser?.creditBalance,
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
              let value = Double(raw) else { return "₹0" }
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_IN")
        f.numberStyle = .currency
        f.currencySymbol = "₹"
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "₹\(raw)"
    }

    var uploadTimingsText: String {
        guard let t = uploadMoneyData?.uploadTimings else { return "" }
        return "(\(t.startTime) to \(t.endTime))"
    }

    var specialMessage: String { uploadMoneyData?.specialMessage ?? "" }

    var currentBanks: [BankItem] {
        guard let data = uploadMoneyData else { return [] }
        switch selectedTab {
        case .bank:   return data.bankList.bank
        case .cash:   return data.bankList.cash
        case .cheque: return data.bankList.cheque
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
        guard let r = remark(for: bank) else { return false }
        return !r.isEmpty
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
        if tab == .bank { transferDate = Date() }
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
            alertMessage = String(localized: "Please select a bank.")
            return
        }
        let trimmed = amount.trimmingCharacters(in: .whitespaces)
        guard let amountInt = Int(trimmed), amountInt >= 10 else {
            alertMessage = String(localized: "Please enter an amount of at least ₹10.")
            return
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let request = UploadMoneyRequest(
            depositType: selectedTab.depositType,
            payMethod: payMethod(for: bank),
            transferAmount: trimmed,
            transferDate: df.string(from: transferDate),
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
            alertMessage = error.localizedDescription
            phase = .loaded
        }
    }

    func initiateInstantTopUp() async {
        let trimmed = amount.trimmingCharacters(in: .whitespaces)
        guard let amountInt = Int(trimmed), amountInt >= 10 else {
            alertMessage = String(localized: "Please enter an amount of at least ₹10.")
            return
        }
        phase = .submitting
        do {
            let orderData = try await authManager.createPaymentOrder(amount: amountInt)
            guard let token = orderData.paymentToken, !token.isEmpty else {
                throw NetworkError.serverError(String(localized: "Invalid payment token received."))
            }
            nimbblOrderData = orderData
            isNimbblPresented = true
            phase = .loaded
        } catch {
            alertMessage = error.localizedDescription
            phase = .loaded
        }
    }

    func handleNimbblSuccess(payload: [String: Any]) async {
        phase = .submitting
        do {
            let body: [String: Any] = ["event_type": "globalHandleCheckoutResponse", "payload": payload]
            let bodyData = try JSONSerialization.data(withJSONObject: body)
            try await authManager.confirmPayment(bodyData: bodyData)
            phase = .success(referenceNo: "", message: String(localized: "Payment of ₹\(amount) completed successfully!"))
        } catch {
            alertMessage = error.localizedDescription
            phase = .loaded
        }
    }

    func handleNimbblFailure(payload: [String: Any]) {
        let message = payload["message"] as? String ?? String(localized: "Payment was not completed.")
        alertMessage = message
        phase = .loaded
    }

    func handleNimbblDismiss() {
        isNimbblPresented = false
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
        alertMessage = nil
    }

    // MARK: - Private

    private func autoSelectFirstBank() {
        selectedBankId = currentBanks.first { !isDisabled($0) }?.bankId
    }
}
