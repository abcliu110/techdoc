# Harbor认证问题诊断和修复

## 问题分析

错误信息：
```
UNAUTHORIZED: unauthorized to access repository: library/nms4cloud-pos3boot, action: push
```

## 可能的原因

### 1. Secret服务器地址不匹配 ⭐ (最可能)

**问题**：Secret可能是用旧地址 `harbor-core.harbor` 创建的

**检查方法**：
```bash
# 查看Secret内容
kubectl get secret harbor-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .

# 应该看到类似：
{
  "auths": {
    "harbor-core.harbor": {  ← 如果是这个，就是问题所在！
      "username": "admin",
      "password": "Harbor12345",
      "auth": "..."
    }
  }
}

# 正确的应该是：
{
  "auths": {
    "harbor.harbor": {  ← 应该是这个
      "username": "admin",
      "password": "Harbor12345",
      "auth": "..."
    }
  }
}
```

**修复方法**：
```bash
# 删除旧Secret
kubectl delete secret harbor-registry-secret -n jenkins

# 创建新Secret（使用正确的服务器地址）
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor.harbor \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n jenkins
```

### 2. Harbor library项目权限问题

**问题**：library项目可能不允许推送

**检查方法**：
1. 访问Harbor Web界面: http://<节点IP>:30002
2. 登录（admin/Harbor12345）
3. 进入 "项目" → "library"
4. 检查项目是否存在
5. 检查项目访问级别

**修复方法**：

如果library项目不存在，创建它：
1. 点击 "新建项目"
2. 项目名称：`library`
3. 访问级别：公开
4. 点击 "确定"

如果library项目存在但权限不对：
1. 进入library项目
2. 点击 "配置"
3. 确保admin用户有推送权限

### 3. Harbor用户密码错误

**检查方法**：
```bash
# 测试Harbor登录
curl -u admin:Harbor12345 http://harbor.harbor/v2/_catalog

# 应该返回：
{"repositories":[...]}

# 如果返回401，说明密码错误
```

**修复方法**：
1. 登录Harbor Web界面
2. 重置admin密码
3. 使用新密码重新创建Secret

---

## 快速修复步骤

### 步骤1: 检查当前Secret

```bash
kubectl get secret harbor-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d
```

### 步骤2: 重新创建Secret

```bash
# 删除旧Secret
kubectl delete secret harbor-registry-secret -n jenkins

# 创建新Secret（确保使用 harbor.harbor）
kubectl create secret docker-registry harbor-registry-secret \
  --docker-server=harbor.harbor \
  --docker-username=admin \
  --docker-password=Harbor12345 \
  -n jenkins

# 验证
kubectl get secret harbor-registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .
```

### 步骤3: 检查Harbor library项目

访问Harbor Web界面，确保：
- ✅ library项目存在
- ✅ 项目访问级别：公开
- ✅ admin用户有推送权限

### 步骤4: 重新运行Jenkins构建

1. 打开Jenkins Web界面
2. 选择项目
3. 点击 "Build with Parameters"
4. 点击 "构建"

---

## 预期结果

**成功的日志：**
```
>>> [2/2] 开始推送镜像到Harbor...
Pushing image to harbor.harbor/library/nms4cloud-pos3boot:46
✓ 镜像推送完成 (耗时: 0分15秒)
```

**不应该再看到：**
```
❌ UNAUTHORIZED: unauthorized to access repository
```

---

## 如果仍然失败

### 调试方法1: 手动测试认证

在Jenkins Pod中测试：
```bash
# 进入Kaniko容器
kubectl exec -it <jenkins-agent-pod> -n jenkins -c kaniko -- sh

# 检查认证配置
cat /kaniko/.docker/config.json

# 应该看到 harbor.harbor 的认证信息
```

### 调试方法2: 使用Docker测试

在任何能访问Harbor的机器上：
```bash
# 登录Harbor
docker login harbor.harbor -u admin -p Harbor12345

# 推送测试镜像
docker pull busybox
docker tag busybox harbor.harbor/library/test:latest
docker push harbor.harbor/library/test:latest

# 如果成功，说明Harbor配置正确
# 如果失败，说明Harbor本身有问题
```

### 调试方法3: 检查Harbor日志

```bash
# 查看Harbor Core日志
kubectl logs -n harbor -l component=core --tail=50

# 查看Harbor Nginx日志
kubectl logs -n harbor -l component=nginx --tail=50

# 查找UNAUTHORIZED相关的错误
```

---

## 总结

最可能的原因是**Secret中的服务器地址不匹配**。

修复步骤：
1. 删除旧Secret
2. 使用 `harbor.harbor` 创建新Secret
3. 确保Harbor library项目存在且有权限
4. 重新运行构建

如果还有问题，请提供：
1. Secret的内容（脱敏后）
2. Harbor Web界面的截图
3. Harbor日志
