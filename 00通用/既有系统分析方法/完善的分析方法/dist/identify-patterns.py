# -*- coding: utf-8 -*-
"""
L4: 业务模式识别
从对象和关系中识别典型的业务模式

典型模式：
- 订单-支付模式 (Order + Payment)
- 主-明细模式 (Master + Detail)
- 用户-角色模式 (User + Role)
- 参照模式 (Reference Data)
"""
import json
import argparse
from collections import defaultdict
from datetime import datetime

# 业务模式关键词
PATTERNS = {
    'Order-Payment': {
        'keywords': ['order', 'pay', 'payment', 'transaction'],
        'description': '订单与支付'
    },
    'Master-Detail': {
        'keywords': ['master', 'detail', 'item', 'line'],
        'description': '主从明细'
    },
    'User-Role': {
        'keywords': ['user', 'member', 'role', 'permission', 'auth'],
        'description': '用户权限'
    },
    'Category-Tree': {
        'keywords': ['category', 'tree', 'parent', 'child'],
        'description': '树形分类'
    },
    'Config-Reference': {
        'keywords': ['config', 'setting', 'param', 'const', 'enum'],
        'description': '配置参照'
    },
    'Print-Label': {
        'keywords': ['print', 'printer', 'label', 'ticket'],
        'description': '打印标签'
    },
    'Goods-SKU': {
        'keywords': ['goods', 'sku', 'product', 'item', 'dish'],
        'description': '商品SKU'
    }
}

def identify_patterns(objects, relationships):
    """
    识别业务模式
    """
    object_names = [o['name'].lower() for o in objects]

    detected_patterns = []

    for pattern_name, pattern_info in PATTERNS.items():
        matched_objects = []
        for obj in objects:
            name_lower = obj['name'].lower()
            # 检查对象名是否包含模式关键词
            for kw in pattern_info['keywords']:
                if kw in name_lower:
                    matched_objects.append(obj['name'])
                    break

        if len(matched_objects) >= 2:
            detected_patterns.append({
                'pattern': pattern_name,
                'description': pattern_info['description'],
                'matched_objects': matched_objects,
                'confidence': min(len(matched_objects) / 5, 1.0)  # 置信度
            })

    return detected_patterns

def analyze_pattern_relationships(patterns, relationships):
    """
    分析模式内部的关系
    """
    pattern_rels = []

    for pattern in patterns:
        matched = set(pattern['matched_objects'])
        rels_in_pattern = []

        for rel in relationships:
            if rel['source'] in matched:
                rels_in_pattern.append(rel)

        pattern_rels.append({
            'pattern': pattern['pattern'],
            'internal_relationships': len(rels_in_pattern),
            'details': rels_in_pattern[:5]  # 只保留前5个
        })

    return pattern_rels

def main():
    parser = argparse.ArgumentParser(description='Identify Business Patterns')
    parser.add_argument('--objects', required=True, help='Path to objects JSON')
    parser.add_argument('--relationships', required=True, help='Path to relationships JSON')
    parser.add_argument('--output', default='patterns.json', help='Output file')
    args = parser.parse_args()

    print("=" * 60)
    print("L4: Business Pattern Identification")
    print("=" * 60)

    # 加载数据
    print("\n[1] Loading data...")
    with open(args.objects, 'r', encoding='utf-8') as f:
        objects_data = json.load(f)
    with open(args.relationships, 'r', encoding='utf-8') as f:
        rel_data = json.load(f)

    objects = objects_data.get('objects', [])
    relationships = rel_data.get('relationships', [])
    print(f"  Objects: {len(objects)}")
    print(f"  Relationships: {len(relationships)}")

    # 识别模式
    print("\n[2] Identifying patterns...")
    patterns = identify_patterns(objects, relationships)
    print(f"  Found {len(patterns)} patterns")

    for p in patterns:
        print(f"    {p['pattern']}: {len(p['matched_objects'])} objects ({p['description']})")

    # 分析模式关系
    print("\n[3] Analyzing pattern relationships...")
    pattern_rels = analyze_pattern_relationships(patterns, relationships)

    # 保存
    print("\n[4] Saving...")
    result = {
        'level': 4,
        'build_time': datetime.now().isoformat(),
        'summary': {
            'patterns_found': len(patterns),
            'pattern_details': pattern_rels
        },
        'patterns': patterns
    }

    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    print(f"  Saved to: {args.output}")

if __name__ == '__main__':
    main()
