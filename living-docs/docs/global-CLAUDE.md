# Global Claude Configuration

## Living Documentation — Auto-Initialization

When starting work in ANY new project directory, check if `CLAUDE.md` exists. If not, offer to initialize Living Documentation using:
```powershell
& "C:\Claude_Code_helper\living-docs\init-living-docs.ps1" -ProjectPath "[CURRENT_DIR]"
```

## Session Start Checklist

1. Check for `CLAUDE.md` in working directory (offer init if missing)
2. Check for recent Chronicle entries in `docs/chronicle/`
3. Quick dependency scan for critical/high vulnerabilities (if package manager detected)
4. Acknowledge context loaded

---

## Core Behaviors

These apply automatically. Full specs are in `~/.claude/capabilities/` — read on demand when you need implementation details.

### App Inspection
When user reports something "looks wrong" or asks to "check" the app, autonomously inspect using Playwright MCP tools (browser_snapshot, take_screenshot, console_messages, network_requests). Browser must be running with debugging: `& "C:\Claude_Code_helper\living-docs\start-browser-debug.ps1"` (Brave, port 9222).

### Code Verification
Verify code works before delivering. Phase 1: syntax/imports. Phase 2: lint/tests. Phase 3: full suite. Phase 4: build/smoke. Self-correct when verification fails.

### Dependency Monitoring
On session start, quick vulnerability scan. On `/deps`, full audit. Before commits, check for known vulnerabilities. Alert immediately for CRITICAL, warn for HIGH.

### PR Review
On `/review` or `/pr-create`, perform deep context-aware review covering security, logic, performance, quality, testing, and documentation.

### Context Protection
Monitor context window usage. Warn at 70%. At 80%+, suggest `/context-guardian` for graceful handoff. At 90%+, `/emergency-handoff`. Creates `docs/context/WORKING.md` or `EMERGENCY.md`.

---

## ManageBac Integration

| Field | Value |
|-------|-------|
| URL | `https://tzuchischool.managebac.com/` |
| Username | `andrew.hymers@tzuchi.sch.id` |
| Password | *Windows Credential Manager: "ManageBac"* |

Reference docs: `C:\Claude-Work\reference\ManageBac-Navigation-Map.md` and `ManageBac-Workflows.md`

| Class | ID | Grade |
|-------|-----|-------|
| English B Phase 5 B | 12756230 | G8 |
| English B Phase 5 E | 12756233 | G8 |
| English B Phase 5 B | 12756131 | G7 |
| English B Phase 6 C | 12756135 | G7 |

Common tasks: Lesson Experience entry (Class → Tasks & Units → Unit → Stream), Grade entry (Class → Gradebook → Term Grades), Report Comments.

Browser automation: Use Playwright MCP tools. Auto-save enabled. Session timeout ~25 min.

---

## PPTX Slide Generation

When user asks for slide decks/presentations/PPTX, use the PPTX Intelligent Grouping skill.

**Core rules:**
- NEVER generate slides as single background images
- ALWAYS create discrete, editable elements grouped for animation
- Library: `C:\Claude-Work\.agent\skills\pptx-intelligent-grouping\lib\pptx-grouping-utils.js`
- Full docs: `C:\Claude-Work\.agent\skills\pptx-intelligent-grouping\SKILL.md`
- Dependencies: `npm install pptxgenjs adm-zip @xmldom/xmldom`

---

## yt-dlp — YouTube Downloads

**Location**: `C:\Tools\yt-dlp\yt-dlp.exe`
**Defaults**: 1080p max, MP4, English subtitles embedded.

```powershell
& 'C:\Tools\yt-dlp\yt-dlp.exe' '[URL]' -f 'bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080][ext=mp4]/best[height<=1080]' --write-subs --write-auto-subs --sub-langs en --embed-subs --merge-output-format mp4 -o '[OUTPUT_PATH]\%(title)s.%(ext)s'
```

---

## User Preferences

- Initialize Living Documentation in new coding projects
- Use Autonomous Lookup for debugging (no manual screenshots)
- Verify code before delivery (Test & Check)
- Monitor dependencies for security (Dependency Doctor)
- Use PPTX Intelligent Grouping for all presentations
- Default browser: Brave (Chromium-based)

---

## Slash Commands — Quick Reference

### Production (implemented, battle-tested)
- `/slides` or `/pptx` — Generate PowerPoint with intelligent grouping
- `/pm` — Regenerate PM dashboard
- `/pm next` — What should I do right now?
- `/pm done [ID]` — Mark task complete
- `/pm new` — Intake new project
- `/pm update` — Interactive status update
- `/pm gantt` — Text-based timeline
- `/pm archive` — Archive completed project

### Beta (working, needs more testing)
- `/deps` — Dependency health report
- `/deps-upgrade` — Generate upgrade plan
- `/review` — Code review current branch
- `/review-pr [N]` — Review existing GitHub PR
- `/pr-create` — Create PR with auto-description
- `/context-status` — Check context window usage
- `/context-guardian` — Create session handoff
- `/emergency-handoff` — Emergency minimal handoff

### Spec-Only (defined, not yet implemented)
`/kg-build`, `/kg-query`, `/profile-view`, `/profile-learn`, `/debt-scan`, `/debt-report`, `/debt-fix`, `/onboard`, `/tour`, `/explain`, `/spec-scan`, `/spec-drift`, `/spec-generate`, `/spec-validate`

---

## Capability Reference Files

Full specs for each capability are stored in `~/.claude/capabilities/`. Read these when you need implementation details:

| File | Capability |
|------|-----------|
| `app-inspection.md` | Browser debugging with Playwright MCP |
| `test-and-check.md` | Code verification phases |
| `dependency-doctor.md` | Dependency auditing and upgrades |
| `pr-reviewer.md` | Code review and PR creation |
| `context-guardian.md` | Session handoff and context protection |
| `spec-only.md` | Index of spec-only capabilities (KG, Debt, Onboard, Spec Bridge, Learning Profile) |
