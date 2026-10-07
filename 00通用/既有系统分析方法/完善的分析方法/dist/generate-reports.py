# -*- coding: utf-8 -*-
"""
生成人类可读的分析报告
把 JSON 产物转换为 Markdown 文档
"""
import json
import os
import argparse
from datetime import datetime

def generate_executive_summary(objects_data, patterns_data, domains_data, flows_data, relationships_data):
    """生成执行摘要"""
    summary = f"""# 系统分析执行摘要

**分析时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**系统名称**: kaci-pos (来店餐饮POS系统)

---

## 1. 概览统计

| 指标 | 数值 |
|------|------|
| 总对象数 | {objects_data['summary']['total_objects']:,} |
| 聚合根 | {objects_data['summary']['aggregate_roots']} |
| 实体 | {objects_data['summary']['entities']} |
| 值对象 | {objects_data['summary']['value_objects']} |
| 业务模式 | {patterns_data['summary']['patterns_found']} |
| 业务领域 | {domains_data['summary']['total_domains']} |
| 业务服务 | {flows_data['summary']['total_flows']} |
| ID引用关系 | {relationships_data['summary']['total_relationships']} |

---

## 2. 业务领域分布

"""
    for domain, details in sorted(domains_data['summary']['domain_details'].items(), key=lambda x: -x[1]['object_count']):
        summary += f"""### {domain} 域 ({details['description']})

- 对象数: {details['object_count']}
- 聚合根: {len(details.get('aggregate_roots', []))}
- 实体: {details['entity_count']}
- 值对象: {details['value_object_count']}

"""
    return summary

def generate_domain_detail(domains_data, relationships_data):
    """生成领域详情"""
    content = """# 业务领域详情

---

"""
    for domain, info in sorted(domains_data['domains'].items(), key=lambda x: -len(x[1]['objects'])):
        if domain == 'other':
            continue

        content += f"""## {domain} 领域

**描述**: {info.get('description', domain + '域')}
**对象数**: {len(info['objects'])}
**聚合根数**: {len(info['aggregate_roots'])}
**实体数**: {len(info['entities'])}
**值对象数**: {len(info['value_objects'])}

### 聚合根

"""
        for ar in info.get('aggregate_roots', [])[:20]:
            content += f"- `{ar}`\n"

        if len(info.get('aggregate_roots', [])) > 20:
            content += f"- ... 还有 {len(info['aggregate_roots']) - 20} 个\n"

        # 该领域的ID引用关系
        domain_rels = [r for r in relationships_data.get('relationships', []) if r.get('domain') == domain]
        if domain_rels:
            content += f"\n### ID引用关系 (共 {len(domain_rels)} 条)\n\n"
            content += "| 源对象 | 引用字段 | 目标推断 |\n"
            content += "|--------|----------|----------|\n"
            for rel in domain_rels[:20]:
                content += f"| {rel['source']} | {rel['target_field']} | {rel['target_inferred']} |\n"
            if len(domain_rels) > 20:
                content += f"\n*... 还有 {len(domain_rels) - 20} 条关系*\n"

        content += "\n---\n\n"

    return content

def generate_relationship_network(relationships_data, objects_data):
    """生成关系网络"""
    content = """# 关系网络分析

## 概述

| 指标 | 数值 |
|------|------|
| 总关系数 | {total} |
| 领域数 | {domains} |

---

## 按领域分布

""".format(
        total=relationships_data['summary']['total_relationships'],
        domains=relationships_data['summary']['domains']
    )

    domain_rels = {}
    for rel in relationships_data.get('relationships', []):
        domain = rel.get('domain', 'other')
        if domain not in domain_rels:
            domain_rels[domain] = []
        domain_rels[domain].append(rel)

    for domain, rels in sorted(domain_rels.items(), key=lambda x: -len(x[1])):
        content += f"""### {domain} 域 ({len(rels)} 条关系)

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
"""
        for rel in rels[:30]:
            content += f"| {rel['source']} | `{rel['target_field']}` | {rel['target_inferred']} | {rel['relationship_type']} |\n"
        if len(rels) > 30:
            content += f"\n*... 还有 {len(rels) - 30} 条关系*\n"
        content += "\n"

    return content

def generate_patterns(patterns_data):
    """生成业务模式"""
    content = """# 业务模式分析

## 概述

发现 **{total}** 种业务模式：

""".format(total=patterns_data['summary']['patterns_found'])

    for p in patterns_data.get('patterns', []):
        content += f"""### {p['pattern']}

**描述**: {p['description']}
**匹配对象数**: {len(p['matched_objects'])}
**置信度**: {p.get('confidence', 'N/A')}

**匹配对象** (前20个):
"""
        for obj in p['matched_objects'][:20]:
            content += f"- `{obj}`\n"
        if len(p['matched_objects']) > 20:
            content += f"- ... 还有 {len(p['matched_objects']) - 20} 个\n"
        content += "\n"

    return content

