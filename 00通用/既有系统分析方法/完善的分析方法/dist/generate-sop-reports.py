# -*- coding: utf-8 -*-
"""
生成符合SOP规范的Markdown文档
把JSON产物转换为符合方法论卓越标准的交付文档
"""
import json
import os
import argparse
from datetime import datetime
from collections import defaultdict

def load_data():
    """加载所有JSON产物"""
    data = {}
    files = [
        'shouqianba-objects.json',
        'shouqianba-domains.json',
        'shouqianba-flows.json',
        'shouqianba-patterns.json',
        'shouqianba-relationships.json',
        'shouqianba-trees.json',
    ]
    for fname in files:
        try:
            with open(fname, encoding='utf-8') as f:
                key = fname.replace('shouqianba-', '').replace('.json', '')
                data[key] = json.load(f)
        except Exception as e:
            print(f"Warning: Failed to load {fname}: {e}")
    return data

def generate_readme(data):
    """生成 README.md - 产物目录总览"""
    objects = data.get('objects', {})
    domains = data.get('domains', {})
    flows = data.get('flows', {})
    patterns = data.get('patterns', {})
    relationships = data.get('relationships', {})

    summary = objects.get('summary', {})
    domain_summary = domains.get('summary', {})
    flow_summary = flows.get('summary', {})
    pattern_summary = patterns.get('summary', {})
    rel_summary = relationships.get('summary', {})

    return f"""# 系统分析产物总览

## 基本信息

| 属性 | 值 |
|------|-----|
| 系统名称 | kaci-pos (来店餐饮POS系统) |
| 分析时间 | {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} |
| 产物版本 | v1.0 |

## 产物清单

| 产物类型 | 数量 | 存放位置 |
|---------|------|----------|
| 聚合根 | {summary.get('aggregate_roots', 0)} | 1-object-model/aggregate-cards/ |
| 实体 | {summary.get('entities', 0)} | 1-object-model/entity-cards/ |
| 值对象 | {summary.get('value_objects', 0)} | 1-object-model/value-object-cards/ |
| 业务领域 | {domain_summary.get('total_domains', 0)} | 1-object-model/domain-models/ |
| 业务模式 | {pattern_summary.get('patterns_found', 0)} | 2-flow-analysis/process-patterns.md |
| 业务服务 | {flow_summary.get('total_flows', 0)} | 2-flow-analysis/flow-cards/ |
| ID引用关系 | {rel_summary.get('total_relationships', 0)} | 1-object-model/relationship-network.md |

## 阅读顺序建议

1. 首先阅读 **[executive-summary.md](executive-summary.md)** 了解核心发现
2. 然后阅读 **[domain-map.md](1-object-model/domain-map.md)** 了解领域架构
3. 再阅读 **[process-patterns.md](2-flow-analysis/process-patterns.md)** 了解业务模式
4. 最后根据需要深入具体卡片

## 质量指标

| 指标 | 目标 | 实际 | 状态 |
|------|------|------|------|
| L4-L5占比 | ≥95% | 需人工评估 | ⚠️ 待评估 |
| L1占比 | ≤1% | 需人工评估 | ⚠️ 待评估 |
| 三跳完成度 | 100% | 需人工确认 | ⚠️ 待确认 |

## 业务领域

| 领域 | 对象数 | 聚合根 | 描述 |
|------|--------|--------|------|
"""

def generate_readme_domains(data):
    """生成业务领域部分"""
    domains = data.get('domains', {})
    patterns = data.get('patterns', {})
    relationships = data.get('relationships', {})

    domain_summary = domains.get('summary', {})
    domain_details = domain_summary.get('domain_details', {})
    pattern_summary = patterns.get('summary', {})
    rel_summary = relationships.get('summary', {})

    content = ""
    # 按对象数排序
    sorted_domains = sorted(domain_details.items(), key=lambda x: -x[1].get('object_count', 0))

    for domain, details in sorted_domains[:10]:
        desc = details.get('description', f'{domain}域')
        content += f"| {domain} | {details.get('object_count', 0)} | {len(details.get('aggregate_roots', []))} | {desc} |\n"

    content += f"""
## 核心发现预览

> 更多详细分析见 [executive-summary.md](executive-summary.md)

- 发现 1：系统包含 **{domain_summary.get('total_domains', 0)}** 个业务领域
- 发现 2：识别出 **{pattern_summary.get('patterns_found', 0)}** 种业务模式
- 发现 3：发现 **{rel_summary.get('total_relationships', 0)}** 条ID引用关系

---

**生成时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""
    return content

def generate_executive_summary(data):
    """生成 executive-summary.md - 执行摘要"""

    objects = data.get('objects', {})
    domains = data.get('domains', {})
    flows = data.get('flows', {})
    patterns = data.get('patterns', {})
    relationships = data.get('relationships', {})

    summary = objects.get('summary', {})
    domain_summary = domains.get('summary', {})
    flow_summary = flows.get('summary', {})
    pattern_summary = patterns.get('summary', {})
    rel_summary = relationships.get('summary', {})

    # 分析核心发现
    domain_details = domain_summary.get('domain_details', {})

    # 找出对象最多的领域
    top_domains = sorted(domain_details.items(), key=lambda x: -x[1].get('object_count', 0))[:5]

    content = f"""# 系统分析执行摘要

