#!/usr/bin/env python3
"""
Obsidian 知识库调用脚本
用法: python obsidian_query.py "搜索关键词"
"""

import os
import sys
from pathlib import Path
from urllib.parse import quote

import requests


API_URL = "https://127.0.0.1:27124"
VERIFY_SSL = False
REQUEST_TIMEOUT_SECONDS = 5
VAULT_ROOT = Path(__file__).resolve().parent
LOCAL_EXCLUDED_DIRS = {".git", ".obsidian", "cache", "logs", ".tmp"}
LAST_SEARCH_SOURCE = None


def build_headers():
    api_key = os.environ.get("OBSIDIAN_API_KEY", "").strip()
    if not api_key:
        raise RuntimeError("OBSIDIAN_API_KEY is not set")
    return {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }


def request_get(path):
    response = requests.get(
        f"{API_URL}{path}",
        headers=build_headers(),
        verify=VERIFY_SSL,
        timeout=REQUEST_TIMEOUT_SECONDS,
    )
    response.raise_for_status()
    return response


def get_vault_files():
    """获取知识库所有文件列表"""
    return request_get("/vault/").json()


def read_note(file_path: str):
    """读取指定笔记内容"""
    encoded_path = quote(file_path, safe="/")
    return request_get(f"/vault/{encoded_path}").text


def get_directory_files(directory: str):
    """获取目录下的所有文件"""
    encoded_path = quote(directory, safe="/")
    return request_get(f"/vault/{encoded_path}").json()


def local_markdown_files():
    for path in VAULT_ROOT.rglob("*.md"):
        relative_parts = path.relative_to(VAULT_ROOT).parts
        if not any(part in LOCAL_EXCLUDED_DIRS for part in relative_parts):
            yield path


def search_local_notes(query: str, max_results: int = 10):
    results = []
    lowered = query.casefold()
    for path in local_markdown_files():
        try:
            content = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        matches = [line for line in content.splitlines() if lowered in line.casefold()]
        if matches:
            results.append(
                {
                    "file": path.relative_to(VAULT_ROOT).as_posix(),
                    "matches": matches[:3],
                    "source": "local",
                }
            )
        if len(results) >= max_results:
            break
    return results


def search_notes(query: str, max_results: int = 10):
    """搜索笔记（基于文件名和简单匹配）"""
    global LAST_SEARCH_SOURCE
    try:
        files = get_vault_files().get("files", [])
        results = []
        lowered = query.casefold()
        for file_path in files:
            if not file_path.endswith(".md"):
                continue
            content = read_note(file_path)
            matches = [line for line in content.splitlines() if lowered in line.casefold()]
            if matches:
                results.append(
                    {"file": file_path, "matches": matches[:3], "source": "api"}
                )
            if len(results) >= max_results:
                break
        LAST_SEARCH_SOURCE = "api"
        return results
    except (RuntimeError, requests.ConnectionError, requests.Timeout):
        LAST_SEARCH_SOURCE = "local"
        return search_local_notes(query, max_results)


def main():
    if len(sys.argv) < 2:
        print("用法: python obsidian_query.py <搜索关键词>")
        print("示例: python obsidian_query.py NocoBase")
        print()
        print("可用命令:")
        print("  python obsidian_query.py --list          # 列出所有文件")
        print("  python obsidian_query.py <关键词>        # 搜索相关笔记")
        print("  python obsidian_query.py <文件路径> --read  # 读取指定文件")
        sys.exit(1)

    command = sys.argv[1]

    try:
        if command == "--list":
            files = get_vault_files()
            print(f"知识库共有 {len(files.get('files', []))} 个文件/目录:")
            for file_path in sorted(files.get("files", [])):
                print(f"  {file_path}")
        elif command == "--read" and len(sys.argv) > 2:
            file_path = sys.argv[2]
            content = read_note(file_path)
            print(content if content else f"文件不存在: {file_path}")
        else:
            results = search_notes(command)
            if LAST_SEARCH_SOURCE == "local":
                print("Local REST API 不可用，已使用本地只读 Markdown 搜索。")
            print(f"搜索结果: {len(results)} 个相关笔记")
            print("=" * 60)
            for i, result in enumerate(results, 1):
                print(f"\n{i}. {result['file']}")
                for match in result["matches"]:
                    print(f"   > {match[:100]}...")
    except (RuntimeError, requests.RequestException) as error:
        print(f"Obsidian API 不可用: {error}")
        sys.exit(2)


if __name__ == "__main__":
    main()
