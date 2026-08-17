#!/usr/bin/env bash
set -Eeuo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required" >&2
  exit 1
fi

if ! python3 -c 'import paramiko' >/dev/null 2>&1; then
  echo "paramiko is required; install it in a managed Python environment" >&2
  exit 1
fi

exec python3 "$script_dir/ssh_tool.py" "$@"
