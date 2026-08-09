import Foundation
import Observation

@Observable
@MainActor
final class UploadMoneyViewModel {

    enum Phase {
        case idle
        case creatingOrder
        case checkout(CreatePaymentOrderData)
        case confirming
        case success(String)
        case failure(String)
    }

    private(set) var phase: Phase = .idle
    var amountText: String = ""

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Computed

    var isNimbblPresented: Bool {
        if case .checkout = phase { return true }
        return false
    }

    var nimbblOrderData: CreatePaymentOrderData? {
        if case .checkout(let data) = phase { return data }
        return nil
    }

    var isLoading: Bool {
        switch phase {
        case .creatingOrder, .confirming: return true
        default: return false
        }
    }

    var loadingMessage: String {
        switch phase {
        case .creatingOrder: return String(localized: "Creating payment order...")
        case .confirming:    return String(localized: "Confirming payment...")
        default:             return ""
        }
    }

    // MARK: - Actions

    func initiatePayment() async {
        let trimmed = amountText.trimmingCharacters(in: .whitespaces)
        guard let amount = Int(trimmed), amount > 0 else {
            phase = .failure(String(localized: "Please enter a valid amount greater than 0."))
            return
        }
        phase = .creatingOrder
        do {
            let orderData = try await authManager.createPaymentOrder(amount: amount)
            guard let token = orderData.paymentToken, !token.isEmpty else {
                throw NetworkError.serverError(String(localized: "Invalid payment token received."))
            }
            phase = .checkout(orderData)
        } catch {
            phase = .failure(error.localizedDescription)
        }
    }

    func handleNimbblSuccess(payload: [String: Any]) async {
        print("[Payment] Nimbbl checkout response received (success):")
        payload.forEach { print("  \($0.key): \($0.value)") }

        phase = .confirming

        do {
            let body: [String: Any] = [
                "event_type": "globalHandleCheckoutResponse",
                "payload": payload
            ]
            let bodyData = try JSONSerialization.data(withJSONObject: body)
            try await authManager.confirmPayment(bodyData: bodyData)
            let suffix = amountText.isEmpty ? "" : " of ₹\(amountText)"
            phase = .success(String(localized: "Payment\(suffix) completed successfully!"))
        } catch {
            phase = .failure(error.localizedDescription)
        }
    }

    func handleNimbblFailure(payload: [String: Any]) {
        print("[Payment] Nimbbl checkout response received (failure):")
        payload.forEach { print("  \($0.key): \($0.value)") }
        let message = payload["message"] as? String ?? String(localized: "Payment was not completed.")
        phase = .failure(message)
    }

    func handleNimbblDismiss() {
        if case .checkout = phase {
            phase = .failure(String(localized: "Payment was cancelled."))
        }
    }

    func retry() { phase = .idle }

    func reset() {
        phase = .idle
        amountText = ""
    }
}
