# 🤖 Git Commit AI

Generador inteligente de commit messages usando modelos LLM locales, optimizado para Mac Apple Silicon (M1/M2/M3/M4/M5).

## ✨ Características

- 🎯 **Generación automática** de commits siguiendo Conventional Commits
- 🚀 **Optimizado para Apple Silicon** con modelos locales (sin API keys)
- 🎨 **Múltiples estilos**: conventional, simple, detailed
- ✏️ **Modo interactivo** con edición pre-commit
- 📋 **Integración con portapapeles**
- 🔒 **Privacidad total**: todo se ejecuta localmente
- ⚡ **Rápido y eficiente** con modelos optimizados

## 🔧 Instalación

### 1. Instalar Ollama

```bash
# Con Homebrew
brew install ollama

# O descarga desde https://ollama.ai
```

### 2. Descargar el modelo recomendado

```bash
# Instala automáticamente el mejor modelo
./git-commit-ai.sh --install-model

# O manualmente
ollama pull qwen2.5-coder:7b
```

### 3. Instalar el script

```bash
# Hacer ejecutable
chmod +x git-commit-ai.sh

# Mover a PATH (opcional)
sudo mv git-commit-ai.sh /usr/local/bin/gcai

# O crear alias en ~/.zshrc o ~/.bashrc
alias gcai='~/path/to/git-commit-ai.sh'
```

### 4. Instalar dependencias opcionales

```bash
# Para mejor parsing de JSON
brew install jq
```

## 🚀 Uso

### Básico

```bash
# Genera y commitea automáticamente
gcai

# O si no lo instalaste globalmente
./git-commit-ai.sh
```

### Opciones avanzadas

```bash
# Editar mensaje antes de commitear
gcai -e

# Solo generar, no commitear
gcai -n

# Generar y copiar al portapapeles
gcai -n -c

# Usar modelo diferente
gcai -m llama3.2:3b

# Cambiar estilo
gcai -s simple

# Modo verbose
gcai -v

# Solo cambios staged
gcai --staged-only
```

### Flujo de trabajo típico

```bash
# 1. Hacer cambios en tu código
vim src/app.js

# 2. Añadir al stage
git add src/app.js

# 3. Generar commit con IA
gcai

# 4. Confirmar o editar
# El script preguntará antes de commitear
```

## 📝 Estilos de Commit

### Conventional (default)

Sigue la especificación de Conventional Commits:

```
feat(auth): add OAuth2 login support

Implements OAuth2 flow with Google and GitHub providers.
Includes token refresh logic and session management.
```

### Simple

Mensajes concisos de una línea:

```
add user authentication with OAuth2
```

### Detailed

Mensajes con título y body detallado:

```
Add OAuth2 authentication support

- Implements OAuth2 flow for Google and GitHub
- Adds token refresh mechanism
- Includes comprehensive error handling
- Updates documentation with new auth flow
```

## 🎯 Modelos Recomendados

Para Mac M-series, ordenados por calidad vs velocidad:

| Modelo | Tamaño | Velocidad | Calidad | Uso recomendado |
|--------|--------|-----------|---------|-----------------|
| `qwen2.5-coder:7b` | 4.7GB | Media | ⭐⭐⭐⭐⭐ | **Recomendado** - Mejor balance |
| `deepseek-coder:6.7b` | 3.8GB | Media | ⭐⭐⭐⭐⭐ | Alternativa excelente |
| `codellama:7b` | 3.8GB | Media | ⭐⭐⭐⭐ | Sólido para código |
| `llama3.2:3b` | 2.0GB | Rápida | ⭐⭐⭐ | Para máquinas con poca RAM |
| `qwen2.5:7b` | 4.7GB | Media | ⭐⭐⭐⭐ | General purpose |

### Cambiar modelo por defecto

```bash
# Variable de entorno
export GIT_COMMIT_AI_MODEL="deepseek-coder:6.7b"

# O usar flag
gcai -m deepseek-coder:6.7b
```

