# Clearance — Phases 6–10 (Milestone 3)

Archived from CLEARANCE_PROJECT_PLAN.md. Load this file when starting Milestone 3 work.

---

## Phase 6 — GitHub Repository Setup

**Est. time: 1 hour | Checkpoint: repo public, all files present, Actions badge green**

### Repository details

```
Name:        clearance
Visibility:  Public
URL:         github.com/[your-handle]/clearance
Description: Native macOS app to audit, edit & understand app privacy permissions (TCC). 100% local.
Topics:      macos, privacy, security, tcc, swift, sqlite, developer-tools, open-source,
             permissions, macos-app, indie, privacy-audit, transparency-consent-control
Homepage:    (leave blank until you have a dedicated page)
```

### Repo file structure

```
clearance/
├── Clearance.xcodeproj/
├── Clearance/
│   └── [Swift source files]
├── Screenshots/
│   ├── dark-mode.png
│   ├── light-mode.png
│   └── edit-popup.png
├── README.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── LICENSE
└── .gitignore
```

---

## Phase 7 — README (SEO-Optimised)

**Est. time: 45 min | Checkpoint: renders correctly on GitHub, all links work**

### README structure

```markdown
# Clearance

[screenshot — dark mode, full app, 1440px wide]

> A native macOS app to audit and manage what your apps can access.
> View, edit, and export TCC (Transparency, Consent & Control) permissions —
> all 100% local. No data leaves your Mac.

[badge: macOS 12+] [badge: Swift 5.9] [badge: MIT] [badge: Latest Release]

## What is TCC?

macOS uses a framework called Transparency, Consent & Control (TCC) to manage
which apps can access sensitive resources: microphone, camera, contacts,
calendar, desktop folder, downloads, photos, Bluetooth, and more. This data
lives in a local SQLite database at:
  ~/Library/Application Support/com.apple.TCC/TCC.db

Clearance gives you a clean, interactive view of that database — and lets
you modify it without touching the terminal.

## Features
- Pivot table: one row per app, one column per permission category
- Visual encoding: ✓ Granted · ✗ Denied · – Never prompted
- Edit any permission with a single click (only valid values, no data corruption)
- Pending changes highlighted in amber before you commit
- Light and dark mode, follows macOS System Preferences
- Export a modified .db file — your original is never touched
- Filter by app, sort by most-granted, denied, or pending
- 100% offline — no telemetry, no network calls, no accounts

## Install

### Option A — Direct download (recommended)
1. Download `Clearance.zip` from the [latest release](releases)
2. Unzip and drag `Clearance.app` to `/Applications`
3. Open — macOS may show a Gatekeeper warning on first launch:
   Right-click → Open → Open (once only)

### Option B — Build from source
Requirements: Xcode 15+, macOS 12+
  git clone https://github.com/[handle]/clearance
  open Clearance.xcodeproj
  # Press ⌘R to build and run

## How to use

1. Run the audit command in Terminal to generate the database copy:
   [code block with the cp + sqlite3 command]
2. Open Clearance
3. Drag ~/Desktop/UserTCC.db onto the drop zone
4. Browse, filter, sort your app permissions
5. Click any cell to change its value
6. Click "Apply & Download .db" to save a modified version
7. [Optional] Replace the system TCC database with the modified file:
   cp ~/Downloads/UserTCC_modified.db \
      ~/Library/Application\ Support/com.apple.TCC/TCC.db

## Privacy

Clearance is entirely offline. It contains no analytics, no crash reporting,
no telemetry, and makes no network requests. The only external resource
loaded is sql.js (SQLite compiled to WebAssembly via cdnjs.cloudflare.com)
on first load — subsequent loads use the browser cache.

Your database file is read in memory. No copy is made on your system except
the modified file you explicitly download.

## Built with
- Swift 5.9 + WKWebView
- sql.js (SQLite → WebAssembly, MIT)
- HTML/CSS/JS — no frameworks

## Author
Chirag Chopra · Lucid Labs
[lucidlabs.in] · [@handle on GitHub]

## License
MIT — see LICENSE
```

---

## Phase 8 — Supporting Repo Files

### CONTRIBUTING.md structure

```markdown
# Contributing to Clearance

## Before you open a PR
- Open an issue first for anything beyond a bug fix
- Assign yourself to avoid duplicate work

## What's in scope
- Bug fixes
- New permission service columns (new kTCCService* keys)
- Accessibility improvements
- Performance (sql.js load time, large DB handling)
- Light/dark theme refinements

## Out of scope (for now)
- System-level TCC edits (SIP bypass, /var/db/TCC)
- Windows/Linux port (see Tauri branch if someone wants to take it)
- App Store distribution

## Setup
1. Clone repo, open Clearance.xcodeproj in Xcode 15+
2. Build runs immediately — no dependencies to install
3. Attach Safari Web Inspector to debug the WebView:
   Safari → Develop → [device] → Clearance

## Code style
- SwiftLint not enforced but follow Swift API Design Guidelines
- HTML/CSS/JS is single-file — keep it that way for portability
- Comment non-obvious SQL logic and WKWebView delegate flows

## Submitting
- Branch from main
- PR title: [fix/feat/docs]: short description
- Include a screenshot for any UI change
- One logical change per PR
```

