# 大规模信息系统 AI 深度分析 — 成熟方法与工具选型（本地化版）
> 版本：v1.1 | 日期：2026-09-05
> **硬约束（v1.1 确立）**：分析对象为反编译的第三方代码，**代码不得出域**——一切云端 SaaS 产品（Copilot App Modernization / Amazon Q / CodeScene 云 / Moderne 商业云 / DeepWiki SaaS）不可用。商业产品的价值仅在于其**工作流模式**，本版全部替换为本地可跑的开源等价物。
> 背景：《既有系统深度分析SOP-卓越标准版》在 kaci-pos（71.3 万行）实战中暴露的覆盖缺口，根因是"AI 如何分析大系统"的工程问题。

---

## 一、结论

去掉商业层后，成熟方案依然成立，因为商业产品的内核本来就是开源件+公开模式：

> **确定性引擎做事实层（开源工具本地跑），AI 只做语义判断层（ZCode 编排，代码不出域），assess→plan→transform 三段式，结论全部锚定回源码。**

商业产品验证过的四条可复刻模式：
1. **assess→plan→remediate 任务清单可视化**（Copilot App Modernization 的工作流）→ 用 ZCode 编排 + manifest 落盘复刻；
2. **确定性配方引擎 + AI 判断混合**（Copilot 底层就是开源 OpenRewrite）→ OpenRewrite OSS 本地 CLI 直接可用；
3. **行为分析排序精读优先级**（CodeScene 热点/变更耦合，算法公开：变更频率×复杂度、同 commit 共现）→ git log/jupyter 脚本自算（本仓库非 git，可对原始仓库跑，或按目录结构做替代热点）；
4. **分层 wiki + 回源码锚点**（DeepWiki 的形态）→ DeepWiki-Open 本地部署或自建（我们 SOP 的产物树本身就是这个形态）。

---

## 二、可用方案盘点（全部本地可跑）

### A. 开源框架（AI 编排模式，可直接借鉴/复用）

| 框架 | 机制 | 对应我们的缺口 | 许可/本地化 |
|---|---|---|---|
| **Aider repo-map**（Apache-2.0） | tree-sitter 解析全仓 → 符号引用图 → PageRank 排序 → 二分适配 token 预算 | L1 仓库地图 | 纯本地 |
| **RepoAgent**（清华/OpenBMB） | AST 分层（仓库→文件→类→函数）生成文档 + 变更检测增量更新 | L2 卡片生成参考实现 | 纯本地 |
| **GraphRAG**（Microsoft，MIT） | 知识图谱 + Leiden 社区检测 + 递归社区摘要 | L3 聚合层（领域卡=社区摘要同类物） | 纯本地（LLM 端点可指向内网） |
| **Joern CPG + Codebadger(MCP)** | 代码属性图（AST+CFG+数据流）统一图查询 | 与自有 code-review-graph 同生态位；补数据流级证据 | 纯本地 |
| **DeepWiki-Open** | 分层 wiki + 源码锚点 + 问答 | 交付形态（或直接用我们的产物树） | 本地部署 |
| **Anthropic 多代理编排模式** | 1 编排:3-10 工人、显式 token 预算、15×token≈90.2% 提升、token 用量解释 ~80% 方差 | L2 预算模型（模式公开，编排由 ZCode 实现） | 模式复刻 |
| **Manus 上下文工程模式** | 文件系统即外部记忆、todo 复诵、append-only | 断点续跑/防漂移 | 模式复刻 |
| **Ghidra**（反编译域特化，NSA 开源） | 反编译产物结构化 + 脚本化提取 | 本仓库恰是反编译产物 | 纯本地 |

### B. 确定性工具链（0-token 事实层，全部开源）

| 工具 | 用途 | 对应缺口 |
|---|---|---|
| **SchemaCrawler / SchemaSpy**（BSD/MIT，20+ 年） | 数据库逆向→数据字典+ER 图+文档；支持 SQLite/MySQL；SchemaCrawler Scribe 可输出 AI-ready 格式 | 数据字典（本次最大缺口）；接门店 SQLite 或由 PO 注解生成 DDL |
| **OpenRewrite**（Apache-2.0 OSS） | 无损语义树（LST）批量查询/配方（找用法/统计/改写），本地 CLI | 用法级证据批量提取 |
| **tree-sitter tags / universal-ctags / SCIP** | 符号索引（定义/引用） | L0/L1 底座 |
| **SonarQube CE / jdeps / ArchUnit** | 代码度量；依赖方向 fitness 函数（把"订单→支付单向"写成可执行断言） | 架构守护 |
| **procyon/fernflower 自身** | 反编译产物再结构化（本仓库 17.7K 第三方文件可直接剔除，缩小 78% 噪声） | 预处理 |

