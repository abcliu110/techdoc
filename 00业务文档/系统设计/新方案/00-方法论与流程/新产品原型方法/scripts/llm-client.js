/**
 * llm-client.js — 统一 LLM API 调用封装
 *
 * 支持：
 * - 多模型家族（GLM / Claude / GPT-4o）
 * - 多模态输入（文本 + 截图）
 * - JSON mode 强制结构化输出
 * - 多次采样取中位数
 * - 温度控制
 * - 成本/Token 追踪
 */

const fs = require('fs');
const path = require('path');

// ============================================================
// 模型注册表 — 每个模型家族的配置
// ============================================================
const MODEL_REGISTRY = {
  glm: {
    name: 'GLM-4',
    provider: 'zhipu',
    apiKeyEnv: 'ZHIPU_API_KEY',
    baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    contextWindow: 128000,
    costPer1kInput: 0.05,   // 元/1K tokens
    costPer1kOutput: 0.05,
    supportsVision: true,
    supportsJsonMode: true,
  },
  claude: {
    name: 'Claude-3.5-Sonnet',
    provider: 'anthropic',
    apiKeyEnv: 'ANTHROPIC_API_KEY',
    baseUrl: 'https://api.anthropic.com/v1',
    contextWindow: 200000,
    costPer1kInput: 0.003,  // 美元/1K tokens
    costPer1kOutput: 0.015,
    supportsVision: true,
    supportsJsonMode: false, // Claude 用 prompt 约束 JSON
  },
  gpt4o: {
    name: 'GPT-4o',
    provider: 'openai',
    apiKeyEnv: 'OPENAI_API_KEY',
    baseUrl: 'https://api.openai.com/v1',
    contextWindow: 128000,
    costPer1kInput: 0.0025,
    costPer1kOutput: 0.01,
    supportsVision: true,
    supportsJsonMode: true,
  },
  'glm-flash': {
    name: 'GLM-4-Flash',
    provider: 'zhipu',
    apiKeyEnv: 'ZHIPU_API_KEY',
    baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    contextWindow: 128000,
    costPer1kInput: 0.001,
    costPer1kOutput: 0.001,
    supportsVision: true,
    supportsJsonMode: true,
  },
};

// ============================================================
// 成本追踪器
// ============================================================
const costTracker = {
  totalCalls: 0,
  totalInputTokens: 0,
  totalOutputTokens: 0,
  totalCost: 0,
  log: [],

  record(modelKey, inputTokens, outputTokens) {
    const model = MODEL_REGISTRY[modelKey];
    if (!model) return;
    const cost = (inputTokens / 1000) * model.costPer1kInput +
                 (outputTokens / 1000) * model.costPer1kOutput;
    this.totalCalls++;
    this.totalInputTokens += inputTokens;
    this.totalOutputTokens += outputTokens;
    this.totalCost += cost;
    this.log.push({ timestamp: new Date().toISOString(), model: modelKey, inputTokens, outputTokens, cost });
  },

  checkBudget(budget) {
    const limits = budget || { maxCalls: 100, maxTokens: 2000000, maxCost: 50 };
    return {
      callsExceeded: this.totalCalls >= limits.maxCalls,
      tokensExceeded: (this.totalInputTokens + this.totalOutputTokens) >= limits.maxTokens,
      costExceeded: this.totalCost >= limits.maxCost,
      remaining: {
        calls: limits.maxCalls - this.totalCalls,
        tokens: limits.maxTokens - this.totalInputTokens - this.totalOutputTokens,
        cost: limits.maxCost - this.totalCost,
      },
    };
  },

  report() {
    return {
      totalCalls: this.totalCalls,
      totalInputTokens: this.totalInputTokens,
      totalOutputTokens: this.totalOutputTokens,
      totalCost: this.totalCost.toFixed(4),
    };
  },
};

// ============================================================
// 核心 LLM 调用函数
// ============================================================

/**
 * 调用 LLM（单次）
 * @param {Object} params
 * @param {string} params.modelKey - 模型标识（glm/claude/gpt4o/glm-flash）
 * @param {string} params.systemPrompt - 系统提示
 * @param {string} params.userPrompt - 用户提示
 * @param {string|null} params.imagePath - 截图文件路径（多模态）
 * @param {number} params.temperature - 温度（默认 0）
 * @param {boolean} params.jsonMode - 是否强制 JSON 输出
 * @returns {Object} { content, usage, raw }
 */
