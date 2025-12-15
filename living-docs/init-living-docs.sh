#!/bin/bash

#######################################
# Living Documentation Initializer
#
# This script bootstraps the Living Documentation system in any project.
# It creates the necessary directory structure and copies template files.
#
# Usage:
#   ./init-living-docs.sh [project_path] [project_name]
#
# Examples:
#   ./init-living-docs.sh
#   ./init-living-docs.sh /path/to/project "My Project"
#######################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Get script directory (template source)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
PROJECT_PATH="${1:-.}"
PROJECT_NAME="${2:-}"

# Resolve project path
PROJECT_PATH="$(cd "$PROJECT_PATH" 2>/dev/null && pwd)" || PROJECT_PATH="$(pwd)"

echo -e "\n${CYAN}========================================"
echo -e "  Living Documentation Initializer"
echo -e "========================================${NC}\n"

echo -e "${YELLOW}Target directory: $PROJECT_PATH${NC}"

# Get project name if not provided
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="$(basename "$PROJECT_PATH")"
    echo -e "${YELLOW}Project name (detected): $PROJECT_NAME${NC}"
fi

TODAY=$(date +%Y-%m-%d)
NOW=$(date +%H:%M)

echo -e "\n${GREEN}Creating directory structure...${NC}"

# Create directories
directories=(
    "docs/adr"
    "docs/chronicle"
    ".claude/commands"
)

for dir in "${directories[@]}"; do
    full_path="$PROJECT_PATH/$dir"
    if [ ! -d "$full_path" ]; then
        mkdir -p "$full_path"
        echo -e "  ${GRAY}Created: $dir${NC}"
    else
        echo -e "  ${GRAY}Exists:  $dir${NC}"
    fi
done

echo -e "\n${GREEN}Copying template files...${NC}"

# Function to copy and customize template
copy_template() {
    local source="$1"
    local dest="$2"
    local dest_path="$PROJECT_PATH/$dest"

    if [ -f "$dest_path" ]; then
        echo -e "  ${YELLOW}Skipped: $dest (already exists)${NC}"
        return 1
    fi

    local source_path="$SCRIPT_DIR/$source"
    if [ -f "$source_path" ]; then
        sed -e "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" \
            -e "s/\[DATE\]/$TODAY/g" \
            "$source_path" > "$dest_path"
        echo -e "  ${GRAY}Created: $dest${NC}"
        return 0
    else
        echo -e "  ${RED}Warning: Template not found: $source${NC}"
        return 1
    fi
}

# Copy main templates
copy_template "CLAUDE.md" "CLAUDE.md"
copy_template "AGENTS.md" "AGENTS.md"
copy_template "docs/adr/README.md" "docs/adr/README.md"
copy_template "docs/adr/0000-template.md" "docs/adr/0000-template.md"
copy_template "docs/chronicle/README.md" "docs/chronicle/README.md"
copy_template "docs/chronicle/0000-template.md" "docs/chronicle/0000-template.md"

# Copy slash commands
for cmd_file in "$SCRIPT_DIR/.claude/commands"/*.md; do
    if [ -f "$cmd_file" ]; then
        cmd_name=$(basename "$cmd_file")
        copy_template ".claude/commands/$cmd_name" ".claude/commands/$cmd_name"
    fi
done

# Create initial chronicle entry
chronicle_path="$PROJECT_PATH/docs/chronicle/$TODAY-project-initialization.md"
if [ ! -f "$chronicle_path" ]; then
    cat > "$chronicle_path" << EOF
# Chronicle: $TODAY - Project Initialization

**Session Duration**: $NOW - ongoing
**Focus Area**: Setup
**Participants**: Claude, User

---

## Objectives

- [x] Initialize Living Documentation system

---

## Summary

Initialized the Living Documentation system for $PROJECT_NAME. This creates the foundation for maintaining persistent context across development sessions.

---

## Work Completed

### Living Documentation Setup
- **Status**: Complete
- **Files Created**:
  - \`CLAUDE.md\` - Main context file for Claude
  - \`AGENTS.md\` - Standardized AI agent guidance
  - \`docs/adr/\` - Architecture Decision Records
  - \`docs/chronicle/\` - Development session logs
  - \`.claude/commands/\` - Slash commands

---

## Next Session

### Priority Tasks
1. Fill in project-specific details in CLAUDE.md
2. Fill in project-specific details in AGENTS.md
3. Begin development work

---

## Context for Future Sessions

> **Where this session ended**: Living Documentation initialized
>
> **State of the code**: Ready for customization
>
> **Don't forget**: Update CLAUDE.md and AGENTS.md with actual project details
EOF
    echo -e "  ${GRAY}Created: docs/chronicle/$TODAY-project-initialization.md${NC}"
fi

# Update .gitignore
gitignore_path="$PROJECT_PATH/.gitignore"
if [ -f "$gitignore_path" ]; then
    if ! grep -q "Living Documentation" "$gitignore_path"; then
        cat >> "$gitignore_path" << 'EOF'

# Living Documentation - Optional ignores
# Uncomment if you want to keep chronicle entries local
# docs/chronicle/*.md
# !docs/chronicle/README.md
# !docs/chronicle/0000-template.md
EOF
        echo -e "\n${GREEN}Updated .gitignore with Living Documentation entries${NC}"
    fi
fi

echo -e "\n${GREEN}========================================"
echo -e "  Living Documentation Initialized!"
echo -e "========================================${NC}"

echo -e "\n${YELLOW}Next steps:${NC}"
echo -e "  1. Edit CLAUDE.md with your project details"
echo -e "  2. Edit AGENTS.md with build commands and conventions"
echo -e "  3. Start creating ADRs for architectural decisions"
echo -e "  4. Create chronicle entries at end of each session"

echo -e "\n${YELLOW}File locations:${NC}"
echo -e "  ${GRAY}CLAUDE.md           - Main context (Claude reads automatically)${NC}"
echo -e "  ${GRAY}AGENTS.md           - AI agent guidance (industry standard)${NC}"
echo -e "  ${GRAY}docs/adr/           - Architecture Decision Records${NC}"
echo -e "  ${GRAY}docs/chronicle/     - Session breadcrumb trail${NC}"
echo -e "  ${GRAY}.claude/commands/   - Custom slash commands${NC}"

echo ""
