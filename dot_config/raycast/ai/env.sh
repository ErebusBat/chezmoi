#!/usr/bin/env zsh
RAYCAST_AI_PROVIDERS=providers.yaml

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

# ═══ Raycast AI ═══════════════════════════════════════════════════════════════════
function raycast_ai_models_ls() {
  local provider="$1"
  if [[ -n $provider ]]; then
    provider="$provider" yq eval '.providers[] | select(.id == strenv(provider)) | .id as $pid | .models[] | $pid + "/" + .id' "$RAYCAST_AI_PROVIDERS"
  else
    yq eval '.providers[] | .id as $pid | .models[] | $pid + "/" + .id' "$RAYCAST_AI_PROVIDERS"
  fi
}
alias rcaimls=raycast_ai_models_ls


# ─── Main ────────────────────────────────────────────────────────────────────
_print_usage() {
  _log_info "%F{green}Available commands:%f"
  _log_info ""
  _log_info "  %F{yellow}# AI Providers%f"
  _log_info "  %F{cyan}raycast_ai_models_ls%f  %F{240}(%F{cyan}rcaimls%F{240})%f        <args>          List all models."
  _log_info ""
}
_print_usage
