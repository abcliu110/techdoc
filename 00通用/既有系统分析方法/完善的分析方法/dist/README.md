# 工具目录

## 工具清单

| 层级 | 工具 | 用途 | 输入 | 输出 |
|------|------|------|------|------|
| L1 | `macro-scan.py` | 宏观扫描 | graph.db | macro-profile.json |
| L1 | `extract-fields.py` | 字段预提取 | graph.db | shouqianba-fields.json |
| L1 | `analyze-objects.py` | 对象分析与聚合根判定 | 字段数据 + graph.db | shouqianba-objects.json |
| L2 | `build-object-tree.py` | 对象树构建 | objects.json | shouqianba-trees.json |
| L3 | `build-relationship-network.py` | 关系网络构建 | objects + trees | shouqianba-relationships.json |
| L4 | `identify-patterns.py` | 业务模式识别 | objects + relationships | shouqianba-patterns.json |
| L5 | `group-domains.py` | 领域分组 | objects + patterns | shouqianba-domains.json |
| L6 | `analyze-flows.py` | 流程分析 | objects + graph.db | shouqianba-flows.json |

## 使用流程

```bash
# 1. 构建图谱（首次）
code-review-graph build --repo <repo_path>
code-review-graph postprocess --repo <repo_path>

# 2. L1: 宏观扫描 + 对象分析
python macro-scan.py --repo <repo> --business-prefix <前缀> --output macro-profile.json
python extract-fields.py --graph-db <graph.db> --business-prefix <前缀> --output <项目>-fields.json
python analyze-objects.py --fields <项目>-fields.json --graph-db <graph.db> --output <项目>-objects.json

# 3. L2-L6: 逐层分析
python build-object-tree.py --objects <项目>-objects.json --output <项目>-trees.json
python build-relationship-network.py --objects <项目>-objects.json --trees <项目>-trees.json --output <项目>-relationships.json
python identify-patterns.py --objects <项目>-objects.json --relationships <项目>-relationships.json --output <项目>-patterns.json
python group-domains.py --objects <项目>-objects.json --patterns <项目>-patterns.json --output <项目>-domains.json
python analyze-flows.py --repo <repo> --objects <项目>-objects.json --output <项目>-flows.json
```

## 通用参数

| 参数 | 说明 |
|------|------|
| `--repo` | 仓库路径 |
| `--business-prefix` | 业务包前缀（如 shouqianba、com.example） |
| `--graph-db` | code-review-graph 图谱数据库路径 |
| `--output` | 输出文件路径 |

## 产出文件

```
dist/
├── macro-profile.json         # 宏观画像
├── <项目>-fields.json       # 字段数据
├── <项目>-objects.json      # 对象分析（聚合根/实体/值对象）
├── <项目>-trees.json        # 对象树
├── <项目>-relationships.json # 关系网络
├── <项目>-patterns.json     # 业务模式
├── <项目>-domains.json      # 领域分组
└── <项目>-flows.json        # 流程分析
```

## 从类往上的分析层次

```
类 (Class)
  │
  ├─ L1: 聚合根判定        ✅ 195个聚合根
  │
  ├─ L2: 对象树构建        ✅ 195个对象树
  │
  ├─ L3: 关系网络          ✅ ID引用关系
  │
  ├─ L4: 业务模式识别      ✅ 7种业务模式
  │
  ├─ L5: 领域分组          ✅ 10个业务领域
  │
  └─ L6: 流程分析          ✅ 50条执行流程
```

## 字段预提取说明

`extract-fields.py` 只解析业务类（按 --business-prefix 过滤），不解析第三方库，大幅提升速度。

| 解析范围 | 类数量 | 预估时间 |
|----------|--------|----------|
| 全部类 | ~28,000 | ~30分钟 |
| 只业务类 | ~3,000 | ~5分钟 |
