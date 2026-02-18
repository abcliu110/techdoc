# Harbor未安装问题解决方案

## 问题诊断

### 错误信息
```
WARN Failed to retrieve image eclipse-temurin:21-jre from remapped registry harbor-core.harbor:
unable to complete operation after 0 attempts, last error:
Get "https://harbor-core.harbor/v2/": dial tcp 10.43.196.249:443: connect: connection refused.
```

### 根本原因
**Harbor服务未安装或未运行**

诊断结果显示:
- ❌ Harbor命名空间不存在
- ❌ Harbor服务不可用
- ❌ Kaniko无法连接到Harbor代理

---

## 解决方案

你有两个选择:

### 方案A: 安装Harbor (推荐,长期最优)

如果你想使用Harbor代理加速,需要先安装Harbor服务。

#### 优点
- ✅ 镜像缓存,后续构建极快(< 2秒)
- ✅ 团队共享缓存
- ✅ 不依赖外网
- ✅ 节省带宽

#### 安装步骤

参考已有的部署脚本和文档:

1. **使用Helm安装** (推荐)
   ```bash
   # 参考文档
   cat Harbor-Helm完整部署指南.md

   # 或使用部署脚本
   bash deploy-harbor.sh
   ```

2. **验证安装**
   ```bash
   # 检查Harbor Pod状态
   kubectl get pods -n harbor

   # 检查Harbor服务
   kubectl get svc -n harbor

   # 访问Harbor Web界面
   # http://<节点IP>:30002
   ```

3. **创建代理项目**
   - 登录Harbor Web界面
   - 创建项目: `dockerhub-proxy`
   - 类型: 代理缓存
   - 端点: `https://docker.m.daocloud.io`

4. **重新运行Jenkins构建**

---

### 方案B: 临时使用DaoCloud镜像 (快速解决)

如果暂时不想安装Harbor,可以直接使用DaoCloud国内镜像源。

#### 优点
- ✅ 无需安装Harbor
- ✅ 立即可用
- ✅ 速度较快(5-10秒)

#### 缺点
- ❌ 每次都从外网拉取
- ❌ 无缓存,无法加速后续构建
- ❌ 依赖外网连接

#### 修改步骤

修改Jenkinsfile,将镜像源参数默认值改为`daocloud-mirror`:

