ls:
	ls -la /etc/chrony.d/

install:
	sudo rm -v /etc/chrony.d/chrony.conf
	sudo ln -s ~/.config/chrony/chrony.conf /etc/chrony.d/chrony.conf

etc_to_config:
	cat /etc/chrony.d/chrony.conf > ~/.config/chrony/chrony.conf

fingerprint:
	./fingerprint_etc.sh
