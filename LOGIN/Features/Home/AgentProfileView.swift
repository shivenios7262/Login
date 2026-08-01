import SwiftUI

struct AgentProfileView<VM: ProfileProvider>: View {
    var viewModel: VM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("My Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button { dismiss() } label: {
                            HStack(spacing: DesignTokens.Spacing.xs) {
                                Image(systemName: "chevron.left").fontWeight(.semibold)
                                Text("Back")
                            }
                            .foregroundStyle(Color.ftdAccentOrange)
                        }
                    }
                }
        }
        .task { await viewModel.fetchProfile() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingProfile {
            loadingView("Loading profile…")
        } else if let error = viewModel.profileError {
            errorView(error) { Task { await viewModel.fetchProfile() } }
        } else if let profile = viewModel.profile {
            profileContent(profile)
        } else {
            emptyView("No profile data available.")
        }
    }

    private func profileContent(_ p: AgentProfileData) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.ftdAccentOrange, Color.ftdAccentTeal],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 72, height: 72)
                        Text(initials(p))
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Text(fullName(p))
                        .font(.title3).fontWeight(.bold).foregroundStyle(Color.ftdTextPrimary)
                    if let agency = p.agencyName {
                        Text(agency).font(.subheadline).foregroundStyle(Color.ftdTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.xxl)
                .background(Color.ftdCardBackground)

                if p.creditBalance != nil || p.bookingBalance != nil {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        balanceCard("Credit Balance",  amount: p.creditBalance,  color: Color.ftdAccentOrange)
                        balanceCard("Booking Balance", amount: p.bookingBalance, color: Color.ftdAccentTeal)
                    }
                    .padding(DesignTokens.Spacing.lg)
                }

                infoSection("Contact", rows: [
                    ("envelope",         "Email",   p.agentEmail),
                    ("phone",            "Mobile",  p.mobileNo),
                    ("phone.badge.plus", "Office",  p.officePhoneNo),
                    ("globe",            "Website", p.website),
                ])
                infoSection("Identity", rows: [
                    ("number",     "Agent No",   p.agentNo),
                    ("building.2", "Agent ID",   p.agentId),
                    ("briefcase",  "Agent Type", p.agentType),
                    ("doc.text",   "PAN No",     p.panNo),
                ])
                infoSection("Address", rows: [
                    ("mappin",   "Address",  p.address),
                    ("building", "City",     p.city),
                    ("map",      "State",    p.state),
                    ("globe",    "Country",  p.country),
                    ("number",   "PIN Code", p.pinCode),
                ])
            }
        }
        .background(Color.ftdInputBackground)
    }

    private func balanceCard(_ title: String, amount: String?, color: Color) -> some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text(title).font(.caption2).foregroundStyle(Color.ftdTextSecondary)
            Text(amount.map { "₹\($0)" } ?? "-")
                .font(.headline).fontWeight(.bold).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.card).stroke(color.opacity(0.2), lineWidth: 1))
    }

    private func infoSection(_ title: String, rows: [(String, String, String?)]) -> some View {
        let visibleRows = rows.filter { $0.2 != nil && !($0.2!.isEmpty) }
        guard !visibleRows.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.top, DesignTokens.Spacing.xl)
                    .padding(.bottom, DesignTokens.Spacing.sm - 2)

                VStack(spacing: 0) {
                    ForEach(Array(visibleRows.enumerated()), id: \.offset) { idx, row in
                        HStack(spacing: DesignTokens.Spacing.md) {
                            Image(systemName: row.0)
                                .font(.system(size: DesignTokens.IconSize.sm))
                                .frame(width: 20)
                                .foregroundStyle(Color.ftdAccentOrange)
                            Text(row.1)
                                .font(.subheadline)
                                .foregroundStyle(Color.ftdTextSecondary)
                                .frame(width: 100, alignment: .leading)
                            Text(row.2 ?? "")
                                .font(.subheadline).fontWeight(.medium)
                                .foregroundStyle(Color.ftdTextPrimary)
                            Spacer()
                        }
                        .padding(.horizontal, DesignTokens.Spacing.lg)
                        .padding(.vertical, DesignTokens.Spacing.md)
                        if idx < visibleRows.count - 1 {
                            Divider().padding(.leading, 48)
                        }
                    }
                }
                .background(Color.ftdCardBackground)
            }
        )
    }

    private func fullName(_ p: AgentProfileData) -> String {
        [p.title, p.firstName, p.lastName]
            .compactMap { $0?.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .nilIfEmpty ?? p.agencyName ?? "Agent"
    }

    private func initials(_ p: AgentProfileData) -> String {
        let words = [p.firstName, p.lastName].compactMap { $0?.first.map { String($0).uppercased() } }
        return words.isEmpty ? "?" : words.joined()
    }
}

// MARK: - Statement View

