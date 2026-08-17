#!/usr/bin/env bash
set -euo pipefail

registry='https://192.168.253.128:30083'
password="$(kubectl get secret harbor-admin -n harbor -o jsonpath='{.data.HARBOR_ADMIN_PASSWORD}' | base64 -d)"
trap 'unset password' EXIT

for repository in \
  nms4cloud-platform \
  nms4cloud-biz \
  nms4cloud-crm \
  nms4cloud-mq \
  nms4cloud-netty \
  nms4cloud-order \
  nms4cloud-payment \
  nms4cloud-pos11report; do
  printf '%s\n' "===${repository}==="
  curl -ksS -u "admin:${password}" \
    "${registry}/api/v2.0/projects/library/repositories/${repository}/artifacts?page=1&page_size=20" \
    | jq -r '.[] | (.digest + " tags=" + ([.tags[]?.name] | join(",")))'
done

printf '%s\n' '===report-repositories==='
curl -ksS -u "admin:${password}" \
  "${registry}/api/v2.0/projects/library/repositories?page=1&page_size=100" \
  | jq -r '.[] | select(.name | test("report"; "i")) | .name'
