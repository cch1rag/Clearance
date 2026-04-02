# Milestone 2: Polish

Goal: Both color themes are correct and switch without reload. All menu items
work. About panel shows accurate version info pulled from Info.plist. Privacy
badge is visible on the drop screen in both themes.

Prerequisite: Milestone 1 complete and merged to main.

---

## Phases

### Phase 4 — HTML Light Theme + Privacy Copy
Branch: feature/4-light-theme`

This phase makes two additions to tcc_audit_app.html. No existing code is
removed or restructured. Add only.

Addition 1 — Light theme CSS block:
Append inside the existing <style> tag, after all current :root rules:

  @media (prefers-color-scheme: light) {
    :root {
      --bg: #F7F6F3;   --sf: #FFFFFF;   --sf2: #F0EEE9;  --sf3: #E8E5DF;
      --bd:  rgba(0,0,0,0.07);
      --bd2: rgba(0,0,0,0.11);
      --bd3: rgba(0,0,0,0.16);
      --tx: #1A1A18;   --tx2: #6B6B68;  --tx3: #9B9B98;  --tx4: #C8C6C0;
      --grn: #2D8A4E;
      --grn-bg: rgba(45,138,78,0.09);
      --grn-bd: rgba(45,138,78,0.22);
      --red: #B84040;
      --red-bg: rgba(184,64,64,0.09);
      --red-bd: rgba(184,64,64,0.22);
      --amb: #9E6428;
      --amb-bg: rgba(158,100,40,0.09);
      --amb-bd: rgba(158,100,40,0.25);
      --blue: #2E6DA4;
      --blue-bg: rgba(46,109,164,0.09);
    }
  }

Addition 2 — Privacy badge HTML:
In the drop screen markup, insert the badge between .drop-eyebrow and
#drop-area. Do not place it inside #drop-area. The existing structure is:

  <div class="drop-eyebrow">...</div>
  <div id="drop-area">...</div>    ← drop-area already contains its own ⬡ icon
  ...
  <p class="drop-notice">...</p>

Insert between .drop-eyebrow and #drop-area:

  <div class="privacy-badge">
    <span class="priv-icon">⬡</span>
    100% local &nbsp;·&nbsp; no data leaves your Mac
  </div>

Add the corresponding CSS inside the <style> tag:

  .privacy-badge {
    font-size: 11px;
    color: var(--grn);
    background: var(--grn-bg);
    border: 1px solid var(--grn-bd);
    border-radius: 20px;
    padding: 5px 14px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 6px;
  }
  .priv-icon { font-size: 13px; }

Audit checklist:
- [ ] Switch System Preferences to Light — app switches without reload
- [ ] Switch back to Dark — reverts cleanly, no visual glitches
- [ ] Privacy badge is visible on the drop screen in both themes
- [ ] Badge sits between the eyebrow label and the drop area, not inside it
- [ ] No hardcoded hex color values exist outside :root blocks in the HTML

---

### Phase 5 — App Menu + About Panel
Branch: feature/5-menu`

Menu structure:
  Clearance
    About Clearance       → NSPanel (see content below)
    Quit Clearance  CmdQ

  File
    Open Database…  CmdO  → NSOpenPanel filtered to .db files
    Reload          CmdR  → webView.reload()

  Help
    View on GitHub        → NSWorkspace.shared.open() with repo URL

About panel content:
  Clearance  v[version from Bundle.main.infoDictionary]
  A macOS privacy permission manager.
  Built by Chirag Chopra / Lucid Labs

  100% local — no data leaves your Mac.

  github.com/lucidlabsco/clearance
  MIT License

Version must be read from Bundle.main.infoDictionary["CFBundleShortVersionString"].
Never hardcode it.

Cmd+O implementation:
- NSOpenPanel filtered to .db files only
- On selection, read the file into Data, base64-encode it
- Call webView.evaluateJavaScript("handleFileFromNative('\(b64)', '\(filename)')")
- This calls the handleFileFromNative() function added to the HTML in Phase 3

Audit checklist:
- [ ] CmdO opens a file picker that shows only .db files
- [ ] Selected file loads and renders the permission table correctly
- [ ] CmdR reloads the WebView and returns to the drop screen
- [ ] About panel shows the correct version number from Info.plist
- [ ] View on GitHub opens github.com/lucidlabsco/clearance in the default browser
- [ ] CmdQ quits the app

---

## Milestone 2 Gate

Both phase audits pass. Run a full theme check in both modes before marking
complete: load a DB, edit a cell, check all UI states (pending amber, granted
green, denied red) in light mode and dark mode. Do a clean build from scratch
to confirm no hardcoded values were introduced.

Status: [ ] Complete
