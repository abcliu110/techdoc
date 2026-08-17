#!/usr/bin/env bash
set -euo pipefail

tmp_file="$(mktemp)"
trap 'rm -f -- "$tmp_file"' EXIT

helm show values harbor/harbor --version 1.19.2 > "$tmp_file"
grep -n -A12 -B2 'extraEnv' "$tmp_file"
