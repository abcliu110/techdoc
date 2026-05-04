# 阿里云 NLS TTS 语音合成

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos2plugin-biz、pos4cloud-biz
> 核心源文件：`AkSynthesizerUtil.java`、`NlsCommonService.java`
> 最后更新：2026-04-30

---

## 一、组件概述

阿里云 NLS（Natural Language Service）TTS SDK 用于将文字实时合成为语音，在 POS 收银场景中用于：
- 顾客结账完成后，语音播报"订单完成，欢迎下次光临"
- KDS 厨房显示系统叫号时，播报菜品名称
- 取餐叫号通知

nms4pos 使用两个相关组件：

| 组件 | GroupId | 版本 | 用途 |
|------|---------|------|------|
| **nls-sdk-tts** | `com.alibaba.nls:nls-sdk-tts` | 2.2.18 | 实时语音合成核心 |
| **nls-sdk-common** | `com.alibaba.nls:nls-sdk-common` | 2.2.18 | NLS 通用组件（Token 管理等） |

---

## 二、Maven 依赖

**pos2plugin-biz**（`nms4cloud-pos2plugin/nms4cloud-pos2plugin-biz/pom.xml`）：

```xml
<!-- 阿里云 NLS TTS -->
<dependency>
    <groupId>com.alibaba.nls</groupId>
    <artifactId>nls-sdk-tts</artifactId>
    <version>2.2.18</version>
</dependency>
```

**pos4cloud-biz**（`nms4cloud-pos4cloud/nms4cloud-pos4cloud-biz/pom.xml`）：

```xml
<!-- 阿里云 NLS 通用 -->
<dependency>
    <groupId>com.alibaba.nls</groupId>
    <artifactId>nls-sdk-common</artifactId>
    <version>2.2.18</version>
</dependency>
```

---

## 三、核心实现

### 3.1 Token 管理

NLS TTS 需要阿里云 AccessKey Token，pos4cloud 模块通过云端服务获取 Token 并缓存到 Redis：

```java
// AkSynthesizerUtil.java — Token 获取
public AkTokenVO getAkToken() {
    // 1. 先查 Redis 缓存
    String cachedToken = redisTemplate.opsForValue().get("akToken");
    if (StrUtil.isNotBlank(cachedToken)) {
        return JSON.parseObject(cachedToken, AkTokenVO.class);
    }

    // 2. 缓存未命中，从云端服务获取
    AkTokenVO akTokenVO = pos4CloudCommonService.getAkToken();

    // 3. 写入 Redis，设置过期时间（Token 有效期 24h，留 30 分钟缓冲）
    redisTemplate.opsForValue().set("akToken",
        JSON.toJSONString(akTokenVO),
        Duration.ofMinutes(23 * 60 + 30));
    return akTokenVO;
}
```

### 3.2 NLS 客户端创建

```java
// AkSynthesizerUtil.java — NLS 客户端初始化
private NlsClient getNlsClient() {
    AkTokenVO akToken = getAkToken();

    // 1. 创建 NLS 客户端（传入 Token）
    NlsClient client = new NlsClient(akToken.getToken());

    // 2. 配置客户端参数（可按需调整连接池大小）
    client.setNlsClientMeta(akToken.getAccessKeyId(),
        akToken.getAccessKeySecret(), akToken.getAppKey());

    return client;
}
```

`AkTokenVO` 包含三个关键字段：
- `accessKeyId` — 阿里云 AccessKey ID
- `accessKeySecret` — 阿里云 AccessKey Secret
- `appKey` — NLS 应用唯一标识

### 3.3 语音合成配置

```java
// AkSynthesizerUtil.java — SpeechSynthesizer 配置
SpeechSynthesizer synthesizer = client.createSpeechSynthesizerRequest();

// 应用标识
synthesizer.setAppKey(akToken.getAppKey());

// 输出格式：MP3（也可选 WAV）
synthesizer.setFormat(OutputFormatEnum.MP3);

// 采样率：48kHz（高质量语音）
synthesizer.setSampleRate(SampleRateEnum.SAMPLE_RATE_48K);

// 发音人（声线选择）
synthesizer.setVoice("xiaoyun");   // 小云（女声，通用）
// synthesizer.setVoice("xiaogang"); // 小刚（男声）
// synthesizer.setVoice("aiqi");     // 艾琪（年轻女声）
// synthesizer.setVoice("aijia");    // 艾佳（甜美女声）

// 语速调节（-500 ~ +500，默认 0）
synthesizer.setSpeechRate(0);     // 正常语速

// 音调调节（-500 ~ +500，默认 0）
synthesizer.setPitchRate(0);      // 正常音调

// 音量调节（0 ~ 100，默认 50）
synthesizer.setVolume(80);        // 较大音量（嘈杂餐厅环境）
```

### 3.4 合成回调处理