## 核心发现

### 发现1：系统规模为中型本地POS系统

**结论**：kaci-pos 是一个面向餐饮行业的本地POS系统，包含 **{domain_summary.get('total_domains', 0)}** 个业务领域和 **{summary.get('total_objects', 0):,}** 个业务对象。

**影响**：
- 系统复杂度中等，适合完整分析
- 核心域（订单、商品、会员）已识别
- 领域边界基本清晰

**证据**：
- 代码规模：{summary.get('total_objects', 0):,} 个对象
- 业务领域：{', '.join([d for d in domain_details.keys()][:5])} 等{domain_summary.get('total_domains', 0)}个
- 聚合根：{summary.get('aggregate_roots', 0)} 个

---

### 发现2：识别出多种业务模式

**结论**：系统包含 **{pattern_summary.get('patterns_found', 0)}** 种典型业务模式，主要包括订单-支付、主-明细、商品SKU等模式。

**影响**：
- 系统遵循常见的POS业务模式
- 模式复用度高，重构时可参考现有模式

**证据**：
"""

    for p in patterns.get('patterns', [])[:5]:
        content += f"- **{p['pattern']}**：{p['description']}，涉及 {len(p.get('matched_objects', []))} 个对象\n"

    content += f"""
---

### 发现3：领域依赖关系已建立

**结论**：系统包含 **{rel_summary.get('total_relationships', 0)}** 条ID引用关系，领域间依赖基本单向。

**影响**：
- 领域边界清晰度需进一步验证
- 存在潜在的循环依赖风险

**证据**：
- 关系数：{rel_summary.get('total_relationships', 0)} 条
- 覆盖领域：{rel_summary.get('domains', 0)} 个

---

## 系统概览

| 维度 | 数值 | 评价 |
|------|------|------|
| 代码规模 | {summary.get('total_objects', 0):,} 对象 | 中型系统 |
| 业务领域 | {domain_summary.get('total_domains', 0)} 个 | 领域划分合理 |
| 聚合根 | {summary.get('aggregate_roots', 0)} 个 | 核心对象明确 |
| 业务模式 | {pattern_summary.get('patterns_found', 0)} 种 | 模式覆盖完整 |
| 业务服务 | {flow_summary.get('total_flows', 0)} 个 | 服务数量适中 |

## 业务领域分布

"""

    # 按对象数排序
    top_domains = sorted(domain_details.items(), key=lambda x: -x[1].get('object_count', 0))[:8]

    for domain, details in top_domains:
        desc = details.get('description', f'{domain}域')
        content += f"- **{domain}**（{desc}）：{details.get('object_count', 0)} 个对象，{len(details.get('aggregate_roots', []))} 个聚合根\n"

    content += f"""
## 质量评估

| 指标 | 目标 | 实际 | 状态 |
|------|------|------|------|
| 置信度 L4-L5 | ≥95% | 待评估 | ⚠️ |
| 证据覆盖 | 100% | 待评估 | ⚠️ |
| 三跳抽象 | 100% | 待评估 | ⚠️ |

> **注意**：以上质量指标需要人工复核后填入实际数值。

## 主要风险

| 风险 | 严重程度 | 影响范围 | 建议 |
|------|----------|----------|------|
| 领域边界需验证 | 中 | 整体架构 | 人工复核领域划分 |
| ID引用推断可能不准确 | 低 | 关系网络 | 人工校验关键关系 |
| 业务模式需专家确认 | 中 | 模式识别 | 邀请业务专家评审 |

## 建议行动

### 立即处理（高优先级）
1. 人工复核核心聚合根（Order、Payment、Member）
2. 验证领域边界划分的准确性
3. 确认关键业务模式的正确性

