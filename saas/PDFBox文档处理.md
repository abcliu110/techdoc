# PDFBox 文档处理

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos4cloud-biz
> 核心源文件：`PDFService.java`
> 最后更新：2026-04-30

---

## 一、组件概述

**Apache PDFBox**（`org.apache.pdfbox:pdfbox`）是 Apache 基金会的 PDF 处理库，用于解析和生成 PDF 文件。nms4pos 中 pos4cloud 使用 PDFBox 实现：
- **电子小票 PDF 化**：将收银小票内容导出为 PDF 存档
- **打印模板**：生成打印模板 PDF 后发送至打印机
- **发票电子化**：小票图片转 PDF 存档

---

## 二、Maven 依赖

**pos4cloud-biz**（`nms4cloud-pos4cloud/nms4cloud-pos4cloud-biz/pom.xml`）：

```xml
<!-- Apache PDFBox -->
<dependency>
    <groupId>org.apache.pdfbox</groupId>
    <artifactId>pdfbox</artifactId>
    <version>2.0.30</version>
</dependency>
```

---

## 三、核心使用方式

### 3.1 创建 PDF（小票模板）

```java
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;

import java.io.IOException;

public class PDFService {

    public byte[] generateReceiptPDF(Order order) {
        // 1. 创建空白文档
        PDDocument document = new PDDocument();

        // 2. 添加一页（指定纸张大小，A4 或 80mm 热敏纸宽）
        PDPage page = new PDPage(new PDRectangle(170, 400)); // 58mm 热敏纸（点/72 DPI）
        document.addPage(page);

        // 3. 写入内容
        try (PDPageContentStream content =
                 new PDPageContentStream(document, page)) {

            PDType1Font font = new PDType1Font(Standard14Fonts.FontName.HELVETICA);

            // 标题
            content.beginText();
            content.setFont(font, 14);
            content.newLineAtOffset(20, 360);
            content.showText("收银小票");
            content.endText();

            // 分隔线
            content.setLineWidth(0.5f);
            content.moveTo(20, 350);
            content.lineTo(150, 350);
            content.stroke();

            // 订单信息
            content.beginText();
            content.setFont(font, 8);
            float y = 330;
            for (String line : formatOrderLines(order)) {
                content.newLineAtOffset(20, y);
                content.showText(line);
                y -= 12;
            }
            content.endText();

            // 底部信息
            content.beginText();
            content.setFont(font, 6);
            content.newLineAtOffset(20, 30);
            content.showText("感谢光临，欢迎下次光临");
            content.endText();

        } catch (IOException e) {
            throw new BizException("生成 PDF 失败", e);
        }

        // 4. 导出为字节数组
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try {
            document.save(baos);
            document.close();
        } catch (IOException e) {
            throw new BizException("PDF 输出失败", e);
        }

        return baos.toByteArray();
    }

    private List<String> formatOrderLines(Order order) {
        List<String> lines = new ArrayList<>();
        lines.add("订单号: " + order.getOrderNo());
        lines.add("下单时间: " + order.getCreateTime());
        lines.add("门店: " + order.getStoreName());
        lines.add("------------------------");
        for (OrderItem item : order.getItems()) {
            lines.add(String.format("%s x%d   %s",
                item.getDishName(),
                item.getQuantity(),
                item.getSubtotal()));
        }
        lines.add("------------------------");
        lines.add("合计: " + order.getTotalAmount());
        return lines;
    }
}
```

### 3.2 读取 PDF（提取文字）

```java
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.pdfbox.pdmodel.PDDocument;

// 读取 PDF 中的文字
public String extractTextFromPDF(File pdfFile) {
    try (PDDocument document = PDDocument.load(pdfFile)) {
        PDFTextStripper stripper = new PDFTextStripper();
        stripper.setSortByPosition(true);  // 按阅读顺序提取
        return stripper.getText(document);
    } catch (IOException e) {
        throw new BizException("读取 PDF 失败", e);
    }
}
```

### 3.3 PDF 转图片（用于打印预览）

```java
import org.apache.pdfbox.rendering.PDFRenderer;
import org.apache.pdfbox.rendering.PDFRenderer;

public BufferedImage pdfToImage(File pdfFile, int dpi) {
    try (PDDocument document = PDDocument.load(pdfFile)) {
        PDFRenderer renderer = new PDFRenderer(document);
        BufferedImage image = renderer.renderImageWithDPI(0, dpi);
        return image;
    } catch (IOException e) {
        throw new BizException("PDF 转图片失败", e);
    }
}

// 将 PDF 预览图上传至 OSS
public String uploadPDFPreview(Long orderId, File pdfFile) {
    BufferedImage preview = pdfToImage(pdfFile, 150); // 150 DPI 预览

    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    ImageIO.write(preview, "PNG", baos);

    String key = "previews/" + orderId + ".png";
    ossClient.upload(key, new ByteArrayInputStream(baos.toByteArray()));
    return key;
}
```

### 3.4 合并多个 PDF

```java
// 将多张小票合并为一个 PDF
public byte[] mergeReceipts(List<Order> orders) {
    PDDocument merged = new PDDocument();

    for (Order order : orders) {
        byte[] pdfBytes = generateReceiptPDF(order);
        try (PDDocument source = PDDocument.load(
                new ByteArrayInputStream(pdfBytes))) {
            for (PDPage page : source.getPages()) {
                merged.importPage(page);
            }
        }
    }

    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    merged.save(baos);
    merged.close();
    return baos.toByteArray();
}
```

---

## 四、典型业务场景

| 场景 | 说明 |
|------|------|
| 电子发票 | 顾客结账后可选择"发送电子发票"，生成 PDF 后发送邮件 |
| 小票存档 | 每日交易结束后，将所有小票打包为 PDF 存档 |
| 打印预览 | 在管理后台预览小票效果，无需真实打印机 |
| 报表导出 | 财务对账报表导出为 PDF 下载 |

---

## 五、注意事项

1. **字体支持**：PDFBox 内置 Standard 14 Fonts（Helvetica、Times 等），中文需额外嵌入字体（`.ttf` 文件）
2. **内存占用**：处理大 PDF 时注意内存，建议使用流式处理（`PDFWriter`）避免全量加载
3. **坐标系统**：PDF 坐标系原点在左下角，与 Java AWT 的左上角不同

---

## 六、相关文档

- [jSerialComm与RXTX串口通信](./jSerialComm与RXTX串口通信.md) — 打印机输出
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)