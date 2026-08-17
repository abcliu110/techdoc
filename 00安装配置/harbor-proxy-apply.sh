#!/usr/bin/env bash
set -euo pipefail

values_file="/tmp/k3s-harbor-values.yaml"
rendered_file="/tmp/harbor-proxy-rendered.yaml"

test -r "$values_file" || { echo "Missing values file: $values_file" >&2; exit 1; }

helm template harbor harbor/harbor -n harbor --version 1.19.2 \
  -f "$values_file" > "$rendered_file"
kubectl apply --dry-run=server -f "$rendered_file" >/dev/null

helm upgrade --install harbor harbor/harbor \
  --namespace harbor \
  --version 1.19.2 \
  --values "$values_file" \
  --wait \
  --timeout 20m
kubectl rollout status deployment/harbor-core -n harbor --timeout=20m
kubectl get deployment/harbor-core -n harbor
rm -f -- "$rendered_file"
