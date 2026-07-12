# -*- coding: utf-8 -*-
import sys

filepath = r'D:\AGENTS.md'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

target = '# 项目关系与同步查表'
for i, line in enumerate(lines):
    stripped = line.strip()
    print(f'Line {i+1}: {repr(stripped)}')
    if stripped == target:
        print(f'FOUND at line {i+1}')
        sys.exit(0)
print('NOT FOUND')
