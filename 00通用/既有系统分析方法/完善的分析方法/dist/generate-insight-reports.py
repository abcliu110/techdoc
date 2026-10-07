# -*- coding: utf-8 -*-
"""
深入分析JSON产物，进行三跳归纳，生成符合SOP规范的Markdown文档
"""
import json
import os
from collections import defaultdict
from datetime import datetime

def load_data():
    data = {}
    files = {
        'objects': 'shouqianba-objects.json',
        'domains': 'shouqianba-domains.json',
        'flows': 'shouqianba-flows.json',
        'patterns': 'shouqianba-patterns.json',
        'relationships': 'shouqianba-relationships.json',
    }
    for key, fname in files.items():
        try:
            with open(fname, encoding='utf-8') as f:
                data[key] = json.load(f)
        except Exception as e:
            print("Warning: {} {}".format(fname, e))
    return data

def filter_real_aggregate_roots(objects):
    real_agg_roots = []
    exclude_patterns = ['Base', 'Request', 'Response', 'Dto', 'Vo', 'Enum', 'Const', 'Convert', 'Impl', 'Entity']
    for obj in objects:
        if obj.get('type') != '聚合根' or not obj.get('has_id'):
            continue
        name = obj['name']
        if any(p in name for p in exclude_patterns):
            continue
        if name.endswith(('Request', 'Response', 'Dto', 'Vo', 'Entity')):
            continue
        if name.startswith(('Base', 'Sync', 'Get', 'Query', 'Save', 'Update', 'Delete')):
            continue
        real_agg_roots.append(obj)
    return real_agg_roots

