# FTD Travel — Build Environment Configuration

This directory contains all build-time configuration for the FTD Travel iOS app.
Values are injected at compile time via `.xcconfig` files → `Info.plist` substitution variables → Swift (`AppConfiguration`).

---

## Key Architecture: Single Binary for TestFlight + App Store

> **This project uses a single-binary distribution model.**
>
> You archive **once** with the Release scheme and upload **one `.ipa`** to App Store Connect.
> The same binary is distributed to both TestFlight and the App Store.
> The correct base URL is selected **at runtime** — not at archive time.

### How runtime detection works

Apple embeds a StoreKit receipt file in the app bundle after installation. The filename reveals the distribution channel:

| Receipt filename | Meaning | Base URL used |
|---|---|---|
| `sandboxReceipt` | Installed from TestFlight | `APP_API_STAGING_URL` (staging server) |
| `receipt` | Installed from App Store | `APP_API_BASE_URL` (production server) |
| absent | Running in Xcode / Simulator | `APP_API_STAGING_URL` (staging fallback) |

`#if DEBUG` guards the dev path at compile time — the receipt check only runs in Release builds.

```swift
// AppConfiguration.swift — simplified view
static var apiBaseURL: URL {
    #if DEBUG
    // Always dev URL when running from Xcode
    return URL(from: "APP_API_BASE_URL")  // Debug.xcconfig
    #else
    // Single binary: receipt filename determines the channel at runtime
    let isTestFlightOrDev = Bundle.main.appStoreReceiptURL?.lastPathComponent != "receipt"
    return isTestFlightOrDev ? stagingURL  // APP_API_STAGING_URL
                             : productionURL  // APP_API_BASE_URL
    #endif
}
```

---

## What Changed (Migration Log)

### Change 1 — Broken `//` comment lines in Release.xcconfig

`//` is the xcconfig comment delimiter. The original file used `//` as a separator between old and new values on the same line, silently discarding everything after it:

```xcconfig
// BROKEN — everything after // was treated as a comment:
APP_API_BASE_URL = http:$(SLASH)$(SLASH)13.200.42.214//https:$(SLASH)$(SLASH)www.ftd.travel
APP_USER         = ftdiostest//ftdtravel_ios_2026_sep
APP_PASSWORD     = 123456//Mr&i8&FtFtmMh7jYoBB5k#@ff3egXTRAQBPKdALr

// What Xcode actually read:
APP_API_BASE_URL = http://13.200.42.214   <- dev server, even in Release!
APP_USER         = ftdiostest             <- test credential in production
APP_PASSWORD     = 123456                 <- test password in production
```

**Result:** the App Store build was hitting the dev server with test credentials. Fixed by splitting values onto separate lines.

### Change 2 — Added Staging build configuration (later superseded by Change 3)

Added `Staging.xcconfig` and a `Staging` build configuration so a separate TestFlight build could point at a different URL. Required two archives per release cycle.

### Change 3 — Switched to single-binary distribution *(current)*

Eliminated the need for two separate archives per release.

**What changed:**

| # | File | Change |
|---|---|---|
| 1 | `Config/Release.xcconfig` | Added `APP_API_STAGING_URL` — the TestFlight/staging server URL baked into the release binary |
| 2 | `Config/Info.plist` | Added `APP_API_STAGING_URL` key to expose the new xcconfig variable at runtime |
| 3 | `Core/Networking/AppConfiguration.swift` | Replaced Info.plist-driven environment detection with StoreKit receipt detection at runtime |

**Impact on the Staging build configuration:**
The `Staging` configuration and `LOGIN (Staging)` scheme are now unused. They can be kept or removed — they do not interfere. Do **not** use the Staging scheme for App Store Connect uploads; only the Release scheme produces the correct single binary.

---

## Environment Overview

