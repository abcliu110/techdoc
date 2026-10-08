# -*- coding: utf-8 -*-
with open(r'D:\mywork\techdoc\英语学习软件\中小学英语学习App设计文档.md', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Fix 1: line 148 - 四层→五层
if '### 3.1 四层分类架构' in lines[147]:
    lines[147] = lines[147].replace('四层', '五层')
    print("Fix 1 OK: 3.1 四层→五层")

# Fix 11: line 459 - 3.6 学习证据分类 → 3.5 学习证据分类（回退）
if '### 3.6 学习证据分类' in lines[458]:
    lines[458] = lines[458].replace('### 3.6 学习证据分类', '### 3.5 学习证据分类')
    print("Fix 11a OK: 3.6 学习证据分类 → 3.5")

# Fix 11: line 473 - 3.6 分类驱动 → 3.7 分类驱动
if '### 3.6 分类驱动的最小闭环' in lines[472]:
    lines[472] = lines[472].replace('### 3.6 分类驱动的最小闭环', '### 3.7 分类驱动的最小闭环')
    print("Fix 11b OK: 3.6 分类驱动 → 3.7")

with open(r'D:\mywork\techdoc\英语学习软件\中小学英语学习App设计文档.md', 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("done")