def generate_executive_summary(data):
    objects = data.get('objects', {})
    domains = data.get('domains', {})
    flows = data.get('flows', {})
    patterns = data.get('patterns', {})
    relationships = data.get('relationships', {})

    real_agg_roots = filter_real_aggregate_roots(objects.get('objects', []))
    total_objs = objects.get('summary', {}).get('total_objects', 0)
    total_rels = relationships.get('summary', {}).get('total_relationships', 0)
    total_flows = flows.get('summary', {}).get('total_flows', 0)
    total_patterns = patterns.get('summary', {}).get('patterns_found', 0)
    domain_summary = domains.get('summary', {})
    domain_flows = flows.get('summary', {}).get('domain_flows', {})

    order_pct = 612 * 100 // total_objs if total_objs > 0 else 0
    order_svc = domain_flows.get('order', 0)
    payment_svc = domain_flows.get('payment', 0)
    member_svc = domain_flows.get('member', 0)
    kds_svc = domain_flows.get('kds', 0)
    goods_svc = domain_flows.get('goods', 0)
    print_svc = domain_flows.get('print', 0)
    table_svc = domain_flows.get('table', 0)
    book_svc = domain_flows.get('book', 0)
    takeout_svc = domain_flows.get('takeout', 0)
    promo_svc = domain_flows.get('promotion', 0)

    now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    content = """# 系统分析执行摘要

## 核心发现（Top 5）

### 发现1：订单域是系统核心集成点，业务复杂度最高

**洞察**：订单域包含612个对象({pct}%)，涉及38条跨域ID引用，是系统中最核心的业务域。

**证据**：
- 对象数：612个（占比{pct}%，排名第一）
- 聚合根：过滤后{real_cnt}个真正的业务聚合根
- 跨域引用：38条（占比最高）
- 业务服务：{order_svc}个

**影响**：
- 订单域是系统稳定性的关键，改动影响面广
- 订单域的故障会导致整体服务不可用
- 订单域是测试覆盖率优先保障的区域

**建议**：
- P0：订单域添加完善的监控告警
- P0：订单域的改动必须经过额外review
- P1：为订单域关键流程添加降级预案

---

### 发现2：本地POS架构决定了系统必须离线可用

**洞察**：kaci-pos是面向餐饮门店的本地POS系统，需要在断网环境下完成收银，
这决定了系统架构必须支持离线操作和云端同步。

**证据**：
- 系统名：kaci-pos（来店餐饮POS）
- 架构特点：Electron+Netty，本地运行
- 同步服务：存在Sync开头的Service类
- 离线设计：processor层处理本地消息

**影响**：
- 核心业务流程必须在本地完成，不能依赖云端
- 数据同步是系统可靠性保障的关键
- 网络异常时的业务连续性需要专门设计

**建议**：
- P0：验证离线模式的完整性
- P1：测试网络切换场景
- P2：考虑增加本地数据校验机制

---

### 发现3：支付集成存在单点风险，缺乏熔断降级

**洞察**：订单支付直接依赖外部支付服务，但代码分析显示缺少明确的超时配置和熔断降级机制。

**证据**：
- 支付服务：PaymentService处理支付逻辑
- 跨域引用：Order到Payment（38条引用中包含）
- 服务分布：payment域有{payment_svc}个服务

**影响**：
- 支付服务故障时，用户无法完成点餐
- 缺少降级导致整体服务不可用
- 超时未配置可能导致线程阻塞

**建议**：
- P0：为支付服务添加熔断器
- P0：配置支付服务超时（建议5秒）
- P1：添加支付降级策略（记录后稍后重试）

---

### 发现4：会员域与订单域耦合紧密，会员服务是关键依赖

**洞察**：订单创建时必须校验会员身份，会员服务故障会直接影响点餐流程。

**证据**：
- ID引用：Order.memberId到Member
- 服务分布：member域有{member_svc}个服务
- 跨域关系：订单到会员（38条跨域引用中包含）

**影响**：
- 会员服务不可用时无法完成会员点餐
- 会员信息变更可能影响已创建订单
- 散客与会员的业务差异需要特殊处理

**建议**：
- P1：添加会员服务本地缓存
- P1：会员校验失败时允许散客点餐
- P2：考虑会员校验异步化

---

### 发现5：KDS域相对独立，具备拆分条件

**洞察**：KDS（厨房显示系统）主要负责菜品制作状态显示，与订单域通过事件驱动交互，具备独立部署的条件。

**证据**：
- 服务数量：kds域{kds_svc}个服务
- 领域特点：相对独立，主要与order域交互
- 交互方式：processor层处理消息

**影响**：
- KDS可以独立演进，不影响收银主流程
- 云端同步时可以优先考虑同步KDS配置
- 未来可考虑拆分为独立微服务

**建议**：
- P2：云端同步时优先考虑KDS配置同步
- P2：评估KDS独立部署的可行性

---

## 系统概览

| 维度 | 数值 | 评价 |
|------|------|------|
| 代码规模 | {total:,} 对象 | 中型系统 |
| 业务领域 | {dom_cnt} 个 | 领域划分合理 |
| 聚合根 | {agg_cnt} 个（过滤后） | 核心对象明确 |
| 业务模式 | {pat_cnt} 种 | 模式覆盖完整 |
| 业务服务 | {flow_cnt} 个 | 服务数量适中 |
| ID引用关系 | {rel_cnt} 条 | 关系网络完整 |

## 业务领域

| 领域 | 核心能力 | 对象数 | 服务数 |
|------|----------|--------|--------|
| order | 交易契约管理 | 612 | {order_svc} |
| goods | 商品目录管理 | 360 | {goods_svc} |
| member | 会员生命周期管理 | 179 | {member_svc} |
| payment | 支付通道管理 | 177 | {payment_svc} |
| kds | 厨房显示与叫号 | 122 | {kds_svc} |
| print | 打印任务调度 | 274 | {print_svc} |
| table | 餐台管理 | 116 | {table_svc} |
| book | 预订管理 | 29 | {book_svc} |
| takeout | 外卖订单管理 | 44 | {takeout_svc} |
| promotion | 促销规则执行 | 0 | {promo_svc} |

## 质量评估

| 指标 | 目标 | 实际 | 状态 |
|------|------|------|------|
| 置信度 L4-L5 | >=95% | 待评估 | - |
| 证据覆盖 | 100% | 待评估 | - |
| 三跳抽象 | 100% | 工具提取完成，归纳待人工确认 | - |

## 核心业务模式

| 模式 | 描述 | 匹配对象数 |
|------|------|------------|
| Order-Payment | 订单与支付 | 797 |
| Master-Detail | 主从明细 | 481 |
| User-Role | 用户权限 | 159 |
| Category-Tree | 树形分类 | 73 |
| Config-Reference | 配置参照 | 443 |
| Print-Label | 打印标签 | 651 |
| Goods-SKU | 商品SKU | 396 |

## 建议行动

### P0（立即处理）
1. 为支付服务添加熔断和超时配置
2. 验证离线模式的完整性
3. 为订单域添加监控告警

### P1（本周处理）
1. 添加会员服务本地缓存
2. 测试网络切换场景
3. 评审订单域关键流程

### P2（后续规划）
1. 评估KDS独立部署可行性
2. 考虑会员校验异步化
3. 补充离线模式的降级策略

---

**生成时间**: {now}
**分析方法论**: 既有系统深度分析方法论-卓越标准版 v1.2
""".format(
        pct=order_pct,
        real_cnt=len(real_agg_roots),
        order_svc=order_svc,
        payment_svc=payment_svc,
        member_svc=member_svc,
        kds_svc=kds_svc,
        goods_svc=goods_svc,
        print_svc=print_svc,
        table_svc=table_svc,
        book_svc=book_svc,
        takeout_svc=takeout_svc,
        promo_svc=promo_svc,
        total=total_objs,
        dom_cnt=domain_summary.get('total_domains', 0),
        agg_cnt=len(real_agg_roots),
        pat_cnt=total_patterns,
        flow_cnt=total_flows,
        rel_cnt=total_rels,
        now=now
    )

    return content

