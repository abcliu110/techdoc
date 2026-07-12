# -*- coding: utf-8 -*-
import sys

def insert_kb_config(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    lines = content.split('\r\n')

    target = '# 项目关系与同步查表'
    insert_idx = None
    for i, line in enumerate(lines):
        if line.strip() == target:
            insert_idx = i
            break
    if insert_idx is None:
        print('Target not found')
        sys.exit(1)

    new_section = """# 知识库配置

## 低代码平台竞品知识库

| 配置项 | 值 |
|--------|-----|
| 位置 | D:\\mywork\\techdoc\\01业务文档\\系统设计\\01-知识库\\低代码平台竞品知识库 |
| 工具 | Obsidian + Local REST API |
| API 地址 | https://127.0.0.1:27124 |
| API Key | 465b6395af0a16a8e1ead030d1d2bff766cd18686b865e9d23b304dcb2d89eb6 |
| 端口 | 27124 |
| 协议 | HTTPS |

## AI 调用规范

- 分析竞品前，必须先从知识库检索相关证据
- 通过 Obsidian Local REST API 检索笔记内容
- API 端点：`/vault/{文件路径}` 读取笔记，`/vault/` 列出文件
- 调用脚本：`obsidian_query.py`（在知识库根目录）

## API 调用示例

```bash
# 列出知识库文件
curl -k -H "Authorization: Bearer 465b6395af0a16a8e1ead030d1d2bff766cd18686b865e9d23b304dcb2d89eb6" \\
  "https://127.0.0.1:27124/vault/"

# 读取指定笔记
curl -k -H "Authorization: Bearer 465b6395af0a16a8e1ead030d1d2bff766cd18686b865e9d23b304dcb2d89eb6" \\
  "https://127.0.0.1:27124/vault/README.md"
```

## 注意事项

- Obsidian 必须保持运行状态，API 才能响应
- 知识库使用 Markdown + YAML frontmatter 格式
- 目录结构：00-domain、01-evidence、02-competitors、03-business-design、04-ui-design、05-data-model、06-state-machine、07-business-rule、08-process、09-permission、10-pain-point、11-decision、12-metrics、13-non-functional、14-license-pricing、matrices、gaps
"""

    new_lines = lines[:insert_idx] + [new_section] + lines[insert_idx:]
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('\r\n'.join(new_lines))
    print(f'Inserted at line {insert_idx}')


if __name__ == '__main__':
    insert_kb_config(r'D:\AGENTS.md')
