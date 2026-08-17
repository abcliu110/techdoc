#!/usr/bin/env bash
set -euo pipefail

job_name="${1:?job name is required}"
build_number="${2:?build number is required}"
jenkins_url="${JENKINS_URL:-http://127.0.0.1:30080}"
password="$(kubectl get secret jenkins-admin -n jenkins -o jsonpath='{.data.chart-admin-password}' | base64 -d)"
work_dir="$(mktemp -d)"
trap 'unset password curl_userpwd; rm -rf -- "$work_dir"' EXIT

curl_userpwd="admin:${password}"
curl_userpwd="${curl_userpwd//\\/\\\\}"
curl_userpwd="${curl_userpwd//\"/\\\"}"
printf 'user = "%s"\n' "$curl_userpwd" > "$work_dir/curl.conf"
chmod 600 "$work_dir/curl.conf"
crumb_json="$(curl --config "$work_dir/curl.conf" --fail --silent --show-error \
  --cookie-jar "$work_dir/cookies" "${jenkins_url}/crumbIssuer/api/json")"
crumb_field="$(jq -er '.crumbRequestField' <<<"$crumb_json")"
crumb_value="$(jq -er '.crumb' <<<"$crumb_json")"
curl --config "$work_dir/curl.conf" --fail --silent --show-error \
  --cookie "$work_dir/cookies" --cookie-jar "$work_dir/cookies" \
  -H "${crumb_field}: ${crumb_value}" -X POST \
  "${jenkins_url}/job/${job_name}/${build_number}/stop"
echo "Stopped Jenkins build: ${job_name} #${build_number}"
