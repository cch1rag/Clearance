# Contributing to Clearance

Thanks for your interest in contributing. Here is what you need to know before opening a PR.

---

## Before You Open a PR

Open an issue first for anything beyond a straightforward bug fix. This lets us agree on scope and approach before you spend time writing code.

---

## What Is In Scope

- Bug fixes
- New `kTCCService` columns in the permission table
- Accessibility improvements (VoiceOver, keyboard navigation)
- Performance improvements to table rendering or DB loading
- Theme refinements (contrast, spacing, typography)

## What Is Out of Scope

- SIP bypass or writing to system TCC (`/var/db/TCC`)
- App Store distribution
- Windows or Linux ports
- Third-party Swift dependencies

---

## Setup

Requirements: macOS 12 or later, Xcode 15 or later.

```bash
git clone https://github.com/cch1rag/Clearance.git
cd Clearance
open Clearance.xcodeproj
```

Press **⌘R** to build and run. There are no external dependencies to install.

## Debugging the WebView

Open Safari, go to **Develop → [Your Mac] → Clearance**, and you will get a full Web Inspector attached to the WKWebView.

---

## Code Style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- The HTML app lives in a single file (`Clearance/Resources/tcc_audit_app.html`) and must stay that way
- Comment non-obvious SQL queries and WKWebView delegate logic; skip obvious comments

---

## PR Format

- Title: `type: short description` (`feat`, `fix`, `docs`, `chore`, `style`)
- One logical change per PR
- Include a screenshot for any UI change
- Plain English in the description — what changed and why
