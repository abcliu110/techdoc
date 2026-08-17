#!/usr/bin/env python3
"""Prepare Nacos configuration copies without modifying the source directory."""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path


SOURCE_HOST = "192.168.1.119"
MYSQL_URL = re.compile(r"jdbc:mysql://192\.168\.1\.119(?::\d+)?/", re.IGNORECASE)
MYSQL_URL_LINE = re.compile(r"^(\s*)url\s*:\s*jdbc:mysql://192\.168\.253\.128:30306/", re.IGNORECASE)
MYSQL_CREDENTIAL_LINE = re.compile(r"^(\s*)(username|user-name|userName|password|passwd)\s*:(.*)$")
MANIFEST_KIND = re.compile(r"^kind:\s*(Deployment|Service|ConfigMap|Secret)\s*$", re.MULTILINE)


def replace_mysql_credentials(text: str, username: str, password: str) -> tuple[str, int, int]:
    result: list[str] = []
    mysql_indent: int | None = None
    username_changes = 0
    password_changes = 0

    for line in text.splitlines(keepends=True):
        url_match = MYSQL_URL_LINE.match(line)
        if url_match:
            mysql_indent = len(url_match.group(1).expandtabs(2))
            result.append(line)
            continue

        credential_match = MYSQL_CREDENTIAL_LINE.match(line)
        current_indent = len(line) - len(line.lstrip(" "))
        if mysql_indent is not None and credential_match and current_indent == mysql_indent:
            key = credential_match.group(2).lower()
            newline = "\n" if line.endswith("\n") else ""
            if key in {"username", "user-name", "username"}:
                result.append(f"{credential_match.group(1)}{credential_match.group(2)}: {username}{newline}")
                username_changes += 1
                continue
            if key in {"password", "passwd"}:
                result.append(f"{credential_match.group(1)}{credential_match.group(2)}: {password}{newline}")
                password_changes += 1
                continue

        if mysql_indent is not None and line.strip() and current_indent <= mysql_indent:
            mysql_indent = None
        result.append(line)

    return "".join(result), username_changes, password_changes


def replace_redis_passwords(text: str) -> str:
    result = []
    redis_indent = None
    for line in text.splitlines(keepends=True):
        indent = len(line) - len(line.lstrip(" "))
        key = line.strip().split(":", 1)[0]
        if key in {"redis", "redis2"} and indent in {2, 4}:
            redis_indent = indent
        elif redis_indent is not None and line.strip() and indent <= redis_indent:
            redis_indent = None
        if redis_indent is not None and key == "password" and indent == redis_indent + 2:
            result.append(" " * indent + "password: __K3S_REDIS_PASSWORD__" + ("\n" if line.endswith("\n") else ""))
        else:
            result.append(line)
    return "".join(result)


def prepare_file(source: Path, target: Path, host: str, port: int, username: str, password: str) -> tuple[int, int, int]:
    text = source.read_text(encoding="utf-8")
    mysql_urls = len(MYSQL_URL.findall(text))
    source_references = text.count(SOURCE_HOST)
    text = MYSQL_URL.sub(f"jdbc:mysql://{host}:{port}/", text)
    text = text.replace(SOURCE_HOST, host)
    if source.name in {"nms4cloud-shared.yaml", "yd4cloud-shared.yaml"}:
        text = text.replace("host: 192.168.253.128", "host: redis.lgy.svc.cluster.local.")
        text = text.replace("name-server: 192.168.253.128:9876", "name-server: rocketmq-nameserver.lgy.svc.cluster.local.:9876")
        text = replace_redis_passwords(text)
    text, username_changes, password_changes = replace_mysql_credentials(text, username, password)
    if SOURCE_HOST in text:
        raise ValueError(f"source host remains in {source.name}")
    target.write_text(text, encoding="utf-8", newline="")
    return source_references, mysql_urls, username_changes + password_changes


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("target", type=Path)
    parser.add_argument("--mysql-host", default="192.168.253.128")
    parser.add_argument("--mysql-port", type=int, default=30306)
    parser.add_argument("--mysql-username", default="__K3S_MYSQL_USERNAME__")
    parser.add_argument("--mysql-password", default="__K3S_MYSQL_PASSWORD__")
    args = parser.parse_args()

    if not args.source.is_dir():
        raise SystemExit(f"source directory does not exist: {args.source}")
    if args.target.exists():
        shutil.rmtree(args.target)
    args.target.mkdir(parents=True)

    imported = 0
    source_references = 0
    mysql_urls = 0
    credential_changes = 0
    for source in sorted(args.source.glob("*.yaml")):
        source_text = source.read_text(encoding="utf-8")
        if MANIFEST_KIND.search(source_text):
            print(f"SKIP_MANIFEST {source.name}")
            continue
        counts = prepare_file(
            source,
            args.target / source.name,
            args.mysql_host,
            args.mysql_port,
            args.mysql_username,
            args.mysql_password,
        )
        imported += 1
        source_references += counts[0]
        mysql_urls += counts[1]
        credential_changes += counts[2]
        print(f"PREPARED {source.name}")

    print(
        f"SUMMARY files={imported} source_references={source_references} "
        f"mysql_urls={mysql_urls} mysql_credential_lines={credential_changes}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