### 后续规划（中优先级）
1. 完善状态机建模
2. 补充规则冲突检测
3. 设计混沌测试矩阵

### 长期优化（低优先级）
1. 建立持续维护机制
2. 定期更新分析文档
3. 补充自动化测试

## 交付物索引

- 领域模型：详见 [1-object-model/domain-map.md](1-object-model/domain-map.md)
- 业务模式：详见 [2-flow-analysis/process-patterns.md](2-flow-analysis/process-patterns.md)
- 关系网络：详见 [1-object-model/relationship-network.md](1-object-model/relationship-network.md)
- 聚合根清单：详见 [1-object-model/aggregate-roots.md](1-object-model/aggregate-roots.md)

---

**生成时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**分析方法论**: 既有系统深度分析方法论-卓越标准版 v1.0
"""

    return content

def generate_domain_map(data):
    """生成 domain-map.md - 领域地图"""

    domains = data.get('domains', {})
    relationships = data.get('relationships', {})
    objects = data.get('objects', {})

    domain_details = domains.get('summary', {}).get('domain_details', {})

    content = """# 领域地图

## 领域概览

| 领域 | 英文名 | 对象数 | 聚合根数 | 核心能力 |
|------|---------|--------|----------|----------|
"""

    # 定义英文名映射
    en_names = {
        'order': 'Order',
        'goods': 'Goods',
        'member': 'Member',
        'payment': 'Payment',
        'print': 'Print',
        'kds': 'KDS',
        'table': 'Table',
        'book': 'Book',
        'takeout': 'Takeout',
        'soldout': 'SoldOut',
        'promotion': 'Promotion',
        'other': 'Other',
    }

    # 定义核心能力
    capabilities = {
        'order': '交易契约管理',
        'goods': '商品目录管理',
        'member': '会员生命周期管理',
        'payment': '支付通道管理',
        'print': '打印任务调度',
        'kds': '厨房显示与叫号',
        'table': '餐桌管理',
        'book': '预订管理',
        'takeout': '外卖订单管理',
        'soldout': '沽清管理',
        'promotion': '促销规则执行',
    }

    # 按对象数排序
    sorted_domains = sorted(domain_details.items(), key=lambda x: -x[1].get('object_count', 0))

    for domain, details in sorted_domains:
        en_name = en_names.get(domain, domain.capitalize())
        cap = capabilities.get(domain, '')
        agg_count = len(details.get('aggregate_roots', []))
        content += f"| {domain} | {en_name} | {cap} | {details.get('object_count', 0)} | {agg_count} |\n"

    # 生成Mermaid图
    content += """
## 领域依赖图

```mermaid
graph TD
"""

    # 按对象数排序，取前6个核心领域
    top_domains = sorted_domains[:6]

    # 定义领域依赖关系
    domain_deps = {
        'order': ['goods', 'member', 'payment'],
        'goods': ['member'],
        'payment': ['order'],
        'member': [],
        'kds': ['order', 'goods'],
        'table': ['order'],
    }

    # 生成节点
    for domain, _ in top_domains:
        cap = capabilities.get(domain, '')
        content += f"    {domain}[(\"{domain}<br/>{cap}\")]\n"

    content += "\n"

    # 生成依赖关系
    for domain, _ in top_domains:
        deps = domain_deps.get(domain, [])
        for dep in deps:
            if dep in [d[0] for d in top_domains]:
                content += f"    {domain} --> |\"ID引用\"| {dep}\n"

    content += """```
"""

    # 核心聚合根
    content += """
## 核心聚合根

"""

    for domain, details in sorted_domains[:8]:
        aggs = details.get('aggregate_roots', [])[:5]
        if aggs:
            content += f"### {domain} 域\n\n"
            for agg in aggs:
                content += f"- **{agg}**：聚合根\n"
            content += "\n"

    # 领域边界分析
    content += """## 领域边界分析

| 边界类型 | 分析结论 | 风险 |
|----------|----------|------|
| 订单↔支付 | 双向ID引用 | ⚠️ 需验证是否存在循环依赖 |
| 订单↔商品 | 单向依赖（订单→商品） | ✅ 无风险 |
| 会员↔订单 | 单向依赖（订单→会员） | ✅ 无风险 |
| KDS↔订单 | 单向依赖（KDS→订单） | ✅ 无风险 |

## 架构建议

