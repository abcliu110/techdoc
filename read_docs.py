import os
import json

base = r'D:\mywork\techdoc\00通用\00-方法论与流程'
result = {}

for dirname in os.listdir(base):
    dirpath = os.path.join(base, dirname)
    if not os.path.isdir(dirpath):
        continue
    
    if '遗留' in dirname and '理论框架' in dirname:
        files = {}
        for filename in os.listdir(dirpath):
            if filename.endswith('.md'):
                filepath = os.path.join(dirpath, filename)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                files[filename] = {
                    'path': filepath,
                    'size': len(content),
                    'lines': len(content.split('\n'))
                }
        result[dirname] = files

print(json.dumps(result, ensure_ascii=False, indent=2))