### C. 自有资产（已存在，纳入方案即可）

| 资产 | 生态位 |
|---|---|
| **code-review-graph MCP**（AGENTS.md 已定义） | 事实层主存储=代码知识图谱；本会话不可用的教训：L0 提取物落盘为 JSONL/CSV，任何会话可重建、可 diff |
| **SOP-卓越标准版 + 本次产物树** | assess 阶段的方法论与 L3/L4 骨架已在 |
| **ZCode 编排能力**（子代理/脚本/文件读写） | plan+transform 阶段的执行器 |

---

## 三、五层流水线（L0-L4，全部本地）

```
L0 确定性提取（0 token，纯脚本/开源工具）
   产：数据字典(138表)、API全清单(394条)、枚举字典(229个)、云端URL清单、
       MQTT契约、配置键清单、线程池/锁/缓存清单、processor清单
   工具：自研 rg+python 提取器 / SchemaCrawler / OpenRewrite 本地 CLI
L1 地图层（近乎 0 token）
   产：符号图+PageRank repo-map（Aider 算法自实现）、模块依赖图、
       PO↔路由↔Service 交叉索引、git 热点/变更耦合脚本（替代 CodeScene）
L2 单元语义（AI Map，预算主战场，代码不出域）
   输入：L0 切片(≤3K) + 该单元关键类源码(≤30K) + 分片契约
   输出：一卡一文件（严格 schema）；manifest.yaml 记录 pending/done/failed → 断点续跑
   编排：ZCode 1 编排 : 3-10 工人；并发受限退化为串行队列（队列落盘，跨会话可续）
L3 聚合归纳（AI Reduce，输入是卡不是源码）
   产：模式卡、领域卡（GraphRAG 社区摘要同类物）、状态机、冲突检测
L4 审计交付（0 token 脚本 + 人类复核队列）
   产：证据行号审计、schema lint、术语一致性、置信度统计、抽样复核清单
```

**Token 数学**（kaci-pos 推演）：71.3 万行 ≈ 250 万 token 原始码。先剔除 1.77 万第三方反编译文件（-78% 噪声）；L0 吃掉 60-70% 事实面（0 token）；需语义精读的核心类约 8-12 万行 ≈ 35 万 token，12 分片 × 3-5 次调用 ≈ **40-60 次模型调用全量覆盖**——问题从"读不完"变为"排队跑完"。

---

## 四、对《SOP-卓越标准版》的修订建议（差分，v1.1 微调）

| # | 修订 | 落点 |
|---|---|---|
| 1 | 阶段 0 新增 **L0 确定性提取管线** 为 Gate 0 必过项（数据字典/API/枚举/URL 四大事实分册缺一不得进入阶段 1） | §2.6 |
| 2 | 候选生成改双轨：**L0 脚本出全集清单，AI 只做语义标注与判定** | §3.2 |
| 3 | **一卡一文件**硬约束（禁止合并卡） | §3.3/§4.3/§5.5 |
| 4 | 7-meta 增加 **manifest.yaml 断点续跑协议**（每单元状态/尝试次数/产物路径/预算消耗） | §2.4 |
| 5 | "AI 协作分析师"细化为**编排者**：预算管理、队列调度、manifest 维护、失败重试 | §1.3 |
| 6 | 混沌矩阵区分 designed/executed 两级 + **测试脚本骨架**随卡交付 | §5.6 |
| 7 | 交付物新增 **L0 事实分册**为第一优先级阅读物 | 附录 D |
| 8 | 新增"证据来源分级"：L0 提取物引用（脚本保证行号）> AI 直接引用（需审计） | §6.3 |
| 9 | **代码出域红线**写入 SOP 前置约束：分析流水线只允许本地工具 + 已批准的 AI 环境；外部 SaaS 一律禁止 | §0 |

## 五、针对 kaci-pos 的落地顺序（全部本地）

