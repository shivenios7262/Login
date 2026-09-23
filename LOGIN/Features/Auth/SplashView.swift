import SwiftUI

struct SplashView: View {
    let onGetStarted: () async throws -> Void

    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack(alignment: .top) {
            Color.ftdCardBackground.ignoresSafeArea()

            if AppConfiguration.environment != .production {
                Text(AppConfiguration.environment == .debug ? "DEBUG" : "TESTFLIGHT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppConfiguration.environment == .debug ? Color.orange : Color.purple)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 56)
                    .padding(.trailing, 16)
                    .zIndex(1)
            }

            Image("dottedMap")
                .resizable()
                .scaledToFill()
                .containerRelativeFrame(.vertical, alignment: .top) { height, _ in height * (440.0 / 932.0) }
                .frame(maxWidth: .infinity, alignment: .top)
                .clipped()
                .ignoresSafeArea(edges: .top)
                .padding(.top, 0)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 144)
                    .padding(.top, 56)

                Text("\(Text("Travel Far. ").foregroundStyle(Color.ftdAccentTeal))\(Text("Discover More").foregroundStyle(Color.ftdAccentOrange))")
                    .font(.ftdSectionHeaderMedium)
                    .padding(.top, DesignTokens.Spacing.lg)
                
                

                Image("splashMiddleImg")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 280)
                    .padding(.top,24)

                FTDPrimaryButton(title: "Let's Get Started", trailingIcon: "arrow.right", isLoading: isLoading) {
                    Task {
                        isLoading = true
                        defer { isLoading = false }
                        do {
                            try await onGetStarted()
                        } catch let error as NetworkError {
                            errorMessage = error.errorDescription
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top,40)

                Spacer()

                Image("splashBottomImg")
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea(edges: .bottom)
                
            }
        }
        .navigationBarHidden(true)
        .alert("Unable to Connect", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
}
