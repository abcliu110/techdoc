#!/usr/bin/env python3
"""Import prepared Nacos configs and verify each API write without logging secrets."""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path


SOURCE_HOST = "192.168.1.119"
USERNAME_MARKER = "__K3S_MYSQL_USERNAME__"
PASSWORD_MARKER = "__K3S_MYSQL_PASSWORD__"
REDIS_PASSWORD_MARKER = "__K3S_REDIS_PASSWORD__"
CLICKHOUSE_PASSWORD_MARKER = "__K3S_CLICKHOUSE_PASSWORD__"


def request(url: str, data: dict[str, str] | None = None) -> tuple[int, str]:
    encoded = None if data is None else urllib.parse.urlencode(data).encode("utf-8")
    http_request = urllib.request.Request(url, data=encoded, method="POST" if data is not None else "GET")
    try:
        with urllib.request.urlopen(http_request, timeout=30) as response:
            return response.status, response.read().decode("utf-8")
    except urllib.error.HTTPError as error:
        return error.code, error.read().decode("utf-8", errors="replace")


def config_url(api: str, data_id: str, token: str) -> str:
    query = urllib.parse.urlencode({"dataId": data_id, "groupName": "DEFAULT_GROUP", "accessToken": token})
    return f"{api}/nacos/v3/admin/cs/config?{query}"


def secret_value(namespace: str, secret: str, key: str) -> str:
    encoded = subprocess.check_output(
        ["kubectl", "-n", namespace, "get", "secret", secret, "-o", f"jsonpath={{.data.{key}}}"],
        text=True,
    ).strip()
    if not encoded:
        raise RuntimeError(f"Secret key is empty: {namespace}/{secret}/{key}")
    return base64.b64decode(encoded).decode("utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("input_dir", type=Path)
    parser.add_argument("--api", default="http://127.0.0.1:30089")
    parser.add_argument("--data-id", action="append", dest="data_ids")
    args = parser.parse_args()

    nacos_username = os.environ.get("NACOS_USERNAME") or secret_value("nacos", "nacos-admin", "username")
    nacos_password = os.environ.get("NACOS_PASSWORD") or secret_value("nacos", "nacos-admin", "password")
    mysql_username = os.environ.get("MYSQL_USERNAME", "root")
    mysql_password = os.environ.get("MYSQL_PASSWORD") or secret_value("mysql", "mysql-auth", "MYSQL_PASSWORD")
    redis_password = os.environ.get("REDIS_PASSWORD") or secret_value("lgy", "redis-auth", "password")
    clickhouse_password = os.environ.get("CLICKHOUSE_PASSWORD") or secret_value("lgy", "clickhouse-secrets", "CLICKHOUSE_PASSWORD")
    if not args.input_dir.is_dir():
        raise SystemExit(f"input directory does not exist: {args.input_dir}")

    status, response = request(
        f"{args.api}/nacos/v1/auth/login",
        {"username": nacos_username, "password": nacos_password},
    )
    if status != 200:
        raise SystemExit(f"Nacos authentication failed with HTTP {status}")
    token = json.loads(response).get("accessToken")
    if not token:
        raise SystemExit("Nacos authentication returned no access token")

    created = 0
    updated = 0
    mysql_urls = 0
    paths = sorted(args.input_dir.glob("*.yaml"))
    if args.data_ids:
        requested = set(args.data_ids)
        paths = [path for path in paths if path.name in requested]
        missing = requested - {path.name for path in paths}
        if missing:
            raise SystemExit(f"requested config is missing: {', '.join(sorted(missing))}")
    for path in paths:
        data_id = path.name
        content = path.read_text(encoding="utf-8")
        original_mysql_urls = content.lower().count("jdbc:mysql://")
        content = content.replace(USERNAME_MARKER, mysql_username).replace(PASSWORD_MARKER, mysql_password).replace(REDIS_PASSWORD_MARKER, redis_password).replace(CLICKHOUSE_PASSWORD_MARKER, clickhouse_password)
        if SOURCE_HOST in content or USERNAME_MARKER in content or PASSWORD_MARKER in content or REDIS_PASSWORD_MARKER in content or CLICKHOUSE_PASSWORD_MARKER in content:
            raise SystemExit(f"pre-import validation failed for {data_id}")

        get_status, _ = request(config_url(args.api, data_id, token))
        if get_status == 404:
            created += 1
        elif get_status == 200:
            updated += 1
        else:
            raise SystemExit(f"cannot inspect existing config {data_id}: HTTP {get_status}")

        post_status, post_response = request(
            f"{args.api}/nacos/v3/admin/cs/config",
            {"dataId": data_id, "groupName": "DEFAULT_GROUP", "content": content, "accessToken": token},
        )
        if post_status != 200 or (post_response.strip().lower() != "true" and '"code":0' not in post_response.replace(" ", "")):
            raise SystemExit(f"write failed for {data_id}: HTTP {post_status}")

        read_status, stored = request(config_url(args.api, data_id, token))
        if read_status != 200:
            raise SystemExit(f"readback failed for {data_id}: HTTP {read_status}")
        try:
            payload = json.loads(stored)
            stored = payload.get("content", payload.get("data", {}).get("content", stored))
        except json.JSONDecodeError:
            pass
        if SOURCE_HOST in stored or USERNAME_MARKER in stored or PASSWORD_MARKER in stored:
            raise SystemExit(f"post-import validation failed for {data_id}")
        if hashlib.sha256(stored.encode("utf-8")).digest() != hashlib.sha256(content.encode("utf-8")).digest():
            raise SystemExit(f"readback content mismatch for {data_id}")

        mysql_urls += original_mysql_urls
        print(f"IMPORTED {data_id} mysql_urls={original_mysql_urls}")

    print(f"SUMMARY created={created} updated={updated} files={created + updated} mysql_urls={mysql_urls}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
