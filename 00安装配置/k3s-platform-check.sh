#!/usr/bin/env bash
set -Eeuo pipefail

export KUBECONFIG="${KUBECONFIG:-/home/lgy/.kube/config}"
mode="${1:-verify}"
failures=0

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

check_command() {
  command -v "$1" >/dev/null 2>&1 && pass "$1 is installed" || fail "$1 is missing"
}

check_release() {
  release="$1"
  namespace="$2"
  expected_chart="$3"
  record="$(helm list -n "$namespace" --filter "^${release}$" -o json 2>/dev/null || true)"
  if [ -z "$record" ] || [ "$record" = "[]" ]; then
    fail "$namespace/$release release is missing"
    return
  fi
  status="$(printf '%s\n' "$record" | jq -r '.[0].status')"
  chart="$(printf '%s\n' "$record" | jq -r '.[0].chart')"
  [ "$status" = "deployed" ] && pass "$namespace/$release is deployed" || fail "$namespace/$release status is $status"
  [ "$chart" = "$expected_chart" ] && pass "$namespace/$release chart is $expected_chart" || fail "$namespace/$release chart is $chart, expected $expected_chart"
}

check_secret_keys() {
  namespace="$1"
  secret="$2"
  shift 2
  if ! kubectl get secret "$secret" -n "$namespace" -o name >/dev/null 2>&1; then
    fail "$namespace/$secret Secret is missing"
    return
  fi

  for key in "$@"; do
    kubectl get secret "$secret" -n "$namespace" \
      -o go-template="{{if index .data \"$key\"}}ok{{end}}" | grep -qx ok \
      && pass "$namespace/$secret contains non-empty key $key" \
      || fail "$namespace/$secret has a missing or empty key $key"
  done
}

secret_data() {
  kubectl get secret "$2" -n "$1" -o "jsonpath={.data.$3}" 2>/dev/null || true
}

check_unified_admin_password() {
  namespace="$1"
  secret="$2"
  key="$3"
  actual="$(secret_data "$namespace" "$secret" "$key")"
  [ -n "$admin_password_reference" ] && [ "$actual" = "$admin_password_reference" ] \
    && pass "$namespace/$secret key $key matches the unified administrator password" \
    || fail "$namespace/$secret key $key does not match the unified administrator password"
}

check_command kubectl
check_command helm
check_command jq

kubectl wait --for=condition=Ready node --all --timeout=30s >/dev/null 2>&1 \
  && pass "all nodes are Ready" || fail "a node is not Ready"

kubectl get pods -A
kubectl get pvc -A
kubectl top node || fail "node metrics are unavailable"
storage_path=/var/lib/rancher/k3s/storage
[ -d "$storage_path" ] || storage_path=/var/lib/rancher/k3s
df -h "$storage_path"

non_running_pods="$(kubectl get pods -A -o json | jq '[.items[] | select(.status.phase != "Running" and .status.phase != "Succeeded")] | length')"
[ "$non_running_pods" -eq 0 ] && pass "all pods are Running or Succeeded" || fail "$non_running_pods pods are not Running or Succeeded"

unbound_pvcs="$(kubectl get pvc -A -o json | jq '[.items[] | select(.status.phase != "Bound")] | length')"
[ "$unbound_pvcs" -eq 0 ] && pass "all PVCs are Bound" || fail "$unbound_pvcs PVCs are not Bound"

if [ "$mode" = "preflight" ]; then
  [ "$failures" -eq 0 ] || exit 1
  exit 0
fi

check_release jenkins jenkins jenkins-5.9.53
check_release gitea gitea gitea-12.7.0
check_release nexus nexus nexus3-5.24.1
check_release harbor harbor harbor-1.19.2
check_release rancher cattle-system rancher-2.15.0

check_secret_keys jenkins jenkins-admin chart-admin-username chart-admin-password
check_secret_keys gitea gitea-admin username password
check_secret_keys harbor harbor-admin HARBOR_ADMIN_PASSWORD
check_secret_keys nexus nexus-admin password
check_secret_keys nacos nacos-auth NACOS_AUTH_TOKEN NACOS_AUTH_IDENTITY_KEY NACOS_AUTH_IDENTITY_VALUE
check_secret_keys nacos nacos-admin username password
check_secret_keys mysql mysql-auth MYSQL_ROOT_PASSWORD MYSQL_PASSWORD
check_secret_keys cattle-system rancher-admin username password

admin_password_reference="$(secret_data jenkins jenkins-admin chart-admin-password)"
check_unified_admin_password harbor harbor-admin HARBOR_ADMIN_PASSWORD
check_unified_admin_password gitea gitea-admin password
check_unified_admin_password nexus nexus-admin password
check_unified_admin_password nacos nacos-admin password
check_unified_admin_password mysql mysql-auth MYSQL_ROOT_PASSWORD
check_unified_admin_password mysql mysql-auth MYSQL_PASSWORD
check_unified_admin_password cattle-system rancher-admin password
unset admin_password_reference actual

not_ready_running_pods="$(kubectl get pods -A -o json | jq '[
  .items[]
  | select(.status.phase == "Running")
  | select(any(.status.conditions[]?; .type == "Ready" and .status == "True") | not)
] | length')"
[ "$not_ready_running_pods" -eq 0 ] \
  && pass "all Running pods are Ready" \
  || fail "$not_ready_running_pods Running pods are not Ready"

[ "$failures" -eq 0 ] || exit 1
echo "Platform resource verification passed; interactive authentication is still required"
