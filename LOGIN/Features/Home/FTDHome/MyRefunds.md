# My Refunds

Lets an agent view and filter cancelled-booking refund records across all travel verticals in one screen.

---

## Files

| File | Role |
|------|------|
| `RefundView.swift` | SwiftUI view — parallax hero, pinned tab bar + chips, collapsible search/filter row, refund card list with tap-to-expand detail, pagination, CSV export. |
| `RefundViewModel.swift` | `@Observable @MainActor` — all state, per-tab filter fields, API orchestration, per-vertical mapping functions, pagination, CSV export. |
| `AgentB2BModels.swift` | `AgentRefundsRequest`, `AgentRefundsResponse`, and one dedicated response model per vertical (see table below). |

---

## Tabs & API `search_type` Mapping

| Tab | `search_type` | Response key | Model | Booking ref field |
|-----|:---:|---|---|---|
| Flight | 1 | `flight_bookings` | `FlightRefundBooking` | `uniquerefno` (lowercase) |
| Bus | 2 | `bus_bookings` | `BusRefundBooking` | `uniqueRefNo` (camelCase) |
| Cab | 3 | `cab_bookings` | `CabRefundBooking` | `uniquerefno` |
| Hotel | 4 | `hotel_bookings` | `HotelRefundBooking` | `uniquerefno` |
| Insurance | 5 | `insurance_bookings` | `InsuranceRefundBooking` | `reference_no` |
| Visa | 6 | `visa_bookings` | `VisaRefundBooking` | `reference_no` |
| eSIM | 7 | `esim_bookings` | `EsimRefundBooking` | `uniquerefno` |

---

## API Endpoint

**`POST /book/mapp/mapp_b2b/agent_refunds`**
Auth: App-Token + Bearer
Content-Type: `application/json`

### Request Structure

All date fields use format `"yyyy-MM-dd"` (empty string `""` means no filter).
Every tab has its own prefixed fields; only the active tab's fields are sent:

```
search_type   Int      1–7 (tab selector)

── Flight (search_type=1) ──────────────────────────
fromdate      String   cancel date from (default: 1 month ago)
todate        String   cancel date to
rfromdate     String   refund date from
rtodate       String   refund date to
f_pnr         String
bookingid     String
f_refunded    String   "0"=Under Process  "1"=Refunded

── Bus (search_type=2) ─────────────────────────────
b_fromdate, b_todate, b_rfromdate, b_rtodate
b_pnr, b_bookingid, b_refund_status

── Cab (search_type=3) ─────────────────────────────
c_fromdate, c_todate, c_rfromdate, c_rtodate
c_pnr, c_bookingid, c_refunded

── Hotel (search_type=4) ───────────────────────────
h_fromdate, h_todate, h_rfromdate, h_rtodate
h_pnr, h_bookingid, h_refund_status

── Insurance (search_type=5) ───────────────────────
i_fromdate, i_todate, i_rfromdate, i_rtodate
i_policy, i_bookingid, i_refund_status

── Visa (search_type=6) ────────────────────────────
v_fromdate, v_todate, v_rfromdate, v_rtodate
v_bookingid                          (no status or PNR filter)

── eSIM (search_type=7) ────────────────────────────
e_fromdate, e_todate, e_rfromdate, e_rtodate
e_bookingid, e_refund_status
```

---

## Response Models — Per Vertical

Each vertical has a dedicated Swift struct because the API returns different field names, types, and nesting per `search_type`.

### Flight — `FlightRefundBooking`

```json
{
  "uniquerefno": "SZ2609017X...",
  "refund_amount": 3186,                 // Int
  "status": "Under Process",             // human-readable string
  "agent_net": "3209",                   // String
  "validating_carrier_name": "IndiGo",
  "fare_type": "Retail Fare",
  "passengers": [
    {
      "pax_id", "booking_id", "ticket_no", "name", "pnr",
      "cancel_date", "pax_type", "refunded",           // Int: 0/1
      "refund_date", "cancel_type", "fcid",
      "ancillary_refund": {
        "airline_charge", "ftd_fees", "agent_net", "refund_amt",
        "seat": { "paid", "refund" },
        "meal": { "paid", "refund" },
        "baggage": { "paid", "refund" },
        "special_service": { "paid", "refund" },
        "web_checkin": { "paid", "refund" },
        "refund_amounts": [Double]         // breakup amounts array
      },
      "reference_id": [String],           // transaction IDs
      "value_date": [String]              // transaction dates
    }
  ]
}
```