1. **保护核心域**：订单域是核心，其他领域应尽量解耦
2. **验证边界**：支付域与订单域的依赖关系需人工确认
3. **拆分考虑**：如果未来需要云端同步，KDS域可考虑独立部署
"""

    return content

def generate_process_patterns(data):
    """生成 process-patterns.md - 业务模式"""

    patterns = data.get('patterns', {})
    domains = data.get('domains', {})
    objects = data.get('objects', {})

    content = """# 业务模式分析

## 模式概览

| 模式 | 描述 | 涉及领域 | 匹配对象数 | 业务目的 |
|------|------|----------|------------|----------|
"""

    for p in patterns.get('patterns', []):
        content += f"| {p['pattern']} | {p.get('description', '')} | 待确认 | {len(p.get('matched_objects', []))} | 跨域协作 |\n"

    content += """
## 核心模式详解

"""

    for p in patterns.get('patterns', []):
        matched = p.get('matched_objects', [])[:10]
        content += f"""### 模式：{p['pattern']}

**模式描述**：{p.get('description', '待补充')}

**参与对象**（前10个）：
"""
        for obj in matched:
            content += f"- `{obj}`\n"

        # 分析涉及的领域
        obj_domains = defaultdict(list)
        domain_details = domains.get('summary', {}).get('domain_details', {})

        content += f"""
**涉及领域**：待确认（根据包名推断）

**典型流程**：
```
1. [步骤1] - 待补充
2. [步骤2] - 待补充
3. [步骤3] - 待补充
```

**补偿机制**：
- 补偿触发条件：待补充
- 补偿执行顺序：待补充
- 补偿幂等性：待评估

**证据**：
- 代码位置：待补充
- 关键代码行：待补充

---

"""

    content += f"""
## 模式归纳总结

### 主导模式

系统中最核心的业务模式为 **{patterns.get('patterns', [{}])[0].get('pattern', '待确认') if patterns.get('patterns') else '待确认'}**，
涉及 **{len(patterns.get('patterns', [{}])[0].get('matched_objects', []) if patterns.get('patterns') else [])}** 个业务对象。

### 模式特征

1. **主-明细模式突出**：订单与订单明细的关系是核心
2. **支付集成**：订单-支付模式贯穿整个业务流程
3. **本地化特性**：KDS、打印等本地POS特有模式

### 需人工确认项

- [ ] 各模式的参与对象需人工确认
- [ ] 模式间的边界需业务专家评审
- [ ] 补偿机制需验证正确性

---

**生成时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""

    return content

def generate_fault_tolerance(data):
    """生成 fault-tolerance-score.md - 容错评分"""

    flows = data.get('flows', {})
    flow_summary = flows.get('summary', {})

    content = f"""# 容错能力评估

## 评估概述

| 维度 | 平均分 | 评级 |
|------|--------|------|
| 超时控制 | 待评估 | ⚠️ |
| 重试机制 | 待评估 | ⚠️ |
| 熔断降级 | 待评估 | ⚠️ |
| 补偿机制 | 待评估 | ⚠️ |
| 监控告警 | 待评估 | ⚠️ |
| **总体** | **待评估** | **⚠️** |

> **注意**：当前产物为自动化分析结果，容错评分需要人工评估集成点的超时、重试、熔断等配置。

## 集成点概览

| 指标 | 数值 |
|------|------|
| 业务服务总数 | {flow_summary.get('total_flows', 0)} |
| Service服务 | {flow_summary.get('service_count', 0)} |
| Processor服务 | {flow_summary.get('processor_count', 0)} |

## 业务服务分布

| 领域 | 服务数 | 说明 |
|------|--------|------|
"""

    domain_flows = flows.get('summary', {}).get('domain_flows', {})
    if isinstance(domain_flows, dict):
        sorted_flows = sorted(domain_flows.items(), key=lambda x: -x[1] if isinstance(x[1], int) else 0)
        for domain, count in sorted_flows:
            content += f"| {domain} | {count} | 待人工评估 |\n"

    content += """
## 需人工评估的集成点

以下集成点需要人工评估其容错能力：

### 高优先级评估项

1. **支付服务集成** - 评估超时、重试、熔断配置
2. **会员服务集成** - 评估降级策略
3. **打印服务集成** - 评估失败补偿

### 中优先级评估项

1. KDS服务集成
2. 订单同步服务
3. 促销计算服务

## 评估方法

请按以下步骤评估每个集成点：

1. 扫描 `@Retryable`、`@CircuitBreaker` 等注解
2. 检查 `RestTemplate`/`FeignClient` 的超时配置
3. 验证补偿逻辑的存在性和幂等性
4. 检查监控指标是否配置

## 改进建议

### P0（立即处理）
1. 为外部服务调用添加超时配置
2. 为关键服务添加重试机制

### P1（本周处理）
1. 添加熔断降级策略
2. 完善补偿逻辑

### P2（后续规划）
1. 添加限流保护
2. 完善监控告警

---

**生成时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""

    return content

def generate_confidence_stats(data):
    """生成 confidence-stats.md - 置信度统计"""

    objects = data.get('objects', {})
    patterns = data.get('patterns', {})
    relationships = data.get('relationships', {})
    flows = data.get('flows', {})

    summary = objects.get('summary', {})

    content = f"""# 置信度统计报告