struct StatementView<VM: StatementProvider>: View {
    var viewModel: VM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Statement")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button { dismiss() } label: {
                            HStack(spacing: DesignTokens.Spacing.xs) {
                                Image(systemName: "chevron.left").fontWeight(.semibold)
                                Text("Back")
                            }
                            .foregroundStyle(Color.ftdAccentOrange)
                        }
                    }
                }
        }
        .task { await viewModel.fetchStatement() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingStatement {
            loadingView("Loading statement…")
        } else if let error = viewModel.statementError {
            errorView(error) { Task { await viewModel.fetchStatement() } }
        } else if viewModel.statements.isEmpty {
            emptyView("No transactions in the last 30 days.")
        } else {
            ScrollView {
                LazyVStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(viewModel.statements) { item in
                        statementRow(item)
                    }
                }
                .padding(DesignTokens.Spacing.lg)
            }
            .background(Color.ftdInputBackground)
        }
    }

    private func statementRow(_ item: StatementItem) -> some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            let isCredit = !(item.credit?.isEmpty ?? true)
            ZStack {
                Circle()
                    .fill(isCredit ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: isCredit ? "arrow.down.left" : "arrow.up.right")
                    .font(.system(size: DesignTokens.IconSize.sm, weight: .semibold))
                    .foregroundStyle(isCredit ? .green : .red)
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                Text(item.description ?? item.transactionType ?? "-")
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                HStack(spacing: DesignTokens.Spacing.sm) {
                    if let date = item.date {
                        Text(date).font(.caption2).foregroundStyle(Color.ftdTextSecondary)
                    }
                    if let ref = item.referenceNo ?? item.bookingId {
                        Text(ref).font(.caption2).foregroundStyle(Color.ftdTextSecondary).lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: DesignTokens.Spacing.inputLabelGap) {
                if let credit = item.credit, !credit.isEmpty {
                    Text("+₹\(credit)").font(.subheadline).fontWeight(.bold).foregroundStyle(.green)
                } else if let debit = item.debit, !debit.isEmpty {
                    Text("-₹\(debit)").font(.subheadline).fontWeight(.bold).foregroundStyle(.red)
                }
                if let bal = item.balance, !bal.isEmpty {
                    Text("Bal: ₹\(bal)").font(.caption2).foregroundStyle(Color.ftdTextSecondary)
                }
            }
        }
        .padding(14)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.card).stroke(Color.ftdBorder, lineWidth: 0.5))
    }
}

// MARK: - Markup View

struct MarkupView<VM: MarkupsProvider>: View {
    var viewModel: VM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("My Markup")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button { dismiss() } label: {
                            HStack(spacing: DesignTokens.Spacing.xs) {
                                Image(systemName: "chevron.left").fontWeight(.semibold)
                                Text("Back")
                            }
                            .foregroundStyle(Color.ftdAccentOrange)
                        }
                    }
                }
        }
        .task { await viewModel.fetchMarkups() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingMarkups {
            loadingView("Loading markups…")
        } else if let error = viewModel.markupsError {
            errorView(error) { Task { await viewModel.fetchMarkups() } }
        } else if viewModel.markups.isEmpty {
            emptyView("No markup configuration found.")
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        headerCell("Service", flex: 2)
                        headerCell("Airline", flex: 1)
                        headerCell("Type",    flex: 1)
                        headerCell("Value",   flex: 1)
                    }
                    .background(Color.ftdAccentOrange.opacity(0.1))

                    Divider()

                    ForEach(Array(viewModel.markups.enumerated()), id: \.offset) { idx, item in
                        HStack(spacing: 0) {
                            dataCell(item.serviceType, flex: 2, primary: true)
                            dataCell(item.airline ?? item.cabType, flex: 1)
                            dataCell(item.markupType, flex: 1)
                            dataCell(item.markupValue, flex: 1, accent: true)
                        }
                        .background(idx % 2 == 0 ? Color.ftdCardBackground : Color.ftdInputBackground)
                        if idx < viewModel.markups.count - 1 { Divider() }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
                .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.card).stroke(Color.ftdBorder, lineWidth: 0.5))
                .padding(DesignTokens.Spacing.lg)
            }
            .background(Color.ftdInputBackground)
        }
    }

    private func headerCell(_ title: String, flex: Int) -> some View {
        Text(title)
            .font(.caption).fontWeight(.semibold)
            .foregroundStyle(Color.ftdAccentOrange)
            .padding(.vertical, DesignTokens.Spacing.inputVertical)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dataCell(_ value: String?, flex: Int, primary: Bool = false, accent: Bool = false) -> some View {
        Text(value ?? "-")
            .font(.caption)
            .fontWeight(primary ? .semibold : .regular)
            .foregroundStyle(accent ? Color.ftdAccentOrange : primary ? Color.ftdTextPrimary : Color.ftdTextSecondary)
            .padding(.vertical, DesignTokens.Spacing.md)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(1)
    }
}

// MARK: - Shared state views (file-private)

private func loadingView(_ message: String) -> some View {
    VStack(spacing: DesignTokens.Spacing.md) {
        Spacer()
        ProgressView().scaleEffect(1.3)
        Text(message).font(.subheadline).foregroundStyle(Color.ftdTextSecondary)
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.ftdInputBackground)
}

private func emptyView(_ message: String) -> some View {
    VStack(spacing: DesignTokens.Spacing.md) {
        Spacer()
        Image(systemName: "tray")
            .font(.system(size: DesignTokens.IconSize.hero))
            .foregroundStyle(Color.ftdTextSecondary.opacity(0.35))
        Text(message).font(.subheadline).multilineTextAlignment(.center)
            .foregroundStyle(Color.ftdTextSecondary).padding(.horizontal, 40)
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.ftdInputBackground)
}

private func errorView(_ message: String, retry: @escaping () -> Void) -> some View {
    VStack(spacing: DesignTokens.Spacing.lg) {
        Spacer()
        Image(systemName: "exclamationmark.triangle")
            .font(.system(size: DesignTokens.IconSize.hero))
            .foregroundStyle(Color.ftdAccentOrange.opacity(0.6))
        Text(message).font(.subheadline).multilineTextAlignment(.center)
            .foregroundStyle(Color.ftdTextSecondary).padding(.horizontal, 32)
        Button("Retry", action: retry).buttonStyle(.borderedProminent).tint(Color.ftdAccentOrange)
        Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.ftdInputBackground)
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