async function callLLM({ modelKey, systemPrompt, userPrompt, imagePath = null, temperature = 0, jsonMode = false }) {
  const model = MODEL_REGISTRY[modelKey];
  if (!model) throw new Error(`Unknown model: ${modelKey}`);

  const apiKey = process.env[model.apiKeyEnv];
  if (!apiKey) throw new Error(`Missing API key: ${model.apiKeyEnv}`);

  // 预算检查
  const budgetStatus = costTracker.checkBudget();
  if (budgetStatus.callsExceeded || budgetStatus.tokensExceeded || budgetStatus.costExceeded) {
    throw new Error(`Budget exceeded: ${JSON.stringify(budgetStatus)}`);
  }

  // 构建消息体（按 provider 分发）
  let response;
  if (model.provider === 'openai') {
    response = await callOpenAICompatible(model, apiKey, systemPrompt, userPrompt, imagePath, temperature, jsonMode);
  } else if (model.provider === 'anthropic') {
    response = await callAnthropic(model, apiKey, systemPrompt, userPrompt, imagePath, temperature);
  } else if (model.provider === 'zhipu') {
    response = await callOpenAICompatible(model, apiKey, systemPrompt, userPrompt, imagePath, temperature, jsonMode);
  }

  // 记录成本
  costTracker.record(modelKey, response.usage.inputTokens, response.usage.outputTokens);

  return {
    content: response.content,
    usage: response.usage,
    model: model.name,
  };
}

// OpenAI 兼容接口（GPT-4o / GLM）
async function callOpenAICompatible(model, apiKey, systemPrompt, userPrompt, imagePath, temperature, jsonMode) {
  const messages = [{ role: 'system', content: systemPrompt }];

  if (imagePath && model.supportsVision) {
    const imageBase64 = fs.readFileSync(imagePath).toString('base64');
    const ext = path.extname(imagePath).slice(1);
    messages.push({
      role: 'user',
      content: [
        { type: 'text', text: userPrompt },
        { type: 'image_url', image_url: { url: `data:image/${ext};base64,${imageBase64}` } },
      ],
    });
  } else {
    messages.push({ role: 'user', content: userPrompt });
  }

  const body = {
    model: model.name,
    messages,
    temperature,
    max_tokens: 4096,
  };
  if (jsonMode && model.supportsJsonMode) {
    body.response_format = { type: 'json_object' };
  }

  const resp = await fetch(`${model.baseUrl}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`,
    },
    body: JSON.stringify(body),
  });

  if (!resp.ok) {
    const errText = await resp.text();
    throw new Error(`LLM API error ${resp.status}: ${errText}`);
  }

  const data = await resp.json();
  return {
    content: data.choices[0].message.content,
    usage: {
      inputTokens: data.usage.prompt_tokens,
      outputTokens: data.usage.completion_tokens,
    },
  };
}

// Anthropic 接口（Claude）
async function callAnthropic(model, apiKey, systemPrompt, userPrompt, imagePath, temperature) {
  const content = [];
  if (imagePath && model.supportsVision) {
    const imageBase64 = fs.readFileSync(imagePath).toString('base64');
    const mediaType = imagePath.endsWith('.png') ? 'image/png' : 'image/jpeg';
    content.push({
      type: 'image',
      source: { type: 'base64', media_type: mediaType, data: imageBase64 },
    });
  }
  content.push({ type: 'text', text: userPrompt });

  // Claude 无 JSON mode，在 prompt 中强制
  const fullSystem = jsonMode
    ? systemPrompt + '\n\nYou MUST respond with valid JSON only. No markdown, no explanation.'
    : systemPrompt;

  const resp = await fetch(`${model.baseUrl}/messages`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: model.name,
      system: fullSystem,
      messages: [{ role: 'user', content }],
      temperature,
      max_tokens: 4096,
    }),
  });

  if (!resp.ok) {
    const errText = await resp.text();
    throw new Error(`Anthropic API error ${resp.status}: ${errText}`);
  }

  const data = await resp.json();
  return {
    content: data.content[0].text,
    usage: {
      inputTokens: data.usage.input_tokens,
      outputTokens: data.usage.output_tokens,
    },
  };
}

// ============================================================
// 多次采样取中位数
// ============================================================

/**
 * 多次采样取中位数（用于 LLM 评分维度）
 * @param {Object} params - 同 callLLM
 * @param {number} samples - 采样次数（默认 3）
 * @returns {Object} { medianScore, scores, stdDev, lowConfidence }
 */
async function callLLMWithSampling(params, samples = 3) {
  const results = [];
  const parsedScores = [];

  for (let i = 0; i < samples; i++) {
    const result = await callLLM(params);
    results.push(result);

    // 尝试从输出中提取分数
    try {
      const parsed = JSON.parse(result.content);
      if (typeof parsed.score === 'number') parsedScores.push(parsed.score);
    } catch (e) {
      // JSON 解析失败，记录但不计入分数
    }
  }

  if (parsedScores.length === 0) {
    return { medianScore: null, scores: [], stdDev: null, lowConfidence: true, results };
  }

  parsedScores.sort((a, b) => a - b);
  const median = parsedScores[Math.floor(parsedScores.length / 2)];
  const mean = parsedScores.reduce((s, v) => s + v, 0) / parsedScores.length;
  const stdDev = Math.sqrt(parsedScores.reduce((s, v) => s + (v - mean) ** 2, 0) / parsedScores.length);

  // 置信度判定：标准差 > 1.5 → 低置信，取保守值（中位数 - 标准差）
  const lowConfidence = stdDev > 1.5;
  const finalScore = lowConfidence ? Math.max(0, median - stdDev) : median;

  return {
    medianScore: finalScore,
    rawMedian: median,
    scores: parsedScores,
    stdDev: parseFloat(stdDev.toFixed(2)),
    lowConfidence,
    results,
  };
}

