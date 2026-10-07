# 系统分析方法工具集

## 目录结构

```
完善的分析方法/
├── 方法论/          # 分析方法论文档
│   ├── 既有系统深度分析方法论-code-review-graph版.md
│   ├── 既有系统深度分析方法论-卓越标准.md
│   └── 更高维业务设计方法论.md
├── SOP/            # 标准操作流程
│   └── 既有系统深度分析SOP-卓越标准版.md
└── 工具/          # 分析脚本
    ├── main.py             # 主入口
    ├── check_graph.py      # 图谱检查
    ├── analyze_classes.py   # 类分析
    └── generate_report.py  # 报告生成
```

## 使用方法

### 1. 检查图谱状态

```bash
export CRG_DATA_DIR=/path/to/repo/.code-review-graph
python 工具/check_graph.py --repo /path/to/repo
```

### 2. 分析类

```bash
# 分析所有类
python 工具/analyze_classes.py --repo /path/to/repo --output classes.json

# 只分析核心业务类
python 工具/analyze_classes.py --repo /path/to/repo --filter shouqianba --output core_classes.json
```

### 3. 生成报告

```bash
python 工具/generate_report.py --input classes.json --output report.md
```

## 前置条件

1. 已安装 `code-review-graph`
2. 已对目标仓库建图：
   ```bash
   code-review-graph build --repo /path/to/repo
   code-review-graph postprocess --repo /path/to/repo
   ```

## 输出示例

```
节点统计:
  类: 28,965
  函数: 283,800
  文件: 21,421
  总计: 334,206

边总数: 1,530,401

按路径前缀统计:
  shouqianba: 3,930
  localserver: 28,965
  hutool: 1,350
  netty: 1,627
```
