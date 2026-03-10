#!/bin/bash

# git-commit-ai.sh - Generador inteligente de commit messages con LLM local
# Optimizado para Mac Apple Silicon (M1/M2/M3/M4/M5)

set -euo pipefail

# ============================================================================
# CONFIGURACIÓN
# ============================================================================

# Modelo LLM (optimizado para Apple Silicon)
MODEL="${GIT_COMMIT_AI_MODEL:-qwen2.5-coder:7b}"

# Estilos de commit disponibles
COMMIT_STYLE="${GIT_COMMIT_AI_STYLE:-conventional}"  # conventional, simple, detailed

# Límite de líneas del diff para análisis
MAX_DIFF_LINES="${GIT_COMMIT_AI_MAX_LINES:-500}"

# Temperatura del modelo (0.0-1.0, menor = más determinista)
TEMPERATURE="${GIT_COMMIT_AI_TEMP:-0.3}"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

show_usage() {
    cat <<EOF
Uso: $(basename "$0") [OPCIONES]

Genera mensajes de commit inteligentes usando IA local.

OPCIONES:
    -h, --help              Muestra esta ayuda
    -m, --model MODEL       Especifica el modelo LLM (default: qwen2.5-coder:7b)
    -s, --style STYLE       Estilo: conventional, simple, detailed (default: conventional)
    -e, --edit              Edita el mensaje antes de commitear
    -n, --no-commit         Solo genera el mensaje, no hace commit
    -c, --clipboard         Copia el mensaje al portapapeles
    -v, --verbose           Modo verbose
    --staged-only           Solo considera cambios staged
    --install-model         Instala el modelo recomendado

VARIABLES DE ENTORNO:
    GIT_COMMIT_AI_MODEL     Modelo por defecto
    GIT_COMMIT_AI_STYLE     Estilo por defecto
    GIT_COMMIT_AI_TEMP      Temperatura del modelo (0.0-1.0)

EJEMPLOS:
    $(basename "$0")                    # Genera y commitea automáticamente
    $(basename "$0") -e                 # Genera y permite editar
    $(basename "$0") -n -c              # Solo genera y copia al portapapeles
    $(basename "$0") -m llama3.2:3b     # Usa modelo más rápido

MODELOS RECOMENDADOS PARA MAC M-SERIES:
    qwen2.5-coder:7b       - Mejor calidad para código (recomendado)
    deepseek-coder:6.7b    - Excelente para commits técnicos
    llama3.2:3b            - Más rápido, menor consumo de memoria
    codellama:7b           - Alternativa sólida

EOF
}

check_dependencies() {
    local missing_deps=()

    # Git es obligatorio
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi

    # Ollama es obligatorio
    if ! command -v ollama &> /dev/null; then
        log_error "Ollama no está instalado."
        echo ""
        echo "Para instalar Ollama en Mac:"
        echo "  brew install ollama"
        echo "  O descarga desde: https://ollama.ai"
        echo ""
        exit 1
    fi

    # jq es útil pero opcional
    if ! command -v jq &> /dev/null; then
        log_warning "jq no está instalado. Se recomienda para mejor parsing: brew install jq"
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Dependencias faltantes: ${missing_deps[*]}"
        exit 1
    fi
}

check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "No estás en un repositorio Git"
        exit 1
    fi
}

check_ollama_running() {
    if ! ollama list &> /dev/null; then
        log_warning "Ollama no está ejecutándose. Intentando iniciar..."
        # En Mac, Ollama debería iniciarse automáticamente
        sleep 2
        if ! ollama list &> /dev/null; then
            log_error "No se puede conectar con Ollama. Inicia la aplicación Ollama."
            exit 1
        fi
    fi
}

check_model_available() {
    local model="$1"
    
    if ! ollama list | grep -q "^${model%%:*}"; then
        log_warning "Modelo '$model' no encontrado localmente."
        read -p "¿Descargar ahora? (s/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            log_info "Descargando modelo $model..."
            ollama pull "$model"
        else
            log_error "Modelo no disponible. Abortando."
            exit 1
        fi
    fi
}

