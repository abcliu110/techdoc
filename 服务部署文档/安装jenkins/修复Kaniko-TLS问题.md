# 修复Kaniko连接Harbor的TLS问题

## 问题描述

即使将 `harbor-core.harbor` 改为 `harbor.harbor` 后，Kaniko仍然无法拉取基础镜像：

```
WARN Failed to retrieve image eclipse-temurin:21-jre from remapped registry harbor.harbor:
unable to complete operation after 0 attempts, last error:
Get "https://harbor.harbor/v2/": dial tcp 10.43.254.220:443: connect: connection refused.
```

## 根本原因

**Kaniko在构建阶段缺少TLS相关参数**

### 问题分析

1. **Harbor配置**: Harbor使用HTTP(不是HTTPS)，没有配置TLS证书
2. **Kaniko行为**: 默认使用HTTPS连接registry
3. **缺失参数**: 构建阶段（拉取基础镜像）没有告诉Kaniko跳过TLS验证

### 代码对比

**推送阶段（第2步）- 正常工作 ✅**
```groovy
/kaniko/executor \
    --registry-mirror=${registryMirror} \
    --insecure-registry=${HARBOR_REGISTRY} \  ← 有这个参数
    --skip-tls-verify \                        ← 有这个参数
    ${DESTINATIONS} \
    ...
```

**构建阶段（第1步）- 失败 ❌**
```groovy
/kaniko/executor \
    --registry-mirror=${registryMirror} \
    --no-push \
    ...
    # ❌ 缺少 --insecure-registry
    # ❌ 缺少 --skip-tls-verify
```

---

## 解决方案

在构建阶段添加TLS相关参数。

### 修改的文件

1. **Jenkinsfile-nms4cloud-final** (第973-986行)
2. **Jenkinsfile-nms4cloud-pos-java-optimized-v2** (第535-548行)

### 修改内容

**修改前:**
```groovy
if [ -n "${registryMirror}" ]; then
    /kaniko/executor \
        --context=${buildContext} \
        --dockerfile=${dockerfilePath} \
        --registry-mirror=${registryMirror} \
        --no-push \
        --tar-path=/tmp/${moduleName}-image.tar \
        ...
```

**修改后:**
```groovy
if [ -n "${registryMirror}" ]; then
    /kaniko/executor \
        --context=${buildContext} \
        --dockerfile=${dockerfilePath} \
        --registry-mirror=${registryMirror} \
        --insecure-registry=${HARBOR_REGISTRY} \  ← 新增
        --skip-tls-verify \                        ← 新增
        --no-push \
        --tar-path=/tmp/${moduleName}-image.tar \
        ...
```

---

## 参数说明

### --insecure-registry

告诉Kaniko指定的registry不使用TLS加密。

```bash
--insecure-registry=harbor.harbor
```

这样Kaniko会使用HTTP而不是HTTPS连接Harbor。

### --skip-tls-verify

跳过TLS证书验证（如果registry使用自签名证书）。

```bash
--skip-tls-verify
```

虽然Harbor使用HTTP，但添加这个参数可以确保兼容性。

---

## 验证修改

### 1. 检查修改

```bash
cd /f/python资料/服务部署文档/安装jenkins

# 查看修改
git diff Jenkinsfile-nms4cloud-final | grep -A5 -B5 "insecure-registry"
git diff Jenkinsfile-nms4cloud-pos-java-optimized-v2 | grep -A5 -B5 "insecure-registry"
```

### 2. 提交修改

```bash
git add Jenkinsfile-nms4cloud-final
git add Jenkinsfile-nms4cloud-pos-java-optimized-v2

git commit -m "修复Kaniko构建阶段缺少TLS参数的问题

- 在构建阶段添加 --insecure-registry 参数
- 在构建阶段添加 --skip-tls-verify 参数
- 解决Kaniko无法从Harbor拉取基础镜像的问题"

git push
```

