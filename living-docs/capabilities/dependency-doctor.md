# Dependency Doctor — Automated Dependency Management

Proactively monitor, audit, and help upgrade project dependencies for security and freshness.

## When It Activates
1. **Session Start**: Quick vulnerability scan when entering a project
2. **On Request**: Full audit via `/deps`
3. **Before Commits**: Check for known vulnerable dependencies

## What Gets Checked

| Check | JS | Python |
|-------|-----|--------|
| Security | `npm audit` | `pip-audit` |
| Outdated | `npm outdated` | `pip list --outdated` |

## Severity Response

| Severity | Response |
|----------|----------|
| **CRITICAL** | Alert immediately, provide upgrade command |
| **HIGH** | Warn prominently, recommend upgrade this session |
| **MODERATE** | Note in report, suggest upgrading soon |
| **LOW** | Include in full report only |

## Upgrade Workflow
1. Analyze breaking changes
2. Generate step-by-step plan
3. Backup lock file
4. Execute with user confirmation
5. Verify tests pass
6. Rollback if verification fails

## Commands
- `/deps` — Full dependency health report
- `/deps-upgrade` — Generate upgrade plan
- `/deps-upgrade [package]` — Upgrade specific package
