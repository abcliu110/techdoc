# libs6 / pos6monitor 拷贝命令对照说明

这条命令不是前端接口改动，而是安装包制包阶段，把 `pos6monitor` 的 jar 放到 `libs6\` 目录的老脚本。

## 1. 老命令

老脚本使用本地 `xcopy`：

```bat
xcopy /s /Y "..\2_nms4pos\nms4cloud-pos6monitor\target\nms4cloud-pos6monitor-0.0.1-SNAPSHOT.jar" "libs6\"
```

它的含义是：

- 从本地构建目录取 `nms4cloud-pos6monitor` 的 jar
- 拷贝到安装包目录下的 `libs6\`

## 2. 现在对应的来源位置

现有资料里，这一项已经映射到新的产物目录：

- 目标目录仍然是 `libs6\`
- 来源不再是本地固定相对路径
- 对应的产物来源目录是：

```text
/data/backend-build-output/01-nms4pos-java/nms4cloud-pos6monitor/target/
```

对应关系可以理解为：

- 老的本地来源：
  - `..\2_nms4pos\nms4cloud-pos6monitor\target\nms4cloud-pos6monitor-0.0.1-SNAPSHOT.jar`
- 现在的产物来源：
  - `/data/backend-build-output/01-nms4pos-java/nms4cloud-pos6monitor/target/*`
- 最终落地目录不变：
  - `libs6\`

## 3. 新方式对应命令

在现在的方案里，这一步通常不再用本地 `xcopy`，而是改成从 Ubuntu 拉包：

```bat
scp -r jj@192.168.1.119:/data/backend-build-output/01-nms4pos-java/nms4cloud-pos6monitor/target/* D:\制包目录\libs6\
```

如果只看含义，对应关系就是：

- 老方式：
  - 本地构建完成后，从本地 `target` 目录拷贝 jar 到 `libs6\`
- 新方式：
  - Jenkins/K8s 构建后，Windows 再从 Ubuntu 的产物目录把 jar 拉到 `libs6\`

## 4. 一句话发给同事

`libs6\` 这条老 `xcopy` 的对象是 `nms4cloud-pos6monitor` 的 jar。现在不是从本地 `..\2_nms4pos\...\target\` 拷了，而是改成从 Ubuntu 上的：

```text
/data/backend-build-output/01-nms4pos-java/nms4cloud-pos6monitor/target/
```

把产物拉到本地 `libs6\`。目标目录没变，变的是产物来源路径和取包方式。
