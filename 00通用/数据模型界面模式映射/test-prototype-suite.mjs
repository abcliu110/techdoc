import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { regressionCases } from "./prototype-suite/contracts/regressions.mjs";

const root = path.dirname(fileURLToPath(import.meta.url));
const pyenvRoot = process.env.USERPROFILE && path.join(process.env.USERPROFILE, ".pyenv", "pyenv-win");
const pyenvVersionFile = pyenvRoot && path.join(pyenvRoot, "version");
const pyenvPython = pyenvVersionFile && fs.existsSync(pyenvVersionFile)
  ? path.join(pyenvRoot, "versions", fs.readFileSync(pyenvVersionFile, "utf8").trim(), "python.exe")
  : "";
const python = process.env.PROTOTYPE_SUITE_PYTHON
  || (pyenvPython && fs.existsSync(pyenvPython) ? pyenvPython : (process.platform === "win32" ? "python.exe" : "python3"));

function parseArgs(argv) {
  const options = { categories: "", url: "http://127.0.0.1:8765", viewport: "1440x900" };
  const valueFlags = new Set(["--categories", "--url", "--viewport"]);
  const booleanFlags = new Set(["--static", "--regressions", "--security", "--browser", "--all"]);
  for (let index = 0; index < argv.length; index += 1) {
    const flag = argv[index];
    if (valueFlags.has(flag)) {
      assert.ok(argv[index + 1] && !argv[index + 1].startsWith("--"), `Missing value for ${flag}`);
      options[flag.slice(2)] = argv[index + 1];
      index += 1;
    } else if (booleanFlags.has(flag)) {
      options[flag.slice(2)] = true;
    } else {
      throw new Error(`Unknown option: ${flag}`);
    }
  }
  return options;
}

function run(command, args) {
  const result = spawnSync(command, args, { cwd: root, encoding: "utf8" });
  if (result.stdout) process.stdout.write(result.stdout);
  if (result.stderr) process.stderr.write(result.stderr);
  assert.equal(result.status, 0, `Command failed: ${command} ${args.join(" ")}`);
}

async function requiredImport(relativePath) {
  const absolutePath = path.join(root, relativePath);
  assert.ok(fs.existsSync(absolutePath), `Missing required source: ${relativePath}`);
  return import(new URL(relativePath, import.meta.url));
}

const options = parseArgs(process.argv.slice(2));
if (options.all) run(process.execPath, [path.join(root, "build-prototype-suite.mjs")]);

const { categories, components } = await requiredImport("./prototype-suite/catalog.mjs");
const { renderersByCategory } = await requiredImport("./prototype-suite/renderers.mjs");
const { interactionContracts } = await requiredImport("./prototype-suite/contracts/interactions.mjs");

assert.equal(categories.length, 13, "The suite must retain 13 categories");
assert.equal(components.length, 309, "The suite must retain 309 components");

const selectedNumbers = new Set(options.categories.split(",").map((value) => value.trim()).filter(Boolean));
const unknownCategories = [...selectedNumbers].filter((number) => !categories.some((category) => category.number === number));
assert.deepEqual(unknownCategories, [], `Unknown categories: ${unknownCategories.join(",")}`);
const selectedCategories = categories.filter((category) => !selectedNumbers.size || selectedNumbers.has(category.number));
const selectedComponents = selectedCategories.flatMap((category) => category.components);

const renderers = Object.assign({}, ...Object.values(renderersByCategory));
const componentIds = components.map((component) => component.key).sort();
assert.deepEqual(Object.keys(renderers).sort(), componentIds, "Every component must have one explicit renderer");
assert.deepEqual(Object.keys(interactionContracts).sort(), componentIds, "Every component must have one interaction contract");
assert.equal(new Set(Object.values(renderers)).size, 309, "Renderer functions must be unique references");

for (const component of selectedComponents) {
  const renderer = renderers[component.key];
  const contract = interactionContracts[component.key];
  assert.equal(typeof renderer, "function", `Renderer missing: ${component.key}`);
  assert.equal(contract.componentKey, component.key, `Contract key mismatch: ${component.key}`);
  assert.ok(contract.steps.length > 0, `Contract steps missing: ${component.key}`);
  assert.ok(contract.observe, `Contract observe selector missing: ${component.key}`);
  assert.ok(contract.changed, `Contract changed assertion missing: ${component.key}`);
  assert.ok(contract.reset, `Contract reset assertion missing: ${component.key}`);
}

const sourceFiles = fs.readdirSync(path.join(root, "prototype-suite", "categories"))
  .filter((name) => name.endsWith(".mjs") && !name.endsWith(".test.mjs"));
const sourceText = sourceFiles
  .map((name) => fs.readFileSync(path.join(root, "prototype-suite", "categories", name), "utf8"))
  .join("\n");

for (const forbidden of ["defaultRenderer", "fallbackRenderer"]) {
  assert.ok(!sourceText.includes(forbidden), `Forbidden generic renderer found: ${forbidden}`);
}

for (const category of selectedCategories) {
  const generated = fs.readFileSync(path.join(root, category.file), "utf8");
  assert.ok(generated.includes(`const renderers${category.number}`), `Generated renderer registry missing: ${category.number}`);
  assert.ok(generated.includes('rel="icon" href="data:,"'), `Generated page must suppress implicit favicon requests: ${category.file}`);
  assert.ok(!generated.includes("export default"), `Generated script contains an ESM export: ${category.file}`);
}

const generatedSource = selectedCategories.map((category) => fs.readFileSync(path.join(root, category.file), "utf8")).join("\n");
for (const forbidden of ["else stage.innerHTML=gridHtml", "else stage.innerHTML=formHtml", "defaultRenderer", "fallbackRenderer", "insertAdjacentHTML"]) {
  assert.ok(!generatedSource.includes(forbidden), `Forbidden generated behavior found: ${forbidden}`);
}

assert.equal(regressionCases.length, 10, "All confirmed regressions must remain registered");

if (options.static || options.all) {
  run(process.execPath, [path.join(root, "prototype-suite", "business-realism.test.mjs")]);
}

if (options.regressions || options.security || options.all) {
  run(python, [path.join(root, "prototype-suite", "confirmed-regressions.py")]);
}
if (options.browser) {
  const args = [path.join(root, "prototype-suite", "browser-regression.py"), "--url", options.url, "--viewport", options.viewport];
  if (options.categories) args.push("--categories", options.categories);
  run(python, args);
}
if (options.all) {
  run(python, [path.join(root, "prototype-suite", "browser-regression.py"), "--url", options.url, "--viewport", "1440x900"]);
  run(python, [path.join(root, "prototype-suite", "browser-regression.py"), "--url", options.url, "--viewport", "390x844"]);
  run(python, [path.join(root, "prototype-suite", "responsive-audit.py")]);
}

console.log(JSON.stringify({
  static: "pass",
  categories: selectedCategories.length,
  components: selectedComponents.length,
  renderers: selectedComponents.length,
  contracts: selectedComponents.length,
  regressions: regressionCases.length,
}));
