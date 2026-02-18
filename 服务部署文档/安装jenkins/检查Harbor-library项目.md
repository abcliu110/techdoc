# 检查Harbor library项目配置

## 需要在Harbor Web界面检查的内容

### 1. 访问Harbor
```
http://<节点IP>:30002
用户名: admin
密码: Harbor12345
```

### 2. 检查library项目

#### 方法1: 检查项目是否存在
1. 点击 "项目"
2. 查找 `library` 项目
3. 如果不存在，需要创建

#### 方法2: 创建library项目（如果不存在）
1. 点击 "新建项目"
2. 项目名称: `library`
3. 访问级别: **公开** ← 重要！
4. 点击 "确定"

#### 方法3: 检查现有library项目配置
1. 进入 `library` 项目
2. 点击 "配置" 标签
3. 检查以下设置：
   - 访问级别: 应该是 "公开"
   - 是否允许匿名拉取: 建议启用
   - 是否阻止漏洞镜像: 建议禁用（开发环境）

### 3. 检查用户权限

1. 进入 `library` 项目
2. 点击 "成员" 标签
3. 确认 `admin` 用户有 "项目管理员" 权限

---

## 为什么library项目很重要

Harbor的项目权限控制：
- **公开项目**: 任何人可以拉取，认证用户可以推送
- **私有项目**: 只有项目成员可以访问

如果library项目不存在或配置错误，会导致：
```
UNAUTHORIZED: unauthorized to access repository: library/xxx, action: push
```

---

## 对比参考配置

参考文件推送到 `192.168.80.100:30500`，这可能是：
1. 一个简单的Docker Registry（不需要认证）
2. 或者配置了允许匿名推送

Harbor默认需要认证，所以需要：
- ✅ 正确的Secret配置
- ✅ 正确的项目权限
- ✅ 使用 `--insecure` 参数

---

## 快速验证

### 测试1: 手动推送测试镜像

```bash
# 登录Harbor
docker login harbor.harbor -u admin -p Harbor12345

# 推送测试镜像
docker pull busybox
docker tag busybox harbor.harbor/library/test:latest
docker push harbor.harbor/library/test:latest
```

如果这个测试成功，说明：
- ✅ Harbor配置正确
- ✅ library项目存在且有权限
- ✅ 认证配置正确

如果失败，检查错误信息。

### 测试2: 检查Secret是否正确

```bash
# 查看Secret内容
kubectl get secret harbor-registry-secret -n jenkins \
  -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .

# 应该看到：
{
  "auths": {
    "harbor.harbor": {  ← 确认是harbor.harbor
      "username": "admin",
      "password": "Harbor12345",
      "auth": "YWRtaW46SGFyYm9yMTIzNDU="
    }
  }
}
```

---

## 总结

参考文件可以工作是因为：
1. 使用 `--insecure` 参数
2. 目标registry配置简单（可能不需要认证）

当前配置需要确保：
1. ✅ 使用 `--insecure` (已修改)
2. ⚠️ Harbor library项目存在且配置正确
3. ⚠️ Secret配置正确（服务器地址匹配）

请先检查Harbor Web界面的library项目配置！
