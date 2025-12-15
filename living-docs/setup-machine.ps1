<#
.SYNOPSIS
    Set up Living Documentation capabilities on a new machine

.DESCRIPTION
    This script configures a machine with all three Claude capabilities:
    1. Living Documentation (persistent context)
    2. Autonomous Lookup and Inform (app inspection)
    3. Autonomous Test and Check (code verification)

    Run this after copying/cloning the living-docs folder to a new machine.

.PARAMETER LivingDocsPath
    Path where living-docs folder is located. Defaults to script location.

.EXAMPLE
    .\setup-machine.ps1
#>

param(
    [string]$LivingDocsPath = ""
)

$ErrorActionPreference = "Stop"

# Determine paths
if (-not $LivingDocsPath) {
    $LivingDocsPath = Split-Path -Parent $MyInvocation.MyCommand.Path
}
$LivingDocsPath = Resolve-Path $LivingDocsPath

$ClaudeConfigDir = Join-Path $env:USERPROFILE ".claude"
$HooksDir = Join-Path $ClaudeConfigDir "hooks"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Claude Capabilities Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Living Docs location: $LivingDocsPath" -ForegroundColor Yellow
Write-Host "Claude config dir: $ClaudeConfigDir" -ForegroundColor Yellow

# Step 1: Create directories
Write-Host "`n[1/5] Creating directories..." -ForegroundColor Green
if (-not (Test-Path $ClaudeConfigDir)) {
    New-Item -ItemType Directory -Path $ClaudeConfigDir -Force | Out-Null
    Write-Host "  Created: $ClaudeConfigDir" -ForegroundColor Gray
}
if (-not (Test-Path $HooksDir)) {
    New-Item -ItemType Directory -Path $HooksDir -Force | Out-Null
    Write-Host "  Created: $HooksDir" -ForegroundColor Gray
}

# Step 2: Create global CLAUDE.md
Write-Host "`n[2/5] Creating global CLAUDE.md..." -ForegroundColor Green
$globalClaudeMd = @"
# Global Claude Configuration

## Living Documentation - Auto-Initialization

**IMPORTANT**: When starting work in ANY new project directory, check if Living Documentation exists. If it doesn't, offer to initialize it.

### Detection Logic
A project has Living Documentation if it contains:
- ``CLAUDE.md`` in the project root

### Auto-Init Behavior
When I detect a new project WITHOUT Living Documentation:

1. **Inform the user**: "I notice this project doesn't have Living Documentation set up yet."
2. **Offer to initialize**: "Would you like me to initialize Living Documentation for persistent context across sessions?"
3. **If yes**: Run the initialization from ``$LivingDocsPath``
4. **If no**: Proceed normally, but remind them they can ask anytime

### Living Documentation Location
Templates and initializer scripts are stored at:
``````
$LivingDocsPath
``````

### Initialization Command
``````powershell
& "$LivingDocsPath\init-living-docs.ps1" -ProjectPath "[CURRENT_DIR]"
``````

---

## Autonomous Lookup and Inform - App Inspection

**CAPABILITY**: I can autonomously inspect running web applications to capture full debugging context without requiring manual screenshots from the user.

### When to Use App Inspection
- User reports something "looks wrong" or "isn't working"
- Debugging UI issues, API failures, or unexpected behavior
- User asks me to "check" or "look at" the app

### How to Inspect

1. **Ensure browser is running with debugging enabled**
   - Run: ``& "$LivingDocsPath\start-browser-debug.ps1"``

2. **Use MCP tools to capture context**:
   - ``mcp__playwright__browser_snapshot`` - Accessibility tree
   - ``mcp__playwright__browser_take_screenshot`` - Visual capture
   - ``mcp__playwright__browser_console_messages`` - Console logs/errors
   - ``mcp__playwright__browser_network_requests`` - Network activity
   - ``mcp__playwright__browser_evaluate`` - Execute JS to get app state

---

## Autonomous Test and Check - Code Verification

**CAPABILITY**: I automatically verify code quality before delivering changes.

### Core Principle
**"I don't deliver code until I've verified it works."**

### Verification Phases

**Phase 1 - Immediate:** Syntax, imports, types
**Phase 2 - Pre-Delivery:** Lint, tests, security, no debug statements
**Phase 3 - Integration:** Full test suite, coverage, regressions
**Phase 4 - Smoke:** Build, app starts

### Self-Correction Protocol
When verification fails: Identify → Analyze → Auto-fix if possible → Re-verify → Report if can't fix

---

## Session Start Checklist

1. Check for CLAUDE.md in working directory
2. If missing, offer Living Documentation initialization
3. If exists, read context and check latest chronicle

---

## User Preferences

- Initialize Living Documentation in new coding projects
- Use Autonomous Lookup and Inform for debugging
- Use Autonomous Test and Check for all code changes
- Default browser: Brave/Chrome (Chromium-based)

---

## Slash Commands

- ``/status`` - Project status check
- ``/chronicle`` - Create session summary
- ``/adr`` - Create architecture decision record
- ``/handoff`` - Prepare session handoff
- ``/inspect`` - Capture full app debugging context
- ``/debug-browser`` - Instructions to start browser with debugging
- ``/verify`` - Run full verification suite
- ``/test`` - Run tests for recent changes
"@