### Bus — `BusRefundBooking`

```json
{
  "uniqueRefNo": "...",                  // camelCase (differs from flight)
  "refund_amount": 1500,                 // Int
  "status": "2",                         // "1"=Pending, "2"=Refunded
  "agent_net_price": "1200",             // String (differs from flight's "agent_net")
  "booking_reference_no": "BK123",       // secondary PNR-like ref
  "cancel_date": "2026-05-01 ...",       // at booking level (not passenger)
  "refund_date": "2026-05-02 ...",       // at booking level
  "passengers": [ { "name", ... } ]
}
```

**Status normalization:** `"1"` → `"Pending"`, `"2"` → `"Refunded"`

### Cab — `CabRefundBooking`

```json
{
  "uniquerefno": "SR2605017...",
  "booking_id": "1263",                  // secondary ref
  "cancel_date": "2026-05-01 ...",       // at booking level
  "refund_amount": 50,                   // Int
  "status": "2",                         // "1"=Pending, "2"=Refunded, "3"=Rejected
  "refund_date": "2026-04-09 ...",
  "agent_net": 3083.3,                   // Double (number, not string)
  "user_name": "Bangalore Praveen"       // flat name (no passengers array)
}
```

**Status normalization:** `"1"` → `"Pending"`, `"2"` → `"Refunded"`, `"3"` → `"Rejected"`

### Hotel — `HotelRefundBooking`

```json
{
  "uniquerefno": "SQ2509137...",
  "bookingId": "SNHAPI00006876",         // camelCase secondary ref
  "cancel_date": "2026-09-01 ...",       // at booking level
  "refund_amount": "15392",              // String (or null) — not Int
  "refund_date": "2025-04-17 ...",
  "agent_net": "3879",                   // String
  "status": "1",                         // "1"=Refunded, null=Unknown
  "passengers": [ { "name": "..." } ]    // name only
}
```

**Status normalization:** `"1"` → `"Refunded"`

### Insurance — `InsuranceRefundBooking` + `InsuranceRefundPassenger`

```json
{
  "reference_no": "SMSW2601307...",      // booking ref (not uniquerefno)
  "agent_net": 411,                      // Double (number)
  "passengers": [
    {
      "name": "VIJAYA KUMARI",
      "policy_no": "12001081",           // per-passenger policy number
      "cancel_date": "2026-09-01 ...",   // at passenger level
      "refund_amount": "311.3",          // String (or null)
      "refund_date": "2026-03-26 ...",
      "status": "2"                      // "2"=Refunded, null=Unknown
    }
  ]
}
```

**Booking status derived:** `"Refunded"` if all passengers with a non-null status have `"2"`, else `nil`.
**Amount:** sum of all passengers' `refund_amount` values.

### Visa — `VisaRefundBooking` + `VisaRefundPassenger`

```json
{
  "reference_no": "SMSX2505059...",      // no agent_net at booking level
  "passengers": [
    {
      "name": "Santosh Kumar",
      "remarks": "Testing Santosh",
      "charge_date": "2025-05-05 ...",   // equiv. cancel_date
      "reverse_date": "2026-03-26 ...",  // equiv. refund_date
      "refund_amount": "2450",           // String
      "status": "Reversed"              // human-readable; normalized → "Refunded"
    }
  ]
}
```

**Status normalization:** `"Reversed"` → `"Refunded"` (case-insensitive). No `agent_net`.

### eSIM — `EsimRefundBooking` + `EsimRefundPassenger`

```json
{
  "reference_no": "SU2605297...",
  "uniquerefno": "SU2605297...",         // same value as reference_no
  "insert_date": "2026-05-29 ...",
  "agent_net": 2966,                     // Double (number)
  "passengers": [
    {
      "name": "ETA Garden",
      "remarks": "",
      "cancel_date": "2026-05-29 ...",
      "refund_amount": "950",            // String (or null)
      "refund_date": "2026-05-29 ...",
      "refund_status": "2"              // NOTE: field name is "refund_status", not "status"
    }
  ]
}
```

**Status normalization:** `"2"` → `"Refunded"`, `null` → `nil`.
**Booking status derived:** same logic as insurance/visa — all passengers with a value must be `"2"`.

---

## Response → `RefundRecord` Mapping

