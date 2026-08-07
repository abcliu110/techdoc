# G0-A 启动契约

## 文档信息

| 项目 | 内容 |
|---|---|
| 版本 | v1.0 |
| 日期 | 2026-08-03 |
| 任务模式 | 认知重建 |
| 编排契约 | `SYS-ANALYSIS-CONTRACT-v2.10` |

---

## 1. 原始目标

用户原始要求：对项目 D:\mywork\nms4pos、D:\mywork\nms4pos-ui、D:\mywork\nms4cloud、D:\mywork\nms4cloud-biz-ui 只全面分析**打印功能**，输出文档放在 D:\mywork\techdoc\打印原理 目录下。

目标：按 SOP-00 标准级（16 个文档）重建打印功能的领域认知。

---

## 2. 分析对象

| 仓库 | 角色 | 技术形态 |
|---|---|---|
| nms4pos | POS 后端（打印核心） | Java / Spring Boot |
| nms4pos-ui | POS 前端（打印配置界面） | React / Taro |
| nms4cloud | SaaS 后端（打印管理 API） | Java / Spring Cloud |
| nms4cloud-biz-ui | SaaS 后台（打印管理界面） | React / Ant Design |

---

## 3. 证据范围

| 仓库 | 基线 | 证据范围 |
|---|---|---|
| nms4pos | 72e2b45ef | PosPrn*、DwdPrn* 相关类、Service、Mapper |
| nms4pos-ui | bd82c18a | PrintJob、PrintStyle、PrintQueue、PrintPrinter 页面 |
| nms4cloud | cbe1399518 | pos 模块的 Printer、Print 相关 API |
| nms4cloud-biz-ui | b281445a | PrintMgr、PosPrn* 页面 |

---

## 4. 输出与读者

- **输出位置**：D:\mywork\techdoc\打印原理
- **主要读者**：接手 POS 打印功能的新开发者
- **预期交付**：标准级 16 个文档 + 深度级 10 个验证文档

---

## 5. 动作边界

| 动作类型 | 允许 |
|---|---|
| 只读源码分析 | ✅ |
| 生成文档 | ✅ |
| 修改代码 | ❌ |
| 执行测试/验证 | ❌（无运行环境） |

---

## 6. 旧文档处理

- D:\mywork\techdoc\打印原理1：历史分析产物，仅作参考
- D:\mywork\techdoc\打印原理：新生成文档，不覆盖同名文件

---

## 7. G0 门禁结论

**结论**：通过

**理由**：
- 分析对象明确：四个仓库的打印功能
- 证据范围明确：nms4pos、nms4pos-ui、nms4cloud、nms4cloud-biz-ui
- 输出位置明确：D:\mywork\techdoc\打印原理
- 只读边界明确：无修改、无执行
