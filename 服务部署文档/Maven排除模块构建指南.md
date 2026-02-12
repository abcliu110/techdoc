# Maven 排除模块构建指南

## 概述

本文档详细说明如何在 Maven 多模块项目中排除不能编译的模块，继续构建其他模块。

---

## 一、为什么需要排除模块？

### 常见场景

1. **模块编译失败**
   - 依赖缺失
   - 代码错误
   - 配置问题

2. **模块暂时不需要**
   - 开发中的模块
   - 实验性功能
   - 已废弃的模块

3. **加快构建速度**
   - 只构建需要的模块
   - 节省时间

---

## 二、Maven 排除模块的方法

### 方法1：使用 -pl 和 ! 排除（推荐）

#### 语法

```bash
mvn install -pl '!module-name'
```

#### 示例

**排除单个模块：**
```bash
mvn clean install -pl '!nms4cloud-payment-service' -DskipTests
```

**排除多个模块：**
```bash
mvn clean install -pl '!nms4cloud-payment-service,!nms4cloud-order-service' -DskipTests
```

**构建指定模块，排除其他：**
```bash
mvn clean install -pl nms4cloud-starter,nms4cloud-app -DskipTests
```

#### 参数说明

- `-pl`：projects（项目）
- `!`：排除符号
- `,`：分隔多个模块

#### 注意事项

⚠️ **引号很重要！**
- Linux/Mac：使用单引号 `'!module'`
- Windows：使用双引号 `"!module"` 或转义 `^!module`

---

### 方法2：在父 pom.xml 中注释模块

#### 修改父 pom.xml

```xml
<modules>
    <module>nms4cloud-starter</module>
    <module>nms4cloud-app</module>
    <!-- 注释掉不需要的模块 -->
    <!-- <module>nms4cloud-payment-service</module> -->
</modules>
```

#### 优点

- ✅ 简单直接
- ✅ 不需要修改构建命令

#### 缺点

- ❌ 需要修改代码
- ❌ 可能影响其他开发者

---

### 方法3：使用 Maven Profile

#### 在父 pom.xml 中配置

```xml
<profiles>
    <!-- 默认构建所有模块 -->
    <profile>
        <id>all</id>
        <activation>
            <activeByDefault>true</activeByDefault>
        </activation>
        <modules>
            <module>nms4cloud-starter</module>
            <module>nms4cloud-app</module>
            <module>nms4cloud-payment-service</module>
        </modules>
    </profile>

    <!-- 排除 payment 模块 -->
    <profile>
        <id>exclude-payment</id>
        <modules>
            <module>nms4cloud-starter</module>
            <module>nms4cloud-app</module>
            <!-- 不包含 payment -->
        </modules>
    </profile>
</profiles>
```

#### 使用

```bash
# 使用默认 profile（构建所有模块）
mvn clean install

# 使用 exclude-payment profile（排除 payment）
mvn clean install -P exclude-payment
```

---

## 三、在 Jenkins 中排除模块

### 3.1 方法1：在 Jenkinsfile 中配置（已实现）

#### 配置环境变量

```groovy
environment {
    // 排除的模块（不能编译的模块）
    EXCLUDE_MODULES = 'nms4cloud-payment-service'  // 多个模块用逗号分隔
}
```

#### 在构建命令中使用

```groovy
sh """
    echo "排除的模块: ${EXCLUDE_MODULES}"
    mvn clean install -pl '!${EXCLUDE_MODULES}' -DskipTests
"""
```

#### 排除多个模块

```groovy
environment {
    EXCLUDE_MODULES = 'nms4cloud-payment-service,nms4cloud-order-service'
}
```

---

### 3.2 方法2：添加参数化选项

#### 修改 Jenkinsfile 参数

```groovy
parameters {
    choice(
        name: 'BUILD_MODULE',
        choices: [
            'all',
            'all-exclude-payment',  // 排除 payment
            'nms4cloud-starter',
            'nms4cloud-app'
        ],
        description: '选择构建模块'
    )
}
```

#### 在构建阶段处理

```groovy
switch(params.BUILD_MODULE) {
    case 'all':
        buildModule = ''
        break
    case 'all-exclude-payment':
        buildModule = '-pl !nms4cloud-payment-service'
        break
    case 'nms4cloud-starter':
        buildModule = '-pl nms4cloud-starter -am'
        break
}
```

---

### 3.3 方法3：使用字符串参数

#### 添加参数

```groovy
parameters {
    string(
        name: 'EXCLUDE_MODULES',
        defaultValue: '',
        description: '要排除的模块（多个用逗号分隔，如：module1,module2）'
    )
}
```

#### 在构建阶段使用

```groovy
sh """
    if [ -n "${params.EXCLUDE_MODULES}" ]; then
        echo "排除的模块: ${params.EXCLUDE_MODULES}"
        mvn clean install -pl '!${params.EXCLUDE_MODULES}' -DskipTests
    else
        echo "构建所有模块"
        mvn clean install -DskipTests
    fi
"""
```

---

## 四、实际示例

### 示例1：排除 payment-service

#### 命令

```bash
mvn clean install -pl '!nms4cloud-payment-service' -DskipTests -T 2C
```

#### 效果

```
构建模块：
✅ nms4cloud-starter
✅ nms4cloud-app
✅ nms4cloud-bi-api
❌ nms4cloud-payment-service (已排除)
```

---

### 示例2：排除多个模块

#### 命令

```bash
mvn clean install -pl '!nms4cloud-payment-service,!nms4cloud-order-service' -DskipTests
```

#### 效果

