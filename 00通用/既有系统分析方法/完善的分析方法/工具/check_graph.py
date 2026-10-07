# -*- coding: utf-8 -*-
"""
图谱检查工具
检查图谱状态和完整性
"""
import sqlite3
import argparse
import os

def get_args():
    parser = argparse.ArgumentParser(description='检查图谱状态')
    parser.add_argument('--repo', default='.', help='仓库路径')
    return parser.parse_args()

def main():
    args = get_args()

    graph_dir = os.environ.get('CRG_DATA_DIR', f'{args.repo}/.code-review-graph')
    graph_db = f'{graph_dir}/graph.db'

    if not os.path.exists(graph_db):
        print(f"错误: 找不到图谱数据库 {graph_db}")
        print("请先运行: code-review-graph build --repo <仓库路径>")
        return

    conn = sqlite3.connect(graph_db)
    cur = conn.cursor()

    print("=" * 60)
    print("图谱检查")
    print("=" * 60)
    print(f"图谱路径: {graph_db}\n")

    # 节点统计
    cur.execute("SELECT COUNT(*) FROM nodes WHERE kind = 'Class'")
    class_count = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM nodes WHERE kind = 'Function'")
    func_count = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM nodes WHERE kind = 'File'")
    file_count = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM nodes")
    total_nodes = cur.fetchone()[0]

    print("节点统计:")
    print(f"  类: {class_count:,}")
    print(f"  函数: {func_count:,}")
    print(f"  文件: {file_count:,}")
    print(f"  总计: {total_nodes:,}")

    # 边统计
    cur.execute("SELECT COUNT(*) FROM edges")
    total_edges = cur.fetchone()[0]
    print(f"\n边总数: {total_edges:,}")

    # 按路径分类
    print("\n按路径前缀统计:")
    paths = ['shouqianba', 'localserver', 'hutool', 'netty', 'okhttp']
    for p in paths:
        cur.execute("SELECT COUNT(*) FROM nodes WHERE kind = 'Class' AND file_path LIKE ?", (f'%{p}%',))
        cnt = cur.fetchone()[0]
        if cnt > 0:
            print(f"  {p}: {cnt:,}")

    # 检查后处理
    cur.execute("SELECT COUNT(*) FROM nodes WHERE community_id IS NOT NULL")
    community_count = cur.fetchone()[0]
    if community_count > 0:
        print(f"\n社区检测: OK ({community_count} nodes)")
    else:
        print("\n社区检测: NOT DONE")
        print("Run: code-review-graph postprocess")

    conn.close()
    print("\n检查完成!")

if __name__ == '__main__':
    main()
