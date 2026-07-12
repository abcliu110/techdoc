# 低代码平台竞品知识库

> 版本：v1.2
> 日期：2026-07-12
> 更新：API 配置（2026-07-12）

## 目录结构

```
低代码平台竞品知识库/
├── 00-assets/           ← 原始素材（截图、PDF等）
├── 00-domain/           ← 领域定义、术语表
├── 01-evidence/         ← 原始证据卡片
├── 02-competitors/      ← 竞品清单与分级
├── 03-business-design/  ← 业务设计抽象
├── 04-ui-design/        ← UI 与交互模式
├── 05-data-model/       ← 数据模型 / 元模型
├── 06-state-machine/    ← 状态机
├── 07-business-rule/    ← 业务规则
├── 08-process/          ← 流程
├── 09-permission/       ← 权限模型
├── 10-pain-point/       ← 痛点与机会
├── 11-decision/         ← ADR 产品决策
├── 12-metrics/          ← 指标体系
├── 13-non-functional/   ← 非功能性要求
├── 14-license-pricing/  ← License 与定价
├── assets/              ← 文档图片
├── matrices/            ← 能力矩阵
├── gaps/                ← 缺口清单
└── .obsidian/          ← Obsidian 配置
```

## API 配置

| 配置项 | 值 |
|--------|-----|
| API 地址 | https://127.0.0.1:27124 |
| 端口 | 27124 |
| 协议 | HTTPS |
| 鉴权 | Bearer API Key |

**重要**：Obsidian 必须保持运行状态，API 才能响应。

## 已安装插件

| 插件 | 版本 | 用途 |
|------|------|------|
| Local REST API | 4.1.7 | HTTP 接口供 AI 调用 |

## API 端点示例

```bash
# 获取笔记列表
curl -k -H "Authorization: Bearer YOUR_API_KEY" \
  "https://127.0.0.1:27124/api/search?q=NocoBase"

# 获取笔记内容
curl -k -H "Authorization: Bearer YOUR_API_KEY" \
  "https://127.0.0.1:27124/api/notes/README.md"

# 获取文件夹内容
curl -k -H "Authorization: Bearer YOUR_API_KEY" \
  "https://127.0.0.1:27124/api/folders/"
```

## AI 调用流程

```
用户提问
    ↓
Claude Code 调用 Obsidian API 搜索
    ↓
获取相关笔记片段
    ↓
Claude Code 基于结果回答
```
