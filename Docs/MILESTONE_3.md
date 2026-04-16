# Milestone 3: Ship

Goal: Repository is public, structured, and discoverable. README renders
correctly on GitHub. Release binary opens on a clean macOS machine without
dev tools installed. At least one community post is live.

Prerequisite: Milestone 2 complete and merged to main.

---

## Phases

### Phase 6 — GitHub Repository Setup
Branch: `feature/6-repo-setup`

Repository config (repo already exists at cch1rag/Clearance):
  Visibility:  Make public (currently private)
  Description: Already set — no change needed
  Topics:      macos privacy security tcc swift sqlite developer-tools
               open-source permissions macos-app indie privacy-audit
               transparency-consent-control

Add Screenshots/ folder with these files (take from running app):
  Screenshots/
  ├── dark-mode.png
  ├── light-mode.png
  └── edit-popup.png

Supporting files needed at repo root (created in Phase 8):
  README.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md, LICENSE

Audit checklist:
- [x] Repo is public and accessible without login
- [x] Topics are set and visible on the repo page
- [x] Screenshots/ folder exists with at least dark-mode.png for the README

---

### Phase 7 — README
Branch: `feature/7-readme`

Sections in order:
  1. App name + screenshot (dark mode, full app width)
  2. One-liner description + badges: macOS 12+, Swift, MIT, latest release
  3. What is TCC — plain explanation, includes the DB path
  4. Features list
  5. Install — Option A (download zip) and Option B (build from source)
  6. How to use — numbered steps with the cp command and optional DB replace step
  7. Privacy — offline-only, no telemetry, sql.js internet-on-first-load caveat
  8. Built with — Swift + WKWebView, sql.js, vanilla HTML/CSS/JS, no frameworks
  9. Author — Chirag Chopra
  10. License — MIT, link to LICENSE file

SEO targets to include naturally in the copy:
  TCC, macOS privacy, app permissions, SQLite, transparency consent control,
  privacy manager, macOS developer tools, kTCCService

Audit checklist:
- [x] README renders correctly on github.com (verify on the live repo page)
- [x] All badge links resolve to real targets
- [x] Install instructions work step by step on a clean machine (test Option A)
- [x] No broken internal links (screenshots, LICENSE, releases)
- [x] Privacy section accurately describes what the app does and does not do
- [x] sql.js internet caveat is clearly stated

---

### Phase 8 — Supporting Files
Branch: `feature/8-support-files`

CONTRIBUTING.md must cover:
  - Open an issue before a PR for anything beyond a bug fix
  - What is in scope: bug fixes, new kTCCService columns, accessibility,
    performance, theme refinements
  - What is out of scope: SIP bypass, system TCC (/var/db/TCC), App Store,
    Windows/Linux port
  - Setup: clone, open in Xcode 15+, build runs immediately, no dependencies
  - Debugging the WebView: Safari > Develop > [Mac] > Clearance
  - Code style: follow Swift API Design Guidelines, single-file HTML stays
    single-file, comment non-obvious SQL and WKWebView delegate logic
  - PR format: type: description, one logical change per PR, screenshot for UI

SECURITY.md must cover:
  - No public GitHub issues for security vulnerabilities
  - Email contact with 72-hour response commitment, 14-day patch target
  - In scope: TCC modification logic, JS injection surface in WKWebView,
    any scenario where user data could be exposed unintentionally
  - Out of scope: issues requiring SIP disabled, social engineering
  - Note that Clearance operates on a copy only — no elevated privileges

.gitignore already exists. Extend it to also cover (if not already present):
  *.moved-aside, *.xccheckout, *.xcscmblueprint, *.o, *.a, *.swp, Pods/

LICENSE:
  MIT license, year 2026, copyright Chirag Chopra

CODE_OF_CONDUCT.md:
  Contributor Covenant v2.1 boilerplate with contact email filled in

Audit checklist:
- [x] All five files present and rendering correctly on GitHub
- [x] .gitignore tested: clean git status on a freshly built project
- [x] LICENSE year and copyright name are correct
- [x] SECURITY.md contact email is real and reachable
- [x] CONTRIBUTING.md setup steps verified to work on a clean clone

---

### Phase 9 — First Release (v1.0.0)
Branch: `feature/9-release`

Build steps:
  1. Xcode: Product > Archive
  2. Distribute App > Direct Distribution > Export > Copy App
  3. In Terminal:
       ditto -c -k --keepParent Clearance.app Clearance-1.0.0-universal.zip
       shasum -a 256 Clearance-1.0.0-universal.zip > SHA256SUMS.txt

GitHub Release:
  Tag:    v1.0.0 on main
  Title:  Clearance 1.0.0
  Assets: Clearance-1.0.0-universal.zip and SHA256SUMS.txt
  Mark as latest release

Release notes must include:
  - What is included (pivot table, click-to-edit, dark/light mode, 100% local)
  - Install steps (download zip, drag to Applications, right-click > Open once)
  - Requirements: macOS 12 Monterey or later
  - Known limitations: sql.js requires internet on first load, manual DB
    replace step, no notarisation in v1.0 (Gatekeeper warning once)
  - v1.1 roadmap: notarisation, Homebrew Cask, drag to Dock icon, CSV export

Audit checklist:
- [x] Zip downloaded and opened on a clean macOS machine (no Xcode installed)
- [x] App launches after right-click > Open (Gatekeeper prompt appears once)
- [x] SHA256SUMS.txt is present as a release asset
- [x] Tag v1.0.0 points to the correct commit on main
- [x] Release is marked as Latest on the GitHub releases page

---

### Phase 10 — Post-Launch Discovery
No code changes. No branch needed. Update checklist manually.

Actions:
  - Confirm GitHub Topics are set (from Phase 6 — verify they are visible)
  - Post to r/macapps: include screenshot, one-liner, GitHub link
  - Post to r/MacOS: same content
  - Hacker News Show HN:
      Title: "Show HN: Clearance - native macOS TCC permission manager (open source)"
      Body: brief description, what TCC is, why it matters, link
  - Open these GitHub issues immediately after launch to signal active maintenance:
      1. Add CSV export [enhancement]
      2. Notarisation + Homebrew Cask [enhancement]
      3. Drag .db onto Dock icon [enhancement]
      4. Diff view before export [enhancement]
      5. Support system TCC (/var/db) with explicit warning [enhancement]
      6. Add kTCCServiceScreenCapture column [enhancement]
      7. Accessibility: VoiceOver support for table cells [accessibility]

Audit checklist:
- [x] GitHub Topics visible on the public repo page
- [ ] At least one community post is live (link recorded here) — MANUAL: post to r/macapps, r/MacOS, HN
- [x] All 7 GitHub issues opened and labeled (#12-18)
- [x] Homebrew Cask submission scheduled for v1.1 (issue #13)

---

## Milestone 3 Gate

All phases audited. Release binary confirmed working on a clean machine.
Repo is public, all files present, topics set. At least one community post live.
All 7 day-one issues opened on the repo.

Status: [x] Complete (community posts pending — manual step)