### 3. 重新运行构建

1. 打开Jenkins Web界面
2. 选择项目
3. 点击 "Build with Parameters"
4. 确保: `DOCKER_REGISTRY_SOURCE = harbor-proxy`
5. 点击 "构建"

### 4. 预期输出

**成功的日志:**
```
>>> [1/2] 开始构建镜像...
  镜像源: Harbor代理(本地缓存)
[INFO] Retrieving image manifest eclipse-temurin:21-jre
[INFO] Retrieving image eclipse-temurin:21-jre from mapped registry harbor.harbor
[INFO] Using base image eclipse-temurin:21-jre
✓ 镜像构建完成 (耗时: 0分8秒)
```

**不应该再看到:**
```
❌ WARN Failed to retrieve image from remapped registry harbor.harbor
❌ Get "https://harbor.harbor/v2/": dial tcp xxx:443: connect: connection refused
```

---

## 完整的修复历史

### 第1次修复: 服务名称错误
- **问题**: 使用了 `harbor-core.harbor`
- **修复**: 改为 `harbor.harbor`
- **结果**: 仍然失败（TLS问题）

### 第2次修复: TLS参数缺失 ⭐
- **问题**: 构建阶段缺少 `--insecure-registry` 和 `--skip-tls-verify`
- **修复**: 添加这两个参数
- **结果**: 应该可以正常工作

---

## 技术细节

### Kaniko的Registry连接逻辑

1. **默认行为**: 使用HTTPS连接registry
2. **--insecure-registry**: 使用HTTP连接指定的registry
3. **--skip-tls-verify**: 跳过TLS证书验证

### Harbor的服务配置

```yaml
expose:
  type: nodePort
  tls:
    enabled: false  # ← Harbor没有启用TLS
  nodePort:
    ports:
      http:
        nodePort: 30002  # ← 使用HTTP端口
```

### 为什么推送阶段正常？

推送阶段已经有这些参数：
```groovy
--insecure-registry=${HARBOR_REGISTRY}  # harbor.harbor
--skip-tls-verify
```

所以推送到Harbor时没有问题，只有拉取基础镜像时才失败。

---

## 故障排查

### 如果仍然失败

1. **检查Harbor服务**
   ```bash
   kubectl get svc harbor -n harbor
   # 确认服务存在且端口正确
   ```

2. **测试HTTP连接**
   ```bash
   kubectl run test --image=curlimages/curl --rm -it --restart=Never -n jenkins \
     -- curl -v http://harbor.harbor/v2/
   # 应该返回 200 OK 或 401 Unauthorized
   ```

3. **检查Harbor代理项目**
   - 访问: http://<节点IP>:30002
   - 确认 `dockerhub-proxy` 项目存在
   - 确认项目类型是 "镜像代理"

4. **查看Kaniko详细日志**
   在Jenkinsfile中临时修改:
   ```groovy
   --verbosity=debug  # 改为debug级别
   ```

---

## 总结

### ✅ 已完成

1. 第1次修复: `harbor-core.harbor` → `harbor.harbor`
2. 第2次修复: 添加 `--insecure-registry` 和 `--skip-tls-verify`

### 🎯 修改的文件

- `Jenkinsfile-nms4cloud-final` - 构建阶段添加2个参数
- `Jenkinsfile-nms4cloud-pos-java-optimized-v2` - 构建阶段添加2个参数

### 📊 预期效果

- ✅ Kaniko可以从Harbor拉取基础镜像
- ✅ 首次构建: 8-12秒
- ✅ 后续构建: 1-3秒（使用缓存）
- ✅ 不再出现TLS连接错误

---

## 相关文档

- `Harbor服务地址修复完成.md` - 第1次修复（服务名称）
- `Harbor连接问题已解决.md` - 问题诊断和解决方案
- `Harbor代理加速方案.md` - Harbor代理配置说明

现在重新运行构建，应该可以正常工作了！
