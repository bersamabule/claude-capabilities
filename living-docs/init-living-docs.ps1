<#
.SYNOPSIS
    Initialize Living Documentation in a project

.DESCRIPTION
    Bootstraps the Living Documentation system with five capabilities:
    1. Living Documentation (persistent context)
    2. Autonomous Lookup and Inform (app inspection)
    3. Autonomous Test and Check (code verification)
    4. Dependency Doctor (dependency management)
    5. Autonomous PR Reviewer (code review & PR creation)

.PARAMETER ProjectPath
    Path to initialize. Defaults to current directory.

.PARAMETER ProjectName
    Project name (auto-detected from folder if not specified)

.EXAMPLE
    .\init-living-docs.ps1
    .\init-living-docs.ps1 -ProjectPath "C:\MyProject"
#>

param(
    [string]$ProjectPath = ".",
    [string]$ProjectName = ""
)

$ErrorActionPreference = "Stop"

$ProjectPath = Resolve-Path $ProjectPath -ErrorAction SilentlyContinue
if (-not $ProjectPath) { $ProjectPath = $PWD }

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Living Documentation Initializer" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Target: $ProjectPath" -ForegroundColor Yellow

if (-not $ProjectName) {
    $ProjectName = Split-Path $ProjectPath -Leaf
    Write-Host "Project: $ProjectName" -ForegroundColor Yellow
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateDir = $ScriptDir

Write-Host "`nCreating directories..." -ForegroundColor Green

$directories = @(
    "docs/adr",
    "docs/chronicle",
    "docs/inspect",
    "docs/inspect/screenshots",
    "docs/testing",
    "docs/dependencies",
    ".claude/commands"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path $ProjectPath $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Gray
    }
}

Write-Host "`nCopying templates..." -ForegroundColor Green

function Copy-Template {
    param([string]$Source, [string]$Destination, [string]$Name)
    $destPath = Join-Path $ProjectPath $Destination
    if (Test-Path $destPath) { return }
    $sourcePath = Join-Path $TemplateDir $Source
    if (Test-Path $sourcePath) {
        $content = Get-Content $sourcePath -Raw
        $content = $content -replace '\[PROJECT_NAME\]', $Name
        $content = $content -replace '\[DATE\]', (Get-Date -Format "yyyy-MM-dd")
        Set-Content -Path $destPath -Value $content -NoNewline
        Write-Host "  Created: $Destination" -ForegroundColor Gray
    }
}

# Copy templates
Copy-Template "CLAUDE.md" "CLAUDE.md" $ProjectName
Copy-Template "AGENTS.md" "AGENTS.md" $ProjectName
Copy-Template "docs/adr/README.md" "docs/adr/README.md" $ProjectName
Copy-Template "docs/adr/0000-template.md" "docs/adr/0000-template.md" $ProjectName
Copy-Template "docs/chronicle/README.md" "docs/chronicle/README.md" $ProjectName
Copy-Template "docs/chronicle/0000-template.md" "docs/chronicle/0000-template.md" $ProjectName
Copy-Template "docs/inspect/README.md" "docs/inspect/README.md" $ProjectName
Copy-Template "docs/testing/README.md" "docs/testing/README.md" $ProjectName
Copy-Template "docs/testing/test-config.json" "docs/testing/test-config.json" $ProjectName
Copy-Template "docs/testing/verification-checklist.md" "docs/testing/verification-checklist.md" $ProjectName
Copy-Template "docs/dependencies/README.md" "docs/dependencies/README.md" $ProjectName
Copy-Template "docs/dependencies/config.json" "docs/dependencies/config.json" $ProjectName

# Copy slash commands
$commandsSource = Join-Path $TemplateDir ".claude/commands"
if (Test-Path $commandsSource) {
    Get-ChildItem $commandsSource -Filter "*.md" | ForEach-Object {
        Copy-Template ".claude/commands/$($_.Name)" ".claude/commands/$($_.Name)" $ProjectName
    }
}

# Create initial chronicle
$today = Get-Date -Format "yyyy-MM-dd"
$chronicleEntry = @"
# Chronicle: $today - Project Initialization

**Focus**: Setup
**Participants**: Claude, User

---

## Summary

Initialized Living Documentation for $ProjectName with all five capabilities:
1. Living Documentation (persistent context)
2. Autonomous Lookup and Inform (app inspection)
3. Autonomous Test and Check (code verification)
4. Dependency Doctor (dependency management)
5. Autonomous PR Reviewer (code review & PR creation)

## Files Created

- CLAUDE.md - Main context file
- AGENTS.md - AI agent guidance
- docs/adr/ - Architecture decisions
- docs/chronicle/ - Session logs
- docs/inspect/ - Inspection reports
- docs/testing/ - Test configuration
- docs/dependencies/ - Dependency management
- .claude/commands/ - Slash commands

## Next Session

1. Fill in CLAUDE.md with project details
2. Fill in AGENTS.md with build/test commands
3. Run /deps to check dependency health
4. Begin development

## Context

> **Capabilities Active**: All four capabilities ready
> **Run /deps**: Check for vulnerable dependencies
> **Run /verify**: Verify code before delivery
"@

$chroniclePath = Join-Path $ProjectPath "docs/chronicle/$today-project-initialization.md"
if (-not (Test-Path $chroniclePath)) {
    Set-Content -Path $chroniclePath -Value $chronicleEntry
    Write-Host "  Created: docs/chronicle/$today-project-initialization.md" -ForegroundColor Gray
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Living Documentation Initialized!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nCapabilities:" -ForegroundColor Yellow
Write-Host "  1. Living Documentation - Persistent context across sessions" -ForegroundColor White
Write-Host "  2. Autonomous Lookup and Inform - App inspection" -ForegroundColor White
Write-Host "  3. Autonomous Test and Check - Code verification" -ForegroundColor White
Write-Host "  4. Dependency Doctor - Security & freshness monitoring" -ForegroundColor White
Write-Host "  5. Autonomous PR Reviewer - Code review & PR creation" -ForegroundColor White

Write-Host "`nSlash Commands:" -ForegroundColor Yellow
Write-Host "  /status       - Project status" -ForegroundColor Gray
Write-Host "  /chronicle    - Create session entry" -ForegroundColor Gray
Write-Host "  /adr          - Create architecture decision" -ForegroundColor Gray
Write-Host "  /inspect      - Capture app state" -ForegroundColor Gray
Write-Host "  /verify       - Run verification suite" -ForegroundColor Gray
Write-Host "  /test         - Run tests" -ForegroundColor Gray
Write-Host "  /deps         - Dependency health report" -ForegroundColor Gray
Write-Host "  /deps-upgrade - Dependency upgrade plan" -ForegroundColor Gray
Write-Host "  /review       - Code review for current branch" -ForegroundColor Gray
Write-Host "  /review-pr    - Review existing GitHub PR" -ForegroundColor Gray
Write-Host "  /pr-create    - Create PR with auto-description" -ForegroundColor Gray

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  1. Edit CLAUDE.md with project details" -ForegroundColor White
Write-Host "  2. Edit AGENTS.md with build/test commands" -ForegroundColor White
Write-Host "  3. Run /deps to check dependency health" -ForegroundColor White

Write-Host ""