$globalClaudeMdPath = Join-Path $ClaudeConfigDir "CLAUDE.md"
Set-Content -Path $globalClaudeMdPath -Value $globalClaudeMd
Write-Host "  Created: $globalClaudeMdPath" -ForegroundColor Gray

# Step 3: Create hook script
Write-Host "`n[3/5] Creating session hook..." -ForegroundColor Green
$hookScript = @"
#!/bin/bash
#
# Living Documentation Session Start Hook
#

PROJECT_DIR="`$(pwd)"
CLAUDE_MD="`$PROJECT_DIR/CLAUDE.md"
LIVING_DOCS_TEMPLATE="$($LivingDocsPath -replace '\\', '/')"

is_coding_project() {
    [ -f "`$PROJECT_DIR/package.json" ] || \
    [ -f "`$PROJECT_DIR/Cargo.toml" ] || \
    [ -f "`$PROJECT_DIR/pyproject.toml" ] || \
    [ -f "`$PROJECT_DIR/requirements.txt" ] || \
    [ -f "`$PROJECT_DIR/go.mod" ] || \
    [ -f "`$PROJECT_DIR/pom.xml" ] || \
    [ -f "`$PROJECT_DIR/.git/config" ] || \
    [ -d "`$PROJECT_DIR/src" ]
}

if [ "`$PROJECT_DIR" = "`$HOME" ] || [ "`$PROJECT_DIR" = "/" ]; then
    exit 0
fi

if [[ "`$PROJECT_DIR" == *"living-docs"* ]]; then
    exit 0
fi

if [ -f "`$CLAUDE_MD" ]; then
    echo "LIVING_DOCS_STATUS=initialized"
    echo "Living Documentation found. Project context loaded."

    CHRONICLE_DIR="`$PROJECT_DIR/docs/chronicle"
    if [ -d "`$CHRONICLE_DIR" ]; then
        LATEST=`$(ls -t "`$CHRONICLE_DIR"/*.md 2>/dev/null | grep -v "template\|README" | head -1)
        if [ -n "`$LATEST" ]; then
            echo "Latest chronicle: `$(basename "`$LATEST")"
        fi
    fi
else
    if is_coding_project; then
        echo "LIVING_DOCS_STATUS=not_initialized"
        echo "NEW_PROJECT_DETECTED=true"
        echo ""
        echo "This project does not have Living Documentation."
        echo "To initialize: & \"`$LIVING_DOCS_TEMPLATE/init-living-docs.ps1\""
    fi
fi

exit 0
"@

$hookPath = Join-Path $HooksDir "check-living-docs.sh"
Set-Content -Path $hookPath -Value $hookScript -NoNewline
Write-Host "  Created: $hookPath" -ForegroundColor Gray

# Step 4: Create/update settings.json
Write-Host "`n[4/5] Configuring settings.json..." -ForegroundColor Green
$settingsPath = Join-Path $ClaudeConfigDir "settings.json"
$settings = @{
    hooks = @{
        SessionStart = @(
            @{
                hooks = @(
                    @{
                        type = "command"
                        command = "bash `"$($HooksDir -replace '\\', '/')/check-living-docs.sh`""
                        timeout = 30
                    }
                )
            }
        )
    }
}

# If settings.json exists, merge hooks
if (Test-Path $settingsPath) {
    try {
        $existing = Get-Content $settingsPath -Raw | ConvertFrom-Json -AsHashtable
        $existing.hooks = $settings.hooks
        $settings = $existing
    } catch {
        # If parse fails, just use our settings
    }
}

$settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath
Write-Host "  Updated: $settingsPath" -ForegroundColor Gray

# Step 5: Install MCP server
Write-Host "`n[5/5] Installing Chrome DevTools MCP..." -ForegroundColor Green
Write-Host "  Running: claude mcp add chrome-devtools" -ForegroundColor Gray
try {
    $result = & claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  MCP server added successfully" -ForegroundColor Gray
    } else {
        Write-Host "  Note: MCP may already be configured or requires manual setup" -ForegroundColor Yellow
        Write-Host "  Run manually: claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  Note: Could not auto-add MCP server" -ForegroundColor Yellow
    Write-Host "  Run manually: claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest" -ForegroundColor Yellow
}

# Summary
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nCapabilities installed:" -ForegroundColor Yellow
Write-Host "  1. Living Documentation - Auto-init in new projects" -ForegroundColor White
Write-Host "  2. Autonomous Lookup and Inform - App inspection" -ForegroundColor White
Write-Host "  3. Autonomous Test and Check - Code verification" -ForegroundColor White

Write-Host "`nFiles created:" -ForegroundColor Yellow
Write-Host "  $globalClaudeMdPath" -ForegroundColor Gray
Write-Host "  $hookPath" -ForegroundColor Gray
Write-Host "  $settingsPath" -ForegroundColor Gray

Write-Host "`nTo verify setup:" -ForegroundColor Yellow
Write-Host "  1. Start a new Claude Code session" -ForegroundColor White
Write-Host "  2. Navigate to any coding project" -ForegroundColor White
Write-Host "  3. Claude should offer to initialize Living Documentation" -ForegroundColor White

Write-Host "`nTo initialize a project manually:" -ForegroundColor Yellow
Write-Host "  & `"$LivingDocsPath\init-living-docs.ps1`"" -ForegroundColor Cyan

Write-Host ""
