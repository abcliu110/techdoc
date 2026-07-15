import assert from "node:assert/strict";
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const sopRoot = resolve(scriptDir, "..");
const suiteRoot = resolve(sopRoot, "..");
const repositoryRoot = resolve(suiteRoot, "..", "..");
const catalogPath = join(suiteRoot, "prototype-suite", "catalog.browser.json");
const indexPath = join(sopRoot, "03-机器索引", "component-sops.json");
const schemaPath = join(sopRoot, "03-机器索引", "component-sops.schema.json");
const governanceSourcePath = join(repositoryRoot, "docs", "superpowers", "specs", "2026-07-15-react-component-production-sop-design.md");
const governanceCopyPath = join(sopRoot, "00-治理总纲", "React企业级组件库生产交付与认证SOP.md");

function readJson(path) {
  assert.ok(existsSync(path), `Missing required JSON file: ${path}`);
  return JSON.parse(readFileSync(path, "utf8"));
}

function extractMetadata(markdown, path) {
  const match = markdown.match(/<!-- component-sop-metadata\n([\s\S]*?)\n-->/);
  assert.ok(match, `Missing component SOP metadata block: ${path}`);
  return JSON.parse(match[1]);
}

function verifyRelativeMarkdownLinks(markdown, path) {
  const links = [...markdown.matchAll(/\[[^\]]+\]\(([^)]+)\)/g)].map((match) => match[1]);
  for (const link of links) {
    if (/^(?:https?:|#)/.test(link)) continue;
    const target = resolve(dirname(path), decodeURIComponent(link.split("#", 1)[0]));
    assert.ok(existsSync(target), `Broken relative Markdown link in ${path}: ${link}`);
  }
}

const catalog = readJson(catalogPath);
const index = readJson(indexPath);
const schema = readJson(schemaPath);
assert.ok(existsSync(governanceCopyPath), `Missing canonical SOP copy: ${governanceCopyPath}`);
assert.equal(
  readFileSync(governanceCopyPath, "utf8"),
  readFileSync(governanceSourcePath, "utf8"),
  "Canonical SOP copy must exactly match the approved design record",
);
const catalogComponents = catalog.flatMap((category) =>
  category.components.map((component) => ({ category, component })),
);

assert.equal(catalog.length, 13, "Catalog must contain the 13 in-scope categories");
assert.equal(catalogComponents.length, 309, "Catalog must contain 309 components");
assert.equal(schema.$id, "component-sops.schema.json", "Unexpected index schema id");
assert.equal(index.schemaVersion, 1, "Unexpected component SOP index version");
assert.equal(index.certificationPolicy, "draft-is-not-certified");
assert.equal(index.components.length, 309, "Index must contain 309 components");

const catalogKeys = new Set(catalogComponents.map(({ component }) => component.key));
const indexKeys = new Set(index.components.map((component) => component.componentKey));
const sopPaths = new Set(index.components.map((component) => component.sopPath));
assert.equal(catalogKeys.size, 309, "Catalog component keys must be unique");
assert.equal(indexKeys.size, 309, "Index component keys must be unique");
assert.equal(sopPaths.size, 309, "Index SOP paths must be unique");
assert.deepEqual([...indexKeys].sort(), [...catalogKeys].sort(), "Index keys must exactly match catalog keys");

const expectedCategoryCounts = Object.fromEntries(
  catalog.map((category) => [category.number, category.components.length]),
);
assert.deepEqual(index.categoryCounts, expectedCategoryCounts, "Index category counts must match catalog");

const requiredHeadings = [
  "## 1. 身份与认证状态",
  "## 2. 原型直接事实",
  "## 3. 生产风险基线",
  "## 4. 生产交互契约",
  "## 5. 组件专属验证",
  "## 6. 七道 Gate 执行卡",
  "## 7. 证据包与发布条件",
  "## 8. 未冻结实施决策",
];

for (const entry of index.components) {
  assert.match(entry.componentKey, /^(0[1-9]|1[5-8]):[a-z0-9-]+$/);
  assert.match(entry.prototypeComplexity, /^[BC]$/);
  assert.match(entry.provisionalRisk, /^R[123]$/);
  assert.equal(entry.lifecycle, "Draft", `${entry.componentKey} must start in Draft`);
  assert.equal(entry.certification, "not-certified", `${entry.componentKey} must not be pre-certified`);

  const sopPath = join(sopRoot, ...entry.sopPath.split("/"));
  assert.ok(existsSync(sopPath), `Missing component SOP: ${entry.sopPath}`);
  const markdown = readFileSync(sopPath, "utf8");
  const metadata = extractMetadata(markdown, sopPath);
  verifyRelativeMarkdownLinks(markdown, sopPath);
  assert.equal(metadata.componentKey, entry.componentKey);
  assert.equal(metadata.lifecycle, entry.lifecycle);
  assert.equal(metadata.certification, entry.certification);
  assert.equal(metadata.provisionalRisk, entry.provisionalRisk);
  assert.ok(markdown.includes(`# ${entry.name}生产级组件 SOP`));
  assert.ok(markdown.includes("现有 HTML 仅是需求与特征化基线，不是生产认证证据"));
  for (const heading of requiredHeadings) assert.ok(markdown.includes(heading), `${entry.componentKey} missing ${heading}`);
  assert.doesNotMatch(markdown, /\b(?:TBD|TODO|FIXME)\b|\uFFFD|\?\?\?/u);
}

const componentRoot = join(sopRoot, "02-组件SOP");
const markdownCount = readdirSync(componentRoot, { recursive: true, withFileTypes: true })
  .filter((entry) => entry.isFile() && entry.name.endsWith(".md"))
  .length;
assert.equal(markdownCount, 309, "Component SOP directory must contain exactly 309 Markdown files");

const categorySopRoot = join(sopRoot, "01-类别SOP");
const categorySopCount = readdirSync(categorySopRoot, { withFileTypes: true })
  .filter((entry) => entry.isFile() && entry.name.endsWith(".md"))
  .length;
assert.equal(categorySopCount, 13, "Category SOP directory must contain exactly 13 Markdown files");
for (const file of readdirSync(categorySopRoot, { withFileTypes: true })) {
  if (!file.isFile() || !file.name.endsWith(".md")) continue;
  const path = join(categorySopRoot, file.name);
  verifyRelativeMarkdownLinks(readFileSync(path, "utf8"), path);
}

const readmePath = join(sopRoot, "README.md");
verifyRelativeMarkdownLinks(readFileSync(readmePath, "utf8"), readmePath);

console.log(JSON.stringify({
  status: "PASS",
  categories: catalog.length,
  components: index.components.length,
  componentSops: markdownCount,
  categorySops: categorySopCount,
  lifecycle: "Draft",
  certification: "not-certified",
}, null, 2));
