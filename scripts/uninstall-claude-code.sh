#!/bin/bash

echo "Completely removing Claude Code..."

# Function to remove safely
safe_remove() {
    if [ -e "$1" ]; then
        echo "Removing: $1"
        rm -rf "$1"
    fi
}

# Stop any running processes
pkill -f claude-code 2>/dev/null

# Remove from npm
npm uninstall -g @anthropic-ai/claude-code 2>/dev/null

# Remove directories
safe_remove "$(npm config get prefix)/lib/node_modules/@anthropic-ai/claude-code"
safe_remove "$(npm config get prefix)/bin/claude-code"
safe_remove "$HOME/.claude-code"
safe_remove "$HOME/.config/claude-code"
safe_remove "$HOME/.cache/claude-code"
safe_remove "$HOME/.local/share/claude-code"

# macOS specific
if [[ "$OSTYPE" == "darwin"* ]]; then
    safe_remove "$HOME/Library/Application Support/claude-code"
    safe_remove "$HOME/Library/Caches/com.anthropic.claude-code"
    safe_remove "$HOME/Library/Preferences/com.anthropic.claude-code.plist"
fi

# Clear npm cache
npm cache clean --force

# Remove from PATH in shell configs
for file in ~/.bashrc ~/.zshrc ~/.profile ~/.bash_profile; do
    if [ -f "$file" ]; then
        sed -i.bak '/claude-code/d' "$file"
    fi
done

echo "Claude Code has been completely removed."
echo "Please restart your terminal for changes to take effect."
