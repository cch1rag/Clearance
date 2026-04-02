# Known Issues

Issues found during testing that are deferred to a later phase.

---

## P2 — Permission dropdown: current status should not be selectable

**Reported:** 2026-04-02
**Phase to fix:** Phase 4 or 5 (HTML polish)

When editing permissions for an app, the dropdown for a given permission type shows all options including the app's current status. The current status should appear greyed out and be non-selectable, making it visually clear it is the existing state rather than a valid edit target.

Requires JS/CSS changes to `tcc_audit_app.html`. Deferred because the only permitted changes to that file before Phase 4 are the light theme CSS block and privacy badge HTML.
