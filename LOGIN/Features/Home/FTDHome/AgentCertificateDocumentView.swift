import SwiftUI
import UIKit

// MARK: - Certificate Images

struct CertificateImages {
    var logo: UIImage?
    var seal: UIImage?
    var nameText: UIImage?

    private static let base = "http://13.200.42.214/book/public/img/gs/"

    static func fetch() async -> CertificateImages {
        async let logo     = fetchImage("logoCertificate.png")
        async let seal     = fetchImage("certificateSeal.png")
        async let nameText = fetchImage("nameText.png")
        return CertificateImages(logo: await logo, seal: await seal, nameText: await nameText)
    }

    private static func fetchImage(_ name: String) async -> UIImage? {
        guard let url = URL(string: base + name),
              let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Certificate View (A4 Portrait 595 × 842)

struct AgentCertificateDocumentView: View {
    let agentNo: String
    let agencyName: String
    let address: String
    let memberSince: String
    var images: CertificateImages = CertificateImages()

    private let ftdCompany = "Shubh Mani Solutions Pvt Ltd"
    private let ftdCIN     = "U63040KA2015PTC084306"
    private let ftdGST     = "29AAWCS4469E1ZL"

    private let pageW: CGFloat = 595
    private let pageH: CGFloat = 842

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white

            VStack(spacing: 0) {
                headerRow
                contentSection
                Spacer(minLength: 0)
                footerRow
            }
        }
        .frame(width: pageW, height: pageH)
        .clipShape(RoundedRectangle(cornerRadius: 7))
        // Outer thick orange border
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.ftdAccentOrange, lineWidth: 8)
        )
        // Inner thin orange border
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.ftdAccentOrange.opacity(0.5), lineWidth: 1.5)
                .padding(14)
        )
        .background(Color.white)
        // Force light evaluation so semantic tokens render correctly on the fixed white background
        .colorScheme(.light)
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(alignment: .center, spacing: 0) {
            ftdLogoBadge
                .padding(.top, 104)
                .padding(.leading, 14)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(ftdCompany)
                    .font(.ftdCertCompanyName)
                    .foregroundStyle(Color.ftdTextPrimary)
                    .multilineTextAlignment(.trailing)
                HStack(spacing: 4) {
                    Text("CIN -").font(.ftdSectionHeader).foregroundStyle(Color.ftdTextPrimary)
                    Text(ftdCIN).font(.ftdCertMetaValue).foregroundStyle(Color.ftdTextSecondary)
                }
                HStack(spacing: 4) {
                    Text("GST -").font(.ftdSectionHeader).foregroundStyle(Color.ftdTextPrimary)
                    Text(ftdGST).font(.ftdCertMetaValue).foregroundStyle(Color.ftdTextSecondary)
                }
            }
            .padding(.trailing, 30)
            .padding(.top, 40)
        }
        .frame(height: 110)
    }

    @ViewBuilder
    private var ftdLogoBadge: some View {
        if let logo = images.logo {
            Image(uiImage: logo)
                .resizable()
                .scaledToFit()
                .frame(height: 188)
        } else {
            ZStack {
                Color.ftdAccentOrange
                VStack(alignment: .leading, spacing: 1) {
                    HStack(alignment: .center, spacing: 0) {
                        Text("f").font(.ftdCertLogoText)
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20, weight: .bold))
                            .rotationEffect(.degrees(-25))
                            .offset(x: -2, y: -2)
                        Text("d").font(.ftdCertLogoText)
                    }
                    .foregroundStyle(.white)
                    Text("TRAVEL")
                        .font(.ftdCertLogoBadge)
                        .foregroundStyle(.white.opacity(0.92))
                        .tracking(2.5)
                }
                .padding(.leading, 22)
            }
            .frame(width: 310, height: 188)
        }
    }

    // MARK: - Content

    private var contentSection: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 55)

            // Intentional serif — decorative certificate heading with no Poppins equivalent
            Text("Certificate of Registration")
                .font(.system(size: 38, weight: .light, design: .serif))
                .italic()
                .foregroundStyle(Color.ftdTextPrimary)

            Spacer().frame(height: 36)

            Text("This is to certify that")
                .font(.ftdCertBody)
                .foregroundStyle(Color.ftdTextSecondary)

            Spacer().frame(height: 24)

            Text(agencyName.isEmpty ? "—" : agencyName)
                .font(.ftdCertAgencyName)
                .foregroundStyle(Color.ftdTextPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Spacer().frame(height: 7)

            (Text("has registered on ").foregroundStyle(Color.ftdTextSecondary)
             + Text("FTD Travel").font(.ftdCertBodyBold).foregroundStyle(Color.ftdTextPrimary)
             + Text(" as travel agent").foregroundStyle(Color.ftdTextSecondary))
                .font(.ftdCertBody)

            Spacer().frame(height: 44)

            detailsBlock
        }
        .padding(.horizontal, 60)
    }

    private var detailsBlock: some View {
        VStack(alignment: .center, spacing: 6) {
            HStack(spacing: 24) {
                detailPair(label: "Agency ID", value: agentNo)
                if !memberSince.isEmpty {
                    detailPair(label: "Registration Date", value: memberSince)
                }
            }
            if !address.isEmpty {
                HStack(alignment: .top, spacing: 4) {
                    Text("Address : ")
                        .font(.ftdCertDetailLabel)
                        .foregroundStyle(Color.ftdTextPrimary)
                    Text(address)
                        .font(.ftdCertDetailValue)
                        .foregroundStyle(Color.ftdTextSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func detailPair(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text("\(label) : ").font(.ftdCertDetailLabel).foregroundStyle(Color.ftdTextPrimary)
            Text(value.isEmpty ? "—" : value).font(.ftdCertDetailValue).foregroundStyle(Color.ftdTextSecondary)
        }
    }

    // MARK: - Footer

    private var footerRow: some View {
        HStack(alignment: .center, spacing: 0) {
            ftdSeal
                .padding(.leading, 48)
                .padding(.bottom, 100)
            Spacer()
            signatureBlock
                .padding(.trailing, 48)
                .padding(.bottom, 86)
        }
    }

    @ViewBuilder
    private var ftdSeal: some View {
        if let seal = images.seal {
            Image(uiImage: seal)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
        } else {
            ZStack {
                Circle().stroke(Color.ftdCertSealBlue, lineWidth: 2.5).frame(width: 72, height: 72)
                Circle().stroke(Color.ftdCertSealBlue.opacity(0.5), lineWidth: 1).frame(width: 60, height: 60)
                VStack(spacing: 1) {
                    Text("ftd").font(.ftdAvatarLabel).foregroundStyle(Color.ftdCertSealBlue)
                    Text("TRAVEL").font(.ftdCertSealBadge).foregroundStyle(Color.ftdCertSealBlue).tracking(1.5)
                }
            }
        }
    }

    @ViewBuilder
    private var signatureBlock: some View {
        if let nameText = images.nameText {
            VStack(alignment: .center, spacing: 6) {
                Image(uiImage: nameText)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130)
                Text("Director")
                    .font(.ftdCertDirectorLabel)
                    .foregroundStyle(Color.ftdTextPrimary)
                Text("www.ftd.travel")
                    .font(.ftdBodySM)
                    .foregroundStyle(Color.ftdTextSecondary)
            }
        } else {
            VStack(alignment: .center, spacing: 3) {
                // Intentional serif — script signature style with no Poppins equivalent
                Text("Vinit Jain")
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .italic()
                    .foregroundStyle(Color.ftdTextPrimary)
                Text("Director")
                    .font(.ftdCertDirectorLabel)
                    .foregroundStyle(Color.ftdTextPrimary)
                Text("www.ftd.travel")
                    .font(.ftdBodySM)
                    .foregroundStyle(Color.ftdTextSecondary)
            }
        }
    }
}