// ============================================================
// 多 LLM 共识终审
// ============================================================

/**
 * 多 LLM 共识终审（3 个不同模型家族）
 * @param {Object} params - 输入参数（systemPrompt, userPrompt, imagePath）
 * @returns {Object} { verdict, votes, details }
 */
async function consensusReview({ systemPrompt, userPrompt, imagePath }) {
  const models = ['glm', 'claude', 'gpt4o']; // 3 个不同模型家族
  const votes = [];

  for (const modelKey of models) {
    try {
      const result = await callLLM({
        modelKey,
        systemPrompt,
        userPrompt,
        imagePath,
        temperature: 0,
        jsonMode: true,
      });
      const parsed = JSON.parse(result.content);
      votes.push({
        model: modelKey,
        verdict: parsed.verdict, // 'PASS' or 'FAIL'
        reason: parsed.reason,
        raw: result.content,
      });
    } catch (e) {
      // 实例失败，重试 1 次
      try {
        const retry = await callLLM({
          modelKey, systemPrompt, userPrompt, imagePath, temperature: 0, jsonMode: true,
        });
        const parsed = JSON.parse(retry.content);
        votes.push({ model: modelKey, verdict: parsed.verdict, reason: parsed.reason, raw: retry.content });
      } catch (e2) {
        votes.push({ model: modelKey, verdict: 'ERROR', reason: e2.message, raw: null });
      }
    }
  }

  const passCount = votes.filter(v => v.verdict === 'PASS').length;
  const failCount = votes.filter(v => v.verdict === 'FAIL').length;
  const errorCount = votes.filter(v => v.verdict === 'ERROR').length;

  let verdict;
  if (passCount === 3) {
    verdict = 'PASS';
  } else if (passCount === 2 && failCount === 1) {
    verdict = 'ARBITRATION'; // 2/3 PASS → 触发仲裁
  } else if (errorCount > 0 && passCount >= 1 && failCount === 0) {
    // 有实例失败，剩余需 2/2 PASS
    verdict = passCount >= 2 ? 'PASS' : 'FAIL';
  } else {
    verdict = 'FAIL';
  }

  return { verdict, votes, passCount, failCount, errorCount };
}

// ============================================================
// 仲裁 Agent（2/3 分歧时决胜）
// ============================================================

async function arbitrationReview({ systemPrompt, userPrompt, imagePath, votes }) {
  const arbitrationPrompt = `Previous review results showed a split decision:
${JSON.stringify(votes, null, 2)}

You are the arbitrator. Review the prototype independently and give your final verdict.
Respond with JSON: { "verdict": "PASS" | "FAIL", "reason": "..." }`;

  // 使用第 4 个模型（如果可用，否则用不同的一个）
  const arbitratorModel = 'glm-flash';
  const result = await callLLM({
    modelKey: arbitratorModel,
    systemPrompt: systemPrompt + '\n\nYou are the ARBITRATOR making a final decision.',
    userPrompt: arbitrationPrompt,
    imagePath,
    temperature: 0,
    jsonMode: true,
  });

  try {
    return JSON.parse(result.content);
  } catch (e) {
    return { verdict: 'FAIL', reason: 'Arbitration parse error: ' + result.content };
  }
}

// ============================================================
// JSON 安全解析
// ============================================================

function safeJsonParse(content, fallback = null) {
  // 尝试直接解析
  try {
    return JSON.parse(content);
  } catch (e) {
    // 尝试提取 JSON 块（```json ... ```）
    const match = content.match(/```json\s*([\s\S]*?)```/);
    if (match) {
      try {
        return JSON.parse(match[1]);
      } catch (e2) {}
    }
    // 尝试提取花括号内容
    const braceMatch = content.match(/\{[\s\S]*\}/);
    if (braceMatch) {
      try {
        return JSON.parse(braceMatch[0]);
      } catch (e3) {}
    }
    return fallback;
  }
}

// ============================================================
// 导出
// ============================================================

module.exports = {
  MODEL_REGISTRY,
  costTracker,
  callLLM,
  callLLMWithSampling,
  consensusReview,
  arbitrationReview,
  safeJsonParse,
};
