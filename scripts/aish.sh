#!/usr/bin/env bash
# aish — AI Shell Command Generator
# Source this file from your ~/.zshrc or ~/.bashrc

# Capture the path this file was sourced from, for use by aish-update
if [[ -n "$ZSH_VERSION" ]]; then
    _AISH_SOURCE_PATH="${(%):-%x}"
else
    _AISH_SOURCE_PATH="${BASH_SOURCE[0]}"
fi

_AISH_SYSTEM_PROMPT='You are a command-line generator. Given a natural language description of a task, output ONLY the corresponding shell command. Rules:\n- Output the raw command only — no explanations, no markdown, no code fences\n- If the task requires multiple commands, chain them with && or ;\n- Use common CLI tools and flags'

_aish_check_provider() {
    if [[ -z "$AISH_PROVIDER" ]]; then
        echo "aish: AISH_PROVIDER is not set." >&2
        echo "Set it to one of: anthropic, openai, ollama" >&2
        echo "" >&2
        echo "  export AISH_PROVIDER=anthropic" >&2
        echo "  export AISH_PROVIDER=openai" >&2
        echo "  export AISH_PROVIDER=ollama" >&2
        return 1
    fi
    case "$AISH_PROVIDER" in
        anthropic|openai|ollama) return 0 ;;
        *)
            echo "aish: Unknown provider '$AISH_PROVIDER'." >&2
            echo "Supported providers: anthropic, openai, ollama" >&2
            return 1
            ;;
    esac
}

_aish_escape_json() {
    printf '%s' "$1" | jq -Rs .
}

_aish_spinner_start() {
    { (
        frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
        i=0
        while true; do
            printf '\r%s' "${frames:$i:1}" >&3
            i=$(( (i + 1) % ${#frames} ))
            sleep 0.1
        done
    ) & } 3>&2 2>/dev/null
    exec 3>&-
    _AISH_SPINNER_PID=$!
}

_aish_spinner_stop() {
    if [[ -n "$_AISH_SPINNER_PID" ]]; then
        kill "$_AISH_SPINNER_PID" 2>/dev/null
        wait "$_AISH_SPINNER_PID" 2>/dev/null
        unset _AISH_SPINNER_PID
        printf '\r\033[2K' >&2
    fi
}

_aish_call_anthropic() {
    local prompt="$1"
    local model="${AISH_MODEL:-claude-sonnet-4-6}"
    local escaped_prompt
    escaped_prompt=$(_aish_escape_json "$prompt")

    curl -s https://api.anthropic.com/v1/messages \
        -H "x-api-key: $ANTHROPIC_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -H "content-type: application/json" \
        -d '{
            "model": "'"$model"'",
            "max_tokens": 256,
            "system": "'"$_AISH_SYSTEM_PROMPT"'",
            "messages": [{"role": "user", "content": '"$escaped_prompt"'}]
        }' | jq -r '.content[0].text // empty'
}

_aish_call_openai() {
    local prompt="$1"
    local model="${AISH_MODEL:-gpt-5-mini}"
    local escaped_prompt
    escaped_prompt=$(_aish_escape_json "$prompt")

    curl -s https://api.openai.com/v1/chat/completions \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{
            "model": "'"$model"'",
            "max_tokens": 256,
            "messages": [
                {"role": "system", "content": "'"$_AISH_SYSTEM_PROMPT"'"},
                {"role": "user", "content": '"$escaped_prompt"'}
            ]
        }' | jq -r '.choices[0].message.content // empty'
}

_aish_call_ollama() {
    local prompt="$1"
    local model="${AISH_MODEL}"
    local base_url="${AISH_OLLAMA_URL:-http://localhost:11434}"

    if [[ -z "$model" ]]; then
        echo "aish: AISH_MODEL is required for Ollama. Set it to a model you have pulled, e.g. llama3." >&2
        return 1
    fi
    local escaped_prompt
    escaped_prompt=$(_aish_escape_json "$prompt")

    curl -s "${base_url}/api/chat" \
        -H "Content-Type: application/json" \
        -d '{
            "model": "'"$model"'",
            "stream": false,
            "messages": [
                {"role": "system", "content": "'"$_AISH_SYSTEM_PROMPT"'"},
                {"role": "user", "content": '"$escaped_prompt"'}
            ]
        }' | jq -r '.message.content // empty'
}

_aish_clean_result() {
    local text="$1"
    # Strip code fences
    text=$(printf '%s' "$text" | sed 's/^```[a-z]*$//' | sed 's/^```$//')
    # Trim leading/trailing whitespace
    text=$(printf '%s' "$text" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    printf '%s' "$text"
}

aish-update() {
    local url="https://raw.githubusercontent.com/circleci-petri/aish/main/aish.sh"
    local dest="$_AISH_SOURCE_PATH"
    local tmp
    tmp=$(mktemp)

    echo "aish: Downloading latest version to $dest..." >&2
    if curl -fsSL "$url" -o "$tmp"; then
        mv "$tmp" "$dest"
        # shellcheck source=/dev/null
        source "$dest"
        echo "aish: Updated successfully." >&2
    else
        rm -f "$tmp"
        echo "aish: Update failed. Check your network connection." >&2
        return 1
    fi
}

aish() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: aish <natural language description>" >&2
        echo "Example: aish list all files larger than 10MB" >&2
        return 1
    fi

    _aish_check_provider || return 1

    # Check API key before starting the spinner
    case "$AISH_PROVIDER" in
        anthropic)
            if [[ -z "$ANTHROPIC_API_KEY" ]]; then
                echo "aish: ANTHROPIC_API_KEY is not set." >&2
                return 1
            fi ;;
        openai)
            if [[ -z "$OPENAI_API_KEY" ]]; then
                echo "aish: OPENAI_API_KEY is not set." >&2
                return 1
            fi ;;
        ollama)
            if [[ -z "$AISH_MODEL" ]]; then
                echo "aish: AISH_MODEL is required for Ollama. Set it to a model you have pulled, e.g. llama3." >&2
                return 1
            fi ;;
    esac

    local prompt="$*"
    local result

    # Suppress job control messages ([1] 12345, [1] + terminated ...)
    if [[ -n "$ZSH_VERSION" ]]; then
        setopt LOCAL_OPTIONS NO_MONITOR
    else
        set +m
    fi

    trap '_aish_spinner_stop' INT TERM
    _aish_spinner_start

    case "$AISH_PROVIDER" in
        anthropic) result=$(_aish_call_anthropic "$prompt") ;;
        openai)    result=$(_aish_call_openai "$prompt") ;;
        ollama)    result=$(_aish_call_ollama "$prompt") ;;
    esac

    _aish_spinner_stop
    trap - INT TERM

    if [[ -z "$result" ]]; then
        echo "aish: No response from $AISH_PROVIDER. Check your API key and network." >&2
        return 1
    fi

    result=$(_aish_clean_result "$result")

    if [[ -z "$result" ]]; then
        echo "aish: Empty result." >&2
        return 1
    fi

    # Push to editing buffer
    if [[ -n "$ZSH_VERSION" ]]; then
        print -z "$result"
    else
        local histfile="${HISTFILE:-$HOME/.bash_history}"
        printf '%s\n' "$result" >> "$histfile"
        history -n
        printf '\033[2m%s\033[0m\n' "↑ to run: $result" >&2
    fi
}
