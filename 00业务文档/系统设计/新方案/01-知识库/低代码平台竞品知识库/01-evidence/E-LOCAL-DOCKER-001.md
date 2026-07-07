---
id: E-LOCAL-DOCKER-001
type: evidence
competitor: LocalEnvironment
module: runtime-test
source_channel: trial
source_type: trial-note
source_url: local-command:docker-info
source_owner: self-trial
captured_at: 2026-07-05
valid_until: 2026-07-12
license_note: local-test
compliance_status: approved
status: active
owner: AI
ai_generated: false
---

# 证据：本机 Docker daemon 未运行，阻塞 NocoBase/Frappe 本地实测

## 原始观察

本机具备 Docker CLI、Docker Compose、Node、Python、Git：

```text
Docker version 29.2.1
Docker Compose version v5.1.0
Node v22.11.0
Python 3.11.4
git 2.53.0.windows.1
```

但 `docker info` 无法连接 Docker Desktop Linux Engine：

```text
failed to connect to the docker API at npipe:////./pipe/dockerDesktopLinuxEngine
The system cannot find the file specified.
```

`Get-Service` 显示 `com.docker.service` 为 `Stopped`。尝试 `Start-Service -Name com.docker.service` 返回：

```text
Service 'Docker Desktop Service (com.docker.service)' cannot be started
Cannot open com.docker.service service on computer '.'
```

## 结论

当前无法产出 NocoBase/Frappe 本地安装实测卡、运行时截图和最小样例验证卡。该缺口属于本机 Docker daemon/服务权限阻塞，不是方法论或知识库执行完成。

## 下一步

需要在 Docker Desktop 服务可用后继续执行：

```text
docker info
docker compose up
NocoBase: 13000+
Frappe: 14000+
```
