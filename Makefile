test:
	shellcheck scripts/*.sh tests/*.sh
	bash tests/restore-drill.sh