| Environment | How triggered | App name | API URL |
|---|---|---|---|
| Debug | Running in Xcode / Simulator (`#if DEBUG`) | `FTD Travel'D` | `http://13.200.42.214` (from `Debug.xcconfig`) |
| TestFlight | `sandboxReceipt` in bundle at runtime | `FTD Travel` | `APP_API_STAGING_URL` (from `Release.xcconfig`) |
| App Store | `receipt` in bundle at runtime | `FTD Travel` | `APP_API_BASE_URL` (from `Release.xcconfig`) |

> TestFlight and App Store share the same app name (`FTD Travel`) because they are the same binary.
> Only the Debug build gets the `'D` suffix.

---

## Files in This Directory

```
Config/
├── Debug.xcconfig      # Dev environment — test credentials, dev server
├── Staging.xcconfig    # Legacy (unused) — kept for reference
├── Release.xcconfig    # Single archive for both TestFlight + App Store
├── Info.plist          # Shared Info.plist; uses $(VAR) substitution from xcconfigs
└── README.md           # This file
```

---

## xcconfig Variables Reference

| Variable | File | Description |
|---|---|---|
| `APP_ENV` | All | Environment identifier (legacy — no longer drives runtime behavior in Release) |
| `APP_DISPLAY_NAME` | All | App name shown on the home screen |
| `APP_API_BASE_URL` | All | Production API base URL (Release) / Dev URL (Debug) |
| `APP_API_STAGING_URL` | Release only | Staging / TestFlight API base URL — selected at runtime for TestFlight installs |
| `APP_TYPE` | All | App type integer sent in auth requests |
| `APP_USER` | All | App-level auth username |
| `APP_PASSWORD` | All | App-level auth password |
| `APP_VERSION` | All | App version string sent in API requests |
| `APP_OTP_TIMEZONE` | All | Timezone used for OTP expiry calculation (`UTC` / `IST`) |
| `SLASH` | All | Workaround — xcconfig treats `//` as a comment, so URLs use `$(SLASH)$(SLASH)` |

### Updating the staging URL

Open `Config/Release.xcconfig` and update `APP_API_STAGING_URL`:

```xcconfig
APP_API_STAGING_URL = https:$(SLASH)$(SLASH)staging.ftd.travel
```

Rebuild and re-upload to App Store Connect. TestFlight users will hit the new URL on next install.

---

## Swift API

Values are accessed via `AppConfiguration` in `Core/Networking/AppConfiguration.swift`.

```swift
// Current environment — derived at runtime from StoreKit receipt (not Info.plist)
AppConfiguration.environment          // .debug | .staging | .production
AppConfiguration.environment.rawValue // "debug" | "staging" | "production"

// API base URL — correct URL for the current distribution channel
AppConfiguration.apiBaseURL           // URL (crashes with fatalError if key missing — intentional)

// App-level credentials for token auth
AppConfiguration.appCredentials       // AppCredentials

// OTP expiry timezone
AppConfiguration.otpExpiryTimeZone    // TimeZone
```

### AppEnvironment enum

```swift
enum AppEnvironment: String {
    case debug
    case staging      // .staging  → TestFlight (runtime detection via sandboxReceipt)
    case production   // .production → App Store (runtime detection via receipt)

    var isDebugLike: Bool { self != .production } // true for debug + staging
}
```

Use `isDebugLike` to gate logging, debug banners, or test-only features:

```swift
if AppConfiguration.environment.isDebugLike {
    print("API:", AppConfiguration.apiBaseURL)
}
```

> **Key note — `#if DEBUG` vs `isDebugLike`:**
> With single-binary distribution, TestFlight builds are Release builds. `#if DEBUG` is **false** for TestFlight users.
> Use `AppConfiguration.environment.isDebugLike` (not `#if DEBUG`) for anything that should be hidden from App Store users but visible in TestFlight.

---

## One-Time Xcode Setup (New Developer / New Clone)

### 1. Assign xcconfig files to build configurations

