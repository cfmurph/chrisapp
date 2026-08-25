# GigTrack

An iOS app for people in the music industry to manage the business side of gigging: receipts, invoices, hours, and driving costs.

## Features

1. **Receipts** — Snap a photo with the camera or upload one from your library, tag it with a vendor, amount, category, and date.
2. **Invoices** — Create clients, build line-item invoices, track status (Draft / Sent / Paid / Overdue), and share a PDF via Mail/Messages/AirDrop. See at a glance what's paid vs. outstanding.
3. **Timer** — Add band members / crew, start and stop a live timer per person and project, or log/edit hours manually. Hourly rate on each person gives an estimated earnings total.
4. **Driving costs** — Log trips (start/end location, miles, purpose) and calculate cost using a per-mile rate (defaults to a standard mileage rate, editable in Settings). See totals across all trips.

Data lives on-device in **SwiftData**, no account required to use the app. Two extras layer on top of that:

- **iCloud sync** — SwiftData's built-in CloudKit mirroring keeps a user's own data (and only their own data) in sync across their devices, signed in with their personal Apple ID. There's no shared backend — it's private per-user sync, not multi-user collaboration. Requires a one-time capability setup in Xcode — see [iCloud Sync Setup](#icloud-sync-setup-one-time-xcode-step) below. If that setup hasn't been done (or the device isn't signed into iCloud), the app automatically falls back to local-only storage instead of crashing, and Settings shows the current sync status.
- **CSV export** — the Settings tab can export Receipts, Invoices (+ a separate line-items file), Time Entries, or Driving Trips as CSV, individually or all at once, via the share sheet (Files, Mail, AirDrop, etc.) — a simple way to back up data or hand it to an accountant/spreadsheet.

## Project Structure

```
GigTrack/
├── GigTrack.xcodeproj/        # Xcode project (open this in Xcode)
└── GigTrack/                  # App source
    ├── GigTrackApp.swift      # App entry point, SwiftData model container
    ├── Models/                # SwiftData models (Person, TimeEntry, Client,
    │                          #   Invoice, InvoiceLineItem, Receipt, DrivingTrip)
    ├── Views/
    │   ├── RootTabView.swift  # Top-level tab bar
    │   ├── Receipts/
    │   ├── Invoices/
    │   ├── Time/
    │   ├── Driving/
    │   ├── Settings/
    │   └── Components/        # Shared UI pieces (StatCard, ShareSheet, etc.)
    ├── Utilities/              # Formatters, invoice PDF generator, CSV exporter, app-storage keys
    ├── Assets.xcassets/        # App icon + accent color
    └── GigTrack.entitlements   # iCloud/CloudKit capability (see setup below)
```

## Browser Preview (no Xcode required)

`GigTrack/WebPreview/` contains a standalone HTML/CSS/JS mockup of the app's screens and flows,
for quickly demoing or reviewing the UX without Xcode/iOS Simulator. See
[`GigTrack/WebPreview/README.md`](GigTrack/WebPreview/README.md) for how to run it. It is not
part of the iOS build — the Xcode project is the real app.

## Requirements

- macOS with **Xcode 16** (or newer) installed
- iOS 17.0+ deployment target (uses SwiftData)

## Getting Started

1. Clone the repo and open `GigTrack/GigTrack.xcodeproj` in Xcode.
2. Select an iPhone simulator (or your device) and hit **Run** (⌘R).
3. On first launch, go to the **Settings** tab to set your business name/email (used on shared invoice PDFs), preferred currency, and default mileage rate.
4. Add a few **People** (Time tab) and **Clients** (Invoices tab) to get started.

No signing/provisioning is required to run in the Simulator. To run on a physical device, select your team under the target's **Signing & Capabilities** tab.

### iCloud Sync Setup (one-time Xcode step)

The code already has everything wired up for CloudKit sync (`GigTrack.entitlements`, `CODE_SIGN_ENTITLEMENTS` build setting, `cloudKitDatabase: .automatic` in `GigTrackApp.swift`, and CloudKit-compatible model defaults), but **Apple requires the iCloud capability to be explicitly enabled with a signed-in developer account** — this can't be done from a `project.pbxproj` file alone. To turn sync on:

1. Open the project in Xcode, select the **GigTrack** target → **Signing & Capabilities**.
2. Under **Signing**, choose your Apple ID / Team (a free personal Apple ID works fine for development/testing on your own devices; a paid Apple Developer Program membership is only needed to distribute via TestFlight/App Store).
3. Click **+ Capability** and add **iCloud**.
4. Check the **CloudKit** service checkbox.
5. Under **Containers**, make sure `iCloud.com.cfmurph.gigtrack` is selected (Xcode will offer to create it if it doesn't exist yet under your team) — this must match the container identifier already declared in `GigTrack.entitlements`. If you change the bundle identifier, update the container identifier in both places to match.
6. Build and run on a device/simulator signed into iCloud (Settings app → your Apple ID). Open the **Settings** tab in GigTrack — it shows live iCloud sync status ("Signed in — syncing via iCloud", "Not signed into iCloud", etc.).

If you skip this setup, the app still works great — it just falls back to local-only storage automatically (no crash), and Settings will say sync isn't configured for that build. Sync is private per-user (each person's data syncs only to their own other devices, signed in with the same Apple ID) — there's no shared/multi-user backend.

### App Icon

The asset catalog includes an empty `AppIcon` slot (`GigTrack/Assets.xcassets/AppIcon.appiconset`). Drop a 1024×1024 PNG (no transparency) into that folder and reference it as `AppIcon.png` in its `Contents.json`, or simply drag an icon onto the App Icon well in Xcode's asset catalog editor.

### Regenerating the Xcode project

If you add or remove Swift files, `GigTrack/GigTrack.xcodeproj/project.pbxproj` needs to include them. A helper script rebuilds the project file by scanning the `GigTrack/GigTrack` source tree:

```bash
cd GigTrack
python3 Scripts/gen_pbxproj.py
```

This is a convenience script for regenerating file references — it is not part of the app itself, and running it is optional if you just add files directly from within Xcode (which updates the project file for you automatically).

## Notes on Permissions

The app requests camera access (`NSCameraUsageDescription`) only when you choose "Take Photo" while adding a receipt. Photo library access uses the modern `PhotosPicker`, which does not require a usage description or full-library permission.
