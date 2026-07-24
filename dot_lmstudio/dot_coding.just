QWEN36_35B_PATH := LMS_COMMUNITY_PATH / 'Qwen3.6-35B-A3B-GGUF'
DEFAULT_CONTEXT := '131072' # 128k
LLAMA_PORT := '8888'
# LLAMA_CPP_CMD := 'llama'
LLAMA_CPP_CMD := env('HOME') / 'src/vendor/llama.cpp/build/bin/llama'
LLAMA_SERVE_CMD := LLAMA_CPP_CMD + ' serve'

ls-llama:
  just --list --group 'llama.cpp'

# Start the 'big' Qwen 3.6 MoE Model
[group('llama.cpp')]
qwen36-llamacpp context=DEFAULT_CONTEXT:
  cd {{QWEN36_35B_PATH}} && \
    {{LLAMA_SERVE_CMD}} --port {{LLAMA_PORT}} --jinja \
      --flash-attn on \
      -c {{context}} \
      -m Qwen3.6-35B-A3B-Q4_K_M.gguf \
      --mmproj mmproj-Qwen3.6-35B-A3B-BF16.gguf

laguna-s context=DEFAULT_CONTEXT:
  @#https://huggingface.co/unsloth/Laguna-S-2.1-GGUF
  cd {{LMS_MODEL_ROOT }}/poolside/Laguna-S-2.1-GGUF && \
    llama serve --port {{LLAMA_PORT}} --jinja \
      --fit on \
      -c {{context}} \
      -m laguna-s-2.1-DFlash-BF16.gguf

