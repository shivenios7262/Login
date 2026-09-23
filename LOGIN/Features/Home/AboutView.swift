import SwiftUI

private let ftdImg      = FTDImageURL.aboutBase
private let sectionNavy = Color(red: 0.106, green: 0.239, blue: 0.380)
private let cardNavy    = Color(red: 0.141, green: 0.306, blue: 0.467)
private let sectionGray = Color(red: 0.953, green: 0.957, blue: 0.965)

struct AboutView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                statsSection
                aboutSection
                servicesSection
                whyChooseSection
                technologySection
                awardsSection
                contactSection
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("About FTD")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.ftdTextSecondary)
                }
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            FTDAuthLogo()

            VStack(spacing: DesignTokens.Spacing.sm) {
                Text("Enterprise-Grade\nB2B Travel Platform")
                    .font(.custom("Poppins-Bold", size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.ftdTextPrimary)

                Text("Built for Growth. Trusted by 55,000+ Agents")
                    .font(.custom("Poppins-SemiBold", size: 15))
                    .foregroundStyle(Color.ftdAccentOrange)
                    .multilineTextAlignment(.center)

                Text("The only travel distribution platform built specifically for professional travel agencies across India — with unified access to flights, hotels, buses, cabs, visas, and insurance.")
                    .font(.custom("Poppins-Regular", size: 13))
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, DesignTokens.Spacing.xs)
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xxxl)
        .background(Color.ftdCardBackground)
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {

            VStack(spacing: DesignTokens.Spacing.sm) {
                Text("Powering India's Travel Industry")
                    .font(.custom("Poppins-Bold", size: 22))
                    .foregroundStyle(Color.ftdTextPrimary)
                    .multilineTextAlignment(.center)

                Rectangle()
                    .fill(Color.white)
                    .frame(width: 48, height: 3)
                    .cornerRadius(1.5)

                Text("Real numbers. Real impact.")
                    .font(.custom("Poppins-Regular", size: 13))
                    .foregroundStyle(Color.ftdTextPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: DesignTokens.Spacing.md
            ) {
                StatCard(iconURL: "\(ftdImg)iconUserOrange.svg",        sfIcon: "person.3.fill",         value: "55,000+", label: "Registered Agents")
                StatCard(iconURL: "\(ftdImg)iconLocationPinOrange.svg", sfIcon: "mappin.circle.fill",    value: "5,000+",  label: "Cities Covered")
                StatCard(iconURL: "\(ftdImg)iconHotelOrange.svg",       sfIcon: "building.2.fill",       value: "2M+",     label: "Global Hotels")
                StatCard(iconURL: "\(ftdImg)iconVerifyOrange.svg",      sfIcon: "checkmark.shield.fill", value: "10+",     label: "Years Experience")
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .padding(.vertical, DesignTokens.Spacing.xxxl)
        .background(Color.ftdAccentOrange)
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            VStack(spacing: DesignTokens.Spacing.sm) {
                (Text("One Platform.\n")
                    .foregroundStyle(Color.ftdTextPrimary) +
                 Text("Endless Possibilities.")
                    .foregroundStyle(Color.ftdAccentOrange))
                    .font(.custom("Poppins-Bold", size: 24))
                    .multilineTextAlignment(.center)

                Rectangle()
                    .fill(Color.ftdAccentOrange)
                    .frame(width: 48, height: 3)
                    .cornerRadius(1.5)
            }

            Text("FTD Travel is an enterprise-grade B2B travel technology and distribution platform, purpose-built to empower professional travel agencies across India. Operated by Shubh Mani Solutions Private Limited, we have been delivering reliable, scalable, and profitable travel solutions since 2015.")
                .font(.custom("Poppins-Regular", size: 13))
                .foregroundStyle(Color.ftdTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xxxl)
        .background(Color.ftdCardBackground)
    }

    // MARK: - Services

    private var servicesSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            SectionHeader(
                title: "Core Services",
                subtitle: "A unified ecosystem for all your travel distribution needs",
                onDark: true
            )

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: DesignTokens.Spacing.md
            ) {
                ServiceCard(iconURL: "\(ftdImg)cs_flight.svg",       sfIcon: "airplane",         title: "Air Travel",
                            desc: "Access domestic & international flights with NDC, LCC and GDS integrations — all in one platform.", onDark: true)
                ServiceCard(iconURL: "\(ftdImg)cs_hotel.svg",        sfIcon: "building.2.fill",  title: "Hotels",
                            desc: "2M+ properties worldwide from budget to luxury, with real-time availability and instant confirmation.", onDark: true)
                ServiceCard(iconURL: "\(ftdImg)cs_bus.svg",          sfIcon: "bus.fill",         title: "Bus Services",
                            desc: "Pan-India bus ticketing with 2,000+ bus operators and real-time seat availability.", onDark: true)
                ServiceCard(iconURL: "\(ftdImg)cs_cab.svg",          sfIcon: "car.fill",         title: "Cab Services",
                            desc: "Local and outstation cabs across 1,200+ cities including airport transfers and full-day hire.", onDark: true)
                ServiceCard(iconURL: "\(ftdImg)cs_visa.svg",         sfIcon: "doc.text.fill",    title: "Visa Services",
                            desc: "End-to-end visa processing for 70+ countries with documentation support and real-time tracking.", onDark: true)
                ServiceCard(iconURL: "\(ftdImg)cs_tripcare.svg",     sfIcon: "heart.fill",       title: "Travel Insurance",
                            desc: "Comprehensive travel insurance plans to protect your customers — available to sell from your dashboard.", onDark: true)
                ServiceCard(iconURL: "\(ftdImg)cs_eSim.svg",         sfIcon: "simcard.fill",     title: "International eSIM",
                            desc: "Seamless global connectivity solutions for travellers — instant activation across 150+ countries.", onDark: true)
                ServiceCard(iconURL: "\(ftdImg)iconLocationPin.svg", sfIcon: "sparkles",         title: "Things To Do",
                            desc: "Curated activities, sightseeing, and experiences worldwide to enrich every itinerary you create.", onDark: true)
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .padding(.vertical, DesignTokens.Spacing.xxxl)
        .background(sectionNavy)
    }

    // MARK: - Why Choose FTD

    private var whyChooseSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            SectionHeader(
                title: "Why Leading Agents Choose\n",
                highlight: "FTD Travel",
                subtitle: "Built for scale, designed for professionals"
            )

            VStack(spacing: DesignTokens.Spacing.md) {
                BenefitRow(iconURL: "\(ftdImg)why_1.svg", sfIcon: "tag.fill",           title: "Exclusive B2B Pricing",
                           desc: "Wholesale and agency-exclusive pricing to maximise your margins — updated in real time.")
                BenefitRow(iconURL: "\(ftdImg)why_2.svg", sfIcon: "lock.shield.fill",   title: "Secure & Reliable",
                           desc: "Bank-grade security with 99.9% uptime SLA — your business never sleeps, neither do we.")
                BenefitRow(iconURL: "\(ftdImg)why_3.svg", sfIcon: "network",            title: "55,000+ Agent Network",
                           desc: "Join India's largest community of professional travel agents backed by a trusted brand.")
                BenefitRow(iconURL: "\(ftdImg)why_4.svg", sfIcon: "headset",            title: "24/7 Support",
                           desc: "Round-the-clock professionals available whenever you need them — phone, email, or chat.")
                BenefitRow(iconURL: "\(ftdImg)why_5.svg", sfIcon: "chart.bar.fill",     title: "Advanced MIS & Analytics",
                           desc: "Powerful reporting tools for booking performance and real-time operational insights.")
                BenefitRow(iconURL: "\(ftdImg)why_6.svg", sfIcon: "creditcard.fill",    title: "Flexible Payments",
                           desc: "Multiple payment options — credit line, UPI, cards, Pay Later — for seamless transactions.")
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .padding(.vertical, DesignTokens.Spacing.xxxl)
        .background(Color.ftdSurfaceSubtle)
    }

    // MARK: - Technology

    private var technologySection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            SectionHeader(
                title: "Technology-First. ",
                highlight: "Future-Ready.",
                subtitle: "Continuously investing in innovation to keep our partners ahead",
                onDark: true
            )

            VStack(spacing: DesignTokens.Spacing.md) {
                TechCard(iconURL: "\(ftdImg)tf_1.svg", sfIcon: "chevron.left.forwardslash.chevron.right",
                         title: "Enterprise APIs",
                         desc: "RESTful APIs with comprehensive documentation to integrate FTD into your existing booking systems.")
                TechCard(iconURL: "\(ftdImg)tf_2.svg", sfIcon: "paintbrush.fill",
                         title: "White Label Solution",
                         desc: "Launch your own branded booking platform powered by FTD infrastructure — fast, easy, scalable.")
                TechCard(iconURL: "\(ftdImg)tf_3.svg", sfIcon: "tablecells.fill",
                         title: "Advanced MIS",
                         desc: "Real-time business intelligence dashboards, automated MIS reports, and performance monitoring tools.")
                TechCard(iconURL: "\(ftdImg)tf_4.svg", sfIcon: "laptopcomputer.and.iphone",
                         title: "Multi-Platform Access",
                         desc: "Fully responsive web portal plus iOS & Android apps so you can book from anywhere, anytime.")
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .padding(.vertical, DesignTokens.Spacing.xxxl)
        .background(sectionNavy)
    }

    // MARK: - Awards

    private var awardsSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            SectionHeader(
                title: "Awards & ",
                highlight: "Recognition",
                subtitle: "Acknowledged by industry leaders"
            )

            VStack(spacing: DesignTokens.Spacing.md) {
                AwardBadge(
                    sfIcon: "chart.line.uptrend.xyaxis",
                    iconBgColor: Color.ftdAccentOrange,
                    tag: "NASSCOM",
                    title: "NASSCOM 10K Startups",
                    subtitle: "Featured in India's premier startup acceleration program — recognised for technology innovation in travel."
                )
                AwardBadge(
                    sfIcon: "lock.fill",
                    iconBgColor: sectionNavy,
                    tag: "TOP 10",
                    title: "Top 10 Travel Tech Startups",
                    subtitle: "Recognised for innovation and impact in travel technology — among India's fastest-growing travel platforms."
                )
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .padding(.vertical, DesignTokens.Spacing.xxxl)
        .background(Color.ftdSurfaceSubtle)
    }

    // MARK: - Contact

    private var contactSection: some View {
        VStack(spacing: 0) {
            VStack(spacing: DesignTokens.Spacing.lg) {
                SectionHeader(
                    title: "Get In ",
                    highlight: "Touch",
                    subtitle: "Corporate Office"
                )

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    Text("Shubh Mani Solutions\nPrivate Limited")
                        .font(.custom("Poppins-Bold", size: 20))
                        .foregroundStyle(.white)

                    ContactRow(icon: "mappin.circle.fill", label: "ADDRESS",
                               text: "1035, 1st Floor, 4th M Block, RajajiNagar, Dr. RajKumar Road, Bangalore – 560 010")
                    ContactRow(icon: "phone.fill",    label: "PHONE",   text: "+91 73533 11550")
                    ContactRow(icon: "envelope.fill", label: "EMAIL",   text: "admin@ftd.travel")
                    ContactRow(icon: "globe",         label: "WEBSITE", text: "www.ftd.travel")
                }
                .padding(DesignTokens.Spacing.xl)
                .background(sectionNavy)
                .cornerRadius(DesignTokens.Radius.cardLg)
                .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            }
            .padding(.vertical, DesignTokens.Spacing.xxxl)
            .background(Color.ftdCardBackground)

            Text("© 2012–\(String(Calendar.current.component(.year, from: Date()))) Shubh Mani Solutions Pvt Ltd")
                .font(.custom("Poppins-Regular", size: 11))
                .foregroundStyle(Color.ftdTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.xl)
                .background(Color.ftdCardBackground)
        }
    }
}

