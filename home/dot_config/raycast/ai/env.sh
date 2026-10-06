#!/usr/bin/env zsh
RAYCAST_AI_SCRIPT_DIR="${0:a:h}"
RAYCAST_AI_PROVIDERS="${RAYCAST_AI_SCRIPT_DIR}/providers.yaml"

# ─── Early Helpers  ──────────────────────────────────────────────────────────
_log_debug() { print -P "%F{240}[DEBUG] $*%f" }
_log_info()  { print -P "[INFO ] $*" }
_log_warn()  { print -P "%F{yellow}[WARN ] $*%f" }
_log_error() { print -P "%F{red}[ERROR] $*%f" }
_log_fatal() {
  print -P "%F{red}[FATAL] $*%f"
  kill -INT $$
}
# ─── Sanity Check ─────────────────────────────────────────────────────────────
if [[ "${ZSH_EVAL_CONTEXT}" != *:file* ]]; then
  _log_info "%F{green}Usage%f: source ${0:a}"
  _log_fatal "This script must be sourced, not executed directly."
  return 1 2>/dev/null || exit 1
fi
# ─── Functions ───────────────────────────────────────────────────────────────

# ─── Main ────────────────────────────────────────────────────────────────────
_print_raycast_env_usage() {
  _log_info "%F{green}Available commands:%f"
  _log_info ""
  _log_info "  %F{yellow}# Raycast AI%f"
  _log_info "  %F{cyan}raycast_ai_providers_ls%f  %F{240}(alias: %F{cyan}raipls%F{240})%f               List provider ids."
  _log_info "  %F{cyan}raycast_ai_models_ls%f     %F{240}(alias: %F{cyan}raimls%F{240})%f  [provider]   List all models or filter by provider id."
  _log_info ""
  _log_info "  %F{240}Examples:%f"
  _log_info "  raipls"
  _log_info "  raimls"
  _log_info "  raimls kimi"
  _log_info ""
}
if [[ "$PWD" == "$RAYCAST_AI_SCRIPT_DIR" ]]; then
  _print_raycast_env_usage
fi

unfunction _print_raycast_env_usage _log_debug _log_info _log_warn _log_error _log_fatal

# NOTE: helper log functions are unfunctioned above; do not use below.

# ═══ Raycast AI ═══════════════════════════════════════════════════════════════════
function raycast_ai_providers_ls() {
  yq eval '.providers[] | .id' "$RAYCAST_AI_PROVIDERS"
}
alias raipls=raycast_ai_providers_ls

function raycast_ai_models_ls() {
  local provider="$1"
  if [[ -n $provider ]]; then
    provider="$provider" yq eval '.providers[] | select(.id == strenv(provider)) | .id as $pid | .models[] | $pid + "/" + .id' "$RAYCAST_AI_PROVIDERS"
  else
    yq eval '.providers[] | .id as $pid | .models[] | $pid + "/" + .id' "$RAYCAST_AI_PROVIDERS"
  fi
}
alias raimls=raycast_ai_models_ls
