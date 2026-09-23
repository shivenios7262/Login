import SwiftUI

struct ContactSupportView: View {

    @Bindable var viewModel: ContactSupportViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                infoPanel
                formPanel
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Help & Support")
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
        .disabled(viewModel.isSubmitting)
        .overlay {
            if alertBinding.wrappedValue {
                FTDAlertOverlay(
                    isSuccess: isAlertSuccess,
                    title: alertTitle,
                    message: alertMessage,
                    onDismiss: { viewModel.dismissAlert() }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: alertBinding.wrappedValue)
    }

    private static let experienceServices: [(url: URL?, label: String)] = [
        (FTDImageURL.contactBanner(1), "Flights"),
        (FTDImageURL.contactBanner(2), "Buses"),
        (FTDImageURL.contactBanner(3), "Hotels"),
        (FTDImageURL.contactBanner(4), "Visa"),
        (FTDImageURL.contactBanner(5), "Cabs"),
        (FTDImageURL.contactBanner(6), "Insurance"),
        (FTDImageURL.contactBanner(7), "Experiences"),
    ]
    // MARK: - Info Panel

    private var infoPanel: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text("Get in touch")
                    .font(.custom("Poppins-SemiBold", size: 13))
                    .foregroundStyle(Color.ftdAccentOrange)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text("Need more details?\nDon't hesitate to connect with us!")
                    .font(.custom("Poppins-Bold", size: 20))
                    .foregroundStyle(Color.ftdTextPrimary)
                    .lineSpacing(3)

                Text("Have a question or need travel assistance? Our team at FTD Travel is here to help you plan, book, or customise your next journey. Get in touch—we'd love to hear from you!")
                    .font(.custom("Poppins-Regular", size: 13))
                    .foregroundStyle(Color.ftdTextSecondary)
                    .lineSpacing(4)
                    .padding(.top, DesignTokens.Spacing.xxs)
            }

            VStack(spacing: DesignTokens.Spacing.sm) {
                ContactInfoRow(icon: "phone.fill",    label: "Call us at",        value: "+91 73533 11550")
                ContactInfoRow(icon: "envelope.fill", label: "Customer Support",  value: "admin@ftd.travel")
                ContactInfoRow(icon: "mappin.circle.fill",   label: "Address",           value: "1035, 1st Floor, 4th M Block, Dr RajKumar Road, RajiNagar, Bangalore – 560010")
            }
        }
        .padding(DesignTokens.Spacing.screenHorizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.ftdCardBackground)
    }

    // MARK: - Form Panel

    private var formPanel: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {

            // We serve best experience in
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Group {
                    Text("We serve best experience ").foregroundStyle(Color.ftdTextPrimary) +
                    Text("in").foregroundStyle(Color.ftdAccentOrange)
                }
                .font(.custom("Poppins-Bold", size: 16))

                ForEach([0, 2, 4], id: \.self) { start in
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(Self.experienceServices[start..<(start + 2)], id: \.label) { item in
                            ServiceCard(url: item.url, label: item.label)
                        }
                    }
                }
                // Last card centered at half-row width
                GeometryReader { geo in
                    let cardWidth = (geo.size.width - DesignTokens.Spacing.sm) / 2
                    HStack {
                        Spacer()
                        ServiceCard(
                            url: Self.experienceServices[6].url,
                            label: Self.experienceServices[6].label
                        )
                        .frame(width: cardWidth, height: 90)
                        Spacer()
                    }
                }
                .frame(height: 90)
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Group {
                    Text("Contact ").foregroundStyle(Color.ftdAccentOrange) +
                    Text("Our Travel Experts").foregroundStyle(Color.ftdTextPrimary)
                }
                .font(.custom("Poppins-Bold", size: 18))
            }

            // Name + Mobile side by side
            HStack(spacing: DesignTokens.Spacing.md) {
                FormField(label: "Name", placeholder: "Enter your name", text: $viewModel.name,
                          error: viewModel.nameError)
                FormField(label: "Mobile Number", placeholder: "Enter phone number", text: $viewModel.mobile,
                          error: viewModel.mobileError)
                    .keyboardType(.phonePad)
                    .onChange(of: viewModel.mobile) { _, new in
                        let digits = new.filter(\.isNumber)
                        if digits.count > 10 { viewModel.mobile = String(digits.prefix(10)) }
                        else if digits != new { viewModel.mobile = digits }
                    }
            }

            FormField(label: "Email Address", placeholder: "Enter your email address", text: $viewModel.email,
                      error: viewModel.emailError)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                Text("Message")
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundStyle(Color.ftdTextSecondary)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .stroke(viewModel.messageError != nil ? Color.ftdDestructiveRed : Color.ftdBorder, lineWidth: 1)
                        .background(Color(.systemBackground).cornerRadius(DesignTokens.Radius.field))

                    TextEditor(text: $viewModel.message)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundStyle(Color.ftdTextPrimary)
                        .scrollContentBackground(.hidden)
                        .padding(DesignTokens.Spacing.sm)
                        .frame(minHeight: 100)

                    if viewModel.message.isEmpty {
                        Text("Enter your comments here")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundStyle(Color.ftdTextSecondary.opacity(0.55))
                            .padding(.top, DesignTokens.Spacing.sm + 4)
                            .padding(.leading, DesignTokens.Spacing.sm + 4)
                            .allowsHitTesting(false)
                    }
                }
                .frame(minHeight: 110)

                if let error = viewModel.messageError {
                    Text(error)
                        .font(.custom("Poppins-Regular", size: 11))
                        .foregroundStyle(Color.ftdDestructiveRed)
                }
            }

            // Submit button
            Button {
                Task { await viewModel.submit() }
            } label: {
                ZStack {
                    if viewModel.isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Submit")
                            .font(.custom("Poppins-SemiBold", size: 15))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(viewModel.isFormValid ? Color.ftdAccentOrange : Color.ftdAccentOrange.opacity(0.45))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
            }
            .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
        }
        .padding(DesignTokens.Spacing.screenHorizontal)
        .padding(.vertical, DesignTokens.Spacing.xl)
    }

    // MARK: - Alert helpers

    private var isAlertSuccess: Bool {
        if case .success = viewModel.phase { return true }
        return false
    }

    private var alertTitle: String {
        if case .success = viewModel.phase { return "Message Sent!" }
        return "Something went wrong"
    }

    private var alertMessage: String {
        switch viewModel.phase {
        case .success(let msg): return msg
        case .failure(let msg): return msg
        default: return ""
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: {
                if case .success = viewModel.phase { return true }
                if case .failure = viewModel.phase { return true }
                return false
            },
            set: { if !$0 { viewModel.dismissAlert() } }
        )
    }
}

