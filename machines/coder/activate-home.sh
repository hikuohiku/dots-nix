#!/usr/bin/env bash
set -euo pipefail

export HOME="${HOME:-/home/coder}"
activation_path="$(cat /nix/coder-home-activation)"

exec "$activation_path/activate"
