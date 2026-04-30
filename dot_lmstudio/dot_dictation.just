# https://chatgpt.com/c/69f1449c-9344-83e8-b418-0314883513d6

# DICTATION_MODEL := 'qwen2.5-3b-instruct'
# DICTATION_MODEL_CONTEXT_SIZE := '2048 '
DICTATION_MODEL := 'qwen2.5-7b-instruct-mlx@8bit'
DICTATION_MODEL_CONTEXT_SIZE := '8192'

# Load the dictation model
[group('Dictation')]
load-dictation:
  ./bin/lms load --gpu max -c {{ DICTATION_MODEL_CONTEXT_SIZE }}  --identifier dictation --parallel 4 --verbose {{ DICTATION_MODEL }}

# Unload the dictation model
[group('Dictation')]
unload-dictation:
  ./bin/lms unload dictation

# Reload the dictation model
[group('Dictation')]
reload-dictation: unload-dictation load-dictation
