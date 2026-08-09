# Travel Booking App — Design Document

> Status: DRAFT — to be refined with your Xcode agent after reviewing actual Postman collection endpoints and confirming assumptions marked with ⚠️

## 1. Overview

A multi-vertical travel booking iOS app supporting:
- **Verticals (phased rollout)**
  - Phase 1: ⚠️ *fill in — e.g. Flights, Hotels*
  - Phase 2: ⚠️ *e.g. Trains, Buses*
  - Future phases: additional verticals (e.g. Cabs, Cruises) to be added post-launch without touching shared code

- **User roles** (⚠️ CONFIRMED from actual UI screenshot — supersedes earlier 3-role assumption)
  1. **Travel Agent** — B2B partner; confirmed via Postman (`mapp_b2b/agent_login`), full signup form with business docs (PAN, GST, company details)
  2. **Customer** — end consumer/traveler ⚠️ *no dedicated login/signup endpoint found yet in Postman collection*
  3. **Distributor** — ⚠️ *role purpose, permissions, and endpoints unknown — need clarification*
  4. **Sales** — ⚠️ *role purpose, permissions, and endpoints unknown — need clarification*
  - **Admin** does NOT appear in the app's user-type selector — likely web/backend-only, not part of iOS scope

- **Core flows**: Signup/Sign-in (role-aware) → Search → Results/Filter → Detail → Booking → Payment → Confirmation → Booking History/Management

- **Backend**: Existing API, contract defined in Postman collection. ⚠️ *Path to collection to be added here once placed in repo, e.g. `docs/travel-api.postman_collection.json`*

---

## 2a. Technical Constraints (confirmed)

- **Min iOS version**: 17.0+
- **UI Framework**: SwiftUI only — no UIKit, no Storyboards
- **Language**: Swift only
- **Architecture rule**: NO business logic in Views. Views are purely declarative/presentational — all logic (validation, state, API calls, navigation decisions) lives in ViewModels/use-cases. Views only bind to `@Published`/`@Observable` state and call ViewModel methods.
- **Theming**: Must support Light and Dark mode — use semantic colors (`Color("...")` from Asset Catalog with light/dark variants, or `.primary`/`.secondary`/custom `Color` extensions), never hardcoded hex colors in Views
- **Localization**: Multi-language support required from day one — all user-facing strings must use `String(localized:)` / `.strings`/`.xcstrings` catalogs, no hardcoded strings in Views
- **Device support**: Must be adaptive across iPhone and iPad — use `NavigationSplitView` where appropriate for iPad, size-class-aware layouts (`@Environment(\.horizontalSizeClass)`), avoid fixed-width layouts that break on iPad

## 2b. Architecture Principles

1. **Shared core, pluggable verticals.** Auth, Payment, Booking-orchestration, and Networking live in a shared core module with **zero vertical-specific logic** (no `if vertical == .flight` conditionals in core).
2. **Protocol-driven verticals.** Every vertical (present or future) conforms to a small set of protocols so the app can treat them uniformly:
   - `VerticalSearchable` — defines search request/response shape, filter options
   - `VerticalBookable` — defines booking payload, confirmation shape
   - `VerticalDisplayable` — defines how results/detail screens render
3. **Vertical Registry.** A central registry (`VerticalRegistry`) holds all active verticals. Adding Phase 2/3 verticals means registering a new conforming module — no changes to home screen, tab bar, or core flow logic.
4. **Role-based access as a first-class layer**, not just UI hiding. A `PermissionProvider`/`RoleContext` determines available actions and screens — checked at the ViewModel/use-case level, not just by hiding buttons in the View.

---

## 3. Module / Folder Structure

```
TravelApp/
├── App/                          # App entry, DI composition root
├── Core/
│   ├── Auth/                     # Signup/signin, token/session mgmt, role resolution
│   ├── Networking/                # Shared API client, interceptors, error mapping
│   ├── Payment/                   # Payment gateway abstraction
│   ├── Booking/                   # Shared booking orchestration, cart/checkout
│   ├── Permissions/                # RoleContext, PermissionProvider
│   └── VerticalKit/                # Protocols: VerticalSearchable, VerticalBookable, VerticalDisplayable, VerticalRegistry
├── Verticals/
│   ├── Flights/                   # Phase 1
│   ├── Hotels/                    # Phase 1
│   ├── Trains/                    # Phase 2
│   └── Buses/                     # Phase 2
├── Features/
│   ├── SignupSignin/
│   ├── Home/                       # Vertical picker, driven by VerticalRegistry
│   ├── BookingHistory/
│   └── AgentDashboard/             # Agent-specific: client mgmt, commission view
├── DesignSystem/                   # Shared UI components, theming
└── Tests/
    ├── CoreTests/
    └── VerticalTests/
```

---

## 4. Data Models (draft — confirm against Postman schemas)

```swift
struct User {
    let id: String
    let name: String
    let email: String
    let role: UserRole            // .traveler, .agent, .admin
    let agentProfile: AgentProfile?  // present only if role == .agent
}

enum UserRole { case traveler, agent, admin }

struct AgentProfile {
    let commissionRate: Double
    let managedClients: [ClientReference]
}

struct Booking {
    let id: String
    let verticalType: String       // "flight", "hotel", "train", "bus", future verticals
    let bookedBy: String           // user id
    let onBehalfOf: String?        // set when Agent books for a client
    let status: BookingStatus
    let paymentReference: String
    let details: [String: Any]     // vertical-specific payload — see VerticalBookable
}

// Example per-vertical model (pattern repeats for Hotel/Train/Bus)
struct FlightSearchResult: VerticalDisplayable {
    let flightId: String
    let origin: String
    let destination: String
    let departure: Date
    let arrival: Date
    let fare: Fare
}
```

