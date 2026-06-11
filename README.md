# Family Hub 🇦🇺

An iOS app for Australian parents of preschool-aged kids (3–5). It pulls the
admin of Australian family life into one place:

| Tab | What it does |
| --- | --- |
| **Today** | Dashboard: your kids, the next term date for your state, checklist progress |
| **CCS** | Child Care Subsidy estimator using the 2025–26 rates and the Jan-2026 3-Day Guarantee |
| **Terms** | 2026 government school/kindy term dates for every state and territory |
| **Checklists** | Templates for the 3–5 stage: Daycare Bag, Kindy Enrolment, Starting School Prep |
| **Kids** | Profiles for each child (name, age, care type) |

Built with **SwiftUI** and **SwiftData** (Apple's modern app database). No
backend, no accounts — everything stays on the phone, which also keeps us
clear of child-data privacy headaches for v1.

## Running the app (you need a Mac)

1. Install **Xcode** from the Mac App Store (free, large download). Xcode 16
   or newer.
2. Clone this repository, or download it as a ZIP from GitHub.
3. Double-click `FamilyHub.xcodeproj` to open it in Xcode.
4. At the top of the Xcode window, pick a simulator (e.g. *iPhone 16*).
5. Press **⌘R** (or the ▶ button). The simulator boots and the app launches.

To run on your real iPhone: plug it in, select it as the destination, and in
*Signing & Capabilities* for the FamilyHub target choose your personal team
(free Apple ID works for development).

> **If the project file won't open** (older Xcode): create a new iOS App
> project in Xcode named `FamilyHub` (SwiftUI, Swift), delete its generated
> Swift files, and drag the contents of the `FamilyHub/` folder from this
> repo into the project.

## Project layout

```
FamilyHub/
├── FamilyHubApp.swift        # App entry point, sets up the database
├── ContentView.swift         # The tab bar
├── Models/Models.swift       # Child, Checklist, ChecklistItem + templates
├── Data/
│   ├── CCSCalculator.swift   # CCS rates + estimate maths (pure logic, easy to test)
│   └── TermDates.swift       # 2026 term dates per state
└── Views/                    # One file per screen
```

## Data accuracy

- **CCS rates** are the published 2025–26 figures (90% max rate under
  $85,279 family income, tapering 1% per $5,000; $14.63/hr cap for centre
  based care; 72 hrs/fortnight 3-Day Guarantee from 5 Jan 2026). They are
  estimates only — Services Australia decides the real entitlement.
- **Term dates** are 2026 government school dates compiled from public
  sources in June 2026. Private schools differ. Verify against your state
  education department before relying on them. Both live in single data
  files (`Data/`) so they're easy to update — longer term they should come
  from a small server/JSON feed so users don't need an app update.

## Roadmap

**v1 (this code)** — local-only MVP. Ship to TestFlight, give it to other
parents at daycare, learn what they actually use.

**v2 ideas**
- Pupil-free days and vacation-care booking reminders (notifications)
- Multi-child CCS (higher rate for 2nd child under 6)
- Public holidays per state on the Today screen
- iCloud sync between parents (CloudKit — free, no backend to run)
- Widget: "Term ends in 12 days"

**Monetisation (later, once people use it)**
- Freemium subscription (~$2–4/month): free = 1 child + calculator;
  paid = unlimited kids, reminders, sync between parents, widgets
- Family-services partnerships (vacation care providers, kids' activities)
- Keep the CCS calculator free forever — it's the acquisition hook
