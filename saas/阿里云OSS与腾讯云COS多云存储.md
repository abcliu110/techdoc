# 阿里云 OSS 与腾讯云 COS 多云存储

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos4cloud-biz
> 最后更新：2026-04-30

---

## 一、组件概述

nms4pos 使用两套云存储实现多云冗余，避免单厂商锁定：

| 组件 | GroupId | 版本 | 用途 | 引入方式 |
|------|---------|------|------|----------|
| **阿里云 OSS** | `nms4cloud-starter-oss` | 继承 | 主存储（电子小票图片、发票、备份文件） | nms4cloud 主平台提供 |
| **腾讯云 COS** | `com.qcloud:cos_api` | 5.6.54 | 备选/跨云备份 | Maven 仓库 |

---

## 二、阿里云 OSS

### 2.1 引入方式

阿里云 OSS 通过 `nms4cloud-starter-oss` 引入，这是 nms4cloud 主平台提供的封装 starter，简化了 OSS 操作：

```xml
<!-- 由 nms4cloud-starter-oss 提供 -->
<dependency>
    <groupId>com.nms4cloud</groupId>
    <artifactId>nms4cloud-starter-oss</artifactId>
    <!-- 版本由 nms4cloud parent 管理 -->
</dependency>
```

### 2.2 核心使用

```java
import org.springframework.web.multipart.MultipartFile;
import com.nms4cloud.oss.service.OssService;

@Service
public class ReceiptService {

    @Autowired
    private OssService ossService;

    /**
     * 上传电子小票图片到阿里云 OSS
     */
    public String uploadReceiptImage(Long orderId, MultipartFile file) {
        // 生成唯一文件名
        String key = "receipts/" + LocalDate.now() + "/" + orderId + ".jpg";

        // 上传到 OSS（自动生成访问 URL）
        String url = ossService.upload(key, file);

        log.info("小票图片上传成功: orderId={}, url={}", orderId, url);
        return url;
    }

    /**
     * 上传 PDF 电子发票
     */
    public String uploadInvoicePDF(Long orderId, byte[] pdfBytes) {
        String key = "invoices/" + LocalDate.now() + "/" + orderId + ".pdf";

        // OSS 支持字节数组上传
        String url = ossService.upload(key, pdfBytes, "application/pdf");
        return url;
    }

    /**
     * 下载文件
     */
    public void downloadReceipt(String key, OutputStream out) {
        ossService.download(key, out);
    }

    /**
     * 生成签名 URL（私有文件访问）
     */
    public String generateSignedUrl(String key, Duration expires) {
        return ossService.generatePresignedUrl(key, expires);
    }
}
```

---

## 三、腾讯云 COS

### 3.1 Maven 依赖

**pos4cloud-biz**（`nms4cloud-pos4cloud/nms4cloud-pos4cloud-biz/pom.xml`）：

```xml
<!-- 腾讯云 COS SDK（精简版，仅包含存储相关类） -->
<dependency>
    <groupId>com.qcloud</groupId>
    <artifactId>cos_api</artifactId>
    <version>5.6.54</version>
</dependency>
```

### 3.2 核心使用

```java
import com.qcloud.cos.COSClient;
import com.qcloud.cos.ClientConfig;
import com.qcloud.cos.auth.BasicCOSCredentials;
import com.qcloud.cos.model.ObjectMetadata;
import com.qcloud.cos.model.PutObjectRequest;
import com.qcloud.cos.region.Region;

public class TencentCOSService {

    private static final String SECRET_ID = "${COS_SECRET_ID}";
    private static final String SECRET_KEY = "${COS_SECRET_KEY}";
    private static final String BUCKET_NAME = "nms4pos-receipts";
    private static final String REGION = "ap-guangzhou";  // 广州区域

    private final COSClient cosClient;

    public TencentCOSService() {
        COSCredentials cred = new BasicCOSCredentials(SECRET_ID, SECRET_KEY);

        ClientConfig config = new ClientConfig(new Region(REGION));

        // 连接超时/读取超时
        config.setConnectionTimeout(10_000);
        config.setSocketTimeout(30_000);

        this.cosClient = new COSClient(cred, config);
    }

    /**
     * 上传小票备份到腾讯云 COS（作为阿里云 OSS 的备份）
     */
    public String uploadBackup(Long orderId, byte[] data, String contentType) {
        String key = "backup/receipts/" + LocalDate.now() + "/" + orderId + ".jpg";

        ObjectMetadata meta = new ObjectMetadata();
        meta.setContentLength(data.length);
        meta.setContentType(contentType);

        PutObjectRequest request = new PutObjectRequest(
            BUCKET_NAME,
            key,
            new ByteArrayInputStream(data)
        );
        request.setMetadata(meta);

        cosClient.putObject(request);

        // 返回访问 URL
        return "https://" + BUCKET_NAME + ".cos." + REGION + ".myqcloud.com/" + key;
    }

    /**
     * 删除备份文件
     */
    public void deleteBackup(String key) {
        cosClient.deleteObject(BUCKET_NAME, key);
    }

    /**
     * 生成临时下载链接（私有文件访问）
     */
    public String generateDownloadUrl(String key, Duration validDuration) {
        Date expiration = new Date(System.currentTimeMillis() + validDuration.toMillis());
        return cosClient.generatePresignedUrl(BUCKET_NAME, key, expiration).toString();
    }
}
```

---

## 四、多云存储策略

```
pos2plugin 生成电子小票图片
  ↓ 上传到阿里云 OSS（主存储）
  ↓ 备份到腾讯云 COS（跨云冗余）
  ↓ 生成访问 URL（可设置有效期）
```

**存储分层**：

| 数据类型 | 主存储 | 备份策略 | 保留时长 |
|---------|--------|---------|---------|
| 电子小票图片 | 阿里云 OSS | 腾讯云 COS（每日增量备份） | 3 年 |
| 电子发票 PDF | 阿里云 OSS | 腾讯云 COS | 永久 |
| 数据备份 | 腾讯云 COS | 阿里云 OSS | 按需 |
| 临时文件 | 阿里云 OSS（生命中期短） | 无 | 7 天 |

---

## 五、凭证管理

```yaml
# application.yml（敏感信息通过环境变量注入）
aliyun:
  oss:
    endpoint: ${OSS_ENDPOINT}
    access-key-id: ${OSS_AK_ID}
    access-key-secret: ${OSS_AK_SECRET}
    bucket: ${OSS_BUCKET}

tencent:
  cos:
    secret-id: ${COS_SECRET_ID}
    secret-key: ${COS_SECRET_KEY}
    bucket: ${COS_BUCKET}
    region: ap-guangzhou
```

> **禁止硬编码**：AccessKey 等凭证严禁硬编码在代码中，必须通过环境变量或密钥管理服务（KMS）注入。

---

## 六、注意事项

1. **多云冗余**：阿里云 OSS 为主，腾讯云 COS 作为备份，重要文件双重存储
2. **区域选择**：COS 部署在 `ap-guangzhou`（广州），需与阿里云 OSS 区域保持一致
3. **清理策略**：过期文件需要定期清理，避免存储成本增长
4. **下载链接有效期**：公开小票图片无需签名；发票等敏感文件需设置短期签名 URL

---

## 七、相关文档

- [OkHttp与SSE实时通信](./OkHttp与SSE实时通信.md)
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)