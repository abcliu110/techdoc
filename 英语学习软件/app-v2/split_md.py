# 自动拆分 markdown 文件为多个维度文件
# 用法：修改底部的 FILES 列表，指定源文件和输出目录即可

import os, re

PROTOTYPE_DIR = r'D:\mywork\techdoc\英语学习软件\app\prototype'
MD_DIR = os.path.join(PROTOTYPE_DIR, 'md')

# 要拆分的文件列表：(源文件路径, 输出前缀, [维度标题列表])
FILES = [
    # 示例：
    # (r'..\run-深度分析示范.md', 'run', [
    #     '维度一：语义',
    #     '维度二：搭配',
    #     '维度三：语法',
    #     '维度四：隐喻',
    #     '维度五：英汉对比',
    #     '维度六：语体',
    # ]),
]


def split_md(source_path, prefix, sections):
    """按章节标题拆分 markdown 文件"""
    if not os.path.exists(source_path):
        print(f'文件不存在: {source_path}')
        return

    with open(source_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 去掉文件头部的元信息（前10行内找到第一个维度标题为止）
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if any(s in line for s in sections):
            content = '\n'.join(lines[i:])
            break

    os.makedirs(MD_DIR, exist_ok=True)

    for i, section in enumerate(sections):
        # 找到当前章节
        start = content.find('### ' + section)
        if start == -1:
            start = content.find('## ' + section)
        if start == -1:
            print(f'  警告：未找到 "{section}"')
            continue

        # 找到下一个章节
        end = len(content)
        if i + 1 < len(sections):
            next_section = sections[i + 1]
            next_start = content.find('### ' + next_section, start + 1)
            if next_start == -1:
                next_start = content.find('## ' + next_section, start + 1)
            if next_start != -1:
                end = next_start

        chunk = content[start:end].strip()

        # 生成文件名
        dim_key = section.split('：')[0].replace('维度', 'dim')
        out_file = os.path.join(MD_DIR, f'{prefix}-{dim_key}.md')

        with open(out_file, 'w', encoding='utf-8') as f:
            f.write(chunk + '\n')

        print(f'  [OK] {os.path.basename(out_file)} ({len(chunk)} chars)')


# ============================================================
# 在这里配置要拆分的文件
# ============================================================
FILES = [
    # run 单词
    (r'D:\mywork\techdoc\英语学习软件\run-深度分析示范.md', 'run', [
        '维度一：语义',
        '维度二：搭配',
        '维度三：语法',
        '维度四：隐喻',
        '维度五：英汉对比',
        '维度六：语体',
    ]),
]

if __name__ == '__main__':
    for source, prefix, sections in FILES:
        print(f'\n拆分: {source}')
        split_md(source, prefix, sections)
    print('\n完成！')
