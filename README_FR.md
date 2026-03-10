<p align="center">
  <a href="README.md">🇪🇸 Español</a> •
  <a href="README_EN.md">🇬🇧 English</a>
</p>

<div align="center">
  <h1>🤖 Git Commit AI</h1>
  <p><b>Générateur intelligent de messages de commit utilisant des LLM locaux, optimisé pour Mac Apple Silicon.</b></p>
</div>

<p align="center">
  <img src="https://img.shields.io/badge/Powered_by-Ollama-black?logo=ollama&logoColor=white" alt="Ollama">
  <img src="https://img.shields.io/badge/Platform-macOS_Apple_Silicon-lightgrey?logo=apple&logoColor=black" alt="Apple Silicon">
  <img src="https://img.shields.io/badge/Privacy-100%25_Local_(Zero_Cost)-brightgreen" alt="Privacy & Cost">
  <img src="https://img.shields.io/badge/Standard-Conventional_Commits-blue?logo=git&logoColor=white" alt="Conventional Commits">
</p>

## ✨ Fonctionnalités

- 🎯 **Génération automatique** de commits suivant la spécification Conventional Commits.
- 🚀 **Optimisé pour Apple Silicon** utilisant des modèles locaux (pas de clés API, zéro latence réseau).
- 🛡️ **Extraction Propre (API REST) :** Immunisé contre la corruption par les couleurs ANSI ou les animations de chargement du terminal. Garantit un texte brut parfait pour votre presse-papiers.
- 🎨 **Styles multiples :** `conventional`, `simple`, `detailed`.
- ✏️ **Mode interactif** avec édition avant le commit (pre-commit).
- 🔒 **Confidentialité absolue :** Votre code ne quitte jamais votre machine.

---

## 🔧 Installation

### Option A : Installation Automatique (Recommandée)

Exécutez cette commande dans votre terminal. Elle installera Ollama (si vous ne l'avez pas), téléchargera le modèle optimisé pour le code, et configurera le script globalement.

```bash
curl -fsSL https://raw.githubusercontent.com/GuilleFB/Local_AI_Commit_Messages/main/install.sh | bash
```

### Option B : Installation Manuelle

**1. Installer Ollama**

```bash
brew install ollama
# Ou téléchargez depuis [https://ollama.com](https://ollama.com)
```

**2. Télécharger le modèle recommandé**

```bash
ollama pull qwen2.5-coder:7b
```

**3. Installer le script**

```bash
chmod +x git-commit-ai.sh
sudo mv git-commit-ai.sh /usr/local/bin/gcai
```

---

## 🚀 Utilisation

### Basique

```bash
# 1. Ajouter vos modifications (stage)
git add .

# 2. Générer automatiquement et commiter
gcai
```

### Options Avancées

```bash
gcai -e                 # Générer et ouvrir l'éditeur avant de commiter
gcai -n                 # Générer uniquement le message, ne pas commiter
gcai -n -c              # Générer et copier dans le presse-papiers en texte brut
gcai -m llama3.2:3b     # Utiliser un modèle spécifique pour ce commit
gcai -s simple          # Changer le style du message
gcai -v                 # Mode verbeux (affiche les statistiques du diff)
gcai --staged-only      # Forcer l'analyse uniquement sur les fichiers indexés (staged)
```

---

## 📝 Styles de Commit

### Conventional (Par défaut)

Suit strictement la spécification Conventional Commits.

```
feat(auth): add OAuth2 login support
```

### Simple

Un message concis d'une seule ligne à l'impératif.

```
add user authentication with OAuth2
```

### Detailed (Détaillé)

Messages avec un titre et un corps explicatif détaillant le "pourquoi".

```
Add OAuth2 authentication support

- Implements OAuth2 flow for Google and GitHub
- Adds token refresh mechanism
- Includes comprehensive error handling
```

---

## 🎯 Modèles Recommandés

Pour les Mac série M, classés par qualité vs. vitesse :

| Modèle | Taille | RAM Req. | Qualité | Utilisation recommandée |
| --- | --- | --- | --- | --- |
| `qwen2.5-coder:7b` | 4.7GB | 8GB+ | ⭐⭐⭐⭐⭐ | **Recommandé** - Meilleur raisonnement sur le code |
| `deepseek-coder:6.7b` | 3.8GB | 8GB+ | ⭐⭐⭐⭐⭐ | Excellente alternative légère |
| `llama3.2:3b` | 2.0GB | 4GB+ | ⭐⭐⭐ | Extrêmement rapide. Pour les anciens Macs |

---

## ⚙️ Configuration

Vous pouvez personnaliser le comportement par défaut en ajoutant ces variables à votre `~/.zshrc` ou `~/.bashrc` :

```bash
export GIT_COMMIT_AI_MODEL="qwen2.5-coder:7b"
export GIT_COMMIT_AI_STYLE="conventional"
export GIT_COMMIT_AI_TEMP="0.3"  # Plus bas = plus déterministe
```

---

## 🔍 Dépannage

**"Ollama n'est pas en cours d'exécution"**
Démarrez le moteur en arrière-plan :

```bash
ollama serve
```

**"Le presse-papiers contient des caractères parasites ou étranges"**
Assurez-vous d'exécuter la dernière version du script (`gcai`), qui utilise l'API REST d'Ollama (`http://localhost:11434/api/generate`) et l'analyseur Python natif de macOS pour garantir une extraction de texte propre à 100 %.

---

## 📊 Comparaison avec les alternatives

| Fonctionnalité | Git Commit AI | GitHub Copilot | API ChatGPT / Claude |
| --- | --- | --- | --- |
| **Coût** | ✅ Gratuit ($0) | ❌ $10/mois | ❌ Paiement à l'usage |
| **Confidentialité** | ✅ 100% Local | ❌ Cloud | ❌ Cloud |
| **Hors ligne** | ✅ Oui | ❌ Non | ❌ Non |
| **Intégration CLI** | ✅ Native | ⚠️ Requiert des extensions | ❌ Requiert des scripts personnalisés |

---

## 📄 Licence

Licence MIT - Utilisez-le et modifiez-le librement.

**Fait avec ❤️ pour les développeurs qui exigent une vitesse et une confidentialité absolues.**
