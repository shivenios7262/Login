import SwiftUI

struct SplashView: View {
    let onGetStarted: () async throws -> Void

    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack(alignment: .top) {
            Color.ftdCardBackground.ignoresSafeArea()

            Image("dottedMap")
                .resizable()
                .scaledToFill()
                .containerRelativeFrame(.vertical) { height, _ in height * 0.5 }
                .frame(maxWidth: .infinity, alignment: .top)
                .clipped()
                .opacity(0.95)
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 139)
                    .padding(.top, 56)

                Text("\(Text("Travel Far, ").foregroundStyle(Color.ftdAccentTeal))\(Text("Discover More").foregroundStyle(Color.ftdAccentOrange))")
                    .font(.system(size: 18, weight: .medium))
                    .padding(.top, DesignTokens.Spacing.inputVertical)

                Image("splashMiddleImg")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 251)

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
                .padding(.horizontal, 80)

                Spacer()

                Image("splashBottomImg")
                    .resizable()
                    .scaledToFit()
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
