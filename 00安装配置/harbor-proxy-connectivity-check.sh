#!/usr/bin/env bash
set -euo pipefail

proxy_url="http://192.168.253.1:7897"
docker_hub_url="https://index.docker.io/v2/"

direct_status="$(curl --connect-timeout 10 --max-time 20 --silent --show-error \
  --output /dev/null --write-out '%{http_code}' "$docker_hub_url" || true)"
proxy_status="$(curl --connect-timeout 10 --max-time 20 --silent --show-error \
  --proxy "$proxy_url" --output /dev/null --write-out '%{http_code}' "$docker_hub_url" || true)"

printf 'direct_status=%s\n' "$direct_status"
printf 'proxy_status=%s\n' "$proxy_status"
[[ "$proxy_status" == '401' ]]
