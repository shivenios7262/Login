import SwiftUI

struct BookingCalendarView: View {
    @Bindable var viewModel: BookingCalendarViewModel
    @Environment(\.dismiss) private var dismiss

    private static let weekdayHeaders = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                controlsBar
                Divider().overlay(Color.ftdBorder.opacity(0.5))
                calendarBody
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color.ftdInputBackground)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.ftdCardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "Booking Calendar"))
                        .font(.ftdSectionHeaderMedium)
                        .foregroundStyle(Color.ftdTextPrimary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image("back")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.ftdTextPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.ftdCardBackground)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "Close"))
                }
            }
        }
        .task { await viewModel.fetchBookedDates() }
        .onChange(of: viewModel.currentDate) { _, _ in
            Task { await viewModel.fetchBookedDates() }
        }
    }

    // MARK: - Controls Bar

    private var controlsBar: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                // Prev / Next
                HStack(spacing: DesignTokens.Spacing.xs) {
                    navButton(icon: "chevron.left")  { viewModel.goPrev() }
                    navButton(icon: "chevron.right") { viewModel.goNext() }
                }

                Button { viewModel.goToToday() } label: {
                    Text(String(localized: "today"))
                        .font(.ftdLabelMD)
                        .foregroundStyle(Color.ftdTextPrimary)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(Color.ftdInputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                                .stroke(Color.ftdBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Spacer()

                // View-mode toggle
                HStack(spacing: 0) {
                    ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                        viewModeButton(mode)
                    }
                }
                .background(Color.ftdInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .stroke(Color.ftdBorder, lineWidth: 1)
                )

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.75)
                        .tint(Color.ftdAccentOrange)
                }
            }

            // Period title
            Text(viewModel.headerTitle)
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
    }

    private func navButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.ftdTextPrimary)
                .frame(width: 32, height: 32)
                .background(Color.ftdInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .stroke(Color.ftdBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func viewModeButton(_ mode: CalendarViewMode) -> some View {
        let isSelected = viewModel.viewMode == mode
        return Button {
            withAnimation(.easeInOut(duration: DesignTokens.Animation.fast)) {
                viewModel.viewMode = mode
            }
        } label: {
            Text(mode.rawValue)
                .font(.ftdLabelMD)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, 6)
                .background(isSelected ? Color.ftdBorder : Color.clear)
                .foregroundStyle(isSelected ? Color.ftdTextPrimary : Color.ftdTextSecondary)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: viewModel.viewMode)
    }

    // MARK: - Calendar Body

    @ViewBuilder
    private var calendarBody: some View {
        switch viewModel.viewMode {
        case .month: monthView
        case .week:  weekView
        case .day:   dayView
        }
    }

    // MARK: - Month View

    private var monthView: some View {
        VStack(spacing: 0) {
            weekdayHeaderRow
            Divider().overlay(Color.ftdBorder.opacity(0.4))
            monthGrid
            Spacer(minLength: 0)
        }
        .background(Color.ftdCardBackground)
    }

    private var weekdayHeaderRow: some View {
        HStack(spacing: 0) {
            ForEach(Self.weekdayHeaders, id: \.self) { day in
                Text(day)
                    .font(.caption2).fontWeight(.semibold)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.sm)
            }
        }
        .background(Color.ftdInputBackground)
    }

    private var monthGrid: some View {
        let days = viewModel.monthGridDays
        let rows = max(1, days.count / 7)

        return VStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { col in
                        let idx = row * 7 + col
                        if idx < days.count, let date = days[idx] {
                            monthDayCell(date)
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DesignTokens.Spacing.md)
                        }
                    }
                }
                if row < rows - 1 {
                    Divider().overlay(Color.ftdBorder.opacity(0.3))
                }
            }
        }
    }

    private func monthDayCell(_ date: Date) -> some View {
        let isToday     = viewModel.isToday(date)
        let hasBooking  = viewModel.hasBooking(on: date)
        let inMonth     = viewModel.isCurrentMonth(date)

        return VStack(spacing: DesignTokens.Spacing.xxs) {
            // Booking indicator
            if hasBooking {
                ZStack {
                    Circle()
                        .fill(Color.ftdAccentTeal.opacity(0.85))
                        .frame(width: 28, height: 28)
                    Image(systemName: "airplane")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                }
            } else {
                Spacer().frame(width: 28, height: 28)
            }

            // Day number
            ZStack {
                Circle()
                    .fill(isToday ? Color.ftdAccentOrange : Color.clear)
                    .frame(width: 26, height: 26)
                Text(viewModel.dayNumber(date))
                    .font(.caption)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(
                        isToday ? .white :
                        inMonth ? Color.ftdTextPrimary :
                        Color.ftdTextSecondary.opacity(0.35)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(isToday ? Color.ftdAccentOrange.opacity(0.04) : Color.clear)
    }

    // MARK: - Week View

    private var weekView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(viewModel.weekDays.enumerated()), id: \.offset) { idx, date in
                    weekDayColumn(date)
                    if idx < 6 {
                        Divider().frame(maxHeight: .infinity)
                    }
                }
            }
            .background(Color.ftdCardBackground)
            .frame(maxHeight: 140)

            Spacer()
        }
    }

    private func weekDayColumn(_ date: Date) -> some View {
        let isToday    = viewModel.isToday(date)
        let hasBooking = viewModel.hasBooking(on: date)

        return VStack(spacing: DesignTokens.Spacing.sm) {
            Text(viewModel.shortWeekday(date))
                .font(.caption2).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextSecondary)

            ZStack {
                Circle()
                    .fill(isToday ? Color.ftdAccentOrange : Color.clear)
                    .frame(width: 30, height: 30)
                Text(viewModel.dayNumber(date))
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isToday ? .white : Color.ftdTextPrimary)
            }

            if hasBooking {
                ZStack {
                    Circle()
                        .fill(Color.ftdAccentTeal.opacity(0.15))
                        .frame(width: 26, height: 26)
                    Image(systemName: "airplane")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.ftdAccentTeal)
                }
            } else {
                Spacer().frame(height: 26)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(isToday ? Color.ftdAccentOrange.opacity(0.04) : Color.clear)
    }

    // MARK: - Day View

    private var dayView: some View {
        let hasBooking = viewModel.hasBooking(on: viewModel.currentDate)

        return VStack(spacing: DesignTokens.Spacing.xxl) {
            Spacer()

            if hasBooking {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    ZStack {
                        Circle()
                            .fill(Color.ftdAccentTeal.opacity(0.12))
                            .frame(width: 100, height: 100)
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.ftdAccentTeal)
                    }
                    Text(String(localized: "Bookings on this day"))
                        .font(.title3).fontWeight(.semibold)
                        .foregroundStyle(Color.ftdTextPrimary)
                    Text(String(localized: "Open My Bookings for full details."))
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.xxl)
                }
            } else {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    ZStack {
                        Circle()
                            .fill(Color.ftdTextSecondary.opacity(0.06))
                            .frame(width: 100, height: 100)
                        Image(systemName: "calendar.badge.minus")
                            .font(.system(size: 44))
                            .foregroundStyle(Color.ftdTextSecondary.opacity(0.4))
                    }
                    Text(String(localized: "No bookings"))
                        .font(.title3).fontWeight(.semibold)
                        .foregroundStyle(Color.ftdTextSecondary)
                    Text(String(localized: "No departures found for this date."))
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdTextSecondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignTokens.Spacing.xxl)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ftdCardBackground)
    }
}
