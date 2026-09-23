# Upload Money

Allows an agent to top up their FTD wallet. Two modes are available:

| Mode | Settlement |
|------|-----------|
| **Offline Request** | Agent submits transfer details; admin reviews and credits manually. |
| **Instant Top-Up** | Real-time credit via Nimbbl payment gateway. |

---

## Files

| File | Role |
|------|------|
| `UploadMoneyView.swift` | SwiftUI view — renders both modes, phase-driven UI, Nimbbl `fullScreenCover`. |
| `UploadMoneyViewModel.swift` | `@Observable @MainActor` — all state, form fields, API orchestration, Nimbbl session management. |
| `NimbblCheckoutRepresentable.swift` | `UIViewControllerRepresentable` wrapping `NimbblCheckoutWebView`; bridges both Nimbbl delegate protocols to SwiftUI closures via `Coordinator`. |

---

## API Endpoints

| # | Method | Path | Purpose |
|---|--------|------|---------|
| 1 | GET | `/book/mapp/mapp_b2b/upload_money` | Fetch wallet balance, pending stats, bank list, timings, special message |
| 2 | POST | `/book/mapp/mapp_b2b/upload_money_request` | Submit offline request (bank/cash/cheque) |
| 3 | POST | `/book/mapp/mapp_b2b/create_payment_order` | Create Nimbbl order — returns `payment_token` JWT |
| 4 | POST | `/book/mapp/mapp_b2b/payment_checkout` | Confirm Nimbbl payment after gateway callback |
| 5 | GET | `/book/mapp/mapp_b2b/agent_balance` | Refresh wallet balance post-payment (called automatically) |

All endpoints require App-Token + Bearer auth.

---

## Phase State Machine

`UploadMoneyViewModel.Phase` is the single source of truth for what the view renders:

```
.loading  ──fetchData()──►  .loaded ◄──────────────────────────────────────────┐
                                │                                                │
                    ┌───────────┴────────────┐                                  │
                    ▼                        ▼                                  │
          submitOfflineRequest()    initiateInstantTopUp()                      │
                    │                        │                                  │
             .submitting             .submitting                                │
                    │                        │                                  │
              API error                API error ──► alertMessage ─────────────┘
                    │                        │
              API success          create_payment_order OK
                    │                   isNimbblPresented = true
                    ▼                        │
              .success             .loaded (Nimbbl open)
                                       │
                          ┌────────────┼────────────┐
                          ▼            ▼             ▼
                     User Close  Nimbbl Fail   Nimbbl Success
                      dismiss     alertMsg      .submitting
                                  .loaded            │
                                              payment_checkout
                                                     │
                                              error ──► alertMsg → .loaded
                                                     │
                                              success → refreshBalance()
                                                     ▼
                                                .success(refNo: "", msg:)
```

| Phase | View shown |
|-------|-----------|
| `.loading` | Full-screen spinner |
| `.loaded` / `.submitting` | Payment form (submitting adds loading overlay) |
| `.success(refNo, msg)` | Success screen + "Done" dismisses the sheet |
| `.failure(msg)` | Error screen + "Retry" / "Cancel" |

---

## Screen Entry

On `.task`, the view calls `reset()` then `fetchData()`:
- GET `/upload_money`
- Populates: wallet balance, pending count/amount, bank list per tab, upload timings, `specialMessage`, `cashDailyLimit`
- Auto-selects first eligible bank (`showBank == "1"` / `showCash == "1"` / `showCheque == "1"` filtered server-side)
- If `specialMessage` is non-empty, a dismissible overlay popup appears immediately on top of the form

---

## Offline Request Flow

User picks **Offline Request** → selects tab (Bank / Cash / Cheque).

**Bank list:** filtered from `bank_list.bank` / `.cash` / `.cheque` in the API response; the server controls visibility and ordering per tab via `show_bank`, `bank_order`, etc.

**Form fields by tab:**

| Field | Bank | Cash | Cheque |
|-------|------|------|--------|
| Amount | ✓ (≥ ₹10) | ✓ (≥ ₹10, daily limit shown) | ✓ (≥ ₹10) |
| Transfer Date | ✓ (≤ today) | ✓ | ✓ |
| UTR ID | required | optional | — |
| Cheque drawn on / Cheque No | — | — | required |
| Remark | required | required | required |

