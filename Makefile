prepare:
	scripts/prepare.sh

test:
	echo "Test not implemented yet."; exit 1

format:
	stylua -v --verify lua/

lint:
	selene lua/

profile:
	scripts/profile_startup.sh
