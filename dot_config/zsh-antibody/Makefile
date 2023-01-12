COMPDUMP=~/.zcompdump
STATIC=~/.zsh_antibody_static.zsh
PLUGINS=~/.config/zsh-antibody/plugins.txt

help:
	cat Makefile

dynamic: clean

clean:
	@echo "\n*** [dynamic] Removing antibody static startup script..."
	rm -fv $(STATIC) $(STATIC).zwc $(COMPDUMP) $(COMPDUMP).zwc

static: clean compile

compile:
	@echo "\n*** [static] Compling antibody into static startup script..."
	/opt/homebrew/bin/antibody bundle < $(PLUGINS) > $(STATIC)
	zsh -c 'autoload -Uz compinit; compinit; compdump; zcompile $(STATIC); zcompile $(COMPDUMP)'

watch_compdump:
	# macOS needs `stat -x` to have the same output as linux
	while [ true ]; do stat -x ~/.zcompdump | grep Modify; sleep 1; done
