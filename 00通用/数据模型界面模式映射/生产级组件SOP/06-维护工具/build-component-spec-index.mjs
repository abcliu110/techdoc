import { existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { isImplementationAllowed } from "./implementation-admission.mjs";

export { isImplementationAllowed } from "./implementation-admission.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = resolve(scriptDir, "..");
const suiteRoot = resolve(root, "..");
const catalog = JSON.parse(readFileSync(join(suiteRoot, "prototype-suite", "catalog.browser.json"), "utf8"));
const specsRoot = join(root, "02-组件规范");
const outputPath = join(root, "04-机器索引与Schema", "component-spec-index.json");
const v2CandidatesRoot = join(specsRoot, "v2-candidates");
const v2SopsRoot = join(root, "03-生产SOP", "组件实施SOP-v2-candidates");

export function findSpecs(directory) {
  const results = [];
  if (!existsSync(directory)) return results;
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    if (entry.isDirectory() && entry.name === "v2-candidates") continue;
    const path = join(directory, entry.name);
    if (entry.isDirectory()) results.push(...findSpecs(path));
    else if (entry.isFile() && entry.name.endsWith(".spec.json")) results.push(path);
  }
  return results;
}

const specs = new Map();
for (const path of findSpecs(specsRoot)) {
  const spec = JSON.parse(readFileSync(path, "utf8"));
  if (specs.has(spec.identity.componentKey)) throw new Error(`Duplicate component specification: ${spec.identity.componentKey}`);
  specs.set(spec.identity.componentKey, { spec, path });
}

const v2Candidates = new Map();
for (const path of findSpecs(v2CandidatesRoot)) {
  const spec = JSON.parse(readFileSync(path, "utf8"));
  if (v2Candidates.has(spec.component.key)) throw new Error(`Duplicate v2 candidate specification: ${spec.component.key}`);
  v2Candidates.set(spec.component.key, { spec, path });
}

function v2CandidateFields(componentKey) {
  const found = v2Candidates.get(componentKey);
  if (!found) return {};
  const stem = componentKey.replace(":", "-");
  const sopPath = join(v2SopsRoot, `${stem}.implementation-sop.json`);
  return {
    v2CandidateSpecPath: relative(root, found.path).replaceAll("\\", "/"),
    v2CandidateSopPath: existsSync(sopPath) ? relative(root, sopPath).replaceAll("\\", "/") : null,
    v2CandidateStatus: found.spec.lifecycle.implementationAllowed === false
      && ["Draft", "ReviewReady"].includes(found.spec.lifecycle.specificationStatus)
      ? `Shadow${found.spec.lifecycle.specificationStatus}`
      : "InvalidShadowState",
  };
}

function blockersFor(spec, hasImplementationSop) {
  const blockers = spec.openDecisions.map((decision) => `${decision.id}: ${decision.question}`);
  if (spec.publicApi.status !== "frozen") blockers.push("公开 API 尚未冻结");
  if (spec.approval.status !== "approved") blockers.push("规定角色审批尚未完成");
  if (!hasImplementationSop) blockers.push("缺少与组件 key 对应的组件实施 SOP");
  return blockers;
}

const components = catalog.flatMap((category) => category.components.map((component) => {
  const found = specs.get(component.key);
  if (!found) {
    return {
      componentKey: component.key,
      name: component.name,
      category: category.number,
      specificationStatus: "Backlog",
      implementationAllowed: false,
      specPath: null,
      ...v2CandidateFields(component.key),
      blockers: [
        "缺少逐组件公开 API、状态机、真实主路径、异常恢复和验收 oracle",
        "必须经过 API、UX、无障碍和风险评审后才能实现"
      ]
    };
  }
  const { spec, path } = found;
  const implementationSopRelativePath = `03-生产SOP/组件实施SOP/${component.key.replace(":", "-")}.implementation-sop.md`;
  const hasImplementationSop = existsSync(join(root, ...implementationSopRelativePath.split("/")));
  const implementationAllowed = isImplementationAllowed(spec, hasImplementationSop);
  if (spec.lifecycle === "ImplementationReady" && !implementationAllowed) {
    throw new Error(`ImplementationReady specification does not satisfy implementation admission: ${component.key}`);
  }
  return {
    componentKey: component.key,
    name: component.name,
    category: category.number,
    specificationVersion: spec.specificationVersion,
    specificationStatus: spec.lifecycle,
    implementationAllowed,
    specPath: relative(root, path).replaceAll("\\", "/"),
    implementationSopPath: hasImplementationSop ? implementationSopRelativePath : null,
    ...v2CandidateFields(component.key),
    blockers: blockersFor(spec, hasImplementationSop)
  };
}));

const catalogKeys = new Set(components.map((component) => component.componentKey));
for (const componentKey of specs.keys()) {
  if (!catalogKeys.has(componentKey)) throw new Error(`Orphan component specification: ${componentKey}`);
}

const index = {
  schemaVersion: 3,
  generatedFrom: "prototype-suite/catalog.browser.json + reviewed component specifications",
  catalogComponents: components.length,
  components
};

export function buildIndex() {
  mkdirSync(dirname(outputPath), { recursive: true });
  writeFileSync(outputPath, `${JSON.stringify(index, null, 2)}\n`, "utf8");
  return {
    status: "BUILT",
    catalogComponents: components.length,
    specifications: specs.size,
    statuses: components.reduce((counts, component) => {
      counts[component.specificationStatus] = (counts[component.specificationStatus] || 0) + 1;
      return counts;
    }, {}),
  };
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  console.log(JSON.stringify(buildIndex(), null, 2));
}
