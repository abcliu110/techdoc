#!/usr/bin/env bash
set -Eeuo pipefail

jenkins_namespace="${JENKINS_NAMESPACE:-jenkins}"
gitea_namespace="${GITEA_NAMESPACE:-gitea}"
harbor_namespace="${HARBOR_NAMESPACE:-harbor}"
nexus_namespace="${NEXUS_NAMESPACE:-nexus}"
nacos_namespace="${NACOS_NAMESPACE:-nacos}"
mysql_namespace="${MYSQL_NAMESPACE:-mysql}"
rancher_namespace="${RANCHER_NAMESPACE:-cattle-system}"
platform_admin_password="${PLATFORM_ADMIN_PASSWORD:-St11338st11338}"

command -v kubectl >/dev/null || { echo 'kubectl is required' >&2; exit 1; }
command -v openssl >/dev/null || { echo 'openssl is required' >&2; exit 1; }
command -v helm >/dev/null || { echo 'helm is required' >&2; exit 1; }

secret_has_keys() {
  local namespace="$1"
  local secret="$2"
  shift 2
  local key
  for key in "$@"; do
    kubectl get secret "$secret" -n "$namespace" \
      -o go-template="{{if index .data \"$key\"}}ok{{end}}" | grep -qx ok || return 1
  done
}

state_exists() {
  local app="$1"
  local namespace="$2"
  case "$app" in
    jenkins)
      helm status jenkins -n "$namespace" >/dev/null 2>&1 || \
        kubectl get pvc jenkins -n "$namespace" >/dev/null 2>&1
      ;;
    gitea)
      helm status gitea -n "$namespace" >/dev/null 2>&1 || \
        kubectl get pvc gitea-shared-storage -n "$namespace" >/dev/null 2>&1
      ;;
    harbor)
      helm status harbor -n "$namespace" >/dev/null 2>&1 || \
        kubectl get pvc -n "$namespace" -l release=harbor -o name | grep -q .
      ;;
    nexus)
      helm status nexus -n "$namespace" >/dev/null 2>&1 || \
        kubectl get pvc -n "$namespace" -l app.kubernetes.io/instance=nexus -o name | grep -q .
      ;;
    nacos) kubectl get pvc nacos-data -n "$namespace" >/dev/null 2>&1 ;;
    mysql) kubectl get pvc mysql-data -n "$namespace" >/dev/null 2>&1 ;;
    rancher) helm status rancher -n "$namespace" >/dev/null 2>&1 ;;
  esac
}

require_fresh_state() {
  local app="$1"
  local namespace="$2"
  local secret="$3"
  if state_exists "$app" "$namespace"; then
    echo "$namespace/$secret is missing but $app state exists; back up and reinstall $app" >&2
    exit 1
  fi
}