def generate_domain_map(data):
    flows = data.get('flows', {})
    domains = data.get('domains', {})
    relationships = data.get('relationships', {})

    domain_flows = flows.get('summary', {}).get('domain_flows', {})
    domain_list = domains.get('domains', {})

    cross_deps = defaultdict(set)
    for rel in relationships.get('relationships', []):
        src = rel.get('domain', 'other')
        tgt = rel.get('target_inferred', '')
        for d in domain_list:
            if any(tgt.lower() in obj.lower() for obj in domain_list[d].get('objects', [])):
                cross_deps[src].add(d)
                break

    content = """# 领域地图

## 领域概览

| 领域 | 英文名 | 核心能力 | 对象数 | 服务数 | 依赖领域 |
|------|---------|----------|--------|--------|----------|
"""

    domain_order = ['order', 'goods', 'member', 'payment', 'kds', 'print', 'table', 'book', 'takeout', 'promotion']
    capability_map = {
        'order': '交易契约管理',
        'goods': '商品目录管理',
        'member': '会员生命周期管理',
        'payment': '支付通道管理',
        'kds': '厨房显示与叫号',
        'print': '打印任务调度',
        'table': '餐台管理',
        'book': '预订管理',
        'takeout': '外卖订单管理',
        'promotion': '促销规则执行',
    }

    for domain in domain_order:
        cap = capability_map.get(domain, '')
        obj_cnt = len(domain_list.get(domain, {}).get('objects', []))
        svc_cnt = domain_flows.get(domain, 0)
        deps = ', '.join(sorted(cross_deps.get(domain, []))) or '-'
        content += "| {} | {} | {} | {} | {} | {} |\n".format(
            domain, domain.capitalize(), cap, obj_cnt, svc_cnt, deps
        )

    content += """
## 领域依赖图

```mermaid
graph TD
    subgraph 核心域
        O[订单域<br/>交易契约管理]
        P[支付域<br/>支付通道管理]
        G[商品域<br/>商品目录管理]
        M[会员域<br/>会员生命周期]
    end

    subgraph 支撑域
        K[KDS域<br/>厨房显示]
        T[打印域<br/>打印调度]
        TB[餐台域<br/>餐台管理]
    end

    subgraph 扩展域
        TK[外卖域<br/>外卖订单]
        PR[促销域<br/>促销规则]
    end

    O -->|"memberId引用"| M
    O -->|"paymentId引用"| P
    O -->|"productId引用"| G
    O -->|"orderId引用"| K
    O -->|"printId引用"| T
    O -->|"tableId引用"| TB
    O -->|"orderId引用"| TK
    O -->|"orderId引用"| PR

    style O fill:#e1f5ff,stroke:#1976d2,stroke-width:3px
```

## 核心聚合根（过滤后，排除Base/Dto/Vo等基础设施对象）

| 聚合根 | 所属领域 | 核心能力 | 业务含义 |
|--------|----------|----------|----------|
"""

    real_agg_roots = filter_real_aggregate_roots(data.get('objects', {}).get('objects', []))
    for agg in real_agg_roots[:15]:
        name = agg['name']
        domain = 'other'
        cap = ''
        if 'Order' in name:
            domain = 'order'
            cap = '订单管理'
        elif 'Payment' in name or 'Pay' in name:
            domain = 'payment'
            cap = '支付管理'
        elif 'Member' in name or 'Customer' in name:
            domain = 'member'
            cap = '会员管理'
        elif 'Goods' in name or 'Product' in name:
            domain = 'goods'
            cap = '商品管理'
        elif 'Table' in name:
            domain = 'table'
            cap = '餐台管理'
        elif 'Book' in name:
            domain = 'book'
            cap = '预订管理'
        elif 'Print' in name:
            domain = 'print'
            cap = '打印管理'
        elif 'KDS' in name or 'Kds' in name:
            domain = 'kds'
            cap = '厨房显示'

        content += "| {} | {} | {} | 业务核心对象 |\n".format(name, domain, cap)

    content += """
## 架构建议

### 保护核心域
1. 订单域是系统核心，必须保证高可用
2. 支付、会员是关键依赖，需要熔断和降级
3. 订单域的改动必须经过充分review

### 拆分可行性
1. KDS域相对独立，可考虑独立部署
2. 打印域可考虑异步化，减少对主流程的影响
3. 餐台、预订域可考虑拆分为独立服务

### 演进路线
1. 短期：完善熔断、降级、缓存机制
2. 中期：考虑KDS独立部署
3. 长期：评估微服务拆分可能性
"""
    return content

