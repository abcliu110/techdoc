#!/usr/bin/env bash
set -euo pipefail

token="$(kubectl get secret jenkins-admin -n jenkins -o jsonpath='{.data.chart-admin-password}' | base64 -d)"
trap 'unset token' EXIT
base='http://127.0.0.1:30080'

curl --globoff -fsS -u "admin:${token}" \
  "${base}/job/build-nms4cloud-images/job/jujiao_master/config.xml" \
  | grep -E -i -C 5 'latest|destination|image.tag|image.ref|harbor|jenkinsfile'
