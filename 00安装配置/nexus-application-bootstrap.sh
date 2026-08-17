#!/usr/bin/env bash
set -euo pipefail

# Configure Nexus application state after the Helm release is Ready.

NEXUS_URL="${NEXUS_URL:-http://127.0.0.1:30081}"
NEXUS_ADMIN_USER="${NEXUS_ADMIN_USER:-admin}"
NEXUS_DEPLOYER_USER="${NEXUS_DEPLOYER_USER:-nexus-deployer}"
NEXUS_DEPLOYER_PASSWORD="${NEXUS_DEPLOYER_PASSWORD:-}"
NEXUS_ACCEPT_EULA="${NEXUS_ACCEPT_EULA:-false}"
NEXUS_EULA_FILE="${NEXUS_EULA_FILE:-/tmp/nexus-eula.json}"
command -v curl >/dev/null || { echo 'curl is required' >&2; exit 1; }
command -v jq >/dev/null || { echo 'jq is required' >&2; exit 1; }
command -v kubectl >/dev/null || { echo 'kubectl is required' >&2; exit 1; }

if [[ -v NEXUS_ADMIN_PASSWORD ]]; then
  echo 'NEXUS_ADMIN_PASSWORD environment override is forbidden; unset it and use nexus/nexus-admin Secret' >&2
  exit 1
fi
NEXUS_ADMIN_PASSWORD="$(kubectl get secret nexus-admin -n nexus \
  -o jsonpath='{.data.password}' | base64 --decode)"
[ -n "$NEXUS_ADMIN_PASSWORD" ] || { echo 'nexus/nexus-admin password is empty' >&2; exit 1; }

case "$NEXUS_ADMIN_PASSWORD" in
  *$'\n'*|*$'\r'*) echo 'Nexus password must not contain a newline' >&2; exit 1 ;;
esac
auth_dir="$(mktemp -d "${TMPDIR:-/tmp}/nexus-auth.XXXXXX")"
chmod 700 "$auth_dir"
curl_userpwd="${NEXUS_ADMIN_USER}:${NEXUS_ADMIN_PASSWORD}"
curl_userpwd="${curl_userpwd//\\/\\\\}"
curl_userpwd="${curl_userpwd//\"/\\\"}"
(umask 077; printf 'user = "%s"\n' "$curl_userpwd" > "$auth_dir/curl.conf")
cleanup() {
  unset NEXUS_ADMIN_PASSWORD NEXUS_DEPLOYER_PASSWORD curl_userpwd user_payload role_payload user_json password_json
  rm -rf -- "$auth_dir"
}
trap cleanup EXIT

nexus_request() {
  curl --config "$auth_dir/curl.conf" --fail-with-body --silent --show-error \
    -H 'Accept: application/json' "$@"
}

authenticated_get_code() {
  curl --config "$auth_dir/curl.conf" --silent --output /dev/null \
    --write-out '%{http_code}' "$1"
}

authenticated_resource_exists() {
  local url="$1"
  local label="$2"
  local code
  code="$(authenticated_get_code "$url")"
  case "$code" in
    200) return 0 ;;
    404) return 1 ;;
    401|403|429)
      echo "Nexus authentication/authorization failed for ${label}, HTTP ${code}; stop without retrying" >&2
      exit 1
      ;;
    *)
      echo "Unexpected Nexus response for ${label}, HTTP ${code}; no mutation performed" >&2
      exit 1
      ;;
  esac
}

wait_for_nexus() {
  local attempt
  for attempt in $(seq 1 60); do
    if curl --fail --silent --show-error "${NEXUS_URL}/service/rest/v1/status" >/dev/null 2>&1; then
      nexus_request "${NEXUS_URL}/service/rest/v1/status" >/dev/null || {
        echo 'Nexus administrator authentication failed; stop without retrying to avoid account lockout' >&2
        exit 1
      }
      return 0
    fi
    sleep 5
  done
  echo 'Nexus did not become ready within 5 minutes' >&2
  exit 1
}

repository_exists() {
  local name="$1"
  nexus_request "${NEXUS_URL}/service/rest/v1/repositories" | \
    jq -e --arg name "$name" 'any(.[]; .name == $name)' >/dev/null
}

ensure_repository() {
  local name="$1"
  local endpoint="$2"
  local payload="$3"
  if repository_exists "$name"; then
    echo "Nexus repository already exists: ${name}"
    return 0
  fi
  printf '%s' "$payload" | nexus_request -X POST \
    -H 'Content-Type: application/json' \
    --data-binary @- "${NEXUS_URL}/service/rest/v1/repositories/${endpoint}"
  echo "Created Nexus repository: ${name}"
}

wait_for_nexus

