# -*- coding: utf-8 -*-
# Remove nodes by line range
# 同重音模式: lines 904-927 (0-indexed: 903-926)
# 同音节数: lines 1100-1116 (0-indexed: 1099-1115)

with open(r'D:\mywork\techdoc\英语学习软件\app\index.html', 'r', encoding='utf-8') as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")

# Delete in reverse order to preserve line numbers
ranges_to_delete = [
    (1100 - 1, 1117 - 1),  # 0-indexed: 1099-1116 (exclusive 1117)
    (904 - 1, 928 - 1),    # 0-indexed: 903-927 (exclusive 928)
]

for start, end in ranges_to_delete:
    print(f"Deleting lines {start+1}-{end} ({end - start} lines)")
    del lines[start:end]

print(f"Remaining lines: {len(lines)}")

with open(r'D:\mywork\techdoc\英语学习软件\app\index.html', 'w', encoding='utf-8') as f:
    f.writelines(lines)

print('done')
