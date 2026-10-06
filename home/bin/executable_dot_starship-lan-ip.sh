#!/bin/bash

set -euo pipefail

is_private_ipv4() {
  case "$1" in
    10.*|192.168.*) return 0 ;;
    172.1[6-9].*|172.2[0-9].*|172.3[0-1].*) return 0 ;;
    *) return 1 ;;
  esac
}

skip_iface() {
  case "$1" in
    lo*|utun*|awdl*|llw*|bridge*|gif*|stf*|anpi*|vmenet*) return 0 ;;
    *) return 1 ;;
  esac
}

is_linux() {
  [[ "${OSTYPE:-}" == linux* ]]
}

try_iface_macos() {
  local iface="$1"
  local ip

  if skip_iface "$iface"; then
    return 1
  fi

  ip="$(ipconfig getifaddr "$iface" 2>/dev/null || true)"
  if [[ -n "$ip" ]] && is_private_ipv4 "$ip"; then
    printf "%s" "$ip"
    return 0
  fi

  return 1
}

try_iface_linux() {
  local iface="$1"
  local ip

  if skip_iface "$iface"; then
    return 1
  fi

  ip="$(ip -4 -o addr show dev "$iface" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1)"
  if [[ -n "$ip" ]] && is_private_ipv4 "$ip"; then
    printf "%s" "$ip"
    return 0
  fi

  return 1
}

# Prefer common primary interfaces first.
for iface in en0 en1 en2; do
  if is_linux; then
    if try_iface_linux "$iface"; then
      exit 0
    fi
  else
    if try_iface_macos "$iface"; then
      exit 0
    fi
  fi
done

# Linux primary interface names.
for iface in eth0 wlan0 wlp2s0 ens33; do
  if is_linux; then
    if try_iface_linux "$iface"; then
      exit 0
    fi
  fi
done

# Fallback: scan all other interfaces.
if is_linux; then
  for iface in $(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | cut -d@ -f1); do
    if try_iface_linux "$iface"; then
      exit 0
    fi
  done
else
  for iface in $(ifconfig -l); do
    if try_iface_macos "$iface"; then
      exit 0
    fi
  done
fi

exit 1
