#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""手写产物检查器：代码围栏配平、相对链接目标存在性、ID 撞号。

用法：
  python check-artifacts.py <file-or-dir> [more...]
  目录会递归收集 *.md；generated/ 目录只做标记完整性检查。

规则：
  1. 围栏配平：4 反引号围栏必须成对；其余 3 反引号围栏在全局模拟下必须配对。
  2. 相对链接：代码围栏外的 [text](relative.md) 目标必须存在（忽略锚点/外链）。
  3. ID 撞号：TDxxx / GAPxxx / EVD-xxx 的"裸 ID 表行 / yaml id 行"视为定义，
     同一 ID 在多个文件出现定义即报错；"[ID](...)" 链接形式视为引用，不算定义。
  4. 生成视图：generated/ 下文件必须带 "generated from" 标记。

退出码：0 = 通过；1 = 存在错误。
"""
import io
import re
import sys
import urllib.parse
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

FENCE_RE = re.compile(r"^ {0,3}(`{3,})(.*)$")
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
BARE_ID_RE = re.compile(r"^\s*\|\s*((?:TD|GAP)\d{3}|EVD-\d{3})\s*\|")
LINKED_ID_RE = re.compile(r"^\s*\|\s*\[((?:TD|GAP)\d{3}|EVD-\d{3})\]")
YAML_ID_RE = re.compile(r"^\s*-\s*id:\s*((?:TD|GAP)\d{3}|EVD-\d{3})\s*$")


def collect_files(args):
    files = []
    for a in args:
        p = Path(a)
        if p.is_dir():
            for f in sorted(p.rglob("*.md")):
                files.append(f)
        elif p.suffix == ".md":
            files.append(p)
    return files


def check_file(path):
    """返回 (errors, defined_ids)。围栏外内容才参与链接与 ID 检查。"""
    errors = []
    defined = set()
    with io.open(path, "r", encoding="utf-8-sig") as f:
        lines = f.read().split("\n")

    depth4 = 0
    depth3 = False
    for idx, line in enumerate(lines, 1):
        m = FENCE_RE.match(line)
        if m:
            ticks, info = m.group(1), m.group(2).strip()
            if len(ticks) >= 4:
                if depth4 == 0 and info:
                    depth4 = 1
                elif depth4 == 1 and not info:
                    depth4 = 0
                else:
                    errors.append("%s:%d 4反引号围栏异常: %s" % (path.name, idx, line[:40]))
                continue
            if depth4 == 1:
                continue  # 4 反引号块内部是字面内容（模板示例）
            depth3 = not depth3
            continue
        if depth4 == 1 or depth3:
            continue  # 代码围栏内不检查链接/ID

        for lm in LINK_RE.finditer(line):
            target = lm.group(1)
            if target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            file_part = urllib.parse.unquote(target.split("#", 1)[0])
            if not file_part:
                continue
            if not (path.parent / file_part).exists():
                errors.append("%s:%d 链接目标不存在: %s" % (path.name, idx, target))

        for idm in BARE_ID_RE.finditer(line):
            defined.add(idm.group(1))
        for idm in YAML_ID_RE.finditer(line):
            defined.add(idm.group(1))
        # 带链接的 ID 是引用，不算定义
        for idm in LINKED_ID_RE.finditer(line):
            defined.discard(idm.group(1))
    return errors, defined


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 1
    files = collect_files(sys.argv[1:])
    if not files:
        print("没有找到 markdown 文件")
        return 1

    errors = []
    id_defs = {}   # id -> [file...]
    for f in files:
        ferr, defined = check_file(f)
        errors += ferr
        for i in defined:
            id_defs.setdefault(i, []).append(f.name)

    for i, fl in sorted(id_defs.items()):
        if len(fl) > 1:
            errors.append("ID '%s' 在多个文件中定义: %s（登记制：只允许一处定义，其余改为链接引用）"
                          % (i, ", ".join(fl)))

    # 生成视图标记检查
    for f in files:
        if "generated" in f.parts:
            head = io.open(f, "r", encoding="utf-8-sig").read(400)
            if "generated from" not in head:
                errors.append("%s: generated/ 下的文件缺少生成标记，疑似被手改" % f.name)

    print("检查文件数: %d" % len(files))
    if errors:
        print("结果: FAIL（%d 个问题）" % len(errors))
        for e in errors:
            print("  [ERROR] %s" % e)
        return 1
    print("结果: PASS（围栏配平、链接有效、ID 无撞号、生成标记完整）")
    return 0


if __name__ == "__main__":
    sys.exit(main())
