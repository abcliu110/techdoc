# -*- coding: utf-8 -*-
import os
filepath = r'D:\AGENTS.md'
size = os.path.getsize(filepath)
print(f'File size: {size} bytes')
with open(filepath, 'rb') as f:
    raw = f.read()
print(repr(raw[:200]))
