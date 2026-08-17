#!/usr/bin/env bash
set -euo pipefail

# Configure Harbor application state after the Helm release is Ready.
# Passwords and robot tokens are never written to this repository.

HARBOR_URL="${HARBOR_URL:-https://192.168.253.128:30083}"
HARBOR_ADMIN_USER="${HARBOR_ADMIN_USER:-admin}"
HARBOR_PROJECT="${HARBOR_PROJECT:-library}"
HARBOR_ROBOT_NAME="${HARBOR_ROBOT_NAME:-ci-publisher-v8}"
RETENTION_FILE="${RETENTION_FILE:-$(dirname "$0")/harbor-retention-library.json}"
HARBOR_ROBOT_CREDENTIAL_FILE="${HARBOR_ROBOT_CREDENTIAL_FILE:-/tmp/harbor-robot-credential.json}"
JENKINS_CREDENTIAL_UPSERT="${JENKINS_CREDENTIAL_UPSERT:-/tmp/jenkins-credential-upsert.sh}"
auth_dir=""
token_file=""
HARBOR_CURL_ARGS=()
if [[ "${HARBOR_INSECURE:-false}" == 'true' ]]; then
  HARBOR_CURL_ARGS+=('--insecure')
fi

command -v curl >/dev/null || { echo 'curl is required' >&2; exit 1; }
command -v jq >/dev/null || { echo 'jq is required' >&2; exit 1; }
[[ -f "$RETENTION_FILE" ]] || { echo "Retention file not found: $RETENTION_FILE" >&2; exit 1; }
[[ -x "$JENKINS_CREDENTIAL_UPSERT" ]] || { echo "Jenkins credential helper is not executable: $JENKINS_CREDENTIAL_UPSERT" >&2; exit 1; }

HARBOR_ADMIN_PASSWORD="$(kubectl get secret harbor-admin -n harbor \
  -o jsonpath='{.data.HARBOR_ADMIN_PASSWORD}' | base64 --decode)"

case "$HARBOR_ADMIN_PASSWORD" in
  *$'\n'*|*$'\r'*) echo 'Harbor password must not contain a newline' >&2; exit 1 ;;
esac
auth_dir="$(mktemp -d "${TMPDIR:-/tmp}/harbor-auth.XXXXXX")"
chmod 700 "$auth_dir"
curl_userpwd="${HARBOR_ADMIN_USER}:${HARBOR_ADMIN_PASSWORD}"
curl_userpwd="${curl_userpwd//\\/\\\\}"
curl_userpwd="${curl_userpwd//\"/\\\"}"
(umask 077; printf 'user = "%s"\n' "$curl_userpwd" > "$auth_dir/curl.conf")

cleanup() {
  unset HARBOR_ADMIN_PASSWORD curl_userpwd robot_payload robot_response robot_username robot_secret retention_payload robots
  [[ -z "$token_file" ]] || rm -f -- "$token_file"
  [[ -z "$auth_dir" ]] || rm -rf -- "$auth_dir"
}
trap cleanup EXIT

harbor_request() {
  curl "${HARBOR_CURL_ARGS[@]}" --config "$auth_dir/curl.conf" \
    --fail-with-body --silent --show-error --retry 3 \
    -H 'Accept: application/json' "$@"
}

