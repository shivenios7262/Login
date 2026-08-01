# FTD Login — iOS App

SwiftUI iOS application for FTD agent authentication and home dashboard.

## Requirements

- Xcode 15+
- iOS 17+

## Setup

The project uses `.xcconfig` files for environment configuration. These are gitignored — you must create them locally before building.

```bash
cp Config/Debug.xcconfig.example Config/Debug.xcconfig
cp Config/Release.xcconfig.example Config/Release.xcconfig
```

Open each file and replace the placeholder values with your actual dev/prod credentials.

Then in Xcode, assign the xcconfig files to their build configurations:

1. Select the project in the navigator → **Info** tab → **Configurations**
2. Expand **Debug** → set base configuration to `Config/Debug.xcconfig`
3. Expand **Release** → set base configuration to `Config/Release.xcconfig`

## Architecture

- **Core/Auth** — `AuthManager`, Keychain, token models
- **Core/Networking** — `APIClient`, endpoint definitions, HTTP client
- **DesignSystem** — Shared SwiftUI components and tokens
- **Features/Auth** — Sign-in, Sign-up, OTP verification, Forgot password flows
- **Features/Home** — Agent home, side menu, bookings, markups, statement
