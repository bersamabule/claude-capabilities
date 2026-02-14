# Auto-Continue Orchestrator

Zero-dependency Node.js script that wraps Claude Code CLI with automatic context handoff.

## Problem

Claude Code sessions hit the ~200k token context limit during long tasks. Recovering requires:
1. Notice the limit
2. Run `/context-guardian`
3. Start a new terminal
4. Paste resume prompt
5. Wait for reload

## Solution

This orchestrator automates the entire cycle:
1. Runs Claude in headless mode (`-p`) with chunked execution (`--max-turns`)
2. Monitors token usage after each chunk via JSON output
3. When context hits 75%, triggers Claude to write a handoff file
4. Spawns a fresh session that reads the handoff and continues
5. Repeats until task complete or safety limits hit

## Usage

```bash
# Basic
node index.js "Grade all essays in tzu-chi/grade8-ela/weekly/T3-week4/"

# With options
node index.js "Create slides for G7 Week 8" --turns 20 --threshold 70 --max-cost 15

# With context from a previous handoff
node index.js "Continue grading" --context docs/context/auto-continue/HANDOFF_auto_1_2026-02-14.md

# Via bash alias (after adding to .bashrc)
auto-continue "Analyze all student data and create intervention plans"

# Dry run
node index.js "test task" --dry-run
```

## Options

| Flag | Default | Description |
|------|---------|-------------|
| `--turns N` | 15 | Turns per chunk |
| `--threshold N` | 75 | Token % to trigger handoff |
| `--max-sessions N` | 5 | Max fresh sessions |
| `--max-cost N` | 10.0 | Cost ceiling (USD) |
| `--max-time N` | 120 | Wall-clock limit (minutes) |
| `--model MODEL` | auto | Model to use |
| `--cwd PATH` | C:\Claude-Work | Working directory |
| `--context FILE` | - | Context file for initial prompt |
| `--permission-mode MODE` | acceptEdits | Permission mode |
| `--verbose` | false | Verbose logging |
| `--dry-run` | false | Show config without running |

## Configuration

Edit `config.json` to change defaults. CLI flags override config.json.

## Output

- **Logs**: `logs/run_{timestamp}.jsonl` (machine-readable) + `logs/run_{timestamp}_summary.md` (human-readable)
- **Handoffs**: `{cwd}/docs/context/auto-continue/HANDOFF_auto_{N}_{timestamp}.md`

## Safety Limits

- Max 5 sessions (prevents infinite loops)
- Max $10 spend per run
- Max 120 minutes wall-clock
- Stall detection (2 consecutive chunks with no progress = abort)
- Per-chunk 10-minute timeout

## How It Works

```
┌─────────────────────────────────────────────┐
│              Main Loop                       │
│                                             │
│  ┌─── Safety checks (time/cost/sessions) ──┐│
│  │                                         ││
│  │  Run claude -p --max-turns N            ││
│  │         │                               ││
│  │         ▼                               ││
│  │  Parse JSON result                      ││
│  │         │                               ││
│  │    ┌────┴────┐                          ││
│  │    │         │                          ││
│  │  Complete  Tokens OK?                   ││
│  │  ──► EXIT   │                           ││
│  │         ┌───┴───┐                       ││
│  │         │       │                       ││
│  │      Yes(>75%) No                       ││
│  │         │       │                       ││
│  │     Handoff   Resume                    ││
│  │    new session  same session             ││
│  │         │       │                       ││
│  │         └───┬───┘                       ││
│  │             │                           ││
│  │         Loop back                       ││
│  └─────────────────────────────────────────┘│
└─────────────────────────────────────────────┘
```

## Requirements

- Node.js >= 18
- Claude Code CLI installed and authenticated
- Zero npm dependencies