**Submit (`submitOfflineRequest()`):**
1. Validates all required fields — sets `alertMessage` on failure, returns early.
2. Builds `UploadMoneyRequest` with `depositType` and `payMethod` (pulled from selected bank's per-tab field: `bankPayMethod` / `cashPayMethod` / `chequePayMethod`).
3. POST `/upload_money_request` → on success: `phase = .success(referenceNo:, message:)`.
4. On API error: sets `alertMessage`, returns to `.loaded` (form stays intact).

Cash tab shows an `InfoBanner` noting to email a deposit slip to `admin@ftd.travel`. Cheque tab shows the same for cheque deposit slips.

---

## Instant Top-Up Flow (4 steps)

### Step 1 — Create Nimbbl Order

`initiateInstantTopUp()`:
- Validates amount ≥ ₹10 (Int parse).
- POST `/create_payment_order` with `{ transfer_amount: <int>, callback_mode: "callback_mobile", referrer_platform: "ios" }`.
- Response: `payment_token` (JWT), `reference_id`, `invoice_id`.
- JWT is base64-decoded client-side **only** to extract `order_id` as a validity check — if missing, aborts with an error. The decoded `order_id` is never sent to the server.
- Stores `nimbblOrderData`, sets `isNimbblPresented = true`.

### Step 2 — Nimbbl WebView

- `fullScreenCover` presents `NimbblCheckoutRepresentable`.
- SDK initialized with `appCode: nil` (production), no sandbox URL.
- `NimbblCheckoutOptions` passes only `orderToken` — `paymentModeCode: nil` so the full payment-method selector renders. Passing a mode code without a `bankCode` silently disables the submit button inside the WebView.
- A "Close" toolbar button calls `handleNimbblDismiss()`. The `isNimbblPresented` binding setter is wrapped to route swipe-to-dismiss through the same handler.
- A 5-minute session timeout auto-closes the WebView to recover from UPI deep-link freezes on iPad.

### Step 3 — Callback Deduplication

Two delegate protocols fire on the same `Coordinator`:

| Delegate | Protocol | When |
|----------|----------|------|
| `onCheckoutResponse(data:)` | `NimbblCheckoutSDKDelegate` (ObjC) | All states |
| `nimbblCheckoutWebViewDidSucceed/DidFail` | `NimbblCheckoutWebViewDelegate` (Swift) | Success / failure only |

A `hasResponded: Bool` flag prevents double-firing. Additionally, if `onCheckoutResponse` fires as success but the payload lacks the `order` key (which the FTD backend requires), it is **skipped without setting `hasResponded = true`** — allowing the Swift delegate to fire with the complete payload. Failure events always go through the ObjC delegate.

Success/failure classification checks `status` and `event_type` against known string sets; unknown states are treated as failure.

### Step 4 — Confirm Payment

On Nimbbl success callback:
1. Capture `referenceId` and `invoiceId` from `nimbblOrderData` **before** `dismissNimbblCheckout()` nils it.
2. Dismiss Nimbbl (`isNimbblPresented = false`, `nimbblOrderData = nil`, timeout cancelled).
3. Patch `order.shopfront_domain` in the callback payload to `"{apiBaseURL}/book/b2b/money-management"` — Nimbbl sets it to `"server_to_server"` for `callback_mode: "callback_mobile"`, but the FTD backend validates against the registered web URL. Base URL comes from `AppConfiguration.apiBaseURL` (injected via xcconfig).
4. Build body: `{ event_type: "globalHandleCheckoutResponse", payload: <patched>, reference_id: ..., invoice_id: ... }`. The `reference_id`/`invoice_id` are injected because Nimbbl does not echo back `custom_attributes` in the callback.
5. POST `/payment_checkout` (JSON).
6. On success: `authManager.refreshBalance()` then `phase = .success(referenceNo: "", message: "Payment of ₹{amount} completed successfully!")`.
7. On error: `alertMessage = ...`, `phase = .loaded` (agent is warned that payment may have been captured but confirmation failed — do not retry to avoid duplicate charge).

---

## Key Design Notes

- **`walletBalanceAmount`** strips the leading "₹" because the view renders a custom rupee image asset alongside the number.
- **`selectTab(_:)`** resets all form fields and auto-selects the first eligible bank for the new tab.
- **`autoSelectFirstBank()`** runs on data fetch and on every tab switch — always picks the first bank where `isDisabled` is false.
- **Bank remarks:** `remark(for:)` returns the per-tab remark string (`bankRemarks` / `cashRemarks` / `chequeRemarks`) displayed as a warning inside the bank card UI.
- **Bearer token auto-refresh:** `APIClient` checks `accessTokenExpiry` before every authenticated request, silently refreshing if within 30 s of expiry. On a 401, it retries once. Important for long Nimbbl sessions.

---

## Nimbbl Pod Dependencies

Both pods are required. Removing either causes build failures.

| Pod | Provides |
|-----|---------|
| `nimbbl_mobile_kit_ios_core_api_sdk = 2.0.17` | `NimbblCheckoutSDK`, `NimbblCheckoutSDKDelegate` (ObjC), `NimbblCheckoutOptions` |
| `nimbbl_mobile_kit_ios_webview_sdk ~> 2.0.17` | `NimbblCheckoutWebView`, `NimbblCheckoutWebViewDelegate` (Swift) |
