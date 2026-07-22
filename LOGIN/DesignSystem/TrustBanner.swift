import SwiftUI

struct TrustBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.title2)
                .foregroundStyle(Color("AccentOrange"))

            VStack(alignment: .leading, spacing: 2) {
                Text("Secure & Trusted")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("TextPrimary"))
                Text("Your data is safe with us, we never share")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
            }

            Spacer()
        }
        .padding()
        .background(Color("InputBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("BorderColor"), lineWidth: 1)
        )
    }
}
