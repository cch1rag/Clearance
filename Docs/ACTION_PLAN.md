# Clearance — Action Plan
Technical reference for the build agent. No narrative. All signal.
Read this alongside the active milestone doc.

---

## App Architecture

```
Clearance/  (inside project root: /Users/chiragc/Projects/Clearance)
├── main.swift                     Entry point. Creates AppDelegate, sets as NSApp.delegate,
│                                  calls app.run(). Explicit setup required — no nib/storyboard.
│
├── AppDelegate.swift              Boot sequence. Instantiates MainWindowController on launch.
│                                  Handles applicationShouldTerminateAfterLastWindowClosed → true.
│                                  Implements applicationSupportsSecureRestorableState → true.
│
├── MainWindowController.swift     Owns the NSWindow.
│                                  Size: 1200×760 default, 860×580 minimum.
│                                  Standard titled style (no fullSizeContentView).
│                                  isRestorable = false. Centers on launch.
│                                  Holds WebViewController as content.
│
├── WebViewController.swift        Owns the WKWebView.
│                                  Configures WKWebViewConfiguration.
│                                  Registers all WKScriptMessageHandler names.
│                                  Loads tcc_audit_app.html via loadFileURL.
│                                  Conforms to: WKScriptMessageHandler, WKNavigationDelegate,
│                                  WKUIDelegate (file picker via NSOpenPanel).
│                                  Handles all JS → Swift messages.
│                                  Owns menu action implementations (CmdO, CmdR).
│
├── DownloadHandler.swift          Owns NSSavePanel logic.
│                                  Called by WebViewController when saveDB message arrives.
│                                  Decodes base64 → Data → writes to user-chosen URL.
│                                  Single responsibility: file write only.
│
└── Resources/
    ├── tcc_audit_app.html         Existing, complete. Do not rebuild.
    │                              Only Phase 4 additions permitted.
    └── Assets.xcassets/
        └── AppIcon.appiconset/
```

---

## Data Flow

### Load path (user opens a DB)

```
User drags .db onto drop zone
  → HTML FileReader reads ArrayBuffer
  → sql.js (WASM) opens DB in memory as SQL.Database instance
  → buildPivot() runs SELECT across access table, filters out com.apple.* and /System/*
  → pivot[] array built: one object per third-party app, one key per kTCCService
  → render() draws the permission table

User picks via Cmd+O (native menu)
  → Swift NSOpenPanel → user selects .db
  → Swift reads file → base64 encodes → evaluateJavaScript("handleFileFromNative(b64, filename)")
  → HTML handleFileFromNative() decodes → constructs File object → calls handleFile()
  → same path as drag-and-drop from here
```

### Edit + save path

```
User clicks a cell
  → openPopup() shows Grant / Deny / Remove options
  → applyEdit(newVal) stores change in changes{} object keyed by "service\x00client"
  → eff() overlays changes{} on top of pivot[] for all renders (original DB untouched in memory)
  → pending cells get amber outline via is-pending CSS class

User clicks Apply & Download
  → applyAndDownload() clones DB: new SQL.Database(db.export())
  → iterates changes{}: UPDATE first, INSERT if 0 rows modified, DELETE for null
  → cloned.export() → Uint8Array
  → window.webkit.messageHandlers.saveDB.postMessage({ data: b64, filename })
  → Swift userContentController(_:didReceive:) receives message
  → DownloadHandler opens NSSavePanel, writes decoded Data to chosen URL
  → toast confirmation shown in HTML via evaluateJavaScript
```

---

## Swift ↔ HTML Bridge

All communication between Swift and the HTML goes through two channels only.

### JS → Swift (WKScriptMessageHandler)

| Handler name | Payload | Swift action |
|---|---|---|
| `saveDB` | `{ data: String (base64), filename: String }` | Decode → NSSavePanel → write file |

### Swift → JS (evaluateJavaScript)

| Call | When |
|---|---|
| `handleFileFromNative(b64, filename)` | User picks file via Cmd+O |
| `toast('message')` | Optional: confirm save success from native side |

---

## HTML File Contract

- File: `tcc_audit_app.html`
  - Project root location (source of truth): `Resources/tcc_audit_app.html`
  - Xcode target location (after Phase 1 setup): `Clearance/Resources/tcc_audit_app.html`
- Status: Complete and verified. Do not rewrite.

**What exists (do not touch):**
- All dark mode CSS variables in `:root`
- Loader → drop screen → app state machine
- sql.js 1.10.3 loaded from cdnjs
- `buildPivot()` — SQL query, filters, pivot array construction
- `eff()` — pending changes overlay
- `render()` — table, stats, filter, sort
- `openPopup()` / `applyEdit()` — cell editing
- `resetApp()` / `resetChanges()` — state resets
- Existing `applyAndDownload()` blob download (browser fallback path)

**Phase 3 modifications:** Complete. See `applyAndDownload()` and `handleFileFromNative()` in the HTML, and `DownloadHandler.swift`.

