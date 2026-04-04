# Clearance

## Project
Native macOS privacy permission manager. Read these files in order before starting any work:
1. [CLEARANCE_PROJECT_PLAN.md](Docs/CLEARANCE_PROJECT_PLAN.md) — full product spec and phase details
2. [ACTION_PLAN.md](Docs/ACTION_PLAN.md) — architecture map, data flow, API decisions, constraints
3. The relevant milestone doc for the current session (see below)

## Existing Files (do not rebuild)
- [tcc_audit_app.html](Clearance/Resources/tcc_audit_app.html) already exists and is complete. It is the working HTML app built prior to this project. Do not rewrite it.
- Treat it as verified, production-ready code. The only permitted changes to this file are the additions specified in Phase 4 (light theme CSS block and privacy badge HTML). Everything else stays untouched.

## Bridge Pattern (Swift ↔ HTML)
- Swift and the HTML communicate via WKScriptMessageHandler, not WKDownloadDelegate.
- JS posts messages to named handlers registered in WebViewController.
- Never use navigation-based download interception for blob data — it will not work.

## Privacy Constraint
The app makes zero network requests except sql.js loading from cdnjs (cached after first load). Do not add analytics, crash reporting, or any external calls.

## Project Scope (File System)
All work stays inside the project directory (/Users/chiragc/Projects/Clearance).
Never create, edit, move, or delete anything outside it — not even temp files.

- For throwaway/intermediate work, use a `tmp/` folder inside the project root.
- When the work is done, either move the output to its proper project location or delete it.
- If something needs to persist but is not part of the public-facing build (generated assets, scratch files, test databases), add it to `.gitignore`.
- This rule has no exceptions. Everything done for this project is project-scoped.

## Audit Rule
After each phase, run the checkpoint list from the milestone doc against
the actual output. Only mark a phase complete when all checklist items pass. If any item fails, fix it before moving to the next phase.

## Git Flow (GitHub Flow via git-flow-next by Tower)
- `main` is the source of truth. Never commit directly to it.
- Create a topic branch per feature: feature/0-branding, feature/1-xcode-setup, etc.
- Merge to main via PR after each full milestone passes audit.
- One logical change per commit.

## Commit Messages
- Format: `type: short description` (feat, fix, docs, chore, style)
- Plain American English. No em dashes. No AI-sounding phrases.
- No co-author or tool attribution anywhere — not in commits, comments, or PRs.
- Example: `feat: add WKWebView with local file access config`

## Pull Requests
- Title: same format as commit message
- Description: plain English, what changed and why, no AI tone
- Include a screenshot for any UI change

## Code Style
- Write code a skilled human developer would write, not an agent
- No over-engineered abstractions or unnecessary design patterns
- No third-party Swift dependencies
- Single-file HTML stays single-file. Swift files stay modular.
- Comment non-obvious logic only — not every line

## Milestone Structure
- Milestone 1: Phases 0–3 — Foundation (app runs, WebView loads, downloads work)
- Milestone 2: Phases 4–5 — Polish (themes, menus, About panel)
- Milestone 3: Phases 6–10 — Ship (repo, README, release)

Read only the milestone doc for the session you are in. Do not read ahead.

## Context Health Check
Run at phase start only. Full procedure: [Docs/context-health-check.md](Docs/context-health-check.md)
