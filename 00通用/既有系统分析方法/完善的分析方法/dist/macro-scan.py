# -*- coding: utf-8 -*-
"""
SOP 阶段0：宏观扫描
产出 macro-profile.json（通用版）

支持按业务包过滤，使用标准 Java 包名格式。
"""
import sqlite3
import os
import argparse
from collections import defaultdict
import json
from datetime import datetime

def extract_package_info(path, business_prefix):
    """
    从路径提取包信息
    返回 (is_business, package_name)
    使用标准 Java 包名格式，截断到第四层
    """
    path_norm = path.lower().replace('\\', '/')

    # 查找 src/ 位置
    src_idx = path_norm.find('/src/')
    if src_idx == -1:
        return False, 'other'

    # 取 src/ 后的路径部分
    subpath = path_norm[src_idx + 5:]

    # 分割路径
    parts = subpath.split('/')

    # 过滤掉源码目录前缀，只保留 Java 包路径
    skip_prefixes = {'java', 'kotlin', 'scala', 'src', 'main', 'test'}
    filtered_parts = [p for p in parts if p not in skip_prefixes and not p.endswith('.java')]

    if len(filtered_parts) >= 2:
        # 构建标准包名，截断到前4层（通常是 module.layer.xxx）
        # 例如: com.shouqianba.localserver.dao.po -> com.shouqianba.localserver.dao.po
        max_layers = 4
        truncated = '.'.join(filtered_parts[:max_layers])

        # 检查是否是业务包（精确匹配前缀）
        if business_prefix:
            # 将路径格式的前缀转换为点号格式
            biz_prefix = business_prefix.replace('/', '.')
            if truncated.startswith(biz_prefix):
                return True, truncated

        # 第三方库：返回前两层
        return False, '.'.join(filtered_parts[:2])

    return False, 'other'

def main():
    parser = argparse.ArgumentParser(description='System Macro Scan (Universal)')
    parser.add_argument('--repo', default='D:/kaci-pos-decompiled/kaci-pos-localserver', help='Repo path')
    parser.add_argument('--business-prefix', default='com.shouqianba', help='Business package prefix (e.g., com.company)')
    parser.add_argument('--max-layers', type=int, default=4, help='Max package layers (default: 4)')
    parser.add_argument('--output', default='macro-profile.json', help='Output file')
    args = parser.parse_args()

    repo_path = args.repo
    business_prefix = args.business_prefix

    graph_dir = os.environ.get('CRG_DATA_DIR', f'{repo_path}/.code-review-graph')
    graph_db = f'{graph_dir}/graph.db'

    if not os.path.exists(graph_db):
        print(f"Error: Graph DB not found: {graph_db}")
        return

    conn = sqlite3.connect(graph_db)
    conn.text_factory = str
    cur = conn.cursor()

    print("=" * 60)
    print("System Macro Scan")
    print("=" * 60)
    print(f"Business package prefix: {business_prefix}")
    print(f"Max package layers: {args.max_layers}")

    # 1. Node stats
    print("\n[1] Node Stats...")
    cur.execute("SELECT COUNT(*) FROM nodes WHERE kind = 'Class'")
    total_classes = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM nodes WHERE kind = 'Function'")
    func_count = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM nodes WHERE kind = 'File'")
    file_count = cur.fetchone()[0]
    print(f"  Total Classes: {total_classes:,}")
    print(f"  Total Functions: {func_count:,}")
    print(f"  Total Files: {file_count:,}")

    # 2. 包分布
    print("\n[2] Package Distribution...")
    business_dist = defaultdict(int)
    third_party_dist = defaultdict(int)

    cur.execute("SELECT file_path FROM nodes WHERE kind = 'Class'")
    for row in cur.fetchall():
        path = row[0]
        is_biz, pkg = extract_package_info(path, business_prefix)
        if is_biz:
            business_dist[pkg] += 1
        else:
            third_party_dist[pkg] += 1

    print(f"  Business packages: {sum(business_dist.values()):,}")
    print(f"  Third-party: {sum(third_party_dist.values()):,}")

    print("\n  Business packages (top 20):")
    for pkg, cnt in sorted(business_dist.items(), key=lambda x: -x[1])[:20]:
        print(f"    {pkg}: {cnt}")

    print("\n  Top third-party packages:")
    for pkg, cnt in sorted(third_party_dist.items(), key=lambda x: -x[1])[:10]:
        print(f"    {pkg}: {cnt}")

    # 3. Edge stats
    print("\n[3] Edge Stats...")
    cur.execute("SELECT COUNT(*) FROM edges")
    edge_count = cur.fetchone()[0]
    print(f"  Total edges: {edge_count:,}")

    # 4. Community stats
    print("\n[4] Community Detection...")
    cur.execute("SELECT COUNT(DISTINCT community_id) FROM nodes WHERE community_id IS NOT NULL")
    community_count = cur.fetchone()[0]
    print(f"  Communities: {community_count}")

    conn.close()

    # Generate report
    profile = {
        "scan_time": datetime.now().isoformat(),
        "repo_path": repo_path,
        "business_prefix": business_prefix,
        "max_layers": args.max_layers,
        "code_metrics": {
            "total_classes": total_classes,
            "business_classes": sum(business_dist.values()),
            "third_party_classes": sum(third_party_dist.values()),
            "total_functions": func_count,
            "total_files": file_count,
            "total_edges": edge_count,
        },
        "business_package_distribution": dict(sorted(business_dist.items(), key=lambda x: -x[1])[:50]),
        "third_party_package_distribution": dict(sorted(third_party_dist.items(), key=lambda x: -x[1])[:20]),
        "community_metrics": {"community_count": community_count},
        "ai_budget_estimate": {
            "candidate_objects": sum(business_dist.values()),
            "estimated_ai_calls": max(100, sum(business_dist.values()) // 10)
        }
    }

    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(profile, f, ensure_ascii=False, indent=2)
    print(f"\nProfile saved: {args.output}")

if __name__ == '__main__':
    main()
