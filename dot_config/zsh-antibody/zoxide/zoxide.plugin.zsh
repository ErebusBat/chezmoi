if ! command -v zoxide >/dev/null 2>&1; then
  return
fi

export _ZO_ECHO=1
export _ZO_DATA_DIR=$HOME/.config/zoxide
eval "$(zoxide init --cmd=z zsh)"
eval "$(zoxide init --cmd=cd zsh)"

wd() {
  local delay
  # RANDOM is 0..32767; normalize to 0..1, scale to 0..3.67, then shift to 0.33..4.00s.
  # 3.67 = (4.0s - 0.33s)
  delay=$(printf '%.2f' "$((0.33 + (RANDOM / 32767.0) * 3.67))")
  printf "🚧 WARNING: Don't use wd anymore! \n  🎮 Penalty: %ss\n" "$delay"
  sleep "$delay"
  cd "$@"
}
