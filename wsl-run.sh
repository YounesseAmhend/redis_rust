#!/bin/bash
# Run a command in this repo with WSL-local Go and Rust on PATH.
set -euo pipefail
export PATH="${HOME}/.local/go/bin:${HOME}/.cargo/bin:${PATH}"
cd "$(dirname "$0")"
exec "$@"