ensure_platform_admin_password() {
  if [ -z "$platform_admin_password" ]; then
    read -rsp 'Platform administrator password: ' platform_admin_password; echo
    read -rsp 'Confirm platform administrator password: ' platform_admin_password_confirmation; echo
    [ "$platform_admin_password" = "$platform_admin_password_confirmation" ] || {
      unset platform_admin_password platform_admin_password_confirmation
      echo 'Platform administrator passwords do not match' >&2
      exit 1
    }
    unset platform_admin_password_confirmation
  fi

  if (( ${#platform_admin_password} < 12 )) || [[ ! "$platform_admin_password" =~ [A-Z] ]] || \
     [[ ! "$platform_admin_password" =~ [a-z] ]] || [[ ! "$platform_admin_password" =~ [0-9] ]]; then
    echo 'PLATFORM_ADMIN_PASSWORD must be at least 12 characters and include upper/lowercase letters and a digit' >&2
    exit 1
  fi
}

secret_data() {
  kubectl get secret "$2" -n "$1" -o "jsonpath={.data.$3}"
}

require_unified_admin_password() {
  local namespace="$1"
  local secret="$2"
  local key="$3"
  local actual
  actual="$(secret_data "$namespace" "$secret" "$key")"
  [ -n "$admin_password_reference" ] && [ -n "$actual" ] && \
    [ "$actual" = "$admin_password_reference" ] || {
    echo "$namespace/$secret key $key does not match the unified platform administrator password" >&2
    exit 1
  }
}

for namespace in \
  "$jenkins_namespace" "$gitea_namespace" "$harbor_namespace" "$nexus_namespace" \
  "$nacos_namespace" "$mysql_namespace" "$rancher_namespace"; do
  kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f - >/dev/null
done

namespace="$jenkins_namespace"
if kubectl get secret jenkins-admin -n "$namespace" >/dev/null 2>&1; then
  secret_has_keys "$namespace" jenkins-admin chart-admin-username chart-admin-password || {
    echo 'jenkins-admin has a missing or empty required key' >&2; exit 1;
  }
else
  require_fresh_state jenkins "$namespace" jenkins-admin
  ensure_platform_admin_password
  printf 'chart-admin-username=admin\nchart-admin-password=%s\n' "$platform_admin_password" | \
    kubectl create secret generic jenkins-admin -n "$namespace" --from-env-file=/dev/stdin >/dev/null
fi

namespace="$gitea_namespace"
if kubectl get secret gitea-admin -n "$namespace" >/dev/null 2>&1; then
  secret_has_keys "$namespace" gitea-admin username password || {
    echo 'gitea-admin has a missing or empty required key' >&2; exit 1;
  }
else
  require_fresh_state gitea "$namespace" gitea-admin
  ensure_platform_admin_password
  printf 'username=admin\npassword=%s\n' "$platform_admin_password" | \
    kubectl create secret generic gitea-admin -n "$namespace" --from-env-file=/dev/stdin >/dev/null
fi

namespace="$harbor_namespace"
if kubectl get secret harbor-admin -n "$namespace" >/dev/null 2>&1; then
  secret_has_keys "$namespace" harbor-admin HARBOR_ADMIN_PASSWORD || {
    echo 'harbor-admin has a missing or empty required key' >&2; exit 1;
  }
else
  require_fresh_state harbor "$namespace" harbor-admin
  ensure_platform_admin_password
  printf 'HARBOR_ADMIN_PASSWORD=%s\n' "$platform_admin_password" | \
    kubectl create secret generic harbor-admin -n "$namespace" --from-env-file=/dev/stdin >/dev/null
fi

namespace="$nexus_namespace"
if kubectl get secret nexus-admin -n "$namespace" >/dev/null 2>&1; then
  secret_has_keys "$namespace" nexus-admin password || {
    echo 'nexus-admin has a missing or empty password key' >&2; exit 1;
  }
else
  require_fresh_state nexus "$namespace" nexus-admin
  ensure_platform_admin_password
  printf 'password=%s\n' "$platform_admin_password" | \
    kubectl create secret generic nexus-admin -n "$namespace" --from-env-file=/dev/stdin >/dev/null
fi

namespace="$nacos_namespace"
if kubectl get secret nacos-auth -n "$namespace" >/dev/null 2>&1; then
  secret_has_keys "$namespace" nacos-auth NACOS_AUTH_TOKEN NACOS_AUTH_IDENTITY_KEY NACOS_AUTH_IDENTITY_VALUE || {
    echo 'nacos-auth has a missing or empty required key' >&2; exit 1;
  }
else
  require_fresh_state nacos "$namespace" nacos-auth
  token="$(openssl rand -base64 32)"
  identity="$(openssl rand -hex 16)"
  printf 'NACOS_AUTH_TOKEN=%s\nNACOS_AUTH_IDENTITY_KEY=nacos-server\nNACOS_AUTH_IDENTITY_VALUE=%s\n' \
    "$token" "$identity" | \
    kubectl create secret generic nacos-auth -n "$namespace" --from-env-file=/dev/stdin >/dev/null
  unset token identity
fi

if kubectl get secret nacos-admin -n "$namespace" >/dev/null 2>&1; then
  secret_has_keys "$namespace" nacos-admin username password || {
    echo 'nacos-admin has a missing or empty required key' >&2; exit 1;
  }
else
  require_fresh_state nacos "$namespace" nacos-admin
  ensure_platform_admin_password
  printf 'username=nacos\npassword=%s\n' "$platform_admin_password" | \
    kubectl create secret generic nacos-admin -n "$namespace" --from-env-file=/dev/stdin >/dev/null
fi

if kubectl get secret nacos-bootstrap-admin -n "$namespace" >/dev/null 2>&1; then
  secret_has_keys "$namespace" nacos-bootstrap-admin username password || {
    echo 'nacos-bootstrap-admin has a missing or empty required key' >&2; exit 1;
  }
else
  if ! state_exists nacos "$namespace"; then
    printf 'username=nacos\npassword=nacos\n' | \
      kubectl create secret generic nacos-bootstrap-admin -n "$namespace" --from-env-file=/dev/stdin >/dev/null
  fi
fi

namespace="$mysql_namespace"
if kubectl get secret mysql-auth -n "$namespace" >/dev/null 2>&1; then
  secret_has_keys "$namespace" mysql-auth MYSQL_ROOT_PASSWORD MYSQL_PASSWORD || {
    echo 'mysql-auth has a missing or empty required key' >&2; exit 1;
  }
else
  require_fresh_state mysql "$namespace" mysql-auth
  ensure_platform_admin_password
  printf 'MYSQL_ROOT_PASSWORD=%s\nMYSQL_PASSWORD=%s\n' "$platform_admin_password" "$platform_admin_password" | \
    kubectl create secret generic mysql-auth -n "$namespace" --from-env-file=/dev/stdin >/dev/null
fi

namespace="$rancher_namespace"
if kubectl get secret rancher-admin -n "$namespace" >/dev/null 2>&1; then
  secret_has_keys "$namespace" rancher-admin username password || {
    echo 'rancher-admin has a missing or empty required key' >&2; exit 1;
  }
else
  require_fresh_state rancher "$namespace" rancher-admin
  ensure_platform_admin_password
  printf 'username=admin\npassword=%s\n' "$platform_admin_password" | \
    kubectl create secret generic rancher-admin -n "$namespace" --from-env-file=/dev/stdin >/dev/null
fi

admin_password_reference="$(secret_data "$jenkins_namespace" jenkins-admin chart-admin-password)"
require_unified_admin_password "$harbor_namespace" harbor-admin HARBOR_ADMIN_PASSWORD
require_unified_admin_password "$gitea_namespace" gitea-admin password
require_unified_admin_password "$nexus_namespace" nexus-admin password
require_unified_admin_password "$nacos_namespace" nacos-admin password
require_unified_admin_password "$mysql_namespace" mysql-auth MYSQL_ROOT_PASSWORD
require_unified_admin_password "$mysql_namespace" mysql-auth MYSQL_PASSWORD
require_unified_admin_password "$rancher_namespace" rancher-admin password

unset platform_admin_password admin_password_reference actual

echo 'All required platform Secrets exist, contain non-empty required keys, and use one administrator password'
