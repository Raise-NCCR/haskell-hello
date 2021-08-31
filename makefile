BINARY_PATH_RELATIVE = .stack-work/install/x86_64-linux-tinfo6/aaeaad50d86ac0ac61a8ce777cd37b160d7bed6b7e4b4f6a6d8fe67ec4a80b57/8.10.6/bin/hello-exe
## Build binary and docker images
build:
	@stack build
	@BINARY_PATH=${BINARY_PATH_RELATIVE} docker-compose build