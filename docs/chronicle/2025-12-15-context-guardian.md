# Chronicle: Context Guardian

**Date**: 2025-12-15
**Session Focus**: Implement Context Guardian capability
**Status**: Completed

---

## Summary

Implemented the Context Guardian capability - the 11th capability in the Living Documentation system. This capability proactively monitors context window usage and facilitates graceful handoffs before sessions fail with "prompt is too long" errors.

---

## Problem Statement

Claude Code has a 200k token context window. When it fills up:
- The session fails with "prompt is too long"
- No further messages can be sent
- Work in progress may be lost
- You must start a new session from scratch

This typically happens in the middle of complex building sessions, causing significant workflow disruption and potential loss of work.

---

## Research Conducted

Consulted community best practices from:
- [Smart Handoff for Claude Code](https://blog.skinnyandbald.com/never-lose-your-flow-smart-handoff-for-claude-code/)
- [Token Reduction Workflow](https://gist.github.com/artemgetmann/74f28d2958b53baf50597b669d4bce43)
- [Handoff Protocol](https://blackdoglabs.io/blog/claude-code-decoded-handoff-protocol)
- [GitHub Issue #11455 - Session Handoff/Continuity Support](https://github.com/anthropics/claude-code/issues/11455)
- [Anthropic's Best Practices for Agentic Coding](https://www.anthropic.com/engineering/claude-code-best-practices)

### Key Insights from Community

1. **Monitor at 70-80%**: Create handoffs proactively, not when forced
2. **Use WORKING.md pattern**: Capture full session state in a structured file
3. **Keep resume prompts ready**: Enable seamless session transitions
4. **Git stash for safety**: Preserve uncommitted changes
5. **Token reduction**: Use subagents, clear between tasks, keep CLAUDE.md lean

---

## What Was Built

### Slash Commands Created

1. **`/context-status`** (`living-docs/.claude/commands/context-status.md`)
   - Checks current context window usage
   - Provides color-coded status (Green/Yellow/Orange/Red/Black)
   - Gives recommendations based on usage level
   - Helps users understand when to take action

2. **`/context-guardian`** (`living-docs/.claude/commands/context-guardian.md`)
   - Creates comprehensive `docs/context/WORKING.md` with full session state
   - Captures: objective, progress, files modified, decisions, problems, next steps
   - Updates CLAUDE.md with continuation notes
   - Optionally stashes/commits git changes
   - Provides ready-to-use resume prompt
   - `:quick` variant for 80-90% situations

3. **`/emergency-handoff`** (`living-docs/.claude/commands/emergency-handoff.md`)
   - Minimal handoff for critical situations (90%+)
   - Creates `docs/context/EMERGENCY.md` with essential info only
   - Stashes git changes immediately
   - Provides emergency resume prompt
   - Designed to execute in under 60 seconds

### Directory Structure

```
living-docs/
├── .claude/commands/
│   ├── context-status.md     # Check usage levels
│   ├── context-guardian.md   # Full handoff
│   └── emergency-handoff.md  # Emergency minimal handoff
└── docs/context/
    └── README.md             # Directory template
```

### Documentation Updates

- Updated `living-docs/global-CLAUDE.md` with full capability section
- Updated user's `~/.claude/CLAUDE.md` with capability
- Updated project `CLAUDE.md` to version 0.11.0

---

## Context Usage Levels

| Level | Usage | Status | Action |
|-------|-------|--------|--------|
| **Green** | 0-50% | Safe | Continue working |
| **Yellow** | 50-70% | Caution | Be mindful |
| **Orange** | 70-80% | Warning | Run `/context-guardian` |
| **Red** | 80-90% | Critical | Run `/emergency-handoff` |
| **Black** | 90%+ | Danger | Immediate handoff, session at risk |

---

## Handoff File Contents

### WORKING.md (Full Handoff)
- Original objective
- Progress summary (completed, in progress, not started)
- Modified files with change descriptions
- Key decisions and rationale
- Problems encountered (resolved and unresolved)
- Technical context (architecture, dependencies, config)
- Priority-ordered next steps
- Resume instructions and suggested prompt

### EMERGENCY.md (Minimal Handoff)
- What you were doing (one sentence)
- Modified files (git status)
- Single most important next step
- Emergency resume prompt

---

## Integration Points

- **Chronicle**: Handoffs can trigger chronicle entries
- **Living Documentation**: Updates CLAUDE.md automatically
- **Git Integration**: Stashes/commits to preserve changes

---

## How to Use

### Check Context Status
```
/context-status
```

### Proactive Handoff (at 70-80%)
```
/context-guardian
```

### Emergency Handoff (at 90%+)
```
/emergency-handoff
```

### Resume in New Session
```
Continue from the previous session. Read docs/context/WORKING.md
for the full state. The previous session was working on [TASK].
Start with [NEXT_STEP].
```

---

## Prevention Tips

1. **Check regularly**: Run `/context-status` every 30-40 messages
2. **Handoff early**: At 70%, not when forced
3. **Use subagents**: Offload exploration to preserve main context
4. **Clear between tasks**: Use `/clear` for unrelated work
5. **Keep CLAUDE.md lean**: Under 5k tokens
6. **Read selectively**: Only load files you need

---

## Capabilities Completed

| # | Capability | Status |
|---|------------|--------|
| 1 | Living Documentation | Done |
| 2 | Autonomous Lookup and Inform | Done |
| 3 | Autonomous Test and Check | Done |
| 4 | Dependency Doctor | Done |
| 5 | Autonomous PR Reviewer | Done |
| 6 | Codebase Knowledge Graph | Done |
| 7 | Cross-Session Learning Profile | Done |
| 8 | Technical Debt Radar | Done |
| 9 | Intelligent Onboarding Agent | Done |
| 10 | Spec-to-Implementation Bridge | Done |
| 11 | **Context Guardian** | **Done** |

---

## Next Steps

Remaining capabilities from original roadmap:
- Production Feedback Loop (Sentry/logs integration)
- Performance Profiler (bottleneck detection)
- Incident Response Copilot (root cause tracing)

---

## Notes

- This capability addresses one of the most common pain points in Claude Code usage
- Based on extensive community research and best practices
- Designed to be proactive (warnings) not just reactive (emergency)
- Should significantly reduce lost work from context exhaustion

---

*Chronicle entry for Living Documentation system*
