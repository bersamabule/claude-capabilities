# Spec-Only Capabilities

These capabilities are DEFINED but NOT YET IMPLEMENTED. They have slash command stubs but no production implementation. Do not activate proactively — only invoke when explicitly requested.

## Knowledge Graph (`/kg-build`, `/kg-query`, `/kg-update`)
Semantic knowledge graph of codebase for architectural queries and impact analysis. Stores in `docs/knowledge-graph/`.

## Cross-Session Learning Profile (`/profile-view`, `/profile-learn`, `/profile-reset`)
Learn coding patterns, preferences, and common mistakes over time. Stores in `~/.claude/learning-profile.json`.

## Technical Debt Radar (`/debt-scan`, `/debt-report`, `/debt-fix`)
Scan and track technical debt (complexity, code smells, test gaps, security debt). Stores in `docs/debt/`.

## Intelligent Onboarding (`/onboard`, `/tour`, `/explain`)
Auto-generate onboarding documentation, code tours, and deep explanations. Stores in `docs/onboarding/`.

## Spec-to-Implementation Bridge (`/spec-scan`, `/spec-drift`, `/spec-generate`, `/spec-validate`)
Detect, validate, and track API specifications (OpenAPI, GraphQL, Prisma). Stores in `docs/specs/`.
