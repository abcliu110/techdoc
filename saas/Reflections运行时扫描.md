# Reflections 运行时扫描

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos1starter
> 最后更新：2026-04-30

---

## 一、组件概述

**Reflections**（`org.reflections:reflections`）是一个运行时注解扫描库，能够扫描指定包下的所有类，查找带有特定注解的类并自动收集。在 nms4pos 中，pos1starter 使用 Reflections 实现：
- **自动组件发现**：扫描所有 `@Component` 之外的业务 Bean（如 `@JobHandler` 自定义任务处理器）
- **路由自动注册**：扫描所有 Controller 注解类，生成 API 路由映射

---

## 二、Maven 依赖

**pos1starter**（`nms4cloud-pos1starter/pom.xml`）：

```xml
<!-- Reflections 运行时注解扫描 -->
<dependency>
    <groupId>org.reflections</groupId>
    <artifactId>reflections</artifactId>
    <version>0.10.2</version>
</dependency>
```

---

## 三、核心使用方式

### 3.1 初始化扫描器

```java
import org.reflections.Reflections;
import org.reflections.scanners.Scanner;
import org.reflections.util.ClasspathHelper;
import org.reflections.util.ConfigurationBuilder;

public class ComponentScanner {

    private Reflections reflections;

    public ComponentScanner() {
        this.reflections = new Reflections(
            new ConfigurationBuilder()
                // 扫描的包路径
                .setUrls(ClasspathHelper.forPackage("com.nms4cloud.pos"))
                // 使用的扫描器（注解扫描 + 子类型扫描）
                .setScanners(
                    new SubTypesScanner(),
                    new AnnotationsScanner()
                )
                // 可选：排除测试类
                .filterInputsBy(new FilterBuilder()
                    .exclude(".*Test$"))
        );
    }
}
```

### 3.2 扫描带特定注解的类

```java
// 扫描所有 @PrintHandler 注解的类
public Set<Class<?>> scanPrintHandlers() {
    return reflections.getTypesAnnotatedWith(PrintHandler.class);
}

// 扫描所有实现了特定接口的类
public <T> Set<Class<? extends T>> scanImpl(Class<T> interfaceClass) {
    return reflections.getSubTypesOf(interfaceClass);
}

// 使用示例
public void registerHandlers() {
    Set<Class<?>> handlerClasses = scanPrintHandlers();

    for (Class<?> handlerClass : handlerClasses) {
        try {
            // 实例化并注册
            Object handler = handlerClass.getDeclaredConstructor().newInstance();
            handlerRegistry.register(handler);
            log.info("注册处理器: {}", handlerClass.getName());
        } catch (Exception e) {
            log.error("注册处理器失败: {}", handlerClass.getName(), e);
        }
    }
}
```

### 3.3 扫描方法注解

```java
// 扫描所有带 @JobMethod 注解的方法
public Set<Method> scanJobMethods() {
    return reflections.getMethodsAnnotatedWith(JobMethod.class);
}

// 扫描结果使用
public void initJobs() {
    Set<Method> methods = scanJobMethods();

    for (Method method : methods) {
        String jobName = method.getAnnotation(JobMethod.class).name();
        Object bean = applicationContext.getBean(method.getDeclaringClass());

        scheduler.scheduleJob(
            jobName,
            () -> method.invoke(bean)  // 执行带注解的方法
        );
    }
}
```

---

## 四、注意事项

1. **性能影响**：Reflections 在启动时扫描全路径，依赖 JAR 多时可能较慢，建议限定扫描包范围
2. **启动时执行**：扫描操作应在应用启动阶段完成，不适合运行时高频调用
3. **0.10.2 版本**：较新版本，兼容 Java 11+，使用前检查 JDK 版本

---

## 五、相关文档

- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)