// MARK: - Sub-components

private struct SectionHeader: View {
    let title: String
    var highlight: String = ""
    let subtitle: String
    var onDark: Bool = false

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            if !highlight.isEmpty {
                (Text(title)
                    .foregroundStyle(onDark ? Color.white : Color.ftdTextPrimary) +
                 Text(highlight)
                    .foregroundStyle(Color.ftdAccentOrange))
                    .font(.custom("Poppins-Bold", size: 22))
                    .multilineTextAlignment(.center)
            } else {
                Text(title)
                    .font(.custom("Poppins-Bold", size: 22))
                    .foregroundStyle(onDark ? Color.white : Color.ftdTextPrimary)
                    .multilineTextAlignment(.center)
            }

            Rectangle()
                .fill(Color.ftdAccentOrange)
                .frame(width: 48, height: 3)
                .cornerRadius(1.5)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.custom("Poppins-Regular", size: 13))
                    .foregroundStyle(onDark ? Color.white.opacity(0.75) : Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
    }
}

private struct StatCard: View {
    let iconURL: String
    let sfIcon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            FTDRemoteImage(url: URL(string: iconURL)) {
                Image(systemName: sfIcon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.ftdAccentOrange)
            }
            .frame(width: 36, height: 36)

            Text(value)
                .font(.custom("Poppins-Bold", size: 22))
                .foregroundStyle(Color.ftdAccentOrange)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(label)
                .font(.custom("Poppins-SemiBold", size: 12))
                .foregroundStyle(Color.ftdTextPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xl)
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .background(Color.ftdCardBackground)
        .cornerRadius(DesignTokens.Radius.card)
    }
}

