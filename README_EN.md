<p align="center">
  <a href="README.md">🇪🇸 Español</a> •
  <a href="README_FR.md">🇫🇷 Français</a>
</p>

<div align="center">
  <h1>🤖 Git Commit AI</h1>
  <p><b>Intelligent commit message generator using local LLMs, optimized for Mac Apple Silicon.</b></p>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/Powered_by-Ollama-black?logo=ollama&logoColor=white" alt="Ollama">
  <img src="https://img.shields.io/badge/Platform-macOS_Apple_Silicon-lightgrey?logo=apple&logoColor=black" alt="Apple Silicon">
  <img src="https://img.shields.io/badge/Privacy-100%25_Local_(Zero_Cost)-brightgreen" alt="Privacy & Cost">
  <img src="https://img.shields.io/badge/Standard-Conventional_Commits-blue?logo=git&logoColor=white" alt="Conventional Commits">
</p>

## ✨ Features

- 🎯 **Automatic generation** of commits following the Conventional Commits specification.
- 🚀 **Optimized for Apple Silicon** using local models (no API keys, zero network latency).
- 🛡️ **Clean Extraction (REST API):** Immune to corruption by ANSI colors or terminal loading spinners. Guarantees perfect plain text for your clipboard.
- 🎨 **Multiple styles:** `conventional`, `simple`, `detailed`.
- ✏️ **Interactive mode** with pre-commit editing.
- 🔒 **Absolute privacy:** Your code never leaves your machine.

---

## 🔧 Installation

### Option A: Automatic Installation (Recommended)

Run this command in your terminal. It will install Ollama (if you don't have it), download the optimized coding model, and configure the script globally.

```bash
curl -fsSL https://raw.githubusercontent.com/GuilleFB/Local_AI_Commit_Messages/main/install.sh | bash
```

### Option B: Manual Installation

**1. Install Ollama**

```bash
brew install ollama
# Or download from [https://ollama.com](https://ollama.com)
```

**2. Download the recommended model**

```bash
ollama pull qwen2.5-coder:7b
```

**3. Install the script**

```bash
chmod +x git-commit-ai.sh
sudo mv git-commit-ai.sh /usr/local/bin/gcai
```

---

## 🚀 Usage

### Basic

```bash
# 1. Stage your changes
git add .

# 2. Auto-generate and commit
gcai
```

### Advanced Options

```bash
gcai -e                 # Generate and open editor before committing
gcai -n                 # Only generate the message, do not commit
gcai -n -c              # Generate and copy to clipboard as plain text
gcai -m llama3.2:3b     # Use a specific model for this commit
gcai -s simple          # Change the message style
gcai -v                 # Verbose mode (shows diff stats)
gcai --staged-only      # Force analysis of staged files only
```

---

## 📝 Commit Styles

### Conventional (Default)

Strictly follows the Conventional Commits specification.

```
feat(auth): add OAuth2 login support
```

### Simple

A concise, single-line message in the imperative mood.

```
add user authentication with OAuth2
```

### Detailed

Messages with a title and an explanatory body detailing the "why".

```
Add OAuth2 authentication support

- Implements OAuth2 flow for Google and GitHub
- Adds token refresh mechanism
- Includes comprehensive error handling
```

---

## 🎯 Recommended Models

For Mac M-series, ordered by quality vs. speed:

| Model | Size | RAM Req. | Quality | Recommended Use |
| --- | --- | --- | --- | --- |
| `qwen2.5-coder:7b` | 4.7GB | 8GB+ | ⭐⭐⭐⭐⭐ | **Recommended** - Best code reasoning |
| `deepseek-coder:6.7b` | 3.8GB | 8GB+ | ⭐⭐⭐⭐⭐ | Excellent, lightweight alternative |
| `llama3.2:3b` | 2.0GB | 4GB+ | ⭐⭐⭐ | Extremely fast. For older Macs |

---

## ⚙️ Configuration

You can customize the default behavior by adding these variables to your `~/.zshrc` or `~/.bashrc`:

```bash
export GIT_COMMIT_AI_MODEL="qwen2.5-coder:7b"
export GIT_COMMIT_AI_STYLE="conventional"
export GIT_COMMIT_AI_TEMP="0.3"  # Lower = more deterministic
```

---

## 🔍 Troubleshooting

**"Ollama is not running"**
Start the background engine:

```bash
ollama serve
```

**"Clipboard contains visual garbage or weird characters"**
Make sure you are running the latest version of the script (`gcai`), which uses Ollama's REST API (`http://localhost:11434/api/generate`) and macOS's native Python parser to guarantee 100% clean text extraction.

---

## 📊 Comparison with Alternatives

| Feature | Git Commit AI | GitHub Copilot | ChatGPT / Claude API |
| --- | --- | --- | --- |
| **Cost** | ✅ Free ($0) | ❌ $10/month | ❌ Pay-per-use |
| **Privacy** | ✅ 100% Local | ❌ Cloud | ❌ Cloud |
| **Offline** | ✅ Yes | ❌ No | ❌ No |
| **CLI Integration** | ✅ Native | ⚠️ Requires extensions | ❌ Requires custom scripts |

---

## 📄 License

MIT License - Use it and modify it freely.

**Made with ❤️ for developers who demand absolute speed and privacy.**