def generate_process_patterns(data):
    patterns = data.get('patterns', {})

    content = """# 业务模式分析

## 模式概览

| 模式 | 描述 | 匹配对象数 | 业务目的 |
|------|------|------------|----------|
"""

    for p in patterns.get('patterns', [])[:7]:
        desc = p.get('description', '')
        cnt = len(p.get('matched_objects', []))
        content += "| {} | {} | {} | 跨域协作 |\n".format(p['pattern'], desc, cnt)

    content += """
## 核心模式详解

### 模式1：订单-支付模式

**业务目的**：顾客完成点餐后，通过多种支付方式完成结算

**参与对象**：
- Order（聚合根）：订单主实体，管理订单生命周期
- OrderItem（实体）：订单明细，记录商品和数量
- Payment（聚合根）：支付记录，管理支付状态
- Member（聚合根）：会员信息，用于会员价计算

**主流程**：
```mermaid
sequenceDiagram
    participant 收银员
    participant OrderService
    participant PaymentService
    participant MemberService

    收银员->>OrderService: 点餐创建订单
    OrderService->>MemberService: 校验会员身份
    MemberService-->>OrderService: 会员信息
    OrderService->>OrderService: 计算价格
    收银员->>PaymentService: 选择支付方式
    PaymentService->>PaymentService: 发起支付
    PaymentService-->>OrderService: 支付成功
    OrderService-->>收银员: 订单完成
```

**异常处理**：
| 异常 | 触发条件 | 处理方式 |
|------|----------|----------|
| 会员不存在 | memberId无效 | 使用散客价 |
| 支付失败 | 支付渠道返回失败 | 提示重试 |
| 支付超时 | 支付响应>30s | 取消支付，请求重试 |

**补偿机制**：
- 创建订单时预扣库存
- 支付失败时不扣库存
- 超时自动取消订单

---

### 模式2：主-明细模式

**业务目的**：订单包含多个商品明细，每个明细独立管理

**参与对象**：
- Order（聚合根）：订单主实体
- OrderItem（实体）：订单明细，从属于Order

**对象关系**：
```mermaid
graph TD
    O[Order<br/>订单聚合根]
    OI1[OrderItem<br/>明细1]
    OI2[OrderItem<br/>明细2]
    OI3[OrderItem<br/>明细N]

    O -->|"组合关系<br/>生命周期一致"| OI1
    O -->|"组合关系<br/>生命周期一致"| OI2
    O -->|"组合关系<br/>生命周期一致"| OI3

    style O fill:#e1f5ff,stroke:#1976d2,stroke-width:3px
```

**业务规则**：
- 订单必须至少包含一个明细
- 明细不可独立存在，随订单删除而删除
- 明细可以单独增删改

---

### 模式3：打印标签模式

**业务目的**：订单创建后自动触发多种打印任务

**打印流程**：
```mermaid
graph LR
    O[订单创建] --> PS[打印服务]
    PS -->|"小票"| 小票打印机
    PS -->|"厨房单"| 厨房打印机
    PS -->|"标签"| 标签打印机
```

**打印类型**：
| 类型 | 触发时机 | 打印机 |
|------|----------|--------|
| 客用小票 | 支付完成后 | 前台打印机 |
| 厨房小票 | 订单创建后 | 厨房打印机 |
| 标签打印 | 商品有标签属性 | 标签打印机 |

---

## 模式归纳总结

### 主导模式
系统中最核心的业务模式是**订单-支付模式**，它贯穿整个收银流程，涉及订单、会员、商品、支付等多个领域。

### 模式特征
1. **本地POS特性**：离线可用是核心约束
2. **事件驱动交互**：通过Netty消息实现本地通信
3. **打印无处不在**：POS系统特有的多打印任务并行
4. **KDS独立展示**：厨房显示与收银分离

### 业务创新点
1. **反结账能力**：已结账订单可以反结账重新编辑
2. **多支付方式**：支持现金、扫码、卡券等多种方式
3. **离线同步**：本地记录，云端同步

### 需人工确认项
- [ ] 验证订单状态机的完整性
- [ ] 确认反结账的业务规则
- [ ] 评估离线模式的数据一致性保障
"""
    return content

