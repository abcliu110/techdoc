# -*- coding: utf-8 -*-
import shutil
src = r'D:\AGENTS.md.bak'
dst = r'D:\AGENTS.md'
shutil.copy2(src, dst)
import os
print(f'Restored from {src}')
print(f'New size: {os.path.getsize(dst)} bytes')
