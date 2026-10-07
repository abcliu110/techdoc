# -*- coding: utf-8 -*-
"""
L2: 对象树构建
为每个聚合根构建对象树（包含的子实体、值对象）

使用预提取的字段数据，分析聚合根包含的字段类型
"""
import json
import argparse
from collections import defaultdict
from datetime import datetime

def extract_package(path):
    """从路径提取包名"""
    path_norm = path.lower().replace('\\', '/')
    src_idx = path_norm.find('/src/')
    if src_idx == -1:
        return 'other'
    subpath = path_norm[src_idx + 5:]
    parts = [p for p in subpath.split('/') if p not in {'java', 'kotlin', 'scala', 'src', 'main', 'test'} and not p.endswith('.java')]
    if len(parts) >= 4:
        return '.'.join(parts[:4])
    elif len(parts) >= 2:
        return '.'.join(parts[:2])
    return 'other'

def build_object_tree(agg_root, all_objects):
    """
    为聚合根构建对象树
    """
    tree = {
        'root': agg_root['name'],
        'package': extract_package(agg_root.get('path', '')),
        'fields': []
    }

    # 分析每个字段
    for field in agg_root.get('fields', []):
        ftype = field['type']
        fname = field['name']

        # 分类逻辑：先检查ID引用，再检查子实体，最后才是值对象
        if fname.endswith('Id') or fname.endswith('_id') or fname.endswith('ID'):
            # 以Id/ID结尾的字段 → ID引用
            field_type = 'ID引用'
        elif fname.lower() in ['id', 'pid', 'mid', 'sid', 'lid']:
            # 本身就是 ID 字段
            field_type = 'ID引用'
        elif any(t in ftype.lower() for t in ['string', 'integer', 'long', 'boolean', 'double', 'float', 'decimal', 'date', 'time']):
            # 基本类型 + 不以Id结尾 → 值对象
            field_type = '值对象'
        elif ftype.lower().startswith('list<') or ftype.lower().startswith('set<') or ftype.lower().startswith('map<'):
            # 集合类型 → 值对象（简化处理）
            field_type = '值对象'
        else:
            # 检查是否是其他聚合根
            is_other_root = any(o['name'] == ftype and o['type'] == '聚合根' for o in all_objects)
            field_type = '子实体' if is_other_root else '值对象'

        tree['fields'].append({
            'name': fname,
            'type': ftype,
            'classification': field_type
        })

    return tree

def main():
    parser = argparse.ArgumentParser(description='Build Object Trees for Aggregate Roots')
    parser.add_argument('--objects', required=True, help='Path to objects analysis JSON')
    parser.add_argument('--output', default='object-trees.json', help='Output file')
    args = parser.parse_args()

    print("=" * 60)
    print("L2: Object Tree Builder")
    print("=" * 60)

    # 加载对象分析结果
    print("\n[1] Loading objects...")
    with open(args.objects, 'r', encoding='utf-8') as f:
        data = json.load(f)

    objects = data.get('objects', [])
    print(f"  Loaded {len(objects)} objects")

    # 提取聚合根
    agg_roots = [o for o in objects if o.get('type') == '聚合根']
    print(f"  Found {len(agg_roots)} aggregate roots")

    # 构建对象树
    print("\n[2] Building object trees...")
    object_trees = []
    for i, agg in enumerate(agg_roots):
        if i % 50 == 0:
            print(f"  Progress: {i}/{len(agg_roots)}")

        tree = build_object_tree(agg, objects)
        object_trees.append(tree)

    print(f"  Built {len(object_trees)} object trees")

    # 统计
    print("\n[3] Statistics...")
    field_types = defaultdict(int)
    for tree in object_trees:
        for field in tree['fields']:
            field_types[field['classification']] += 1

    print("\n  Field type distribution:")
    for ftype, cnt in sorted(field_types.items(), key=lambda x: -x[1]):
        print(f"    {ftype}: {cnt}")

    # 保存
    print("\n[4] Saving...")
    result = {
        'level': 2,
        'build_time': datetime.now().isoformat(),
        'summary': {
            'aggregate_roots': len(object_trees),
            'total_fields': sum(len(t['fields']) for t in object_trees),
            'field_types': dict(field_types)
        },
        'object_trees': object_trees
    }

    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    print(f"  Saved to: {args.output}")

if __name__ == '__main__':
    main()
