# nms4cloud-generator 依赖问题修复说明

## 问题描述

在构建 `nms4cloud-pos-java` 项目时，遇到以下错误：

```
[ERROR] Failed to execute goal on project nms4cloud-pos4cloud-app:
Could not resolve dependencies for project com.nms4cloud:nms4cloud-pos4cloud-app:jar:0.0.1-SNAPSHOT
[ERROR] dependency: com.nms4cloud:nms4cloud-generator:jar:0.0.1-SNAPSHOT (test)
[ERROR]     Could not find artifact com.nms4cloud:nms4cloud-generator:jar:0.0.1-SNAPSHOT
```

## 问题原因

`nms4cloud-generator` 是一个代码生成器工具，作为 **test scope** 依赖被引用：

```xml
<dependency>
    <groupId>com.nms4cloud</groupId>
    <artifactId>nms4cloud-generator</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <scope>test</scope>
</dependency>
```

**问题：**
- `nms4cloud-generator` 在独立的Git仓库中
- 在 `nms4cloud-pos-java` 项目中不存在
- Maven无法找到这个依赖

## 解决方案

在Maven构建前，**临时移除** `nms4cloud-generator` 依赖：

```groovy
// 临时移除各模块的 generator 测试依赖
echo ">>> 移除 generator 依赖（临时修改，不影响 Git）"
sh '''
    set +x
    # 查找所有包含 generator 依赖的 pom.xml 文件并移除
    find . -name "pom.xml" -type f -exec grep -l "nms4cloud-generator" {} \\; | while read pom; do
        echo "处理: $pom"
        perl -i.bak -0pe 's/<dependency>\\s*<groupId>com\\.nms4cloud<\\/groupId>\\s*<artifactId>nms4cloud-generator<\\/artifactId>.*?<\\/dependency>//gs' "$pom"
    done
    echo "✓ generator 依赖已移除"
'''
```

### 工作原理

1. **查找包含 generator 依赖的 pom.xml**
   ```bash
   find . -name "pom.xml" -type f -exec grep -l "nms4cloud-generator" {} \;
   ```

2. **使用 perl 正则表达式移除依赖**
   ```bash
   perl -i.bak -0pe 's/<dependency>...<\/dependency>//gs' "$pom"
   ```
   - `-i.bak`: 原地修改，备份为 `.bak` 文件
   - `-0`: 将整个文件作为一个字符串处理
   - `-pe`: 执行正则替换
   - `s/...//gs`: 全局替换（删除匹配的内容）

3. **不影响 Git**
   - 只修改工作区文件
   - 不提交到Git
   - 构建完成后自动清理

## 修复的文件

✅ `Jenkinsfile-nms4cloud-pos-java-optimized-v2`

已添加移除 generator 依赖的逻辑，与原文件 `Jenkinsfile-nms4cloud-pos-java-optimized` 保持一致。

## 验证方法

### 1. 查看构建日志

```bash
>>> 移除 generator 依赖（临时修改，不影响 Git）
处理: ./pos4cloud/pom.xml
处理: ./pos5sync/pom.xml
✓ generator 依赖已移除
```

### 2. 验证 pom.xml 已修改

```bash
# 在构建过程中，generator 依赖已被移除
grep -r "nms4cloud-generator" . --include="pom.xml"
# 应该没有输出（或只有备份文件 .bak）
```

### 3. Maven 构建成功

```bash
[INFO] BUILD SUCCESS
[INFO] Total time: 3:25 min
```

## 为什么不直接修改 pom.xml？

### 方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| **临时移除依赖（当前方案）** | ✅ 不影响源代码<br>✅ 不需要提交Git<br>✅ 灵活，易于维护 | ❌ 每次构建都要执行 |
| **直接修改 pom.xml** | ✅ 一次修改，永久生效 | ❌ 需要修改源代码<br>❌ 需要提交Git<br>❌ 影响本地开发 |
| **构建 generator 模块** | ✅ 解决根本问题 | ❌ 需要额外的Git仓库<br>❌ 增加构建复杂度 |

**选择当前方案的原因：**
- 不修改源代码
- 不影响开发环境
- 构建时自动处理
- 与主项目保持一致

## 相关项目

### nms4cloud 主项目
- 文件：`Jenkinsfile-nms4cloud-final`
- 也有类似的 generator 依赖问题
- 使用相同的解决方案

### nms4cloud-pos-java 项目
- 文件：`Jenkinsfile-nms4cloud-pos-java-optimized`（原文件）
- 文件：`Jenkinsfile-nms4cloud-pos-java-optimized-v2`（优化版，已修复）

## 注意事项

1. **不要删除 .bak 文件的清理逻辑**
   - perl 会生成 `.bak` 备份文件
   - 这些文件不会影响构建
   - 构建完成后会自动清理

2. **如果需要使用 generator**
   - 在本地开发环境中保留依赖
   - 只在 Jenkins 构建时移除

3. **正则表达式说明**
   ```perl
   s/<dependency>\s*<groupId>com\.nms4cloud<\/groupId>\s*<artifactId>nms4cloud-generator<\/artifactId>.*?<\/dependency>//gs
   ```
   - `\s*`: 匹配任意空白字符
   - `.*?`: 非贪婪匹配（匹配最短的内容）
   - `//gs`: 全局替换为空（删除）

## 故障排查

### 问题1: 依赖仍然存在

**症状：**
```
Could not find artifact com.nms4cloud:nms4cloud-generator
```

**解决：**
1. 检查 perl 是否安装
   ```bash
   perl --version
   ```

2. 检查正则表达式是否正确
   ```bash
   # 手动测试
   perl -0pe 's/<dependency>.*?nms4cloud-generator.*?<\/dependency>//gs' pom.xml
   ```

3. 查看构建日志，确认依赖已移除

### 问题2: 构建失败，找不到其他依赖

**症状：**
```
Could not find artifact com.nms4cloud:xxx
```

**解决：**
- 检查是否误删了其他依赖
- 查看 `.bak` 备份文件
- 恢复 pom.xml：`mv pom.xml.bak pom.xml`

### 问题3: perl 命令不存在

**症状：**
```
perl: command not found
```

**解决：**
```bash
# 在 Maven 镜像中安装 perl
apt-get update && apt-get install -y perl
```

或者修改 Jenkinsfile，使用 sed 替代：
```bash
sed -i '/<dependency>.*nms4cloud-generator.*<\/dependency>/d' pom.xml
```

## 总结

通过在构建前临时移除 `nms4cloud-generator` 依赖，成功解决了依赖找不到的问题，同时不影响源代码和本地开发环境。
