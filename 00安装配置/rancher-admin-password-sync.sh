#!/usr/bin/env bash
set -Eeuo pipefail

namespace="${RANCHER_NAMESPACE:-cattle-system}"
rancher_url="${RANCHER_URL:-https://127.0.0.1:30085}"

secret_value() {
  kubectl get secret "$2" -n "$1" -o jsonpath="{.data.$3}" | base64 -d
}

json_string() {
  printf '%s' "$1" | jq -Rs .
}

login() {
  local username="$1"
  local password="$2"
  local payload
  payload="$(printf '{"username":%s,"password":%s,"responseType":"json"}' \
    "$(json_string "$username")" "$(json_string "$password")")"
  printf '%s' "$payload" | curl -kfsS -X POST \
    "$rancher_url/v3-public/localProviders/local?action=login" \
    -H 'Content-Type: application/json' --data-binary @-
}

kubectl rollout status deployment/rancher -n "$namespace" --timeout=15m >/dev/null
target_username="$(secret_value "$namespace" rancher-admin username)"
target_password="$(secret_value "$namespace" rancher-admin password)"

verify_response=''
if verify_response="$(login "$target_username" "$target_password" 2>/dev/null)"; then
  verify_token="$(printf '%s' "$verify_response" | jq -r '.token // empty')"
else
  verify_token=''
fi
if [ -n "$verify_token" ]; then
  kubectl delete secret bootstrap-secret -n "$namespace" --ignore-not-found >/dev/null
  unset target_password verify_token verify_response
  echo 'Rancher administrator password already matches rancher-admin Secret'
  exit 0
fi

bootstrap_password="$(secret_value "$namespace" bootstrap-secret bootstrapPassword)"
login_response="$(login "$target_username" "$bootstrap_password")"
access_token="$(printf '%s' "$login_response" | jq -r '.token // empty')"
[ -n "$access_token" ] || { echo 'Rancher bootstrap login returned no API token' >&2; exit 1; }

payload="$(printf '{"currentPassword":%s,"newPassword":%s}' \
  "$(json_string "$bootstrap_password")" "$(json_string "$target_password")")"
status="$(printf '%s' "$payload" | curl -ksS -o /dev/null -w '%{http_code}' \
  -X POST "$rancher_url/v3/users?action=changepassword" \
  -H @<(printf 'Authorization: Bearer %s\n' "$access_token") \
  -H 'Content-Type: application/json' --data-binary @-)"
[ "$status" = 200 ] || [ "$status" = 204 ] || { echo "Rancher password update returned HTTP $status" >&2; exit 1; }

verify_response="$(login "$target_username" "$target_password")"
verify_token="$(printf '%s' "$verify_response" | jq -r '.token // empty')"
[ -n "$verify_token" ] || { echo 'Rancher target Secret authentication failed' >&2; exit 1; }

kubectl delete secret bootstrap-secret -n "$namespace" --ignore-not-found >/dev/null
unset bootstrap_password target_password access_token verify_token payload login_response verify_response
echo 'Rancher administrator password synchronized from rancher-admin Secret'
