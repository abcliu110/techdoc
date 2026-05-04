# Tess4J OCR 识别

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos4cloud-biz
> 最后更新：2026-04-30

---

## 一、组件概述

**Tess4J**（`net.sourceforge.tess4j:tess4j`）是 Tesseract OCR 引擎的 Java 封装，支持本地离线 OCR。nms4pos 中 pos4cloud 使用 Tess4J 扫描纸质小票/发票，识别文字用于财务对账。

**与百度 OCR 的对比**：

| 特性 | Tess4J | 百度 OCR |
|------|--------|---------|
| 部署方式 | 本地离线（无需网络） | 云端 API（需联网） |
| 精度 | 中等（热敏/打印体高，手写低） | 高（有专项训练模型） |
| 离线支持 | ✅ 完全支持 | ❌ 依赖网络 |
| 维护成本 | 需要下载语言包 | 自动更新模型 |
| 适用场景 | 断网环境、隐私敏感场景 | 高精度要求的联网环境 |

---

## 二、Maven 依赖

**pos4cloud-biz**（`nms4cloud-pos4cloud/nms4cloud-pos4cloud-biz/pom.xml`）：

```xml
<!-- Tess4J（Tesseract OCR Java 封装） -->
<dependency>
    <groupId>net.sourceforge.tess4j</groupId>
    <artifactId>tess4j</artifactId>
    <version>4.5.4</version>
</dependency>
```

> Tess4J 依赖 Tesseract OCR 引擎本身（二进制可执行文件），Windows 环境需安装 `tesseract-ocr-w64-setup.exe`，并将路径配置到系统 PATH 或代码中指定。

---

## 三、核心实现

### 3.1 初始化

```java
import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;

public class Tess4jOcrService {

    private Tesseract tesseract;

    @PostConstruct
    public void init() {
        tesseract = new Tesseract();

        // 指定 tessdata 目录（语言包目录）
        // tessdata 应包含 chi_sim.traineddata（简体中文）等文件
        String tessdataPath = "/opt/tesseract/tessdata";
        tesseract.setDatapath(tessdataPath);

        // 设置语言：eng（英文）、chi_sim（简体中文）
        tesseract.setLanguage("chi_sim+eng");

        // 设置 OCR 模式（精细控制）
        tesseract.setPageSegMode(6);  // PSM_AUTO（自动分页）
        // 6 = Assume a single uniform block of text.

        // 提高精度（预处理相关参数）
        // tesseract.setOcrEngineMode(1); // LSTM 神经网络模式（更高精度）
    }
}
```

### 3.2 识别图片文字

```java
// 识别图片中的文字
public String recognizeText(File imageFile) {
    try {
        // 可选：图片预处理（提升识别率）
        BufferedImage image = ImageIO.read(imageFile);
        BufferedImage gray = toGrayscale(image); // 转灰度
        BufferedImage binarized = binarize(gray, 128); // 二值化

        // 执行 OCR
        String result = tesseract.doOCR(binarized);
        return result.trim();

    } catch (TesseractException e) {
        log.error("Tess4J OCR 识别失败: {}", e.getMessage(), e);
        return null;
    }
}

// 图像预处理：灰度转换
private BufferedImage toGrayscale(BufferedImage image) {
    BufferedImage gray = new BufferedImage(
        image.getWidth(), image.getHeight(),
        BufferedImage.TYPE_BYTE_GRAY);
    gray.getGraphics().drawImage(image, 0, 0, null);
    return gray;
}

// 图像预处理：二值化
private BufferedImage binarize(BufferedImage image, int threshold) {
    BufferedImage binarized = new BufferedImage(
        image.getWidth(), image.getHeight(),
        BufferedImage.TYPE_BYTE_BINARY);
    Graphics2D g = binarized.createGraphics();
    g.drawImage(image, 0, 0, null);
    g.dispose();
    return binarized;
}
```

### 3.3 识别后处理（提取金额）

```java
// 从 OCR 结果中提取金额
public BigDecimal extractAmount(String ocrText) {
    // 匹配金额正则：¥123.45 或 123.45 元 或 合计 123.45
    Pattern pattern = Pattern.compile(
        "(?:合计|总金额|应付)[^0-9]*([0-9]+\\.?[0-9]*)"
    );
    Matcher matcher = pattern.matcher(ocrText);

    if (matcher.find()) {
        return new BigDecimal(matcher.group(1));
    }

    // 兜底：匹配任意金额
    pattern = Pattern.compile("¥?([0-9]+\\.[0-9]{2})");
    matcher = pattern.matcher(ocrText);
    if (matcher.find()) {
        return new BigDecimal(matcher.group(1));
    }

    return null;
}
```

### 3.4 财务对账集成

```java
// 扫描纸质小票 → Tess4J OCR 识别 → 金额提取 → 对账
public ReconciliationResult reconcileReceipt(File receiptImage) {
    // 1. OCR 识别
    String text = recognizeText(receiptImage);
    if (text == null) {
        return ReconciliationResult.fail("文字识别失败");
    }

    // 2. 提取金额
    BigDecimal ocrAmount = extractAmount(text);
    if (ocrAmount == null) {
        return ReconciliationResult.fail("无法提取金额，请手动核对");
    }

    // 3. 查询系统订单
    String orderNo = extractOrderNo(text);
    Order order = orderService.findByOrderNo(orderNo);

    // 4. 对账比较
    if (ocrAmount.compareTo(order.getTotalAmount()) == 0) {
        return ReconciliationResult.success();
    } else {
        return ReconciliationResult.mismatch(ocrAmount, order.getTotalAmount());
    }
}
```

---

## 四、语言包安装

Tess4J 需要 Tesseract 语言包（`traineddata` 文件）：

```bash
# Windows（使用 chocolatey）
choco install tesseract

# Linux（Ubuntu）
sudo apt-get install tesseract-ocr
sudo apt-get install tesseract-ocr-chi-sim  # 简体中文

# 语言包默认路径
# Windows: C:\Program Files\Tesseract-OCR\tessdata
# Linux: /usr/share/tesseract-ocr/4.00/tessdata
```

---

## 五、注意事项

1. **Tesseract 引擎安装**：Tess4J 依赖操作系统安装 Tesseract OCR 引擎，不能纯 Java 独立运行
2. **语言包体积**：中文语言包（`chi_sim.traineddata`）约 15MB，需确保分发到部署环境
3. **图片质量**：识别率随图片质量下降而下降，热敏小票（高对比度）效果最好
4. **预处理是关键**：灰度 + 二值化预处理可将识别率提升 10-20%

---

## 六、相关文档

- [百度AI-Java-SDK-OCR识别](./百度AI-Java-SDK-OCR识别.md) — 云端高精度 OCR
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)