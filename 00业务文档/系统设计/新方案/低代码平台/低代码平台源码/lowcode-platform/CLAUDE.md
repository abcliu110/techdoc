# 低代码平台 AI 执行规则

## 必读材料

修改代码前必须先阅读：

- 产品文档目录下的 README 与 PRD。
- `../04-架构决策/ADR/` 下的架构决策。
- `../05-详细设计/` 下的详细设计总纲与当前任务卡。
- `../06-任务与测试/测试规格/` 下的测试规格。
- `D:\mywork\techdoc\00业务文档\系统设计\工程规范\README.md`。
- `D:\mywork\techdoc\00业务文档\系统设计\工程规范\00-陷阱覆盖总表.md`。

## 技术栈

- Java 21.
- Spring Boot 3.4.x.
- Maven 多模块单体。
- React 18, TypeScript, Vite, pnpm 9.
- MySQL 8 与 Redis 7。

## 模块边界

- `lowcode-common`：公共契约、错误码、租户上下文和 ID 能力。
- `lowcode-metamodel`：M0 元模型定义、元模型服务、Schema Sync 和 MetaGraph 的归属模块。
- `lowcode-runtime`：M0 之后的动态运行时 API；当前已提供模块级运行时 CRUD 能力，`lowcode-app` 允许暴露最小 HTTP CRUD 闭环，但生产路径不能隐式回退到 demo / in-memory 装配。
- `lowcode-designer`：M0 之后的设计期 API；当前仍不实现正式设计器 UI，只保留设计期后端与预览/演示契约。
- `lowcode-expression`：表达式门面；其他模块禁止直接引入 Aviator。
- `lowcode-plugin`：插件 SPI 边界。
- `lowcode-workflow`：工作流扩展边界。
- `lowcode-app`：应用装配模块，不放业务逻辑。

## 安全规则

- 每个业务查询都必须绑定租户上下文；缺失租户必须快速失败。
- 动态 SQL 必须来自白名单元数据，禁止拼接用户原始片段。
- 密钥和 token 禁止硬编码，禁止写入日志。
- 表达式执行必须经过表达式模块门面。
- Entity 类禁止出现在 API 方法签名中。

## ID 策略

- 内部主键：雪花风格的 `bigint id`。
- 外部动态记录 ID：ULID 形态的 `varchar(26) lid`。
- 稳定元模型引用：`code`。
- 禁止把 `lid` 当作业务时间排序保证。

## 命令

```bash
mvn clean verify
cd lowcode-web && pnpm install --frozen-lockfile && pnpm lint && pnpm test && pnpm build
docker compose up -d mysql redis
```

## 交付模板

```text
任务卡：
变更目标：
实现要点与设计文档对应章节：
新增依赖及理由：
验收标准自检：
测试证据：
未覆盖风险：
需要人类确认的未决项：
```

如果实现过程中发现设计缺陷，必须先同步更新 PRD、设计文档和测试规格，形成一致结论后再继续。产品取舍、不可逆架构决策和证据不足的问题必须显式报告，不能藏在代码里。
