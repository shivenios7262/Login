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
        .alert(alertTitle, isPresented: alertBinding) {
            Button("OK") { viewModel.dismissAlert() }
        } message: {
            Text(alertMessage)
        }
        .disabled(viewModel.isSubmitting)
    }

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
                ContactInfoRow(icon: "mappin.fill",   label: "Address",           value: "1035, 1st Floor, 4th M Block, Dr RajKumar Road, RajiNagar, Bangalore – 560010")
            }
        }
        .padding(DesignTokens.Spacing.screenHorizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.ftdCardBackground)
    }

    // MARK: - Form Panel

    private var formPanel: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Group {
                    Text("Contact ").foregroundStyle(Color.ftdAccentOrange) +
                    Text("Our Travel Experts").foregroundStyle(Color.ftdTextPrimary)
                }
                .font(.custom("Poppins-Bold", size: 18))
            }

            // Name + Mobile side by side
            HStack(spacing: DesignTokens.Spacing.md) {
                FormField(label: "Name", placeholder: "Enter your name", text: $viewModel.name)
                FormField(label: "Mobile Number", placeholder: "Enter phone number", text: $viewModel.mobile)
                    .keyboardType(.phonePad)
            }

            FormField(label: "Email Address", placeholder: "Enter your email address", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                Text("Message")
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundStyle(Color.ftdTextSecondary)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .stroke(Color.ftdBorder, lineWidth: 1)
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

private struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

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
                        .stroke(Color.ftdBorder, lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity)
    }
}
