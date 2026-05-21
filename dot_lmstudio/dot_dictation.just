# older: https://chatgpt.com/c/69f1449c-9344-83e8-b418-0314883513d6

# MAY-2026: codex://threads/019e4aaa-5afa-7de3-a6e6-e2a40f270dee
# DICTATION_MODEL := 'qwen2.5-7b-instruct-mlx'
DICTATION_MODEL := 'qwen3-4b-instruct-2507-mlx'
DICTATION_MODEL_CONTEXT_SIZE := '8192'

# MAY-2026: codex://threads/019e4b1d-6a84-7913-b2f2-84b9d8782f75
SUMMARY_MODEL := 'gemma-4-e4b-it'
SUMMARY_MODEL_CONTEXT_SIZE := '32780'

# Bring LM Studio up with background models that are expected to be there
[group('Dictation')]
up:
  just load-dictation || true
  just load-dictation-summary || true
  @printf "\n\n\nThe following models are available:"
  @./bin/lms ps

# Shut down LM Studio / Restart
[group('Dictation')]
restart:
  ./bin/lms server stop || true
  ./bin/lms server start
  just up

# Unload models
[group('Dictation')]
down: unload-all

# Unload models
[group('Dictation')]
unload-all:
  just unload-dictation || true
  just unload-dictation-summary || true

# Load the dictation model
[group('Dictation')]
load-dictation:
  ./bin/lms load \
    --gpu max \
    -c {{ DICTATION_MODEL_CONTEXT_SIZE }}  \
    --identifier dictation \
    --parallel 4 \
    {{ DICTATION_MODEL }}

# Unload the dictation model
[group('Dictation')]
unload-dictation:
  ./bin/lms unload dictation

# Reload the dictation model
[group('Dictation')]
reload-dictation: unload-dictation load-dictation

# Load the summary model
[group('Dictation')]
load-dictation-summary:
  ./bin/lms load \
    --identifier {{ SUMMARY_MODEL }} \
    --gpu max \
    --context-length {{ SUMMARY_MODEL_CONTEXT_SIZE }} \
    --yes \
    {{ SUMMARY_MODEL }}

# Unload the summary model
[group('Dictation')]
unload-dictation-summary:
  ./bin/lms unload {{ SUMMARY_MODEL }}

# Unload the summary model
[group('Dictation')]
lean:
  just unload-dictation-summary || true