private struct ServiceCard: View {
    let iconURL: String
    let sfIcon: String
    let title: String
    let desc: String
    var onDark: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .fill(Color.ftdAccentOrange)
                        .frame(width: 44, height: 44)
                    FTDRemoteImage(url: URL(string: iconURL)) {
                        Image(systemName: sfIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 24, height: 24)
                }

                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 13))
                    .foregroundStyle(onDark ? Color.white : Color.ftdTextPrimary)
            }

            Text(desc)
                .font(.custom("Poppins-Regular", size: 11))
                .foregroundStyle(onDark ? Color.white.opacity(0.7) : Color.ftdTextSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.md)
        .background(onDark ? cardNavy : Color.ftdCardBackground)
        .cornerRadius(DesignTokens.Radius.card)
    }
}

private struct BenefitRow: View {
    let iconURL: String
    let sfIcon: String
    let title: String
    let desc: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .fill(Color.ftdAccentOrange)
                        .frame(width: 44, height: 44)
                    FTDRemoteImage(url: URL(string: iconURL)) {
                        Image(systemName: sfIcon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 24, height: 24)
                }

                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 15))
                    .foregroundStyle(Color.ftdAccentOrange)
            }

            Text(desc)
                .font(.custom("Poppins-Regular", size: 13))
                .foregroundStyle(Color.ftdTextSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.xl)
        .background(Color.ftdCardBackground)
        .cornerRadius(DesignTokens.Radius.card)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

