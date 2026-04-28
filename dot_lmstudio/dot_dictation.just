# Load the dictation model
[group('Dictation')]
load-dictation:
  ./bin/lms load --gpu max -c 2048 --identifier dictation --parallel 4 qwen2.5-3b-instruct --verbose

# Unload the dictation model
[group('Dictation')]
unload-dictation:
  ./bin/lms unload dictation

# Reload the dictation model
[group('Dictation')]
reload-dictation: unload-dictation load-dictation
