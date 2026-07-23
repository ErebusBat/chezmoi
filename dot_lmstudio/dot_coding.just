QWEN36_35B_PATH := LMS_COMMUNITY_PATH / 'Qwen3.6-35B-A3B-GGUF'
DEFAULT_CONTEXT := '131072' # 128k
LLAMA_PORT := '8888'

ls-llama:
  just --list --group 'llama.cpp'

# Start the 'big' Qwen 3.6 MoE Model
[group('llama.cpp')]
qwen36-llamacpp context=DEFAULT_CONTEXT:
  cd {{QWEN36_35B_PATH}} && \
    llama serve --port {{LLAMA_PORT}} --jinja \
      --flash-attn on \
      -c {{context}} \
      -m Qwen3.6-35B-A3B-Q4_K_M.gguf \
      --mmproj mmproj-Qwen3.6-35B-A3B-BF16.gguf
