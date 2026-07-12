# -*- coding: utf-8 -*-
filepath = r'D:\AGENTS.md'
with open(filepath, 'rb') as f:
    raw = f.read(500)
print(repr(raw[:300]))
