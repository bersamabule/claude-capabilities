# App Inspection — Autonomous Lookup and Inform

I can autonomously inspect running web applications to capture full debugging context.

## When to Use
- User reports something "looks wrong" or "isn't working"
- Debugging UI issues, API failures, or unexpected behavior
- User asks me to "check" or "look at" the app

## How to Inspect

1. **Ensure browser is running with debugging enabled**
   - If not: `& "C:\Claude_Code_helper\living-docs\start-browser-debug.ps1"`
   - Launches Brave/Chrome with remote debugging on port 9222

2. **MCP tools for context capture**:
   - `mcp__playwright__browser_snapshot` — Accessibility tree
   - `mcp__playwright__browser_take_screenshot` — Visual capture
   - `mcp__playwright__browser_console_messages` — Console logs/errors
   - `mcp__playwright__browser_network_requests` — Network activity
   - `mcp__playwright__browser_evaluate` — Execute JS for app state

3. **Analyze and report**: Identify errors, failed requests, correlate with code.
