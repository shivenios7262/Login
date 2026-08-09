import SwiftUI
import UIKit
import nimbbl_mobile_kit_ios_webview_sdk
import nimbbl_mobile_kit_ios_core_api_sdk

struct NimbblCheckoutRepresentable: UIViewControllerRepresentable {
    let orderToken: String
    let onSuccess: ([String: Any]) -> Void
    let onFailure: ([String: Any]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSuccess: onSuccess, onFailure: onFailure)
    }

    @MainActor
    func makeUIViewController(context: Context) -> NimbblCheckoutWebView {
        let options = NimbblCheckoutOptions(
            orderToken: orderToken,
            paymentModeCode: nil,
            bankCode: nil,
            walletCode: nil,
            paymentFlow: nil
        )
        let vc = NimbblCheckoutWebView(options: options)
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: NimbblCheckoutWebView, context: Context) {}

    // Coordinator is @MainActor so delegate callbacks — called from NimbblCheckoutWebView
    // which is also @MainActor — require no extra dispatching.
    @MainActor
    final class Coordinator: NSObject, NimbblCheckoutWebViewDelegate {
        private let onSuccess: ([String: Any]) -> Void
        private let onFailure: ([String: Any]) -> Void

        init(
            onSuccess: @escaping ([String: Any]) -> Void,
            onFailure: @escaping ([String: Any]) -> Void
        ) {
            self.onSuccess = onSuccess
            self.onFailure = onFailure
            super.init()
        }

        func nimbblCheckoutWebViewDidSucceed(_ controller: NimbblCheckoutWebView, payload: [String: Any]) {
            onSuccess(payload)
        }

        func nimbblCheckoutWebViewDidFail(_ controller: NimbblCheckoutWebView, payload: [String: Any]) {
            onFailure(payload)
        }
    }
}
