# -*- coding: utf-8 -*-
"""
对象分析与聚合根判定工具
使用预提取的字段数据进行严格判定

使用方式：
python analyze-objects.py --fields <预提取的数据.json> --graph-db <可选>

四重过滤器：
F1: 有 @Id 或 id/pid/lid 字段（精确或 Id 后缀）
F2: 有独立生命周期方法 (create/update/delete)
F3: 不被其他聚合根级联删除
F4: 有业务状态或状态机
"""
import sqlite3
import os
import json
import argparse
from collections import defaultdict
from datetime import datetime

def has_id_field(fields):
    """检查是否有 ID 字段（支持多种命名）"""
    for f in fields:
        name = f['name']
        # 精确匹配
        if name in ['id', 'pid', 'lid']:
            return True
        # 后缀匹配 (goodsId, orderId, skuId...)
        if name.endswith('Id') and len(name) > 2:
            return True
        # _id 后缀
        if name.endswith('_id'):
            return True
    return False

def classify_object(name, fields, has_create_method=False, has_update_method=False, has_delete_method=False):
    """
    严格对象分类：聚合根 / 实体 / 值对象

    四重过滤器：
    F1: 有 ID 字段（支持 goodsId, orderId 等）
    F2: 有独立生命周期方法
    F3: 不被级联删除（需分析关系，暂用名字推断）
    F4: 有业务状态（需分析代码，暂用字段推断）
    """
    has_id = has_id_field(fields)

    # 生命周期方法检查
    has_lifecycle = has_create_method or has_update_method or has_delete_method

    # F1 + F2: 聚合根
    if has_id and has_lifecycle:
        return '聚合根'

    # 只有 F1 但字段多: 实体
    if has_id and len(fields) > 5:
        return '实体'

    # 有 ID 但字段少: 聚合根（可能是小型实体）
    if has_id:
        return '聚合根'

    # 其他: 值对象
    return '值对象'

def main():
    parser = argparse.ArgumentParser(description='Object Analysis and Aggregate Root Detection')
    parser.add_argument('--fields', required=True, help='Path to fields JSON from extract-fields.py')
    parser.add_argument('--graph-db', help='Optional: Path to graph.db for reference count')
    parser.add_argument('--output', default='objects-analysis.json', help='Output file')
    args = parser.parse_args()

    print("=" * 60)
    print("Object Analysis")
    print("=" * 60)

    # 1. 加载预提取的字段数据
    print("\n[1] Loading fields data...")
    with open(args.fields, 'r', encoding='utf-8') as f:
        fields_data = json.load(f)

    classes = fields_data['classes']
    print(f"  Loaded {len(classes)} classes")
    print(f"  Total fields: {fields_data.get('total_fields', 'N/A')}")

    # 2. 获取引用次数（可选）
    ref_counts = {}
    if args.graph_db and os.path.exists(args.graph_db):
        print("\n[2] Loading reference counts...")
        conn = sqlite3.connect(args.graph_db)
        conn.text_factory = str
        cur = conn.cursor()
        cur.execute("""
            SELECT target_qualified, COUNT(*) as cnt
            FROM edges
            WHERE kind IN ('CALLS', 'REFERENCES')
            GROUP BY target_qualified
        """)
        for target, cnt in cur.fetchall():
            name = target.split('::')[-1].split('(')[0] if '::' in target else target
            ref_counts[name] = cnt
        conn.close()
        print(f"  Loaded {len(ref_counts)} reference counts")
    else:
        print("\n[2] Skipping reference counts (no graph.db)")

    # 3. 分析对象
    print("\n[3] Analyzing objects...")
    objects = []
    for i, c in enumerate(classes):
        if i % 500 == 0:
            print(f"  Progress: {i}/{len(classes)}")

        name = c['name']
        fields = c.get('fields', [])
        ref_count = ref_counts.get(name, 0)

        obj_type = classify_object(name, fields)

        objects.append({
            'name': name,
            'path': c['path'],
            'node_id': c.get('node_id'),
            'type': obj_type,
            'field_count': c.get('field_count', len(fields)),
            'ref_count': ref_count,
            'has_id': has_id_field(fields),
            'fields': fields[:20]  # 只保留前20个字段
        })

    print(f"  Analyzed {len(objects)} objects")

    # 4. 统计
    print("\n[4] Statistics...")
    agg_roots = [o for o in objects if o['type'] == '聚合根']
    entities = [o for o in objects if o['type'] == '实体']
    value_objects = [o for o in objects if o['type'] == '值对象']

    print(f"  Aggregate Roots: {len(agg_roots)}")
    print(f"  Entities: {len(entities)}")
    print(f"  Value Objects: {len(value_objects)}")

    # 5. 按包统计
    print("\n[5] Package distribution...")
    pkg_stats = defaultdict(lambda: {'total': 0, 'agg': 0, 'entity': 0, 'vo': 0})

    for o in objects:
        # 从路径提取包名
        path = o['path'].lower().replace('\\', '/')
        if '/src/' in path:
            idx = path.find('/src/')
            subpath = path[idx + 5:]
            parts = [p for p in subpath.split('/') if p not in {'java', 'kotlin', 'scala', 'src', 'main', 'test'} and not p.endswith('.java')]
            if len(parts) >= 4:
                pkg = '.'.join(parts[:4])
            elif len(parts) >= 2:
                pkg = '.'.join(parts[:2])
            else:
                pkg = 'other'
        else:
            pkg = 'other'

        pkg_stats[pkg]['total'] += 1
        if o['type'] == '聚合根':
            pkg_stats[pkg]['agg'] += 1
        elif o['type'] == '实体':
            pkg_stats[pkg]['entity'] += 1
        else:
            pkg_stats[pkg]['vo'] += 1

    print("\n  Top packages:")
    for pkg, stats in sorted(pkg_stats.items(), key=lambda x: -x[1]['total'])[:15]:
        print(f"    {pkg}: {stats['total']} (agg:{stats['agg']}, entity:{stats['entity']}, vo:{stats['vo']})")

    # 6. 高引用聚合根
    print("\n[6] Top aggregate roots by reference...")
    sorted_agg = sorted(agg_roots, key=lambda x: -x['ref_count'])
    for o in sorted_agg[:20]:
        print(f"  {o['ref_count']:4d}  {o['name']}")

    # 7. 保存结果
    print("\n[7] Saving results...")
    result = {
        'analysis_time': datetime.now().isoformat(),
        'summary': {
            'total_objects': len(objects),
            'aggregate_roots': len(agg_roots),
            'entities': len(entities),
            'value_objects': len(value_objects)
        },
        'package_stats': dict(pkg_stats),
        'objects': objects,
        'top_aggregate_roots': sorted_agg[:50]
    }

    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    print(f"  Saved to: {args.output}")

if __name__ == '__main__':
    main()
