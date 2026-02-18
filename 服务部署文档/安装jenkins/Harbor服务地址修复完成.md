# Harbor服务地址修复完成

## 修改的文件

已修改3个Jenkinsfile文件,将所有 `harbor-core.harbor` 替换为 `harbor.harbor`:

### 1. Jenkinsfile-nms4cloud-final
- ✅ 第174行: HARBOR_REGISTRY
- ✅ 第178行: DOCKER_REGISTRY_MIRROR
- ✅ 第877行: registryMirror (harbor-proxy case)
- ✅ 第890行: registryMirror (default case)

### 2. Jenkinsfile-nms4cloud-pos-java-optimized
- ✅ 第118行: HARBOR_REGISTRY

### 3. Jenkinsfile-nms4cloud-pos-java-optimized-v2 ⭐
- ✅ 第22行: 注释中的docker-server
- ✅ 第113行: HARBOR_REGISTRY
- ✅ 第117行: DOCKER_REGISTRY_MIRROR
- ✅ 第437行: registryMirror (harbor-proxy case)
- ✅ 第449行: registryMirror (default case)

---

## 修改详情

### 环境变量配置
```groovy
// 修改前
HARBOR_REGISTRY = 'harbor-core.harbor'
DOCKER_REGISTRY_MIRROR = 'harbor-core.harbor/dockerhub-proxy'

// 修改后
HARBOR_REGISTRY = 'harbor.harbor'
DOCKER_REGISTRY_MIRROR = 'harbor.harbor/dockerhub-proxy'
```

### 镜像源选择逻辑
```groovy
// 修改前
case 'harbor-proxy':
    registryMirror = 'harbor-core.harbor/dockerhub-proxy'
    break
default:
    registryMirror = 'harbor-core.harbor/dockerhub-proxy'

// 修改后
case 'harbor-proxy':
    registryMirror = 'harbor.harbor/dockerhub-proxy'
    break
default:
    registryMirror = 'harbor.harbor/dockerhub-proxy'
```

---

## 验证结果

```bash
✓ 所有 harbor-core.harbor 已替换为 harbor.harbor
```

确认修改位置:
```
Jenkinsfile-nms4cloud-pos-java-optimized-v2:
  22: --docker-server=harbor.harbor
 113: HARBOR_REGISTRY = 'harbor.harbor'
 117: DOCKER_REGISTRY_MIRROR = 'harbor.harbor/dockerhub-proxy'
 437: registryMirror = 'harbor.harbor/dockerhub-proxy'
 449: registryMirror = 'harbor.harbor/dockerhub-proxy'
```

---

## 下一步操作

### 1. 提交Git修改

```bash
cd /f/python资料/服务部署文档/安装jenkins

# 查看修改
git status
git diff Jenkinsfile-nms4cloud-final
git diff Jenkinsfile-nms4cloud-pos-java-optimized
git diff Jenkinsfile-nms4cloud-pos-java-optimized-v2

# 添加文件
git add Jenkinsfile-nms4cloud-final
git add Jenkinsfile-nms4cloud-pos-java-optimized
git add Jenkinsfile-nms4cloud-pos-java-optimized-v2

# 提交
git commit -m "修复Harbor服务地址: harbor-core.harbor -> harbor.harbor

- 修复3个Jenkinsfile文件
- Harbor主服务是harbor(nginx),不是harbor-core
- 解决Kaniko连接Harbor失败的问题"

# 推送
git push
```

### 2. 重新运行Jenkins构建

1. 打开Jenkins Web界面
2. 选择项目
3. 点击 "Build with Parameters"
4. 确保选择: **DOCKER_REGISTRY_SOURCE = harbor-proxy**
5. 点击 "构建"

### 3. 观察构建日志

**预期成功输出:**
```
>>> [1/2] 开始构建镜像...
  镜像源: Harbor代理(本地缓存)
[INFO] Retrieving image eclipse-temurin:21-jre
[INFO] Retrieving image eclipse-temurin:21-jre from mapped registry harbor.harbor
✓ 镜像构建完成 (耗时: 0分8秒)
```

**不应该再看到:**
```
❌ WARN Failed to retrieve image from remapped registry harbor-core.harbor
❌ dial tcp 10.43.196.249:443: connect: connection refused
```

---

## Harbor服务架构说明

### 正确的服务名称

| 服务名 | 用途 | 是否对外 | 访问方式 |
|--------|------|----------|----------|
| **harbor** | 主入口(nginx) | ✅ 是 | `harbor.harbor` |
| harbor-core | 核心服务 | ❌ 否 | 仅内部使用 |
| harbor-registry | 镜像存储 | ❌ 否 | 通过nginx访问 |
| harbor-portal | Web界面 | ❌ 否 | 通过nginx访问 |

### Kaniko应该使用的地址

```groovy
// ✅ 正确
--registry-mirror=harbor.harbor/dockerhub-proxy
--destination=harbor.harbor/library/myapp:latest

// ❌ 错误
--registry-mirror=harbor-core.harbor/dockerhub-proxy
--destination=harbor-core.harbor/library/myapp:latest
```

---

## 性能预期

### 首次构建(无缓存)
```
拉取 eclipse-temurin:21-jre
├─ Kaniko → harbor.harbor
├─ Harbor检查缓存: 未找到
├─ Harbor → DaoCloud拉取: 5-10秒
├─ Harbor缓存到本地
└─ 返回给Kaniko

总耗时: 8-12秒
```

### 后续构建(有缓存)
```
拉取 eclipse-temurin:21-jre
├─ Kaniko → harbor.harbor
├─ Harbor检查缓存: 找到 ✓
└─ 直接返回缓存

总耗时: 1-3秒 ← 快10倍!
```

---

## 故障排查

如果仍然失败,检查:

1. **Harbor服务状态**
   ```bash
   kubectl get svc harbor -n harbor
   kubectl get pods -n harbor
   ```

2. **测试连接**
   ```bash
   kubectl run test --image=curlimages/curl --rm -it --restart=Never -n jenkins \
     -- curl -v http://harbor.harbor/v2/
   ```

3. **查看Harbor日志**
   ```bash
   kubectl logs -n harbor -l component=nginx --tail=50
   ```

---

## 总结

✅ **已完成**
- 修复3个Jenkinsfile文件
- 所有 `harbor-core.harbor` → `harbor.harbor`
- 共修改10处配置

🎯 **下一步**
- 提交Git修改
- 重新运行Jenkins构建
- 验证镜像拉取成功

📊 **预期效果**
- 首次: 8-12秒
- 后续: 1-3秒
- 速度提升: 10-30倍
