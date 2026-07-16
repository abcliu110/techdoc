import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { canonicalDigest } from "./validate-sop-references.mjs";
import { readJson, stableJson } from "./shared.mjs";

function rowsFromMap(map, render) {
  return Object.entries(map || {}).sort(([left], [right]) => left.localeCompare(right)).map(([key, value]) => render(key, value));
}

function componentStem(spec) {
  return `${spec.component.category}-${spec.component.key.split(":")[1]}`;
}

function renderSpec(spec, digest) {
  const stem = componentStem(spec);
  const lines = [
    "<!-- GENERATED FILE: 请勿手工编辑 -->",
    "",
    `# ${spec.component.englishName} v2 候选规范`,
    "",
    `- 源：\`${stem}.spec.json\``,
    `- 版本：\`${spec.specificationVersion}\``,
    `- Digest：\`${digest}\``,
    `- 状态：\`${spec.lifecycle.specificationStatus}\`，\`implementationAllowed=${spec.lifecycle.implementationAllowed}\``,
    "",
    "## 范围",
    "",
    spec.scope.purpose,
    "",
    `包含：${spec.scope.in.join("、")}`,
    "",
    `不包含：${spec.scope.out.join("、")}`,
    "",
    "## API",
    "",
    "| Pointer | 类型/事件 | 契约 |",
    "|---|---|---|",
    ...rowsFromMap(spec.api.props, (key, value) => `| \`/api/props/${key}\` | \`${value.type}\` | ${value.contract} |`),
    ...rowsFromMap(spec.api.events, (key, value) => `| \`/api/events/${key}\` | \`${value.name}\` | \`${value.payload}\` |`),
    "",
    "## 状态机",
    "",
    `状态：${Object.keys(spec.behavior.states).join("、")}`,
    "",
    "| 转换 | From | To |",
    "|---|---|---|",
    ...spec.behavior.transitions.map((value) => `| ${value.id} | ${value.from.join(" / ")} | ${value.to.join(" / ")} |`),
    "",
    "## 界面结构",
    "",
    "| 区域 | 用途 |",
    "|---|---|",
    ...rowsFromMap(spec.view.regions, (key, value) => `| \`/view/regions/${key}\` | ${value.purpose} |`),
    "",
    "## 状态视图",
    "",
    "| 状态 | 区域 | 呈现 |",
    "|---|---|---|",
    ...rowsFromMap(spec.view.statePresentation, (key, value) => `| \`${key}\` | ${value.regions.join("、")} | ${value.presentation} |`),
    "",
    "## 无障碍",
    "",
    `${spec.accessibility.keyboardModel.pattern}；${spec.accessibility.keyboardModel.focusRecovery}`,
    "",
    "## 质量预算",
    "",
    "| Pointer | Operator | Value | Unit | Fixture |",
    "|---|---|---:|---|---|",
    ...rowsFromMap(spec.quality.performanceBudgets, (key, value) => `| \`/quality/performanceBudgets/${key}\` | ${value.operator} | ${value.value} | ${value.unit} | ${value.fixture} |`),
    "",
    "## 行为 Oracle",
    "",
    ...rowsFromMap(spec.quality.oracles, (key, value) => `### \`/quality/oracles/${key}\`\n\nGiven ${value.given}\n\nWhen ${value.when}\n\nThen ${value.then}`),
    "",
    "## 视觉 Oracle",
    "",
    ...rowsFromMap(spec.quality.visualOracles, (key, value) => `### \`/quality/visualOracles/${key}\`\n\nGiven ${value.given}\n\nWhen ${value.when}\n\nThen ${value.then}`),
    "",
    "## 风险与审批",
    "",
    `风险：\`${spec.risk.level}\`；所需角色：${spec.approval.requiredRoles.map((role) => `\`${role}\``).join("、")}；当前审批：\`${spec.approval.status}\`。`,
    "",
  ];
  return lines.join("\n");
}

