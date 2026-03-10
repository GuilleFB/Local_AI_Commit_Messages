#!/bin/bash

# Instalador rápido de git-commit-ai
# Ejecuta: curl -fsSL <url> | bash

set -e

echo "🤖 Instalador de Git Commit AI"
echo ""

# Verificar que estamos en Mac
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "⚠️  Este instalador está optimizado para macOS"
    read -p "¿Continuar de todos modos? (s/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        exit 1
    fi
fi

# Verificar/Instalar Ollama
echo "Verificando Ollama..."
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollama no encontrado"
    echo ""
    echo "Instálalo con:"
    echo "  brew install ollama"
    echo "  O desde: https://ollama.ai"
    exit 1
else
    echo "✅ Ollama instalado"
fi

# Descargar modelo
echo ""
echo "Descargando modelo qwen2.5-coder:7b..."
echo "Esto puede tardar varios minutos (4.7GB)"
ollama pull qwen2.5-coder:7b

# Instalar script
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="gcai"

echo ""
echo "Instalando script como '$SCRIPT_NAME'..."

# Verificar permisos
if [ ! -w "$INSTALL_DIR" ]; then
    echo "Necesitas permisos de administrador"
    sudo cp git-commit-ai.sh "$INSTALL_DIR/$SCRIPT_NAME"
    sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
else
    cp git-commit-ai.sh "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
fi

echo "✅ Instalado en: $INSTALL_DIR/$SCRIPT_NAME"

# Configurar variables de entorno
echo ""
read -p "¿Añadir configuración a ~/.zshrc? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    cat >> ~/.zshrc <<'EOF'

# Git Commit AI
export GIT_COMMIT_AI_MODEL="qwen2.5-coder:7b"
export GIT_COMMIT_AI_STYLE="conventional"
export GIT_COMMIT_AI_TEMP="0.3"
EOF
    echo "✅ Configuración añadida a ~/.zshrc"
    echo "Ejecuta: source ~/.zshrc"
fi

# Finalizar
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 ¡Instalación completada!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Uso básico:"
echo "  cd tu-proyecto"
echo "  git add ."
echo "  gcai"
echo ""
echo "Ver ayuda completa:"
echo "  gcai --help"
echo ""
echo "Probar:"
echo "  gcai -n -v  # Genera mensaje sin commitear"
echo ""