| `RefundRecord` field | Flight | Bus | Cab | Hotel | Insurance | Visa | eSIM |
|---------------------|--------|-----|-----|-------|-----------|------|------|
| `bookingRef` | `uniquerefno` | `uniqueRefNo` | `uniquerefno` | `uniquerefno` | `reference_no` | `reference_no` | `uniquerefno` |
| `secondaryRef` | first pax PNR | `booking_reference_no` | `booking_id` | `bookingId` | first pax `policy_no` | — | — |
| `pnr` | first pax PNR | `booking_reference_no` | `booking_id` | `bookingId` | — | — | — |
| `policyNo` | — | — | — | — | first pax `policy_no` | — | — |
| `passengerName` | all pax names | all pax names | `user_name` | all pax names | all pax names | all pax names | all pax names |
| `cancellationDate` | first pax `cancel_date` | booking `cancel_date` | booking `cancel_date` | booking `cancel_date` | first pax `cancel_date` | first pax `charge_date` | first pax `cancel_date` |
| `refundDate` | first pax `refund_date` | booking `refund_date` | booking `refund_date` | booking `refund_date` | first pax `refund_date` | first pax `reverse_date` | first pax `refund_date` |
| `amount` | `refund_amount` (Int) | `refund_amount` (Int) | `refund_amount` (Int) | `refund_amount` (String→Double) | sum of pax amounts | sum of pax amounts | sum of pax amounts |
| `agentNet` | `agent_net` (String→Double) | `agent_net_price` (String→Double) | `agent_net` (Double) | `agent_net` (String→Double) | `agent_net` (Double) | — | `agent_net` (Double) |
| `status` | as-is string | normalized | normalized | normalized | derived from pax | derived (→ "Refunded") | derived from pax |
| `passengers` | full `RefundPassenger[]` | full `RefundPassenger[]` | `[]` | `RefundPassenger[]` (name only) | `[]` | `[]` | `[]` |

Passenger name collapsing: `"<First Name> +N"` when multiple passengers.
Amount `nil` when `0` or unparseable — hides the amount label rather than showing `₹0`.

---

## Expanded Detail Card

Tapping a **Refunded** card (`status == "Refunded"`) expands it in-place (animated).
All collapsed-state content hides; the expanded card shows per-passenger detail.

**Expandable tabs:** Flight and Bus (have full `RefundPassenger` data).
**Minimal expand** (shows only Agent Net + Refund Amount): Hotel, Insurance, Visa, eSIM, Cab — these either have no passenger detail or store data in vertical-specific structs not mapped to `RefundPassenger`.

Per-passenger expanded section shows:
- Passenger name + Pax Type badge + Refund Status badge + X close button (first pax only)
- Unique Ref No / Ticket No
- FCID + Cancel Type
- Amount | Cancelled two-column strip
- Route: Carrier · Fare Type · PNR
- Agent Net | Airline Charge | FTD Fees
- Breakup (`refund_amounts[]`): "Refund Amount" (single) or "Refund Amount N" (multiple)
- Service table: Seat / Meal / Baggage / Special / Web Check-in | Paid | Refund
- Transactions: reference ID + value date pairs

---

## Auto-Load Pattern

```
View appears
    │
    └── .task(id: viewModel.autoLoadKey)
            └── viewModel.search()    ← loads flight refunds immediately

User taps a different tab
    │
    └── viewModel.switchTab(_:)
            • selectedTab updated
            • resetFilters() — all filter fields reset
            • autoLoadKey = tab.rawValue + UUID()   ← key changes
            └── .task(id:) fires again → viewModel.search()
```

`autoLoadKey` appends a UUID on every switch — ensures `.task` re-fires even when switching back to a previously visited tab.

---

## Screen Structure

```
┌─ safeAreaInset(.top) — FIXED nav bar ───────────────────────────────┐
│   [← Back]      My Refunds      [Filter badge button]               │
├─ ScrollView ────────────────────────────────────────────────────────┤
│  ┌─ Parallax Hero (banner image, 160pt) ──────────────────────────┐ │
│  ├─ Pinned Section Header ───────────────────────────────────────── │
│  │   Tab Bar (horizontal scroll: Flight | Bus | Cab | …)          │ │
│  │   ─────────────────────────────────────────────────────────    │ │
│  │   Controls Row: [Search] [Filters N] [Export]                  │ │
│  │   ─────────────────────────────────────────────────────────    │ │
│  │   Active Filter Chips (scrollable, + Clear All)                │ │
│  └─────────────────────────────────────────────────────────────── │ │
│  ┌─ Content Area ─────────────────────────────────────────────────┐ │
│  │  LazyVStack of refund cards (collapsed / expanded)             │ │
│  │  Pagination row                                                 │ │
│  └─────────────────────────────────────────────────────────────── │ │
└─────────────────────────────────────────────────────────────────────┘
```