function renderSop(sop, spec) {
  const stem = componentStem(spec);
  const lines = [
    "<!-- GENERATED FILE: 请勿手工编辑 -->",
    "",
    `# ${spec.component.exportName} v2 候选实施 SOP`,
    "",
    `- 源：\`${stem}.implementation-sop.json\``,
    `- SOP 版本：\`${sop.sopVersion}\``,
    `- 规范版本：\`${spec.specificationVersion}\``,
    `- Digest：\`${sop.specification.digest}\``,
    `- 状态：\`${sop.status}\``,
    "",
    "## 执行步骤",
    "",
  ];
  for (const [index, step] of sop.steps.entries()) {
    lines.push(
      `### ${index + 1}. ${step.key}`,
      "",
      `动作：\`${step.action}\``,
      "",
      step.method,
      "",
      `实施引用：${step.implements.length ? step.implements.map((pointer) => `\`${pointer}\``).join("、") : "无"}`,
      "",
      `验证引用：${step.verifies.length ? step.verifies.map((pointer) => `\`${pointer}\``).join("、") : "无"}`,
      "",
      `证据：${step.evidenceKinds.map((kind) => `\`${kind}\``).join("、")}`,
      "",
    );
  }
  return lines.join("\n");
}

export function generateArtifacts(spec, sop) {
  const digest = canonicalDigest(spec);
  const pointerSet = new Set();
  for (const step of sop.steps || []) for (const pointer of [...step.implements, ...step.verifies]) pointerSet.add(pointer);
  const pointers = [...pointerSet].sort();
  const oracles = [
    ...Object.keys(spec.quality?.oracles || {}).map((key) => `/quality/oracles/${key}`),
    ...Object.keys(spec.quality?.visualOracles || {}).map((key) => `/quality/visualOracles/${key}`),
  ].sort();

  const rows = oracles.map((oracle) => {
    const steps = (sop.steps || []).filter((step) => step.verifies.includes(oracle));
    return {
      oracle,
      steps: steps.map((step) => step.key).sort(),
      evidenceKinds: [...new Set(steps.flatMap((step) => step.evidenceKinds))].sort(),
    };
  });
  const links = (sop.steps || []).flatMap((step) =>
    step.implements.flatMap((implementationPointer) =>
      step.verifies.flatMap((oracle) =>
        step.evidenceKinds.map((evidenceKind) => ({ implementationPointer, step: step.key, oracle, evidenceKind })))))
    .sort((left, right) => left.implementationPointer.localeCompare(right.implementationPointer)
      || left.step.localeCompare(right.step)
      || left.oracle.localeCompare(right.oracle)
      || left.evidenceKind.localeCompare(right.evidenceKind));

  return {
    specMarkdown: renderSpec(spec, digest),
    sopMarkdown: renderSop(sop, spec),
    referenceCatalog: {
      componentKey: spec.component.key,
      specificationVersion: spec.specificationVersion,
      digest,
      pointers,
    },
    traceability: {
      componentKey: spec.component.key,
      specificationVersion: spec.specificationVersion,
      digest,
      rows,
      links,
    },
  };
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  const [specPath, sopPath, specMarkdownPath, sopMarkdownPath, catalogPath, traceabilityPath] = process.argv.slice(2);
  if (!traceabilityPath) throw new Error("Usage: node generate-artifacts.mjs <spec> <sop> <spec-md> <sop-md> <catalog-json> <trace-json>");
  const artifacts = generateArtifacts(readJson(resolve(specPath)), readJson(resolve(sopPath)));
  for (const [path, content] of [
    [specMarkdownPath, artifacts.specMarkdown],
    [sopMarkdownPath, artifacts.sopMarkdown],
    [catalogPath, stableJson(artifacts.referenceCatalog)],
    [traceabilityPath, stableJson(artifacts.traceability)],
  ]) {
    mkdirSync(dirname(resolve(path)), { recursive: true });
    writeFileSync(resolve(path), content, "utf8");
  }
  console.log(JSON.stringify({ status: "PASS", componentKey: artifacts.referenceCatalog.componentKey, generated: 4 }, null, 2));
}
