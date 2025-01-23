COMPDUMP=~/.zcompdump
PLUGINS=~/.config/zsh-antibody/plugins.txt
STATIC=~/.config/zsh-antibody/plugins.zsh

help:
	cat Makefile

dynamic: clean

clean:
	@echo "\n*** [dynamic] Removing antibody static startup script..."
	/bin/rm -fv $(STATIC) $(STATIC).zwc $(COMPDUMP) $(COMPDUMP).zwc

static: clean compile gen_sums

compile:
	@echo "\n*** The next time a new shell opens it will be compiled"

watch_compdump:
	# macOS needs `stat -x` to have the same output as linux
	while [ true ]; do stat -x ~/.zcompdump | grep Modify; sleep 1; done

gen_sums:
	find . -type f \! -iname '.shasum' | sort | xargs shasum > .shasum

rm_sums:
	test -f .shasum && rm .shasum || true
