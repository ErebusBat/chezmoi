# vim: set ft=just ts=4 sw=4 sts=4 et ai si sta:

# DEFAULT_CONTEXT := '0' # 0=default/max
# DEFAULT_CONTEXT := '8192' # 8k
# DEFAULT_CONTEXT := '16384' # 16k
DEFAULT_CONTEXT := '131072' # 128k

LLAMA_PORT := '8888'
# LLAMA_CPP_CMD := 'llama'
# LLAMA_SERVE_CMD := LLAMA_CPP_CMD + ' serve' + ' --port '+LLAMA_PORT
LLAMA_CPP_CMD := env('HOME') / 'src/vendor/llama.cpp/official/build/bin/llama-server'
# LLAMA_CPP_CMD := env('HOME') / 'src/vendor/llama.cpp/prism-ml/build/bin/llama-server'

LLAMA_SERVE_CMD := LLAMA_CPP_CMD + ' --port ' + LLAMA_PORT
LLAMA_CPP_MODELS_PATH := LMS_MODEL_ROOT / 'llama.cpp'

### Fit Options
# FIT_OPTIONS := '--fit on'
FIT_OPTIONS := '--fit-target 4096'

### IMPORTANT: re context / parallel
# -c 131072 = The server allocates a single KV cache pool that can hold 131,072 tokens.
# --parallel 2 = The server creates 2 separate "slots" (workers) within that pool.
#
# With --parallel 2, the server splits that 131k context pool into 2 equal halves. So:
#   - Slot 1 gets ~65,536 tokens
#   - Slot 2 gets ~65,536 tokens
# This means:
# You can handle 2 concurrent requests, but each request is limited to ~65k tokens, not the full 131k.
# See: https://chat.deepseek.com/a/chat/s/1e3af977-711d-4500-aab4-1e16d368e8bb

# Helper to list llama.cpp tasks
[group('llama.cpp')]
ls-llama:
    just --list --group 'llama.cpp'

# Run llama-server command
[group('llama.cpp')]
llama-server *args:
    {{ LLAMA_CPP_CMD }} {{ args }}

# Serve Gemma4 31B
[group('llama.cpp')]
serve-gemma4 context=DEFAULT_CONTEXT vision='1':
    #!/usr/bin/env zsh
    context="{{context}}"
    if [[ $context -eq 1 ]]; then
        context="{{DEFAULT_CONTEXT}}"
        echo "*** INFO: Context was 1; using $context"
    elif [[ $context -eq 0 ]]; then
        echo "*** WARN: Context is 0; llama will use max"
    fi
    # codex://threads/019fb013-a51a-71a2-a29c-eecdaddb908d
    ARGS=(--load-mode mmap)
    ARGS+=(--flash-attn on)
    ARGS+=(--reasoning on)
    ARGS+=(-ngl all)
    ARGS+=(--alias gemma4-31b)
    ARGS+=(--parallel 1)
    ARGS+=(-c $context)
    ARGS+=(-b 1024 -ub 256)
    ARGS+=(--cache-type-k q8_0 --cache-type-v q8_0 --cache-ram 0)
    ARGS+=(-t 8)
    ARGS+=(-m {{ QWEN36_35B_PATH }}/Qwen3.6-35B-A3B-Q4_K_M.gguf)

    if [[ "{{vision}}" -gt 0 ]]; then
        echo "*** INFO: Enabling Vision Mode"
        echo "        : Disable with: just serve-gemma4 $context 0"
        ARGS+=(--mmproj {{ QWEN36_35B_PATH }}/mmproj-Qwen3.6-35B-A3B-BF16.gguf)
    fi

    echo "*** INFO: Starting with c=$context"
    echo "> llama-server $ARGS[@]"
    {{ LLAMA_SERVE_CMD }} "$ARGS[@]"

QWEN36_35B_PATH := LMS_COMMUNITY_PATH / 'Qwen3.6-35B-A3B-GGUF'
# Start the 'big' Qwen 3.6 MoE Model
[group('llama.cpp')]
serve-qwen36 context=DEFAULT_CONTEXT slots='1':
    @# https://chat.deepseek.com/a/chat/s/6038e837-ea63-4b1d-be55-8d5e4872bbb3
    {{ LLAMA_SERVE_CMD }} --load-mode mmap \
      --flash-attn on \
      --reasoning-preserve \
      -mg 999 \
      --alias qwen36-35b-a3b \
      --parallel {{ slots }} \
      -c {{ context }} \
      -b 1024 -ub 256 \
      --cache-type-k q8_0 --cache-type-v q8_0 \
      -t 8 \
      -m {{ QWEN36_35B_PATH }}/Qwen3.6-35B-A3B-Q4_K_M.gguf \
      --mmproj {{ QWEN36_35B_PATH }}/mmproj-Qwen3.6-35B-A3B-BF16.gguf

# Start Laguna-XS 2.1
[group('llama.cpp')]
serve-laguna-xs context=DEFAULT_CONTEXT:
    @# https://huggingface.co/poolside/Laguna-XS-2.1-GGUF
    {{ LLAMA_SERVE_CMD }} --load-mode mmap \
      --alias laguna-xs-2.1 \
      --parallel 1 \
      -fa on \
      -ngl 999 \
      -c {{ context }} \
      -m {{ LMS_MODEL_ROOT }}/poolside/Laguna-XS-2.1-GGUF/Laguna-XS-2.1-Q4_K_M.gguf

# Start Laguna-S 2
[group('llama.cpp')]
serve-laguna-s context=DEFAULT_CONTEXT:
    # --no-mmap         # Disable mmap; tensor overrides to CPU are used with mmap enabled
    # --load-mode none  # Replacement for no-mmap

    @#https://huggingface.co/unsloth/Laguna-S-2.1-GGUF
    {{ LLAMA_SERVE_CMD }} {{ FIT_OPTIONS }} --load-mode none \
      --alias laguna-s2-iq1_s \
      --parallel 1 \
      -c {{ context }} \
      -m {{ LLAMA_CPP_MODELS_PATH }}/Laguna-S-2.1-UD-IQ1_S/Laguna-S-2.1-UD-IQ1_S.gguf

# Ternary-Bonsai-27B
[group('llama.cpp')]
serve-bonsai context=DEFAULT_CONTEXT:
    # --no-mmap         # Disable mmap; tensor overrides to CPU are used with mmap enabled
    # --load-mode none  # Replacement for no-mmap

    @#https://huggingface.co/prism-ml/Ternary-Bonsai-27B-gguf
    {{ LLAMA_SERVE_CMD }} {{ FIT_OPTIONS }} --no-mmap \
      --alias bonsai-27b \
      --parallel 1 \
      -n 256 \
      --temp 0.7 --top-p 0.95 --top-k 20 \
      -ngl 99 \
      -c {{ context }} \
      -m {{ LLAMA_CPP_MODELS_PATH }}/Ternary-Bonsai-27B-PQ2_0/Ternary-Bonsai-27B-Q2_0.gguf

# Helper to download Hugging Face Models to propper path
[group('llama.cpp')]
hf-download hf-uri *args:
    #!/usr/bin/env zsh
    hf_uri={{ hf-uri }}
    model_name=${hf_uri:t:r}
    local_dir="{{ LLAMA_CPP_MODELS_PATH }}/${model_name}"

    if [[ $hf_uri != hf://* ]]; then
      echo "WARNING: URI Should start with hf://"
      exit 1
    fi

    echo "> hf download --local-dir $local_dir {{ args }} $hf_uri"
    hf download --local-dir $local_dir {{ args }} $hf_uri
