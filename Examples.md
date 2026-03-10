# 📚 Ejemplos de Git Commit AI

## Escenarios de uso común

### 1. Nueva funcionalidad

```bash
# Cambios:
# + src/auth/oauth.js (nuevo archivo)
# ~ src/config/auth.js (modificado)

$ gcai

# Genera:
feat(auth): add OAuth2 authentication support

Implements OAuth2 flow with Google and GitHub providers
```

### 2. Corrección de bug

```bash
# Cambios:
# ~ src/validators/email.js (fix regex)

$ gcai

# Genera:
fix(validation): resolve email regex edge case

Fixes validation for emails with + character
```

### 3. Refactoring

```bash
# Cambios:
# ~ src/utils/helpers.js (extracted functions)
# + src/utils/date.js (new file)
# + src/utils/string.js (new file)

$ gcai -s detailed

# Genera:
refactor(utils): extract helper functions into modules

Splits monolithic helpers.js into focused modules:
- date.js: Date formatting and parsing utilities
- string.js: String manipulation functions
- Improves testability and maintainability
```

### 4. Documentación

```bash
# Cambios:
# ~ README.md (added API docs)
# ~ docs/api.md (new)

$ gcai

# Genera:
docs: add comprehensive API documentation

Includes endpoint descriptions, request/response examples
```

### 5. Múltiples cambios (release)

```bash
# Cambios:
# ~ package.json (version bump)
# ~ CHANGELOG.md (new entries)
# ~ src/* (various improvements)

$ gcai -s conventional

# Genera:
chore(release): bump version to 2.0.0

- Update dependencies
- Add CHANGELOG entries
- Prepare for production release
```

## Flujos de trabajo

### Workflow 1: Quick commit

```bash
git add .
gcai
# Confirma y listo
```

### Workflow 2: Review y editar

```bash
git add src/
gcai -e
# Edita el mensaje en tu editor
# Guarda y cierra para commitear
```

### Workflow 3: Generar múltiples opciones

```bash
# Genera sin commitear
gcai -n > /tmp/msg1.txt

# Prueba con otro estilo
gcai -n -s simple > /tmp/msg2.txt

# Compara y elige
cat /tmp/msg1.txt /tmp/msg2.txt

# Commit manual con el mejor
git commit -m "$(cat /tmp/msg1.txt)"
```

### Workflow 4: Pre-commit hook automation

```bash
# .git/hooks/prepare-commit-msg
#!/bin/bash
COMMIT_MSG_FILE=$1

# Si el mensaje está vacío, genera uno
if [ ! -s "$COMMIT_MSG_FILE" ]; then
    gcai -n > "$COMMIT_MSG_FILE"
fi
```

## Comparación de estilos

### Mismo diff, diferentes estilos

**Diff:**

```diff
+ function calculateDiscount(price, percentage) {
+   return price * (1 - percentage / 100);
+ }
```

**Conventional:**

```
feat(pricing): add discount calculation function

Implements percentage-based discount logic for products
```

**Simple:**

```
add discount calculation function
```

**Detailed:**

```
Add discount calculation utility function

New function calculateDiscount() provides percentage-based
discount calculations for product pricing.

Usage:
  const finalPrice = calculateDiscount(100, 10); // 90
```

## Tips avanzados

### 1. Commits atómicos con contexto

```bash
# Commit solo archivos relacionados
git add src/auth/*
gcai -s conventional
# feat(auth): add login endpoint

git add src/db/migrations/*
gcai -s conventional
# chore(db): add user table migration
```

### 2. Branch feature commits

```bash
# En una feature branch
git checkout -b feature/payment-gateway

# Varios commits descriptivos
git add src/payment/stripe.js
gcai
# feat(payment): integrate Stripe API

git add src/payment/webhook.js
gcai
# feat(payment): add webhook handling

git add tests/payment.test.js
gcai
# test(payment): add Stripe integration tests
```

### 3. Hotfix workflow

```bash
git checkout -b hotfix/critical-bug
git add src/critical-fix.js
gcai -m llama3.2:3b  # modelo rápido
# fix(core): resolve critical null pointer
git push origin hotfix/critical-bug
```

### 4. Experimental commits

```bash
# Trabajo experimental
git add src/experimental/
gcai -s simple
# experiment with new algorithm

# Si funciona, squash y re-commit con mejor mensaje
git reset --soft HEAD~1
gcai -s conventional
# feat(algorithm): implement improved search algorithm
```

## Personalización por proyecto

### Archivo .git-commit-ai.conf en raíz del proyecto

```bash
# Configuración específica del proyecto
export GIT_COMMIT_AI_MODEL="deepseek-coder:6.7b"
export GIT_COMMIT_AI_STYLE="conventional"
export GIT_COMMIT_AI_TEMP="0.2"
```

### Cargar antes de usar

```bash
source .git-commit-ai.conf
gcai
```

## Troubleshooting por casos de uso

### Mensajes genéricos

```bash
# Problema: "update files"
# Solución: Commits más específicos
git add src/auth.js
gcai  # Mejor contexto

# O usa temperatura más baja
export GIT_COMMIT_AI_TEMP="0.1"
```

### Mensajes muy largos

```bash
# Problema: Body demasiado extenso
# Solución: Usa estilo simple
gcai -s simple
```

### Contexto insuficiente

```bash
# Problema: Diff muy pequeño
# Solución: Agrupa cambios relacionados
git add feature-*.js
gcai -s detailed
```

## Integración con otros tools

### Con git-flow

```bash
git flow feature start payment
# ... cambios ...
git add .
gcai
git flow feature finish payment
```

### Con commitizen

```bash
# Usa gcai en lugar de git-cz
alias gcz='gcai -s conventional'
```

### Con GitHub CLI

```bash
git add .
gcai
git push
gh pr create --fill
```

### Con IDE (VS Code)

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "AI Commit",
      "type": "shell",
      "command": "gcai -e",
      "problemMatcher": []
    }
  ]
}
```
