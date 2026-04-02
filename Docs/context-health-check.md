# Context Health Check Procedure

Run at the start of each phase (before loading docs).

**Scope: always-loaded files only.**
Files to check: `CLAUDE.md`, `ACTION_PLAN.md`, `CLEARANCE_PROJECT_PLAN.md`

---

## Step 1 — Measure

Run `wc -w` on each file. Use 1 word ≈ 1.3 tokens.

Soft token limits:
- CLAUDE.md: 600 tokens (~460 words)
- ACTION_PLAN.md: 1500 tokens (~1150 words)
- CLEARANCE_PROJECT_PLAN.md: 2000 tokens (~1540 words)

---

## Step 2 — Flag content quality

Even within-limit files should be flagged if they contain:
- Inline code examples that duplicate content already in source files
- Ticked checklists or completed phase specs that are no longer actionable
- Phase-specific details (volatile content) that have crept into a stable always-loaded file

---

## Step 3 — Flag structure

In CLAUDE.md, the most critical rules must appear in the first half. If important constraints are buried past the midpoint, flag for reorganisation. (Models attend most strongly to content at the start and end of a long context.)

---

## Step 4 — Report and act only if flagged

If nothing triggers, proceed without interruption.

If anything is flagged, pause, present the finding and a specific proposed fix, and wait for acknowledgement before continuing.

**Mitigation options:**
- Move completed phase content to `Docs/archive/`
- Replace inline code blocks with a pointer to the actual source file
- Extract stable reference tables into a standalone file loaded on demand
- Reorganise CLAUDE.md so high-priority rules appear in the first third

**Priority order when multiple files are flagged:** CLAUDE.md first, then ACTION_PLAN.md, then CLEARANCE_PROJECT_PLAN.md.
