#!/bin/sh

# macOS 15: SSID retrieval requires com.apple.developer.networking.wifi-info entitlement
# (restricted — needs paid Apple Developer ID). All other tools (networksetup, ipconfig,
# system_profiler, CoreWLAN) redact or return empty for the SSID without it.
#
# Instead: detect connected state via ifconfig en0 status + inet address presence.
# en0 is the canonical Wi-Fi interface on Apple Silicon/Intel Macs.

STATUS=$(ifconfig en0 2>/dev/null | awk '/status:/{print $2}')
HAS_IP=$(ifconfig en0 2>/dev/null | awk '/inet /{print $2; exit}')

if [ "$STATUS" = "active" ] && [ -n "$HAS_IP" ]; then
  sketchybar --set "$NAME" icon="󰤨" label=""
else
  sketchybar --set "$NAME" icon="󰤭" label=""
fi
