# G0-A 启动契约

## 版本信息
| 属性 | 值 |
|---|---|
| 分析对象 | 打印相关模块 |
| 任务模式 | 认知重建 |
| 侦察时间 | 2026-08-04 |

## 一、原始目标
用户要求根据 SOP-00 及其子SOP对打印相关模块进行分析，输出文档到 `D:\mywork\techdoc\打印原理` 目录。

## 二、分析范围

### 2.1 相关仓库

| 仓库 | 路径 | 备注 |
|---|---|---|
| ms4pos | `D:\mywork\ns4pos` | 包含 pos10printer（独立打印应用）、pos2plugin（打印插件）、pos3boot（打印服务） |
| ms4cloud | `D:\mywork\ns4cloud` | 包含 pos-api（打印API）、pos相关业务模块 |
| ms4pos-ui | `D:\mywork\ns4pos-ui` | 前端打印组件 |
| ms4cloud-biz-ui | `D:\mywork\ns4cloud-biz-ui` | 业务前端打印模块 |

### 2.2 打印模块识别

**后端核心模块：**
- `ms4cloud-pos10printer`：独立打印应用（Windows桌面客户端）
- `ms4cloud-pos2plugin`：打印插件模块
- `ms4cloud-pos3boot`：打印服务（Spring Boot）
- `ms4cloud-pos-api`：打印API定义

**前端模块：**
- `ms4pos-ui`：桌面端打印UI
- `ms4cloud-biz-ui`：云端业务打印UI

### 2.3 输出位置
`D:\mywork\techdoc\打印原理`

## 三、动作边界
- 只读源码分析
- 不修改任何代码
- 不执行任何测试
- 不访问生产环境

## 四、深度级别
**精简级**（3个核心文档）：业务全景 + 核心切片 + 关键映射

---

## G0-A 门禁结论：通过

分析对象、证据范围、输出位置和只读边界已明确，可开始侦察。
