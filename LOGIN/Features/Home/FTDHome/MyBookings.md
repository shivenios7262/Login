# My Bookings

Lets an agent view, search, and filter confirmed booking records across all travel verticals.  
Only the **Flight** tab is fully implemented; all other tabs show a "Coming soon" placeholder.

---

## Files

| File | Role |
|------|------|
| `MyBookingsView.swift` | SwiftUI view — parallax hero, pinned tab bar + filter chips, search/filter/export controls row, flight card list with tap-to-detail alert, client-side pagination, CSV export. |
| `BookingsViewModel.swift` | `@Observable @MainActor` — all state, per-tab filter fields, API orchestration via `AuthManager.fetchBookings`, `resetFilters()`, `buildRequest()`. |
| `AgentB2BModels.swift` | `AgentBookingsRequest`, `AgentBookingsResponse`, `AgentBookingsData`, `AgentFlightBooking`, `ReturnFlightBooking`, `FlightPassenger`. |

---

## Tabs & API `search_type` Mapping

| Tab | `search_type` | Status |
|-----|:---:|---|
| Flight | 1 | Fully implemented |
| Bus | 2 | Coming soon |
| Cab | 3 | Coming soon |
| Hotel | 4 | Coming soon |
| Insurance | 5 | Coming soon |
| Visa | 6 | Coming soon |
| eSIM | 7 | Coming soon |

---

## API Endpoint

**`POST /book/mapp/mapp_b2b/agent_bookings`**  
Auth: App-Token + Bearer  
Content-Type: `application/json`

### Request Structure

All date fields use format `"yyyy-MM-dd"`. Omit a field (send `null`) to apply no filter for it.  
Every tab has its own prefixed fields; `buildRequest()` only populates the active tab's fields:

```
search_type   Int      1–7 (tab selector)

── Flight (search_type=1) ──────────────────────────
from_date     String   booking date from
to_date       String   booking date to
pnr           String
status        String   "Confirmed" | "Rejected" | "Pending"
first_name    String   passenger first name
airline       String   airline code
uniquerefno   String   booking ID (e.g. SZ2312211111)

── Bus (search_type=2) ─────────────────────────────
b_from_date, b_to_date, b_booking_date, b_depart_date
b_Booking_Status, b_uniqueRefNo, b_pass_name

── Cab (search_type=3) ─────────────────────────────
c_from_date, c_to_date, c_depart_date, c_bookingdate
c_pnr, c_status, c_first_name

── Hotel (search_type=4) ───────────────────────────
check_in_date, check_out_date
pnr_hotel, uniquerefno_hotel, hotel_status

── Insurance (search_type=5) ───────────────────────
onward_date, return_date
country_name, insurance_status, insurance_type, reference_insurance

── Visa (search_type=6) ────────────────────────────
onward_date_visa, return_date_visa
country_name_visa, reference_visa

── eSIM (search_type=7) ────────────────────────────
esim_from_date, esim_to_date
reference_esim
```

---

## Response Models — Flight

### `AgentFlightBooking`

```json
{
  "uniquerefno":       "SZ2312211111",
  "triptype":          "S",            // "S"=One-way, "R"=Round trip, "2"/"4" also round
  "servicetype":       1,              // Int: 2 = International
  "bookingdate":       "2025-09-01",
  "status":            "SUCCESS",
  "origin":            "BOM",
  "destination":       "DEL",
  "pnr":               "ABCXYZ",
  "carrier":           "6E",
  "carriername":       "IndiGo",
  "faretypedesc":      "Retail Fare",
  "departuredate":     "2025-09-15",
  "departuretime":     "0620",         // 4-digit string → formatted as "06:20"
  "totalfare":         "4500",
  "agent_net_price":   "4100",
  "origin_city":       "Mumbai",
  "destination_city":  "Delhi",
  "total_amount":      4500,           // Int in JSON → stored as String
  "total_net":         4100,           // Int in JSON → stored as String
  "onward_total_net":  "4100",
  "return_total_net":  "3136",         // String for round trips, Int 0 for one-way → nil
  "passengers": [
    {
      "title":          "Mr",
      "first_name":     "John",
      "last_name":      "Doe",
      "passenger_type": "ADT"
    }
  ],
  "return_booking": {                  // present only for round trips
    "origin", "destination", "origin_city", "destination_city",
    "pnr", "carrier", "carriername", "validatingcarriername",
    "faretypedesc", "departuredate", "departuretime",
    "totalfare", "agent_net_price"
  }
}
```

