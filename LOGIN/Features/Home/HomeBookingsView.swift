import SwiftUI

struct HomeBookingsView<VM: B2BDataProvider>: View {
    var viewModel: VM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("My Bookings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        backButton
                    }
                }
        }
        .task { await viewModel.fetchBookings() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoadingBookings {
            stateView(icon: nil, message: nil, isLoading: true)
        } else if let error = viewModel.bookingsError {
            stateView(icon: "exclamationmark.triangle", message: error, isLoading: false, retry: {
                Task { await viewModel.fetchBookings() }
            })
        } else if viewModel.bookings.isEmpty {
            stateView(icon: "ticket", message: "No flight bookings in the last 30 days.", isLoading: false)
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.bookings) { booking in
                        bookingCard(booking)
                    }
                }
                .padding(16)
            }
            .background(Color("InputBackground"))
        }
    }

    private func bookingCard(_ b: AgentFlightBooking) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Route header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(b.origin ?? "-")
                            .font(.title3).fontWeight(.bold)
                            .foregroundStyle(Color("TextPrimary"))
                        Image(systemName: "airplane")
                            .font(.caption).foregroundStyle(Color("AccentOrange"))
                        Text(b.destination ?? "-")
                            .font(.title3).fontWeight(.bold)
                            .foregroundStyle(Color("TextPrimary"))
                    }
                    Text("\(b.originCity ?? "") → \(b.destinationCity ?? "")")
                        .font(.caption2).foregroundStyle(Color("TextSecondary"))
                }
                Spacer()
                statusBadge(b.status)
            }
            .padding(14)

            Divider().padding(.horizontal, 14)

            // Details grid
            HStack(spacing: 0) {
                infoCol("Airline",   b.carrierName ?? b.carrier)
                infoCol("PNR",       b.pnr)
                infoCol("Depart",    b.departureDate)
                infoCol("Time",      formattedTime(b.departureTime))
            }
            .padding(.horizontal, 14).padding(.vertical, 10)

            if let passengers = b.passengers, !passengers.isEmpty {
                Divider().padding(.horizontal, 14)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(passengers.enumerated()), id: \.offset) { _, p in
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.caption2).foregroundStyle(Color("AccentOrange"))
                            Text(p.fullName).font(.caption).foregroundStyle(Color("TextPrimary"))
                            if let t = p.passengerType {
                                Text("(\(t))").font(.caption2).foregroundStyle(Color("TextSecondary"))
                            }
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
            }

            Divider().padding(.horizontal, 14)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ref No").font(.caption2).foregroundStyle(Color("TextSecondary"))
                    Text(b.uniqueRefNo ?? "-").font(.caption).fontWeight(.semibold)
                        .foregroundStyle(Color("AccentOrange"))
                }
                Spacer()
                if let fare = b.totalFare, !fare.isEmpty {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Fare").font(.caption2).foregroundStyle(Color("TextSecondary"))
                        Text("₹\(fare)").font(.subheadline).fontWeight(.bold)
                            .foregroundStyle(Color("TextPrimary"))
                    }
                }
            }
            .padding(14)
        }
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color("BorderColor"), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private func infoCol(_ title: String, _ value: String?) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.caption2).foregroundStyle(Color("TextSecondary"))
            Text(value ?? "-").font(.caption).fontWeight(.semibold)
                .foregroundStyle(Color("TextPrimary")).lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statusBadge(_ status: String?) -> some View {
        let s = status ?? "-"
        let color: Color = s.lowercased() == "success" ? .green : s.lowercased() == "cancelled" ? .red : Color("AccentOrange")
        return Text(s).font(.caption2).fontWeight(.bold)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(color.opacity(0.12)).foregroundStyle(color).clipShape(Capsule())
    }

    private func formattedTime(_ raw: String?) -> String? {
        guard let raw, raw.count >= 4 else { return raw }
        return "\(raw.prefix(raw.count - 2)):\(raw.suffix(2))"
    }

    private func stateView(icon: String?, message: String?, isLoading: Bool, retry: (() -> Void)? = nil) -> some View {
        VStack(spacing: 16) {
            Spacer()
            if isLoading {
                ProgressView().scaleEffect(1.3)
                Text("Loading bookings…").font(.subheadline).foregroundStyle(Color("TextSecondary"))
            } else {
                if let icon { Image(systemName: icon).font(.system(size: 52)).foregroundStyle(Color("TextSecondary").opacity(0.35)) }
                if let message { Text(message).font(.subheadline).multilineTextAlignment(.center).foregroundStyle(Color("TextSecondary")).padding(.horizontal, 32) }
                if let retry {
                    Button("Retry", action: retry).buttonStyle(.borderedProminent).tint(Color("AccentOrange"))
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("InputBackground"))
    }

    private var backButton: some View {
        Button { dismiss() } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left").fontWeight(.semibold)
                Text("Back")
            }
            .foregroundStyle(Color("AccentOrange"))
        }
    }
}
