# 百度 AI Java SDK（OCR 识别）

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos4cloud-biz
> 最后更新：2026-04-30

---

## 一、组件概述

**百度 AI Java SDK**（`com.baidu.aip:java-sdk`）提供百度 AI 开放平台的 OCR、语音、人脸识别等能力。nms4pos 中 pos4cloud 使用百度 OCR 实现**票据扫描识别**：顾客扫描发票/收据，自动识别金额、日期、商户名等关键信息，用于财务对账。

---

## 二、Maven 依赖

**pos4cloud-biz**（`nms4cloud-pos4cloud/nms4cloud-pos4cloud-biz/pom.xml`）：

```xml
<!-- 百度 AI Java SDK -->
<dependency>
    <groupId>com.baidu.aip</groupId>
    <artifactId>java-sdk</artifactId>
    <version>4.8.0</version>
</dependency>
```

---

## 三、核心实现

### 3.1 客户端初始化

```java
import com.baidu.aip.ocr.AipOcr;

public class BaiduOcrService {

    // 百度 AI 应用配置（建议从配置中心读取）
    private static final String APP_ID = "your_app_id";
    private static final String API_KEY = "your_api_key";
    private static final String SECRET_KEY = "your_secret_key";

    private AipOcr aipOcr;

    @PostConstruct
    public void init() {
        aipOcr = new AipOcr(APP_ID, API_KEY, SECRET_KEY);

        // 可选：设置连接超时和读取超时
        aipOcr.setConnectionTimeoutInMillis(5000);
        aipOcr.setSocketTimeoutInMillis(30000);
    }
}
```

### 3.2 通用文字识别（高精度）

```java
import org.json.JSONObject;

// 上传小票图片，识别全部文字
public String recognizeReceipt(File imageFile) {
    // 传入图片文件路径
    JSONObject result = aipOcr.detectText(
        imageFile.getAbsolutePath(),  // 图片路径
        AipOcr.ENUM_PIC_TYPE.JPG      // 图片类型
    );

    if (result.has("words_result")) {
        StringBuilder text = new StringBuilder();
        JSONArray wordsArray = result.getJSONArray("words_result");
        for (int i = 0; i < wordsArray.length(); i++) {
            String word = wordsArray.getJSONObject(i).getString("words");
            text.append(word).append("\n");
        }
        return text.toString();
    }

    log.warn("OCR 识别失败: {}", result.optString("error_msg"));
    return null;
}
```

### 3.3 票据识别（专用于发票/收据）

```java
import org.json.JSONObject;

// 百度票据识别（专门优化发票、收据）
public InvoiceInfo recognizeInvoice(File imageFile) {
    // 调用百度发票识别接口
    JSONObject result = aipOcr Invoice(
        imageFile.getAbsolutePath(),
        new HashMap<>()
    );

    InvoiceInfo info = new InvoiceInfo();

    if (result.has("words_result")) {
        JSONObject words = result.getJSONObject("words_result");

        // 解析关键字段
        if (words.has("InvoiceCode")) {
            info.setInvoiceCode(words.getJSONObject("InvoiceCode").getString("words"));
        }
        if (words.has("InvoiceNumber")) {
            info.setInvoiceNumber(words.getJSONObject("InvoiceNumber").getString("words"));
        }
        if (words.has("AmountInFiguers")) {
            info.setAmount(words.getJSONObject("AmountInFiguers").getString("words"));
        }
        if (words.has("InvoiceDate")) {
            info.setInvoiceDate(words.getJSONObject("InvoiceDate").getString("words"));
        }
        if (words.has("SellerName")) {
            info.setSellerName(words.getJSONObject("SellerName").getString("words"));
        }
        if (words.has("BuyerName")) {
            info.setBuyerName(words.getJSONObject("BuyerName").getString("words"));
        }
    }

    return info;
}
```

### 3.4 财务对账流程

```java
// pos4cloud — 扫描上传小票 → 百度 OCR 识别 → 财务系统对账
public ReconciliationResult reconcile(UploadedReceipt receipt) {
    // 1. 调用百度 OCR 识别小票
    InvoiceInfo invoice = recognizeInvoice(receipt.getImageFile());

    if (invoice == null) {
        return ReconciliationResult.fail("识别失败，请重试");
    }

    // 2. 从 POS 系统中查询对应订单
    Order order = orderService.findByOrderNo(receipt.getOrderNo());

    // 3. 比对金额（OCR 识别金额 vs 系统订单金额）
    BigDecimal ocrAmount = new BigDecimal(invoice.getAmount());
    BigDecimal orderAmount = order.getTotalAmount();

    if (ocrAmount.compareTo(orderAmount) != 0) {
        // 金额不一致，触发差异告警
        alertService.sendReconcileAlert(receipt, invoice, order);
        return ReconciliationResult.mismatch(ocrAmount, orderAmount);
    }

    // 4. 对账成功，标记收据已核销
    receiptService.markReconciled(receipt.getId());
    return ReconciliationResult.success();
}
```

---

## 四、OCR 识别精度说明

| 场景 | 精度 | 说明 |
|------|------|------|
| 打印小票（热敏） | 高 | 热敏纸黑白对比度高，识别率 > 95% |
| 发票 | 高 | 百度专项票据识别，支持增值税发票 |
| 手写收据 | 中 | 手写体识别率较低，建议人工复核 |
| 手机拍照 | 中低 | 需确保光照均匀、无反光、字迹清晰 |

---

## 五、注意事项

1. **调用配额**：百度 OCR 有每日免费调用额度限制（500 次/天），超量需付费
2. **图片质量**：识别精度与图片质量强相关，建议 POS 端提供图片裁剪和增强功能
3. **结果校验**：OCR 结果应作为辅助参考，重要金额信息需人工确认
4. **并发控制**：多个 POS 同时上传小票时注意 API 限流

---

## 六、相关文档

- [Tess4J-OCR识别](./Tess4J-OCR识别.md) — 本地离线 OCR（备选方案）
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)