#!/bin/bash

# Instalador rápido de git-commit-ai optimizado para ejecución remota

set -e

echo "🤖 Git Commit AI Installer"
echo ""

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  This installer is optimized for macOS."
    # Forzar lectura desde la terminal real, evitando corrupción por pipe
    read -p "Continue anyway? (y/n): " -n 1 -r < /dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Checking Ollama..."
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollama not found. Install it with: brew install ollama"
    exit 1
else
    echo "✅ Ollama installed"
fi

echo ""
echo "Downloading model qwen2.5-coder:7b (This may take several minutes)..."
ollama pull qwen2.5-coder:7b

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="gcai"
SCRIPT_URL="https://raw.githubusercontent.com/GuilleFB/Local_AI_Commit_Messages/main/git-commit-ai.sh"

echo ""
echo "Downloading and installing script as '$SCRIPT_NAME'..."

# Descarga directa en lugar de depender de archivos locales
if [ ! -w "$INSTALL_DIR" ]; then
    echo "Requesting administrator permissions to write to $INSTALL_DIR..."
    sudo curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/$SCRIPT_NAME"
    sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
else
    curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
fi

echo "✅ Installed in: $INSTALL_DIR/$SCRIPT_NAME"

echo ""
# Forzar lectura desde la terminal real
read -p "Add configuration to ~/.zshrc? (y/n): " -n 1 -r < /dev/tty
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cat >> ~/.zshrc <<'EOF'

# Git Commit AI
export GIT_COMMIT_AI_MODEL="qwen2.5-coder:7b"
export GIT_COMMIT_AI_STYLE="conventional"
export GIT_COMMIT_AI_TEMP="0.3"
EOF
    echo "✅ Configuration added to ~/.zshrc (Run: source ~/.zshrc)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"