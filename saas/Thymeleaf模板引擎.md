# Thymeleaf 模板引擎

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos3boot-app
> 最后更新：2026-04-30

---

## 一、组件概述

**Thymeleaf**（`spring-boot-starter-thymeleaf`）是 Spring Boot 推荐的服务端模板引擎，用于生成 HTML 页面。pos3boot 是 nms4pos 的本地启动服务，通过 Thymeleaf 渲染收银小票、订单凭条的 HTML 模板。

---

## 二、Maven 依赖

**pos3boot-app**（`nms4cloud-pos3boot/nms4cloud-pos3boot-app/pom.xml`）：

```xml
<!-- Thymeleaf 模板引擎 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>

<!-- Jackson JSR310（LocalDateTime JSON 序列化） -->
<dependency>
    <groupId>com.fasterxml.jackson.datatype</groupId>
    <artifactId>jackson-datatype-jsr310</artifactId>
    <version>2.13.0</version>
</dependency>
```

---

## 三、核心使用方式

### 3.1 配置

```yaml
# application.yml
spring:
  thymeleaf:
    prefix: classpath:/templates/       # 模板目录
    suffix: .html                       # 模板后缀
    mode: HTML                          # 解析模式
    encoding: UTF-8
    cache: false                        # 开发环境关闭缓存
```

### 3.2 渲染小票模板

```java
import org.springframework.stereotype.Controller;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

@Controller
public class ReceiptController {

    @Autowired
    private TemplateEngine templateEngine;

    @GetMapping("/receipt/preview/{orderId}")
    public String previewReceipt(@PathVariable Long orderId, Model model) {
        Order order = orderService.findById(orderId);

        // 设置模板变量
        model.addAttribute("order", order);
        model.addAttribute("storeName", order.getStore().getName());
        model.addAttribute("cashier", SecurityContext.getCurrentUser());

        // 返回模板路径（src/main/resources/templates/receipt.html）
        return "receipt";
    }

    // 渲染为字符串（用于 PDF 生成或打印）
    public String renderReceiptHtml(Order order) {
        Context context = new Context();
        context.setVariable("order", order);
        context.setVariable("storeName", order.getStore().getName());
        context.setVariable("items", order.getItems());

        return templateEngine.process("receipt", context);
    }
}
```

### 3.3 模板文件示例（receipt.html）

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title th:text="${order.orderNo} + ' - 小票'">订单小票</title>
    <style>
        body { font-family: monospace; width: 58mm; margin: 0 auto; }
        .center { text-align: center; }
        .bold { font-weight: bold; }
        .line { border-top: 1px dashed #000; margin: 4px 0; }
    </style>
</head>
<body>
    <div class="center bold" th:text="${storeName}">门店名称</div>
    <div class="line"></div>

    <div>订单号：<span th:text="${order.orderNo}">20250430001</span></div>
    <div>下单时间：<span th:text="${#temporals.format(order.createTime, 'yyyy-MM-dd HH:mm')}">2025-04-30 10:30</span></div>
    <div class="line"></div>

    <!-- 循环打印菜品 -->
    <div th:each="item : ${items}">
        <span th:text="${item.dishName}">宫保鸡丁</span>
        <span>x<span th:text="${item.quantity}">2</span></span>
        <span class="right" th:text="${'¥' + item.subtotal}">¥58.00</span>
    </div>

    <div class="line"></div>
    <div class="bold right" th:text="'合计: ¥' + ${order.totalAmount}">合计: ¥116.00</div>
    <div class="line"></div>

    <div class="center">感谢光临，欢迎下次光临</div>
</body>
</html>
```

---

## 四、注意事项

1. **模板缓存**：生产环境应开启 Thymeleaf 缓存，提升渲染性能
2. **JSR310 支持**：Jackson JSR310 处理 LocalDateTime 的 Thymeleaf 格式化
3. **PDF 转换**：Thymeleaf 渲染 HTML 后，可结合 Flying Saucer 或 iText 转 PDF

---

## 五、相关文档

- [PDFBox文档处理](./PDFBox文档处理.md) — PDF 生成
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)