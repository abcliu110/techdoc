# -*- coding: utf-8 -*-
"""
L6: 流程分析
扫描 Service 层识别业务操作，构建业务流程序列

适用于本地POS系统（无Controller层，通过Netty/WebSocket通信）
"""
import json
import os
import re
import argparse
from collections import defaultdict
from datetime import datetime

def extract_domain_from_path(file_path):
    """从文件路径提取领域"""
    path_norm = file_path.lower().replace('\\', '/')
    parts = path_norm.split('/')
    # com/shouqianba/localserver/order/service/xxx.java
    for part in ['order', 'goods', 'member', 'payment', 'print', 'kds', 'table', 'book', 'takeout', 'shift', 'soldout', 'promotion', 'member', 'biz']:
        if part in parts:
            return part
    return 'other'

def extract_domain_from_package(pkg):
    """从包名提取领域"""
    if not pkg:
        return 'other'
    parts = pkg.split('.')
    for part in parts:
        if part in ['order', 'goods', 'member', 'payment', 'print', 'kds', 'table', 'book', 'takeout', 'shift', 'soldout', 'promotion', 'biz', 'scrm', 'base']:
            return part
    return 'other'

def get_class_methods(content, class_name):
    """提取类中的公开方法"""
    methods = []

    # 匹配 public 方法
    pattern = r'public\s+(?:static\s+)?(?:void|\w+(?:<[^>]+>)?)\s+(\w+)\s*\(([^)]*)\)'
    for match in re.finditer(pattern, content):
        method_name = match.group(1)
        params = match.group(2).strip()

        # 跳过构造函数和私有方法
        if method_name == class_name or method_name.startswith('_') and len(method_name) > 10:
            continue

        # 解析参数类型
        param_types = []
        for param in params.split(','):
            param = param.strip()
            if param:
                parts = param.split()
                if len(parts) >= 2:
                    param_types.append(parts[0])
                elif parts:
                    param_types.append(parts[0])

        methods.append({
            'name': method_name,
            'param_types': param_types,
            'param_count': len(param_types)
        })

    return methods

def get_class_dependencies(content):
    """提取类的依赖（成员变量中的Service/Dao/Entity等）"""
    deps = []

    # 匹配 private XXX xxx;
    pattern = r'private\s+(\w+(?:<[^>]+>)?)\s+(\w+);'
    for match in re.finditer(pattern, content):
        dep_type = match.group(1)
        dep_name = match.group(2)

        # 过滤出业务相关的依赖
        if any(kw in dep_type for kw in ['Service', 'Dao', 'Manager', 'Entity', 'Bo', 'Dto', 'Vo']):
            deps.append({
                'type': dep_type,
                'name': dep_name
            })

    return deps

def normalize_path(path):
    """统一路径分隔符"""
    return path.replace('\\', '/')

def scan_business_services(repo_path):
    """
    扫描 Service 层识别业务操作
    """
    services = []
    seen = set()

    # 基础路径
    base_dir = os.path.join(repo_path, 'src', 'com', 'shouqianba', 'localserver')
    if not os.path.exists(base_dir):
        base_dir = os.path.join(repo_path, 'src', 'com', 'shouqianba')
        if not os.path.exists(base_dir):
            return services

    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if not file.endswith('.java'):
                continue

            file_path = os.path.join(root, file)

            # 统一路径分隔符进行检测
            path_normalized = normalize_path(file_path)

            # 只扫描 service、biz、manager 目录
            if '/service/' not in path_normalized and '/biz/' not in path_normalized and '/manager/' not in path_normalized:
                continue
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
            except:
                continue

            # 提取包名
            pkg_match = re.search(r'package\s+([\w.]+);', content)
            pkg = pkg_match.group(1) if pkg_match else ''
            domain = extract_domain_from_package(pkg)

            # 提取类名
            class_match = re.search(r'class\s+(\w+)', content)
            class_name = class_match.group(1) if class_match else file[:-5]

            # 提取方法
            methods = get_class_methods(content, class_name)

            # 提取依赖
            deps = get_class_dependencies(content)

            # 过滤出业务方法（排除getter/setter/equals/hashCode/toString）
            business_methods = [
                m for m in methods
                if not any(kw in m['name'].lower() for kw in ['get', 'set', 'equals', 'hash', 'tostring', 'init', 'destroy'])
            ]

            if not business_methods:
                continue

            service_id = f"{domain}_{class_name}"
            if service_id in seen:
                continue
            seen.add(service_id)

            services.append({
                'service_id': service_id,
                'domain': domain,
                'class_name': class_name,
                'package': pkg,
                'file': file,
                'method_count': len(business_methods),
                'methods': business_methods[:10],  # 最多10个方法
                'dependencies': deps[:5]  # 最多5个依赖
            })

    return services

