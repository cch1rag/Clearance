# Clearance — Project Execution Plan

**macOS Privacy Permission Manager**
*Built by Chirag Chopra*

---

## App Identity

|               |                                                                                                                       |
| ------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Name**      | Clearance                                                                                                             |
| **Tagline**   | Full visibility into what your Mac apps can access.                                                                   |
| **One-liner** | A native macOS tool to audit, edit, and understand app privacy permissions. 100% local — no data leaves your machine. |
| **Category**  | Utilities / Privacy & Security                                                                                        |
| **License**   | MIT                                                                                                                   |
| **Min macOS** | 12 Monterey                                                                                                           |
| **Arch**      | Universal (Apple Silicon + Intel)                                                                                     |

**Why "Clearance":** Security clearance = who has access to what. It's a double meaning (clearing permissions), short enough to remember, not taken on GitHub as a macOS utility, and SEO-friendly in the privacy tools space.

---

## Deliverables Checklist

- [ ] Swift macOS app (WKWebView wrapper)
- [ ] Embedded HTML viewer/editor (dark + light theme, auto-follows system)
- [ ] App icon (all required sizes)
- [ ] GitHub repository, fully structured
- [ ] README (SEO-optimised, with screenshot, install badge, usage GIF)
- [ ] CONTRIBUTING.md
- [ ] CODE_OF_CONDUCT.md
- [ ] SECURITY.md
- [ ] LICENSE (MIT)
- [ ] .gitignore (Xcode + macOS)
- [ ] GitHub Release v1.0.0 with universal binary `.zip`
- [ ] GitHub Topics tags (for discoverability)
- [ ] App menu bar: File, Help, About
- [ ] About panel with version, author, GitHub link

---

*Phases 0–3 archived → [Docs/archive/phases_0_3.md](archive/phases_0_3.md). Milestone 1 is complete.*

---

## Phase 4 — HTML Layer: Light Theme + Privacy Copy

**Est. time: 45 min | Checkpoint: both themes match spec, privacy banner visible on drop screen**

### Light theme additions to `tcc_audit_app.html`

Add `@media (prefers-color-scheme: light)` block to the existing `:root` styles:

```css
@media (prefers-color-scheme: light) {
  :root {
    --bg: #F7F6F3; --sf: #FFFFFF; --sf2: #F0EEE9; --sf3: #E8E5DF;
    --bd: rgba(0,0,0,0.07); --bd2: rgba(0,0,0,0.11); --bd3: rgba(0,0,0,0.16);
    --tx: #1A1A18; --tx2: #6B6B68; --tx3: #9B9B98; --tx4: #C8C6C0;
    --grn: #2D8A4E; --grn-bg: rgba(45,138,78,0.09); --grn-bd: rgba(45,138,78,0.22);
    --red: #B84040; --red-bg: rgba(184,64,64,0.09); --red-bd: rgba(184,64,64,0.22);
    --amb: #9E6428; --amb-bg: rgba(158,100,40,0.09); --amb-bd: rgba(158,100,40,0.25);
    --blue: #2E6DA4; --blue-bg: rgba(46,109,164,0.09);
  }
}
```

### Privacy banner on drop screen

Add directly above `<p class="drop-notice">`:

```html
<div class="privacy-badge">
  <span class="priv-icon">⬡</span>
  100% local  ·  no data leaves your Mac
</div>
```

```css
.privacy-badge {
  font-size: 11px; color: var(--grn); background: var(--grn-bg);
  border: 1px solid var(--grn-bd); border-radius: 20px;
  padding: 5px 14px; margin-bottom: 20px;
  display: flex; align-items: center; gap: 6px;
}
.priv-icon { font-size: 13px; }
```

**Checkpoint audit:**

- [ ] Switch System Preferences → Light — app switches without reload
- [ ] Switch to Dark — reverts cleanly
- [ ] Privacy badge visible on drop screen in both themes
- [ ] No hard-coded color hex values remain in the HTML outside `:root` blocks

---

## Phase 5 — App Menu & About Panel

**Est. time: 30 min | Checkpoint: all menu items functional, About shows correct version**

### Menu items to implement

```
Clearance
  ├── About Clearance        → NSPanel with version, author, GitHub link
  └── Quit Clearance  ⌘Q

File
  ├── Open Database…  ⌘O     → NSOpenPanel filtered to .db
  └── Reload          ⌘R     → webView.reload()

Help
  └── View on GitHub         → opens github.com/lucidlabsco/clearance
```

### About panel content

```
Clearance  v1.0.0
A macOS privacy permission manager.
Built by Chirag Chopra

100% local — no data leaves your Mac.

github.com/lucidlabsco/clearance
MIT License
```

**Checkpoint audit:**

- [ ] `⌘O` opens a file picker filtered to `.db` files
- [ ] Selected file loads into the webView (via JS injection: `handleFileFromNative(path)`)
- [ ] `⌘R` reloads cleanly, drop screen returns
- [ ] About window shows correct version number pulled from `Bundle.main.infoDictionary`

---

*Phases 6–10 archived → [Docs/archive/phases_6_10.md](../archive/phases_6_10.md). Load when starting Milestone 3.*

