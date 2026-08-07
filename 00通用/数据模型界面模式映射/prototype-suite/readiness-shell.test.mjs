import assert from "node:assert/strict";
import { buildHandbookHtml } from "./shell.mjs";

const category = {
  number: "99",
  name: "测试类",
  en: "Test",
  components: [{
    id: "sample",
    key: "99:sample",
    name: "样例组件",
    en: "Sample",
    summary: "样例",
    model: "Sample",
    state: "ready",
    boundary: "边界",
    invariant: "不变量",
    contract: {
      business: { level: "B", role: "审核员", task: "复核订单", objects: ["SO-1"], rule: "金额必须有效", exception: "数据版本冲突", effect: "生成审计记录" },
      readiness: { states: ["initial", "primary", "exception", "recovered"], recovery: "重新加载最新版本", keyboard: "Tab 到操作并按 Enter", riskCapabilities: ["data-integrity"] },
    },
  }],
};

const html = buildHandbookHtml(category, "const renderers99 = {'99:sample': () => {}};", "renderers99");
for (const marker of ["taskContext", "data-readiness-start", "data-readiness-exception", "data-readiness-recovery", "readinessResult"]) {
  assert.ok(html.includes(marker), `Readiness shell marker missing: ${marker}`);
}
assert.ok(html.includes("主路径完成"));
assert.ok(html.includes('["click", "contextmenu"]'));
assert.ok(html.includes("数据版本冲突"));
assert.ok(html.includes("重新加载最新版本"));
console.log(JSON.stringify({ readinessShell: "pass" }));