## ⚙️ Configuración

### Variables de entorno

Añade a tu `~/.zshrc` o `~/.bashrc`:

```bash
# Modelo por defecto
export GIT_COMMIT_AI_MODEL="qwen2.5-coder:7b"

# Estilo por defecto
export GIT_COMMIT_AI_STYLE="conventional"

# Temperatura (0.0-1.0, menor = más determinista)
export GIT_COMMIT_AI_TEMP="0.3"

# Límite de líneas del diff (5000 = máximo recomendado, 0 = sin límite)
export GIT_COMMIT_AI_MAX_LINES="5000"
```

## 🎓 Ejemplos de Uso

### Desarrollo de features

```bash
# Después de implementar nueva funcionalidad
git add .
gcai -s conventional
# Genera: feat(api): add user pagination endpoint
```

### Bug fixes

```bash
git add src/bug-fix.js
gcai
# Genera: fix(validation): resolve null pointer in email check
```

### Refactoring

```bash
git add src/refactored/
gcai -s detailed
# Genera mensaje detallado explicando la refactorización
```

### Documentación

```bash
git add README.md
gcai
# Genera: docs(readme): update installation instructions
```

## 🔍 Troubleshooting

### "Ollama no está ejecutándose"

```bash
# Inicia Ollama
ollama serve

# O abre la app Ollama desde Aplicaciones
```

### "Modelo no encontrado"

```bash
# Instala el modelo
ollama pull qwen2.5-coder:7b

# Verifica modelos instalados
ollama list
```

### "No hay cambios para analizar"

```bash
# Asegúrate de tener cambios staged
git status
git add <archivos>
```

### Mensajes de baja calidad

```bash
# Prueba con temperatura más baja (más determinista)
export GIT_COMMIT_AI_TEMP="0.1"

# O usa un modelo más grande
gcai -m qwen2.5-coder:14b
```

## 🚀 Tips Pro

### 1. Alias útiles

```bash
# En ~/.zshrc o ~/.bashrc
alias gcae='gcai -e'              # Siempre editar
alias gcan='gcai -n -c'            # Solo generar y copiar
alias gcaq='gcai -m llama3.2:3b'  # Versión rápida
```

### 2. Git hooks

```bash
# Usa como prepare-commit-msg hook
cd tu-repo/.git/hooks
ln -s /usr/local/bin/gcai prepare-commit-msg
```

### 3. Integración con workflow

```bash
# Añade cambios y genera commit en un paso
git add . && gcai
```

### 4. Review antes de push

```bash
# Genera mensaje, revisa, y luego push
gcai -e && git push
```

## 📊 Comparación con Alternativas

| Feature | git-commit-ai | Copilot | ChatGPT API |
|---------|---------------|---------|-------------|
| Costo | ✅ Gratis | ❌ $10/mes | ❌ $0.002/request |
| Privacidad | ✅ 100% local | ❌ Cloud | ❌ Cloud |
| Offline | ✅ Sí | ❌ No | ❌ No |
| Velocidad | ✅ <2s | ⚠️ 3-5s | ⚠️ 2-4s |
| Personalizable | ✅ Total | ❌ Limitado | ⚠️ Medio |

## 🤝 Contribuir

Mejoras sugeridas son bienvenidas. Areas de mejora:

- [ ] Soporte para más estilos de commit
- [ ] Integración con pre-commit hooks
- [ ] Análisis de contexto del repo
- [ ] Sugerencias multi-idioma
- [ ] Cache de modelos

## 📄 Licencia

MIT License - Úsalo libremente

## 🙏 Créditos

- Powered by [Ollama](https://ollama.ai)
- Modelos: Qwen, DeepSeek, Meta Llama
- Convencional Commits: [conventionalcommits.org](https://www.conventionalcommits.org/)

---

**Hecho con ❤️ para desarrolladores que valoran su privacidad y velocidad**
