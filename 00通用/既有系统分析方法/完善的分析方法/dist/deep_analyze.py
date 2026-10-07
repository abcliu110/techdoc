# -*- coding: utf-8 -*-
"""
基于SOP附录E规范，进行深度分析
"""
import json
from collections import Counter, defaultdict

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

def analyze_service_verbs(data):
    """分析服务方法动词"""
    flows = data.get('flows', {}).get('flows', [])

    # 按领域统计方法动词
    domain_verbs = defaultdict(list)
    for svc in flows:
        domain = svc.get('domain', 'other')
        for m in svc.get('methods', []):
            method_name = m.get('name', '')
            if '_' in method_name:
                verb = method_name.split('_')[0].lower()
                domain_verbs[domain].append(verb)

    # 统计order域的动词分布
    order_verbs = domain_verbs.get('order', [])
    verb_counter = Counter(order_verbs)

    return dict(verb_counter)

def analyze_payment_anomaly(data):
    """分析payment域的引用vs实现矛盾"""
    relationships = data.get('relationships', {}).get('relationships', [])
    flows = data.get('flows', {}).get('flows', [])

    # payment相关引用
    payment_refs = [r for r in relationships
                   if 'payment' in r.get('target_inferred', '').lower()
                   or 'pay' in r.get('target_inferred', '').lower()]

    # payment域服务
    payment_svcs = [s for s in flows if s.get('domain') == 'payment']

    return {
        'ref_count': len(payment_refs),
        'svc_count': len(payment_svcs),
        'svcs': [s['class_name'] for s in payment_svcs[:5]]
    }

def analyze_pattern_precision(data):
    """分析模式识别精确度"""
    patterns = data.get('patterns', {}).get('patterns', [])

    result = {}
    for p in patterns:
        pattern_name = p.get('pattern', '')
        matched = p.get('matched_objects', [])

        # 统计错误匹配
        enum_cnt = sum(1 for o in matched if 'Enum' in o)
        bo_cnt = sum(1 for o in matched if 'Bo' in o)
        dto_cnt = sum(1 for o in matched if 'Dto' in o or 'Vo' in o or 'Request' in o or 'Response' in o)
        base_cnt = sum(1 for o in matched if 'Base' in o or 'Common' in o)

        wrong_match = enum_cnt + bo_cnt + dto_cnt + base_cnt
        total = len(matched)

        result[pattern_name] = {
            'total': total,
            'wrong_match': wrong_match,
            'wrong_pct': wrong_match * 100 // total if total > 0 else 0,
            'enum': enum_cnt,
            'bo': bo_cnt,
            'dto': dto_cnt,
            'base': base_cnt
        }

    return result

def analyze_domain_complexity(data):
    """分析领域复杂度"""
    domains = data.get('domains', {}).get('domains', {})
    relationships = data.get('relationships', {}).get('relationships', [])

    result = {}
    for domain, info in domains.items():
        if domain == 'other':
            continue

        obj_count = len(info.get('objects', []))
        ar_count = len(info.get('aggregate_roots', []))

        # 跨域引用
        cross_refs = [r for r in relationships if r.get('domain') == domain]

        result[domain] = {
            'objects': obj_count,
            'ar': ar_count,
            'cross_refs': len(cross_refs)
        }

    return result

def main():
    data = load_data()

    print("=" * 60)
    print("深度分析 - 按SOP附录E规范")
    print("=" * 60)

    print("\n[1] 服务方法动词分析")
    verbs = analyze_service_verbs(data)
    print("  order域动词分布:")
    for v, cnt in sorted(verbs.items(), key=lambda x: -x[1])[:10]:
        print("    {}: {}".format(v, cnt))

    print("\n[2] payment域引用vs实现分析")
    payment = analyze_payment_anomaly(data)
    print("  payment相关ID引用: {}".format(payment['ref_count']))
    print("  payment域服务数: {}".format(payment['svc_count']))
    print("  服务列表: {}".format(payment['svcs']))

    print("\n[3] 模式识别精确度分析")
    patterns = analyze_pattern_precision(data)
    for name, info in patterns.items():
        print("  {}: 总数{} 错误匹配{} ({}%)".format(
            name, info['total'], info['wrong_match'], info['wrong_pct']))

    print("\n[4] 领域复杂度分析")
    complexity = analyze_domain_complexity(data)
    for domain, info in sorted(complexity.items(), key=lambda x: -x[1]['objects'])[:10]:
        print("  {}: 对象{} 聚合根{} 跨域引用{}".format(
            domain, info['objects'], info['ar'], info['cross_refs']))

if __name__ == '__main__':
    main()
