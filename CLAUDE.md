# CLAUDE.md - Living Documentation Context

> **Purpose**: This file provides persistent context for Claude across sessions.
> Claude reads this automatically at the start of each conversation.
> Keep this file updated to maintain continuity.

---

## Project Overview

**Project Name**: Claude Code Helper
**Repository**: Local (C:\Claude_Code_helper)
**Primary Language**: PowerShell, Bash, Markdown
**Last Updated**: 2025-12-15

### Description
A collection of templates, scripts, and configurations that extend Claude Code's capabilities with autonomous features. This project contains the "Living Documentation" system that can be initialized in any project to provide persistent context, app inspection, code verification, and dependency management.

### Current Status
- **Phase**: Development
- **Version**: 0.5.0 (5 capabilities implemented)
- **Health**: Healthy

---

## Quick Reference

### Initialize Living Docs in a Project
```powershell
# Windows
& "C:\Claude_Code_helper\living-docs\init-living-docs.ps1" -ProjectPath "C:\path\to\project"

# Linux/Mac
./living-docs/init-living-docs.sh /path/to/project
```

### Start Debug Browser
```powershell
# Windows (Brave)
& "C:\Claude_Code_helper\living-docs\start-browser-debug.ps1"
```

### Key Entry Points
| Purpose | File |
|---------|------|
| Initializer (Windows) | `living-docs/init-living-docs.ps1` |
| Initializer (Unix) | `living-docs/init-living-docs.sh` |
| CLAUDE.md Template | `living-docs/CLAUDE.md` |
| Slash Commands | `living-docs/.claude/commands/` |

---

## Capabilities Implemented

### 1. Living Documentation
- Persistent context via CLAUDE.md
- Chronicle system for session history
- ADR (Architecture Decision Records) support
- Auto-initialization detection

### 2. Autonomous Lookup and Inform (App Inspection)
- Browser inspection via Playwright MCP
- Console log capture
- Network request monitoring
- Screenshot capability
- No manual screenshots needed from users

### 3. Autonomous Test and Check
- Pre-delivery code verification
- Multi-phase testing (syntax, lint, tests, build)
- Self-correction protocol
- Coverage tracking

### 4. Dependency Doctor
- Security vulnerability scanning
- Outdated package detection
- Upgrade plan generation
- Multi-ecosystem support (npm, pip, cargo, go)
- Integration with Test & Check for safe upgrades

### 5. Autonomous PR Reviewer
- Context-aware code review (reads CLAUDE.md)
- Multi-layer analysis (security, logic, performance, quality)
- GitHub PR integration via MCP tools
- Auto-generated PR descriptions
- Review submission with inline comments

---

## Directory Structure
```
Claude_Code_helper/
├── living-docs/           # Template files and initializers
│   ├── .claude/
│   │   └── commands/      # Slash command templates
│   ├── docs/              # Documentation templates
│   ├── init-living-docs.ps1
│   ├── init-living-docs.sh
│   ├── start-browser-debug.ps1
│   ├── start-browser-debug.sh
│   ├── CLAUDE.md          # Template
│   └── AGENTS.md          # Template
├── docs/                  # This project's docs (Living Docs initialized here)
│   ├── adr/
│   ├── chronicle/
│   ├── dependencies/
│   ├── inspect/
│   └── testing/
├── .claude/
│   └── commands/          # This project's slash commands
├── CLAUDE.md              # This file
└── AGENTS.md
```

---

## Current State

### Active Work
- [x] Living Documentation - Complete
- [x] Autonomous Lookup and Inform - Complete
- [x] Autonomous Test and Check - Complete
- [x] Dependency Doctor - Complete & Tested
- [x] Autonomous PR Reviewer - Complete

### Recent Changes
| Date | Change | Chronicle Entry |
|------|--------|-----------------|
| 2025-12-15 | Added Dependency Doctor capability | docs/chronicle/2025-12-15-dependency-doctor.md |
| 2025-12-15 | Initialized Living Docs on this project | docs/chronicle/2025-12-15-project-initialization.md |

### Known Issues
| Issue | Severity | Notes |
|-------|----------|-------|
| None | - | All capabilities working |

---

## Capabilities Roadmap

See "Session Continuity" section for next capabilities to build.

---

## Session Continuity

### For Next Session
> **Where I left off**: Successfully tested Dependency Doctor capability. All 4 core capabilities are now implemented and working.
>
> **Next steps**: Choose next capability from roadmap (see below)
>
> **Watch out for**: Global CLAUDE.md in ~/.claude/ has the master capability instructions

### Capabilities Roadmap Table (Original Top 10)

| # | Capability | Description | Status |
|---|------------|-------------|--------|
| 1 | **Dependency Doctor** | Security vulns, outdated versions, auto-upgrade PRs | **DONE** |
| 2 | Codebase Knowledge Graph | Semantic graph of codebase, architectural queries | Not Started |
| 3 | Technical Debt Radar | Code smells, complexity hotspots, debt dashboard | Not Started |
| 4 | Production Feedback Loop | Sentry/logs integration, error correlation, fixes | Not Started |
| 5 | Intelligent Onboarding Agent | Auto-generate onboarding docs, code tours | Not Started |
| 6 | Performance Profiler | Bottleneck detection, auto-optimization | Not Started |
| 7 | Cross-Session Learning Profile | Learn user patterns/preferences over time | Not Started |
| 8 | **Autonomous PR Reviewer** | Deep PR review with codebase context | **DONE** |
| 9 | Spec-to-Implementation Bridge | OpenAPI/GraphQL/Figma to code, drift detection | Not Started |
| 10 | Incident Response Copilot | Root cause tracing, rollback strategies, comms | Not Started |

**Foundation Capabilities (Pre-requisites, already built):**
- Living Documentation - Persistent context via CLAUDE.md (DONE)
- Autonomous Lookup and Inform - App inspection without screenshots (DONE)
- Autonomous Test and Check - Auto-verify code before delivery (DONE)

### Chronicle Index
See `docs/chronicle/` for session history.

---

## Claude-Specific Instructions

### Preferred Behaviors
- Initialize Living Docs in new projects
- Use Chronicle for session tracking
- Create ADRs for significant decisions
- Use App Inspection instead of asking for screenshots
- Verify code before delivery
- Check dependencies at session start

### Slash Commands
- `/status` - Project status
- `/chronicle` - Create session entry
- `/adr` - Create architecture decision
- `/handoff` - Prepare handoff
- `/inspect` - Capture app context
- `/verify` - Run verification suite
- `/test` - Run tests
- `/deps` - Dependency health report
- `/deps-upgrade` - Dependency upgrade plan
- `/review` - Code review for current branch
- `/review-pr` - Review existing GitHub PR
- `/pr-create` - Create PR with auto-description

---

*Living Documentation system - Update frequently for context continuity.*
