# LSHQ-ipad (65907ABE-7A1A-462F-BBEB-5CB3800DDA13)
LSHQ_IPAD_ID:='65907ABE-7A1A-462F-BBEB-5CB3800DDA13'
LSHQ_IPAD_NM:='LSHQ-ipad'

# ???
DD_IPAD_ID:=''
DD_IPAD_NM:='Daddys iPad'

# List Sidecar tasksp
[group('Sidecar')]
ls-sidecar:
  just --list --group 'Sidecar'

# show current sidecar status.
[group('Sidecar')]
sidecar-status:
  sidecarctl status

# disconnect sidecar display.
[group('Sidecar')]
sidecar-disconnect:
  sidecarctl disconnect

# Connect to prefered sidecar device
[group('Sidecar')]
sidecar-connect:
  sidecarctl connect \
    --device-name "{{LSHQ_IPAD_NM}}" \
    --device-name "{{DD_IPAD_NM}}" \

# connect sidecar to LSHQ iPad.
[group('Sidecar')]
sidecar-connect-lshq:
  sidecarctl connect --device-name "{{LSHQ_IPAD_NM}}"
