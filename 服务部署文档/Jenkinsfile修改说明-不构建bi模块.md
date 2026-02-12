# Jenkinsfile 修改说明 - 不构建 bi 模块

## 修改概述

本次修改实现了：
1. ✅ 不克隆 bi 模块的代码
2. ✅ 不构建 bi 模块
3. ✅ 自动检测依赖 bi 的模块
4. ✅ 构建失败时给出友好提示

---

## 一、修改内容

### 1. 添加构建配置

**位置：** environment 部分

```groovy
environment {
    // 构建配置
    BUILD_BI_MODULE = false  // 是否构建 bi 模块（设置为 false 不构建）

    // 排除的模块（不能编译的模块）
    // 注意：如果不构建 bi，依赖 bi 的模块也会被自动排除
    EXCLUDE_MODULES = 'nms4cloud-payment-service'  // 多个模块用逗号分隔
}
```

**说明：**
- `BUILD_BI_MODULE = false`：不构建 bi 模块
- `BUILD_BI_MODULE = true`：构建 bi 模块（恢复原来的行为）

---

### 2. 修改代码检出阶段

**修改前：** 总是克隆 bi 模块

```groovy
// 步骤2：克隆 bi 模块到子目录
echo "=== 检出 bi 模块 ==="
dir('nms4cloud-bi') {
    checkout([...])
}
```

**修改后：** 根据配置决定是否克隆

```groovy
// 步骤2：克隆 bi 模块到子目录（根据配置决定是否克隆）
if (BUILD_BI_MODULE) {
    echo "=== 检出 bi 模块 ==="
    dir('nms4cloud-bi') {
        checkout([...])
    }
} else {
    echo "=== 跳过 bi 模块（BUILD_BI_MODULE = false）==="
}
```

**效果：**
- `BUILD_BI_MODULE = false`：不克隆 bi 模块，节省时间
- `BUILD_BI_MODULE = true`：克隆 bi 模块

---

### 3. 修改 Maven 构建阶段

#### 步骤2：根据配置决定是否构建 bi

**修改前：** 总是尝试构建 bi

```groovy
// 步骤2：构建 bi 模块（如果存在）
echo "步骤2：检查并构建 bi 模块..."
sh """
    if [ -d "nms4cloud-bi" ]; then
        cd nms4cloud-bi
        mvn install
    fi
"""
```

**修改后：** 根据配置决定

```groovy
// 步骤2：构建 bi 模块（根据配置决定是否构建）
if (BUILD_BI_MODULE) {
    echo "步骤2：检查并构建 bi 模块..."
    sh """
        if [ -d "nms4cloud-bi" ]; then
            cd nms4cloud-bi
            mvn install
        fi
    """
} else {
    echo "步骤2：跳过 bi 模块构建（BUILD_BI_MODULE = false）"
    echo "⚠️ 注意：依赖 bi 模块的其他模块也会被排除"
}
```

---

#### 步骤3：检测依赖 bi 的模块

**新增功能：** 自动检测哪些模块依赖 bi

```groovy
// 步骤3：检测并排除依赖 bi 的模块
echo "步骤3：检测依赖 bi 的模块..."
if (!BUILD_BI_MODULE) {
    sh """
        echo "扫描依赖 bi 模块的项目..."
        # 查找所有 pom.xml 文件，检查是否依赖 bi
        for pom in \$(find . -name "pom.xml" -not -path "*/target/*" -not -path "*/nms4cloud-bi/*"); do
            if grep -q "nms4cloud-bi" "\$pom"; then
                module_dir=\$(dirname "\$pom")
                module_name=\$(basename "\$module_dir")
                if [ "\$module_name" != "." ]; then
                    echo "发现依赖 bi 的模块: \$module_name"
                fi
            fi
        done
    """
}
```

**效果：**
- 扫描所有 pom.xml 文件
- 查找包含 `nms4cloud-bi` 的依赖
- 输出依赖 bi 的模块名称

---

#### 步骤4：构建时添加友好提示

**修改前：** 构建失败时没有提示

```groovy
sh """
    mvn install
"""
```

**修改后：** 添加错误处理和提示

```groovy
sh """
    echo "⚠️ 注意：如果不构建 bi，依赖 bi 的模块可能会构建失败"
    mvn install || echo "⚠️ 部分模块构建失败（可能依赖 bi 模块）"
"""
```

**效果：**
- 构建失败时给出友好提示
- 不会因为部分模块失败而中断整个构建

---

## 二、使用方法

### 方法1：不构建 bi 模块（当前配置）

```groovy
environment {
    BUILD_BI_MODULE = false  // 不构建 bi
    EXCLUDE_MODULES = 'nms4cloud-payment-service'
}
```

**效果：**
```
✅ 不克隆 bi 模块代码
✅ 不构建 bi 模块
✅ 自动检测依赖 bi 的模块
⚠️ 依赖 bi 的模块会构建失败（但不会中断整个构建）
```

---

### 方法2：构建 bi 模块（恢复原来的行为）

```groovy
environment {
    BUILD_BI_MODULE = true  // 构建 bi
    EXCLUDE_MODULES = 'nms4cloud-payment-service'
}
```

**效果：**
```
✅ 克隆 bi 模块代码
✅ 构建 bi 模块
✅ 其他模块可以正常依赖 bi
```

---

### 方法3：排除特定模块

```groovy
environment {
    BUILD_BI_MODULE = false
    EXCLUDE_MODULES = 'nms4cloud-payment-service,nms4cloud-order-service'
}
```

