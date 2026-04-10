# Phases 4–5 Archive (Milestone 2)

Merged to main 2026-04-10. PR #7 (Phase 4), PR #8 (Phase 5).

---

## Phase 4 — HTML Light Theme + Privacy Copy

Branch: `feature/4-light-theme`

Added light theme CSS block (`@media (prefers-color-scheme: light)`) and privacy badge to drop screen in `tcc_audit_app.html`. System appearance bridged from Swift via KVO + `evaluateJavaScript("setSystemAppearance(\(isDark))")` because `prefers-color-scheme` media queries do not work in sandboxed WKWebView.

Audit: all items passed.

---

## Phase 5 — App Menu + About Panel

Branch: `feature/5-app-menu`

Added native macOS menu bar (Clearance, File, Help) and `AboutWindowController` NSPanel. `openDatabase(_:)` and `reloadPage(_:)` wired as responder-chain actions on `WebViewController`. GitHub URL consolidated to `AppDelegate.openGitHub()` to avoid duplication.

Deviations from original spec (all user-requested):
- "Built by Chirag Chopra" removed from About panel
- Window title set to "Clearance - Hidden App Permission"
- GitHub URL updated to `github.com/cch1rag/clearance`

Audit: all items passed.