get_diff() {
    local staged_only="$1"
    local diff_output

    if [ "$staged_only" = true ]; then
        diff_output=$(git diff --staged --no-color)
        
        if [ -z "$diff_output" ]; then
            log_error "No hay cambios staged para commitear."
            log_info "Usa 'git add' para añadir archivos al stage."
            exit 1
        fi
    else
        # Intenta primero staged, luego unstaged
        diff_output=$(git diff --staged --no-color)
        
        if [ -z "$diff_output" ]; then
            diff_output=$(git diff --no-color)
            
            if [ -z "$diff_output" ]; then
                log_error "No hay cambios para analizar."
                exit 1
            fi
            
            log_warning "Usando cambios unstaged. Considera hacer 'git add' primero."
        fi
    fi

    # Limita el tamaño del diff
    local line_count=$(echo "$diff_output" | wc -l | tr -d ' ')
    
    if [ "$line_count" -gt "$MAX_DIFF_LINES" ]; then
        log_warning "Diff muy largo ($line_count líneas). Truncando a $MAX_DIFF_LINES líneas."
        diff_output=$(echo "$diff_output" | head -n "$MAX_DIFF_LINES")
        diff_output="$diff_output

[... diff truncado, ${line_count} líneas totales ...]"
    fi

    echo "$diff_output"
}

get_commit_stats() {
    local files_changed=$(git diff --staged --stat | tail -n 1 | awk '{print $1}' || echo "0")
    local insertions=$(git diff --staged --numstat | awk '{sum+=$1} END {print sum+0}')
    local deletions=$(git diff --staged --numstat | awk '{sum+=$2} END {print sum+0}')
    
    echo "Archivos: $files_changed | +$insertions -$deletions"
}

generate_prompt() {
    local style="$1"
    local diff="$2"
    
    case "$style" in
        conventional)
            cat <<EOF
Eres un experto en Git y desarrollo de software. Analiza el siguiente diff y genera un commit message siguiendo la convención Conventional Commits.

REGLAS ESTRICTAS:
1. Formato: <type>(<scope>): <description>
2. Types válidos: feat, fix, docs, style, refactor, perf, test, chore, ci, build
3. Scope es opcional pero recomendado (nombre del módulo/archivo afectado)
4. Description: imperativo, minúsculas, sin punto final, máximo 50 caracteres
5. Si hay breaking changes, añadir línea "BREAKING CHANGE:" en el body
6. Body opcional: explica el "qué" y "por qué", no el "cómo"

EJEMPLOS:
- feat(auth): add OAuth2 login support
- fix(api): resolve null pointer in user validation
- refactor(db): optimize query performance
- docs(readme): update installation instructions

Responde SOLO con el commit message, sin explicaciones adicionales.

DIFF:
\`\`\`diff
$diff
\`\`\`

COMMIT MESSAGE:
EOF
            ;;
        simple)
            cat <<EOF
Genera un commit message simple y claro que describa los cambios en el siguiente diff.

REGLAS:
- Una línea concisa de máximo 72 caracteres
- Usa imperativo (add, fix, update, remove)
- Sin emojis ni formato especial
- Directo al grano

DIFF:
\`\`\`diff
$diff
\`\`\`

COMMIT MESSAGE:
EOF
            ;;
        detailed)
            cat <<EOF
Analiza el diff y genera un commit message detallado con título y body.

FORMATO:
Línea 1: Título conciso (máx 50 chars)
Línea 2: (vacía)
Línea 3+: Body explicando cambios importantes, motivación, contexto

DIFF:
\`\`\`diff
$diff
\`\`\`

COMMIT MESSAGE:
EOF
            ;;
        *)
            log_error "Estilo desconocido: $style"
            exit 1
            ;;
    esac
}

generate_commit_message() {
    local model="$1"
    local style="$2"
    local diff="$3"
    local verbose="$4"
    
    local prompt=$(generate_prompt "$style" "$diff")
    
    if [ "$verbose" = true ]; then
        log_info "Generando mensaje con modelo: $model"
        log_info "Estilo: $style"
    fi
    
    # Llama a Ollama
    local response
    response=$(ollama run "$model" --temperature "$TEMPERATURE" <<< "$prompt" 2>&1)
    
    if [ $? -ne 0 ]; then
        log_error "Error al generar mensaje con Ollama"
        echo "$response" >&2
        exit 1
    fi
    
    # Limpia la respuesta
    # Elimina líneas vacías al inicio/final y bloques de código markdown
    echo "$response" | sed -e 's/^```.*$//' -e '/^$/d' | sed -e :a -e '/^\n*$/d;N;ba'
}

