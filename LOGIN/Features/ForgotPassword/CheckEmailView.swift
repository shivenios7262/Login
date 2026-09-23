import SwiftUI

struct CheckEmailView: View {
    let email: String
    let dismissSheet: DismissAction

    @Environment(\.openURL) private var openURL
    @State private var showMailUnavailableAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Logo — larger than the shared FTDAuthLogo default
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160)
                    .padding(.top, 44)
                    .padding(.bottom, 44)

                Image("mail")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .padding(.bottom, 36)

                Text("Check Your Email")
                    .font(.ftdTitleLG)
                    .foregroundStyle(Color.ftdTextPrimary)
                    .padding(.bottom, 12)

                VStack(spacing: 4) {
                    Text("We have sent a Password reset link to")
                        .font(.ftdBodyMD)
                        .foregroundStyle(Color.ftdTextSecondary)
                    Text(email)
                        .font(.ftdLabelSM)
                        .foregroundStyle(Color.ftdAccentOrange)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)

                Text("Please check your inbox and click on the link\nto reset your password")
                    .font(.ftdBodyMD)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)

                FTDPrimaryButton(title: "Open Email", leadingIcon: "envelope.fill") {
                    openMailApp()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                Button("Cancel") {
                    dismissSheet()
                }
                .font(.ftdButton)
                .foregroundStyle(Color.ftdTextSecondary)
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .alert("No Email App Found", isPresented: $showMailUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please set up an email app on your device to open your email.")
        }
    }

    private func openMailApp() {
        let mailURL = URL(string: "message://")!
        let mailtoURL = URL(string: "mailto:")!
        if UIApplication.shared.canOpenURL(mailURL) {
            openURL(mailURL)
        } else if UIApplication.shared.canOpenURL(mailtoURL) {
            openURL(mailtoURL)
        } else {
            showMailUnavailableAlert = true
        }
    }
}