def generate_flows(flows_data):
    """生成业务流程"""
    content = """# 业务服务分析

## 概述

| 指标 | 数值 |
|------|------|
| 总服务数 | {total} |
| Service服务 | {service_count} |
| Processor处理器 | {processor_count} |

---

## 按领域分布

""".format(
        total=flows_data['summary']['total_flows'],
        service_count=flows_data['summary'].get('service_count', 0),
        processor_count=flows_data['summary'].get('processor_count', 0)
    )

    domain_flows = flows_data.get('domain_flows', {})
    for domain, val in sorted(domain_flows.items(), key=lambda x: -len(x[1]) if isinstance(x[1], list) else x[1]):
        count = len(val) if isinstance(val, list) else val
        content += f"- **{domain}**: {count} 个服务\n"

    content += "\n## 服务列表\n\n"
    for flow in flows_data.get('flows', [])[:100]:
        content += f"""### {flow['class_name']}

- **领域**: {flow['domain']}
- **包路径**: `{flow['package']}`
- **文件**: {flow['file']}
- **方法数**: {flow['method_count']}

**方法列表**:
"""
        for m in flow.get('methods', [])[:5]:
            params = ', '.join(m.get('param_types', [])[:3])
            content += f"- `{m['name']}({params})`\n"

        if flow.get('dependencies'):
            content += "\n**依赖**:\n"
            for dep in flow.get('dependencies', [])[:5]:
                content += f"- `{dep['type']}`: {dep['name']}\n"

        content += "\n---\n\n"

    return content

def generate_aggregate_roots(objects_data):
    """生成聚合根详情"""
    content = """# 聚合根清单

## 概述

共识别出 **{total}** 个聚合根：

""".format(total=objects_data['summary']['aggregate_roots'])

    # 按包分组
    package_stats = objects_data.get('package_stats', {})
    for pkg, stats in sorted(package_stats.items(), key=lambda x: -x[1]['agg']):
        if stats['agg'] == 0:
            continue
        content += f"""### {pkg}

| 指标 | 数值 |
|------|------|
| 聚合根 | {stats['agg']} |
| 实体 | {stats['entity']} |
| 值对象 | {stats['vo']} |
| 合计 | {stats['total']} |

"""

    # 聚合根列表
    agg_roots = [o for o in objects_data['objects'] if o.get('type') == '聚合根']
    content += "## 聚合根详情\n\n"

    for agg in agg_roots[:50]:
        content += f"""### {agg['name']}

- **类型**: {agg['type']}
- **路径**: `{agg.get('path', 'N/A')}`
- **字段数**: {agg.get('field_count', 0)}
- **有ID**: {'是' if agg.get('has_id') else '否'}

**字段**:
"""
        for f in agg.get('fields', [])[:10]:
            content += f"- `{f['name']}`: {f['type']}\n"
        if len(agg.get('fields', [])) > 10:
            content += f"- ... 还有 {len(agg['fields']) - 10} 个字段\n"
        content += "\n"

    return content