```java
// AkSynthesizerUtil.java — SpeechSynthesizerListener 回调
SpeechSynthesizerListener listener = new SpeechSynthesizerListener() {

    @Override
    public void onComplete(SpeechSynthesizerRequest request) {
        log.info("TTS 合成完成: {}", request.getRequestId());
    }

    @Override
    public void onFail(SpeechSynthesizerRequest request, SpeechSynthesizerException e) {
        log.error("TTS 合成失败: {}, error: {}",
            request.getRequestId(), e.getMessage());
    }

    @Override
    public void onMessage(ByteBuffer buffer) {
        // 合成数据分片到达，写入本地文件
        try (FileOutputStream out = new FileOutputStream(audioFile, true)) {
            byte[] data = new byte[buffer.remaining()];
            buffer.get(data);
            out.write(data);
        } catch (IOException e) {
            log.error("写入音频文件失败", e);
        }
    }
};

synthesizer.setListener(listener);
```

### 3.5 发起合成请求

```java
// AkSynthesizerUtil.java — 完整合成流程
public File synthesize(String text) throws Exception {
    NlsClient client = getNlsClient();
    SpeechSynthesizer synthesizer = client.createSpeechSynthesizerRequest();
    synthesizer.setAppKey(appKey);
    synthesizer.setFormat(OutputFormatEnum.MP3);
    synthesizer.setSampleRate(SampleRateEnum.SAMPLE_RATE_48K);
    synthesizer.setVoice("xiaoyun");
    synthesizer.setPitchRate(0);
    synthesizer.setSpeechRate(0);
    synthesizer.setVolume(80);

    // 生成输出文件
    File audioFile = File.createTempFile("tts_", ".mp3");
    SpeechSynthesizerListener listener = buildListener(audioFile);
    synthesizer.setListener(listener);

    // 同步合成（等待完成）
    synthesizer.start();
    synthesizer.synthesize(text);
    synthesizer.stop();

    // 等待 onComplete 回调后，audioFile 即为完整 MP3 文件
    return audioFile;
}
```

### 3.6 音频播放

使用 Java Sound API（`javax.sound.sampled`）播放合成的 MP3：

```java
// AkSynthesizerUtil.java — 音频播放
public void playAudio(File audioFile) {
    try (FileInputStream fis = new FileInputStream(audioFile);
         AudioInputStream audioStream = AudioSystem.getAudioInputStream(fis)) {

        // 获取音频格式
        AudioFormat format = audioStream.getFormat();

        // 打开播放通道
        DataLine.Info info = new DataLine.Info(SourceDataLine.class, format);
        SourceDataLine line = (SourceDataLine) AudioSystem.getLine(info);
        line.open(format);
        line.start();

        // 播放音频数据
        byte[] buffer = new byte[4096];
        int bytesRead;
        while ((bytesRead = audioStream.read(buffer)) != -1) {
            line.write(buffer, 0, bytesRead);
        }

        // 等待播放完成
        line.drain();
        line.close();
    } catch (Exception e) {
        log.error("音频播放失败", e);
    }
}
```

### 3.7 MD5 缓存

为避免重复合成相同文本，使用 MD5 作为缓存 key：

```java
// AkSynthesizerUtil.java — 合成缓存
public File synthesizeWithCache(String text) {
    // 1. 计算文本的 MD5 作为缓存 key
    String cacheKey = SecureUtil.md5(text + voice + speechRate + pitchRate);

    // 2. 查缓存（Redis 或本地文件）
    File cachedFile = getCachedAudio(cacheKey);
    if (cachedFile != null && cachedFile.exists()) {
        log.debug("TTS 命中缓存: {}", cacheKey);
        return cachedFile;
    }

    // 3. 合成并缓存
    File audioFile = synthesize(text);
    saveToCache(cacheKey, audioFile);
    return audioFile;
}
```

---

## 四、典型业务场景

### 4.1 结账完成语音播报

```
顾客付款成功
  → pos2plugin 触发结账完成事件
    → AkSynthesizerUtil.synthesize("订单完成，欢迎下次光临")
      → 生成 MP3 文件
        → javax.sound.sampled 播放
```

### 4.2 KDS 叫号

```
厨房菜品制作完成
  → pos2plugin 触发叫号事件
    → AkSynthesizerUtil.synthesize("" + tableNo + "号桌，请取餐")
      → 播放音频
```

---

## 五、参数配置建议

餐厅嘈杂环境下的参数优化：

| 参数 | 推荐值 | 说明 |
|------|--------|------|
| `voice` | `xiaoyun`（小云） | 女声穿透力较强 |
| `volume` | `80-100` | 嘈杂环境需要较大音量 |
| `speechRate` | `0` 或 `+50` | 略快于正常语速，减少等待 |
| `sampleRate` | `SAMPLE_RATE_48K` | 高采样率保证音质 |
| 缓存 TTL | 23.5 小时 | Token 有效期 24h，提前 30 分钟刷新 |

---

## 六、注意事项

1. **Token 刷新**：AccessKey Token 有 24 小时有效期，需提前刷新，避免服务中断
2. **并发限制**：阿里云 NLS 对并发请求数有限制，高峰时段（午/晚餐）可能触发限流
3. **网络延迟**：语音合成需要网络请求，pos2plugin 部署在本地局域网内延迟较低
4. **pos4cloud 作为 Token 中转**：pos2plugin 通过 pos4CloudCommonService 获取 Token，Token 管理逻辑集中在 pos4cloud-biz

---

## 七、相关文档

- [腾讯云语音 SDK 使用](./腾讯云语音SDK使用.md) — TTS 备选方案
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)
