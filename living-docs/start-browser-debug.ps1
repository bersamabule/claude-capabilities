<#
.SYNOPSIS
    Start Brave or Chrome with remote debugging enabled

.DESCRIPTION
    Launches a Chromium-based browser with remote debugging port open,
    allowing Claude to connect via Playwright MCP for browser automation.

    Two profile modes:
    - Default (separate profile): Safe, isolated, no existing logins
    - Main profile (-UseMainProfile): Uses your real browser profile with
      all saved logins (ManageBac, Google, etc.) — requires closing all
      existing browser windows first

.PARAMETER Browser
    Which browser to launch: 'brave' (default) or 'chrome'

.PARAMETER Port
    Remote debugging port (default: 9222)

.PARAMETER Url
    Initial URL to open (default: about:blank)

.PARAMETER UseMainProfile
    Use your real browser profile instead of a temp one.
    Preserves all logins (ManageBac, Google, etc.)
    IMPORTANT: Close all existing browser windows first!

.PARAMETER Profile
    Use a separate profile for debugging (default: true).
    Ignored if -UseMainProfile is set.

.EXAMPLE
    .\start-browser-debug.ps1
    # Launches with temp profile, good for general debugging

.EXAMPLE
    .\start-browser-debug.ps1 -UseMainProfile -Url "https://tzuchischool.managebac.com/"
    # Launches with your real profile — ManageBac already logged in

.EXAMPLE
    .\start-browser-debug.ps1 -Browser chrome -Url http://localhost:5173
    .\start-browser-debug.ps1 -Port 9223
#>

param(
    [ValidateSet('brave', 'chrome')]
    [string]$Browser = 'brave',
    [int]$Port = 9222,
    [string]$Url = 'about:blank',
    [switch]$UseMainProfile,
    [bool]$Profile = $true
)

$ErrorActionPreference = "Stop"

# Define browser paths
$BrowserPaths = @{
    'brave' = @(
        "${env:ProgramFiles}\BraveSoftware\Brave-Browser\Application\brave.exe",
        "${env:ProgramFiles(x86)}\BraveSoftware\Brave-Browser\Application\brave.exe",
        "${env:LocalAppData}\BraveSoftware\Brave-Browser\Application\brave.exe"
    )
    'chrome' = @(
        "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "${env:LocalAppData}\Google\Chrome\Application\chrome.exe"
    )
}

# Define user data directories for main profile
$MainProfilePaths = @{
    'brave'  = "${env:LocalAppData}\BraveSoftware\Brave-Browser\User Data"
    'chrome' = "${env:LocalAppData}\Google\Chrome\User Data"
}

# Find browser executable
$BrowserExe = $null
foreach ($path in $BrowserPaths[$Browser]) {
    if (Test-Path $path) {
        $BrowserExe = $path
        break
    }
}

if (-not $BrowserExe) {
    Write-Host "ERROR: Could not find $Browser browser." -ForegroundColor Red
    Write-Host "Searched paths:" -ForegroundColor Yellow
    $BrowserPaths[$Browser] | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }

    # Try the other browser
    $OtherBrowser = if ($Browser -eq 'brave') { 'chrome' } else { 'brave' }
    Write-Host "`nTrying $OtherBrowser instead..." -ForegroundColor Yellow

    foreach ($path in $BrowserPaths[$OtherBrowser]) {
        if (Test-Path $path) {
            $BrowserExe = $path
            $Browser = $OtherBrowser
            Write-Host "Found $OtherBrowser at: $BrowserExe" -ForegroundColor Green
            break
        }
    }

    if (-not $BrowserExe) {
        Write-Host "ERROR: No compatible browser found." -ForegroundColor Red
        exit 1
    }
}

# Check if port is already in use
$PortInUse = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
if ($PortInUse) {
    Write-Host "Port $Port is already in use." -ForegroundColor Yellow
    Write-Host "A debugging session may already be running." -ForegroundColor Yellow
    Write-Host "`nClaude can connect at: http://localhost:$Port" -ForegroundColor Green

    # Check if we can get browser info
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$Port/json/version" -TimeoutSec 2
        Write-Host "Browser: $($response.Browser)" -ForegroundColor Cyan
    } catch {
        Write-Host "Could not verify browser connection." -ForegroundColor Yellow
    }
    exit 0
}

