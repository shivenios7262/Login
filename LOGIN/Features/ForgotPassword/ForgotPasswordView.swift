import SwiftUI

struct ForgotPasswordView: View {
    @State private var viewModel = ForgotPasswordViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var vm = viewModel

        ZStack(alignment: .top) {
            Color("CardBackground").ignoresSafeArea()

            Image("dottedMap")
                .resizable()
                .scaledToFill()
                .containerRelativeFrame(.vertical) { height, _ in height * 0.35 }
                .frame(maxWidth: .infinity, alignment: .top)
                .clipped()
                .opacity(0.95)
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(spacing: 28) {
                    FTDAuthLogo()
                        .padding(.top, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Forgot password")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color("TextPrimary"))
                        Text("Enter your registered email and we will help you reset your password.")
                            .font(.subheadline)
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    FTDTextField(
                        label: String(localized: "Email"),
                        placeholder: String(localized: "Enter your email"),
                        text: $vm.email,
                        errorMessage: vm.emailError,
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )

                    FTDPrimaryButton(
                        title: String(localized: "Send OTP"),
                        isLoading: vm.isLoading
                    ) {
                        Task { await vm.sendOTP() }
                    }

                    Spacer(minLength: 40)
                    TrustBanner()
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $vm.showCheckEmail) {
            CheckEmailView(email: vm.email, dismissSheet: dismiss)
        }
    }
}
