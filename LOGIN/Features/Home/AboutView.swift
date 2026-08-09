import SwiftUI

struct AboutView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                statsSection
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
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            FTDRemoteImage(url: URL(string: "https://www.ftd.travel/includes/img/logo.png")) {
                Text("FTD Travel")
                    .font(.custom("Poppins-Bold", size: 22))
                    .foregroundStyle(Color.ftdAccentOrange)
            }
            .frame(height: 44)
            .padding(.top, DesignTokens.Spacing.xxl)

            VStack(spacing: DesignTokens.Spacing.sm) {
                Text("Enterprise-Grade\nB2B Travel Platform")
                    .font(.custom("Poppins-Bold", size: 26))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.ftdTextPrimary)

                Text("Built for Growth. Trusted by 55,000+ Agents")
                    .font(.custom("Poppins-SemiBold", size: 15))
                    .foregroundStyle(Color.ftdAccentOrange)
                    .multilineTextAlignment(.center)

                Text("One unified platform for flights, hotels, buses, cabs, visa, insurance, and eSIM — built to power every Indian travel agent's business.")
                    .font(.custom("Poppins-Regular", size: 13))
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.top, DesignTokens.Spacing.xs)
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, DesignTokens.Spacing.xxxl)
        .background(Color.ftdCardBackground)
    }

    // MARK: - Stats

    private var statsSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Text("Powering India's Travel Industry")
                .font(.custom("Poppins-SemiBold", size: 17))
                .foregroundStyle(Color.ftdTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignTokens.Spacing.md) {
                StatCard(icon: "person.3.fill",     value: "55,000+",  label: "Registered Agents")
                StatCard(icon: "map.fill",           value: "5,000+",   label: "Cities Covered")
                StatCard(icon: "building.2.fill",    value: "2M+",      label: "Global Hotels")
                StatCard(icon: "star.fill",          value: "10+",      label: "Years Experience")
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .padding(.vertical, DesignTokens.Spacing.xxxl)
    }

    // MARK: - Services

    private var servicesSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            SectionHeader(title: "Our Core Services", subtitle: "Everything a travel agent needs, in one place")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignTokens.Spacing.md) {
                ServiceCard(icon: "airplane",           title: "Air Travel",         color: .blue)
                ServiceCard(icon: "building.2.fill",    title: "Hotels",             color: .indigo)
                ServiceCard(icon: "bus.fill",           title: "Bus Services",       color: .green)
                ServiceCard(icon: "car.fill",           title: "Cab Services",       color: .orange)
                ServiceCard(icon: "doc.text.fill",      title: "Visa Services",      color: .purple)
                ServiceCard(icon: "heart.fill",         title: "Travel Insurance",   color: .red)
                ServiceCard(icon: "simcard.fill",       title: "International eSIM", color: .teal)
                ServiceCard(icon: "sparkles",           title: "Things To Do",       color: .yellow)
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .padding(.vertical, DesignTokens.Spacing.xxxl)
        .background(Color.ftdCardBackground)
    }

    // MARK: - Why Choose FTD

    private var whyChooseSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            SectionHeader(title: "Why Choose FTD Travel", subtitle: "Built with agents at the center of everything")

            VStack(spacing: DesignTokens.Spacing.md) {
                BenefitRow(icon: "tag.fill",          title: "Best B2B Pricing",        desc: "Competitive net fares across all travel categories")
                BenefitRow(icon: "lock.shield.fill",  title: "Secure & Reliable",       desc: "Enterprise-grade security with 99.9% uptime")
                BenefitRow(icon: "network",           title: "Largest Agent Network",   desc: "55,000+ agents growing every day across India")
                BenefitRow(icon: "headset",           title: "Dedicated Support",       desc: "Round-the-clock assistance for you and your clients")
                BenefitRow(icon: "chart.bar.fill",    title: "Advanced Analytics",      desc: "Real-time MIS reports and booking insights")
                BenefitRow(icon: "creditcard.fill",   title: "Flexible Payments",       desc: "Multiple payment modes with instant credit options")
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .padding(.vertical, DesignTokens.Spacing.xxxl)
    }

    // MARK: - Technology

    private var technologySection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            SectionHeader(title: "Powered by Technology", subtitle: "Built for scale, designed for simplicity")

            VStack(spacing: DesignTokens.Spacing.md) {
                TechCard(icon: "chevron.left.forwardslash.chevron.right",
                         title: "Enterprise APIs",
                         desc: "Seamlessly integrate our travel inventory into your own systems")
                TechCard(icon: "paintbrush.fill",
                         title: "White Label Solution",
                         desc: "Launch your branded travel portal powered by FTD")
                TechCard(icon: "tablecells.fill",
                         title: "Advanced MIS",
                         desc: "Comprehensive management information system with real-time data")
                TechCard(icon: "iphone.and.ipad",
                         title: "Multi-Platform Access",
                         desc: "Access FTD from web, iOS, and Android — anywhere, anytime")
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .padding(.vertical, DesignTokens.Spacing.xxxl)
        .background(Color.ftdCardBackground)
    }

    // MARK: - Awards

    private var awardsSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            SectionHeader(title: "Recognition & Awards", subtitle: "Acknowledged by industry leaders")

            FTDRemoteImage(url: URL(string: "https://www.ftd.travel/includes/img/award.webp"), contentMode: .fill) {
                HStack(spacing: DesignTokens.Spacing.md) {
                    AwardBadge(icon: "trophy.fill", title: "NASSCOM",  subtitle: "Recognized Member")
                    AwardBadge(icon: "medal.fill",  title: "Top 10",   subtitle: "Travel Tech Company")
                }
            }
            .cornerRadius(DesignTokens.Radius.card)
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        }
        .padding(.vertical, DesignTokens.Spacing.xxxl)
    }

    // MARK: - Contact

    private var contactSection: some View {
        VStack(spacing: 0) {
            VStack(spacing: DesignTokens.Spacing.lg) {
                SectionHeader(title: "Get In Touch", subtitle: "We're here to help you grow")

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    ContactRow(icon: "mappin.circle.fill",  text: "Tank Bund Road, Magadi Road, Bangalore – 560021, Karnataka, India")
                    ContactRow(icon: "phone.fill",          text: "+91 73533 11550")
                    ContactRow(icon: "envelope.fill",       text: "support@ftd.travel")
                    ContactRow(icon: "globe",               text: "www.ftd.travel")
                }
                .padding(DesignTokens.Spacing.xl)
                .background(Color.ftdCardBackground)
                .cornerRadius(DesignTokens.Radius.cardLg)
                .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            }
            .padding(.vertical, DesignTokens.Spacing.xxxl)
            .background(Color.ftdAccentOrange.opacity(0.05))

            Text("© \(Calendar.current.component(.year, from: Date())) FTD Travel. All rights reserved.")
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
    let subtitle: String

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundStyle(Color.ftdTextPrimary)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.custom("Poppins-Regular", size: 13))
                .foregroundStyle(Color.ftdTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
    }
}

private struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.ftdAccentOrange)

            Text(value)
                .font(.custom("Poppins-Bold", size: 22))
                .foregroundStyle(Color.ftdTextPrimary)

            Text(label)
                .font(.custom("Poppins-Regular", size: 11))
                .foregroundStyle(Color.ftdTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xl)
        .background(Color.ftdCardBackground)
        .cornerRadius(DesignTokens.Radius.card)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

private struct ServiceCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12))
                .cornerRadius(DesignTokens.Radius.field)

            Text(title)
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundStyle(Color.ftdTextPrimary)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .cornerRadius(DesignTokens.Radius.card)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

private struct BenefitRow: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.ftdAccentOrange)
                .frame(width: 40, height: 40)
                .background(Color.ftdAccentOrange.opacity(0.1))
                .cornerRadius(DesignTokens.Radius.field)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundStyle(Color.ftdTextPrimary)
                Text(desc)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundStyle(Color.ftdTextSecondary)
                    .lineSpacing(3)
            }
            Spacer(minLength: 0)
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .cornerRadius(DesignTokens.Radius.card)
        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}

private struct TechCard: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.ftdAccentOrange)
                .cornerRadius(DesignTokens.Radius.field)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(title)
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundStyle(Color.ftdTextPrimary)
                Text(desc)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundStyle(Color.ftdTextSecondary)
                    .lineSpacing(3)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct AwardBadge: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.ftdAccentOrange)

            Text(title)
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundStyle(Color.ftdTextPrimary)

            Text(subtitle)
                .font(.custom("Poppins-Regular", size: 11))
                .foregroundStyle(Color.ftdTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xl)
        .background(Color.ftdCardBackground)
        .cornerRadius(DesignTokens.Radius.card)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .stroke(Color.ftdAccentOrange.opacity(0.3), lineWidth: 1)
        )
    }
}

private struct ContactRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.ftdAccentOrange)
                .frame(width: 22)
            Text(text)
                .font(.custom("Poppins-Regular", size: 13))
                .foregroundStyle(Color.ftdTextPrimary)
                .lineSpacing(3)
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