**Phase 4 modifications (two additions only):**
1. Append `@media (prefers-color-scheme: light)` CSS block after `:root`.
2. Add `.privacy-badge` HTML between `.drop-eyebrow` and `#drop-area`.
   Add corresponding `.privacy-badge` and `.priv-icon` CSS rules.

**After Phase 4: file is frozen.** No further modifications under any
circumstance.

---

## Key API Decisions

| Decision | What to use | What not to use | Why |
|---|---|---|---|
| File save | `WKScriptMessageHandler` + `NSSavePanel` | `WKDownloadDelegate` | Blob URL clicks are never navigation events — WKDownloadDelegate will not fire |
| File load (native) | `evaluateJavaScript("handleFileFromNative(...)")` | Injecting raw JS or reloading WebView | Keeps all DB state in the HTML layer |
| WebView load | `loadFileURL(_:allowingReadAccessTo:)` with parent directory | `loadHTMLString` | sql.js needs to resolve the .wasm file relative to the HTML |
| Local file access | `allowFileAccessFromFileURLs = true` on WKPreferences | Default config | Required for sql.js WASM loading from bundle |
| Background | `webView.underPageBackgroundColor = .clear` | Default | Clears overscroll rubber-band area to avoid white flash on theme change |
| Version string | `Bundle.main.infoDictionary["CFBundleShortVersionString"]` | Hardcoded string | Single source of truth in Info.plist |
| App termination | `applicationShouldTerminateAfterLastWindowClosed` → `true` | Default | Standard macOS utility app behavior |

---

## TCC Database Reference

File path (user-facing copy): `~/Desktop/UserTCC.db`
Source: `~/Library/Application Support/com.apple.TCC/TCC.db`

Relevant table: `access`

| Column | Type | Notes |
|---|---|---|
| `service` | TEXT | kTCCService* constant, e.g. `kTCCServiceCamera` |
| `client` | TEXT | Bundle ID or path, e.g. `com.example.app` |
| `client_type` | INTEGER | 0 = bundle ID (third-party apps). Filter to this only. |
| `auth_value` | INTEGER | 0 = denied, 2 = granted. NULL = never prompted. |
| `auth_reason` | INTEGER | Set to 3 on all writes (user-modified). |
| `last_modified` | INTEGER | Unix timestamp. Set via `CAST(strftime('%s','now') AS INTEGER)`. |

Write pattern: UPDATE first, INSERT if 0 rows modified, DELETE for null.
See `applyAndDownload()` in `tcc_audit_app.html` for the exact SQL.
`auth_reason` is always set to 3 (user-modified). `last_modified` uses `CAST(strftime('%s','now') AS INTEGER)`.

---

## Git Branch Map

| Branch | Milestone | Merges when |
|---|---|---|
| `feature/0-branding` | 1 | Phase 0 audit passes |
| `feature/1-xcode-setup` | 1 | Phase 1 audit passes |
| `feature/2-webview` | 1 | Phase 2 audit passes |
| `feature/3-download-handler` | 1 | Phase 3 audit passes + M1 gate passes |
| `feature/4-light-theme` | 2 | Phase 4 audit passes |
| `feature/5-menu` | 2 | Phase 5 audit passes + M2 gate passes |
| `feature/6-repo-setup` | 3 | Phase 6 audit passes |
| `feature/7-readme` | 3 | Phase 7 audit passes |
| `feature/8-support-files` | 3 | Phase 8 audit passes |
| `feature/9-release` | 3 | Phase 9 audit passes + M3 gate passes |

Phase 10 has no branch — manual actions only. All other git rules are in CLAUDE.md.

---

## Build Config

| Setting | Value |
|---|---|
| Product Name | Clearance |
| Bundle ID | in.lucidlabs.clearance |
| Deployment Target | macOS 12.0 Monterey |
| Language | Swift |
| Interface | Programmatic (no SwiftUI, no XIB) |
| Architecture | Universal (Apple Silicon + Intel) |
| Swift Package dependencies | None |
| Third-party frameworks | None |
| External JS dependencies | sql.js 1.10.3 via cdnjs (runtime, not bundled) |

Info.plist keys: see `Clearance/Info.plist` (source of truth).

---

## Hard Constraints

These do not change. Do not work around them.

- Zero network requests from Swift. The app makes no outbound calls.
- sql.js loads from cdnjs once, then the browser caches it. This is the only
  accepted external load and it happens inside the WebView, not Swift.
- No SIP bypass. No elevated privileges. No sudo. The app operates on a
  user-space copy of the TCC database only.
- No notarisation in v1.0. Document this clearly in release notes and
  SECURITY.md. Gatekeeper right-click > Open workaround is the install path.
- tcc_audit_app.html is frozen after Phase 4. Any bug found after that
  milestone is a new feature branch, not a rewrite.
- Version string always comes from Info.plist. Never hardcoded anywhere.
