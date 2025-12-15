#!/bin/bash
#
# Set up Living Documentation capabilities on a new machine (Mac/Linux)
#
# This script configures a machine with all three Claude capabilities:
# 1. Living Documentation (persistent context)
# 2. Autonomous Lookup and Inform (app inspection)
# 3. Autonomous Test and Check (code verification)
#
# Usage:
#   ./setup-machine.sh [living-docs-path]
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Determine paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIVING_DOCS_PATH="${1:-$SCRIPT_DIR}"
CLAUDE_CONFIG_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_CONFIG_DIR/hooks"

echo -e "\n${CYAN}========================================"
echo -e "  Claude Capabilities Setup"
echo -e "========================================${NC}\n"

echo -e "${YELLOW}Living Docs location: $LIVING_DOCS_PATH${NC}"
echo -e "${YELLOW}Claude config dir: $CLAUDE_CONFIG_DIR${NC}"

# Step 1: Create directories
echo -e "\n${GREEN}[1/5] Creating directories...${NC}"
mkdir -p "$CLAUDE_CONFIG_DIR"
mkdir -p "$HOOKS_DIR"
echo -e "  ${GRAY}Created: $CLAUDE_CONFIG_DIR${NC}"
echo -e "  ${GRAY}Created: $HOOKS_DIR${NC}"

# Step 2: Create global CLAUDE.md
echo -e "\n${GREEN}[2/5] Creating global CLAUDE.md...${NC}"
cat > "$CLAUDE_CONFIG_DIR/CLAUDE.md" << CLAUDEMD
# Global Claude Configuration

## Living Documentation - Auto-Initialization

**IMPORTANT**: When starting work in ANY new project directory, check if Living Documentation exists. If it doesn't, offer to initialize it.

### Detection Logic
A project has Living Documentation if it contains:
- \`CLAUDE.md\` in the project root

### Auto-Init Behavior
When I detect a new project WITHOUT Living Documentation:

1. **Inform the user**: "I notice this project doesn't have Living Documentation set up yet."
2. **Offer to initialize**: "Would you like me to initialize Living Documentation for persistent context across sessions?"
3. **If yes**: Run the initialization from \`$LIVING_DOCS_PATH\`
4. **If no**: Proceed normally, but remind them they can ask anytime

### Living Documentation Location
\`\`\`
$LIVING_DOCS_PATH
\`\`\`

### Initialization Command
\`\`\`bash
bash "$LIVING_DOCS_PATH/init-living-docs.sh"
\`\`\`

---

## Autonomous Lookup and Inform - App Inspection

**CAPABILITY**: I can autonomously inspect running web applications.

### How to Inspect
1. Run: \`bash "$LIVING_DOCS_PATH/start-browser-debug.sh"\`
2. Use MCP tools: browser_snapshot, browser_take_screenshot, browser_console_messages

---

## Autonomous Test and Check - Code Verification

**CAPABILITY**: I automatically verify code quality before delivering changes.

### Core Principle
**"I don't deliver code until I've verified it works."**

---

## Slash Commands

- \`/status\` - Project status
- \`/chronicle\` - Create session summary
- \`/adr\` - Create architecture decision
- \`/inspect\` - Capture app context
- \`/verify\` - Run verification suite
- \`/test\` - Run tests
CLAUDEMD

echo -e "  ${GRAY}Created: $CLAUDE_CONFIG_DIR/CLAUDE.md${NC}"

# Step 3: Create hook script
echo -e "\n${GREEN}[3/5] Creating session hook...${NC}"
cat > "$HOOKS_DIR/check-living-docs.sh" << 'HOOKSCRIPT'
#!/bin/bash
PROJECT_DIR="$(pwd)"
CLAUDE_MD="$PROJECT_DIR/CLAUDE.md"

is_coding_project() {
    [ -f "$PROJECT_DIR/package.json" ] || \
    [ -f "$PROJECT_DIR/Cargo.toml" ] || \
    [ -f "$PROJECT_DIR/pyproject.toml" ] || \
    [ -f "$PROJECT_DIR/go.mod" ] || \
    [ -f "$PROJECT_DIR/.git/config" ] || \
    [ -d "$PROJECT_DIR/src" ]
}

if [ "$PROJECT_DIR" = "$HOME" ] || [ "$PROJECT_DIR" = "/" ]; then
    exit 0
fi

if [[ "$PROJECT_DIR" == *"living-docs"* ]]; then
    exit 0
fi

if [ -f "$CLAUDE_MD" ]; then
    echo "LIVING_DOCS_STATUS=initialized"
    echo "Living Documentation found."
else
    if is_coding_project; then
        echo "LIVING_DOCS_STATUS=not_initialized"
        echo "This project does not have Living Documentation."
    fi
fi
exit 0
HOOKSCRIPT

chmod +x "$HOOKS_DIR/check-living-docs.sh"
echo -e "  ${GRAY}Created: $HOOKS_DIR/check-living-docs.sh${NC}"

# Step 4: Create/update settings.json
echo -e "\n${GREEN}[4/5] Configuring settings.json...${NC}"
cat > "$CLAUDE_CONFIG_DIR/settings.json" << SETTINGS
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$HOOKS_DIR/check-living-docs.sh\"",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
SETTINGS

echo -e "  ${GRAY}Updated: $CLAUDE_CONFIG_DIR/settings.json${NC}"

# Step 5: Install MCP server
echo -e "\n${GREEN}[5/5] Installing Chrome DevTools MCP...${NC}"
if command -v claude &> /dev/null; then
    claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest 2>/dev/null || \
        echo -e "  ${YELLOW}Note: MCP may already be configured${NC}"
else
    echo -e "  ${YELLOW}Note: 'claude' command not found. Add MCP manually after installing Claude Code.${NC}"
fi

# Summary
echo -e "\n${GREEN}========================================"
echo -e "  Setup Complete!"
echo -e "========================================${NC}"

echo -e "\n${YELLOW}Capabilities installed:${NC}"
echo -e "  1. Living Documentation - Auto-init in new projects"
echo -e "  2. Autonomous Lookup and Inform - App inspection"
echo -e "  3. Autonomous Test and Check - Code verification"

echo -e "\n${YELLOW}To initialize a project:${NC}"
echo -e "  ${CYAN}bash \"$LIVING_DOCS_PATH/init-living-docs.sh\"${NC}"

echo ""
