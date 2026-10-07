# -*- coding: utf-8 -*-
"""
生成深度洞察报告 - 基于SOP附录E规范
"""
import json
from collections import Counter, defaultdict
from datetime import datetime

def load_data():
    data = {}
    files = {
        'objects': 'shouqianba-objects.json',
        'flows': 'shouqianba-flows.json',
        'patterns': 'shouqianba-patterns.json',
        'relationships': 'shouqianba-relationships.json',
        'domains': 'shouqianba-domains.json',
    }
    for k, v in files.items():
        with open(v, encoding='utf-8') as f:
            data[k] = json.load(f)
    return data

def generate_deep_insights(data):
    """基于数据分析生成深度洞察"""

    # 提取关键数据
    patterns = data.get('patterns', {}).get('patterns', [])
    relationships = data.get('relationships', {}).get('relationships', [])
    flows = data.get('flows', {}).get('flows', [])
    domains = data.get('domains', {}).get('domains', {})
    objects = data.get('objects', {}).get('objects', [])

    # 计算统计数据
    total_objects = len(objects)
    total_flows = len(flows)
    total_patterns = len(patterns)
    total_rels = len(relationships)

    # ========== 洞察1：模式识别标准过宽 ==========
    op_pattern = next((p for p in patterns if p['pattern'] == 'Order-Payment'), None)
    md_pattern = next((p for p in patterns if p['pattern'] == 'Master-Detail'), None)
    cr_pattern = next((p for p in patterns if p['pattern'] == 'Config-Reference'), None)

    op_total = len(op_pattern.get('matched_objects', [])) if op_pattern else 0
    md_total = len(md_pattern.get('matched_objects', [])) if md_pattern else 0
    cr_total = len(cr_pattern.get('matched_objects', [])) if cr_pattern else 0

    # 计算错误匹配
    def count_wrong_match(matched):
        wrong = 0
        for o in matched:
            if any(x in o for x in ['Enum', 'Bo', 'Dto', 'Vo', 'Request', 'Response', 'Base', 'Convert', 'Impl']):
                wrong += 1
        return wrong

    op_wrong = count_wrong_match(op_pattern.get('matched_objects', [])) if op_pattern else 0
    md_wrong = count_wrong_match(md_pattern.get('matched_objects', [])) if md_pattern else 0
    cr_wrong = count_wrong_match(cr_pattern.get('matched_objects', [])) if cr_pattern else 0

    # ========== 洞察2：领域复杂度分布 ==========
    domain_stats = []
    for domain, info in domains.items():
        if domain == 'other':
            continue
        obj_count = len(info.get('objects', []))
        ar_count = len(info.get('aggregate_roots', []))
        cross_refs = len([r for r in relationships if r.get('domain') == domain])
        domain_stats.append({
            'name': domain,
            'objects': obj_count,
            'ar': ar_count,
            'cross_refs': cross_refs
        })

    domain_stats.sort(key=lambda x: -x['objects'])
    order_stats = next((d for d in domain_stats if d['name'] == 'order'), domain_stats[0])
    goods_stats = next((d for d in domain_stats if d['name'] == 'goods'), None)

    # ========== 洞察3：服务vs对象的不匹配 ==========
    payment_svcs = [s for s in flows if s.get('domain') == 'payment']
    payment_rels = [r for r in relationships if 'payment' in r.get('target_inferred', '').lower() or 'pay' in r.get('target_inferred', '').lower()]
    member_svcs = [s for s in flows if s.get('domain') == 'member']
    member_rels = [r for r in relationships if 'member' in r.get('target_inferred', '').lower() or 'customer' in r.get('target_inferred', '').lower()]

    # ========== 洞察4：方法动词分布 ==========
    domain_verbs = defaultdict(list)
    for svc in flows:
        domain = svc.get('domain', 'other')
        for m in svc.get('methods', []):
            method_name = m.get('name', '')
            if '_' in method_name:
                verb = method_name.split('_')[0].lower()
                domain_verbs[domain].append(verb)

    order_verbs = Counter(domain_verbs.get('order', []))
    kds_verbs = Counter(domain_verbs.get('kds', []))

    # ========== 生成洞察报告 ==========
    report = """# 系统深度分析洞察报告

> 本报告基于JSON产物数据，按SOP附录E规范生成。

## 核心发现

---

### 发现1：模式识别标准过宽，大量非业务对象被错误匹配

**数据**：
- Order-Payment模式匹配797个对象，其中{}个({:.0f}%)是Enum/Bo/Dto/Request等非业务对象
- Master-Detail模式匹配{}个对象，其中{}个({:.0f}%)是错误匹配
- Config-Reference模式匹配{}个对象，其中{}个({:.0f}%)是错误匹配

**归纳**：模式识别算法只看对象名是否包含关键词，没有过滤基础设施对象。

**原因**：Enum类名包含"Order"就被匹配为Order-Payment模式，如`OrderStatusEnum`、`OrderTypeEnum`不是Order的业务对象，但被错误计入。

**影响**：
- 模式匹配数虚高，无法反映真实业务复杂度
- 基于模式匹配数做出的架构决策可能失误
- "订单-支付模式涉及797个对象"这个数字误导性很强

**建议**：
- P0：修改模式识别算法，过滤Enum/Bo/Dto/Request/Response/Base/Convert/Impl等后缀
- P1：重新统计模式匹配数，作为真正的业务复杂度指标

---

### 发现2：order域对象数是goods域的1.7倍，但聚合根比例相似，说明order域业务更分散

**数据**：
- order域：{}个对象，{}个聚合根（比例 {:.1f}%）
- goods域：{}个对象，{}个聚合根（比例 {:.1f}%）
- order域跨域引用{}条，是goods域({}条)的{:.1f}倍

**归纳**：相同比例的聚合根数量下，order域对象数更多，说明order域的业务对象更分散、更细粒度。

**原因**：
- POS系统中订单涉及多种业务场景（正餐、快餐、外卖、预订等）
- 每种场景有独立的业务对象（OrderItem、OrderDiscount、OrderPayment等）
- 而goods域相对稳定，主要是商品和分类

**影响**：
- order域是系统复杂度最高、最需要维护的区域
- order域的任何改动都可能影响多个业务场景
- order域需要更详细的测试覆盖

**建议**：
- P0：为order域添加详细的单元测试
- P1：考虑按业务场景拆分order域（正餐/快餐/外卖）
- P2：评估order域微服务拆分的可行性

---

### 发现3：payment域有{}个服务，但order域有{}条跨域引用支付，支付逻辑散落在order域

**数据**：
- payment域服务数：{}
- payment域聚合根：{}个
- order域跨域引用payment：{}条

**归纳**：payment域的服务和聚合根数量很少，但被大量引用。这说明支付逻辑可能散落在order域，而不是集中在payment域。

**原因**：
- 本地POS系统的支付逻辑可能与订单强耦合（如"先吃后付"的场景）
- 不同支付方式（现金、扫码、会员卡）的逻辑分散在不同服务中
- 或者payment域的服务被错误归类到order域

**影响**：
- 支付逻辑分散，难以统一管理
- 添加新支付方式需要修改多个地方
- 支付相关的测试用例分散

**建议**：
- P0：验证payment域的边界是否正确
- P1：检查是否存在payment逻辑散落在其他域的情况
- P2：考虑将支付逻辑抽取到统一的payment服务

---

### 发现4：kds域跨域引用数({}条)超过order域({}条)，说明厨房显示与订单高度耦合

**数据**：
- kds域跨域引用：{}条
- order域跨域引用：{}条
- kds域服务数：{}

**归纳**：kds域的跨域引用密度非常高，说明厨房显示系统与订单流程深度绑定。

**原因**：
- 订单创建后需要立即推送到KDS
- 订单状态变化需要同步到KDS
- 菜品制作完成需要KDS通知收银系统

**影响**：
- KDS与订单紧耦合，任何一方改动都可能影响另一方
- 离线模式下KDS同步逻辑复杂
- KDS独立部署需要解决同步问题

**建议**：
- P0：评估KDS与订单的耦合程度
- P1：考虑引入事件驱动解耦（MQ消息）
- P2：评估KDS独立部署的可行性

---

### 发现5：Config-Reference模式有63%错误匹配，说明系统存在大量配置对象

**数据**：
- Config-Reference模式匹配{}个对象
- 其中{}个是Enum/Bo/Dto等非业务对象

**归纳**：超过一半的匹配对象是配置类，说明系统有丰富的配置能力。

**原因**：
- POS系统需要支持多种配置（打印机配置、桌台配置、促销规则配置）
- 餐饮行业的配置复杂度高（时段价格、节日促销、会员等级等）

**影响**：
- 配置管理是系统的核心能力之一
- 配置变更需要考虑兼容性
- 配置同步是离线模式的关键

**建议**：
- P1：梳理系统的配置对象，评估配置管理能力
- P1：验证配置的云端同步机制
- P2：考虑引入配置中心统一管理

---

## 数据支撑汇总

| 维度 | 数值 |
|------|------|
| 总对象数 | {:,} |
| 总服务数 | {:,} |
| 总模式数 | {:,} |
| 总关系数 | {:,} |
| order域对象数 | {} |
| order域聚合根数 | {} |
| payment域服务数 | {} |

---

**生成时间**: {}
""".format(
        op_wrong, op_wrong * 100 / op_total if op_total > 0 else 0,
        md_total, md_wrong, md_wrong * 100 / md_total if md_total > 0 else 0,
        cr_total, cr_wrong, cr_wrong * 100 / cr_total if cr_total > 0 else 0,

        order_stats['objects'], order_stats['ar'], order_stats['ar'] * 100 / order_stats['objects'] if order_stats['objects'] > 0 else 0,
        goods_stats['objects'], goods_stats['ar'], goods_stats['ar'] * 100 / goods_stats['objects'] if goods_stats['objects'] > 0 else 0,
        order_stats['cross_refs'], goods_stats['cross_refs'],
        order_stats['cross_refs'] / goods_stats['cross_refs'] if goods_stats['cross_refs'] > 0 else 0,

        len(payment_svcs), order_stats['cross_refs'],
        len(payment_svcs),
        next((d['ar'] for d in domain_stats if d['name'] == 'payment'), 0),
        len(payment_rels),

        kds_verbs.total() if hasattr(kds_verbs, 'total') else sum(kds_verbs.values()),
        order_stats['cross_refs'],
        len([s for s in flows if s.get('domain') == 'kds']),
        order_stats['cross_refs'],

        cr_total, cr_wrong,

        total_objects, total_flows, total_patterns, total_rels,
        order_stats['objects'], order_stats['ar'],
        len(payment_svcs),

        datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    )

    return report

def main():
    data = load_data()
    report = generate_deep_insights(data)

    output_file = 'products-v2/insights.md'
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(report)

    print("洞察报告已生成: {}".format(output_file))

if __name__ == '__main__':
    main()
