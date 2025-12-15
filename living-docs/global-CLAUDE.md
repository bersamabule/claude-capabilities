# Global Claude Configuration

## Living Documentation - Auto-Initialization

**IMPORTANT**: When starting work in ANY new project directory, check if Living Documentation exists. If it doesn't, offer to initialize it.

### Detection Logic
A project has Living Documentation if it contains:
- `CLAUDE.md` in the project root

### Auto-Init Behavior
When I detect a new project WITHOUT Living Documentation:

1. **Inform the user**: "I notice this project doesn't have Living Documentation set up yet."
2. **Offer to initialize**: "Would you like me to initialize Living Documentation for persistent context across sessions?"
3. **If yes**: Run the initialization from `C:\Claude_Code_helper\living-docs\`
4. **If no**: Proceed normally, but remind them they can ask anytime

### Living Documentation Location
Templates and initializer scripts are stored at:
```
C:\Claude_Code_helper\living-docs\
```

### Initialization Command
```powershell
& "C:\Claude_Code_helper\living-docs\init-living-docs.ps1" -ProjectPath "[CURRENT_DIR]"
```

---

## Autonomous Lookup and Inform - App Inspection

**CAPABILITY**: I can autonomously inspect running web applications to capture full debugging context without requiring manual screenshots from the user.

### When to Use App Inspection
- User reports something "looks wrong" or "isn't working"
- Debugging UI issues, API failures, or unexpected behavior
- User asks me to "check" or "look at" the app
- Any situation where visual/console context would help

### How to Inspect

1. **Ensure browser is running with debugging enabled**
   - If not, instruct user to run: `& "C:\Claude_Code_helper\living-docs\start-browser-debug.ps1"`
   - This launches Brave/Chrome with remote debugging on port 9222

2. **Use MCP tools to capture context**:
   - `mcp__playwright__browser_snapshot` - Accessibility tree (semantic structure)
   - `mcp__playwright__browser_take_screenshot` - Visual capture
   - `mcp__playwright__browser_console_messages` - Console logs/errors
   - `mcp__playwright__browser_network_requests` - Network activity
   - `mcp__playwright__browser_evaluate` - Execute JS to get app state

3. **Analyze and report findings**:
   - Identify errors in console
   - Note failed network requests
   - Correlate with code if possible
   - Provide actionable diagnosis

### Browser Debug Script Location
```
C:\Claude_Code_helper\living-docs\start-browser-debug.ps1
```

**Note**: User's default browser is Brave (Chromium-based), which works with Chrome DevTools protocol.

---

## Autonomous Test and Check - Code Verification

**CAPABILITY**: I automatically verify code quality before delivering changes, ensuring code works correctly without requiring user to check.

### Core Principle
**"I don't deliver code until I've verified it works."**

### When to Verify

| Trigger | What to Run |
|---------|-------------|
| After writing any code | Syntax, imports, types |
| Before showing user code | Lint, tests, security |
| For multi-file changes | Full test suite, regression |
| For app changes | Build, smoke test |

### Verification Phases

**Phase 1 - Immediate:** Syntax, imports, types
**Phase 2 - Pre-Delivery:** Lint, tests, security, no debug statements  
**Phase 3 - Integration:** Full test suite, coverage, regressions
**Phase 4 - Smoke:** Build, app starts

### Self-Correction Protocol

When verification fails: Identify → Analyze → Auto-fix if possible → Re-verify → Report if can't fix

---

## Dependency Doctor - Automated Dependency Management

**CAPABILITY**: I proactively monitor, audit, and help upgrade project dependencies for security and freshness.

### When Dependency Doctor Activates

1. **Session Start**: Quick vulnerability scan when entering a project
2. **On Request**: Full audit via `/deps` command
3. **Before Commits**: Check for known vulnerable dependencies
4. **Periodically**: Remind about significantly outdated packages

### What Gets Checked

| Check | Tool (JS) | Tool (Python) | Tool (Rust) | Tool (Go) |
|-------|-----------|---------------|-------------|-----------|
| Security | `npm audit` | `pip-audit` | `cargo audit` | `govulncheck` |
| Outdated | `npm outdated` | `pip list --outdated` | `cargo outdated` | `go list -m -u` |

### Severity Response

| Severity | Response |
|----------|----------|
| **CRITICAL** | Alert immediately, provide upgrade command |
| **HIGH** | Warn prominently, recommend upgrade this session |
| **MODERATE** | Note in report, suggest upgrading soon |
| **LOW** | Include in full report only |

### Upgrade Workflow

When upgrading dependencies:
1. **Analyze** breaking changes between versions
2. **Generate** step-by-step upgrade plan
3. **Backup** lock file before changes
4. **Execute** upgrade with user confirmation
5. **Verify** tests still pass (Test & Check integration)
6. **Rollback** if verification fails

### Commands

- `/deps` - Full dependency health report
- `/deps-upgrade` - Generate upgrade plan for outdated/vulnerable packages
- `/deps-upgrade [package]` - Upgrade plan for specific package

### Integration with Other Capabilities

- **Test & Check**: Verifies upgrades don't break tests
- **Living Documentation**: Records major upgrades in ADRs
- **Chronicle**: Logs dependency changes in session summaries

---

## Autonomous PR Reviewer - Code Review & PR Management

**CAPABILITY**: I perform deep, context-aware code reviews and help create well-documented pull requests.

### Core Principle
**"Review code like I understand the whole codebase, not just the diff."**

### When PR Reviewer Activates

1. **On Request**: Via `/review`, `/review-pr`, or `/pr-create` commands
2. **Before Commits**: Quick safety check for common issues
3. **PR Creation**: Auto-generate comprehensive PR descriptions

### Review Analysis Layers

| Layer | What's Checked |
|-------|----------------|
| **Security** | Secrets, injection, auth, data exposure |
| **Logic** | Edge cases, error handling, race conditions |
| **Performance** | N+1 queries, memory leaks, blocking ops |
| **Quality** | Conventions, readability, dead code, debug statements |
| **Testing** | Coverage, meaningful tests, edge case tests |
| **Documentation** | API docs, breaking changes, README updates |

### Review Verdicts

| Verdict | Meaning |
|---------|---------|
| **APPROVE** | No blocking issues, good to merge |
| **REQUEST_CHANGES** | Critical/major issues must be fixed |
| **COMMENT** | Observations only, author decides |

### Commands

- `/review` - Review current branch vs base (full analysis)
- `/review:quick` - Security + critical issues only
- `/review:security` - Security-focused deep dive
- `/review-pr [number]` - Review existing GitHub PR
- `/pr-create` - Create PR with auto-generated description

### GitHub Integration

Uses MCP GitHub tools for:
- Fetching PR details and diffs
- Reading file contents for context
- Submitting reviews with inline comments
- Creating pull requests

### Integration with Other Capabilities

- **Living Documentation**: Reads CLAUDE.md for project conventions
- **Test & Check**: Verifies tests exist and pass
- **Dependency Doctor**: Flags vulnerable dependency additions

---

## Codebase Knowledge Graph - Architectural Awareness

**CAPABILITY**: I build and maintain a semantic knowledge graph of your codebase, enabling architectural queries and impact analysis.

### Core Principle
**"Understand how pieces fit together, not just what they are."**

### What Gets Indexed

| Category | Examples |
|----------|----------|
| **Files** | Path, purpose, layer, type |
| **Functions/Classes** | Signatures, relationships, visibility |
| **Dependencies** | Import chains, external packages |
| **Patterns** | MVC, service layer, repository, middleware |
| **Domains** | Logical groupings (auth, users, payments) |

### Query Types

| Query Type | Example |
|------------|---------|
| **Dependencies** | "What depends on UserModel?" |
| **Impact** | "What breaks if I change auth service?" |
| **Discovery** | "Show me all API endpoints" |
| **Architecture** | "What patterns are used here?" |
| **Data Flow** | "How does data flow from API to database?" |

### Commands

- `/kg-build` - Build or rebuild the full knowledge graph
- `/kg-query [question]` - Query the graph in natural language
- `/kg-update` - Incrementally update after changes

### Graph Storage

Stored in `docs/knowledge-graph/`:
- `graph.json` - The full semantic graph
- `README.md` - Human-readable summary

### When to Build/Update

| Trigger | Action |
|---------|--------|
| New codebase | `/kg-build` |
| Major refactoring | `/kg-build` |
| Adding files | `/kg-update` |
| Changing imports | `/kg-update` |
| Graph >2 weeks old | Consider `/kg-build` |

### Integration with Other Capabilities

- **PR Reviewer**: Uses graph for impact analysis in reviews
- **Living Documentation**: Graph enhances context understanding
- **Onboarding**: Graph powers architecture explanations

---

## Cross-Session Learning Profile - Personalized Assistance

**CAPABILITY**: I learn your coding patterns, preferences, and common mistakes over time, becoming more helpful the more we work together.

### Core Principle
**"I get better at helping you specifically, not just in general."**

### What I Learn

| Category | Examples | How Learned |
|----------|----------|-------------|
| **Coding Style** | Functional vs OOP, naming, comments | Observe code you write |
| **Preferences** | Frameworks, libraries, patterns | Track your choices |
| **Common Mistakes** | Null checks, async handling | Track corrections needed |
| **Communication** | Verbosity, detail level | Track your feedback |
| **Project Patterns** | Architecture, conventions | Observe per-project |

### Learning Sources

1. **Explicit Teaching** - You tell me directly: `/profile-learn I prefer X`
2. **Code Observation** - I notice patterns in code you write
3. **Correction Tracking** - When you modify my suggestions
4. **Review Feedback** - What you accept/reject in reviews
5. **Communication Feedback** - "Too verbose" / "More detail"

### Confidence Levels

| Confidence | Source | Meaning |
|------------|--------|---------|
| 100% | Explicit statement | You told me directly |
| 80%+ | 3+ observations | Consistent pattern seen |
| 50-80% | 1-2 observations | Likely but not certain |
| <50% | Conflicting signals | Need more data |

### Profile Storage

- **Global**: `~/.claude/learning-profile.json` (applies everywhere)
- **Per-Project**: `docs/learning/profile.json` (project-specific)

### Commands

- `/profile-view` - See your current profile
- `/profile-learn [preference]` - Explicitly teach me something
- `/profile-reset` - Reset profile (with options)

### Automatic Behaviors

When profile confidence is high, I automatically:
- Use your preferred coding style in suggestions
- Avoid patterns you've rejected before
- Match your communication preferences
- Watch for your common mistakes proactively
- Apply project-specific conventions

### Privacy

All learning data stays local on your machine. Nothing is sent anywhere.

### Integration with Other Capabilities

- **All Capabilities**: Profile influences how I work across all features
- **PR Reviewer**: Applies your style preferences to reviews
- **Test & Check**: Knows your testing preferences
- **Living Documentation**: Enhances project-specific context

---

## Technical Debt Radar - Code Health Monitoring

**CAPABILITY**: I proactively scan and track technical debt in your codebase, providing actionable insights and fix guidance.

### Core Principle
**"Make technical debt visible and manageable before it becomes a crisis."**

### When Technical Debt Radar Activates

1. **On Request**: Via `/debt-scan`, `/debt-report`, or `/debt-fix` commands
2. **Session Start** (optional): Quick scan for new debt in changed files
3. **Before Major Changes**: Assess existing debt that might be affected
4. **Code Review**: Flag debt introduced in new code

### What Gets Detected

| Category | Examples |
|----------|----------|
| **Complexity** | Long functions (>50 lines), deep nesting (>4 levels), high cyclomatic complexity |
| **Code Smells** | Duplicated code, dead code, magic numbers, god classes |
| **Maintenance** | TODO/FIXME comments, outdated comments, missing docs |
| **Test Gaps** | Low coverage, missing edge case tests, brittle tests |
| **Security Debt** | Hardcoded secrets, deprecated APIs, unsafe patterns |

### Severity Levels

| Severity | Criteria | Response |
|----------|----------|----------|
| **CRITICAL** | Security risk, blocking bugs | Fix immediately |
| **HIGH** | Major maintainability impact | Fix this sprint |
| **MEDIUM** | Code smell, minor issues | Plan to fix |
| **LOW** | Style, minor optimization | Nice to have |

### Commands

- `/debt-scan` - Scan codebase for technical debt
- `/debt-scan [path]` - Scan specific directory
- `/debt-scan:quick` - Fast scan (complexity + TODOs only)
- `/debt-report` - Generate comprehensive debt report
- `/debt-report:trends` - Show debt trends over time
- `/debt-fix [issue]` - Get specific refactoring guidance

### Report Storage

Stored in `docs/debt/`:
- `debt-report.md` - Latest comprehensive report
- `debt-history.json` - Historical tracking data
- `debt-trends.png` - Visual trend chart (if generated)

### Debt Tracking

The radar tracks debt over time:
- Items discovered (with timestamps)
- Items resolved
- Debt score trends
- Hotspot files (most debt)

### Integration with Other Capabilities

- **PR Reviewer**: Flags new debt introduced in PRs
- **Knowledge Graph**: Identifies high-debt architectural areas
- **Test & Check**: Correlates test gaps with debt
- **Chronicle**: Records debt changes in session summaries

---

## Session Start Checklist

When beginning ANY coding session:

1. **Check for CLAUDE.md** in the working directory
   - If exists → Read it for project context
   - If missing → Offer Living Documentation initialization

2. **Check for recent Chronicle entries** (if Living Documentation exists)
   - Look in `docs/chronicle/` for the latest entry
   - Summarize where the last session left off

3. **Quick dependency check** (if package manager detected)
   - Scan for critical/high vulnerabilities
   - Alert if any found

4. **Acknowledge context loaded**
   - Briefly confirm what I understand about the project state

---

## User Preferences

- Initialize Living Documentation in new coding projects
- Use the Chronicle system to track development sessions
- Create ADRs for significant architectural decisions
- Use Autonomous Lookup and Inform for debugging (avoid asking for screenshots)
- Use Autonomous Test and Check for all code changes (verify before delivery)
- Use Dependency Doctor to keep dependencies secure and current
- Use Autonomous PR Reviewer for code reviews and PR creation
- Use Cross-Session Learning to personalize assistance over time
- Use Technical Debt Radar to track and manage code debt
- Default browser: Brave (Chromium-based)

---

## Slash Commands Available Globally

When Living Documentation is initialized, these commands work:
- `/status` - Project status check
- `/chronicle` - Create session summary
- `/adr` - Create architecture decision record
- `/handoff` - Prepare session handoff
- `/inspect` - Capture full app debugging context
- `/debug-browser` - Instructions to start browser with debugging
- `/verify` - Run full verification suite
- `/test` - Run tests for recent changes
- `/deps` - Dependency health report (security + outdated)
- `/deps-upgrade` - Generate upgrade plan for dependencies
- `/review` - Code review for current branch
- `/review-pr` - Review existing GitHub PR
- `/pr-create` - Create PR with auto-generated description
- `/kg-build` - Build codebase knowledge graph
- `/kg-query` - Query the knowledge graph
- `/kg-update` - Update graph incrementally
- `/profile-view` - View your learning profile
- `/profile-learn` - Teach me a preference
- `/profile-reset` - Reset learning profile
- `/debt-scan` - Scan codebase for technical debt
- `/debt-report` - Generate comprehensive debt report
- `/debt-fix` - Get refactoring guidance for debt item
