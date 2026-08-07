import assert from "node:assert/strict";
import { components } from "./catalog.mjs";
import { renderers01 } from "./categories/01-layout.mjs";
import { renderers02 } from "./categories/02-table.mjs";
import { renderers03 } from "./categories/03-tree.mjs";
import { renderers04 } from "./categories/04-form.mjs";
import { interactionContractsCore } from "./contracts/interactions-core.mjs";

const categoryNumbers = new Set(["01", "02", "03", "04"]);
const expectedKeys = components.filter(({ categoryNumber }) => categoryNumbers.has(categoryNumber)).map(({ key }) => key).sort();
const renderers = { ...renderers01, ...renderers02, ...renderers03, ...renderers04 };

assert.equal(expectedKeys.length, 109);
assert.deepEqual(Object.keys(renderers).sort(), expectedKeys);
assert.deepEqual(Object.keys(interactionContractsCore).sort(), expectedKeys);
assert.equal(new Set(Object.values(renderers)).size, 109);
for (const key of expectedKeys) {
  const contract = interactionContractsCore[key];
  assert.equal(contract.componentKey, key);
  assert.ok(contract.steps.length > 0);
  assert.notEqual(contract.steps[0].selector, "[data-action]");
}

console.log(JSON.stringify({ components: 109, renderers: 109, contracts: 109, functions: 109 }));
