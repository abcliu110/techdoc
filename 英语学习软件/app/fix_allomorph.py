# -*- coding: utf-8 -*-
# 删除第一个 allomorph_mappings 列表（行666-761），保留第二个（行762+）
with open(r'D:\mywork\techdoc\英语学习软件\app\fill_all_v15.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# 删除行 666-761（0-indexed: 665-760）
# 保留行 762+（0-indexed: 761+）
new_lines = lines[:665] + lines[761:]

with open(r'D:\mywork\techdoc\英语学习软件\app\fill_all_v15.py', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print(f"Done. Original {len(lines)} lines -> {len(new_lines)} lines (removed {len(lines)-len(new_lines)} lines)")
