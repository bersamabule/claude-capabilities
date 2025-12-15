# Setting Up Claude Capabilities on a New Machine

This guide explains how to replicate the three Claude capabilities on another computer.

## The Three Capabilities

| Capability | Purpose |
|------------|---------|
| **Living Documentation** | Persistent context across sessions |
| **Autonomous Lookup and Inform** | App inspection without manual screenshots |
| **Autonomous Test and Check** | Auto-verify code before delivery |

---

## Quick Setup (5 minutes)

### Step 1: Copy the living-docs folder

**Option A: Git clone (recommended)**
```bash
git clone https://github.com/YOUR_USERNAME/claude-capabilities.git C:\Claude_Code_helper
```

**Option B: Manual copy**
Copy the entire `living-docs` folder to `C:\Claude_Code_helper\living-docs\` (or your preferred location).

### Step 2: Run the setup script

**Windows (PowerShell):**
```powershell
cd C:\Claude_Code_helper\living-docs
.\setup-machine.ps1
```

**Mac/Linux:**
```bash
cd ~/Claude_Code_helper/living-docs
chmod +x setup-machine.sh
./setup-machine.sh
```

### Step 3: Verify

1. Start a new Claude Code session
2. Navigate to any project with code files
3. Claude should detect and offer to initialize Living Documentation

---

## What the Setup Script Does

1. **Creates `~/.claude/CLAUDE.md`** - Global instructions Claude always reads
2. **Creates `~/.claude/hooks/check-living-docs.sh`** - Auto-detects new projects
3. **Creates `~/.claude/settings.json`** - Configures SessionStart hook
4. **Installs Chrome DevTools MCP** - Enables browser inspection

---

## Manual Setup (if script fails)

### 1. Create ~/.claude directory
```bash
mkdir -p ~/.claude/hooks
```

### 2. Copy CLAUDE.md
Copy the global CLAUDE.md content from an existing machine to `~/.claude/CLAUDE.md`

### 3. Create settings.json
Create `~/.claude/settings.json`:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$HOME/.claude/hooks/check-living-docs.sh\"",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### 4. Create hook script
Create `~/.claude/hooks/check-living-docs.sh` (copy from existing machine)

### 5. Install MCP server
```bash
claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest
```

---

## Customizing Paths

If you install living-docs to a different location, update these references:

1. In `~/.claude/CLAUDE.md` - Update all paths to living-docs folder
2. In `~/.claude/hooks/check-living-docs.sh` - Update LIVING_DOCS_TEMPLATE variable

---

## Per-Project Initialization

After machine setup, initialize Living Documentation in each project:

```powershell
# Windows
& "C:\Claude_Code_helper\living-docs\init-living-docs.ps1"

# Mac/Linux
bash ~/Claude_Code_helper/living-docs/init-living-docs.sh
```

Or just start working in a project - Claude will offer to initialize automatically.

---

## Troubleshooting

### "Claude doesn't offer to initialize"
- Check that `~/.claude/settings.json` exists and has the hook configured
- Verify the hook script is executable: `chmod +x ~/.claude/hooks/check-living-docs.sh`
- Check hook script path matches your installation location

### "MCP tools not available"
- Run: `claude mcp list` to see configured servers
- Re-add if missing: `claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest`

### "Browser inspection not working"
- Ensure browser is started with debugging: `start-browser-debug.ps1`
- Check port 9222 is not blocked by firewall
- Verify browser is Chromium-based (Chrome, Brave, Edge)

---

## File Locations Summary

| File | Purpose |
|------|---------|
| `~/.claude/CLAUDE.md` | Global Claude instructions |
| `~/.claude/settings.json` | Hook configuration |
| `~/.claude/hooks/check-living-docs.sh` | Project detection script |
| `[living-docs]/init-living-docs.ps1` | Initialize new projects |
| `[living-docs]/start-browser-debug.ps1` | Start browser for inspection |
| `[living-docs]/setup-machine.ps1` | Set up new machine |
