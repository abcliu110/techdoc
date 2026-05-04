# 通义千问 DashScope SDK 使用

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos4cloud-biz
> 核心源文件：`AIOrderServicePlus.java`
> 最后更新：2026-04-30

---

## 一、组件概述

**通义千问 DashScope SDK**（`com.alibaba:dashscope-sdk-java`）是阿里云大语言模型 Qwen 的 Java SDK，用于在 pos4cloud 中实现**智能客服**：顾客在收银界面或小程序中提问，AI 自动回复推荐菜品、解答营业时间等问题。

---

## 二、Maven 依赖

**pos4cloud-biz**（`nms4cloud-pos4cloud/nms4cloud-pos4cloud-biz/pom.xml`）：

```xml
<!-- 通义千问 DashScope SDK -->
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>dashscope-sdk-java</artifactId>
    <version>2.18.5</version>
</dependency>
```

---

## 三、核心实现

### 3.1 初始化

```java
import com.alibaba.dashscope.DashScope;
import com.alibaba.dashscope.common.DashScopeResult;
import com.alibaba.dashscope.utils.DashScopeHeaders;

public class AIOrderServicePlus {

    // DashScope API Key（从配置中心读取）
    private static final String API_KEY = "${DASHSCOPE_API_KEY}";

    // 设置默认 API Key
    static {
        DashScope.apiKey = API_KEY;
    }
}
```

### 3.2 调用 Qwen 对话

```java
import com.alibaba.dashscope.aigc.multimodalconversation.MultiModalConversation;
import com.alibaba.dashscope.aigc.multimodalconversation.MultiModalConversationParam;
import com.alibaba.dashscope.aigc.multimodalconversation.MultiModalConversationResult;
import com.alibaba.dashscope.common.DashScopeException;

public String askAI(String question, Long storeId) {
    try {
        // 1. 构建对话参数
        MultiModalConversationParam param =
            MultiModalConversationParam.builder()
                .model("qwen-vl-max")         // 视觉语言模型（支持图片输入）
                // .model("qwen-turbo")         // 快速模型（纯文本）
                // .model("qwen-plus")          // 增强模型（更高质量）
                .build();

        // 2. 添加对话历史（可选，支持多轮对话）
        // param.addSystemMessage(systemPrompt);
        // param.addUserMessage(userMessage);

        // 3. 设置系统提示词（注入餐饮知识）
        String systemPrompt = "你是一个专业的餐饮收银助手，可以推荐菜品、解答营业问题。" +
            "只回答与餐饮相关的问题，不回答无关内容。";
        param.addSystemMessage(systemPrompt);

        // 4. 添加用户问题
        param.addUserMessage(question);

        // 5. 调用 Qwen
        MultiModalConversation conv = new MultiModalConversation();
        MultiModalConversationResult result = conv.call(param);

        // 6. 解析结果
        if (result != null && result.getOutput() != null) {
            return result.getOutput().getChoices().getText();
        }
        return null;

    } catch (DashScopeException e) {
        log.error("调用 Qwen 失败: {}", e.getMessage(), e);
        return "抱歉，AI 服务暂时不可用，请稍后重试。";
    }
}
```

### 3.3 业务场景：智能推荐

```java
// AIOrderServicePlus.java — 智能菜品推荐
public List<Dish> recommendDishes(String preference, Long storeId) {
    String prompt = String.format(
        "顾客说：'%s'。根据这个描述，推荐3道适合的菜品，返回菜品ID列表。",
        preference
    );

    String aiResponse = askAI(prompt, storeId);

    // 解析 AI 返回的菜品 ID（需要约定输出格式）
    List<Long> dishIds = parseDishIds(aiResponse);

    // 从数据库加载菜品详情
    return dishService.getDishesByIds(dishIds);
}

// 示例解析：约定 AI 返回格式为 JSON 数组
private List<Long> parseDishIds(String response) {
    List<Long> ids = new ArrayList<>();
    try {
        // 尝试解析 JSON 格式
        JSONArray arr = JSON.parseArray(response);
        for (Object item : arr) {
            ids.add(((JSONObject) item).getLong("id"));
        }
    } catch (Exception e) {
        log.warn("AI 返回格式解析失败: {}", response);
    }
    return ids;
}
```

### 3.4 带图像理解的菜品识别（多模态）

```java
// 顾客拍照上传图片，Qwen 视觉模型识别菜品并推荐
public Dish recognizeDishFromImage(File imageFile) {
    try {
        MultiModalConversationParam param =
            MultiModalConversationParam.builder()
                .model("qwen-vl-max")  // 视觉模型
                .build();

        param.addSystemMessage(
            "你是一个菜品识别专家，识别图片中的菜品名称和数量，返回菜品信息。");
        param.addUserMessage(
            MultiModalConversation.UserMessage.ofImages(
                "这是什么菜品？请告诉我菜品名称。",
                imageFile.getAbsolutePath()  // 本地图片路径
            )
        );

        MultiModalConversation conv = new MultiModalConversation();
        MultiModalConversationResult result = conv.call(param);

        String answer = result.getOutput().getChoices().getText();
        return dishService.findByName(parseDishName(answer));
    } catch (Exception e) {
        log.error("菜品图片识别失败", e);
        return null;
    }
}
```

---

## 四、模型选型建议

| 模型 | 适用场景 | 延迟 | 成本 |
|------|---------|------|------|
| `qwen-turbo` | 快速问答、菜单查询 | ~500ms | 低 |
| `qwen-plus` | 复杂对话、多轮上下文 | ~2s | 中 |
| `qwen-vl-max` | 图文混合、菜品图片识别 | ~3s | 高 |

---

## 五、注意事项

1. **Prompt 工程**：AI 回复质量依赖系统提示词，建议为餐饮场景单独调试
2. **输出格式**：建议约定 AI 输出格式（如 JSON），便于程序解析
3. **成本控制**：Qwen API 按 token 计费，建议限制单次对话长度
4. **兜底策略**：AI 服务不可用时，回退到关键词匹配或人工客服

---

## 六、相关文档

- [OkHttp与SSE实时通信](./OkHttp与SSE实时通信.md) — 与 AI 服务通信的 HTTP 基础
- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)