#!/bin/bash

# git-commit-ai.sh - Generador inteligente de commit messages con LLM local
# Optimizado para Mac Apple Silicon y terminales con caracteres de escape ANSI

set -euo pipefail

# ============================================================================
# CONFIGURACIÓN
# ============================================================================

MODEL="${GIT_COMMIT_AI_MODEL:-qwen2.5-coder:7b}"
COMMIT_STYLE="${GIT_COMMIT_AI_STYLE:-conventional}" 
MAX_DIFF_LINES="${GIT_COMMIT_AI_MAX_LINES:-5000}"
TEMPERATURE="${GIT_COMMIT_AI_TEMP:-0.3}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# FUNCIONES AUXILIARES
# IMPORTANTE: Los logs deben ir a stderr (>&2) para no contaminar subshells $()
# ============================================================================

log_info() { echo -e "${BLUE}ℹ${NC} $1" >&2; }
log_success() { echo -e "${GREEN}✓${NC} $1" >&2; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1" >&2; }
log_error() { echo -e "${RED}✗${NC} $1" >&2; }

show_usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Generate intelligent commit messages using local AI.

OPTIONS:
    -h, --help              Show this help
    -m, --model MODEL       Specify the LLM model
    -s, --style STYLE       Style: conventional, simple, detailed
    -e, --edit              Edit the message before committing
    -n, --no-commit         Just generate the message, don't commit
    -c, --clipboard         Copy the message to the clipboard
    -v, --verbose           Verbose mode
    --staged-only           Only consider staged changes
EOF
}

check_dependencies() {
    if ! command -v git &> /dev/null; then log_error "Git is not installed." && exit 1; fi
    if ! command -v ollama &> /dev/null; then log_error "Ollama is not installed." && exit 1; fi
}

check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "You are not in a Git repository."
        exit 1
    fi
}

check_ollama_running() {
    if ! ollama list &> /dev/null; then
        log_warning "Ollama is not running. Launching might be required."
        sleep 2
        if ! ollama list &> /dev/null; then
            log_error "Unable to connect to Ollama. Launch the Ollama application."
            exit 1
        fi
    fi
}

check_model_available() {
    local model="$1"
    
    # Red Team Fix: Usamos la API REST en lugar de la CLI para evitar colores ANSI
    if ! curl -s http://localhost:11434/api/tags | grep -q "\"name\":\"${model}\""; then
        log_warning "Model '$model' not found locally."
        read -p "Download now? (y/n): " -n 1 -r < /dev/tty
        echo >&2
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Downloading model $model..."
            # Aquí sí usamos la CLI porque queremos que el usuario vea la barra de progreso
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
            log_error "There are no staged changes to commit."
            exit 1
        fi
    else
        diff_output=$(git diff --staged --no-color)
        if [ -z "$diff_output" ]; then
            diff_output=$(git diff --no-color)
            if [ -z "$diff_output" ]; then
                log_error "There are no changes to analyze."
                exit 1
            fi
            log_warning "Using unstaged changes."
        fi
    fi

    if [ "$MAX_DIFF_LINES" -gt 0 ]; then
        local line_count=$(echo "$diff_output" | wc -l | tr -d ' ')
        if [ "$line_count" -gt "$MAX_DIFF_LINES" ]; then
            log_warning "Diff truncated to $MAX_DIFF_LINES lines."
            diff_output=$(echo "$diff_output" | head -n "$MAX_DIFF_LINES")
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
    
    cat <<EOF
Analyze the following diff and generate a commit message.
Respond ONLY with the commit message, without markdown blocks, without additional explanations.

STYLE GUIDELINES:
$([ "$style" == "conventional" ] && echo "- Use Conventional Commits format: <type>(<scope>): <description>")
$([ "$style" == "simple" ] && echo "- Use a single concise line, max 72 characters, imperative mood.")
$([ "$style" == "detailed" ] && echo "- Provide a title (max 50 chars), leave a blank line, and provide a detailed body explaining 'why'.")

DIFF:
$diff
EOF
}