def generate_mermaid_diagrams(objects_data, relationships_data, domains_data, patterns_data):
    """生成 Mermaid 图表"""
    content = """# 关系图谱 (Mermaid)

## 使用说明

以下图表可直接复制到 [Mermaid Live Editor](https://mermaid.live) 查看。

---

## 1. 领域关系总图

```mermaid
graph TD
"""

    # 统计每个领域的入度（被其他领域引用）
    domain_refs = {}
    for rel in relationships_data.get('relationships', []):
        src_domain = rel.get('domain', 'other')
        target = rel.get('target_inferred', '')
        # 尝试推断目标领域
        target_domain = 'other'
        for d in domains_data['domains']:
            if any(target.lower() in obj.lower() for obj in domains_data['domains'][d].get('objects', [])):
                target_domain = d
                break
        if src_domain != target_domain:
            if src_domain not in domain_refs:
                domain_refs[src_domain] = []
            domain_refs[src_domain].append(target_domain)

    # 生成领域节点
    domains = list(set([r.get('domain', 'other') for r in relationships_data.get('relationships', [])]))
    for domain in sorted(domains):
        count = len([r for r in relationships_data.get('relationships', []) if r.get('domain') == domain])
        content += f"    {domain}[(\"{domain}域<br/>{count}条关系\")]\n"

    content += "\n"

    # 生成领域间关系
    added_rels = set()
    for rel in relationships_data.get('relationships', [])[:50]:
        src_domain = rel.get('domain', 'other')
        target = rel.get('target_inferred', '')
        target_domain = 'other'
        for d in domains_data['domains']:
            if any(target.lower() in obj.lower() for obj in domains_data['domains'][d].get('objects', [])):
                target_domain = d
                break

        if src_domain != target_domain:
            rel_key = f"{src_domain}->{target_domain}"
            if rel_key not in added_rels:
                content += f"    {src_domain} -->|{rel.get('target_field')}| {target_domain}\n"
                added_rels.add(rel_key)

    content += "```\n\n"

    # 类图示例
    content += """## 2. 核心聚合根类图

```mermaid
classDiagram
"""

    # 选取核心聚合根生成类图
    agg_roots = [o for o in objects_data['objects'] if o.get('type') == '聚合根' and o.get('has_id')][:15]
    for agg in agg_roots:
        content += f"""    class {agg['name']} {{
        <<aggregate>>
"""
        for f in agg.get('fields', [])[:8]:
            content += f"        {f['name']}: {f['type']}\n"
        content += "    }\n\n"

    # 添加聚合根间关系
    content += "\n    %% 聚合根间关系\n"
    rel_agg = {}
    for rel in relationships_data.get('relationships', [])[:30]:
        src = rel['source']
        tgt = rel['target_inferred']
        if src in [o['name'] for o in agg_roots]:
            content += f"    {src} -->|{rel['target_field']}| {tgt}\n"

    content += "```\n\n"

    # 对象树示例
    content += """## 3. 聚合根对象树示例

聚合根包含的字段结构示例：

```mermaid
graph LR
"""

    for agg in agg_roots[:5]:
        content += f"""    subgraph {agg['name']}
        {agg['name']}[\"{agg['name']}\"]
"""
        for f in agg.get('fields', [])[:5]:
            content += f"        {agg['name']} --> |\"{f['name']}\"| {f['name'].replace('Id', '').replace('ID', '')}Val[\"{f['type']}\"]\n"
        content += "    end\n"

    content += "```\n\n"

    # 模式图
    content += """## 4. 业务模式示意

"""

    for p in patterns_data.get('patterns', [])[:3]:
        content += f"""### {p['pattern']}

```mermaid
graph LR
    subgraph {p['pattern']}
"""
        for obj in p['matched_objects'][:10]:
            content += f"        {obj.replace('-', '').replace(' ', '')}[\"{obj}\"]\n"
        content += "    end\n"
        content += "```\n\n"

    return content

def main():
    parser = argparse.ArgumentParser(description='生成分析报告')
    parser.add_argument('--output-dir', default='reports', help='输出目录')
    args = parser.parse_args()

    print("=" * 60)
    print("生成分析报告")
    print("=" * 60)

    # 确保输出目录存在
    os.makedirs(args.output_dir, exist_ok=True)

    # 加载数据
    print("\n[1] 加载产物...")
    with open('shouqianba-objects.json', encoding='utf-8') as f:
        objects_data = json.load(f)
    with open('shouqianba-domains.json', encoding='utf-8') as f:
        domains_data = json.load(f)
    with open('shouqianba-flows.json', encoding='utf-8') as f:
        flows_data = json.load(f)
    with open('shouqianba-patterns.json', encoding='utf-8') as f:
        patterns_data = json.load(f)
    with open('shouqianba-relationships.json', encoding='utf-8') as f:
        relationships_data = json.load(f)

    # 生成报告
    print("\n[2] 生成执行摘要...")
    with open(os.path.join(args.output_dir, 'README.md'), 'w', encoding='utf-8') as f:
        f.write(generate_executive_summary(objects_data, patterns_data, domains_data, flows_data, relationships_data))

    print("\n[3] 生成领域详情...")
    with open(os.path.join(args.output_dir, '02-domain-details.md'), 'w', encoding='utf-8') as f:
        f.write(generate_domain_detail(domains_data, relationships_data))

    print("\n[4] 生成关系网络...")
    with open(os.path.join(args.output_dir, '03-relationships.md'), 'w', encoding='utf-8') as f:
        f.write(generate_relationship_network(relationships_data, objects_data))

    print("\n[5] 生成业务模式...")
    with open(os.path.join(args.output_dir, '04-patterns.md'), 'w', encoding='utf-8') as f:
        f.write(generate_patterns(patterns_data))

    print("\n[6] 生成业务流程...")
    with open(os.path.join(args.output_dir, '05-flows.md'), 'w', encoding='utf-8') as f:
        f.write(generate_flows(flows_data))

    print("\n[7] 生成聚合根清单...")
    with open(os.path.join(args.output_dir, '06-aggregate-roots.md'), 'w', encoding='utf-8') as f:
        f.write(generate_aggregate_roots(objects_data))

    print("\n[8] 生成Mermaid图表...")
    with open(os.path.join(args.output_dir, '07-mermaid-diagrams.md'), 'w', encoding='utf-8') as f:
        f.write(generate_mermaid_diagrams(objects_data, relationships_data, domains_data, patterns_data))

    print(f"\n[OK] Report generated! Output dir: {args.output_dir}")
    print("\nGenerated files:")
    for f in os.listdir(args.output_dir):
        print(f"  - {f}")

if __name__ == '__main__':
    main()
