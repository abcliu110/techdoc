# -*- coding: utf-8 -*-
"""
L3: 关系网络构建
分析聚合根之间的关系（ID引用）

从对象树中提取 ID 引用，构建关系网络
"""
import json
import argparse
from collections import defaultdict
from datetime import datetime

def extract_domain_from_package(pkg):
    """
    从包名提取领域
    例如：com.shouqianba.localserver.order.xxx -> order
          com.shouqianba.kaci.scrm.xxx -> scrm
    """
    if not pkg:
        return 'other'

    parts = pkg.split('.')
    # 查找 localserver 或 kaci 后的第一个业务域
    for i, part in enumerate(parts):
        if part in ['localserver', 'kaci']:
            if i + 1 < len(parts):
                return parts[i + 1]

    # 如果没有找到，返回包名最后一段
    return parts[-1] if parts else 'other'

def infer_target_object(field_name, all_objects):
    """
    从字段名推断被引用的对象名
    例如：orderId -> Order, memberId -> Member, orgId -> Org
    """
    # 去掉 Id/ID 后缀
    base_name = field_name
    for suffix in ['ID', 'Id', '_id']:
        if base_name.endswith(suffix):
            base_name = base_name[:-len(suffix)]
            break

    # 常见的映射
    mappings = {
        'group': 'Group',
        'org': 'Org',
        'brand': 'Brand',
        'member': 'Member',
        'customer': 'Customer',
        'order': 'Order',
        'goods': 'Goods',
        'sku': 'Sku',
        'category': 'Category',
        'table': 'Table',
        'shift': 'Shift',
        'payment': 'Payment',
        'pay': 'Pay',
        'promotion': 'Promotion',
        'gift': 'Gift',
        'printer': 'Printer',
        'print': 'Print',
        'user': 'User',
        'role': 'Role',
        'permission': 'Permission',
        'operator': 'Operator',
        'staff': 'Staff',
    }

    # 尝试匹配
    base_lower = base_name.lower()
    for key, obj_name in mappings.items():
        if key in base_lower:
            # 优先找完全匹配的对象
            for obj in all_objects:
                if obj_name.lower() in obj['name'].lower():
                    return obj['name']
            return obj_name

    # 默认返回首字母大写的原名
    return base_name.capitalize()

def build_relationship_network(objects, object_trees):
    """
    从对象树中提取关系
    """
    relationships = []

    for tree in object_trees:
        source = tree['root']
        source_package = tree.get('package', '')
        domain = extract_domain_from_package(source_package)

        for field in tree['fields']:
            if field['classification'] == 'ID引用':
                # 推断被引用的对象
                target_name = infer_target_object(field['name'], objects)

                relationships.append({
                    'source': source,
                    'source_package': source_package,
                    'target_field': field['name'],
                    'target_inferred': target_name,
                    'target_type': 'ID引用',
                    'relationship_type': 'N:1',
                    'domain': domain
                })

    return relationships

def group_by_domain(relationships):
    """
    按领域分组关系
    """
    from collections import defaultdict
    domain_rels = defaultdict(list)
    for rel in relationships:
        domain = rel.get('domain', 'other')
        domain_rels[domain].append(rel)
    return dict(domain_rels)

def main():
    parser = argparse.ArgumentParser(description='Build Relationship Network')
    parser.add_argument('--objects', required=True, help='Path to objects JSON')
    parser.add_argument('--trees', required=True, help='Path to object trees JSON')
    parser.add_argument('--output', default='relationship-network.json', help='Output file')
    args = parser.parse_args()

    print("=" * 60)
    print("L3: Relationship Network Builder")
    print("=" * 60)

    # 加载数据
    print("\n[1] Loading data...")
    with open(args.objects, 'r', encoding='utf-8') as f:
        objects_data = json.load(f)
    with open(args.trees, 'r', encoding='utf-8') as f:
        trees_data = json.load(f)

    objects = objects_data.get('objects', [])
    object_trees = trees_data.get('object_trees', [])
    print(f"  Objects: {len(objects)}")
    print(f"  Object trees: {len(object_trees)}")

    # 构建关系网络
    print("\n[2] Building relationship network...")
    relationships = build_relationship_network(objects, object_trees)
    print(f"  Found {len(relationships)} relationships")

    # 按领域分组
    print("\n[3] Grouping by domain...")
    domain_rels = group_by_domain(relationships)

    print("\n  Domain distribution:")
    for domain, rels in sorted(domain_rels.items(), key=lambda x: -len(x[1])):
        print(f"    {domain}: {len(rels)} relationships")

    # 统计关系类型
    rel_types = defaultdict(int)
    for rel in relationships:
        rel_types[rel['relationship_type']] += 1

    print("\n  Relationship types:")
    for rtype, cnt in sorted(rel_types.items(), key=lambda x: -x[1]):
        print(f"    {rtype}: {cnt}")

    # 保存
    print("\n[4] Saving...")
    result = {
        'level': 3,
        'build_time': datetime.now().isoformat(),
        'summary': {
            'total_relationships': len(relationships),
            'relationship_types': dict(rel_types),
            'domains': len(domain_rels)
        },
        'relationships': relationships,
        'domain_relationships': domain_rels
    }

    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    print(f"  Saved to: {args.output}")

if __name__ == '__main__':
    main()
