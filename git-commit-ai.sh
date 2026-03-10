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

# Límite de líneas del diff para análisis (modelos modernos soportan ~128k tokens)
# ~5000 líneas ≈ 50-100k tokens dependiendo del contenido
MAX_DIFF_LINES="${GIT_COMMIT_AI_MAX_LINES:-5000}"

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
Usage: $(basename "$0") [OPTIONS]

Generate intelligent commit messages using local AI.

OPTIONS:
    -h, --help              Show this help
    -m, --model MODEL       Specify the LLM model (default: qwen2.5-coder:7b)
    -s, --style STYLE       Style: conventional, simple, detailed (default: conventional)
    -e, --edit              Edit the message before committing
    -n, --no-commit         Just generate the message, don't commit
    -c, --clipboard         Copy the message to the clipboard
    -v, --verbose           Verbose mode
    --staged-only           Only consider staged changes
    --install-model         Install the recommended model

ENVIRONMENTAL VARIABLES:
    GIT_COMMIT_AI_MODEL     Default model
    GIT_COMMIT_AI_STYLE     Default style
    GIT_COMMIT_AI_TEMP      Model temperature (0.0-1.0)

EXAMPLES:
    $(basename "$0")                    # Automatically generate and commit
    $(basename "$0") -e                 # Generate and allow editing
    $(basename "$0") -n -c              # Just generate and copy to the clipboard
    $(basename "$0") -m llama3.2:3b     # Use faster model

RECOMMENDED MODELS FOR MAC M-SERIES:
    qwen2.5-coder:7b       - Better quality for code (recommended)
    deepseek-coder:6.7b    - Great for technical commits
    llama3.2:3b            - Faster, lower memory consumption
    codellama:7b           - Solid alternative

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
        log_error "Ollama is not installed."
        echo ""
        echo "To install Ollama on Mac:"
        echo "  brew install ollama"
        echo "  Or download from: https://ollama.ai"
        echo ""
        exit 1
    fi

    # jq es útil pero opcional
    if ! command -v jq &> /dev/null; then
        log_warning "jq is not installed. Recommended for better parsing: brew install jq"
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "You are not in a Git repository."
        exit 1
    fi
}

check_ollama_running() {
    if ! ollama list &> /dev/null; then
        log_warning "Ollama is not running. Attempting to start..."
        # En Mac, Ollama debería iniciarse automáticamente
        sleep 2
        if ! ollama list &> /dev/null; then
            log_error "Unable to connect to Ollama. Launch the Ollama application."
            exit 1
        fi
    fi
}

