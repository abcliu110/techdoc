# Docker / Testcontainers Runbook

## 症状

- `docker compose up -d mysql redis` 启动失败。
- Maven 集成测试因 Docker 不可用、镜像拉取失败或端口冲突而失败。
- Testcontainers 测试被自动跳过，导致误以为所有集成链路都已验证。

## 影响

- 后端 `verify` 可能缺少真实 MySQL 行为验证。
- DDL、JDBC 仓储和锁等待类测试可能只跑到单元层，不足以证明发布链路可用。

## 确认命令

```powershell
.\scripts\verify-docker-testcontainers.ps1
```

```powershell
docker compose up -d mysql redis
docker compose ps
```

```powershell
mvn -B clean verify
```

## 止血动作

1. 若 Docker Desktop 未启动，先恢复 Docker 服务。
2. 若 3306 / 6379 端口冲突，先清理占用进程或改本地映射端口。
3. 若网络受限导致镜像拉取失败，先确认本地是否已经存在 `mysql:8.0.37`；存在时预检会复用本地镜像，不需要反复访问 Docker Hub。
4. 若看到 `Docker Desktop has no HTTPS proxy`、`registry-1.docker.io:443` 连接超时或 EOF，原因是 Docker Desktop 拉取 Docker Hub 镜像失败，不是本机缺少 MySQL；需要先配置 Docker Desktop 代理、镜像加速或预加载 `mysql:8.0.37` 镜像。

## 恢复步骤

1. 启动本地依赖：
   - MySQL 8
   - Redis 7
2. 等待健康状态。
3. 再跑后端 `mvn -B clean verify`。
4. 若 Testcontainers 仍被跳过，检查：
   - Docker daemon 是否可访问。
   - 当前用户是否有 Docker 权限。
   - 是否命中了 `disabledWithoutDocker = true` 的降级路径。

## 回滚

- 若只是本地环境问题，停止容器并恢复原端口映射即可。
- 若为了排障临时改过 `docker-compose.yml`，发布前必须恢复到仓库版。

## 验证

- `docker compose ps` 中 `mysql`、`redis` 为运行态。
- `.\scripts\verify-docker-testcontainers.ps1` 能复用本地 `mysql:8.0.37`，或在本地缺失时成功拉取该镜像。
- `mvn -B clean verify` 不再因 Docker / Testcontainers 前置条件失败。

## 升级联系人

- 本地环境维护人。
- CI / 容器平台维护人。