⚠️ Replace/extend field names once the Postman collection's actual response shapes are confirmed.

---

## 5. Role-Based Navigation

| Flow | Traveler | Agent | Admin |
|---|---|---|---|
| Signup/Signin | Standard | Standard + business verification step | ⚠️ *confirm scope* |
| Home | Vertical picker | Vertical picker + "Book for client" toggle | — |
| Search/Results | Standard | Same + agent pricing shown | — |
| Booking | Self only | Self or on-behalf-of client | — |
| History | Own bookings | Own + managed clients' bookings | All bookings (if in-scope) |

---

## 6. Networking Layer

- Single `APIClient` in `Core/Networking`, endpoint definitions mapped from the Postman collection
- **Confirmed auth flow (2-step, from Postman):**
  1. `POST /book/mapp/auth/sigin` — app-level sign-in with `appType` (1=iOS, 2=Android ⚠️ confirm), `appUser`, `appPassword`, `appVersion` → returns an `App-Token` (JWT) used as a header on all subsequent calls. ⚠️ Unclear if this is a per-app credential or per-user — needs clarification, since it takes appUser/appPassword not a real user's email
  2. `POST /book/mapp/mapp_b2b/agent_login` — actual Travel Agent user login with `email`, `password`, `device_id` (sent with `App-Token` header) → returns a bearer `auth_secret` token used for all subsequent agent-scoped calls (My Bookings, Refunds, Statement, Profile, Markups, Calendar)
  3. `POST /book/mapp/mapp_b2b/refresh_token` — refreshes the bearer token using `refresh_token`
- ⚠️ Customer / Distributor / Sales login endpoints not present in current Postman collection — need these added, or confirm if `auth/sigin` doubles as their login with a different `appType`
- Per-vertical API calls live in each vertical module but go through the shared `APIClient` — never a parallel networking stack
- **Interesting discovery**: `My Bookings` and `Agent Refunds` endpoints already unify multiple verticals (flight, hotel, car, insurance, visa, esim) into ONE endpoint using prefixed fields (e.g. `b_` for bus/flight, `c_` for car, `_hotel` suffix, `i_` for insurance). This confirms backend already thinks in a multi-vertical, single-endpoint way — worth mirroring this pattern in app-side `Booking` model design

---

## 7. Payment Integration

- Abstracted behind a `PaymentGateway` protocol in `Core/Payment` — concrete gateway (Razorpay/Stripe/etc.) is a swappable implementation
- ⚠️ *Confirm gateway choice*

---

## 8. Testing Strategy

- **Unit tests**: booking orchestration logic, role-permission resolution, per-vertical search/booking mapping
- **Integration tests**: networking layer against mocked Postman responses
- **UI tests**: critical paths only — signup, one full booking flow per role

---

## 9. Adding a New Vertical (Phase 2/3 playbook)

To add a new vertical (e.g. "Cabs") without touching shared code:
1. Create `Verticals/Cabs/` module
2. Implement `VerticalSearchable`, `VerticalBookable`, `VerticalDisplayable` for Cabs
3. Register the vertical in `VerticalRegistry`
4. Add Cabs-specific API endpoints in its own module (using shared `APIClient`)
5. No changes required to `Core/`, `Home`, or `Booking` orchestration

If any of these steps require touching shared/core files, the architecture has leaked vertical-specific logic and should be revisited.

---

## 10. Typography

- **Font family**: Poppins (OFL licensed)
- **Bundled weights**: Light, Regular, Medium, SemiBold, Bold
- **Font files location**: `LOGIN/Poppins/` — all `.ttf` files must have the LOGIN target checked in Xcode's File Inspector (Target Membership) so they are copied into the app bundle at build time
- **Registration**: Declared under `UIAppFonts` in `Config/Info.plist` with paths prefixed by the folder name (e.g. `Poppins/Poppins-Regular.ttf`)
- **Usage**: All font tokens are defined in `DesignSystem/Font+AppTypography.swift` via `Font.custom(...)` — use the `Font.ftd*` static properties throughout the app; do not call `Font.custom` directly in Views
- **Adding a new weight**: Drop the `.ttf` into the `Poppins/` folder → add it to `UIAppFonts` in Info.plist → add a new case to `PoppinsWeight` enum in `Font+AppTypography.swift`

---

## Open Questions (⚠️ resolve before implementation)
- [ ] Exact Phase 1 vs Phase 2 vertical list
- [ ] Payment gateway choice
- [ ] Min iOS version and SPM-only constraint confirmation
- [ ] **NEW**: Login/signup endpoints for Customer, Distributor, and Sales roles — not present in current Postman collection (only Travel Agent's `agent_login` exists)
- [ ] **NEW**: Does `auth/sigin` (`appType` 1/2) represent iOS-vs-Android, or does it also vary by user role? Its request body uses generic `appUser`/`appPassword`, not role-specific fields
- [ ] **NEW**: Do Customer/Distributor/Sales have their own Sign Up forms like Travel Agent's (PAN, GST, company docs), or a simpler consumer-style form? Only Travel Agent's Sign In/Sign Up screens have been shared so far
- [ ] **NEW**: Confirm Admin has no iOS presence at all (not seen in "Choose User Type" list)
- [ ] **NEW**: Is there a "Forgot Password" backend endpoint? (seen in UI, not in Postman collection)
