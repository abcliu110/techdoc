#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
code-review-graph 系统分析工具集
===========================

使用方法：

1. 设置图谱路径（必须）
   export CRG_DATA_DIR=/path/to/repo/.code-review-graph

2. 分析类
   python analyze_classes.py --repo /path/to/repo --filter shouqianba

3. 生成报告
   python generate_report.py --input classes_analysis.json --output report.md

4. 检查图谱
   python check_graph.py --repo /path/to/repo

工具列表：
- check_graph.py   : 检查图谱状态
- analyze_classes.py: 分析所有类
- generate_report.py : 生成分析报告
"""
import sys

def main():
    print(__doc__)

    if len(sys.argv) == 1:
        print("\n快速开始:")
        print("  1. 检查图谱: python check_graph.py --repo /path/to/repo")
        print("  2. 分析类:  python analyze_classes.py --repo /path/to/repo --filter shouqianba")
        print("  3. 生成报告: python generate_report.py")
        print("\n或者设置环境变量:")
        print("  export CRG_DATA_DIR=/path/to/repo/.code-review-graph")
        print("  python check_graph.py")

if __name__ == '__main__':
    main()
