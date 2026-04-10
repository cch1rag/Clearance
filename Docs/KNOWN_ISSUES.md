# Known Issues

Issues found during testing that are deferred to a later phase.

---

## P2 — Permission dropdown: current status should not be selectable

**Reported:** 2026-04-02
**Phase to fix:** Milestone 3 (Phase 6 or later)

When editing permissions for an app, the dropdown for a given permission type shows all options including the app's current status. The current status should appear greyed out and be non-selectable, making it visually clear it is the existing state rather than a valid edit target.

Requires JS/CSS changes to `tcc_audit_app.html`. Not addressed in Milestone 2 — pick up in Milestone 3.