verify_robot_registry() {
  local username="$1" secret="$2"
  local repo="${HARBOR_PROJECT}/sop-gate-check" tag="20260811"
  local registry_dir config_file config_digest upload_location manifest_file
  registry_dir="$auth_dir/registry"
  mkdir -m 700 "$registry_dir"
  config_file="$registry_dir/config.json"
  printf '{"architecture":"amd64","os":"linux","rootfs":{"type":"layers","diff_ids":[]},"config":{}}' > "$config_file"
  config_digest="sha256:$(sha256sum "$config_file" | awk '{print $1}')"
  (umask 077; printf 'user = "%s:%s"\n' "$username" "$secret" > "$registry_dir/curl.conf")
  curl "${HARBOR_CURL_ARGS[@]}" --config "$registry_dir/curl.conf" --fail --silent --show-error \
    -D "$registry_dir/headers" -o /dev/null -X POST "${HARBOR_URL}/v2/${repo}/blobs/uploads/"
  upload_location="$(awk 'BEGIN{IGNORECASE=1} /^Location:/{gsub("\\r",""); print $2}' "$registry_dir/headers" | tail -n1)"
  [[ -n "$upload_location" ]] || { echo 'Harbor registry did not return a blob upload location' >&2; exit 1; }
  [[ "$upload_location" == http* ]] || upload_location="${HARBOR_URL}${upload_location}"
  curl "${HARBOR_CURL_ARGS[@]}" --config "$registry_dir/curl.conf" --fail --silent --show-error \
    -X PUT -H 'Content-Type: application/octet-stream' --data-binary "@${config_file}" \
    "${upload_location}&digest=${config_digest}" >/dev/null
  manifest_file="$registry_dir/manifest.json"
  jq -n --arg digest "$config_digest" --argjson size "$(stat -c '%s' "$config_file")" \
    '{schemaVersion:2,mediaType:"application/vnd.oci.image.manifest.v1+json",config:{mediaType:"application/vnd.oci.image.config.v1+json",digest:$digest,size:$size},layers:[]}' \
    > "$manifest_file"
  curl "${HARBOR_CURL_ARGS[@]}" --config "$registry_dir/curl.conf" --fail --silent --show-error \
    -X PUT -H 'Content-Type: application/vnd.oci.image.manifest.v1+json' \
    --data-binary "@${manifest_file}" "${HARBOR_URL}/v2/${repo}/manifests/${tag}" >/dev/null
  curl "${HARBOR_CURL_ARGS[@]}" --config "$registry_dir/curl.conf" --fail --silent --show-error \
    -H 'Accept: application/vnd.oci.image.manifest.v1+json' \
    "${HARBOR_URL}/v2/${repo}/manifests/${tag}" | jq -e '.schemaVersion == 2' >/dev/null
  echo "Harbor robot push and query verified: ${repo}:${tag}"
}

project_id=$(harbor_request --get "${HARBOR_URL}/api/v2.0/projects" \
  --data-urlencode "project_name=${HARBOR_PROJECT}" | jq -r '.[0].project_id // empty')

if [[ -z "$project_id" ]]; then
  printf '%s' "$(jq -n --arg name "$HARBOR_PROJECT" '{project_name:$name,public:false}')" | \
    harbor_request -X POST -H 'Content-Type: application/json' --data-binary @- \
      "${HARBOR_URL}/api/v2.0/projects" >/dev/null
  project_id=$(harbor_request --get "${HARBOR_URL}/api/v2.0/projects" \
    --data-urlencode "project_name=${HARBOR_PROJECT}" | jq -r '.[0].project_id // empty')
  [[ -n "$project_id" ]] || { echo 'Harbor project creation did not return a project ID' >&2; exit 1; }
  echo "Created Harbor project: ${HARBOR_PROJECT} (${project_id})"
else
  echo "Harbor project already exists: ${HARBOR_PROJECT} (${project_id})"
fi

full_robot_name="robot\$${HARBOR_PROJECT}+${HARBOR_ROBOT_NAME}"
robot_list_file="$auth_dir/robots.json"
robot_list_code="$(curl "${HARBOR_CURL_ARGS[@]}" --config "$auth_dir/curl.conf" \
  --silent --show-error --output "$robot_list_file" --write-out '%{http_code}' --get \
  "${HARBOR_URL}/api/v2.0/robots" --data-urlencode "q=Level=project,ProjectID=${project_id}" --data-urlencode 'page=1' \
  --data-urlencode 'page_size=100')"
if [[ "$robot_list_code" != '200' ]]; then
  echo "Harbor robot query failed, HTTP ${robot_list_code}:" >&2
  cat "$robot_list_file" >&2
  exit 1
fi
robots="$(<"$robot_list_file")"
existing_robot_id="$(jq -r --arg name "$HARBOR_ROBOT_NAME" --arg full "$full_robot_name" \
  '.[] | select(.name == $name or .name == $full) | .id' <<<"$robots" | head -n1)"
if [[ "${HARBOR_PRUNE_FAILED_ROBOTS:-false}" == 'true' && -n "$existing_robot_id" ]]; then
  while read -r stale_robot_id; do
    [[ -n "$stale_robot_id" ]] || continue
    harbor_request -X DELETE "${HARBOR_URL}/api/v2.0/robots/${stale_robot_id}" >/dev/null
    echo "Deleted failed Harbor robot: ${stale_robot_id}"
  done < <(jq -r --arg prefix "robot\$${HARBOR_PROJECT}+ci-publisher" --argjson keep "$existing_robot_id" \
    '.[] | select((.name | startswith($prefix)) and .id != $keep) | .id' <<<"$robots")