generate_commit_message() {
    local model="$1"
    local style="$2"
    local diff="$3"
    
    local prompt=$(generate_prompt "$style" "$diff")
    
    # Red Team Fix: Escapamos el prompt a formato JSON de forma segura usando Python
    local escaped_prompt=$(python3 -c 'import json, sys; print(json.dumps(sys.stdin.read()))' <<< "$prompt")
    
    # Construimos el payload para la API (stream: false garantiza que nos devuelva la respuesta completa de golpe)
    local payload="{\"model\": \"$model\", \"prompt\": $escaped_prompt, \"stream\": false, \"options\": {\"temperature\": $TEMPERATURE}}"
    
    local response
    # Llamada limpia a la API, sin animaciones ni spinners
    response=$(curl -s -X POST http://localhost:11434/api/generate \
        -H "Content-Type: application/json" \
        -d "$payload")
        
    if [ -z "$response" ]; then
        log_error "Error: Ollama API did not respond."
        exit 1
    fi
    
    # Extraemos solo el campo 'response' del JSON usando Python
    local clean_msg
    clean_msg=$(echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('response', ''))" 2>/dev/null)
    
    if [ -z "$clean_msg" ]; then
        log_error "Error parsing API response."
        exit 1
    fi
    
    # Limpieza final: quitar comillas invertidas de markdown (```) si el modelo las incluyó
    echo "$clean_msg" | sed 's/^```.*$//' | awk 'NF'
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

    if [[ "$(basename "$0")" == "gdcopy" ]]; then
        no_commit=true
        clipboard=true
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) show_usage; exit 0 ;;
            -m|--model) custom_model="$2"; shift 2 ;;
            -s|--style) custom_style="$2"; shift 2 ;;
            -e|--edit) edit=true; shift ;;
            -n|--no-commit) no_commit=true; shift ;;
            -c|--clipboard) clipboard=true; shift ;;
            -v|--verbose) verbose=true; shift ;;
            --staged-only) staged_only=true; shift ;;
            *) log_error "Unknown option: $1"; show_usage; exit 1 ;;
        esac
    done

    local final_model="${custom_model:-$MODEL}"
    local final_style="${custom_style:-$COMMIT_STYLE}"

    check_dependencies
    check_git_repo
    check_ollama_running
    check_model_available "$final_model"

    log_info "Analyzing changes..."
    local diff_content=$(get_diff "$staged_only")
    
    if [ "$verbose" = true ]; then
        log_info "$(get_commit_stats)"
        log_info "Generating message with model: $final_model (Style: $final_style)"
    fi

    # Generación
    local commit_msg
    commit_msg=$(generate_commit_message "$final_model" "$final_style" "$diff_content")

    if [ -z "$commit_msg" ]; then
        log_error "Failed to generate a commit message. AI returned empty."
        exit 1
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}COMMIT MESSAGE GENERADO:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$commit_msg"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [ "$clipboard" = true ]; then
        if command -v pbcopy &> /dev/null; then
            echo "$commit_msg" | pbcopy
            log_success "Copied to clipboard"
        fi
    fi

    if [ "$no_commit" = true ]; then
        log_info "Message generated. No commit made (--no-commit)"
        exit 0
    fi

    if [ "$edit" = true ]; then
        local temp_file=$(mktemp)
        echo "$commit_msg" > "$temp_file"
        ${EDITOR:-vi} "$temp_file"
        commit_msg=$(cat "$temp_file")
        rm "$temp_file"
    else
        read -p "Commit with this message? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Commit canceled"
            exit 0
        fi
    fi

    git commit -m "$commit_msg"
    
    if [ $? -eq 0 ]; then
        log_success "Commit successfully completed"
    else
        log_error "Error when committing"
        exit 1
    fi
}

main "$@"