# If using main profile, check for running browser instances
if ($UseMainProfile) {
    $BrowserProcess = if ($Browser -eq 'brave') { 'brave' } else { 'chrome' }
    $RunningInstances = Get-Process -Name $BrowserProcess -ErrorAction SilentlyContinue
    if ($RunningInstances) {
        Write-Host "`n  WARNING: $Browser is currently running!" -ForegroundColor Red
        Write-Host "  Using -UseMainProfile requires ALL $Browser windows to be closed first." -ForegroundColor Yellow
        Write-Host "  Running two instances on the same profile can corrupt data.`n" -ForegroundColor Yellow

        $response = Read-Host "  Close all $Browser windows and continue? (y/N)"
        if ($response -ne 'y') {
            Write-Host "  Aborted." -ForegroundColor Gray
            exit 0
        }

        Write-Host "  Closing $Browser..." -ForegroundColor Yellow
        Stop-Process -Name $BrowserProcess -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
}

# Determine profile directory
$ProfileArg = ""
$ProfileLabel = ""
if ($UseMainProfile) {
    $MainProfile = $MainProfilePaths[$Browser]
    if (Test-Path $MainProfile) {
        $ProfileLabel = "MAIN PROFILE ($MainProfile)"
        # No --user-data-dir needed — browser uses default when not specified
        # Actually we DO specify it to be explicit
        $ProfileArg = "--user-data-dir=`"$MainProfile`""
    } else {
        Write-Host "WARNING: Main profile not found at $MainProfile" -ForegroundColor Yellow
        Write-Host "Falling back to temp profile." -ForegroundColor Yellow
        $UseMainProfile = $false
    }
}

if (-not $UseMainProfile -and $Profile) {
    $ProfileDir = "$env:TEMP\claude-browser-debug"
    if (-not (Test-Path $ProfileDir)) {
        New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    }
    $ProfileArg = "--user-data-dir=`"$ProfileDir`""
    $ProfileLabel = "Temp ($ProfileDir)"
}

if (-not $UseMainProfile -and -not $Profile) {
    $ProfileLabel = "Default (system)"
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Starting $Browser with Debug Port" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Browser:  $BrowserExe" -ForegroundColor Gray
Write-Host "Debug:    Port $Port" -ForegroundColor Gray
Write-Host "URL:      $Url" -ForegroundColor Gray
Write-Host "Profile:  $ProfileLabel" -ForegroundColor $(if ($UseMainProfile) { 'Green' } else { 'Gray' })
if ($UseMainProfile) {
    Write-Host "          All your saved logins are available!" -ForegroundColor Green
}

# Build arguments
$Arguments = @(
    "--remote-debugging-port=$Port",
    "--remote-allow-origins=*"
)

if ($ProfileArg) {
    $Arguments += $ProfileArg
}

$Arguments += $Url

Write-Host "`nLaunching browser..." -ForegroundColor Green

# Start browser
Start-Process -FilePath $BrowserExe -ArgumentList $Arguments

# Wait for browser to start
Write-Host "Waiting for debug port to become available..." -ForegroundColor Yellow
$MaxWait = 30
$Waited = 0
while ($Waited -lt $MaxWait) {
    Start-Sleep -Seconds 1
    $Waited++

    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$Port/json/version" -TimeoutSec 1
        Write-Host "`nBrowser ready!" -ForegroundColor Green
        Write-Host "Browser: $($response.Browser)" -ForegroundColor Cyan
        Write-Host "WebSocket: $($response.webSocketDebuggerUrl)" -ForegroundColor Cyan
        break
    } catch {
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
}

if ($Waited -ge $MaxWait) {
    Write-Host "`nWARNING: Browser started but debug port not responding." -ForegroundColor Yellow
    Write-Host "The browser may still work - try connecting anyway." -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Browser Debug Mode Active" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nClaude Playwright MCP can now control this browser." -ForegroundColor White
Write-Host "Debug endpoint: http://localhost:$Port" -ForegroundColor Cyan
if ($UseMainProfile) {
    Write-Host "`nTip: Navigate to ManageBac — you're already logged in!" -ForegroundColor Green
}
Write-Host "`nTo stop: Close the browser window or press Ctrl+C" -ForegroundColor Gray
