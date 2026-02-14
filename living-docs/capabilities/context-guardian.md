# Context Guardian — Session Protection

"Never lose work to context exhaustion. Handoff early, handoff often."

## Context Usage Levels

| Level | Usage | Action |
|-------|-------|--------|
| **Green** | 0-50% | Continue working |
| **Yellow** | 50-70% | Be mindful |
| **Orange** | 70-80% | Run `/context-guardian` now |
| **Red** | 80-90% | Run `/emergency-handoff` immediately |
| **Black** | 90%+ | Session at imminent risk |

## Commands
- `/context-status` — Check context usage and get recommendations
- `/context-guardian` — Create comprehensive handoff (use at 70-80%)
- `/emergency-handoff` — Immediate minimal handoff (use at 90%+)

## How Handoffs Work

**At 70-80% (Proactive)**:
1. Creates `docs/context/WORKING.md` with full session state
2. Updates CLAUDE.md with continuation notes
3. Optionally stashes/commits changes
4. Provides resume prompt for next session

**At 90%+ (Emergency)**:
1. Creates minimal `docs/context/EMERGENCY.md`
2. Stashes git changes
3. End session immediately

## Resuming After Handoff
```
Continue from the previous session. Read docs/context/WORKING.md
for the full state. Start with [NEXT_STEP].
```

## WORKING.md captures:
Original objective, progress summary, modified files, key decisions, problems encountered, next steps, resume prompt.

## Prevention Tips
1. Run `/context-status` every 30-40 messages
2. Use subagents for exploration
3. Use `/clear` between unrelated tasks
4. Keep CLAUDE.md lean
