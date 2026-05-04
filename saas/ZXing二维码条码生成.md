# ZXing 二维码与条码生成

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos1starter、pos2plugin-biz
> 最后更新：2026-04-30

---

## 一、组件概述

**ZXing**（"Zebra Crossing"）是 Google 开源的条形码处理库，纯 Java 实现，支持多种格式的编码/解码。nms4pos 使用 ZXing 生成：
- **二维码**：微信/支付宝支付二维码、会员卡二维码
- **一维码**：商品条码（EAN-13/EAN-8/UPC-A）、小票订单条码

---

## 二、Maven 依赖

**pos1starter**（`nms4cloud-pos1starter/pom.xml`）：

```xml
<!-- ZXing Core -->
<dependency>
    <groupId>com.google.zxing</groupId>
    <artifactId>core</artifactId>
    <version>3.5.2</version>
</dependency>
```

**pos2plugin-biz**（`nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/pom.xml`）：

```xml
<!-- ZXing Core -->
<dependency>
    <groupId>com.google.zxing</groupId>
    <artifactId>core</artifactId>
    <version>3.4.1</version>
</dependency>
<!-- ZXing JavaSE（渲染扩展） -->
<dependency>
    <groupId>com.google.zxing</groupId>
    <artifactId>javase</artifactId>
    <version>3.4.1</version>
</dependency>
```

---

## 三、核心使用方式

### 3.1 生成二维码（QR Code）

```java
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

// QR Code 生成
public BufferedImage generateQRCode(String content, int width, int height) {
    try {
        QRCodeWriter qrCodeWriter = new QRCodeWriter();

        Map<EncodeHintType, Object> hints = new HashMap<>();
        hints.put(EncodeHintType.CHARACTER_SET, "UTF-8");
        hints.put(EncodeHintType.MARGIN, 1);  // 白色边距（格子数）

        BitMatrix bitMatrix = qrCodeWriter.encode(
            content,
            BarcodeFormat.QR_CODE,
            width,
            height,
            hints
        );

        return MatrixToImageWriter.toBufferedImage(bitMatrix);
    } catch (Exception e) {
        log.error("生成二维码失败", e);
        return null;
    }
}
```

### 3.2 生成支付二维码

POS 收银系统在顾客付款时生成微信/支付宝支付二维码：

```java
// 支付二维码生成（微信/支付宝扫码付）
public File generatePayQRCode(String orderNo, String payUrl) {
    try {
        // 微信/支付宝支付链接作为二维码内容
        BufferedImage qrImage = generateQRCode(payUrl, 300, 300);

        // 添加门店 Logo 水印（可选）
        Graphics2D g = qrImage.createGraphics();
        g.drawImage(logoImage,
            (qrImage.getWidth() - logoSize) / 2,
            (qrImage.getHeight() - logoSize) / 2,
            logoSize, logoSize, null);
        g.dispose();

        // 输出为 PNG
        File outputFile = new File("/tmp/qr_" + orderNo + ".png");
        ImageIO.write(qrImage, "PNG", outputFile);
        return outputFile;
    } catch (Exception e) {
        log.error("生成支付二维码失败 orderNo={}", orderNo, e);
        return null;
    }
}
```

### 3.3 生成一维码（EAN-13）

```java
import com.google.zxing.oned.EAN13Writer;
import com.google.zxing.client.j2se.MatrixToImageWriter;

public BufferedImage generateEAN13Barcode(String productCode) {
    try {
        EAN13Writer writer = new EAN13Writer();

        Map<EncodeHintType, Object> hints = new HashMap<>();
        hints.put(EncodeHintType.MARGIN, 10);

        BitMatrix bitMatrix = writer.encode(
            productCode,         // 必须是 12 或 13 位数字
            BarcodeFormat.EAN_13,
            300,                 // 宽度
            100                  // 高度
        );

        return MatrixToImageWriter.toBufferedImage(bitMatrix);
    } catch (Exception e) {
        log.error("生成EAN-13条码失败: {}", productCode, e);
        return null;
    }
}
```

### 3.4 生成 Code128（订单号条码）

Code128 支持任意 ASCII 字符，常用于订单号、流水号：

```java
import com.google.zxing.oned.Code128Writer;

public BufferedImage generateCode128(String orderNo) {
    Code128Writer writer = new Code128Writer();

    BitMatrix bitMatrix = writer.encode(
        orderNo,
        BarcodeFormat.CODE_128,
        400,  // 宽度
        80    // 高度
    );

    return MatrixToImageWriter.toBufferedImage(bitMatrix);
}
```

---

## 四、典型业务场景

| 场景 | 格式 | 说明 |
|------|------|------|
| 微信/支付宝扫码付 | QR Code | 将支付链接编码为二维码，顾客扫码支付 |
| 会员卡二维码 | QR Code | 会员识别码，一键入会 |
| 小票订单条码 | Code128 | 订单号编码，退款/查询时扫描 |
| 商品条码 | EAN-13 | 进货/库存管理 |
| 取餐叫号二维码 | QR Code | 绑定桌号/订单号，支持扫码查询 |

---

## 五、pos1starter vs pos2plugin 版本差异

- **pos1starter**：`core 3.5.2`，仅使用核心编码能力，渲染在 pos2plugin 中完成
- **pos2plugin-biz**：`core 3.4.1` + `javase 3.4.1`，使用 JavaSE 扩展渲染 PNG

---

## 六、相关文档

- [jSerialComm与RXTX串口通信](./jSerialComm与RXTX串口通信.md) — 小票打印机打印二维码
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)