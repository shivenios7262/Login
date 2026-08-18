import SwiftUI

struct TransactionDetailView: View {
    let item: StatementItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            navBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignTokens.Spacing.md) {
                    headerCard
                    refIDCard
                    breakdownCard
                    remarkCard
                    backButton
                    chargeFormulaBanner
                    Spacer(minLength: DesignTokens.Spacing.xxl)
                }
                .padding(DesignTokens.Spacing.md)
            }
        }
        .background(Color.ftdInputBackground)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(Color.ftdCardBackground)
                        .frame(width: 36, height: 36)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.ftdTextPrimary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Transaction Details")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    // MARK: - Header Card

    private var headerCard: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.ftdAccentOrange)
                    .frame(width: 52, height: 52)
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text((item.trasactionType ?? "Transaction").uppercased())
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.ftdTextPrimary)
                Text(formatDetailDate(item.valueDate))
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary)
            }

            Spacer()

            amountText
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    @ViewBuilder
    private var amountText: some View {
        let debit = item.withdrawAmount?.trimmingCharacters(in: .whitespaces) ?? ""
        let credit = item.addBookingBalance?.trimmingCharacters(in: .whitespaces) ?? ""
        let isDebit = !debit.isEmpty && debit != "0" && debit != "0.0"
        if isDebit {
            Text("– ₹\(debit)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color(red: 0.85, green: 0.15, blue: 0.15))
        } else {
            Text("+ ₹\(credit.isEmpty || credit == "0" || credit == "0.0" ? "0" : credit)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color(red: 0.10, green: 0.60, blue: 0.25))
        }
    }

    // MARK: - Reference ID Card

    private var refIDCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Reference ID")
                .font(.caption)
                .foregroundStyle(Color.ftdTextSecondary)
            HStack {
                Text(item.transactionId ?? item.referenceNo ?? "-")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.ftdTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                Spacer()
                Button {
                    UIPasteboard.general.string = item.transactionId ?? item.referenceNo
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdTextSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - Transaction Breakdown Card

    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Transaction Breakdown")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)
                .padding(.bottom, DesignTokens.Spacing.sm)

            Group {
                breakdownRow("Debit",          value: item.withdrawAmount,    highlight: .debit)
                Divider().background(Color.ftdBorder.opacity(0.5))
                breakdownRow("Credit",         value: item.addBookingBalance, highlight: .credit)
                Divider().background(Color.ftdBorder.opacity(0.5))
                breakdownRow("Gross",          value: item.transactionAmount, highlight: .neutral)
                Divider().background(Color.ftdBorder.opacity(0.5))
                breakdownRow("Commission",     value: item.commission,        highlight: .neutral)
                Divider().background(Color.ftdBorder.opacity(0.5))
                breakdownRow("Txn Fees",       value: item.txnFees,           highlight: .neutral)
                Divider().background(Color.ftdBorder.opacity(0.5))
                breakdownRow("TDS",            value: item.tds,               highlight: .neutral)
            }
            Group {
                Divider().background(Color.ftdBorder.opacity(0.5))
                breakdownRow("PG Fees",        value: item.paymentCharge,     highlight: .neutral)
                Divider().background(Color.ftdBorder.opacity(0.5))
                breakdownRow("Balance",        value: item.bookingBalance,    highlight: .neutral)
                Divider().background(Color.ftdBorder.opacity(0.5))
                breakdownRow("Credit Balance", value: item.creditBalance,     highlight: .neutral)
                Divider().background(Color.ftdBorder.opacity(0.5))
                breakdownRow("Markup",         value: item.markup,            highlight: .neutral)
                Divider().background(Color.ftdBorder.opacity(0.5))
                breakdownRow("Insurance",      value: item.insuranceCharge,   highlight: .neutral)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    private enum NumHighlight { case debit, credit, neutral }

    private func breakdownRow(_ label: String, value: String?, highlight: NumHighlight) -> some View {
        let raw = value?.trimmingCharacters(in: .whitespaces) ?? ""
        let isZero = raw.isEmpty || raw == "0" || raw == "0.0"
        let display = isZero ? "₹0" : "₹\(raw)"
        let color: Color = {
            if isZero { return Color.ftdTextSecondary.opacity(0.5) }
            switch highlight {
            case .debit:   return Color(red: 0.85, green: 0.15, blue: 0.15)
            case .credit:  return Color(red: 0.10, green: 0.60, blue: 0.25)
            case .neutral: return Color.ftdTextPrimary
            }
        }()
        return HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
            Spacer()
            Text(display)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(color)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Remark Card

    private var remarkCard: some View {
        let r1 = item.addRemarks?.trimmingCharacters(in: .whitespaces) ?? ""
        let r2 = item.remarks?.trimmingCharacters(in: .whitespaces) ?? ""
        let remark = !r1.isEmpty ? r1 : !r2.isEmpty ? r2 : "-"
        return VStack(alignment: .leading, spacing: 4) {
            Text("Remark")
                .font(.caption)
                .foregroundStyle(Color.ftdTextSecondary)
            Text(remark)
                .font(.subheadline)
                .fontWeight(remark == "-" ? .regular : .medium)
                .foregroundStyle(remark == "-" ? Color.ftdTextSecondary : Color.ftdTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - Back Button

    private var backButton: some View {
        Button { dismiss() } label: {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Back To All Transactions")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color.ftdAccentOrange)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Charge Formula Banner

    private var chargeFormulaBanner: some View {
        InfoBanner(
            icon: .asset("iconShield"),
            showIconBackground: true,
            iconTint: .ftdMessageTextInfo,
            title: "Charge Calculation",
            message: "Charged = Gross (Including Insurance) - Commission + Transaction Fees + TDS"
        )
    }

    // MARK: - Date helpers

    private func formatDetailDate(_ raw: String?) -> String {
        guard let s = raw, s.count >= 10 else { return raw ?? "" }
        let key = String(s.prefix(10))
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        parser.locale = Locale(identifier: "en_US_POSIX")
        guard let date = parser.date(from: key) else { return s }
        let display = DateFormatter()
        display.dateFormat = "d MMM yyyy"
        if s.count > 10 {
            let timePart = String(s.dropFirst(11).prefix(8))
            let timeFmt = DateFormatter()
            timeFmt.dateFormat = "HH:mm:ss"
            if let timeDate = timeFmt.date(from: timePart) {
                let timeDsp = DateFormatter()
                timeDsp.dateFormat = "hh:mm a"
                return "\(display.string(from: date)) • \(timeDsp.string(from: timeDate))"
            }
        }
        return display.string(from: date)
    }
}
