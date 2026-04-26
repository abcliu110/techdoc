﻿# Launch4j Spring Boot Demo

这个 demo 用来学习：

```text
IntelliJ IDEA 构建 Spring Boot jar
Launch4j 图形界面生成 Windows exe
```

不使用脚本。

## 项目结构

```text
launch4j-spring-demo/
  pom.xml
  src/main/java/com/example/launch4jdemo/
  src/main/resources/application.yml
  launch4j/
    wrap-jar.xml
    external-libs-server.xml
```

## 操作顺序

1. 用 IntelliJ IDEA 打开本目录。
2. 等 Maven 依赖下载完成。
3. 在 IDEA 右侧 Maven 面板执行 `Lifecycle -> clean`。
4. 再执行 `Lifecycle -> package`。
5. 确认生成 `target/launch4j-spring-demo-1.0.0.jar`。
6. 打开 Launch4j 图形界面 `launch4j.exe`。
7. 打开 `launch4j/wrap-jar.xml`。
8. 点击齿轮按钮 Build wrapper。
9. 确认生成 `target/launch4j-spring-demo.exe`。
10. 双击 exe，浏览器访问 `http://localhost:18080/ping`。

## 两个 Launch4j 配置

`wrap-jar.xml`：

```text
把 Spring Boot jar 包进 exe。
适合学习和小 demo。
Jar 路径使用 ../target/...，因为 Launch4j 按 XML 文件所在目录解析相对路径。
```

`external-libs-server.xml`：

```text
exe 不包含 jar，只从 runtime/libs 加载 jar。
更接近 pos4install 里的 server.exe。
```
