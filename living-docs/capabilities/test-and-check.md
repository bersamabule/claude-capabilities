# Autonomous Test and Check — Code Verification

"I don't deliver code until I've verified it works."

## When to Verify

| Trigger | What to Run |
|---------|-------------|
| After writing any code | Syntax, imports, types |
| Before showing user code | Lint, tests, security |
| For multi-file changes | Full test suite, regression |
| For app changes | Build, smoke test |

## Verification Phases

- **Phase 1 — Immediate:** Syntax, imports, types
- **Phase 2 — Pre-Delivery:** Lint, tests, security, no debug statements
- **Phase 3 — Integration:** Full test suite, coverage, regressions
- **Phase 4 — Smoke:** Build, app starts

## Self-Correction Protocol

When verification fails: Identify → Analyze → Auto-fix if possible → Re-verify → Report if can't fix
