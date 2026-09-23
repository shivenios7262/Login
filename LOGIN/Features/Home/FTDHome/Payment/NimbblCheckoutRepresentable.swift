import SwiftUI
import UIKit
import nimbbl_mobile_kit_ios_webview_sdk
import nimbbl_mobile_kit_ios_core_api_sdk

struct NimbblCheckoutRepresentable: UIViewControllerRepresentable {
    let paymentToken: String
    let onSuccess: ([String: Any]) -> Void
    let onFailure: ([String: Any]) -> Void

    // SDK must only be initialized once per app lifecycle; calling initialize() again
    // resets internal WKWebView delegate state and breaks mid-session navigation on iPad.
    private static var sdkInitialized = false

    func makeCoordinator() -> Coordinator {
        Coordinator(onSuccess: onSuccess, onFailure: onFailure)
    }

    @MainActor
    func makeUIViewController(context: Context) -> NimbblCheckoutWebView {
        // Set environment URL before initializing.
        // For test/sandbox orders set this to Nimbbl's sandbox checkout URL.
        // For production leave nil (SDK uses its default production URL).
        // NimbblCheckoutSDK.shared.environmentUrl = "https://sandbox.nimbbl.tech"
        // Always update the delegate so the current Coordinator receives callbacks.
        NimbblCheckoutSDK.shared.delegate = context.coordinator
        if !NimbblCheckoutRepresentable.sdkInitialized {
            NimbblCheckoutSDK.shared.initialize(appCode: nil)
            NimbblCheckoutRepresentable.sdkInitialized = true
        }

        let options = NimbblCheckoutOptions(
            orderToken: paymentToken,
            paymentModeCode: nil,
            bankCode: nil,
            walletCode: nil,
            paymentFlow: nil
        )
        logCheckoutInit(options)

        // Also set WebView-level delegate as a secondary callback path.
        let vc = NimbblCheckoutWebView(options: options)
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: NimbblCheckoutWebView, context: Context) {}

    @MainActor
    final class Coordinator: NSObject, NimbblCheckoutWebViewDelegate, NimbblCheckoutSDKDelegate {
        private let onSuccess: ([String: Any]) -> Void
        private let onFailure: ([String: Any]) -> Void
        // Guards against both delegates firing for the same payment event.
        private var hasResponded = false

        init(
            onSuccess: @escaping ([String: Any]) -> Void,
            onFailure: @escaping ([String: Any]) -> Void
        ) {
            self.onSuccess = onSuccess
            self.onFailure = onFailure
            super.init()
        }

        // MARK: - NimbblCheckoutSDKDelegate (ObjC-bridged, fires for all states)

        func onCheckoutResponse(data: [AnyHashable: Any]) {
            // ObjC delegates can fire on any thread; hop to main before touching shared state.
            guard Thread.isMainThread else {
                DispatchQueue.main.async { self.onCheckoutResponse(data: data) }
                return
            }
            guard !hasResponded else { return }
            let payload = data.reduce(into: [String: Any]()) { result, pair in
                if let key = pair.key as? String { result[key] = pair.value }
            }
            // For success responses, 'order' is required by the FTD server.
            // If it's missing, skip here so nimbblCheckoutWebViewDidSucceed fires with the full payload.
            if isSuccess(payload) && payload["order"] == nil {
                return
            }
            hasResponded = true
           // print("[STEP 3 RESPONSE] onCheckoutResponse: \(jsonString(from: payload))")
            if isSuccess(payload) {
                onSuccess(payload)
            } else {
                onFailure(payload)
            }
        }

        // MARK: - NimbblCheckoutWebViewDelegate (Swift-only, fires for specific states)

        func nimbblCheckoutWebViewDidSucceed(_ controller: NimbblCheckoutWebView, payload: [String: Any]) {
            guard !hasResponded else { return }
            hasResponded = true
            //print("[STEP 3 RESPONSE] nimbblCheckoutWebViewDidSucceed: \(jsonString(from: payload))")
            onSuccess(payload)
        }

        func nimbblCheckoutWebViewDidFail(_ controller: NimbblCheckoutWebView, payload: [String: Any]) {
            guard !hasResponded else { return }
            hasResponded = true
            //print("[STEP 3 RESPONSE] nimbblCheckoutWebViewDidFail: \(jsonString(from: payload))")
            onFailure(payload)
        }

        // MARK: - Private

        private func isSuccess(_ payload: [String: Any]) -> Bool {
            let status = (payload["status"] as? String ?? "").lowercased()
            let eventType = (payload["event_type"] as? String ?? "").lowercased()
            let successValues: Set<String> = ["success", "completed", "paid"]
            let failureValues: Set<String> = ["failed", "failure", "error", "cancelled", "canceled"]
            if failureValues.contains(status) || failureValues.contains(eventType) { return false }
            if successValues.contains(status) || successValues.contains(eventType) { return true }
            print("[STEP 3 WARNING] onCheckoutResponse status unknown — treating as failure. status='\(status)' event_type='\(eventType)'")
            return false
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
}

private extension NimbblCheckoutRepresentable {
    func logCheckoutInit(_ options: NimbblCheckoutOptions) {
        let token = options.orderToken
        let params: [String: Any] = [
            "order_token": token ?? NSNull(),
            "payment_mode_code": options.paymentModeCode ?? NSNull(),
            "bank_code": options.bankCode ?? NSNull(),
            "wallet_code": options.walletCode ?? NSNull(),
            "payment_flow": options.paymentFlow ?? NSNull()
        ]
        //print("[STEP 2] Nimbbl checkout init → params: \(jsonString(from: params))")
    }

    func jsonString(from object: Any) -> String {
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
              let string = String(data: data, encoding: .utf8) else {
            return String(describing: object)
        }
        return string
    }
}
