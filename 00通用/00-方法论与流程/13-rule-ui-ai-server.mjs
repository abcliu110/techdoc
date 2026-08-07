import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

const HOST = '127.0.0.1';
const PORT = Number(process.env.PORT || 8787);
const HTML_PATH = fileURLToPath(new URL('./13-原型-业务规则到UI交互映射.html', import.meta.url));
const AI_URL = process.env.AI_CHAT_COMPLETIONS_URL || '';
const AI_API_KEY = process.env.AI_API_KEY || '';
const AI_MODEL = process.env.AI_MODEL || '';
const MAX_BODY_BYTES = 64 * 1024;
const MAX_RULE_CHARS = 5000;
const REQUEST_TIMEOUT_MS = 45_000;

const ALLOWED_RULE_TYPES = new Set([
  'THRESHOLD_APPROVAL',
  'SEPARATION_OF_DUTIES',
  'MUTUAL_EXCLUSION',
  'ALLOWED_COMPOSITION',
  'ASYNC_UNKNOWN',
  'VERSIONED_POLICY',
  'INVARIANT',
  'GENERIC_CONSTRAINT'
]);

const SYSTEM_PROMPT = `你是业务规则语义解析器，只负责把自然语言规则转换为候选 Rule IR，不生成 UI，不自行决定缺失的资金、合同、权限或合规语义。
必须只输出 JSON 对象，结构为：
{
  "rules": [{
    "originalStatement": "原文片段",
    "businessMeaning": "规范业务含义",
    "ruleType": "允许的枚举值",
    "facts": ["camelCaseFact"],
    "conditionExpression": "可读的确定性条件表达式",
    "decision": "命中后的业务决定",
    "parameters": {"threshold": 500, "currency": "CNY", "approver": "STORE_MANAGER"},
    "ambiguities": ["原文未明确的问题"],
    "confidence": 0.0
  }]
}
允许的 ruleType：THRESHOLD_APPROVAL、SEPARATION_OF_DUTIES、MUTUAL_EXCLUSION、ALLOWED_COMPOSITION、ASYNC_UNKNOWN、VERSIONED_POLICY、INVARIANT、GENERIC_CONSTRAINT。
规则：复合语句必须拆分；只提取原文和上下文支持的事实；推断写入 ambiguities；confidence 范围 0 到 1；无法分类时使用 GENERIC_CONSTRAINT。`;
function sendJson(response, status, payload) {
  const body = JSON.stringify(payload);
  response.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(body),
    'Cache-Control': 'no-store',
    'X-Content-Type-Options': 'nosniff'
  });
  response.end(body);
}

function applySecurityHeaders(response) {
  response.setHeader('X-Content-Type-Options', 'nosniff');
  response.setHeader('Referrer-Policy', 'no-referrer');
  response.setHeader('X-Frame-Options', 'DENY');
  response.setHeader(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; connect-src 'self'; img-src 'self' data:; font-src 'self'; base-uri 'none'; frame-ancestors 'none'"
  );
}

async function readRequestBody(request) {
  const chunks = [];
  let size = 0;
  for await (const chunk of request) {
    size += chunk.length;
    if (size > MAX_BODY_BYTES) {
      const error = new Error('请求体过大');
      error.statusCode = 413;
      throw error;
    }
    chunks.push(chunk);
  }
  const raw = Buffer.concat(chunks).toString('utf8');
  try {
    return JSON.parse(raw);
  } catch {
    const error = new Error('请求体必须是合法 JSON');
    error.statusCode = 400;
    throw error;
  }
}

function cleanJsonText(content) {
  const trimmed = String(content || '').trim();
  const fenced = trimmed.match(/^```(?:json)?\s*([\s\S]*?)\s*```$/i);
  return fenced ? fenced[1] : trimmed;
}

function normalizeStringArray(value) {
  if (!Array.isArray(value)) return [];
  return value.filter((item) => typeof item === 'string').map((item) => item.trim()).filter(Boolean).slice(0, 30);
}

function validateAiResult(result) {
  if (!result || !Array.isArray(result.rules) || result.rules.length === 0 || result.rules.length > 20) {
    throw new Error('AI 响应缺少有效 rules 数组');
  }
  return {
    rules: result.rules.map((rule, index) => {
      const ruleType = ALLOWED_RULE_TYPES.has(rule?.ruleType) ? rule.ruleType : 'GENERIC_CONSTRAINT';
      const confidence = Number(rule?.confidence);
      return {
        originalStatement: String(rule?.originalStatement || '').slice(0, 1000),
        businessMeaning: String(rule?.businessMeaning || `候选规则 ${index + 1}`).slice(0, 500),
        ruleType,
        facts: normalizeStringArray(rule?.facts),
        conditionExpression: String(rule?.conditionExpression || 'UNPARSED').slice(0, 1000),
        decision: String(rule?.decision || 'EVIDENCE_INSUFFICIENT').slice(0, 1000),
        parameters: rule?.parameters && typeof rule.parameters === 'object' ? rule.parameters : {},
        ambiguities: normalizeStringArray(rule?.ambiguities),
        confidence: Number.isFinite(confidence) ? Math.max(0, Math.min(1, confidence)) : 0.5
      };
    })
  };
}

