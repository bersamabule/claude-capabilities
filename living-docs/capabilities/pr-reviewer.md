# PR Reviewer — Code Review & PR Management

"Review code like I understand the whole codebase, not just the diff."

## When It Activates
1. **On Request**: Via `/review`, `/review-pr`, or `/pr-create`
2. **Before Commits**: Quick safety check
3. **PR Creation**: Auto-generate descriptions

## Review Layers

| Layer | What's Checked |
|-------|----------------|
| Security | Secrets, injection, auth, data exposure |
| Logic | Edge cases, error handling, race conditions |
| Performance | N+1 queries, memory leaks, blocking ops |
| Quality | Conventions, readability, dead code |
| Testing | Coverage, meaningful tests |
| Documentation | API docs, breaking changes |

## Verdicts
- **APPROVE** — No blocking issues
- **REQUEST_CHANGES** — Critical issues must be fixed
- **COMMENT** — Observations only

## Commands
- `/review` — Review current branch vs base
- `/review:quick` — Security + critical issues only
- `/review:security` — Security-focused deep dive
- `/review-pr [number]` — Review existing GitHub PR
- `/pr-create` — Create PR with auto-generated description
