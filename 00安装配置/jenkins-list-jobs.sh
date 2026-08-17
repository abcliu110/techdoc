#!/usr/bin/env bash
set -euo pipefail

jenkins_url="${JENKINS_URL:-http://127.0.0.1:30080}"
password="$(kubectl get secret jenkins-admin -n jenkins -o jsonpath='{.data.chart-admin-password}' | base64 -d)"
work_dir="$(mktemp -d)"
trap 'unset password; rm -rf -- "$work_dir"' EXIT

printf 'user = "admin:%s"\n' "$password" > "$work_dir/curl.conf"
chmod 600 "$work_dir/curl.conf"
curl --config "$work_dir/curl.conf" --fail --silent --show-error \
  "${jenkins_url}/api/json?tree=jobs%5Bname,fullName%5D" \
  | jq -r '.jobs[] | "\(.fullName)"'