```
构建模块：
✅ nms4cloud-starter
✅ nms4cloud-app
✅ nms4cloud-bi-api
❌ nms4cloud-payment-service (已排除)
❌ nms4cloud-order-service (已排除)
```

---

### 示例3：只构建指定模块

#### 命令

```bash
mvn clean install -pl nms4cloud-starter,nms4cloud-app -am -DskipTests
```

#### 效果

```
构建模块：
✅ nms4cloud-starter
✅ nms4cloud-app
✅ nms4cloud-bi-api (依赖，自动构建)
❌ nms4cloud-payment-service (未指定)
❌ nms4cloud-order-service (未指定)
```

---

## 五、当前 Jenkinsfile 的配置

### 已添加的功能

#### 1. 环境变量配置

```groovy
environment {
    // 排除的模块（不能编译的模块）
    EXCLUDE_MODULES = 'nms4cloud-payment-service'  // 多个模块用逗号分隔
}
```

#### 2. 构建命令

```groovy
sh """
    echo "排除的模块: ${EXCLUDE_MODULES}"
    mvn ${cleanCmd} install -pl '!${EXCLUDE_MODULES}' ${skipTests} \
    -Dmaven.compile.fork=true \
    -T 2C
"""
```

### 如何使用

#### 排除单个模块

```groovy
EXCLUDE_MODULES = 'nms4cloud-payment-service'
```

#### 排除多个模块

```groovy
EXCLUDE_MODULES = 'nms4cloud-payment-service,nms4cloud-order-service'
```

#### 不排除任何模块

```groovy
EXCLUDE_MODULES = ''  // 空字符串
```

---

## 六、常见问题

### 问题1：排除模块后，依赖它的模块构建失败

**错误信息：**
```
[ERROR] Could not resolve dependencies for project xxx
```

**原因：**
- 其他模块依赖被排除的模块

**解决方法：**
1. 先构建被依赖的模块
2. 或者同时排除依赖它的模块

**示例：**
```bash
# 如果 order-service 依赖 payment-service
# 需要同时排除
mvn install -pl '!nms4cloud-payment-service,!nms4cloud-order-service'
```

---

### 问题2：Windows 下排除符号不生效

**错误信息：**
```
'!' is not recognized as an internal or external command
```

**原因：**
- Windows 命令行对 `!` 的处理不同

**解决方法：**

**方法1：使用双引号**
```bash
mvn install -pl "!nms4cloud-payment-service"
```

**方法2：使用转义符**
```bash
mvn install -pl ^!nms4cloud-payment-service
```

**方法3：在 Jenkinsfile 中（推荐）**
```groovy
sh """
    mvn install -pl '!${EXCLUDE_MODULES}'
"""
```

---

### 问题3：不知道项目有哪些模块

**解决方法：**

**查看父 pom.xml：**
```xml
<modules>
    <module>nms4cloud-starter</module>
    <module>nms4cloud-app</module>
    <module>nms4cloud-payment-service</module>
</modules>
```

**或者查看目录结构：**
```bash
ls -d */
```

**或者使用 Maven 命令：**
```bash
mvn help:evaluate -Dexpression=project.modules
```

---

## 七、最佳实践

### 7.1 临时排除

✅ **推荐：** 使用命令行参数

```bash
mvn install -pl '!module-name'
```

**优点：**
- 不修改代码
- 灵活方便
- 不影响其他人

---

### 7.2 长期排除

✅ **推荐：** 在父 pom.xml 中注释

```xml
<!-- <module>module-name</module> -->
```

**优点：**
- 明确标记
- 团队共识
- 避免误构建

---

### 7.3 条件排除

✅ **推荐：** 使用 Maven Profile

```xml
<profile>
    <id>exclude-payment</id>
    <modules>
        <!-- 不包含 payment -->
    </modules>
</profile>
```

**优点：**
- 灵活切换
- 支持多种场景
- 不影响默认构建

---

## 八、快速参考

### 命令速查

| 场景 | 命令 |
|------|------|
| 排除单个模块 | `mvn install -pl '!module1'` |
| 排除多个模块 | `mvn install -pl '!module1,!module2'` |
| 只构建指定模块 | `mvn install -pl module1,module2` |
| 构建模块及依赖 | `mvn install -pl module1 -am` |
| 构建模块及依赖它的模块 | `mvn install -pl module1 -amd` |

### Jenkinsfile 配置

```groovy
// 环境变量
environment {
    EXCLUDE_MODULES = 'module1,module2'
}

// 构建命令
sh """
    mvn install -pl '!${EXCLUDE_MODULES}' -DskipTests
"""
```

---

## 九、总结

### 排除模块的方法

1. ✅ **命令行参数**：`mvn install -pl '!module'`（推荐）
2. ✅ **注释 pom.xml**：`<!-- <module>module</module> -->`
3. ✅ **Maven Profile**：`mvn install -P profile-name`

### 在 Jenkins 中

1. ✅ **环境变量**：`EXCLUDE_MODULES = 'module1,module2'`
2. ✅ **参数化构建**：用户选择要排除的模块
3. ✅ **字符串参数**：用户输入要排除的模块

### 注意事项

- ⚠️ 注意模块依赖关系
- ⚠️ Windows 下使用双引号或转义符
- ⚠️ 排除模块后，依赖它的模块可能构建失败

---

## 相关文档

- [Maven多模块项目构建原理.md](./Maven多模块项目构建原理.md)
- [Jenkins构建nms4cloud项目详解.md](./Jenkins构建nms4cloud项目详解.md)
- [nms4cloud构建原理详解.md](./nms4cloud构建原理详解.md)
