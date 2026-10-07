# -*- coding: utf-8 -*-
"""
L5: 领域分组
将对象按业务领域分组

领域划分基于：
- 包结构 (package)
- 业务模式
- 聚合根的业务语义
"""
import json
import argparse
from collections import defaultdict
from datetime import datetime

def extract_domain_from_package(pkg):
    """
    从包名提取领域
    例如: com.shouqianba.localserver.order.dao -> order
    """
    if 'localserver.' in pkg:
        parts = pkg.split('.')
        for i, part in enumerate(parts):
            if part == 'localserver' and i + 1 < len(parts):
                return parts[i + 1]
    elif 'kaci.' in pkg:
        parts = pkg.split('.')
        for i, part in enumerate(parts):
            if part == 'kaci' and i + 1 < len(parts):
                return f"kaci_{parts[i + 1]}"
    return 'other'

# 领域定义
DOMAIN_DEFINITIONS = {
    'order': {
        'description': '订单域',
        'keywords': ['order', 'Order']
    },
    'goods': {
        'description': '商品域',
        'keywords': ['goods', 'Goods', 'dish', 'Dish', 'sku', 'SKU']
    },
    'member': {
        'description': '会员域',
        'keywords': ['member', 'Member', 'customer', 'Customer']
    },
    'payment': {
        'description': '支付域',
        'keywords': ['pay', 'Pay', 'payment', 'Payment']
    },
    'print': {
        'description': '打印域',
        'keywords': ['print', 'Print', 'printer', 'Printer']
    },
    'kds': {
        'description': '厨房显示域',
        'keywords': ['kds', 'KDS', 'kitchen', 'Kitchen']
    },
    'table': {
        'description': '餐桌域',
        'keywords': ['table', 'Table', 'seat', 'Seat']
    },
    'book': {
        'description': '预订域',
        'keywords': ['book', 'Book', 'reservation', 'Reservation']
    },
    'takeout': {
        'description': '外卖域',
        'keywords': ['takeout', 'Takeout', 'delivery', 'Delivery']
    }
}

def group_by_domain(objects, patterns):
    """
    按领域分组
    """
    domains = defaultdict(lambda: {
        'description': '',
        'objects': [],
        'aggregate_roots': [],
        'entities': [],
        'value_objects': []
    })

    # 按包名分组
    for obj in objects:
        pkg = obj.get('package', '')
        domain_key = extract_domain_from_package(pkg)

        if domain_key == 'other':
            # 尝试从对象名推断
            name = obj['name']
            for dk, ddef in DOMAIN_DEFINITIONS.items():
                if any(kw.lower() in name.lower() for kw in ddef['keywords']):
                    domain_key = dk
                    break

        # 更新领域描述
        if domain_key not in domains:
            if domain_key in DOMAIN_DEFINITIONS:
                domains[domain_key]['description'] = DOMAIN_DEFINITIONS[domain_key]['description']
            else:
                domains[domain_key]['description'] = f"{domain_key}域"

        # 添加对象
        obj_type = obj.get('type', '值对象')
        domains[domain_key]['objects'].append(obj['name'])

        if obj_type == '聚合根':
            domains[domain_key]['aggregate_roots'].append(obj['name'])
        elif obj_type == '实体':
            domains[domain_key]['entities'].append(obj['name'])
        else:
            domains[domain_key]['value_objects'].append(obj['name'])

    return dict(domains)

def main():
    parser = argparse.ArgumentParser(description='Group Objects by Domain')
    parser.add_argument('--objects', required=True, help='Path to objects JSON')
    parser.add_argument('--patterns', required=True, help='Path to patterns JSON')
    parser.add_argument('--output', default='domains.json', help='Output file')
    args = parser.parse_args()

    print("=" * 60)
    print("L5: Domain Grouping")
    print("=" * 60)

    # 加载数据
    print("\n[1] Loading data...")
    with open(args.objects, 'r', encoding='utf-8') as f:
        objects_data = json.load(f)
    with open(args.patterns, 'r', encoding='utf-8') as f:
        patterns_data = json.load(f)

    objects = objects_data.get('objects', [])
    patterns = patterns_data.get('patterns', [])
    print(f"  Objects: {len(objects)}")
    print(f"  Patterns: {len(patterns)}")

    # 分组
    print("\n[2] Grouping by domain...")
    domains = group_by_domain(objects, patterns)
    print(f"  Found {len(domains)} domains")

    print("\n  Domain summary:")
    for domain, info in sorted(domains.items(), key=lambda x: -len(x[1]['objects'])):
        print(f"    {domain}: {len(info['objects'])} objects, "
              f"{len(info['aggregate_roots'])} agg roots")

    # 保存
    print("\n[3] Saving...")
    result = {
        'level': 5,
        'build_time': datetime.now().isoformat(),
        'summary': {
            'total_domains': len(domains),
            'domain_details': {k: {
                'description': v['description'],
                'object_count': len(v['objects']),
                'aggregate_roots': v['aggregate_roots'][:10],  # 只保留前10个
                'entity_count': len(v['entities']),
                'value_object_count': len(v['value_objects'])
            } for k, v in domains.items()}
        },
        'domains': domains
    }

    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    print(f"  Saved to: {args.output}")

if __name__ == '__main__':
    main()
