TUITIME_FILE := source_directory() / 'tuitimes'

[doc('Start tuitime with wellknown times file')]
[group('timer')]
timer file=TUITIME_FILE:
  tuitime --file {{ file }} --watch --skip-past -r

[doc('Edit the wellknown times file')]
[group('timer')]
edit-times-file:
  $EDITOR {{ TUITIME_FILE }}
