import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";
import { fileURLToPath } from "node:url";
import { categories } from "../catalog.mjs";
import { middleInteractionContracts } from "../contracts/middle-interactions.mjs";

const suiteRoot = path.dirname(path.dirname(path.dirname(fileURLToPath(import.meta.url))));

const moduleFiles = new Map([
  ["05", "./05-query.mjs"],
  ["06", "./06-selector.mjs"],
  ["07", "./07-editor.mjs"],
  ["08", "./08-lowcode.mjs"],
  ["09", "./09-flow.mjs"],
]);

let total = 0;
const allFunctions = [];

for (const [number, moduleFile] of moduleFiles) {
  const category = categories.find((item) => item.number === number);
  const module = await import(moduleFile);
  const expectedIds = category.components.map((component) => `${number}:${component.id}`).sort();
  const actualIds = Object.keys(module.renderers).sort();

  assert.equal(module.categoryNumber, number);
  assert.deepEqual(actualIds, expectedIds, `${number} renderer IDs must match the catalog`);

  for (const id of actualIds) {
    assert.equal(typeof module.renderers[id], "function", `${number}:${id} must be a function`);
    allFunctions.push(module.renderers[id]);
  }
  total += actualIds.length;
}

assert.equal(total, 110);
assert.equal(new Set(allFunctions).size, 110, "Every component must have an independent renderer function");
const expectedContractIds = categories
  .filter((category) => moduleFiles.has(category.number))
  .flatMap((category) => category.components.map((component) => `${category.number}:${component.id}`))
  .sort();
assert.deepEqual(Object.keys(middleInteractionContracts).sort(), expectedContractIds);
for (const contract of Object.values(middleInteractionContracts)) {
  assert.equal(contract.business?.level, "B", `${contract.componentKey} must be B-level`);
  for (const field of ["role", "task", "rule", "exception", "effect"]) {
    assert.ok(contract.business?.[field]?.trim(), `${contract.componentKey} business.${field} is required`);
  }
  assert.ok(contract.business.objects?.length >= 1, `${contract.componentKey} requires a business object`);
  assert.deepEqual(contract.readiness?.states, ["initial", "primary", "exception", "recovered"]);
  assert.ok(contract.readiness.recovery.trim(), `${contract.componentKey} requires recovery guidance`);
  assert.ok(contract.readiness.keyboard.trim(), `${contract.componentKey} requires a keyboard path`);
  const expectedCapability = contract.componentKey.startsWith("05:")
    ? "data-integrity"
    : contract.componentKey.startsWith("06:")
      ? "navigation-context"
      : "authoring-recovery";
  assert.ok(contract.readiness.riskCapabilities.includes(expectedCapability), `${contract.componentKey} requires ${expectedCapability}`);
  assert.deepEqual(new Set(contract.steps.map((step) => step.path)), new Set(["primary", "exception", "recovery"]));
  assert.match(contract.steps.find((step) => step.path === "primary").selector, /^\[data-action="[a-z0-9:-]+"\]$/);
  assert.equal(contract.steps.find((step) => step.path === "exception").selector, "[data-readiness-exception]");
  assert.equal(contract.steps.find((step) => step.path === "recovery").selector, "[data-readiness-recovery]");
}
for (const [number, moduleFile] of moduleFiles) {
  const source = fs.readFileSync(new URL(moduleFile, import.meta.url), "utf8");
  const categoryContracts = Object.values(middleInteractionContracts).filter((contract) => contract.componentKey.startsWith(`${number}:`));
  for (const contract of categoryContracts) {
    const action = contract.steps.find((step) => step.path === "primary").selector.slice(14, -2);
    assert.ok(source.includes(`"${action}"`), `Missing action ${action} in ${moduleFile}`);
  }
  for (const forbidden of ["default" + "Renderer", "fallback" + "Renderer", "insertAdjacent" + "HTML", "function " + "simple", "action" + "Renderer("]) {
    assert.ok(!source.includes(forbidden), `${moduleFile} contains forbidden behavior: ${forbidden}`);
  }
  const category = categories.find((item) => item.number === number);
  const html = fs.readFileSync(path.join(suiteRoot, category.file), "utf8");
  const script = html.match(/<script>([\s\S]*)<\/script>/)?.[1];
  assert.ok(script, `${category.file} must contain a runtime script`);
  new vm.Script(script, { filename: category.file });
}
console.log(JSON.stringify({ categories: moduleFiles.size, renderers: total }));
