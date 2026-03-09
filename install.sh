#!/bin/bash
set -e # Exit immediately if any command fails

echo "🚀 Starting dotfiles bootstrap..."

# ==============================================================================
# 0. Get User Information
# ==============================================================================
# Ask for the GitHub username right away so the script can run unattended afterward
read -p "👤 Enter your GitHub username: " GITHUB_USERNAME

# Safety check: ensure the username is not empty
if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ Error: GitHub username cannot be empty. Exiting."
    exit 1
fi

# ==============================================================================
# 1. Install Pixi
# ==============================================================================
if ! command -v pixi &> /dev/null; then
    echo "📦 Installing pixi..."
    curl -fsSL https://pixi.sh/install.sh | bash
fi

# Ensure pixi is in the current PATH for the rest of this script
export PATH="$HOME/.pixi/bin:$PATH"

# ==============================================================================
# 2. Install Chezmoi
# ==============================================================================
if ! command -v chezmoi &> /dev/null; then
    echo "🛠️ Installing chezmoi..."
    pixi global install chezmoi
fi

# ==============================================================================
# 3. Pull Dotfiles
# ==============================================================================
echo "📥 Pulling dotfiles from GitHub for user: $GITHUB_USERNAME..."
chezmoi init --apply "$GITHUB_USERNAME"

# ==============================================================================
# 4. Sync Global Tools
# ==============================================================================
echo "🔄 Syncing global tools with pixi..."
pixi global sync

echo "✅ Bootstrap complete! Please restart your shell or run: source ~/.zshrc"