fi
if [[ -n "$existing_robot_id" && "${HARBOR_ROTATE_EXISTING_ROBOT:-false}" == 'true' ]]; then
  echo "Rotating Harbor robot ID ${existing_robot_id}: ${HARBOR_ROBOT_NAME}"
  robot_response="$(printf '{}' | harbor_request -X PATCH \
    -H 'Content-Type: application/json' --data-binary @- \
    "${HARBOR_URL}/api/v2.0/robots/${existing_robot_id}")"
  robot_secret="$(jq -r '.secret // empty' <<<"$robot_response")"
  [[ -n "$robot_secret" ]] || { echo 'Harbor robot rotation did not return a secret' >&2; exit 1; }
  token_file="$HARBOR_ROBOT_CREDENTIAL_FILE"
  (umask 077; jq -n --arg username "$full_robot_name" --arg password "$robot_secret" \
    '{username:$username,password:$password}' > "$token_file")
  chmod 600 "$token_file"
  "$JENKINS_CREDENTIAL_UPSERT" harbor-robot "$token_file"
  token_file=""
  echo "Rotated Harbor robot and updated Jenkins credential: ${HARBOR_ROBOT_NAME}"
fi
if jq -e --arg name "$HARBOR_ROBOT_NAME" --arg full "$full_robot_name" \
  '.[] | select(.name == $name or .name == $full)' <<<"$robots" >/dev/null; then
  echo "Harbor robot already exists: ${HARBOR_ROBOT_NAME}; token was not changed"
else
  robot_payload=$(jq -n \
    --arg name "$HARBOR_ROBOT_NAME" \
    --arg namespace "$HARBOR_PROJECT" \
    '{name:$name,description:"CI image publisher and latest-artifact cleanup",duration:-1,level:"project",permissions:[{kind:"project",namespace:$namespace,access:[{resource:"repository",action:"push"},{resource:"repository",action:"pull"},{resource:"artifact",action:"list"},{resource:"artifact",action:"read"},{resource:"artifact",action:"delete"}]}]}')
  robot_response=$(printf '%s' "$robot_payload" | harbor_request -X POST \
    -H 'Content-Type: application/json' --data-binary @- \
    "${HARBOR_URL}/api/v2.0/robots")
  robot_username=$(jq -r '.name // empty' <<<"$robot_response")
  robot_secret=$(jq -r '.secret // empty' <<<"$robot_response")
  [[ -n "$robot_username" ]] || { echo 'Harbor robot creation did not return a username' >&2; exit 1; }
  [[ -n "$robot_secret" ]] || { echo 'Harbor robot creation did not return a secret' >&2; exit 1; }
  token_file="$HARBOR_ROBOT_CREDENTIAL_FILE"
  (umask 077; jq -n --arg username "$robot_username" --arg password "$robot_secret" \
    '{username:$username,password:$password}' > "$token_file")
  chmod 600 "$token_file"
  echo "Created Harbor robot username: ${robot_username}"
  echo "Robot credential was written to ${token_file} for automated Jenkins import."
  verify_robot_registry "$robot_username" "$robot_secret"
  "$JENKINS_CREDENTIAL_UPSERT" harbor-robot "$token_file"
  token_file=""
fi

retention_payload=$(jq --argjson project_id "$project_id" '.scope.ref = $project_id' "$RETENTION_FILE")
retention_id=$(harbor_request "${HARBOR_URL}/api/v2.0/projects/${project_id}" | jq -r '.metadata.retention_id // 0')
if [[ "$retention_id" == '0' || -z "$retention_id" ]]; then
  printf '%s' "$retention_payload" | harbor_request -X POST \
    -H 'Content-Type: application/json' --data-binary @- \
    "${HARBOR_URL}/api/v2.0/retentions"
  echo "Created Harbor retention policy for project: ${HARBOR_PROJECT}"
else
  printf '%s' "$retention_payload" | harbor_request -X PUT \
    -H 'Content-Type: application/json' --data-binary @- \
    "${HARBOR_URL}/api/v2.0/retentions/${retention_id}"
  echo "Updated Harbor retention policy ${retention_id} for project: ${HARBOR_PROJECT}"
fi

echo 'Harbor bootstrap completed; Jenkins credential and temporary-file gates passed for any newly created robot.'
