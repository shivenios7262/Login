import SwiftUI

struct MyBookingsView<VM: BookingsProvider>: View {
    var viewModel: VM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("My Bookings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: DesignTokens.Spacing.xs) {
                                Image(systemName: "chevron.left")
                                    .fontWeight(.semibold)
                                Text("Back")
                            }
                            .foregroundStyle(Color.ftdAccentOrange)
                        }
                    }
                }
        }
        .task {
            await viewModel.fetchBookings()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingBookings {
            loadingView
        } else if let error = viewModel.bookingsError {
            errorView(error)
        } else if viewModel.bookings.isEmpty {
            emptyView
        } else {
            bookingsList
        }
    }

    // MARK: - List

    private var bookingsList: some View {
        ScrollView {
            LazyVStack(spacing: DesignTokens.Spacing.md) {
                ForEach(viewModel.bookings) { booking in
                    bookingCard(booking)
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
        .background(Color.ftdInputBackground)
    }

    // MARK: - Booking Card

    private func bookingCard(_ b: AgentFlightBooking) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: route + status
            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                HStack(spacing: DesignTokens.Spacing.sm - 2) {
                    VStack(spacing: DesignTokens.Spacing.xxs) {
                        Text(b.origin ?? "-")
                            .font(.title3).fontWeight(.bold)
                            .foregroundStyle(Color.ftdTextPrimary)
                        Text(b.originCity ?? "")
                            .font(.caption2)
                            .foregroundStyle(Color.ftdTextSecondary)
                            .lineLimit(1)
                    }
                    Image(systemName: "airplane")
                        .font(.caption)
                        .foregroundStyle(Color.ftdAccentOrange)
                    VStack(spacing: DesignTokens.Spacing.xxs) {
                        Text(b.destination ?? "-")
                            .font(.title3).fontWeight(.bold)
                            .foregroundStyle(Color.ftdTextPrimary)
                        Text(b.destinationCity ?? "")
                            .font(.caption2)
                            .foregroundStyle(Color.ftdTextSecondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                statusBadge(b.status)
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, DesignTokens.Spacing.inputVertical)

            Divider().padding(.horizontal, 14)

            // Middle: airline info + departure
            HStack(alignment: .top, spacing: 0) {
                infoColumn("Airline",  value: b.carrierName ?? b.carrier)
                infoColumn("PNR",      value: b.pnr)
                infoColumn("Depart",   value: formattedDate(b.departureDate))
                infoColumn("Time",     value: formattedTime(b.departureTime))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, DesignTokens.Spacing.inputVertical)

            Divider().padding(.horizontal, 14)

            // Passengers
            if let passengers = b.passengers, !passengers.isEmpty {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text("Passengers")
                        .font(.caption2).fontWeight(.semibold)
                        .foregroundStyle(Color.ftdTextSecondary)
                    ForEach(Array(passengers.enumerated()), id: \.offset) { _, pax in
                        HStack(spacing: DesignTokens.Spacing.sm - 2) {
                            Image(systemName: "person.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.ftdAccentOrange)
                            Text(pax.fullName)
                                .font(.caption)
                                .foregroundStyle(Color.ftdTextPrimary)
                            if let type = pax.passengerType {
                                Text("(\(type))")
                                    .font(.caption2)
                                    .foregroundStyle(Color.ftdTextSecondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, DesignTokens.Spacing.inputVertical)

                Divider().padding(.horizontal, 14)
            }

            // Footer: ref no + fare
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    Text("Ref No")
                        .font(.caption2).foregroundStyle(Color.ftdTextSecondary)
                    Text(b.uniqueRefNo ?? "-")
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(Color.ftdAccentOrange)
                }
                Spacer()
                if let fare = b.totalFare, !fare.isEmpty {
                    VStack(alignment: .trailing, spacing: DesignTokens.Spacing.xxs) {
                        Text("Total Fare")
                            .font(.caption2).foregroundStyle(Color.ftdTextSecondary)
                        Text("₹\(fare)")
                            .font(.subheadline).fontWeight(.bold)
                            .foregroundStyle(Color.ftdTextPrimary)
                    }
                }
                if let net = b.agentNetPrice, !net.isEmpty {
                    VStack(alignment: .trailing, spacing: DesignTokens.Spacing.xxs) {
                        Text("Net Price")
                            .font(.caption2).foregroundStyle(Color.ftdTextSecondary)
                        Text("₹\(net)")
                            .font(.subheadline).fontWeight(.bold)
                            .foregroundStyle(Color.ftdAccentTeal)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, DesignTokens.Spacing.inputVertical)
        }
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.cardLg))
        .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.cardLg).stroke(Color.ftdBorder, lineWidth: 0.5))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    // MARK: - Helpers

    private func statusBadge(_ status: String?) -> some View {
        let s = status ?? "-"
        let color: Color = {
            switch s.lowercased() {
            case "success", "confirmed", "booked": return .green
            case "cancelled", "failed":            return .red
            case "pending":                        return .ftdAccentOrange
            default:                               return .ftdTextSecondary
            }
        }()
        return Text(s)
            .font(.caption2).fontWeight(.bold)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func infoColumn(_ title: String, value: String?) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
            Text(title)
                .font(.caption2).foregroundStyle(Color.ftdTextSecondary)
            Text(value?.nilIfEmpty ?? "-")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formattedDate(_ raw: String?) -> String? {
        guard let raw, !raw.isEmpty else { return nil }
        let src = DateFormatter(); src.dateFormat = "yyyy-MM-dd"
        let dst = DateFormatter(); dst.dateFormat = "dd MMM yy"
        return src.date(from: raw).map { dst.string(from: $0) } ?? raw
    }

    private func formattedTime(_ raw: String?) -> String? {
        guard let raw, raw.count >= 4 else { return raw }
        let h = raw.prefix(raw.count - 2)
        let m = raw.suffix(2)
        return "\(h):\(m)"
    }

    // MARK: - State Views

    private var loadingView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ProgressView().scaleEffect(1.3)
            Text("Loading bookings…")
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ftdInputBackground)
    }

    private var emptyView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Spacer()
            Image(systemName: "ticket")
                .font(.ftdHeroIcon)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.35))
            Text("No bookings found")
                .font(.title3).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextSecondary)
            Text("Flight bookings from the last 30 days will appear here.")
                .font(.subheadline).multilineTextAlignment(.center)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.7))
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ftdInputBackground)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.ftdHeroIcon)
                .foregroundStyle(Color.ftdAccentOrange.opacity(0.6))
            Text(message)
                .font(.subheadline).multilineTextAlignment(.center)
                .foregroundStyle(Color.ftdTextSecondary)
                .padding(.horizontal, 32)
            Button("Retry") {
                Task { await viewModel.fetchBookings() }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.ftdAccentOrange)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ftdInputBackground)
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
