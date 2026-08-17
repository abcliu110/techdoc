#!/usr/bin/env bash
set -Eeuo pipefail

namespace="${NACOS_NAMESPACE:-nacos}"
base_url="${NACOS_URL:-http://127.0.0.1:30086}"

secret_value() {
  kubectl get secret "$2" -n "$1" -o jsonpath="{.data.$3}" | base64 -d
}

form_encode() {
  local LC_ALL=C
  local value="$1"
  local encoded=''
  local character hex index
  for ((index = 0; index < ${#value}; index++)); do
    character="${value:index:1}"
    case "$character" in
      [a-zA-Z0-9.~_-]) encoded+="$character" ;;
      *) printf -v hex '%%%02X' "'$character"; encoded+="$hex" ;;
    esac
  done
  printf '%s' "$encoded"
}

login() {
  local username="$1"
  local password="$2"
  printf 'username=%s&password=%s' "$(form_encode "$username")" "$(form_encode "$password")" | \
    curl -fsS -X POST "$base_url/v3/auth/user/login" \
      -H 'Content-Type: application/x-www-form-urlencoded' --data-binary @-
}

kubectl rollout status deployment/nacos -n "$namespace" --timeout=15m >/dev/null
target_username="$(secret_value "$namespace" nacos-admin username)"
target_password="$(secret_value "$namespace" nacos-admin password)"

verify_response=''
if verify_response="$(login "$target_username" "$target_password" 2>/dev/null)"; then
  verify_token="$(printf '%s' "$verify_response" | jq -r '.accessToken // .token // empty')"
else
  verify_token=''
fi
if [ -n "$verify_token" ]; then
  kubectl delete secret nacos-bootstrap-admin -n "$namespace" --ignore-not-found >/dev/null
  unset target_password verify_token verify_response
  echo 'Nacos administrator password already matches nacos-admin Secret'
  exit 0
fi

kubectl get secret nacos-bootstrap-admin -n "$namespace" >/dev/null 2>&1 || {
  echo 'Nacos target authentication failed and nacos-bootstrap-admin Secret is missing' >&2
  exit 1
}
current_username="$(secret_value "$namespace" nacos-bootstrap-admin username)"
current_password="$(secret_value "$namespace" nacos-bootstrap-admin password)"

if ! login_response="$(login "$current_username" "$current_password" 2>/dev/null)"; then
  create_response="$(printf 'password=%s' "$(form_encode "$target_password")" | \
    curl -fsS -X POST "$base_url/v3/auth/user/admin" \
      -H 'Content-Type: application/x-www-form-urlencoded' --data-binary @-)"
  jq -e '(.code == 0 or .code == 200) and .data.username == "nacos"' \
    >/dev/null <<<"$create_response" || {
      echo 'Nacos initial administrator creation failed' >&2
      exit 1
    }
  verify_response="$(login "$target_username" "$target_password")"
  verify_token="$(printf '%s' "$verify_response" | jq -r '.accessToken // .token // empty')"
  [ -n "$verify_token" ] || { echo 'Nacos initial administrator authentication failed' >&2; exit 1; }
  kubectl delete secret nacos-bootstrap-admin -n "$namespace" --ignore-not-found >/dev/null
  unset current_password target_password verify_token verify_response create_response
  echo 'Nacos initial administrator created from nacos-admin Secret'
  exit 0
fi
access_token="$(printf '%s' "$login_response" | jq -r '.accessToken // .token // empty')"
[ -n "$access_token" ] || { echo 'Nacos login response has no access token' >&2; exit 1; }

if [ "$current_password" != "$target_password" ]; then
  status="$(printf 'username=%s&newPassword=%s' \
    "$(form_encode "$target_username")" "$(form_encode "$target_password")" | \
    curl -sS -o /dev/null -w '%{http_code}' -X PUT "$base_url/v3/auth/user" \
      -H @<(printf 'Authorization: Bearer %s\n' "$access_token") \
      -H 'Content-Type: application/x-www-form-urlencoded' --data-binary @-)"
  [ "$status" = 200 ] || { echo "Nacos password update returned HTTP $status" >&2; exit 1; }
fi

verify_response="$(login "$target_username" "$target_password")"
verify_token="$(printf '%s' "$verify_response" | jq -r '.accessToken // .token // empty')"
[ -n "$verify_token" ] || { echo 'Nacos target Secret authentication failed' >&2; exit 1; }

kubectl delete secret nacos-bootstrap-admin -n "$namespace" --ignore-not-found >/dev/null
unset current_password target_password access_token verify_token login_response verify_response
echo 'Nacos administrator password synchronized from nacos-admin Secret'
