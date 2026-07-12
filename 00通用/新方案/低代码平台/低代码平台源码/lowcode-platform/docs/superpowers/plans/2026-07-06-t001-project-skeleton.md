# T-001 工程骨架实现计划

> **给 AI 执行者：** 必须使用 superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 按任务逐项执行本计划。步骤使用复选框（`- [ ]`）跟踪。

**目标：** 建立低代码平台 M0 工程骨架，不实现运行时业务功能。

**架构：** 创建 Java 21 / Spring Boot 3.4 模块化单体，后端 Maven 模块包括 common、metamodel、runtime、designer、expression、plugin、workflow 和 app。新增 pnpm 9 前端工作区，包含 builder、renderer、shared 空壳包，并加入可机器执行的架构规则。

**技术栈：** Java 21、Spring Boot 3.4.x、Maven、JUnit 5、ArchUnit、React 18、TypeScript、Vite、Vitest、ESLint、pnpm 9、MySQL 8、Redis 7。

---

### 任务 1：仓库骨架

**文件：**
- 创建：`.editorconfig`
- 创建：`.gitignore`
- 创建：`.nvmrc`
- 创建：`README.md`
- 创建：`CLAUDE.md`
- 创建：`docker-compose.yml`
- 创建：`scripts/scan-todo.ps1`
- 创建：`scripts/scan-sql-risk.ps1`
- 创建：`scripts/scan-sensitive-log.ps1`

- [ ] 创建仓库级文件和脚本。
- [ ] 确认没有引入 M1/M2/M3 运行时功能。

### 任务 2：后端失败测试

**文件：**
- 创建：`lowcode-common/src/test/java/com/lowcode/common/api/ResultTest.java`
- 创建：`lowcode-common/src/test/java/com/lowcode/common/tenant/TenantContextTest.java`
- 创建：`lowcode-app/src/test/java/com/lowcode/app/ArchitectureRulesTest.java`

- [ ] 为 `Result`、`BizException` 和 `TenantContext` 编写测试。
- [ ] 为模块边界、API 层、support 包、事务注解和 Aviator 引用编写 ArchUnit 测试。
- [ ] 运行 `mvn -pl lowcode-common test`，并确认实现前测试失败。

### 任务 3：后端骨架实现

**文件：**
- 创建：`pom.xml`
- 在每个 `lowcode-*` 后端模块下创建模块 POM。
- 创建：`lowcode-common/src/main/java/com/lowcode/common/api/Result.java`
- 创建：`lowcode-common/src/main/java/com/lowcode/common/error/ErrorCode.java`
- 创建：`lowcode-common/src/main/java/com/lowcode/common/error/BizException.java`
- 创建：`lowcode-common/src/main/java/com/lowcode/common/tenant/TenantContext.java`
- 创建：`lowcode-common/src/main/java/com/lowcode/common/id/IdGenerator.java`
- 创建：`lowcode-common/src/main/java/com/lowcode/common/id/LocalIdGenerator.java`
- 在 metamodel/runtime/designer/expression/plugin/workflow 中创建最小包占位。
- 创建：`lowcode-app/src/main/java/com/lowcode/app/LowcodeApplication.java`

- [ ] 只实现 T-001 测试所需代码。
- [ ] 运行 `mvn -pl lowcode-common test` 并确认通过。
- [ ] 运行 `mvn clean verify` 并修复骨架级失败。

### 任务 4：前端工作区骨架

**文件：**
- 创建：`lowcode-web/package.json`
- 创建：`lowcode-web/pnpm-workspace.yaml`
- 创建：`lowcode-web/tsconfig.base.json`
- 创建：`lowcode-web/packages/shared/package.json`
- 创建：`lowcode-web/packages/shared/src/index.ts`
- 创建：`lowcode-web/packages/shared/src/index.test.ts`
- 创建等价的 builder 和 renderer 空壳包。

- [ ] 先写 shared 包的最小测试，再实现。
- [ ] 增加 lint、typecheck、test 和 build 脚本。
- [ ] 如果本地可用 pnpm，则运行前端命令。

### 任务 5：验证

**命令：**
- `mvn clean verify`
- `cd lowcode-web; pnpm install --frozen-lockfile; pnpm lint; pnpm test; pnpm build`
- 运行乱码扫描命令，检查连续问号、替换字符和常见 mojibake 片段。

- [ ] 阅读命令输出，并修复 T-001 范围内的失败。
- [ ] 报告准确命令、通过/失败状态和剩余风险。
