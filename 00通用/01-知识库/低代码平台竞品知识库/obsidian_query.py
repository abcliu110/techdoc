#!/usr/bin/env python3
"""
Obsidian 知识库调用脚本
用法: python obsidian_query.py "搜索关键词"
"""

import requests
import sys
import json
from pathlib import Path

# API 配置
API_URL = "https://127.0.0.1:27124"
API_KEY = "465b6395af0a16a8e1ead030d1d2bff766cd18686b865e9d23b304dcb2d89eb6"
VERIFY_SSL = False

HEADERS = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}


def get_vault_files():
    """获取知识库所有文件列表"""
    response = requests.get(f"{API_URL}/vault/", headers=HEADERS, verify=VERIFY_SSL)
    return response.json()


def read_note(file_path: str):
    """读取指定笔记内容"""
    response = requests.get(f"{API_URL}/vault/{file_path}", headers=HEADERS, verify=VERIFY_SSL)
    if response.status_code == 200:
        return response.text
    return None


def search_notes(query: str, max_results: int = 10):
    """搜索笔记（基于文件名和简单匹配）"""
    files = get_vault_files().get("files", [])

    # 简单关键词匹配
    results = []
    for file_path in files:
        if file_path.endswith(".md"):
            content = read_note(file_path)
            if content and query.lower() in content.lower():
                # 提取包含关键词的片段
                lines = content.split("\n")
                matches = [line for line in lines if query.lower() in line.lower()]
                results.append({
                    "file": file_path,
                    "matches": matches[:3]  # 最多返回3个匹配片段
                })
                if len(results) >= max_results:
                    break

    return results


def get_directory_files(directory: str):
    """获取目录下的所有文件"""
    response = requests.get(f"{API_URL}/vault/{directory}", headers=HEADERS, verify=VERIFY_SSL)
    return response.json()


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

    if command == "--list":
        files = get_vault_files()
        print(f"知识库共有 {len(files.get('files', []))} 个文件/目录:")
        for f in sorted(files.get("files", [])):
            print(f"  {f}")
    elif command == "--read" and len(sys.argv) > 2:
        file_path = sys.argv[2]
        content = read_note(file_path)
        if content:
            print(content)
        else:
            print(f"文件不存在: {file_path}")
    else:
        # 搜索
        results = search_notes(command)
        print(f"搜索结果: {len(results)} 个相关笔记")
        print("=" * 60)
        for i, result in enumerate(results, 1):
            print(f"\n{i}. {result['file']}")
            for match in result['matches']:
                print(f"   > {match[:100]}...")


if __name__ == "__main__":
    main()
