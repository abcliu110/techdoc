#!/usr/bin/env bash
set -euo pipefail

credential_id="${1:?credential ID is required}"
credential_file="${2:?credential JSON file is required}"
jenkins_url="${JENKINS_URL:-http://127.0.0.1:30080}"

command -v kubectl >/dev/null || { echo 'kubectl is required' >&2; exit 1; }
command -v curl >/dev/null || { echo 'curl is required' >&2; exit 1; }
command -v jq >/dev/null || { echo 'jq is required' >&2; exit 1; }
test -s "$credential_file" || { echo 'credential file is missing or empty' >&2; exit 1; }
[ "$(stat -c '%a' "$credential_file")" = 600 ] || { echo 'credential file permission must be 600' >&2; exit 1; }

username="$(jq -er '.username | select(length > 0)' "$credential_file")"
password="$(jq -er '.password | select(length > 0)' "$credential_file")"
jenkins_password="$(kubectl get secret jenkins-admin -n jenkins \
  -o jsonpath='{.data.chart-admin-password}' | base64 --decode)"

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/jenkins-credential.XXXXXX")"
chmod 700 "$work_dir"
cleanup() {
  unset username password jenkins_password username_b64 password_b64 curl_userpwd
  rm -rf -- "$work_dir"
}
trap cleanup EXIT

curl_userpwd="admin:${jenkins_password}"
curl_userpwd="${curl_userpwd//\\/\\\\}"
curl_userpwd="${curl_userpwd//\"/\\\"}"
(umask 077; printf 'user = "%s"\n' "$curl_userpwd" > "$work_dir/curl.conf")

crumb_json="$(curl --config "$work_dir/curl.conf" --fail-with-body --silent --show-error \
  --cookie-jar "$work_dir/cookies" \
  "${jenkins_url}/crumbIssuer/api/json")"
crumb_field="$(jq -er '.crumbRequestField' <<<"$crumb_json")"
crumb_value="$(jq -er '.crumb' <<<"$crumb_json")"
credential_json="$(jq -n --arg id "$credential_id" --arg username "$username" --arg password "$password" \
  '{"": "0",credentials:{scope:"GLOBAL",id:$id,username:$username,password:$password,description:"Managed by K3s infrastructure bootstrap","$class":"com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"}}')"
credentials_api="${jenkins_url}/credentials/store/system/domain/_"
existing_count="$(curl --globoff --config "$work_dir/curl.conf" --cookie "$work_dir/cookies" \
  --cookie-jar "$work_dir/cookies" --fail-with-body --silent --show-error \
  "${credentials_api}/api/json?tree=credentials[id]" | \
  jq --arg id "$credential_id" '[.credentials[] | select(.id == $id)] | length')"
if [[ "$existing_count" == '0' ]]; then
  credential_endpoint="${credentials_api}/createCredentials"
else
  curl --globoff --config "$work_dir/curl.conf" --cookie "$work_dir/cookies" \
    --cookie-jar "$work_dir/cookies" --fail-with-body --silent --show-error \
    -H "${crumb_field}: ${crumb_value}" -X POST \
    "${credentials_api}/credential/${credential_id}/doDelete" >/dev/null
  credential_endpoint="${credentials_api}/createCredentials"
fi
curl --globoff --config "$work_dir/curl.conf" --cookie "$work_dir/cookies" \
  --cookie-jar "$work_dir/cookies" --fail-with-body --silent --show-error \
  -H "${crumb_field}: ${crumb_value}" \
  --data-urlencode "json=${credential_json}" "$credential_endpoint"
curl --globoff --config "$work_dir/curl.conf" --cookie "$work_dir/cookies" \
  --cookie-jar "$work_dir/cookies" --fail-with-body --silent --show-error \
  "${credentials_api}/api/json?tree=credentials[id]" | \
  jq -e --arg id "$credential_id" '.credentials[] | select(.id == $id)' >/dev/null
rm -f -- "$credential_file"
echo "Jenkins credential verified and source file deleted: ${credential_id}"
