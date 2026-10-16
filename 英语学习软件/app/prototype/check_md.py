import os
base = r'D:\mywork\techdoc\英语学习软件\app\prototype\md'
files = ['run-semantic.md','run-collocation.md','run-grammar.md','run-metaphor.md','run-contrast.md','run-register.md']
for f in files:
    path = os.path.join(base, f)
    size = os.path.getsize(path)
    print(f'{f}: {size} bytes')