eula_status="$(nexus_request "${NEXUS_URL}/service/rest/v1/system/eula")"
if ! jq -e '.accepted == true' >/dev/null <<<"$eula_status"; then
  [[ "$NEXUS_ACCEPT_EULA" == 'true' ]] || {
    echo 'Nexus CE EULA is not accepted; set NEXUS_ACCEPT_EULA=true only after explicit authorization' >&2
    exit 1
  }
  test -s "$NEXUS_EULA_FILE" || { echo "Nexus EULA payload is missing: $NEXUS_EULA_FILE" >&2; exit 1; }
  nexus_request -X POST -H 'Content-Type: application/json' \
    --data-binary "@${NEXUS_EULA_FILE}" \
    "${NEXUS_URL}/service/rest/v1/system/eula" >/dev/null
  eula_status="$(nexus_request "${NEXUS_URL}/service/rest/v1/system/eula")"
  jq -e '.accepted == true' >/dev/null <<<"$eula_status" || {
    echo 'Nexus CE EULA acceptance verification failed' >&2
    exit 1
  }
fi
unset eula_status
echo 'Nexus CE EULA accepted state verified'

ensure_repository 'maven-releases' 'maven/hosted' '{
  "name": "maven-releases",
  "online": true,
  "storage": {"blobStoreName": "default", "strictContentTypeValidation": true, "writePolicy": "ALLOW_ONCE"},
  "maven": {"versionPolicy": "RELEASE", "layoutPolicy": "STRICT", "contentDisposition": "INLINE"}
}'

ensure_repository 'maven-snapshots' 'maven/hosted' '{
  "name": "maven-snapshots",
  "online": true,
  "storage": {"blobStoreName": "default", "strictContentTypeValidation": true, "writePolicy": "ALLOW"},
  "maven": {"versionPolicy": "SNAPSHOT", "layoutPolicy": "STRICT", "contentDisposition": "INLINE"}
}'

ensure_repository 'maven-central' 'maven/proxy' '{
  "name": "maven-central",
  "online": true,
  "storage": {"blobStoreName": "default", "strictContentTypeValidation": true},
  "proxy": {"remoteUrl": "https://repo1.maven.org/maven2/", "contentMaxAge": 1440, "metadataMaxAge": 1440},
  "negativeCache": {"enabled": true, "timeToLive": 1440},
  "httpClient": {"blocked": false, "autoBlock": true},
  "maven": {"versionPolicy": "MIXED", "layoutPolicy": "STRICT", "contentDisposition": "INLINE"}
}'

ensure_repository 'maven-public' 'maven/group' '{
  "name": "maven-public",
  "online": true,
  "storage": {"blobStoreName": "default"},
  "group": {"memberNames": ["maven-releases", "maven-snapshots", "maven-central"]}
}'

role_payload=$(jq -n --arg id "${NEXUS_DEPLOYER_USER}" \
  '{id:$id,name:$id,description:"Maven deployment role",privileges:[
    "nx-repository-view-maven2-maven-releases-browse",
    "nx-repository-view-maven2-maven-releases-read",
    "nx-repository-view-maven2-maven-releases-add",
    "nx-repository-view-maven2-maven-releases-edit",
    "nx-repository-view-maven2-maven-snapshots-browse",
    "nx-repository-view-maven2-maven-snapshots-read",
    "nx-repository-view-maven2-maven-snapshots-add",
    "nx-repository-view-maven2-maven-snapshots-edit"
  ],roles:[]}')

if authenticated_resource_exists \
  "${NEXUS_URL}/service/rest/v1/security/roles/${NEXUS_DEPLOYER_USER}" \
  "role ${NEXUS_DEPLOYER_USER}"; then
  echo "Nexus role already exists: ${NEXUS_DEPLOYER_USER}"
else
  printf '%s' "$role_payload" | nexus_request -X POST \
    -H 'Content-Type: application/json' \
    --data-binary @- "${NEXUS_URL}/service/rest/v1/security/roles"
  echo "Created Nexus role: ${NEXUS_DEPLOYER_USER}"
fi

existing_user=$(nexus_request "${NEXUS_URL}/service/rest/v1/security/users" | \
  jq -r --arg user "${NEXUS_DEPLOYER_USER}" '.[] | select(.userId == $user) | .userId' | head -n 1)
if [[ "$existing_user" == "$NEXUS_DEPLOYER_USER" ]]; then
  echo "Nexus user already exists: ${NEXUS_DEPLOYER_USER}; use its existing Jenkins Credential"
else
  [[ -n "$NEXUS_DEPLOYER_PASSWORD" ]] || {
    echo 'NEXUS_DEPLOYER_PASSWORD is required only when creating the deployer user' >&2
    exit 1
  }
  user_json="$(printf '%s' "$NEXUS_DEPLOYER_USER" | jq -Rs .)"
  password_json="$(printf '%s' "$NEXUS_DEPLOYER_PASSWORD" | jq -Rs .)"
  user_payload="$(printf '{"userId":%s,"firstName":"CI","lastName":"Deployer","emailAddress":"ci@example.invalid","password":%s,"status":"active","roles":[%s]}' \
    "$user_json" "$password_json" "$user_json")"
  unset password_json
  printf '%s' "$user_payload" | nexus_request -X POST \
    -H 'Content-Type: application/json' \
    --data-binary @- "${NEXUS_URL}/service/rest/v1/security/users"
  echo "Created Nexus user: ${NEXUS_DEPLOYER_USER}"
fi

echo 'Nexus bootstrap completed. Store the deployer credential in Jenkins Credentials.'
