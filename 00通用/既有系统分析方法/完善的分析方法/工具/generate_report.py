# -*- coding: utf-8 -*-
"""
生成系统分析报告
使用 analyze_classes.py 生成的数据
"""
import json
import argparse
from collections import defaultdict
from datetime import datetime

def get_args():
    parser = argparse.ArgumentParser(description='生成分析报告')
    parser.add_argument('--input', default='classes_analysis.json', help='输入数据文件')
    parser.add_argument('--output', default='analysis_report.md', help='输出报告文件')
    return parser.parse_args()

def main():
    args = get_args()

    # 读取数据
    with open(args.input, 'r', encoding='utf-8') as f:
        data = json.load(f)

    classes = data['classes']
    print(f"生成报告: {len(classes)} 个类")

    # 生成报告
    report = []
    report.append("# 系统分析报告")
    report.append(f"\n> **分析日期**: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    report.append(f"> **总类数**: {len(classes)}")

    # 1. 总体统计
    report.append("\n" + "=" * 60)
    report.append("## 1. 总体统计")
    report.append("=" * 60)

    package_stats = defaultdict(list)
    for c in classes:
        package_stats[c['package']].append(c)

    report.append("\n| 包路径 | 类数量 | 聚合根 | 实体 | 值对象 |")
    report.append("|--------|-------|-------|------|------|")
    for pkg in sorted(package_stats.keys(), key=lambda x: -len(package_stats[x])):
        pkg_classes = package_stats[pkg]
        agg = len([c for c in pkg_classes if c['po_type'] == '聚合根'])
        entity = len([c for c in pkg_classes if c['po_type'] == '实体'])
        vo = len([c for c in pkg_classes if c['po_type'] == '值对象'])
        report.append(f"| {pkg:20s} | {len(pkg_classes):5d} | {agg:4d} | {entity:4d} | {vo:4d} |")

    # 2. 高引用类
    sorted_by_ref = sorted(classes, key=lambda x: -x['ref_count'])

    report.append("\n" + "=" * 60)
    report.append("## 2. 被引用最多的类 (Top 50)")
    report.append("=" * 60)
    report.append("\n| 排名 | 类名 | 包路径 | 类型 | 被引用 |")
    report.append("|-----|------|-------|------|-------|")
    for i, c in enumerate(sorted_by_ref[:50], 1):
        report.append(f"| {i} | {c['name']} | {c['package']} | {c['po_type']} | {c['ref_count']} |")

    # 3. 聚合根
    agg_roots = [c for c in classes if c['po_type'] == '聚合根']
    sorted_agg = sorted(agg_roots, key=lambda x: -x['ref_count'])

    report.append("\n" + "=" * 60)
    report.append("## 3. 聚合根列表")
    report.append("=" * 60)
    report.append(f"\n**聚合根总数**: {len(sorted_agg)}\n")

    for i, c in enumerate(sorted_agg[:30], 1):
        report.append(f"\n### 3.{i} {c['name']}")
        report.append(f"- **包**: {c['package']}")
        report.append(f"- **字段数**: {c['field_count']}")
        report.append(f"- **被引用**: {c['ref_count']}")

    # 4. 完整类列表
    report.append("\n" + "=" * 60)
    report.append("## 4. 完整类列表 (按包)")
    report.append("=" * 60)

    for pkg in sorted(package_stats.keys(), key=lambda x: -len(package_stats[x])):
        pkg_classes = package_stats[pkg]
        report.append(f"\n### {pkg} ({len(pkg_classes)} 类)")
        for c in sorted(pkg_classes, key=lambda x: -x['ref_count'])[:50]:
            report.append(f"- `{c['name']}` ({c['po_type']}, {c['field_count']}字段)")

    # 写入文件
    with open(args.output, 'w', encoding='utf-8') as f:
        f.write('\n'.join(report))

    print(f"报告已生成: {args.output}")
    print(f"文件大小: {len(open(args.output, encoding='utf-8').read())} 字符")

if __name__ == '__main__':
    main()
