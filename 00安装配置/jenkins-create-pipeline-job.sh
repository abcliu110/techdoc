#!/usr/bin/env bash
set -euo pipefail

job_name="${1:?job name is required}"
pipeline_file="${2:?pipeline file is required}"
jenkins_url="${JENKINS_URL:-http://127.0.0.1:30080}"
test -s "$pipeline_file" || { echo 'pipeline file is missing or empty' >&2; exit 1; }

password="$(kubectl get secret jenkins-admin -n jenkins -o jsonpath='{.data.chart-admin-password}' | base64 -d)"
work_dir="$(mktemp -d)"
cleanup() {
  unset password crumb_json crumb_field crumb_value
  rm -rf -- "$work_dir"
}
trap cleanup EXIT

curl_userpwd="admin:${password}"
curl_userpwd="${curl_userpwd//\\/\\\\}"
curl_userpwd="${curl_userpwd//\"/\\\"}"
printf 'user = "%s"\n' "$curl_userpwd" > "$work_dir/curl.conf"
chmod 600 "$work_dir/curl.conf"
python3 - "$pipeline_file" "$work_dir/config.xml" <<'PY'
import sys
from pathlib import Path
from xml.sax.saxutils import escape

pipeline = Path(sys.argv[1]).read_text(encoding="utf-8")
xml = """<flow-definition plugin=\"workflow-job\">
  <actions/>
  <description>Managed report image build pipeline.</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class=\"org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition\" plugin=\"workflow-cps\">
    <script>{script}</script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
""".format(script=escape(pipeline))
Path(sys.argv[2]).write_text(xml, encoding="utf-8")
PY

crumb_json="$(curl --config "$work_dir/curl.conf" --fail --silent --show-error \
  --cookie-jar "$work_dir/cookies" "${jenkins_url}/crumbIssuer/api/json")"
crumb_field="$(jq -er '.crumbRequestField' <<<"$crumb_json")"
crumb_value="$(jq -er '.crumb' <<<"$crumb_json")"
if curl --config "$work_dir/curl.conf" --fail --silent --show-error \
  "${jenkins_url}/job/${job_name}/api/json" >/dev/null; then
  job_endpoint="${jenkins_url}/job/${job_name}/config.xml"
else
  job_endpoint="${jenkins_url}/createItem?name=${job_name}"
fi
curl --config "$work_dir/curl.conf" --fail-with-body --silent --show-error \
  --cookie "$work_dir/cookies" --cookie-jar "$work_dir/cookies" \
  -H "${crumb_field}: ${crumb_value}" \
  -H 'Content-Type: application/xml' \
  --data-binary "@$work_dir/config.xml" \
  "$job_endpoint"
echo "Configured Jenkins pipeline job: ${job_name}"
