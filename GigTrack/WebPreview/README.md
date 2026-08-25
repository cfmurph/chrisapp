# GigTrack — Browser Preview

This folder contains a standalone, dependency-free HTML/CSS/JS mockup of the GigTrack iOS app.
It exists purely so the app's screens and flows can be demoed/reviewed in a regular browser
without needing Xcode or an iOS Simulator (e.g. in CI, a cloud sandbox, or a quick stakeholder demo).

It is **not** part of the iOS app build and is not referenced by the Xcode project.

## Running it

Any static file server works, for example:

```bash
cd GigTrack/WebPreview
python3 -m http.server 8080
# then open http://localhost:8080/index.html
```

## What it covers

- Receipts: add/edit with photo upload (via a file picker), category, vendor, amount, notes.
- Invoices: clients, line items, status (Draft/Sent/Paid/Overdue), a printable PDF-style preview
  (opens the browser print dialog — "Save as PDF" produces a real PDF).
- Time: add people, start/stop a live timer, edit logged hours, full history.
- Driving: log trips and see cost calculated live from miles × rate per mile.
- Settings: business info, currency, default mileage rate.

Data is stored in the browser's `localStorage` (key `gigtrack_demo_state_v1`) and seeded with a
little sample data on first load. Use the "Reset Demo Data" button on the Settings screen to
restore the original sample data at any time.

It mirrors the real app's data model (see `GigTrack/GigTrack/Models/`) and screens
(see `GigTrack/GigTrack/Views/`) as closely as practical in plain JS, but it is a simplified
stand-in, not a literal translation — treat the real Swift/SwiftUI/SwiftData app as the source of truth.
