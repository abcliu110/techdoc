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

export function classifyProductionSops(paths, catalogKeys) {
  const general = [];
  const component = [];
  const mappedComponents = new Set();

  for (const path of paths.map((value) => value.replaceAll("\\", "/"))) {
    if (path === "03-生产SOP/README.md") continue;

    const match = path.match(/^03-生产SOP\/组件实施SOP\/((0[1-9]|1[5-8])-([a-z0-9-]+))\.implementation-sop\.md$/);
    if (match) {
      const componentKey = `${match[2]}:${match[3]}`;
      assert.ok(catalogKeys.has(componentKey), `Component implementation SOP does not map to a catalog component: ${path}`);
      assert.ok(!mappedComponents.has(componentKey), `Duplicate component implementation SOP: ${componentKey}`);
      mappedComponents.add(componentKey);
      component.push(path);
      continue;
    }

    assert.ok(!path.startsWith("03-生产SOP/组件实施SOP/"), `Invalid component implementation SOP name: ${path}`);
    general.push(path);
  }

  assert.equal(general.length, 1, "There must be exactly one general production SOP");
  return { general, component };
}

export function findMissingImplementationSops(indexEntries, mappedComponentKeys) {
  return indexEntries
    .filter((entry) => entry.specificationStatus === "ImplementationReady" && !mappedComponentKeys.has(entry.componentKey))
    .map((entry) => entry.componentKey);
}

export function validateComponentImplementationSop(markdown, componentKey) {
  const specificationId = componentKey.replace(":", "-");
  assert.match(markdown, /> SOP 版本：\s*[0-9]+\.[0-9]+\.[0-9]+/, `${componentKey} implementation SOP requires an SOP version`);
  assert.ok(markdown.includes(`对应组件：\`${componentKey}\``), `${componentKey} implementation SOP must declare its component key`);
  assert.match(markdown, new RegExp(`对应规范：\\[[^\\]]+\\]\\([^)]+${specificationId}\\.spec\\.json\\)`), `${componentKey} implementation SOP must link its own component specification`);
  assert.match(markdown, /上位总流程：\[[^\]]+\]\([^)]+React组件生产交付SOP\.md\)/, `${componentKey} implementation SOP must link the general SOP`);
  for (const section of ["执行输入", "不变量", "RED", "GREEN", "停止条件", "执行记录"]) {
    assert.match(markdown, new RegExp(`^#{1,6} .*${section}.*$`, "m"), `${componentKey} implementation SOP requires section: ${section}`);
  }
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

  assert.equal(index.schemaVersion, 3);
  assert.equal(index.catalogComponents, 309);
  assert.equal(index.components.length, 309);
  assert.deepEqual(index.components.map((entry) => entry.componentKey).sort(), catalogKeys.sort(), "Specification index must exactly cover the catalog");

  const allowedStatuses = new Set(["Backlog", "Draft", "ReviewReady", "ImplementationReady"]);
  const paths = new Set();
  for (const entry of index.components) {
    assert.ok(allowedStatuses.has(entry.specificationStatus), `${entry.componentKey} has invalid status`);
    assert.equal(typeof entry.implementationAllowed, "boolean");
    assert.ok(entry.implementationSopPath === undefined || entry.implementationSopPath === null || typeof entry.implementationSopPath === "string", `${entry.componentKey} has invalid implementation SOP path`);
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
    if (entry.implementationSopPath) {
      assert.ok(existsSync(join(root, ...entry.implementationSopPath.split("/"))), `Missing implementation SOP: ${entry.implementationSopPath}`);
    }
  }

  const actualSpecPaths = new Set(
    findFiles(join(root, "02-组件规范"), (path) => path.endsWith(".spec.json"))
      .map((path) => relative(root, path).replaceAll("\\", "/")),
  );
  assert.deepEqual([...actualSpecPaths].sort(), [...paths].sort(), "Every component specification must be indexed exactly once");

  const productionSopPaths = findFiles(join(root, "03-生产SOP"), (path) => path.endsWith(".md"))
    .map((path) => relative(root, path).replaceAll("\\", "/"));
  const productionSops = classifyProductionSops(productionSopPaths, new Set(catalogKeys));
  const implementationSopKeys = new Set(productionSops.component.map((path) => {
    const match = path.match(/\/((0[1-9]|1[5-8])-([a-z0-9-]+))\.implementation-sop\.md$/);
    const componentKey = `${match[2]}:${match[3]}`;
    validateComponentImplementationSop(readFileSync(join(root, ...path.split("/")), "utf8"), componentKey);
    return componentKey;
  }));
  assert.deepEqual(
    findMissingImplementationSops(index.components, implementationSopKeys),
    [],
    "Every ImplementationReady component requires a component implementation SOP",
  );

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
    generalProductionSops: productionSops.general.length,
    componentImplementationSops: productionSops.component.length,
  };
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  console.log(JSON.stringify(verifySeparation(), null, 2));
}
