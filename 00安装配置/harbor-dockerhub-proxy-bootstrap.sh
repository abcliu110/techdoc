#!/usr/bin/env bash
set -euo pipefail

# Configure an idempotent Harbor Docker Hub proxy-cache project. Credentials
# remain in the existing Kubernetes Secret and are never printed or persisted.

HARBOR_URL="${HARBOR_URL:-https://192.168.253.128:30083}"
HARBOR_REGISTRY_NAME="${HARBOR_REGISTRY_NAME:-docker-hub}"
HARBOR_PROXY_PROJECT="${HARBOR_PROXY_PROJECT:-dockerhub}"
HARBOR_INSECURE="${HARBOR_INSECURE:-true}"
HARBOR_TEST_IMAGE="${HARBOR_TEST_IMAGE:-eclipse-temurin:21-jre}"

command -v kubectl >/dev/null || { echo 'kubectl is required' >&2; exit 1; }
command -v curl >/dev/null || { echo 'curl is required' >&2; exit 1; }
command -v jq >/dev/null || { echo 'jq is required' >&2; exit 1; }

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/harbor-proxy.XXXXXX")"
chmod 700 "$work_dir"
cleanup() {
  unset harbor_password auth registry_payload project_payload
  rm -rf -- "$work_dir"
}
trap cleanup EXIT

harbor_password="$(kubectl get secret harbor-admin -n harbor \
  -o jsonpath='{.data.HARBOR_ADMIN_PASSWORD}' | base64 --decode)"
auth="$(printf 'admin:%s' "$harbor_password" | base64 -w0)"
unset harbor_password

(umask 077; printf 'header = "Authorization: Basic %s"\n' "$auth" > "$work_dir/curl.conf")
chmod 600 "$work_dir/curl.conf"
unset auth

curl_args=(--silent --show-error --fail-with-body --config "$work_dir/curl.conf")
if [[ "$HARBOR_INSECURE" == 'true' ]]; then
  curl_args+=(--insecure)
fi

api_get() {
  curl "${curl_args[@]}" "$1"
}

registry_json="$(api_get "${HARBOR_URL}/api/v2.0/registries")"
registry_id="$(jq -r --arg name "$HARBOR_REGISTRY_NAME" \
  '.[] | select(.name == $name) | .id' <<<"$registry_json" | head -n1)"

if [[ -z "$registry_id" ]]; then
  registry_payload="$(jq -n --arg name "$HARBOR_REGISTRY_NAME" \
    '{name:$name,url:"https://hub.docker.com",type:"docker-hub",insecure:false,credential:{type:"basic",access_key:"",access_secret:""},description:"Docker Hub proxy cache for K3s builds"}')"
  printf '%s' "$registry_payload" | curl "${curl_args[@]}" -X POST \
    -H 'Content-Type: application/json' --data-binary @- \
    "${HARBOR_URL}/api/v2.0/registries"
  registry_json="$(api_get "${HARBOR_URL}/api/v2.0/registries")"
  registry_id="$(jq -r --arg name "$HARBOR_REGISTRY_NAME" \
    '.[] | select(.name == $name) | .id' <<<"$registry_json" | head -n1)"
  [[ -n "$registry_id" ]] || { echo 'Docker Hub registry was not created' >&2; exit 1; }
  echo "Created Harbor registry: ${HARBOR_REGISTRY_NAME}"
else
  echo "Harbor registry already exists: ${HARBOR_REGISTRY_NAME}"
fi

project_json="$(api_get "${HARBOR_URL}/api/v2.0/projects?name=${HARBOR_PROXY_PROJECT}")"
project_id="$(jq -r '.[0].project_id // empty' <<<"$project_json")"
if [[ -z "$project_id" ]]; then
  project_payload="$(jq -n --arg name "$HARBOR_PROXY_PROJECT" --argjson registry_id "$registry_id" \
    '{project_name:$name,public:true,registry_id:$registry_id}')"
  printf '%s' "$project_payload" | curl "${curl_args[@]}" -X POST \
    -H 'Content-Type: application/json' --data-binary @- \
    "${HARBOR_URL}/api/v2.0/projects" >/dev/null
  project_json="$(api_get "${HARBOR_URL}/api/v2.0/projects?name=${HARBOR_PROXY_PROJECT}")"
  project_id="$(jq -r '.[0].project_id // empty' <<<"$project_json")"
  [[ -n "$project_id" ]] || { echo 'Docker Hub proxy project was not created' >&2; exit 1; }
  echo "Created Harbor proxy project: ${HARBOR_PROXY_PROJECT}"
else
  actual_registry_id="$(jq -r '.[0].registry_id // empty' <<<"$project_json")"
  [[ "$actual_registry_id" == "$registry_id" ]] || {
    echo "Project ${HARBOR_PROXY_PROJECT} exists but is not bound to ${HARBOR_REGISTRY_NAME}" >&2
    exit 1
  }
  echo "Harbor proxy project already exists: ${HARBOR_PROXY_PROJECT}"
fi

image_repository="${HARBOR_TEST_IMAGE%%:*}"
image_tag="${HARBOR_TEST_IMAGE##*:}"
case "$image_repository" in
  */*) proxy_repository="$image_repository" ;;
  *) proxy_repository="library/${image_repository}" ;;
esac
manifest_url="${HARBOR_URL}/v2/${HARBOR_PROXY_PROJECT}/${proxy_repository}/manifests/${image_tag}"
curl "${curl_args[@]}" -H 'Accept: application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.v2+json' \
  -o "$work_dir/manifest.json" "$manifest_url"
jq -e '.schemaVersion == 2' "$work_dir/manifest.json" >/dev/null
echo "Harbor Docker Hub proxy verified: ${HARBOR_PROXY_PROJECT}/${proxy_repository}:${image_tag}"
