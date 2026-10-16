# Analyze the HTML file
import re

with open(r'D:\mywork\techdoc\英语学习软件\app\prototype\index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# Count dim script tags for run
tags = re.findall(r'data-word="run" data-dim="([^"]+)"', content)
print('run维度数量:', len(tags))
print('维度列表:', tags)

# Count tabs in WORDS
m = re.search(r"word: 'run'.*?dims: \[([^\]]+)\]", content, re.DOTALL)
if m:
    dims_str = m.group(1)
    dims = re.findall(r"'([^']+)'", dims_str)
    print('WORDS中dims数量:', len(dims))
    print('WORDS dims:', dims)
else:
    print('WORDS dims未找到')

print()
print('getWordMD函数存在:', 'function getWordMD' in content)
print('switchDetailTab函数存在:', 'function switchDetailTab' in content)

# Check if tabs are being rendered
tab_rendering = re.search(r"tabsHtml \+=", content)
print('tabsHtml渲染存在:', bool(tab_rendering))
