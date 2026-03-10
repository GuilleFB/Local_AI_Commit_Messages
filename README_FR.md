<p align="center">
  <a href="README.md">🇪🇸 Spanish</a> •
  <a href="README_EN.md">🇬🇧 English</a> •
</p>

<div align="center">
  <h1>🤖 Git Commit AI</h1>
  <p><b>Intelligent commit message generator using local LLM models, optimized for Mac Apple Silicon.</b></p>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/Powered_by-Ollama-black?logo=ollama&logoColor=white" alt="Ollama">
  <img src="https://img.shields.io/badge/Platform-macOS_Apple_Silicon-lightgrey?logo=apple&logoColor=black" alt="Apple Silicon">
  <img src="https://img.shields.io/badge/Privacy-100%25_Local_(Zero_Cost)-brightgreen" alt="Privacy & Cost">
  <img src="https://img.shields.io/badge/Standard-Conventional_Commits-blue?logo=git&logoColor=white" alt="Conventional Commits">
</p>

# 🤖 Git Commit AI

Générateur intelligent de messages de commit utilisant des modèles LLM locaux, optimisé pour Mac Apple Silicon (M1/M2/M3/M4/M5).

## ✨ Fonctionnalités

- 🎯 **Génération automatique** de commits suivant Conventional Commits
- 🚀 **Optimisé pour Apple Silicon** avec modèles locaux (sans clés API)
- 🎨 **Plusieurs styles**: conventional, simple, détaillé
- ✏️ **Mode interactif** avec édition pré-commit
- 📋 **Intégration presse-papiers**
- 🔒 **Confidentialité totale**: tout s'exécute localement
- ⚡ **Rapide et efficace** avec modèles optimisés

## 🔧 Installation

## Installation à distance

```bash
curl -fsSL https://raw.githubusercontent.com/GuilleFB/Local_AI_Commit_Messages/main/install.sh | bash
```

### 1. Installer Ollama

```bash
# Avec Homebrew
brew install ollama

# Ou télécharger depuis https://ollama.ai
```

### 2. Télécharger le modèle recommandé

```bash
# Installe automatiquement le meilleur modèle
./git-commit-ai.sh --install-model

# Ou manuellement
ollama pull qwen2.5-coder:7b
```

### 3. Installer le script

```bash
# Rendre exécutable
chmod +x git-commit-ai.sh

# Déplacer vers PATH (optionnel)
sudo mv git-commit-ai.sh /usr/local/bin/gca

# Ou créer un alias dans ~/.zshrc ou ~/.bashrc
alias gca='~/chemin/vers/git-commit-ai.sh'
```

### 4. Installer les dépendances optionnelles

```bash
# Pour un meilleur parsing JSON
brew install jq
```

## 🚀 Utilisation

### Basique

```bash
# Générer et commiter automatiquement
gca

# Ou si non installé globalement
./git-commit-ai.sh
```

### Options avancées

```bash
# Éditer le message avant de commiter
gca -e

# Seulement générer, ne pas commiter
gca -n

# Générer et copier dans le presse-papiers
gca -n -c

# Utiliser un modèle différent
gca -m llama3.2:3b

# Changer de style
gca -s simple

# Mode verbose
gca -v

# Changements staged uniquement
gca --staged-only
```

### Flux de travail typique

```bash
# 1. Faire des modifications dans votre code
vim src/app.js

# 2. Mettre en stage
git add src/app.js

# 3. Générer le commit avec l'IA
gca

# 4. Confirmer ou éditer
# Le script demandera avant de commiter
```

## 📝 Styles de Commit

### Conventional (par défaut)

Suit la spécification Conventional Commits:

```
feat(auth): add OAuth2 login support

Implements OAuth2 flow with Google and GitHub providers.
Includes token refresh logic and session management.
```

### Simple

Messages concis d'une ligne:

```
add user authentication with OAuth2
```

### Détaillé

Messages avec titre et corps détaillé:

```
Add OAuth2 authentication support

- Implements OAuth2 flow for Google and GitHub
- Adds token refresh mechanism
- Includes comprehensive error handling
- Updates documentation with new auth flow
```

## 🎯 Modèles Recommandés

Pour Mac M-series, classés par qualité vs vitesse:

| Modèle | Taille | Vitesse | Qualité | Utilisation recommandée |
|--------|--------|-----------|---------|-----------------|
| `qwen2.5-coder:7b` | 4.7GB | Moyenne | ⭐⭐⭐⭐⭐ | **Recommandé** - Meilleur équilibre |
| `deepseek-coder:6.7b` | 3.8GB | Moyenne | ⭐⭐⭐⭐⭐ | Excellente alternative |
| `codellama:7b` | 3.8GB | Moyenne | ⭐⭐⭐⭐ | Solide pour le code |
| `llama3.2:3b` | 2.0GB | Rapide | ⭐⭐⭐ | Pour machines avec peu de RAM |
| `qwen2.5:7b` | 4.7GB | Moyenne | ⭐⭐⭐⭐ | Usage général |