### SECURITY.md

```markdown
# Security Policy

## Reporting a vulnerability

Please do NOT open a public GitHub issue for security vulnerabilities.

Email: [your email] with subject "Clearance Security"

I'll respond within 72 hours and aim to patch within 14 days for confirmed issues.

## Scope

In scope: logic that modifies the TCC database, JS injection surface in WKWebView,
any scenario where user data could be exposed unintentionally.

Out of scope: issues requiring SIP to be disabled, social engineering.

## Notes on TCC access

Clearance operates on a copy of the TCC database, not the live system file.
Modifications only take effect if the user manually replaces the system file.
This is by design — Clearance does not request elevated privileges.
```

### .gitignore

```gitignore
.DS_Store
*.xcuserstate
xcuserdata/
DerivedData/
*.moved-aside
*.xccheckout
*.xcscmblueprint
build/
*.o
*.a
*.swp
Pods/
.build/
```

---

## Phase 9 — First Release (v1.0.0)

**Est. time: 45 min | Checkpoint: zip downloaded by a clean macOS machine, app opens**

### Build steps

```
1. Xcode → Product → Archive
2. Distribute App → Direct Distribution → Export
3. Choose: "Copy App" (no notarisation for v1 — add in v1.1)
4. Zip: ditto -c -k --keepParent Clearance.app Clearance-1.0.0-universal.zip
```

### GitHub Release notes template (v1.0.0)

```markdown
## Clearance 1.0.0

First public release.

### What's included
- Native macOS app (Universal — Apple Silicon + Intel)
- Full TCC permission pivot table with visual encoding
- Click-to-edit with valid-values-only enforcement
- Dark and light mode (follows system)
- Export modified .db — original never touched
- 100% local — no data leaves your Mac

### Install
1. Download `Clearance-1.0.0-universal.zip`
2. Unzip → drag Clearance.app to Applications
3. First launch: right-click → Open (Gatekeeper warning — once only)

### Requirements
macOS 12 Monterey or later

### Known limitations
- sql.js loads from cdnjs on first use (requires internet once; cached after)
- System TCC database replacement requires manual terminal step (by design — no elevated privilege)
- App Notarisation coming in v1.1

### What's next (v1.1)
- Notarisation (no Gatekeeper warning)
- Drag .db directly onto the app icon in Finder/Dock
- Export as CSV
- Diff view: show what changed before you export
```

### Release asset checklist

- [ ] `Clearance-1.0.0-universal.zip` (the `.app` zipped)
- [ ] SHA256 checksum file (`shasum -a 256 Clearance-1.0.0-universal.zip > SHA256SUMS.txt`)
- [ ] Tag: `v1.0.0` on main branch
- [ ] Mark as "Latest release"

---

## Phase 10 — Post-Launch Discovery

**Est. time: 30 min | No code changes**

### GitHub Topics to set

```
macos swift privacy security tcc sqlite permissions developer-tools
open-source privacy-audit transparency-consent-control indie-dev
```

### Social / distribution

- Post to r/macapps, r/MacOS, r/netsec
- Hacker News: Show HN — keep title factual: "Show HN: Clearance – native macOS TCC permission manager (open source)"
- Tweet thread: problem → tool → screenshot → link → "built this weekend" energy
- Product Hunt (optional, but good for a portfolio signal)
- MacUpdate, Homebrew Cask submission (v1.1, after notarisation)

---

## Total Estimated Time

| Phase     | Task                               | Est.         |
| --------- | ---------------------------------- | ------------ |
| 0         | Branding & icon                    | 1h           |
| 1         | Xcode project setup                | 45min        |
| 2         | Swift window + WKWebView           | 1h           |
| 3         | Download handler                   | 1h           |
| 4         | HTML light theme + privacy copy    | 45min        |
| 5         | Menu bar + About panel             | 30min        |
| 6         | GitHub repo setup                  | 30min        |
| 7         | README                             | 45min        |
| 8         | CONTRIBUTING, SECURITY, .gitignore | 30min        |
| 9         | Build, archive, release            | 45min        |
| 10        | Post-launch distribution           | 30min        |
| **Total** |                                    | **~8 hours** |

---

## What I'm Building Next (GitHub Issues to Open on Day 1)

| #   | Title                                              | Label         |
| --- | -------------------------------------------------- | ------------- |
| 1   | Add CSV export                                     | enhancement   |
| 2   | Notarisation + Homebrew Cask                       | enhancement   |
| 3   | Drag .db onto Dock icon                            | enhancement   |
| 4   | Diff view before export                            | enhancement   |
| 5   | Support system TCC (/var/db) with explicit warning | enhancement   |
| 6   | Add kTCCServiceScreenCapture column                | enhancement   |
| 7   | Accessibility: VoiceOver support for table cells   | accessibility |

---

## Execution Order

```
Day 1 (4h): Phase 0 → 1 → 2 → 3  [app is functional]
Day 2 (4h): Phase 4 → 5 → 6 → 7 → 8 → 9 → 10  [shipped]
```
