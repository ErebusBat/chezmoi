
install:
	sudo gem install hashie

newkey:
	dd if=/dev/random bs=1024 count=1 2>/dev/null | sha512sum | awk '{print $$1}'