### Changer le modèle par défaut

```bash
# Variable d'environnement
export GIT_COMMIT_AI_MODEL="deepseek-coder:6.7b"

# Ou utiliser le flag
gca -m deepseek-coder:6.7b
```

## ⚙️ Configuration

### Variables d'environnement

Ajouter à votre `~/.zshrc` ou `~/.bashrc`:

```bash
# Modèle par défaut
export GIT_COMMIT_AI_MODEL="qwen2.5-coder:7b"

# Style par défaut
export GIT_COMMIT_AI_STYLE="conventional"

# Température (0.0-1.0, plus bas = plus déterministe)
export GIT_COMMIT_AI_TEMP="0.3"

# Limite de lignes du diff (5000 = max recommandé, 0 = sans limite)
export GIT_COMMIT_AI_MAX_LINES="5000"
```

## 🎓 Exemples d'Utilisation

### Développement de fonctionnalités

```bash
# Après avoir implémenté une nouvelle fonctionnalité
git add .
gca -s conventional
# Génère: feat(api): add user pagination endpoint
```

### Corrections de bugs

```bash
git add src/bug-fix.js
gca
# Génère: fix(validation): resolve null pointer in email check
```

### Refactoring

```bash
git add src/refactored/
gca -s detailed
# Génère un message détaillé expliquant le refactoring
```

### Documentation

```bash
git add README.md
gca
# Génère: docs(readme): update installation instructions
```

## 🔍 Dépannage

### "Ollama n'est pas en cours d'exécution"

```bash
# Démarrer Ollama
ollama serve

# Ou ouvrir l'application Ollama depuis Applications
```

### "Modèle non trouvé"

```bash
# Installer le modèle
ollama pull qwen2.5-coder:7b

# Vérifier les modèles installés
ollama list
```

### "Aucun changement à analyser"

```bash
# S'assurer d'avoir des changements staged
git status
git add <fichiers>
```

### Messages de faible qualité

```bash
# Essayer une température plus basse (plus déterministe)
export GIT_COMMIT_AI_TEMP="0.1"

# Ou utiliser un modèle plus grand
gca -m qwen2.5-coder:14b
```

## 🚀 Astuces Pro

### 1. Alias utiles

```bash
# Dans ~/.zshrc ou ~/.bashrc
alias gcae='gca -e'              # Toujours éditer
alias gcan='gca -n -c'            # Seulement générer et copier
alias gcaq='gca -m llama3.2:3b'  # Version rapide
```

### 2. Hooks Git

```bash
# Utiliser comme hook prepare-commit-msg
cd votre-repo/.git/hooks
ln -s /usr/local/bin/gca prepare-commit-msg
```

### 3. Intégration du flux de travail

```bash
# Ajouter les changements et générer le commit en une étape
git add . && gca
```

### 4. Révision avant push

```bash
# Générer le message, réviser, puis push
gca -e && git push
```

## 📊 Comparaison avec les Alternatives

| Fonctionnalité | git-commit-ai | Copilot | ChatGPT API |
|---------|---------------|---------|-------------|
| Coût | ✅ Gratuit | ❌ 10$/mois | ❌ 0.002$/requête |
| Confidentialité | ✅ 100% local | ❌ Cloud | ❌ Cloud |
| Hors ligne | ✅ Oui | ❌ Non | ❌ Non |
| Vitesse | ✅ <2s | ⚠️ 3-5s | ⚠️ 2-4s |
| Personnalisable | ✅ Total | ❌ Limité | ⚠️ Moyen |

## 🤝 Contribuer

Les améliorations sont bienvenues. Domaines d'amélioration:

- [ ] Support pour plus de styles de commit
- [ ] Intégration avec les hooks pre-commit
- [ ] Analyse du contexte du dépôt
- [ ] Suggestions multilingues
- [ ] Cache des modèles

## 📄 Licence

Licence MIT - Utilisation libre

## 🙏 Crédits

- Propulsé par [Ollama](https://ollama.ai)
- Modèles: Qwen, DeepSeek, Meta Llama
- Conventional Commits: [conventionalcommits.org](https://www.conventionalcommits.org/)

---

**Fait avec ❤️ pour les développeurs qui valorisent la confidentialité et la vitesse**