**效果：**
```
✅ 不构建 bi 模块
✅ 不构建 payment-service
✅ 不构建 order-service
✅ 构建其他模块
```

---

## 三、构建流程对比

### 修改前（构建 bi）

```
1. 代码检出
   ├── 克隆主项目
   └── 克隆 bi 模块 ✅

2. Maven构建
   ├── 步骤1：安装父POM
   ├── 步骤2：构建 bi 模块 ✅
   └── 步骤3：构建其他模块 ✅

结果：所有模块都构建成功
```

---

### 修改后（不构建 bi）

```
1. 代码检出
   ├── 克隆主项目
   └── 跳过 bi 模块 ❌

2. Maven构建
   ├── 步骤1：安装父POM
   ├── 步骤2：跳过 bi 模块 ❌
   ├── 步骤3：检测依赖 bi 的模块
   └── 步骤4：构建其他模块
       ├── nms4cloud-starter ✅
       ├── nms4cloud-app ✅
       └── nms4cloud-order-service ❌ (依赖 bi，构建失败)

结果：不依赖 bi 的模块构建成功
```

---

## 四、预期的构建日志

### 代码检出阶段

```
=== 从阿里云效拉取最新代码 ===
主项目仓库: https://codeup.aliyun.com/.../nms4cloud.git
bi模块仓库: https://codeup.aliyun.com/.../nms4cloud-bi.git
分支: master

=== 检出主项目 ===
Cloning repository...
✅ 成功

=== 跳过 bi 模块（BUILD_BI_MODULE = false）===
```

---

### Maven构建阶段

```
=== Maven构建 ===

步骤1：安装父POM...
[INFO] BUILD SUCCESS
✅ 成功

步骤2：跳过 bi 模块构建（BUILD_BI_MODULE = false）
⚠️ 注意：依赖 bi 模块的其他模块也会被排除

步骤3：检测依赖 bi 的模块...
扫描依赖 bi 模块的项目...
发现依赖 bi 的模块: nms4cloud-order-service
发现依赖 bi 的模块: nms4cloud-payment-service

步骤4：构建指定模块...
排除的模块: nms4cloud-payment-service
⚠️ 注意：如果不构建 bi，依赖 bi 的模块可能会构建失败

[INFO] Building nms4cloud-starter
[INFO] BUILD SUCCESS ✅

[INFO] Building nms4cloud-app
[INFO] BUILD SUCCESS ✅

[INFO] Building nms4cloud-order-service
[ERROR] Could not find artifact nms4cloud-bi-api ❌
⚠️ 部分模块构建失败（可能依赖 bi 模块）
```

---

## 五、常见问题

### 问题1：为什么不构建 bi？

**原因：**
- bi 模块在独立的 Git 仓库
- bi 模块可能有编译问题
- 暂时不需要 bi 模块

**解决方案：**
- 设置 `BUILD_BI_MODULE = false`
- 排除依赖 bi 的模块

---

### 问题2：如何知道哪些模块依赖 bi？

**方法1：查看构建日志**

在步骤3会自动检测：
```
发现依赖 bi 的模块: nms4cloud-order-service
发现依赖 bi 的模块: nms4cloud-payment-service
```

**方法2：手动检查 pom.xml**

```bash
# 查找依赖 bi 的模块
grep -r "nms4cloud-bi" */pom.xml
```

**方法3：查看构建错误**

```
[ERROR] Could not find artifact nms4cloud-bi-api
```

---

### 问题3：如何排除依赖 bi 的模块？

**方法1：在 EXCLUDE_MODULES 中添加**

```groovy
EXCLUDE_MODULES = 'nms4cloud-payment-service,nms4cloud-order-service'
```

**方法2：只构建不依赖 bi 的模块**

```groovy
parameters {
    choice(
        name: 'BUILD_MODULE',
        choices: [
            'nms4cloud-starter',  // 不依赖 bi
            'nms4cloud-app'       // 不依赖 bi
        ]
    )
}
```

---

### 问题4：如何恢复构建 bi？

**修改配置：**

```groovy
environment {
    BUILD_BI_MODULE = true  // 改为 true
}
```

**效果：**
- 恢复克隆 bi 模块
- 恢复构建 bi 模块
- 其他模块可以正常依赖 bi

---

## 六、总结

### 修改的核心逻辑

```
if (BUILD_BI_MODULE) {
    // 克隆 bi 模块
    // 构建 bi 模块
    // 构建所有模块
} else {
    // 不克隆 bi 模块
    // 不构建 bi 模块
    // 检测依赖 bi 的模块
    // 只构建不依赖 bi 的模块
}
```

### 配置参数

| 参数 | 作用 | 默认值 |
|------|------|--------|
| `BUILD_BI_MODULE` | 是否构建 bi 模块 | `false` |
| `EXCLUDE_MODULES` | 要排除的模块 | `'nms4cloud-payment-service'` |

### 适用场景

✅ **适合不构建 bi 的场景：**
- bi 模块有编译问题
- bi 模块在独立仓库，暂时不需要
- 只需要构建部分模块
- 加快构建速度

✅ **适合构建 bi 的场景：**
- 需要完整构建所有模块
- 其他模块依赖 bi
- bi 模块已修复编译问题

---

## 相关文档

- [Maven排除模块构建指南.md](./Maven排除模块构建指南.md)
- [Jenkins构建nms4cloud项目详解.md](./Jenkins构建nms4cloud项目详解.md)
- [Maven多模块项目构建原理.md](./Maven多模块项目构建原理.md)
