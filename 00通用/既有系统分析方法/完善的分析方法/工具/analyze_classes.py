# -*- coding: utf-8 -*-
"""
code-review-graph 图谱分析工具集

使用方法：
1. 设置环境变量 CRG_DATA_DIR 指向图谱数据库目录
2. 或修改 GRAPH_DB 变量

python analyze_classes.py --repo <仓库路径>
"""
import sqlite3
import argparse
import re
import json
from collections import defaultdict
from datetime import datetime

def get_args():
    parser = argparse.ArgumentParser(description='分析图谱中的类')
    parser.add_argument('--repo', default='.', help='仓库路径')
    parser.add_argument('--output', default='classes_analysis.json', help='输出文件')
    parser.add_argument('--filter', default='', help='过滤路径关键字')
    return parser.parse_args()

def extract_fields(java_file):
    """从 Java 文件提取字段"""
    fields = []
    try:
        with open(java_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        pattern = r'(private|public|protected)\s+([\w<>]+(?:\[\])?)\s+(\w+)\s*;'
        for modifier, ftype, fname in re.findall(pattern, content):
            if fname != 'serialVersionUID':
                fields.append({'type': ftype, 'name': fname})
    except:
        pass
    return fields

def get_package(path):
    """获取包路径"""
    path_lower = path.lower().replace('\\', '/')
    if '/dao/po/' in path_lower:
        return 'dao.po'
    elif '/dao/' in path_lower:
        return 'dao'
    elif '/service/' in path_lower:
        return 'service'
    elif '/print/' in path_lower:
        return 'print'
    elif '/order/' in path_lower:
        return 'order'
    elif '/dto/' in path_lower:
        return 'dto'
    elif '/vo/' in path_lower:
        return 'vo'
    elif '/enums/' in path_lower:
        return 'enums'
    elif '/convert/' in path_lower:
        return 'convert'
    elif '/handler/' in path_lower:
        return 'handler'
    elif '/report/' in path_lower:
        return 'report'
    elif '/client/' in path_lower:
        return 'client'
    elif '/config/' in path_lower:
        return 'config'
    elif '/util/' in path_lower:
        return 'util'
    elif '/domain/' in path_lower:
        return 'domain'
    elif '/biz/' in path_lower:
        return 'biz'
    else:
        return 'other'

def main():
    args = get_args()

    # 连接数据库
    import os
    graph_dir = os.environ.get('CRG_DATA_DIR', f'{args.repo}/.code-review-graph')
    graph_db = f'{graph_dir}/graph.db'

    if not os.path.exists(graph_db):
        print(f"错误: 找不到图谱数据库 {graph_db}")
        return

    conn = sqlite3.connect(graph_db)
    conn.text_factory = str
    cur = conn.cursor()

    print("=" * 60)
    print("code-review-graph 类分析工具")
    print("=" * 60)
    print(f"图谱: {graph_db}")

    # 构建查询条件
    filter_pattern = f'%{args.filter}%' if args.filter else '%'

    # 获取所有类
    cur.execute(f'''
        SELECT name, qualified_name, file_path
        FROM nodes
        WHERE kind = "Class"
          AND file_path LIKE ?
        ORDER BY file_path, name
    ''', (filter_pattern,))

    classes = cur.fetchall()
    print(f"找到 {len(classes)} 个类")

    # 分析每个类
    classes_info = []
    for i, (name, qualified, path) in enumerate(classes):
        if i % 1000 == 0:
            print(f"  进度: {i}/{len(classes)}")

        fields = extract_fields(path)
        pkg = get_package(path)
        has_id = any(f['name'] == 'id' for f in fields)
        po_type = "聚合根" if has_id else ("实体" if len(fields) > 5 else "值对象")

        # 获取被引用次数
        cur.execute('''
            SELECT COUNT(*) FROM edges
            WHERE kind IN ("CALLS", "REFERENCES")
              AND target_qualified LIKE ?
        ''', (f'%::{name}(%',))
        ref_count = cur.fetchone()[0]

        classes_info.append({
            'name': name,
            'path': path,
            'package': pkg,
            'field_count': len(fields),
            'ref_count': ref_count,
            'po_type': po_type
        })

    # 按包统计
    package_stats = defaultdict(list)
    for c in classes_info:
        package_stats[c['package']].append(c)

    print("\n按包统计:")
    for pkg in sorted(package_stats.keys(), key=lambda x: -len(package_stats[x]))[:10]:
        cnt = len(package_stats[pkg])
        print(f"  {pkg}: {cnt} 类")

    # 保存数据
    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump({
            'classes': classes_info,
            'package_stats': {pkg: len(cls) for pkg, cls in package_stats.items()},
            'total': len(classes_info),
            'generated_at': datetime.now().isoformat()
        }, f, ensure_ascii=False, indent=2)

    print(f"\n数据已保存: {args.output}")
    conn.close()

if __name__ == '__main__':
    main()