Open Xcode → click the `LOGIN` project in the navigator → **Info** tab.
Expand each configuration and set the xcconfig for the `LOGIN` target:

| Configuration | xcconfig file |
|---|---|
| Debug | `Config/Debug.xcconfig` |
| Release | `Config/Release.xcconfig` |

> The `Staging` configuration can be left as-is or ignored — it is not used in the current workflow.

### 2. Regenerate CocoaPods configs (if needed)

```bash
pod install
```

---

## Daily Build Workflow

With single-binary distribution, **one archive covers both TestFlight and App Store**.

| Destination | Scheme | Build Config | App name | API URL |
|---|---|---|---|---|
| Simulator / local dev | `LOGIN` (default) | Debug | `FTD Travel'D` | `http://13.200.42.214` (dev) |
| TestFlight | `LOGIN` (default) | Release | `FTD Travel` | `APP_API_STAGING_URL` (auto) |
| App Store | `LOGIN` (default) | Release | `FTD Travel` | `APP_API_BASE_URL` (auto) |

### Archive and upload (one step covers both channels)

1. In the scheme selector choose **`LOGIN`** (the default scheme)
2. Set the destination to **Any iOS Device (arm64)**
3. **Product → Archive**
4. In Organizer → **Distribute App** → **TestFlight & App Store** → upload

That single `.ipa` is now in App Store Connect. Distribute it to TestFlight groups for testing, then submit the same build for App Store review when ready — no second archive needed.

### Full release cycle

```
1. Build new feature
2. Archive with LOGIN (Release) → upload to App Store Connect  [once]
3. Distribute to TestFlight testers → they hit the staging URL automatically
4. Bug found? Fix → repeat steps 2–3
5. All good? Submit the same build for App Store review          [no second archive]
6. Wait for Apple review (~1-2 days)
7. App Store users receive the update → they hit the production URL automatically
```

---

## App Store Update Alert

The app checks iTunes on launch and shows an "Update Available" alert when the App Store version is newer than the installed build.

**Behaviour per environment**

| Build | Alert shown? | Recommended guard |
|---|---|---|
| Debug | No | `#if DEBUG` in `FTDHomeViewModel.checkForAppStoreUpdate()` |
| TestFlight | Yes (Release build, `#if DEBUG` is false) | Use `AppConfiguration.environment.isDebugLike` to suppress if needed |
| App Store | Yes | iTunes lookup runs on view load |

> **Action required if the update alert should be suppressed in TestFlight:**
> Replace the `#if DEBUG` guard in `FTDHomeViewModel.swift` with:
> ```swift
> guard !AppConfiguration.environment.isDebugLike else { return }
> ```
> This hides the alert from both Debug and TestFlight, and shows it only to App Store users.

**How it works (Release only)**

1. `FTDHomeView.task` calls `checkForAppStoreUpdate()` on appear.
2. Fetches `https://itunes.apple.com/lookup?bundleId=<bundleId>`.
3. Compares the returned `version` string against `APP_VERSION` from `Info.plist` using semantic versioning.
4. If the store version is newer → sets `showUpdateAlert = true` → alert appears with **Update Now** (opens App Store) and **Later** buttons.

---

## Security Notes

- `Debug.xcconfig` contains test-only credentials — safe for version control while they remain test-only.
- `Release.xcconfig` contains production credentials — consider adding it to `.gitignore` and injecting via CI secrets instead.
- `Staging.xcconfig` contains dev credentials — same risk level as `Debug.xcconfig`.
- The dev server uses plain HTTP. The `NSAppTransportSecurity` exception in `Info.plist` allows this for `13.200.42.214` only. The production server uses HTTPS and requires no exception.

> **CI/CD:** For automated builds, inject secrets via environment variables before archiving:
> ```bash
> echo "APP_USER = $FTD_PROD_USER"         >> Config/Release.xcconfig
> echo "APP_PASSWORD = $FTD_PROD_PASSWORD" >> Config/Release.xcconfig
> ```