def scan_processor_services(repo_path):
    """
    扫描 Processor 层（Netty消息处理器）
    """
    processors = []
    seen = set()

    processor_dir = os.path.join(repo_path, 'src', 'com', 'shouqianba', 'localserver', 'processor')
    if not os.path.exists(processor_dir):
        processor_dir = os.path.join(repo_path, 'src', 'com', 'shouqianba', 'localserver', 'task')
        if not os.path.exists(processor_dir):
            return processors

    for root, dirs, files in os.walk(processor_dir):
        for file in files:
            if not file.endswith('.java'):
                continue

            file_path = os.path.join(root, file)
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
            except:
                continue

            # 检查是否是消息处理器
            if 'ChannelInboundHandlerAdapter' not in content and 'SimpleChannelInboundHandler' not in content:
                continue

            # 提取包名
            pkg_match = re.search(r'package\s+([\w.]+);', content)
            pkg = pkg_match.group(1) if pkg_match else ''

            # 提取类名
            class_match = re.search(r'class\s+(\w+)', content)
            class_name = class_match.group(1) if class_match else file[:-5]

            # 提取处理的方法
            methods = []
            pattern = r'(process\w*|handle\w*|on\w+|messageReceived)\s*\([^)]+\)'
            for match in re.finditer(pattern, content):
                method_name = match.group(0).split('(')[0].strip()
                methods.append({'name': method_name})

            processor_id = f"processor_{class_name}"
            if processor_id in seen:
                continue
            seen.add(processor_id)

            processors.append({
                'processor_id': processor_id,
                'domain': 'processor',
                'class_name': class_name,
                'package': pkg,
                'file': file,
                'methods': methods[:5]
            })

    return processors

def group_by_domain(services):
    """按领域分组"""
    domain_flows = defaultdict(list)
    for svc in services:
        domain_flows[svc['domain']].append(svc)
    return dict(domain_flows)

def main():
    parser = argparse.ArgumentParser(description='Analyze Business Flows')
    parser.add_argument('--repo', required=True, help='Repository path')
    parser.add_argument('--objects', help='Path to objects JSON (optional)')
    parser.add_argument('--output', default='flows.json', help='Output file')
    args = parser.parse_args()

    print("=" * 60)
    print("L6: Business Flow Analysis (Service Layer)")
    print("=" * 60)

    # 扫描 Service 层
    print("\n[1] Scanning business services...")
    services = scan_business_services(args.repo)
    print(f"  Found {len(services)} business services")

    # 扫描 Processor 层
    print("\n[2] Scanning message processors...")
    processors = scan_processor_services(args.repo)
    print(f"  Found {len(processors)} message processors")

    all_flows = services + processors

    # 按领域分组
    print("\n[3] Grouping by domain...")
    domain_flows = group_by_domain(all_flows)

    print("\n  Domain distribution:")
    for domain, dflows in sorted(domain_flows.items(), key=lambda x: -len(x[1])):
        print(f"    {domain}: {len(dflows)} services")

    # 显示示例
    if services:
        print("\n  Sample services:")
        for svc in services[:5]:
            print(f"    [{svc['domain']}] {svc['class_name']} ({svc['method_count']} methods)")

    # 保存
    print("\n[4] Saving...")
    result = {
        'level': 6,
        'build_time': datetime.now().isoformat(),
        'summary': {
            'total_flows': len(all_flows),
            'service_count': len(services),
            'processor_count': len(processors),
            'domain_flows': {k: len(v) for k, v in domain_flows.items()}
        },
        'flows': all_flows,
        'domain_flows': domain_flows,
        'services': services,
        'processors': processors
    }

    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    print(f"  Saved to: {args.output}")

if __name__ == '__main__':
    main()