async function callAiParser(input) {
  if (!AI_URL || !AI_API_KEY || !AI_MODEL) {
    const error = new Error('AI 服务未配置，请设置 AI_CHAT_COMPLETIONS_URL、AI_API_KEY 和 AI_MODEL');
    error.statusCode = 503;
    throw error;
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
  try {
    const upstream = await fetch(AI_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${AI_API_KEY}`
      },
      body: JSON.stringify({
        model: AI_MODEL,
        temperature: 0.1,
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          {
            role: 'user',
            content: JSON.stringify({
              ruleText: input.text,
              context: input.context
            })
          }
        ]
      }),
      signal: controller.signal
    });

    if (!upstream.ok) {
      const error = new Error(`AI 上游返回 HTTP ${upstream.status}`);
      error.statusCode = 502;
      throw error;
    }
    const payload = await upstream.json();
    const content = payload?.choices?.[0]?.message?.content;
    if (!content) {
      const error = new Error('AI 上游未返回 message.content');
      error.statusCode = 502;
      throw error;
    }
    let parsed;
    try {
      parsed = JSON.parse(cleanJsonText(content));
    } catch {
      const error = new Error('AI 上游返回的内容不是合法 JSON');
      error.statusCode = 502;
      throw error;
    }
    return validateAiResult(parsed);
  } catch (error) {
    if (error.name === 'AbortError') {
      const timeoutError = new Error('AI 请求超时');
      timeoutError.statusCode = 504;
      throw timeoutError;
    }
    throw error;
  } finally {
    clearTimeout(timer);
  }
}
async function handleAnalyze(request, response) {
  const startedAt = Date.now();
  const body = await readRequestBody(request);
  const text = typeof body?.text === 'string' ? body.text.trim() : '';
  if (!text || text.length > MAX_RULE_CHARS) {
    const error = new Error(`规则文本长度必须在 1 到 ${MAX_RULE_CHARS} 字符之间`);
    error.statusCode = 400;
    throw error;
  }
  const context = body?.context && typeof body.context === 'object'
    ? {
        role: String(body.context.role || '').slice(0, 200),
        task: String(body.context.task || '').slice(0, 200),
        state: String(body.context.state || '').slice(0, 200),
        owner: String(body.context.owner || '').slice(0, 200)
      }
    : {};
  const result = await callAiParser({ text, context });
  console.log(`[AI] analyzed rules=${result.rules.length} durationMs=${Date.now() - startedAt}`);
  sendJson(response, 200, { parser: 'AI_CANDIDATE', ...result });
}

const server = createServer(async (request, response) => {
  applySecurityHeaders(response);
  try {
    const url = new URL(request.url || '/', `http://${request.headers.host || `${HOST}:${PORT}`}`);
    if (request.method === 'GET' && url.pathname === '/api/health') {
      sendJson(response, 200, {
        status: 'ok',
        aiConfigured: Boolean(AI_URL && AI_API_KEY && AI_MODEL),
        model: AI_MODEL || null
      });
      return;
    }
    if (request.method === 'POST' && url.pathname === '/api/rule-ir/analyze') {
      await handleAnalyze(request, response);
      return;
    }
    if (request.method === 'GET' && (url.pathname === '/' || url.pathname === '/13-原型-业务规则到UI交互映射.html')) {
      const html = await readFile(HTML_PATH);
      response.writeHead(200, {
        'Content-Type': 'text/html; charset=utf-8',
        'Content-Length': html.length,
        'Cache-Control': 'no-store'
      });
      response.end(html);
      return;
    }
    sendJson(response, 404, { error: 'NOT_FOUND' });
  } catch (error) {
    const status = Number(error.statusCode) || 500;
    console.error(`[ERROR] status=${status} type=${error.name || 'Error'} message=${error.message}`);
    sendJson(response, status, {
      error: status >= 500 ? 'AI_ANALYSIS_FAILED' : 'INVALID_REQUEST',
      message: error.message
    });
  }
});

server.listen(PORT, HOST, () => {
  console.log(`Rule UI AI server: http://${HOST}:${PORT}`);
  console.log(`AI configured: ${Boolean(AI_URL && AI_API_KEY && AI_MODEL)}`);
  if (!AI_URL || !AI_API_KEY || !AI_MODEL) {
    console.log('Set AI_CHAT_COMPLETIONS_URL, AI_API_KEY and AI_MODEL before using AI mode.');
  }
});
