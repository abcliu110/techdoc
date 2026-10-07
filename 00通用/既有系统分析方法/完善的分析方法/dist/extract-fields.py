# -*- coding: utf-8 -*-
"""
字段预提取工具
从图谱获取业务类，只解析这些类的字段

使用方式：
python extract-fields.py --graph-db <path> --business-prefix <包前缀> --output <output.db>

示例：
python extract-fields.py --graph-db .code-review-graph/graph.db --business-prefix shouqianba
python extract-fields.py --graph-db .code-review-graph/graph.db --business-prefix com.example
"""
import sqlite3
import os
import re
import json
import argparse
from datetime import datetime

def extract_fields_from_java(content):
    """从Java源码提取字段"""
    fields = []
    # 匹配字段声明：修饰符 类型 字段名;
    pattern = r'(private|public|protected)\s+([\w<>]+(?:\[\])?)\s+(\w+)\s*[;=]'
    for modifier, ftype, fname in re.findall(pattern, content):
        if fname != 'serialVersionUID':
            fields.append({
                'type': ftype,
                'name': fname,
                'modifier': modifier
            })
    return fields

def main():
    parser = argparse.ArgumentParser(description='Extract fields from business classes')
    parser.add_argument('--graph-db', required=True, help='Path to graph.db')
    parser.add_argument('--business-prefix', required=True, help='Business package prefix (e.g., shouqianba, com.example)')
    parser.add_argument('--output', default='class_fields.json', help='Output file')
    args = parser.parse_args()

    if not os.path.exists(args.graph_db):
        print(f"Error: graph.db not found: {args.graph_db}")
        return

    conn = sqlite3.connect(args.graph_db)
    conn.text_factory = str
    cur = conn.cursor()

    print("=" * 60)
    print("Field Extractor")
    print("=" * 60)
    print(f"Graph DB: {args.graph_db}")
    print(f"Business prefix: {args.business_prefix}")

    # 1. 从图谱获取业务类
    print("\n[1] Getting business classes...")
    cur.execute("""
        SELECT id, name, file_path
        FROM nodes
        WHERE kind = 'Class'
          AND file_path LIKE ?
    """, (f'%{args.business_prefix}%',))

    classes = cur.fetchall()
    print(f"  Found {len(classes)} business classes")

    # 2. 解析字段
    print("\n[2] Extracting fields...")
    results = []
    for i, (node_id, name, path) in enumerate(classes):
        if i % 500 == 0:
            print(f"  Progress: {i}/{len(classes)}")

        if not os.path.exists(path):
            continue

        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            fields = extract_fields_from_java(content)
            results.append({
                'node_id': node_id,
                'name': name,
                'path': path,
                'fields': fields,
                'field_count': len(fields)
            })
        except:
            pass

    print(f"  Extracted fields for {len(results)} classes")

    # 3. 统计
    total_fields = sum(r['field_count'] for r in results)
    print(f"  Total fields: {total_fields}")

    # 4. 保存
    print("\n[3] Saving...")
    output = {
        'extract_time': datetime.now().isoformat(),
        'business_prefix': args.business_prefix,
        'class_count': len(results),
        'total_fields': total_fields,
        'classes': results
    }

    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"  Saved to: {args.output}")

    conn.close()

if __name__ == '__main__':
    main()
