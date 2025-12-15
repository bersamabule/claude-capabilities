#!/bin/bash
#
# Start Brave or Chrome with remote debugging enabled
#
# Usage:
#   ./start-browser-debug.sh [browser] [port] [url]
#
# Examples:
#   ./start-browser-debug.sh                          # Brave on port 9222, localhost:3000
#   ./start-browser-debug.sh chrome 9222 http://localhost:5173
#

BROWSER="${1:-brave}"
PORT="${2:-9222}"
URL="${3:-http://localhost:3000}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Find browser executable
find_browser() {
    local browser=$1

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS paths
        case $browser in
            brave)
                paths=(
                    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
                    "$HOME/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
                )
                ;;
            chrome)
                paths=(
                    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
                    "$HOME/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
                )
                ;;
        esac
    else
        # Linux paths
        case $browser in
            brave)
                paths=(
                    "/usr/bin/brave-browser"
                    "/usr/bin/brave"
                    "/snap/bin/brave"
                )
                ;;
            chrome)
                paths=(
                    "/usr/bin/google-chrome"
                    "/usr/bin/google-chrome-stable"
                    "/usr/bin/chromium-browser"
                    "/usr/bin/chromium"
                )
                ;;
        esac
    fi

    for path in "${paths[@]}"; do
        if [[ -x "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    return 1
}

# Check if port is already in use
if nc -z localhost $PORT 2>/dev/null; then
    echo -e "${YELLOW}Port $PORT is already in use.${NC}"
    echo -e "${YELLOW}A debugging session may already be running.${NC}"
    echo -e "\n${GREEN}Debug endpoint: http://localhost:$PORT${NC}"

    # Try to get browser info
    if command -v curl &> /dev/null; then
        info=$(curl -s "http://localhost:$PORT/json/version" 2>/dev/null)
        if [[ -n "$info" ]]; then
            browser_name=$(echo "$info" | grep -o '"Browser":"[^"]*"' | cut -d'"' -f4)
            echo -e "${CYAN}Browser: $browser_name${NC}"
        fi
    fi
    exit 0
fi

# Find browser
BROWSER_EXE=$(find_browser $BROWSER)

if [[ -z "$BROWSER_EXE" ]]; then
    echo -e "${RED}ERROR: Could not find $BROWSER browser.${NC}"

    # Try the other browser
    OTHER_BROWSER=$([ "$BROWSER" = "brave" ] && echo "chrome" || echo "brave")
    echo -e "${YELLOW}Trying $OTHER_BROWSER instead...${NC}"

    BROWSER_EXE=$(find_browser $OTHER_BROWSER)
    if [[ -n "$BROWSER_EXE" ]]; then
        BROWSER=$OTHER_BROWSER
        echo -e "${GREEN}Found $OTHER_BROWSER${NC}"
    else
        echo -e "${RED}ERROR: No compatible browser found.${NC}"
        exit 1
    fi
fi

# Create debug profile directory
PROFILE_DIR="/tmp/claude-browser-debug"
mkdir -p "$PROFILE_DIR"

echo -e "\n${CYAN}========================================"
echo -e "  Starting $BROWSER with Debug Port"
echo -e "========================================${NC}\n"

echo -e "${GRAY}Browser: $BROWSER_EXE${NC}"
echo -e "${GRAY}Debug Port: $PORT${NC}"
echo -e "${GRAY}URL: $URL${NC}"
echo -e "${GRAY}Profile: $PROFILE_DIR${NC}"

echo -e "\n${GREEN}Launching browser...${NC}"

# Launch browser
"$BROWSER_EXE" \
    --remote-debugging-port=$PORT \
    --remote-allow-origins=* \
    --user-data-dir="$PROFILE_DIR" \
    "$URL" &

BROWSER_PID=$!

# Wait for debug port
echo -e "${YELLOW}Waiting for debug port...${NC}"
for i in {1..30}; do
    if nc -z localhost $PORT 2>/dev/null; then
        echo -e "\n${GREEN}Browser ready!${NC}"

        if command -v curl &> /dev/null; then
            info=$(curl -s "http://localhost:$PORT/json/version" 2>/dev/null)
            browser_name=$(echo "$info" | grep -o '"Browser":"[^"]*"' | cut -d'"' -f4)
            echo -e "${CYAN}Browser: $browser_name${NC}"
        fi
        break
    fi
    echo -n "."
    sleep 1
done

echo -e "\n${GREEN}========================================"
echo -e "  Browser Debug Mode Active"
echo -e "========================================${NC}"
echo -e "\n${WHITE}Claude can now inspect this browser session.${NC}"
echo -e "${CYAN}Debug endpoint: http://localhost:$PORT${NC}"
echo -e "\n${GRAY}To stop: Close the browser window or press Ctrl+C${NC}"

# Keep script running to show it's active
wait $BROWSER_PID