1. **第一步（1 轮会话）**：写 L0 提取器，补齐数据字典/API 清单/枚举字典/云端 URL 清单四个事实分册。
2. **第二步**：git 热点/变更耦合脚本（或目录级替代热点）校准精读优先级；剔除第三方反编译文件缩小 78% 噪声。
3. **第三步**：按 manifest 队列逐分片跑 L2 精读（补 8+ 台状态机、周边域流程卡、登录鉴权链、4 张返工流程卡异常流）。
4. **第四步**：L3 重新聚合 → L4 重审计，置信度推向 ≥95%。
5. **增强项（可选）**：SchemaCrawler 接门店 SQLite 出真 DDL 级字典；ArchUnit 断言固化单向依赖；DeepWiki-Open 本地部署做交互式阅读门面。

---

## 六、code-review-graph 实测验证（kaci-pos 一方代码，2026-09-05）

### 建图（一次性 4 分 36 秒）
- 注册方式：无 .git 的目录直接以一方代码根为 repo（`src\com\shouqianba`，3,757 文件），天然隔离 1.77 万第三方文件
- 结果：**61,541 节点 / 337,307 边 / FTS 60,276 行 / 33,700 条 CALLS 边有证据解析**；社区检测为目录级（igraph 缺失时退化）
- 图库落盘于 `.code-review-graph/`（反编译仓库内缓存目录，`uninstall` 可清理）

### 能力实测（✅ 可用）
| 能力 | 实测证据 |
|---|---|
| 调用图查询 | `callers_of BasePayService.pay` = 7 个调用者（需精确限定名 `文件路径::类.方法`） |
| 精读优先级 | `large-functions` 直接给出 Top：OrderDetail 5209 行 / GoodsDetail 4285 / PosOrderAddDto 3901 / GoodsItem 3701 |
| 全文检索 | FTS 60,276 行，`search` 即时返回 |
| wiki 生成 | 32 页（如 http-client.md），每页成员清单**带文件+行号锚点** |
| 架构总览 | 31 个社区+ cohesion 值 + 132 条警告 |
| 增量维护 | `update`/`watch`/`detect-changes` 齐备 |

### 粒度边界（❌ 结构上给不了的）
| 测试 | 结果 | 结论 |
|---|---|---|
| `file_summary OrderMaster.java` | 170 节点 = File1+Class1+Function168 | **Field 不入图** → 数据字典仍需 L0 提取器 |
| `search "@RequestHandler"` | 仅命中注解类自身 | **注解使用点不入图** → 394 路由清单仍需 L0 提取器 |
| `search "ORDER_DJZ"` | 0 命中 | **枚举常量不入图** → 枚举字典仍需 L0 提取器 |
| communities 命名 | "po-id"/"dto-order" 词法式目录名 | 社区=目录聚类，语义域命名需 AI 叠加 |

### 定位结论（修正此前"解决约一半"的估计）
- **L1 = 100% 由它承担**（导航/检索/调用图/优先级/增量），且有行号锚点可作证据源
- **L3 结构半边由它承担**（社区骨架/wiki 骨架/架构警告），语义命名与血肉需 AI 叠加
- **L0 = 0%**（字段/注解/枚举三类清单必须自研提取器）
- **L2 = 0%**（逐单元语义精读编排照旧）
- 它是流水线的**地基**而非全部：L0 提取器 + code-review-graph + ZCode 编排 + L4 审计脚本，四件缺一不可

### 叠加用法建议
1. L0 提取器产物落盘后，反哺图谱：`enrich` 钩子或把清单挂到 wiki 社区页，形成"结构骨架（工具出）+语义血肉（AI 卡）"的完整 wiki
2. L2 精读顺序直接采用 `large-functions` + 社区 cohesion 排序
3. 每次分析会话开头 `update`（增量秒级）替代重新扫描

## 参考来源

- Aider repo-map：aider.chat/2023/10/22/repomap.html；aider.chat/docs/repomap.html
- RepoAgent：arxiv.org/abs/2402.16667；github.com/openbmb/repoagent
- GraphRAG：github.com/microsoft/graphrag；microsoft.github.io/graphrag
- Joern CPG：docs.joern.io/code-property-graph.io；Codebadger MCP：arxiv.org/html/2603.24837v1
- Anthropic 多代理编排模式：anthropic.com/engineering/multi-agent-research-system
- Manus 上下文工程：manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus
- DeepWiki-Open（开源本地版）：github.com/AsyncFuncAI/deepwiki-open
- SchemaCrawler：schemacrawler.com；SchemaSpy 对比：dev.to/sualeh/schemaspy-vs-schemacrawler-which-database-documentation-tool-is-right-for-you-3do9
- CodeScene 算法公开文档（热点/变更耦合，用于脚本自实现）：codescene.io/docs/guides/technical/hotspots.html；change-coupling.html
- OpenRewrite：docs.openrewrite.org