**`tripType` normalization:**

| Raw value | Interpreted as |
|-----------|---------------|
| `"S"` | One-way |
| `"R"` | Round trip |
| `"2"` | Round trip |
| `"4"` | Round trip + International |
| `"3"` | International |

**`return_total_net`** is a `String` for round trips and `Int 0` for one-way — decoder handles both; maps to `nil` when 0.

---

## Auto-Load Pattern

```
View appears
    │
    └── .task
            └── viewModel.fetchBookings()
                    └── viewModel.search()   ← loads flight bookings immediately

User taps a different tab
    │
    └── .onChange(of: viewModel.selectedTab)
            • searchQuery = ""
            • currentPage = 1
            • scrollToTop.toggle()
            └── Task { await viewModel.search() }  ← new API call for new tab
```

Tab switching always triggers a fresh API call. `searchQuery` is cleared on every tab change, which also resets `currentPage` to 1 via `.onChange(of: searchQuery)`.

---

## Screen Structure

```
┌─ safeAreaInset(.top) — FIXED nav bar ────────────────────────────────┐
│   [← Back]      My Bookings      [Filter badge button]                │
├─ ScrollView (coordinateSpace: "bookingsScroll") ──────────────────────┤
│  ┌─ Parallax Hero (banner image, 160pt) ─────────────────────────────┐ │
│  ├─ Pinned Section Header ────────────────────────────────────────────┤ │
│  │   Tab Bar (horizontal scroll: Flight | Bus | Cab | …)             │ │
│  │   ─────────────────────────────────────────────────────────       │ │
│  │   Controls Row: [Search field] [Filters N] [Export]               │ │
│  │   ─────────────────────────────────────────────────────────       │ │
│  │   Active Filter Chips (scrollable, + Clear All)                   │ │
│  └──────────────────────────────────────────────────────────────────── │
│  ┌─ Content Area ──────────────────────────────────────────────────── │ │
│  │  "Showing X–Y of Z entries" label                                  │ │
│  │  LazyVStack of flight cards                                        │ │
│  │  Pagination row (Previous / Page N of M / Next)                   │ │
│  └──────────────────────────────────────────────────────────────────── │
└───────────────────────────────────────────────────────────────────────┘
```

The nav bar uses `.safeAreaInset(edge: .top)` — stays fixed above all scroll content.  
The section header pins below the nav bar once the hero scrolls past 40% of its height (`BookingsHeroCollapsedKey` preference).

---

## Content Area States

| Condition | View shown |
|-----------|-----------|
| `isLoading == true` | Spinner + "Loading bookings…" |
| `error != nil` | Error icon + message + Retry button |
| `selectedTab != .flight` | "Coming soon" placeholder with tab icon |
| `filteredBookings.isEmpty` | "No bookings found" + hint to adjust filters |
| Records available | Entries label + `LazyVStack` flight cards + pagination |

---

## Flight — Filter Fields

Filter sheet uses a 2-column `LazyVGrid`. Date fields tap to open an inline date picker sheet.

| Field | ViewModel var | API key | Input type |
|-------|--------------|---------|-----------|
| From Date | `flightFromDate` | `from_date` | Date picker |
| To Date | `flightToDate` | `to_date` | Date picker |
| Airline | `flightAirline` | `airline` | Text field |
| Status | `flightStatus` | `status` | Dropdown: Confirmed / Rejected / Pending |
| PNR | `flightPNR` | `pnr` | Text field |
| Pax Name | `flightName` | `first_name` | Text field |
| Booking ID | `flightBookingId` | `uniquerefno` | Text field (placeholder: `Eg: SZ2312211111`) |

Active filters appear as dismissable chips above the content area, each with an `×` to clear that single filter and re-fetch. "Clear All" resets all fields and re-fetches.

---

## Inline Search (`filteredBookings`)

Client-side filter over the already-loaded `flightBookings` array — **no API call**.  
Triggers on every keystroke (`searchQuery` is `@State`, results are a computed property).  
`currentPage` resets to 1 via `.onChange(of: searchQuery)`.

Searches (case-insensitive, substring match) across:

