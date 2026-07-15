import assert from "node:assert/strict";
import { existsSync, readFileSync, readdirSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = resolve(scriptDir, "..");
const suiteRoot = resolve(root, "..");

const expectedDirectories = [
  "00-统一生产规范",
  "01-类别规范",
  "02-组件规范",
  "03-生产SOP",
  "04-机器索引与Schema",
  "05-证据规范",
  "06-维护工具",
  "07-历史迁移记录",
];

function findFiles(directory, predicate) {
  const files = [];
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    const path = join(directory, entry.name);
    if (entry.isDirectory()) files.push(...findFiles(path, predicate));
    else if (entry.isFile() && predicate(path)) files.push(path);
  }
  return files;
}

export function findBrokenRelativeLinks(markdown, filePath, pathExists = existsSync) {
  const broken = [];
  const pattern = /(?<!\!)\[[^\]]+\]\(([^)#]+)(?:#[^)]+)?\)/g;
  for (const match of markdown.matchAll(pattern)) {
    const target = match[1];
    if (/^[a-z][a-z0-9+.-]*:/i.test(target)) continue;
    const decoded = decodeURIComponent(target);
    if (!pathExists(resolve(dirname(filePath), decoded))) broken.push(target);
  }
  return broken;
}

export function writesComponentSpecifications(source) {
  return /(?:writeFileSync|appendFileSync|renameSync|copyFileSync)\s*\([\s\S]{0,500}?02-组件规范/u.test(source);
}

export function verifySeparation() {
  for (const directory of expectedDirectories) {
    assert.ok(existsSync(join(root, directory)), `Missing separated responsibility directory: ${directory}`);
  }

  const catalog = JSON.parse(readFileSync(join(suiteRoot, "prototype-suite", "catalog.browser.json"), "utf8"));
  const catalogKeys = catalog.flatMap((category) => category.components.map((component) => component.key));
  const indexPath = join(root, "04-机器索引与Schema", "component-spec-index.json");
  assert.ok(existsSync(indexPath), `Missing component specification index: ${indexPath}`);
  const index = JSON.parse(readFileSync(indexPath, "utf8"));

  assert.equal(index.schemaVersion, 2);
  assert.equal(index.catalogComponents, 309);
  assert.equal(index.components.length, 309);
  assert.deepEqual(index.components.map((entry) => entry.componentKey).sort(), catalogKeys.sort(), "Specification index must exactly cover the catalog");

  const allowedStatuses = new Set(["Backlog", "Draft", "ReviewReady", "ImplementationReady"]);
  const paths = new Set();
  for (const entry of index.components) {
    assert.ok(allowedStatuses.has(entry.specificationStatus), `${entry.componentKey} has invalid status`);
    assert.equal(typeof entry.implementationAllowed, "boolean");
    assert.equal(entry.implementationAllowed, entry.specificationStatus === "ImplementationReady");
    if (entry.specificationStatus === "Backlog") {
      assert.equal(entry.specPath, null, `${entry.componentKey} backlog must not pretend to have a specification`);
      assert.ok(entry.blockers.length > 0, `${entry.componentKey} backlog requires blockers`);
      continue;
    }
    assert.ok(entry.specPath, `${entry.componentKey} requires a specification path`);
    assert.ok(!paths.has(entry.specPath), `Duplicate specification path: ${entry.specPath}`);
    paths.add(entry.specPath);
    assert.ok(existsSync(join(root, ...entry.specPath.split("/"))), `Missing specification: ${entry.specPath}`);
  }

  const actualSpecPaths = new Set(
    findFiles(join(root, "02-组件规范"), (path) => path.endsWith(".spec.json"))
      .map((path) => relative(root, path).replaceAll("\\", "/")),
  );
  assert.deepEqual([...actualSpecPaths].sort(), [...paths].sort(), "Every component specification must be indexed exactly once");

  const productionSops = readdirSync(join(root, "03-生产SOP"), { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".md"));
  assert.equal(productionSops.length, 1, "There must be exactly one production SOP");

  const categorySpecifications = readdirSync(join(root, "01-类别规范"), { withFileTypes: true })
    .filter((entry) => entry.isFile() && entry.name.endsWith(".md"));
  assert.equal(categorySpecifications.length, 13, "There must be 13 category specifications");

  assert.ok(!existsSync(join(root, "01-类别SOP")), "Mixed category SOP directory must not remain authoritative");
  assert.ok(!existsSync(join(root, "02-组件SOP")), "Mixed component SOP directory must not remain authoritative");

  const authoritativeMarkdown = [
    join(root, "README.md"),
    ...findFiles(join(root, "00-统一生产规范"), (path) => path.endsWith(".md")),
    ...findFiles(join(root, "01-类别规范"), (path) => path.endsWith(".md")),
    ...findFiles(join(root, "03-生产SOP"), (path) => path.endsWith(".md")),
    ...findFiles(join(root, "05-证据规范"), (path) => path.endsWith(".md")),
  ];
  const brokenLinks = authoritativeMarkdown.flatMap((path) =>
    findBrokenRelativeLinks(readFileSync(path, "utf8"), path).map((target) => `${relative(root, path)} -> ${target}`));
  assert.deepEqual(brokenLinks, [], "Authoritative Markdown contains broken relative links");

  const maintenanceTools = findFiles(join(root, "06-维护工具"), (path) => path.endsWith(".mjs") && !path.endsWith(".test.mjs"));
  const destructiveGenerators = maintenanceTools.filter((path) => writesComponentSpecifications(readFileSync(path, "utf8")));
  assert.deepEqual(destructiveGenerators, [], "Authoritative maintenance tools must not write component specifications");

  return {
    status: "PASS",
    catalogComponents: index.catalogComponents,
    specificationStatuses: index.components.reduce((counts, entry) => {
      counts[entry.specificationStatus] = (counts[entry.specificationStatus] || 0) + 1;
      return counts;
    }, {}),
    indexedSpecifications: paths.size,
    brokenLinks: brokenLinks.length,
    destructiveGenerators: destructiveGenerators.length,
    categorySpecifications: categorySpecifications.length,
    productionSops: productionSops.length,
  };
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  console.log(JSON.stringify(verifySeparation(), null, 2));
}