install_recommended_model() {
    log_info "Instalando modelo recomendado: qwen2.5-coder:7b"
    log_info "Este modelo está optimizado para código y Apple Silicon"
    echo ""
    
    ollama pull qwen2.5-coder:7b
    
    if [ $? -eq 0 ]; then
        log_success "Modelo instalado correctamente"
        echo ""
        log_info "Ahora puedes usar: $(basename "$0")"
    else
        log_error "Error al instalar el modelo"
        exit 1
    fi
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    local edit=false
    local no_commit=false
    local clipboard=false
    local verbose=false
    local staged_only=false
    local custom_model=""
    local custom_style=""

    # Parse argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -m|--model)
                custom_model="$2"
                shift 2
                ;;
            -s|--style)
                custom_style="$2"
                shift 2
                ;;
            -e|--edit)
                edit=true
                shift
                ;;
            -n|--no-commit)
                no_commit=true
                shift
                ;;
            -c|--clipboard)
                clipboard=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --staged-only)
                staged_only=true
                shift
                ;;
            --install-model)
                install_recommended_model
                exit 0
                ;;
            *)
                log_error "Opción desconocida: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Usar valores custom o defaults
    local final_model="${custom_model:-$MODEL}"
    local final_style="${custom_style:-$COMMIT_STYLE}"

    # Verificaciones
    check_dependencies
    check_git_repo
    check_ollama_running
    check_model_available "$final_model"

    # Obtener diff
    log_info "Analizando cambios..."
    local diff_content=$(get_diff "$staged_only")
    
    if [ "$verbose" = true ]; then
        log_info "$(get_commit_stats)"
    fi

    # Generar mensaje
    log_info "Generando commit message con IA..."
    local commit_msg=$(generate_commit_message "$final_model" "$final_style" "$diff_content" "$verbose")

    # Validar que se generó algo
    if [ -z "$commit_msg" ]; then
        log_error "No se pudo generar el commit message"
        exit 1
    fi

    # Mostrar resultado
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}COMMIT MESSAGE GENERADO:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$commit_msg"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Copiar al portapapeles si se solicita
    if [ "$clipboard" = true ]; then
        if command -v pbcopy &> /dev/null; then
            echo "$commit_msg" | pbcopy
            log_success "Copiado al portapapeles"
        else
            log_warning "pbcopy no disponible en este sistema"
        fi
    fi

    # Si solo queremos generar, salimos
    if [ "$no_commit" = true ]; then
        log_info "Mensaje generado. No se hizo commit (--no-commit)"
        exit 0
    fi

    # Editar si se solicita
    if [ "$edit" = true ]; then
        local temp_file=$(mktemp)
        echo "$commit_msg" > "$temp_file"
        
        ${EDITOR:-vim} "$temp_file"
        commit_msg=$(cat "$temp_file")
        rm "$temp_file"
    fi

    # Confirmar commit
    if [ "$edit" = false ]; then
        read -p "¿Hacer commit con este mensaje? (s/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            log_info "Commit cancelado"
            exit 0
        fi
    fi

    # Hacer commit
    git commit -m "$commit_msg"
    
    if [ $? -eq 0 ]; then
        log_success "Commit realizado exitosamente"
    else
        log_error "Error al hacer commit"
        exit 1
    fi
}

main "$@"