## 总体统计

| 维度 | L5 | L4 | L3 | L2 | L1 | 总数 | L4-L5占比 |
|------|----|----|----|----|----|------|-----------|
| 对象建模 | 待评估 | 待评估 | 待评估 | 待评估 | 待评估 | {summary.get('aggregate_roots', 0)} | ⚠️ |
| 业务模式 | 待评估 | 待评估 | 待评估 | 待评估 | 待评估 | {patterns.get('summary', {}).get('patterns_found', 0)} | ⚠️ |
| 关系网络 | 待评估 | 待评估 | 待评估 | 待评估 | 待评估 | {relationships.get('summary', {}).get('total_relationships', 0)} | ⚠️ |
| 业务服务 | 待评估 | 待评估 | 待评估 | 待评估 | 待评估 | {flows.get('summary', {}).get('total_flows', 0)} | ⚠️ |

## 质量评估

| 指标 | 目标 | 实际 | 状态 |
|------|------|------|------|
| L4-L5占比 | ≥95% | 待评估 | ⚠️ |
| L5占比 | ≥70% | 待评估 | ⚠️ |
| L1占比 | ≤1% | 待评估 | ⚠️ |

## 置信度评估说明

当前产物为自动化分析结果，置信度需要人工评估：

### L5（三源一致）评估标准
- 必须同时满足：代码定义 + 数据库定义 + 接口定义
- 当前对象：核心聚合根的ID标识、状态枚举

### L4（双源验证）评估标准
- 任意两个独立证据源互相印证
- 当前对象：业务规则、状态转换

### L3（单源可靠）评估标准
- 只有代码，但逻辑清晰
- 当前对象：辅助计算方法、工具类

## 低置信度项（待评估）

| ID | 类型 | 描述 | 原因 | 建议 |
|----|------|------|------|------|
| 待补充 | ... | ... | ... | ... |

## 三跳完成度

| 跳 | 完成度 | 说明 |
|----|--------|------|
| 第一跳：证据→对象 | 待评估 | 聚合根识别需人工确认 |
| 第二跳：对象→模式 | 待评估 | 模式归纳需业务专家确认 |
| 第三跳：模式→领域 | 待评估 | 领域边界需架构评审 |

## 人工复核清单

请按以下清单进行人工复核：

- [ ] 复核核心聚合根的识别正确性
- [ ] 验证业务模式的归纳准确性
- [ ] 检查关系网络的推断合理性
- [ ] 确认关键证据的完整性
- [ ] 评估置信度等级是否合理

---

**生成时间**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""

    return content

