#!/usr/bin/env python3
import base64
import json
import subprocess
import urllib.parse
import urllib.request


API = "http://127.0.0.1:30086/nacos"
NAMESPACE_ID = "56a75109-dbdc-4c5a-8fc1-b2300cef7f4a"


def secret(key):
    value = subprocess.check_output(
        ["kubectl", "-n", "nacos", "get", "secret", "nacos-admin", "-o", f"jsonpath={{.data.{key}}}"], text=True
    ).strip()
    return base64.b64decode(value).decode()


def post(path, form):
    request = urllib.request.Request(path, data=urllib.parse.urlencode(form).encode(), method="POST")
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.status, response.read().decode()


def main():
    _, login = post(f"{API}/v1/auth/login", {"username": secret("username"), "password": secret("password")})
    token = json.loads(login)["accessToken"]
    status, body = post(
        f"{API}/v1/console/namespaces",
        {"namespaceId": NAMESPACE_ID, "namespaceName": "nms4cloud", "namespaceDesc": "nms4cloud imported configuration", "accessToken": token},
    )
    if status != 200:
        raise SystemExit(f"namespace creation failed: HTTP {status}")
    print("NAMESPACE_READY")


if __name__ == "__main__":
    main()
