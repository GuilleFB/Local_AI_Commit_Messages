# 🤖 Git Commit AI

Intelligent commit message generator using local LLM models, optimized for Mac Apple Silicon (M1/M2/M3/M4/M5).

## ✨ Features

- 🎯 **Automatic generation** of commits following Conventional Commits
- 🚀 **Optimized for Apple Silicon** with local models (no API keys)
- 🎨 **Multiple styles**: conventional, simple, detailed
- ✏️ **Interactive mode** with pre-commit editing
- 📋 **Clipboard integration**
- 🔒 **Total privacy**: everything runs locally
- ⚡ **Fast and efficient** with optimized models

## 🔧 Installation

### 1. Install Ollama

```bash
# With Homebrew
brew install ollama

# Or download from https://ollama.ai
```

### 2. Download recommended model

```bash
# Automatically installs the best model
./git-commit-ai.sh --install-model

# Or manually
ollama pull qwen2.5-coder:7b
```

### 3. Install the script

```bash
# Make executable
chmod +x git-commit-ai.sh

# Move to PATH (optional)
sudo mv git-commit-ai.sh /usr/local/bin/gca

# Or create alias in ~/.zshrc or ~/.bashrc
alias gca='~/path/to/git-commit-ai.sh'
```

### 4. Install optional dependencies

```bash
# For better JSON parsing
brew install jq
```

## 🚀 Usage

### Basic

```bash
# Generate and commit automatically
gca

# Or if not installed globally
./git-commit-ai.sh
```

### Advanced options

```bash
# Edit message before committing
gca -e

# Only generate, don't commit
gca -n

# Generate and copy to clipboard
gca -n -c

# Use different model
gca -m llama3.2:3b

# Change style
gca -s simple

# Verbose mode
gca -v

# Staged changes only
gca --staged-only
```

### Typical workflow

```bash
# 1. Make changes to your code
vim src/app.js

# 2. Stage changes
git add src/app.js

# 3. Generate commit with AI
gca

# 4. Confirm or edit
# The script will ask before committing
```

## 📝 Commit Styles

### Conventional (default)

Follows the Conventional Commits specification:

```
feat(auth): add OAuth2 login support

Implements OAuth2 flow with Google and GitHub providers.
Includes token refresh logic and session management.
```

### Simple

Concise one-line messages:

```
add user authentication with OAuth2
```

### Detailed

Messages with title and detailed body:

```
Add OAuth2 authentication support

- Implements OAuth2 flow for Google and GitHub
- Adds token refresh mechanism
- Includes comprehensive error handling
- Updates documentation with new auth flow
```

## 🎯 Recommended Models

For Mac M-series, ordered by quality vs speed:

| Model | Size | Speed | Quality | Recommended use |
|--------|--------|-----------|---------|-----------------|
| `qwen2.5-coder:7b` | 4.7GB | Medium | ⭐⭐⭐⭐⭐ | **Recommended** - Best balance |
| `deepseek-coder:6.7b` | 3.8GB | Medium | ⭐⭐⭐⭐⭐ | Excellent alternative |
| `codellama:7b` | 3.8GB | Medium | ⭐⭐⭐⭐ | Solid for code |
| `llama3.2:3b` | 2.0GB | Fast | ⭐⭐⭐ | For low RAM machines |
| `qwen2.5:7b` | 4.7GB | Medium | ⭐⭐⭐⭐ | General purpose |

### Change default model

```bash
# Environment variable
export GIT_COMMIT_AI_MODEL="deepseek-coder:6.7b"

# Or use flag
gca -m deepseek-coder:6.7b
```

## ⚙️ Configuration

### Environment variables

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Default model
export GIT_COMMIT_AI_MODEL="qwen2.5-coder:7b"

# Default style
export GIT_COMMIT_AI_STYLE="conventional"

# Temperature (0.0-1.0, lower = more deterministic)
export GIT_COMMIT_AI_TEMP="0.3"

# Diff line limit (5000 = recommended max, 0 = no limit)
export GIT_COMMIT_AI_MAX_LINES="5000"
```

## 🎓 Usage Examples

### Feature development

```bash
# After implementing new functionality
git add .
gca -s conventional
# Generates: feat(api): add user pagination endpoint
```

### Bug fixes

```bash
git add src/bug-fix.js
gca
# Generates: fix(validation): resolve null pointer in email check
```

### Refactoring

```bash
git add src/refactored/
gca -s detailed
# Generates detailed message explaining refactoring
```

### Documentation

```bash
git add README.md
gca
# Generates: docs(readme): update installation instructions
```

## 🔍 Troubleshooting

### "Ollama is not running"

```bash
# Start Ollama
ollama serve

# Or open the Ollama app from Applications
```

### "Model not found"

```bash
# Install the model
ollama pull qwen2.5-coder:7b

# Verify installed models
ollama list
```

### "No changes to analyze"

```bash
# Make sure you have staged changes
git status
git add <files>
```

### Low quality messages

```bash
# Try lower temperature (more deterministic)
export GIT_COMMIT_AI_TEMP="0.1"

# Or use a larger model
gca -m qwen2.5-coder:14b
```

## 🚀 Pro Tips

### 1. Useful aliases

```bash
# In ~/.zshrc or ~/.bashrc
alias gcae='gca -e'              # Always edit
alias gcan='gca -n -c'            # Only generate and copy
alias gcaq='gca -m llama3.2:3b'  # Fast version
```

### 2. Git hooks

```bash
# Use as prepare-commit-msg hook
cd your-repo/.git/hooks
ln -s /usr/local/bin/gca prepare-commit-msg
```

### 3. Workflow integration

```bash
# Add changes and generate commit in one step
git add . && gca
```

### 4. Review before push

```bash
# Generate message, review, then push
gca -e && git push
```

## 📊 Comparison with Alternatives

| Feature | git-commit-ai | Copilot | ChatGPT API |
|---------|---------------|---------|-------------|
| Cost | ✅ Free | ❌ $10/month | ❌ $0.002/request |
| Privacy | ✅ 100% local | ❌ Cloud | ❌ Cloud |
| Offline | ✅ Yes | ❌ No | ❌ No |
| Speed | ✅ <2s | ⚠️ 3-5s | ⚠️ 2-4s |
| Customizable | ✅ Total | ❌ Limited | ⚠️ Medium |

## 🤝 Contributing

Improvements are welcome. Areas for enhancement:

- [ ] Support for more commit styles
- [ ] Integration with pre-commit hooks
- [ ] Repository context analysis
- [ ] Multi-language suggestions
- [ ] Model caching

## 📄 License

MIT License - Use freely

## 🙏 Credits

- Powered by [Ollama](https://ollama.ai)
- Models: Qwen, DeepSeek, Meta Llama
- Conventional Commits: [conventionalcommits.org](https://www.conventionalcommits.org/)

---

**Made with ❤️ for developers who value privacy and speed**
