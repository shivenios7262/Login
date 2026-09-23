import SwiftUI
import UIKit

@main
struct LOGINApp: App {

    init() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        var config = UIButton.Configuration.filled()
        config.title = String(localized: "Done")
        config.image = UIImage(systemName: "checkmark")
        config.imagePlacement = .trailing
        config.imagePadding = DesignTokens.Spacing.xs
        config.baseBackgroundColor = .ftdAccentOrange
        config.baseForegroundColor = .ftdTextOnAccent
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = .ftdLabelSM
            return a
        }
        config.cornerStyle = .fixed
        config.background.cornerRadius = DesignTokens.Radius.button
        config.contentInsets = NSDirectionalEdgeInsets(
            top: DesignTokens.Spacing.xs,
            leading: DesignTokens.Spacing.md,
            bottom: DesignTokens.Spacing.xs,
            trailing: DesignTokens.Spacing.md
        )

        let doneBtn = UIButton(configuration: config, primaryAction: UIAction { _ in
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        })

        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(customView: doneBtn)
        toolbar.items = [flex, done]
        UITextField.appearance().inputAccessoryView = toolbar
    }
    // AuthManager and AppRouter are created once at app launch on the main thread.
    // `let` avoids @State overhead since both types are @Observable.
    private let authManager: AuthManager = {
        // Uncomment to wipe stored tokens and test the full first-launch flow:
        // KeychainService().delete(key: .appToken)
        // KeychainService().delete(key: .accessToken)
          let keychain   = KeychainService()
//        keychain.delete(key: .userData)
//       keychain.delete(key: .deviceId)
//        keychain.delete(key: .appToken)
////         print("appToken cleared:", keychain.read(key: .appToken) ?? "nil")
        let apiClient  = APIClient(
            httpClient:     URLSessionHTTPClient(),
            baseURL:        AppConfiguration.apiBaseURL,
            keychain:       keychain,
            appCredentials: AppConfiguration.appCredentials
        )
        return AuthManager(apiClient: apiClient, keychain: keychain)
    }()

    private let appRouter = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authManager)
                .environment(appRouter)
        }
    }
}


