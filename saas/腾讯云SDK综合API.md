# 腾讯云 SDK 综合 API

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos4cloud-biz
> 最后更新：2026-04-30

---

## 一、组件概述

**腾讯云 SDK**（`com.tencentcloudapi:tencentcloud-sdk-java`）是腾讯云开放平台的基础 SDK，覆盖计算、存储、AI、安全等数十个产品线。nms4pos 中 pos4cloud 主要使用其中的**人脸识别**和 **COS 对象存储**能力（OCR 依赖百度 AI）。

---

## 二、Maven 依赖

**pos4cloud-biz**（`nms4cloud-pos4cloud/nms4cloud-pos4cloud-biz/pom.xml`）：

```xml
<!-- 腾讯云基础 SDK（覆盖多产品线） -->
<dependency>
    <groupId>com.tencentcloudapi</groupId>
    <artifactId>tencentcloud-sdk-java</artifactId>
    <version>3.1.1222</version>
</dependency>
```

---

## 三、COS 对象存储（腾讯云对象存储）

详见 [阿里云OSS与腾讯云COS多云存储](./阿里云OSS与腾讯云COS多云存储.md)，此处补充 SDK 用法。

### 3.1 初始化

```java
import com.qcloud.cos.COSClient;
import com.qcloud.cos.ClientConfig;
import com.qcloud.cos.auth.BasicCOSCredentials;
import com.qcloud.cos.region.Region;

public COSClient createCOSClient() {
    // 替换为实际的 SecretId / SecretKey
    COSCredentials cred = new BasicCOSCredentials(
        "your_secret_id",
        "your_secret_key"
    );

    ClientConfig clientConfig = new ClientConfig(new Region("ap-guangzhou"));

    return new COSClient(cred, clientConfig);
}
```

### 3.2 上传文件

```java
public String uploadReceipt(String bucketName, File imageFile) {
    String key = "receipts/" + UUID.randomUUID() + ".jpg";

    PutObjectRequest putRequest = new PutObjectRequest(
        bucketName, key, imageFile
    );

    PutObjectResult result = cosClient.putObject(putRequest);
    String etag = result.getETag();  // 唯一标识

    // 生成访问 URL（默认私有读写，可生成签名 URL）
    return "https://" + bucketName + ".cos.ap-guangzhou.myqcloud.com/" + key;
}
```

---

## 四、注意事项

1. **精简依赖**：`tencentcloud-sdk-java` 是一个聚合包（all-in-one），包含数十个产品线的所有 API 类，体积较大（> 10MB）。如仅需 COS，建议单独引入 `cos_api`（已在 pom 中单独声明）
2. **版本管理**：3.1.1222 版本较新，API 变动需留意腾讯云官方升级公告
3. **凭证安全**：SecretId/SecretKey 严禁硬编码，建议通过环境变量或密钥管理服务（KMS）注入

---

## 五、相关文档

- [腾讯云语音SDK使用](./腾讯云语音SDK使用.md)
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)