# CodeCrafters Redis (Rust)

Local [Build your own Redis](https://app.codecrafters.io/courses/redis/overview) challenge.
The Go tester in `tester/` is the official [redis-tester](https://github.com/codecrafters-io/redis-tester) source, vendored as normal files (not a git submodule).
Starter code is the official unsolved [Rust template](https://github.com/codecrafters-io/build-your-own-redis/tree/main/compiled_starters/rust).

No CodeCrafters subscription is required.

## Requirements

- GNU Make
- Go 1.24+ and Rust (`cargo`) on Linux or macOS
- On Windows, Ubuntu WSL2 (the tester uses Unix process APIs). `make` from Git Bash forwards into WSL.

## Commands

```sh
make test          # all official stages
make test-base     # first 7 stages (PING, ECHO, SET/GET, expiry)
make test-stage-1  # bind to port 6379 (jm1)
make test-stage-7  # through expiry (yz1)
make test-rdb      # RDB persistence extension
make test-repl     # replication extension
make run           # start your server
```

The tester talks to your process on `127.0.0.1:6379`. It starts your code through `your_program.sh`.

The starter leaves stage 1 commented out on purpose. `make test-stage-1` should fail until you uncomment the TCP bind in `src/main.rs`.
