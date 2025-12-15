# Living Documentation - Quick Start Guide

## What Is This?

Living Documentation gives Claude **persistent memory** across sessions. Instead of starting fresh each time, Claude can:

1. **Read** your project's current state from `CLAUDE.md`
2. **Understand** past decisions from Architecture Decision Records (ADRs)
3. **Follow** the development history in the Chronicle
4. **Leave** breadcrumbs for future sessions

---

## 5-Minute Setup

### Step 1: Initialize in Your Project

**Windows (PowerShell):**
```powershell
# Navigate to your project
cd C:\path\to\your\project

# Run the initializer
& "C:\Claude_Code_helper\living-docs\init-living-docs.ps1"
```

**Mac/Linux (Bash):**
```bash
# Navigate to your project
cd /path/to/your/project

# Run the initializer
bash /path/to/living-docs/init-living-docs.sh
```

### Step 2: Fill In Your Project Details

Edit these two files with your project specifics:

1. **`CLAUDE.md`** - The main context file
   - Project overview and tech stack
   - Build/run commands
   - Key file locations
   - Current work status

2. **`AGENTS.md`** - AI guidance (industry standard)
   - Setup and build commands
   - Code style rules
   - Testing commands
   - Boundaries (what NOT to do)

### Step 3: Start Working

That's it! Claude will now automatically read `CLAUDE.md` at the start of each session.

---

## Daily Workflow

### Starting a Session

1. Claude reads `CLAUDE.md` automatically
2. Use `/status` command to get a quick summary
3. Check the latest Chronicle entry for context

### During Work

- Make decisions? Consider creating an ADR
- Use Claude normally for development

### Ending a Session

1. Use `/chronicle` to create a session summary
2. Or use `/handoff` for a comprehensive handoff

---

## File Structure After Setup

```
your-project/
├── CLAUDE.md              # Main context (Claude reads this)
├── AGENTS.md              # AI agent guidance
├── docs/
│   ├── adr/
│   │   ├── README.md      # ADR index
│   │   └── 0000-template.md
│   └── chronicle/
│       ├── README.md      # Chronicle index
│       ├── 0000-template.md
│       └── YYYY-MM-DD-*.md  # Session entries
└── .claude/
    └── commands/
        ├── chronicle.md   # /chronicle command
        ├── adr.md         # /adr command
        ├── status.md      # /status command
        └── handoff.md     # /handoff command
```

---

## Slash Commands

| Command | Purpose |
|---------|---------|
| `/status` | Get current project status and last session summary |
| `/chronicle` | Create a chronicle entry for the current session |
| `/adr` | Create a new Architecture Decision Record |
| `/handoff` | Prepare comprehensive handoff for next session |

---

## When to Create What

### Chronicle Entry
Create when:
- Ending a work session
- Completing a significant milestone
- Encountering a major blocker
- Handing off to someone else

### Architecture Decision Record (ADR)
Create when:
- Choosing between technologies
- Deciding on an architectural pattern
- Making a decision that affects multiple parts of the codebase
- Establishing a convention that should be followed

### Update CLAUDE.md
Update when:
- Project status changes
- Active work items change
- New issues are discovered
- Starting or ending a phase

---

## Tips for Best Results

### Keep CLAUDE.md Current
The more accurate `CLAUDE.md` is, the faster Claude can get up to speed. Update it:
- At the end of each session
- When major things change
- Before long breaks from the project

### Write Chronicles for Future You
Write chronicle entries as if explaining to yourself 6 months from now. Include:
- What you were trying to do
- What actually happened
- What's next
- Any gotchas or context that might be lost

### ADRs Are Forever
Never delete ADRs. When decisions change:
1. Create a new ADR
2. Mark the old one as "Superseded by ADR-XXXX"
3. This preserves the history of why things changed

### Keep It Light
Don't over-document. The goal is useful context, not comprehensive records. A quick 5-minute chronicle entry is better than skipping it entirely.

---

## Troubleshooting

### Claude doesn't seem to know about my project
- Check that `CLAUDE.md` exists in your project root
- Verify the file has actual content (not just template placeholders)

### Chronicle entries are piling up
- That's fine! They're meant to accumulate
- Consider summarizing monthly and archiving old entries
- Or add them to `.gitignore` if you don't want to commit them

### ADR numbering got out of order
- It doesn't matter much - the number is just an ID
- You can renumber if it bothers you, but it's not necessary

---

## Advanced Usage

### Multiple Projects
Each project gets its own Living Documentation. The templates are designed to be copied, not shared.

### Team Usage
Commit the Living Documentation files to git:
- `CLAUDE.md` - Shared project context
- `AGENTS.md` - Shared AI guidance
- `docs/adr/*` - Shared decision records
- `docs/chronicle/*` - Optional (can be personal or shared)

### Customizing Templates
Feel free to modify the templates to fit your needs. The structure is a suggestion, not a requirement.

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                   LIVING DOCUMENTATION                       │
├─────────────────────────────────────────────────────────────┤
│  START SESSION                                               │
│    → Claude reads CLAUDE.md automatically                   │
│    → Use /status for quick summary                          │
│                                                             │
│  DURING WORK                                                │
│    → Make decisions? Create ADR with /adr                   │
│    → Work normally                                          │
│                                                             │
│  END SESSION                                                │
│    → Use /chronicle to record session                       │
│    → Or /handoff for full handoff                          │
│    → Update CLAUDE.md if needed                            │
├─────────────────────────────────────────────────────────────┤
│  FILES                                                       │
│    CLAUDE.md        → Main context (auto-read)              │
│    AGENTS.md        → AI guidance                           │
│    docs/adr/        → Architecture decisions                │
│    docs/chronicle/  → Session breadcrumbs                   │
└─────────────────────────────────────────────────────────────┘
```
