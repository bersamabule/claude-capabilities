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
- **Version**: 0.11.0 (11 capabilities implemented)
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

### 6. Codebase Knowledge Graph
- Semantic graph of entire codebase
- Tracks files, functions, classes, and relationships
- Natural language queries ("What depends on X?")
- Impact analysis for changes
- Pattern and architecture detection

### 7. Cross-Session Learning Profile
- Learns coding patterns and preferences over time
- Tracks common mistakes to avoid
- Adapts communication style
- Project-specific and global preferences
- Explicit teaching via /profile-learn

### 8. Technical Debt Radar
- Scans codebase for technical debt
- Detects complexity, code smells, TODOs, test gaps
- Severity-based prioritization
- Refactoring guidance via /debt-fix
- Trend tracking over time

### 9. Intelligent Onboarding Agent
- Auto-generates comprehensive onboarding guides
- Creates interactive code tours for any area
- Deep explanations of files, functions, and concepts
- Adapts to user experience level
- Integrates with Knowledge Graph for better context

### 10. Spec-to-Implementation Bridge
- Detects and catalogs API specs (OpenAPI, GraphQL, Prisma, Proto)
- Drift detection between specs and implementation
- Code generation from specs (types, clients, server stubs)
- Spec validation with best practice checks
- CI integration for spec compliance

### 11. Context Guardian
- Monitors context window usage proactively
- Warns before "prompt is too long" errors
- Creates comprehensive handoff documents (WORKING.md)
- Emergency handoff for critical situations (EMERGENCY.md)
- Enables seamless session transitions with zero lost work

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
│   ├── knowledge-graph/
│   ├── learning/
│   ├── debt/
│   ├── onboarding/
│   ├── specs/
│   ├── context/
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
- [x] Codebase Knowledge Graph - Complete
- [x] Cross-Session Learning Profile - Complete
- [x] Technical Debt Radar - Complete
- [x] Intelligent Onboarding Agent - Complete
- [x] Spec-to-Implementation Bridge - Complete
- [x] Context Guardian - Complete

### Recent Changes
| Date | Change | Chronicle Entry |
|------|--------|-----------------|
| 2025-12-15 | Added Context Guardian capability | docs/chronicle/2025-12-15-context-guardian.md |
| 2025-12-15 | Added Spec-to-Implementation Bridge capability | docs/chronicle/2025-12-15-spec-bridge.md |
| 2025-12-15 | Added Intelligent Onboarding Agent capability | docs/chronicle/2025-12-15-intelligent-onboarding.md |
| 2025-12-15 | Added Technical Debt Radar capability | docs/chronicle/2025-12-15-technical-debt-radar.md |
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
> **Where I left off**: Completed Context Guardian capability. All 11 capabilities are now implemented and working.
>
> **Next steps**: Choose next capability from roadmap (see below) - remaining: Production Feedback Loop, Performance Profiler, Incident Response Copilot
>
> **Watch out for**: Global CLAUDE.md in ~/.claude/ has the master capability instructions. Use `living-docs/global-CLAUDE.md` as template for other machines.

### Capabilities Roadmap Table (Original Top 10)

| # | Capability | Description | Status |
|---|------------|-------------|--------|
| 1 | **Dependency Doctor** | Security vulns, outdated versions, auto-upgrade PRs | **DONE** |
| 2 | **Codebase Knowledge Graph** | Semantic graph of codebase, architectural queries | **DONE** |
| 3 | **Technical Debt Radar** | Code smells, complexity hotspots, debt dashboard | **DONE** |
| 4 | Production Feedback Loop | Sentry/logs integration, error correlation, fixes | Not Started |
| 5 | **Intelligent Onboarding Agent** | Auto-generate onboarding docs, code tours | **DONE** |
| 6 | Performance Profiler | Bottleneck detection, auto-optimization | Not Started |
| 7 | **Cross-Session Learning Profile** | Learn user patterns/preferences over time | **DONE** |
| 8 | **Autonomous PR Reviewer** | Deep PR review with codebase context | **DONE** |
| 9 | **Spec-to-Implementation Bridge** | OpenAPI/GraphQL/Figma to code, drift detection | **DONE** |
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
- `/kg-build` - Build codebase knowledge graph
- `/kg-query` - Query the knowledge graph
- `/kg-update` - Update graph incrementally
- `/profile-view` - View learning profile
- `/profile-learn` - Teach a preference
- `/profile-reset` - Reset learning profile
- `/debt-scan` - Scan codebase for technical debt
- `/debt-report` - Generate comprehensive debt report
- `/debt-fix` - Get refactoring guidance for debt item
- `/onboard` - Generate codebase onboarding guide
- `/tour` - List or take code tours
- `/tour:create` - Create a new code tour
- `/explain` - Deep explanation of files, functions, or concepts
- `/spec-scan` - Scan for API specs (OpenAPI, GraphQL, etc.)
- `/spec-drift` - Check for spec-implementation drift
- `/spec-generate` - Generate code from specs
- `/spec-validate` - Validate spec files
- `/context-status` - Check context window usage
- `/context-guardian` - Create comprehensive session handoff
- `/emergency-handoff` - Emergency minimal handoff

---

*Living Documentation system - Update frequently for context continuity.*
