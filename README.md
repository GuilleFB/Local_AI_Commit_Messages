<p align="center">
  <a href="README_EN.md">🇬🇧 English</a> •
  <a href="README_FR.md">🇫🇷 Français</a>
</p>

<div align="center">
  <h1>🤖 Git Commit AI</h1>
  <p><b>Generador inteligente de commit messages usando modelos LLM locales, optimizado para Mac Apple Silicon.</b></p>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/Powered_by-Ollama-black?logo=ollama&logoColor=white" alt="Ollama">
  <img src="https://img.shields.io/badge/Platform-macOS_Apple_Silicon-lightgrey?logo=apple&logoColor=black" alt="Apple Silicon">
  <img src="https://img.shields.io/badge/Privacy-100%25_Local_(Zero_Cost)-brightgreen" alt="Privacy & Cost">
  <img src="https://img.shields.io/badge/Standard-Conventional_Commits-blue?logo=git&logoColor=white" alt="Conventional Commits">
</p>

## ✨ Características

- 🎯 **Generación automática** de commits siguiendo la especificación Conventional Commits.
- 🚀 **Optimizado para Apple Silicon** usando modelos locales (sin API keys ni latencia de red).
- 🛡️ **Extracción Limpia (REST API):** Inmune a la corrupción por colores ANSI o spinners de carga de la terminal. Garantiza texto plano perfecto para el portapapeles.
- 🎨 **Múltiples estilos:** `conventional`, `simple`, `detailed`.
- ✏️ **Modo interactivo** con edición pre-commit.
- 🔒 **Privacidad total:** Tu código nunca abandona tu máquina.

---

## 🔧 Instalación

### Opción A: Instalación Automática (Recomendada)

Ejecuta este comando en tu terminal. Instalará Ollama (si no lo tienes), descargará el modelo optimizado para código y configurará el script globalmente.

```bash
curl -fsSL https://raw.githubusercontent.com/GuilleFB/Local_AI_Commit_Messages/main/install.sh | bash
```

### Opción B: Instalación Manual

**1. Instalar Ollama**

```bash
brew install ollama
# O descarga desde [https://ollama.com](https://ollama.com)
```

**2. Descargar el modelo recomendado**

```bash
ollama pull qwen2.5-coder:7b
```

**3. Instalar el script**

```bash
chmod +x git-commit-ai.sh
sudo mv git-commit-ai.sh /usr/local/bin/gcai
```

---

## 🚀 Uso

### Básico

```bash
# 1. Añadir al stage
git add .

# 2. Generar y commitear automáticamente
gcai
```

### Opciones Avanzadas

```bash
gcai -e                 # Generar y abrir el editor antes de commitear
gcai -n                 # Solo generar el mensaje, no hacer commit
gcai -n -c              # Generar y copiar al portapapeles en texto plano
gcai -m llama3.2:3b     # Usar un modelo específico para este commit
gcai -s simple          # Cambiar el estilo del mensaje
gcai -v                 # Modo verbose (muestra estadísticas del diff)
gcai --staged-only      # Forzar análisis solo de archivos en stage
```

---

## 📝 Estilos de Commit

### Conventional (Default)

Sigue la especificación estricta.

```
feat(auth): add OAuth2 login support
```

### Simple

Mensaje conciso de una línea en imperativo.

```
add user authentication with OAuth2
```

### Detailed

Mensajes con título y cuerpo explicativo detallando el "por qué".

```
Add OAuth2 authentication support

- Implements OAuth2 flow for Google and GitHub
- Adds token refresh mechanism
- Includes comprehensive error handling
```

---

## 🎯 Modelos Recomendados

Para Mac M-series, ordenados por calidad vs velocidad:

| Modelo | Tamaño | RAM Req. | Calidad | Uso recomendado |
| --- | --- | --- | --- | --- |
| `qwen2.5-coder:7b` | 4.7GB | 8GB+ | ⭐⭐⭐⭐⭐ | **Recomendado** - Mejor razonamiento de código |
| `deepseek-coder:6.7b` | 3.8GB | 8GB+ | ⭐⭐⭐⭐⭐ | Alternativa excelente y ligera |
| `llama3.2:3b` | 2.0GB | 4GB+ | ⭐⭐⭐ | Extremadamente rápido. Para Macs antiguos |

---

## ⚙️ Configuración

Puedes personalizar el comportamiento por defecto añadiendo estas variables a tu `~/.zshrc` o `~/.bashrc`:

```bash
export GIT_COMMIT_AI_MODEL="qwen2.5-coder:7b"
export GIT_COMMIT_AI_STYLE="conventional"
export GIT_COMMIT_AI_TEMP="0.3"  # Menor = más determinista
```

---

## 🔍 Troubleshooting

**"Ollama no está ejecutándose"**
Inicia el motor en segundo plano:

```bash
ollama serve
```

**Mensajes con basura visual en el portapapeles**
Asegúrate de estar ejecutando la última versión del script (`gcai`), la cual utiliza la API REST de Ollama (`http://localhost:11434/api/generate`) y el parser de Python nativo de macOS para garantizar una extracción de texto 100% limpia.

---

## 📊 Comparación con Alternativas

| Feature | Git Commit AI | GitHub Copilot | ChatGPT / Claude API |
| --- | --- | --- | --- |
| **Costo** | ✅ Gratis ($0) | ❌ $10/mes | ❌ Pago por uso |
| **Privacidad** | ✅ 100% Local | ❌ Nube | ❌ Nube |
| **Offline** | ✅ Sí | ❌ No | ❌ No |
| **Integración CLI** | ✅ Nativa | ⚠️ Requiere extensiones | ❌ Requiere scripts custom |

---

## 📄 Licencia

MIT License - Úsalo y modifícalo libremente.

**Hecho con ❤️ para desarrolladores que exigen velocidad y privacidad absoluta.**
