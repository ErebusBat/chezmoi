# Local coding models. These are intentionally mutually exclusive: loading
# more than one of them would exhaust unified memory once their KV caches grow.
LMS := './bin/lms'
MODELS_ROOT := '/Volumes/SeaBack/llm/lm-studio/models'

DEVSTRAL_MODEL := MODELS_ROOT / 'mlx-community/Devstral-Small-2-24B-Instruct-2512-4bit'
QWEN_MODEL := MODELS_ROOT / 'unsloth/Qwen3.6-27B-UD-MLX-6bit'
QWEN_FAST_MODEL := MODELS_ROOT / 'unsloth/Qwen3.6-27B-UD-MLX-MXFP4'

# Ensure the LM Studio API server is available to Oh My Pi.
[group('Coding models')]
code-server:
  {{LMS}} server start

# Show an estimate before loading a model. No model is loaded by this recipe.
[group('Coding models')]
estimate-devstral:
  {{LMS}} load --estimate-only --gpu max --context-length 65536 {{DEVSTRAL_MODEL}}

[group('Coding models')]
estimate-qwen:
  {{LMS}} load --estimate-only --gpu max --context-length 32768 {{QWEN_MODEL}}

# Load Devstral at a comfortable 64k context. Oh My Pi model: lm-studio/devstral-code.
[group('Coding models')]
load-devstral: code-server
  #!/usr/bin/env zsh
  {{LMS}} unload qwen-code >/dev/null 2>&1 || true
  {{LMS}} unload qwen-code-fast >/dev/null 2>&1 || true
  {{LMS}} load --gpu max --context-length 65536 --identifier devstral-code {{DEVSTRAL_MODEL}}

# Load the highest-quality Qwen variant at 32k context. Oh My Pi model: lm-studio/qwen-code.
[group('Coding models')]
load-qwen: code-server
  #!/usr/bin/env zsh
  {{LMS}} unload devstral-code >/dev/null 2>&1 || true
  {{LMS}} unload qwen-code-fast >/dev/null 2>&1 || true
  {{LMS}} load --gpu max --context-length 32768 --identifier qwen-code {{QWEN_MODEL}}

# Load the smaller Qwen variant for a 48k context. Oh My Pi model: lm-studio/qwen-code-fast.
[group('Coding models')]
load-qwen-fast: code-server
  #!/usr/bin/env zsh
  {{LMS}} unload devstral-code >/dev/null 2>&1 || true
  {{LMS}} unload qwen-code >/dev/null 2>&1 || true
  {{LMS}} load --gpu max --context-length 49152 --identifier qwen-code-fast {{QWEN_FAST_MODEL}}

# Unload only the coding models, preserving dictation and any other LM Studio work.
[group('Coding models')]
code-down:
  #!/usr/bin/env zsh
  {{LMS}} unload devstral-code >/dev/null 2>&1 || true
  {{LMS}} unload qwen-code >/dev/null 2>&1 || true
  {{LMS}} unload qwen-code-fast >/dev/null 2>&1 || true
  {{LMS}} ps

# Show every model currently resident in unified memory.
[group('Coding models')]
code-ps:
  {{LMS}} ps
