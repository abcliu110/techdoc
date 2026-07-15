import assert from "node:assert/strict";
import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = resolve(scriptDir, "..");
const sourceRoot = join(root, "07-历史迁移记录", "mixed-sop", "01-类别SOP");
const targetRoot = join(root, "01-类别规范");

mkdirSync(targetRoot, { recursive: true });
const sources = readdirSync(sourceRoot).filter((name) => name.endsWith(".md")).sort();
assert.equal(sources.length, 13, "Expected 13 historical category documents");

for (const sourceName of sources) {
  const targetName = sourceName.replace(/SOP\.md$/, "规范.md");
  const targetPath = join(targetRoot, targetName);
  assert.ok(!existsSync(targetPath), `Refusing to overwrite category specification: ${targetPath}`);
  const source = readFileSync(join(sourceRoot, sourceName), "utf8");
  const body = source.split("\n## 6. 组件清单\n", 1)[0]
    .replace("生产级组件类别 SOP", "生产级组件类别规范")
    .replace(/^> 风险初始分布：[^\n]+\r?\n/m, "")
    .replace(
      /本类别 SOP 继承[^\n]+\n/,
      "本类别规范继承[React 组件统一生产规范](../00-统一生产规范/README.md)。它定义本类别组件必须满足的结果语义，不定义开发流程。\n",
    )
    .replace("Gate 2 必须基于实际消费场景冻结最终预算；缺少可复现实验环境和 p95 原始数据不得通过。", "单组件规范必须基于实际消费场景给出可复现实验环境、数据规模和 p95 预算。")
    .replaceAll("类别不变量", "正确性不变量")
    .replaceAll("强制验证", "类别验收要求");
  writeFileSync(targetPath, `${body.trim()}\n`, "utf8");
}

console.log(JSON.stringify({ status: "MIGRATED", categorySpecifications: sources.length }, null, 2));