// MARK: - Sub-components

private struct ContactInfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.ftdAccentOrange.opacity(0.12))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.ftdAccentOrange)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.custom("Poppins-SemiBold", size: 13))
                    .foregroundStyle(Color.ftdTextPrimary)
                Text(value)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundStyle(Color.ftdTextSecondary)
                    .lineSpacing(3)
            }
            Spacer(minLength: 0)
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(DesignTokens.Radius.card)
    }
}

private struct ServiceCard: View {
    let url: URL?
    let label: String

    var body: some View {
        FTDRemoteImage(url: url, contentMode: .fill)
            .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
            .clipped()
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [.clear, .black.opacity(0.65)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
            .overlay(alignment: .bottom) {
                Text(label)
                    .font(.custom("Poppins-SemiBold", size: 11))
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)
            }
            .background(Color(.systemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }
}

private struct FTDAlertOverlay: View {
    let isSuccess: Bool
    let title: String
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: DesignTokens.Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(isSuccess ? Color.ftdAccentOrange.opacity(0.12) : Color.red.opacity(0.1))
                        .frame(width: 68, height: 68)
                    Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(isSuccess ? Color.ftdAccentOrange : .red)
                }

                VStack(spacing: DesignTokens.Spacing.xs) {
                    Text(title)
                        .font(.custom("Poppins-Bold", size: 17))
                        .foregroundStyle(Color.ftdTextPrimary)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(.custom("Poppins-Regular", size: 13))
                        .foregroundStyle(Color.ftdTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Button(action: onDismiss) {
                    Text("OK")
                        .font(.custom("Poppins-SemiBold", size: 15))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.ftdAccentOrange)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
                }
            }
            .padding(DesignTokens.Spacing.xl)
            .background(Color.ftdCardBackground)
            .cornerRadius(DesignTokens.Radius.cardLg)
            .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 10)
            .padding(.horizontal, 40)
        }
    }
}

private struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var error: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
            Text(label)
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundStyle(Color.ftdTextSecondary)

            TextField(placeholder, text: $text)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundStyle(Color.ftdTextPrimary)
                .padding(DesignTokens.Spacing.sm)
                .background(Color(.systemBackground))
                .cornerRadius(DesignTokens.Radius.field)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .stroke(error != nil ? Color.ftdDestructiveRed : Color.ftdBorder, lineWidth: 1)
                )

            if let error {
                Text(error)
                    .font(.custom("Poppins-Regular", size: 11))
                    .foregroundStyle(Color.ftdDestructiveRed)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