The nav bar uses `.safeAreaInset(edge: .top)` — it stays fixed above all scroll content at all times.
The section header pins directly below the nav bar when the hero scrolls away (`HeroCollapsedKey` preference).

---

## Content Area States

| Condition | View shown |
|-----------|-----------|
| `isLoading == true` | Spinner + "Loading refunds…" |
| `error != nil` | Error icon + message + Retry button |
| `!hasSearched` | "Search for refunds" prompt |
| `filteredRecords.isEmpty` (after search) | "No refunds found" |
| Records available | `LazyVStack` list + pagination row |

---

## Filter Fields Per Tab

| Field | Flight | Bus | Cab | Hotel | Insurance | Visa | eSIM |
|-------|:------:|:---:|:---:|:-----:|:---------:|:----:|:----:|
| Cancel From / To | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Refund From / To | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| PNR | ✓ | ✓ | ✓ | ✓ | — | — | — |
| Policy No | — | — | — | — | ✓ | — | — |
| Booking Id | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Refund Status | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ |

---

## In-Screen Search (`filteredRecords`)

Client-side filter over the already-loaded records. Searches (case-insensitive) across:
- `bookingRef`
- `secondaryRef`
- `passengerName`
- `pnr`
- `policyNo` — enables insurance policy number search
- `status`

`searchQuery` is cleared by `resetFilters()` on every tab switch.

---

## Status Normalization Summary

| Tab | Raw value | Normalized |
|-----|-----------|-----------|
| Flight | server string (e.g. `"Under Process"`) | as-is |
| Bus | `"1"` | `"Pending"` |
| Bus | `"2"` | `"Refunded"` |
| Cab | `"1"` | `"Pending"` |
| Cab | `"2"` | `"Refunded"` |
| Cab | `"3"` | `"Rejected"` |
| Hotel | `"1"` | `"Refunded"` |
| Insurance | all pax `"2"` | `"Refunded"` |
| Insurance | any pax null | `nil` |
| Visa | all pax `"Reversed"` | `"Refunded"` |
| eSIM | all pax `"2"` | `"Refunded"` |

---

## Status Color Coding

| Status (lowercased) | Color |
|--------------------|-------|
| `"refunded"` | `ftdCreditGreen` |
| `"rejected"` / `"cancelled"` | `ftdDestructiveRed` |
| anything else (`"under process"`, `"pending"`, etc.) | `ftdAccentOrange` |

---

## Pagination

Client-side only — server returns the full list in one response:

- `pageSize = 25`
- `totalEntries` = count of records after mapping
- `currentPage` resets to `1` on every new search (`resetPage: true`)
- Pagination navigation calls `search(resetPage: false)` to preserve `currentPage`

---

## CSV Export

`triggerExport()`:
1. Guards `!filteredRecords.isEmpty`.
2. `buildCSV()` writes metadata header (category, date range) + column header + one row per filtered record.
3. Commas in field values replaced with `;` to prevent CSV corruption.
4. File written to `FileManager.default.temporaryDirectory` as `Refunds_<Tab>_<fromDate>.csv`.
5. Sets `exportURL` + `showExportSheet = true` → presents system share sheet.

Columns: `Booking Ref`, `PNR / Policy No`, `Passenger`, `Cancellation Date`, `Refund Amount`, `Status`.

---

## Key Design Notes

- **Date format split:** The view holds `Date` objects for pickers; converts to `"yyyy-MM-dd"` strings on "Done". The ViewModel holds only API-format strings.
- **Tab switch resets pickers:** `.onChange(of: viewModel.selectedTab)` resets all four picker `Date` states, staying in sync with `resetFilters()`.
- **`CancellationError` swallowed:** Mid-flight task cancellation (tab switch) is silently ignored; the new tab's request overwrites state.
- **Amount `nil` when zero:** `refund_amount == 0` or null maps to `nil` — hides the label rather than showing `₹0`.
- **`agent_net` type variation:** Flight/Bus/Hotel send it as a `String`; Cab/Insurance/eSIM send it as a `Double`. Each model declares the correct type; mappers format uniformly.
- **`refund_amount` type variation:** Flight/Bus/Cab send it as an `Int`; Hotel/Insurance/Visa/eSIM send it as a `String` (or null). Each mapper handles its own type.