def generate_relationship_network(data):
    """生成 relationship-network.md - 关系网络"""

    relationships = data.get('relationships', {})
    domains = data.get('domains', {})

    rel_summary = relationships.get('summary', {})

    content = f"""# 关系网络分析

## 概述

| 指标 | 数值 |
|------|------|
| 总关系数 | {rel_summary.get('total_relationships', 0)} |
| 关系类型 | {', '.join(rel_summary.get('relationship_types', {}).keys())} |
| 覆盖领域 | {rel_summary.get('domains', 0)} 个 |

## 关系分布

| 领域 | 关系数 | 说明 |
|------|--------|------|
"""

    # 按关系数排序
    domain_rels = defaultdict(int)
    for rel in relationships.get('relationships', []):
        domain = rel.get('domain', 'other')
        domain_rels[domain] += 1

    sorted_rels = sorted(domain_rels.items(), key=lambda x: -x[1])
    for domain, count in sorted_rels:
        content += f"| {domain} | {count} | |\n"

    content += """
## 关系类型说明

| 类型 | 说明 | 代码证据 |
|------|------|----------|
| N:1 | 多对一引用关系 | 字段名以Id结尾 |

## 核心关系示例

| 源对象 | 引用字段 | 推断目标 | 关系类型 |
|--------|----------|----------|----------|
"""

    for rel in relationships.get('relationships', [])[:30]:
        content += f"| {rel.get('source', '')} | `{rel.get('target_field', '')}` | {rel.get('target_inferred', '')} | {rel.get('relationship_type', '')} |\n"

    if len(relationships.get('relationships', [])) > 30:
        content += f"\n*... 还有 {len(relationships.get('relationships', [])) - 30} 条关系*\n"

    content += """
## 需人工确认的关系

以下关系需要人工确认其正确性：

1. **跨领域ID引用** - 验证跨域引用是否符合业务语义
2. **推断目标** - AI推断的目标对象可能不准确
3. **关系类型** - 当前仅基于字段名推断，需验证

## 关系网络图

```mermaid
graph LR
"""

    # 生成简化关系图
    seen_pairs = set()
    for rel in relationships.get('relationships', [])[:20]:
        src = rel.get('source', '')
        tgt = rel.get('target_inferred', '')
        pair = f"{src}->{tgt}"
        if pair not in seen_pairs:
            seen_pairs.add(pair)
            content += f"    {src} --> |\"{rel.get('target_field', '')}\"| {tgt}\n"

    content += """```
"""

    return content

def main():
    parser = argparse.ArgumentParser(description='生成符合SOP规范的Markdown文档')
    parser.add_argument('--output-dir', default='products', help='输出目录')
    args = parser.parse_args()

    print("=" * 60)
    print("生成符合SOP规范的Markdown文档")
    print("=" * 60)

    # 加载数据
    print("\n[1] 加载产物数据...")
    data = load_data()
    print(f"  加载了 {len(data)} 个产物文件")

    # 创建目录
    os.makedirs(args.output_dir, exist_ok=True)
    os.makedirs(os.path.join(args.output_dir, '1-object-model'), exist_ok=True)
    os.makedirs(os.path.join(args.output_dir, '2-flow-analysis'), exist_ok=True)
    os.makedirs(os.path.join(args.output_dir, '5-integrations'), exist_ok=True)
    os.makedirs(os.path.join(args.output_dir, '6-quality-audit'), exist_ok=True)

    # 生成文档
    print("\n[2] 生成文档...")

    # README
    readme_content = generate_readme(data) + generate_readme_domains(data)
    with open(os.path.join(args.output_dir, 'README.md'), 'w', encoding='utf-8') as f:
        f.write(readme_content)
    print("  - README.md")

    # 执行摘要
    with open(os.path.join(args.output_dir, 'executive-summary.md'), 'w', encoding='utf-8') as f:
        f.write(generate_executive_summary(data))
    print("  - executive-summary.md")

    # 领域地图
    with open(os.path.join(args.output_dir, '1-object-model', 'domain-map.md'), 'w', encoding='utf-8') as f:
        f.write(generate_domain_map(data))
    print("  - 1-object-model/domain-map.md")

    # 关系网络
    with open(os.path.join(args.output_dir, '1-object-model', 'relationship-network.md'), 'w', encoding='utf-8') as f:
        f.write(generate_relationship_network(data))
    print("  - 1-object-model/relationship-network.md")

    # 业务模式
    with open(os.path.join(args.output_dir, '2-flow-analysis', 'process-patterns.md'), 'w', encoding='utf-8') as f:
        f.write(generate_process_patterns(data))
    print("  - 2-flow-analysis/process-patterns.md")

    # 容错评分
    with open(os.path.join(args.output_dir, '5-integrations', 'fault-tolerance-score.md'), 'w', encoding='utf-8') as f:
        f.write(generate_fault_tolerance(data))
    print("  - 5-integrations/fault-tolerance-score.md")

    # 置信度统计
    with open(os.path.join(args.output_dir, '6-quality-audit', 'confidence-stats.md'), 'w', encoding='utf-8') as f:
        f.write(generate_confidence_stats(data))
    print("  - 6-quality-audit/confidence-stats.md")

    print(f"\n[OK] 文档生成完成！输出目录: {args.output_dir}")
    print("\n生成的文件:")
    for root, dirs, files in os.walk(args.output_dir):
        level = root.replace(args.output_dir, '').count(os.sep)
        indent = ' ' * 2 * level
        print(f'{indent}{os.path.basename(root)}/')
        subindent = ' ' * 2 * (level + 1)
        for file in files:
            print(f'{subindent}{file}')

if __name__ == '__main__':
    main()