private struct TechCard: View {
    let iconURL: String
    let sfIcon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                    .fill(Color.ftdAccentOrange)
                    .frame(width: 44, height: 44)
                FTDRemoteImage(url: URL(string: iconURL)) {
                    Image(systemName: sfIcon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 24, height: 24)
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundStyle(.white)
                Text(desc)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundStyle(Color.white.opacity(0.75))
                    .lineSpacing(3)
            }
            Spacer(minLength: 0)
        }
        .padding(DesignTokens.Spacing.xl)
        .background(cardNavy)
        .cornerRadius(DesignTokens.Radius.card)
    }
}

private struct AwardBadge: View {
    let sfIcon: String
    let iconBgColor: Color
    let tag: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .fill(iconBgColor)
                        .frame(width: 52, height: 52)
                    Image(systemName: sfIcon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    Text(tag)
                        .font(.custom("Poppins-SemiBold", size: 10))
                        .foregroundStyle(Color.ftdTextSecondary)
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xxs)
                        .background(Color.ftdTextSecondary.opacity(0.12))
                        .cornerRadius(DesignTokens.Radius.search)

                    Text(title)
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundStyle(Color.ftdAccentOrange)
                }
            }

            Text(subtitle)
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundStyle(Color.ftdTextSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.xl)
        .background(Color.ftdCardBackground)
        .cornerRadius(DesignTokens.Radius.cardLg)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

private struct ContactRow: View {
    let icon: String
    let label: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                    .fill(Color.ftdAccentOrange)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(label)
                    .font(.custom("Poppins-SemiBold", size: 10))
                    .foregroundStyle(Color.ftdAccentOrange)
                    .kerning(0.5)
                Text(text)
                    .font(.custom("Poppins-Regular", size: 13))
                    .foregroundStyle(.white)
                    .lineSpacing(3)
            }
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