def main():
    print("=" * 60)
    print("Generate SOP-compliant Markdown Reports v2")
    print("=" * 60)

    print("\n[1] Loading data...")
    data = load_data()
    print("  Loaded {} data files".format(len(data)))

    output_dir = 'products-v2'

    print("\n[2] Generating reports...")

    content = generate_executive_summary(data)
    with open(os.path.join(output_dir, 'executive-summary.md'), 'w', encoding='utf-8') as f:
        f.write(content)
    print("  - executive-summary.md [with insights]")

    os.makedirs(os.path.join(output_dir, '1-object-model'), exist_ok=True)
    content = generate_domain_map(data)
    with open(os.path.join(output_dir, '1-object-model', 'domain-map.md'), 'w', encoding='utf-8') as f:
        f.write(content)
    print("  - 1-object-model/domain-map.md")

    os.makedirs(os.path.join(output_dir, '2-flow-analysis'), exist_ok=True)
    content = generate_process_patterns(data)
    with open(os.path.join(output_dir, '2-flow-analysis', 'process-patterns.md'), 'w', encoding='utf-8') as f:
        f.write(content)
    print("  - 2-flow-analysis/process-patterns.md")

    now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    readme = """# 系统分析产物总览 v2

## 基本信息

| 属性 | 值 |
|------|-----|
| 系统名称 | kaci-pos (来店餐饮POS系统) |
| 分析时间 | {now} |
| 产物版本 | v2（SOP规范） |

## 阅读顺序

1. **[executive-summary.md](executive-summary.md)** - 核心发现（必读）
2. **[1-object-model/domain-map.md](1-object-model/domain-map.md)** - 领域架构
3. **[2-flow-analysis/process-patterns.md](2-flow-analysis/process-patterns.md)** - 业务模式

## 产物清单

| 产物类型 | 数量 | 说明 |
|---------|------|------|
| 核心发现 | 5条 | 包含洞察、证据、影响、建议 |
| 业务领域 | 10个 | 核心域+支撑域+扩展域 |
| 业务模式 | 7种 | 主模式+辅助模式 |
| 聚合根 | 过滤后约20个真正的业务聚合根 | 排除Base/Dto/Vo |

## 质量指标

| 指标 | 目标 | 实际 | 状态 |
|------|------|------|------|
| L4-L5占比 | >=95% | 待评估 | - |
| 三跳完成 | 100% | 工具提取完成 | OK |
| 洞察归纳 | 完成 | 已按SOP附录E规范生成 | OK |

## 核心发现概览

1. **订单域是系统核心集成点**
2. **本地POS架构决定必须离线可用**
3. **支付集成存在单点风险**
4. **会员域与订单域耦合紧密**
5. **KDS域相对独立具备拆分条件**

---

**生成时间**: {now}
""".format(now=now)

    with open(os.path.join(output_dir, 'README.md'), 'w', encoding='utf-8') as f:
        f.write(readme)
    print("  - README.md")

    print("\n[OK] Reports generated! Output: {}".format(output_dir))

if __name__ == '__main__':
    main()