| Field | Source |
|-------|--------|
| Booking ID | `uniqueRefNo` |
| PNR | `pnr` |
| Airline code | `carrier` |
| Airline name | `carrierName` |
| Origin IATA | `origin` |
| Destination IATA | `destination` |
| Origin city | `originCity` |
| Destination city | `destinationCity` |
| Total fare | `totalFare` |
| Agent net price | `agentNetPrice` |
| Total amount | `totalAmount` |
| Total net | `totalNet` |
| Onward net | `onwardTotalNet` |
| Return net | `returnTotalNet` |
| Passenger names | all `passengers[].fullName` |

API filters (filter sheet) operate on the server; inline search operates on the returned dataset. Both can be active simultaneously.

---

## Flight Card Structure

Each `AgentFlightBooking` renders as a card with four sections:

```
┌─ Route Header (dark background, tappable → alert detail) ──────────┐
│  [Origin City → Destination City]  [🌐 if intl]  [Status badge]    │
│  [Return City → Origin City]  (round trips only)                    │
│  Booked: DD MMM YY                                                  │
├─ Info Grid ─────────────────────────────────────────────────────────┤
│  Airline + Fare Type  │  PNR (color = status)  │  Departure date+time│
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ (return leg, round trips only) ─│
│  Return Airline       │  Return PNR            │  Return Departure   │
├─ Passengers (2-col grid, shown when present) ───────────────────────┤
│  👤 Name  👤 Name  …                                                │
├─ Footer ────────────────────────────────────────────────────────────┤
│                          Total ₹XXXX  Net ₹XXXX  Net 2 ₹XXXX       │
└─────────────────────────────────────────────────────────────────────┘
```

- **Route Header tap** → system alert showing full booking detail (route, airline, PNR, ref no, trip type, departure, booked date, fare type, total fare, net price, passenger count).
- **International badge** (`🌐`): shown when `serviceType == 2`.
- **Round trip**: detected by `tripType` in `["R", "r", "round", "2", "4"]`.
- **Passenger names**: titles stripped (`Mr.`, `Mrs.`, `Ms.` etc.) before display.
- **Fare chips**: `totalAmount ?? totalFare` for Total; `onwardTotalNet` for Net 1 (round trip) or `totalNet ?? agentNetPrice` for Net (one-way); `returnTotalNet` for Net 2 (round trip only).

### Status Color Coding

| Status (lowercased) | Color |
|--------------------|-------|
| `"success"`, `"confirmed"`, `"completed"`, `"holdconfirm"`, `"booked"` | `green` |
| `"rejected"`, `"holduna"`, `"holdunc"`, `"cancelled"`, `"failed"` | `ftdDestructiveRed` |
| `"hold"`, `"pending"`, `"inprogress"`, `"check"`, `"hc pending"` | `ftdAccentOrange` |
| anything else | `ftdTextSecondary` |

---

## Pagination

Client-side over `filteredBookings`:

- `pageSize = 10`
- `currentPage` resets to `1` on every new search, tab change, or `searchQuery` change
- Previous / Next buttons scroll back to top via `scrollToTop` toggle → `ScrollViewReader`
- "Showing X–Y of Z entries" label reflects filtered count

---

## CSV Export

`exportBookings()`:
1. Guards `!filteredBookings.isEmpty`.
2. Builds CSV from `filteredBookings` (respects active inline search + API filters).
3. Columns: `Ref No`, `Origin`, `Destination`, `Airline`, `PNR`, `Depart Date`, `Status`, `Total Fare`, `Net Price`.
4. Writes to `FileManager.default.temporaryDirectory/bookings_export.csv`.
5. Presents system share sheet via `UIActivityViewController`.

---

## Key Design Notes

- **Search is split:** inline `searchQuery` filters client-side; filter sheet fields go to the API. Both can be active at the same time — the API narrows the dataset, inline search narrows further.
- **`bnil` helper:** `String.bnil` returns `nil` for empty strings so omitted filters are not sent to the API at all (uses `encodeIfPresent`).
- **Departure time formatting:** raw `"0620"` (4-digit) is formatted to `"06:20"`; other lengths passed through as-is.
- **Amount display:** `totalAmount` and `totalNet` come as `Int` from the API and are stored as `String` for display. `return_total_net` can be `String` or `Int 0` — decoded to `nil` when zero to suppress the Net 2 chip for one-way trips.
- **Return leg data:** stored in `returnBooking: ReturnFlightBooking?` (nested object), not derived from CSV field splitting.
