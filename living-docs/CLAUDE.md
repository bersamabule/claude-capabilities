# CLAUDE.md - Living Documentation Context

> **Purpose**: This file provides persistent context for Claude across sessions.
> Claude reads this automatically at the start of each conversation.
> Keep this file updated to maintain continuity.

---

## Project Overview

**Project Name**: [PROJECT_NAME]
**Repository**: [REPO_URL]
**Primary Language**: [LANGUAGE]
**Last Updated**: [DATE]

### Description
[Brief description of what this project does and its purpose]

### Current Status
- **Phase**: [Development/Testing/Production/Maintenance]
- **Version**: [Current version]
- **Health**: [Healthy/Has Issues/Critical]

---

## Quick Reference

### Build & Run
```bash
# Install dependencies
[INSTALL_COMMAND]

# Run development
[DEV_COMMAND]

# Run tests
[TEST_COMMAND]

# Build for production
[BUILD_COMMAND]
```

### Key Entry Points
| Purpose | File |
|---------|------|
| Main entry | `[path/to/main]` |
| Configuration | `[path/to/config]` |
| Routes/API | `[path/to/routes]` |
| Database | `[path/to/db]` |

---

## Testing Configuration

### Test Framework
- **Framework**: [Jest/Vitest/Pytest/Go test/etc.]
- **Location**: [tests/ or __tests__/ or *.test.ts]
- **Coverage Tool**: [built-in/nyc/coverage.py/etc.]

### Test Commands
```bash
# Run all tests
[TEST_COMMAND]

# Run single file
[TEST_SINGLE_COMMAND]

# Run with coverage
[COVERAGE_COMMAND]

# Watch mode
[TEST_WATCH_COMMAND]
```

### Coverage Thresholds
- **Minimum**: 70%
- **Target**: 80%
- **Critical Paths**: 90%

### Testing Conventions
- Test file naming: [*.test.ts / test_*.py / *_test.go]
- Test organization: [by feature / by module / adjacent to source]
- Mocking approach: [Jest mocks / unittest.mock / testify]

---

## Architecture Summary

### Tech Stack
- **Frontend**: [Framework, libraries]
- **Backend**: [Framework, runtime]
- **Database**: [Type, name]
- **Infrastructure**: [Hosting, CI/CD]

### Directory Structure
```
[PROJECT_ROOT]/
├── src/           # Source code
├── tests/         # Test files
├── docs/          # Documentation
│   ├── adr/       # Architecture Decision Records
│   ├── chronicle/ # Development session logs
│   ├── inspect/   # App inspection reports
│   └── testing/   # Test configuration
└── .claude/       # Claude commands
```

### Key Patterns
- [Pattern 1]: [Brief explanation]
- [Pattern 2]: [Brief explanation]
- [Pattern 3]: [Brief explanation]

---

## Code Conventions

### Style Guide
- **Formatting**: [Prettier/ESLint/Black/etc.]
- **Naming**: [camelCase/snake_case/PascalCase rules]
- **Comments**: [When and how to comment]

### Commit Messages
Format: `type(scope): description`

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Branch Strategy
- `main` - Production-ready code
- `develop` - Integration branch  
- `feature/*` - New features
- `fix/*` - Bug fixes

---

## Current State

### Active Work
- [ ] [Current task 1]
- [ ] [Current task 2]

### Recent Changes
| Date | Change | Chronicle Entry |
|------|--------|-----------------|
| [DATE] | [Brief description] | [Link] |

### Known Issues
| Issue | Severity | Notes |
|-------|----------|-------|
| [Description] | [High/Med/Low] | [Context] |

---

## Important Decisions

### Key ADRs
| ADR | Title | Status |
|-----|-------|--------|
| [ADR-0001](docs/adr/0001-example.md) | [Title] | [Accepted] |

### Constraints
- [Technical constraint 1]
- [Business constraint 1]

---

## Session Continuity

### For Next Session
> **Where I left off**: [Description]
>
> **Next steps**: [What to do next]
>
> **Watch out for**: [Gotchas]

### Chronicle Index
See `docs/chronicle/` for session history.

---

## Claude-Specific Instructions

### Preferred Behaviors
- Always run tests after code changes
- Verify before delivery
- Follow existing patterns

### Verification Requirements
- Run tests after changes
- Check coverage maintained
- Lint before committing
- No debug statements in delivered code

### Boundaries (DO NOT)
- [Never do X]
- [Avoid Y without asking]

### Slash Commands
- `/status` - Project status
- `/chronicle` - Create session entry
- `/adr` - Create architecture decision
- `/handoff` - Prepare handoff
- `/inspect` - Capture app context
- `/verify` - Run verification suite
- `/test` - Run tests

---

*Living Documentation system - Update frequently for context continuity.*