check_model_available() {
    local model="$1"
    
    if ! ollama list | grep -q "^${model%%:*}"; then
        log_warning "Model '$model' not found locally."
        read -p "Download now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Downloading template $model..."
            ollama pull "$model"
        else
            log_error "Model not available. Aborting."
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
            log_error "There are no staged changes to commit.."
            log_info "Use 'git add' to add files to the staging area."
            exit 1
        fi
    else
        # Intenta primero staged, luego unstaged
        diff_output=$(git diff --staged --no-color)
        
        if [ -z "$diff_output" ]; then
            diff_output=$(git diff --no-color)
            
            if [ -z "$diff_output" ]; then
                log_error "There are no changes to analyze."
                exit 1
            fi
            
            log_warning "Using unstaged changes. Consider doing 'git add' first."
        fi
    fi

    # Limita el tamaño del diff (0 = sin límite)
    if [ "$MAX_DIFF_LINES" -gt 0 ]; then
        local line_count=$(echo "$diff_output" | wc -l | tr -d ' ')
        
        if [ "$line_count" -gt "$MAX_DIFF_LINES" ]; then
            log_warning "Very long diff ($line_count lines). Truncating the $MAX_DIFF_LINES lines."
            diff_output=$(echo "$diff_output" | head -n "$MAX_DIFF_LINES")
            diff_output="$diff_output

[... truncated diff, ${line_count} total lines ...]"
        fi
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
You are an expert in Git and software development. Analyze the following diff and generate a commit message following the Conventional Commits convention. 

STRICT RULES:
1. Format: <type>(<scope>): <description>
2. Valid types: feat, fix, docs, style, refactor, perf, test, chore, ci, build
3. Scope is optional but recommended (name of affected module/file)
4. Description: imperative, lowercase, no period, maximum 50 characters
5. If there are breaking changes, add the line "BREAKING CHANGE:" in the body.
6. Optional body: explain the "what" and "why," not the "how."

EXAMPLES:
- feat(auth): add OAuth2 login support
- fix(api): resolve null pointer in user validation
- refactor(db): optimize query performance
- docs(readme): update installation instructions

Respond ONLY with the commit message, without additional explanations.

DIFF:
\`\`\`diff
$diff
\`\`\`

COMMIT MESSAGE:
EOF
            ;;
        simple)
            cat <<EOF
Generate a simple and clear commit message that describes the changes in the following diff.

RULES:
- A concise line of no more than 72 characters
- Use imperative (add, fix, update, remove)
- No emojis or special formatting
- Straight to the point

DIFF:
\`\`\`diff
$diff
\`\`\`

COMMIT MESSAGE:
EOF
            ;;
        detailed)
            cat <<EOF
Analyze the diff and generate a detailed commit message with a title and body.

FORMAT:
Line 1: Concise title (max. 50 characters)
Line 2: (empty)
Line 3+: Body explaining important changes, motivation, context

DIFF:
\`\`\`diff
$diff
\`\`\`

COMMIT MESSAGE:
EOF
            ;;
        *)
            log_error "Unknown style: $style"
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
        log_info "Generating message with model: $model"
        log_info "Style: $style"
    fi
    
    # Llama a Ollama
    local response
    response=$(ollama run "$model" --temperature "$TEMPERATURE" <<< "$prompt" 2>&1)
    
    if [ $? -ne 0 ]; then
        log_error "Error generating message with Ollama"
        echo "$response" >&2
        exit 1
    fi
    
    # Limpia la respuesta
    # Elimina líneas vacías al inicio/final y bloques de código markdown
    echo "$response" | sed -e 's/^```.*$//' -e '/^$/d' | sed -e :a -e '/^\n*$/d;N;ba'
}

install_recommended_model() {
    log_info "Installing recommended model: qwen2.5-coder:7b"
    log_info "This model is optimized for code and Apple Silicon."
    echo ""
    
    ollama pull qwen2.5-coder:7b
    
    if [ $? -eq 0 ]; then
        log_success "Model installed correctly"
        echo ""
        log_info "Now you can use: $(basename "$0")"
    else
        log_error "Error installing the model"
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

    # Detección automática: si se llama como "gdcopy", activa modo clipboard
    local script_name=$(basename "$0")
    if [[ "$script_name" == "gdcopy" ]]; then
        no_commit=true
        clipboard=true
    fi

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
                log_error "Unknown option: $1"
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
    log_info "Analyzing changes..."
    local diff_content=$(get_diff "$staged_only")
    
    if [ "$verbose" = true ]; then
        log_info "$(get_commit_stats)"
    fi

    # Generar mensaje
    log_info "Generating commit messages with AI..."
    local commit_msg=$(generate_commit_message "$final_model" "$final_style" "$diff_content" "$verbose")

    # Validar que se generó algo
    if [ -z "$commit_msg" ]; then
        log_error "The commit message could not be generated."
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
            log_success "Copied to clipboard"
        else
            log_warning "pbcopy is not available on this system"
        fi
    fi

    # Si solo queremos generar, salimos
    if [ "$no_commit" = true ]; then
        log_info "Message generated. No commit made (--no-commit)"
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
        read -p "Commit with this message? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Commit canceled"
            exit 0
        fi
    fi

    # Hacer commit
    git commit -m "$commit_msg"
    
    if [ $? -eq 0 ]; then
        log_success "Commit successfully completed"
    else
        log_error "Error when committing"
        exit 1
    fi
}

main "$@"