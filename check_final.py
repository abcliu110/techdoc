# -*- coding: utf-8 -*-
import chardet
with open('crm技术文档/02-积分权益接口与控制逻辑.md', 'rb') as f:
    raw = f.read()
enc = chardet.detect(raw)['encoding']
content = raw.decode(enc)
lines = content.split('\n')

# 检查 6270-6280 行
print('Lines 6270-6285:')
for i in range(6268, 6285):
    print(i+1, repr(lines[i].strip('\r')[:150]))

# 检查是否还有 [...] 残留
remaining = [(i+1, lines[i].strip('\r')[:100]) for i in range(len(lines)) if '[...]' in lines[i]]
print('\nRemaining [...] occurrences:', len(remaining))
for lineno, line in remaining:
    print(lineno, repr(line))

# 统计各商品展示字段出现次数
for field in ['earningSpecifiedProducts', 'deductSpecifiedProducts', 'deductExcludeProducts']:
    count = sum(1 for l in lines if field in l and '//' in l)
    print(f'{field}: {count} occurrences with //')
