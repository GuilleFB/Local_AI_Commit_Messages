#!/bin/bash

# Instalador rápido de git-commit-ai
# Ejecuta: curl -fsSL <url> | bash

set -e

echo "🤖 Git Commit AI Installer"
echo ""

# Verificar que estamos en Mac
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  This installer is optimized for macOS."
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Verificar/Instalar Ollama
echo "Checking Ollama..."
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollama not found"
    echo ""
    echo "Install it with:"
    echo "  brew install ollama"
    echo "  Or from: https://ollama.ai"
    exit 1
else
    echo "✅ Ollama installed"
fi

# Descargar modelo
echo ""
echo "Downloading model qwen2.5-coder:7b..."
echo "This may take several minutes (4.7GB)."
ollama pull qwen2.5-coder:7b

# Instalar script
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="gcai"

echo ""
echo "Installing script as '$SCRIPT_NAME'..."

# Verificar permisos
if [ ! -w "$INSTALL_DIR" ]; then
    echo "You need administrator permissions."
    sudo cp git-commit-ai.sh "$INSTALL_DIR/$SCRIPT_NAME"
    sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
else
    cp git-commit-ai.sh "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
fi

echo "✅ Installed in: $INSTALL_DIR/$SCRIPT_NAME"

# Configurar variables de entorno
echo ""
read -p "Add configuration to ~/.zshrc? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cat >> ~/.zshrc <<'EOF'

# Git Commit AI
export GIT_COMMIT_AI_MODEL="qwen2.5-coder:7b"
export GIT_COMMIT_AI_STYLE="conventional"
export GIT_COMMIT_AI_TEMP="0.3"
EOF
    echo "✅ Configuration added to ~/.zshrc"
    echo "Run: source ~/.zshrc"
fi

# Finalizar
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Basic usage:"
echo "  cd your-project"
echo "  git add ."
echo "  gcai"
echo ""
echo "See full help:"
echo "  gcai --help"
echo ""
echo "Test:"
echo "  gcai -n -v  # Generate message without committing"
echo ""