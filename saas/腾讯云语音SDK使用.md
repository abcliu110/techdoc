# 腾讯云语音 SDK 使用

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos4cloud-biz
> 最后更新：2026-04-30

---

## 一、组件概述

腾讯云语音 SDK（`com.tencentcloudapi:tencentcloud-speech-sdk-java`）提供语音合成（TTS）和语音识别（ASR）能力，作为阿里云 NLS TTS 的备选方案。在 pos4cloud 中用于语音播报和语音指令识别。

**nms4pos 的 TTS 双厂商策略**：
- **主**：阿里云 NLS TTS（pos2plugin 直接调用，延迟低）
- **备**：腾讯云语音 SDK（pos4cloud 云端调用，作为灾备）

---

## 二、Maven 依赖

**pos4cloud-biz**（`nms4cloud-pos4cloud/nms4cloud-pos4cloud-biz/pom.xml`）：

```xml
<!-- 腾讯云语音 SDK -->
<dependency>
    <groupId>com.tencentcloudapi</groupId>
    <artifactId>tencentcloud-speech-sdk-java</artifactId>
    <version>1.0.53</version>
    <!-- 排除了 Hutool 依赖，避免与 nms4cloud 版本冲突 -->
    <exclusions>
        <exclusion>
            <groupId>cn.hutool</groupId>
            <artifactId>hutool-all</artifactId>
        </exclusion>
        <exclusion>
            <groupId>cn.hutool</groupId>
            <artifactId>hutool-core</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

---

## 三、核心使用方式

### 3.1 TTS 语音合成

```java
import com.tencentcloudapi.sms.v1.SmsClient;  // 注意：实际语音接口类名可能不同
// 腾讯云语音合成使用方式（示例）

// 初始化认证信息
Credential cred = new Credential(
    "your_secret_id",
    "your_secret_key"
);

// 创建 TTS 客户端
TtsClient ttsClient = TtsClient.builder()
    .credential(cred)
    .region("ap-guangzhou")  // 广州区域
    .build();

// 配置合成参数
TtsRequest request = TtsRequest.builder()
    .text("订单完成，欢迎下次光临")  // 待合成文本
    .voiceType(0)           // 发音人：0-女声，1-男声
    .speed(0)               // 语速：-2~2，默认 0
    .volume(5)              // 音量：0~10，默认 5
    .sampleRate(16000)      // 采样率：16000 或 8000
    .build();

// 调用合成
TtsResponse response = ttsClient.synthesizeSpeech(request);
byte[] audioData = response.getAudio();  // 返回音频字节

// 保存为文件或直接播放
FileOutputStream fos = new FileOutputStream("output.pcm");
fos.write(audioData);
fos.close();
```

### 3.2 ASR 语音识别（语音指令）

```java
// 腾讯云 ASR（自动语音识别）
AsrClient asrClient = AsrClient.builder()
    .credential(cred)
    .region("ap-guangzhou")
    .build();

AsrRequest asrRequest = AsrRequest.builder()
    .engModelType("16k_zh")  // 16k 中文普通话
    .speakerDiarization(0)   // 不做说话人分离
    .hotwordIds("")          // 热词 ID
    .build();

// 传入音频数据（PCM/WAV 格式，16k 采样率）
AsrResponse response = asrClient.recognize(asrRequest, audioData);
String text = response.getText();  // 识别结果文本
```

### 3.3 TTS 备选切换策略

```java
@Service
public class TTSService {

    @Autowired
    private AlibabaNLSTTSService aliyunService;  // 阿里云 TTS

    @Autowired
    private TencentSpeechService tencentService; // 腾讯云 TTS

    public File synthesize(String text) {
        try {
            // 优先使用阿里云 TTS
            return aliyunService.synthesize(text);
        } catch (Exception e) {
            log.warn("阿里云 TTS 失败，切换腾讯云: {}", e.getMessage());
            return tencentService.synthesize(text);
        }
    }
}
```

---

## 四、注意事项

1. **Hutool 排除**：`tencentcloud-speech-sdk-java` 内部依赖 Hutool，但 nms4cloud 已使用特定版本，因此排除了 SDK 内置的 Hutool
2. **采样率**：腾讯云 ASR 要求 16kHz 采样率的 PCM 音频
3. **区域选择**：腾讯云各区域服务不同，语音服务通常在 `ap-guangzhou`（广州）
4. **用量计费**：TTS 和 ASR 按调用时长/次数计费，需要在腾讯云控制台开通服务并充值

---

## 五、相关文档

- [阿里云NLSTTS语音合成](./阿里云NLSTTS语音合成.md) — 主用 TTS 方案
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)