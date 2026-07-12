# 依赖准入基线

## 当前基线

当前仓库已在使用的运行时 / 构建依赖基线：

- Java 21
- Maven 多模块单体
- Spring Boot 3.4.x
- pnpm 9
- Node 20
- MySQL 8
- Redis 7
- Testcontainers 2.x

本次任务不新增任何依赖；只补脚本、文档和 CI workflow。

## 准入原则

1. 新增依赖前必须先查现有 JDK、Maven、pnpm、官方镜像和仓库已有依赖是否已经能完成目标。
2. 不能为了单个命令或单次格式转换引入大型依赖。
3. 运行时关键路径依赖必须有退出成本评估和回滚方式。
4. Docker image 也属于依赖，需要登记版本与来源。

## 当前允许直接引用的本地工具

- `rg`
- `powershell`
- `mvn`
- `corepack`
- `pnpm`
- `docker compose`

这些工具来自开发 / CI 环境，不计入项目新增依赖。

## 依赖准入表模板

```text
依赖名称：
生态：Maven / npm / Docker / binary
版本：
用途：
是否运行时依赖：
替代方案：
为什么不用 JDK/现有依赖：
License：
是否传染性协议：
CVE 状态：
维护状态：
包体/镜像大小影响：
权限/网络/文件访问能力：
退出成本：
回滚方式：
```

## 人工评审要求

- 必须有 owner。
- 必须说明是否接触网络、文件系统、子进程或动态代码执行。
- 必须说明如果以后要移除，替换成本是什么。

## 当前结论

- `scripts/verify-release.ps1` 及相关扫描全部复用现有命令，不引入新依赖。
- `.github/workflows/release-gate.yml` 复用 GitHub Actions 官方 setup action，不在仓库内引入新的运行时依赖。
