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
                .containerRelativeFrame(.vertical, alignment: .top) { height, _ in height * (440.0 / 932.0) }
                .frame(maxWidth: .infinity, alignment: .top)
                .clipped()
                .opacity(0.95)
                
                .ignoresSafeArea(edges: .top)
                .padding(.top, 0)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 144)
                    .padding(.top, 56)

                Text("\(Text("Travel Far, ").foregroundStyle(Color.ftdAccentTeal))\(Text("Discover More").foregroundStyle(Color.ftdAccentOrange))")
                    .font(.system(size: 18, weight: .medium))
                    .padding(.top, DesignTokens.Spacing.lg)
                
                

                Image("splashMiddleImg")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220)
                    .padding(.top,24)

                FTDPrimaryButton(title: "Let's Get Started", trailingIcon: "arrow.right", isLoading: isLoading, fontSize: 16,
                                 fontWeight: .semibold) {
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
