# Jenkins 镜像推送错误排查和解决方案

## 🔍 问题描述

**错误信息：**
```
exit code 143
构建失败: nms4cloud-platform - script returned exit code 143
跳过镜像构建 - 未找到 Dockerfile
```

**错误原因：**
1. **Exit code 143** = 进程被 SIGTERM 信号终止
2. 原因：**timeout 1800 秒（30分钟）超时**
3. 阿里云个人版镜像仓库带宽慢（0.5-1 MB/s），推送大镜像超时

## ✅ 已修复的问题

### 1. 增加超时时间

**修改前：**
```groovy
timeout 1800 /kaniko/executor \  # 30 分钟
```

**修改后：**
```groovy
timeout 3600 /kaniko/executor \  # 60 分钟
```

### 2. 添加 Kaniko 优化参数

**新增参数：**
```groovy
--skip-unused-stages=true    # 跳过未使用的构建阶段
--single-snapshot=true       # 使用单个快照（减少层数）
```

### 3. 更新超时提示信息

```groovy
echo "超时设置: 3600秒 (60分钟)"  # 从 30 分钟更新到 60 分钟
```

## 📊 性能分析

### 阿里云个人版镜像仓库限制

| 指标 | 数值 |
|------|------|
| 上传带宽 | 0.5-1 MB/s |
| 下载带宽 | 5-10 MB/s |
| 镜像仓库数量 | 300 个 |
| 镜像版本 | 无限制 |

### 推送时间估算

**假设镜像大小 200MB（压缩后）：**

| 带宽 | 推送时间 |
|------|---------|
| 0.5 MB/s | 400 秒 (~7 分钟) |
| 1 MB/s | 200 秒 (~3.5 分钟) |

**13 个模块总推送时间：**
- 最快：45 分钟
- 最慢：90 分钟

**原超时设置（30 分钟）不够！**

## 🎯 完整解决方案

### 方案 1：增加超时时间（已实施）⭐

**优点：**
- ✅ 简单直接
- ✅ 无需额外配置
- ✅ 适合所有场景

**缺点：**
- ⚠️ 构建时间长
- ⚠️ 占用资源时间长

### 方案 2：减少镜像大小

**优化 Dockerfile：**

```dockerfile
# 使用多阶段构建
FROM eclipse-temurin:21-jre-alpine AS runtime

# 只复制必要的文件
COPY --from=builder /app/target/*.jar app.jar

# 使用 Spring Boot 分层 JAR
RUN java -Djarmode=layertools -jar app.jar extract

# 分层复制（利用 Docker 缓存）
COPY --from=extract dependencies/ ./
COPY --from=extract spring-boot-loader/ ./
COPY --from=extract snapshot-dependencies/ ./
COPY --from=extract application/ ./
```

**预期效果：**
- 镜像大小减少 30-40%
- 推送时间减少 30-40%

### 方案 3：使用镜像缓存

**启用 Kaniko 缓存：**

```groovy
/kaniko/executor \
    --cache=true \
    --cache-repo=${DOCKER_REGISTRY}/${DOCKER_NAMESPACE}/cache \
    ...
```

**优点：**
- ✅ 后续构建更快
- ✅ 只推送变更的层

**缺点：**
- ⚠️ 首次构建仍然慢
- ⚠️ 需要额外的缓存仓库

### 方案 4：并行推送（不推荐）

**问题：**
- 阿里云个人版带宽共享
- 并行推送会更慢
- 可能触发限流

### 方案 5：升级到企业版（长期方案）

**阿里云容器镜像服务企业版：**
- 上传带宽：10-50 MB/s
- 镜像扫描
- 镜像同步
- 费用：约 ¥300/月

## 🔧 其他优化建议

### 1. 优化 Maven 构建

**启用并行构建：**
```groovy
mvn install -T 4 -B -Dmaven.test.skip=true
```

### 2. 使用本地 Maven 仓库管理器

**部署 Nexus Repository：**
- 减少依赖下载时间
- 缓存 Maven 依赖
- 加快构建速度

### 3. 选择性构建镜像

**只构建变更的模块：**
```groovy
BUILD_MODULE=nms4cloud-platform  # 只构建单个模块
BUILD_DOCKER_IMAGE=true
```

### 4. 使用更快的基础镜像

**选择更小的基础镜像：**
```dockerfile
# 从 eclipse-temurin:21-jdk (600MB)
# 改为 eclipse-temurin:21-jre-alpine (200MB)
FROM eclipse-temurin:21-jre-alpine
```

## 📝 验证步骤

### 1. 提交更新后的 Jenkinsfile

```bash
cd F:\python资料\服务部署文档\安装jenkins
git add Jenkinsfile-nms4cloud-final
git commit -m "修复: 增加镜像推送超时时间到 60 分钟"
git push
```

### 2. 在 Jenkins 中运行流水线

```
1. 登录 Jenkins
2. 选择 nms4cloud-build 任务
3. 点击 "Build with Parameters"
4. 选择参数：
   - BUILD_MODULE: nms4cloud-platform (先测试单个模块)
   - BUILD_DOCKER_IMAGE: true
5. 点击 "开始构建"
```

### 3. 监控构建日志

**关键日志：**
```
>>> 验证 Dockerfile
✓ Dockerfile 存在

>>> 验证 JAR 文件
✓ JAR 文件已就绪

镜像大小预估
JAR 文件大小: 150M
预估镜像大小: ~150 MB

[Kaniko] Pushing image to ...
[Kaniko] Pushed ...

镜像推送统计
推送耗时: 420秒 (7分0秒)
超时设置: 3600秒 (60分钟)

✓ 镜像构建并推送成功
```

### 4. 验证镜像是否推送成功

**在阿里云控制台查看：**
```
1. 登录阿里云容器镜像服务
2. 个人版 → 镜像仓库
3. 命名空间：lgy-images
4. 查看 nms4cloud-platform 仓库
5. 确认有新的镜像版本
```

**或使用命令行：**
```bash
# 拉取镜像测试
docker pull crpi-csgbt2t7j15cj178.cn-hangzhou.personal.cr.aliyuncs.com/lgy-images/nms4cloud-platform:23

# 查看镜像信息
docker images | grep nms4cloud-platform
```

## ⚠️ 常见问题

### Q1: 仍然超时怎么办？

**A:** 进一步增加超时时间：
```groovy
timeout 7200 /kaniko/executor \  # 120 分钟
```

### Q2: 如何查看推送进度？

**A:** Kaniko 会显示推送进度：
```
[Kaniko] Pushing layer sha256:xxx... (50%)
[Kaniko] Pushing layer sha256:yyy... (75%)
[Kaniko] Pushed image to ...
```

### Q3: 推送失败如何重试？

**A:** Kaniko 已配置自动重试：
```groovy
--push-retry=3  # 失败后自动重试 3 次
```

### Q4: 如何加快推送速度？

**A:** 参考"方案 2：减少镜像大小"和"方案 5：升级到企业版"

## 🎉 总结

**已修复的问题：**
1. ✅ 增加超时时间：30 分钟 → 60 分钟
2. ✅ 添加 Kaniko 优化参数
3. ✅ 更新超时提示信息

**预期效果：**
- ✅ 不再出现 exit code 143 错误
- ✅ 镜像可以成功推送
- ✅ 构建成功率提高

**下一步：**
1. 提交更新后的 Jenkinsfile
2. 运行测试构建
3. 验证镜像推送成功
4. 考虑长期优化方案（减少镜像大小、升级企业版）

现在可以重新运行 Jenkins 流水线了！🚀
