import SwiftUI

struct SplashView: View {
    let onGetStarted: () async throws -> Void

    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack(alignment: .top) {
            Color("CardBackground").ignoresSafeArea()

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

                Text("\(Text("Travel Far, ").foregroundStyle(Color("AccentTeal")))\(Text("Discover More").foregroundStyle(Color("AccentOrange")))")
                    .font(.system(size: 18, weight: .medium))
                    .padding(.top, 10)

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
/*import SwiftUI

struct SplashView: View {
    let onGetStarted: () -> Void

    var body: some View {
        
        ZStack(alignment: .top) {
            Color("CardBackground").ignoresSafeArea()
            Image("dottedMap")
                    .resizable()
                    .scaledToFill()
                    .containerRelativeFrame(.vertical) { height, _ in height * 0.5 }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .clipped()
                    .opacity(0.95)
                    .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                // Logo
//                VStack(spacing: 2) {
//                    HStack(spacing: 6) {
//                        Image(systemName: "airplane")
//                            .font(.system(size: 28, weight: .bold))
//                            .foregroundStyle(Color("AccentOrange"))
//                        Text("FTD")
//                            .font(.system(size: 36, weight: .black))
//                            .foregroundStyle(Color("AccentOrange"))
//                    }
//                    Text("TRAVEL")
//                        .font(.system(size: 13, weight: .bold))
//                        .foregroundStyle(Color("AccentOrange"))
//                        .kerning(5)
//                }
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 139)
                .padding(.top, 56)

                // Tagline
                Text("\(Text("Travel Far, ").foregroundStyle(Color("AccentTeal")))\(Text("Discover More").foregroundStyle(Color("AccentOrange")))")
//                .font(.title3)
//                .fontWeight(.semibold)
                    .font(.system(size: 18, weight: .medium))
                .padding(.top, 10)

                // Hero image placeholder — replace Image("splash_hero") once asset is added
               // ZStack {
//                    RoundedRectangle(cornerRadius: 24)
//                        .fill(
//                            LinearGradient(
//                                colors: [Color("AccentOrange").opacity(0.15), Color("InputBackground")],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                    VStack(spacing: 16) {
//                        Image(systemName: "airplane.departure")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 100, height: 100)
//                            .foregroundStyle(Color("AccentOrange").opacity(0.6))
//                        Text("Your journey starts here")
//                            .font(.subheadline)
//                            .foregroundStyle(Color("TextSecondary"))
//                    }
                    Image("splashMiddleImg")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 251)
                //}
//                .frame(height: 360)
//                .padding(.horizontal, 24)
//                .padding(.top, 28)

               // Spacer()

                // Landmarks strip placeholder — replace with actual landmarks image asset
//                HStack(spacing: 20) {
//                    ForEach(
//                        ["building.columns", "building.2", "ferry", "house"],
//                        id: \.self
//                    ) { icon in
//                        Image(systemName: icon)
//                            .font(.system(size: 28))
//                            .foregroundStyle(Color("TextSecondary").opacity(0.25))
//                    }
//                }
//                .padding(.bottom, 32)

                // CTA
//                Button(action: onGetStarted) {
//                    HStack(spacing: 8) {
//                        Text("Let's Get Started")
//                            .fontWeight(.semibold)
//                        Image(systemName: "arrow.right")
//                    }
//                    .foregroundStyle(.white)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 52)
//                    .background(Color("AccentOrange"))
//                    .clipShape(Capsule())
//                }
//                .padding(.horizontal, 24)
//                .padding(.bottom, 44)
                FTDPrimaryButton(title: "Let's Get Started", trailingIcon: "arrow.right", action: onGetStarted)
                    .padding(.horizontal, 80)
                
                Spacer()
                
                Image("splashBottomImg")
                    .resizable()
                    .scaledToFit()
            }
        }
        .navigationBarHidden(true)
    }
}
//Button(action: onGetStarted) {
//
//    HStack(spacing: 12) {
//
//        Text("Let's Get Started")
//            .font(.system(size: 16, weight: .semibold))
//
//        Image(systemName: "arrow.right")
//            .font(.system(size: 16, weight: .medium))
//    }
//    .foregroundStyle(.white)
//    .frame(maxWidth: .infinity)
//    .frame(height: 44)
//    .background(Color("AccentOrange"))
//    .cornerRadius(8)
//}
//.padding(.horizontal,80)
*/
