import assert from "node:assert/strict";
import { categories } from "./prototype-suite/catalog.mjs";
import { renderers15 as navigationRenderers } from "./prototype-suite/categories/15-navigation.mjs";
import { renderers16 as permissionRenderers } from "./prototype-suite/categories/16-permission.mjs";
import { renderers17 as collaborationRenderers } from "./prototype-suite/categories/17-collaboration.mjs";
import { renderers18 as businessRenderers } from "./prototype-suite/categories/18-business.mjs";
import { enterpriseInteractionContracts } from "./prototype-suite/contracts/enterprise.mjs";

const expectedIds = categories
  .filter(({ number }) => ["15", "16", "17", "18"].includes(number))
  .flatMap(({ number, components }) => components.map(({ id }) => `${number}:${id}`))
  .sort();
const renderers = {
  ...navigationRenderers,
  ...permissionRenderers,
  ...collaborationRenderers,
  ...businessRenderers,
};

assert.equal(expectedIds.length, 90);
assert.deepEqual(Object.keys(renderers).sort(), expectedIds);
assert.deepEqual(Object.keys(enterpriseInteractionContracts).sort(), expectedIds);
assert.equal(new Set(Object.values(renderers)).size, 90);

for (const id of expectedIds) {
  const contract = enterpriseInteractionContracts[id];
  const categoryNumber = id.slice(0, 2);
  assert.equal(contract.componentId, id);
  assert.ok(contract.steps.length >= 3, `Missing primary, exception or recovery steps: ${id}`);
  assert.deepEqual(new Set(contract.steps.map(({ path }) => path)), new Set(["primary", "exception", "recovery"]), `Incomplete paths: ${id}`);
  assert.ok(contract.observe, `Missing observe: ${id}`);
  assert.ok(contract.changed, `Missing changed value: ${id}`);
  assert.ok(contract.reset, `Missing reset value: ${id}`);
  assert.equal(contract.business?.level, categoryNumber === "18" ? "C" : "B", `Wrong realism level: ${id}`);
  assert.ok(contract.business?.role?.trim(), `Missing role: ${id}`);
  assert.ok(contract.business?.task?.trim(), `Missing task: ${id}`);
  assert.ok(contract.business?.objects?.length >= (categoryNumber === "18" ? 3 : 1), `Missing business objects: ${id}`);
  assert.ok(contract.business?.rule?.trim(), `Missing rule: ${id}`);
  assert.ok(contract.business?.exception?.trim(), `Missing exception: ${id}`);
  assert.ok(contract.business?.effect?.trim(), `Missing effect: ${id}`);
  assert.deepEqual(contract.readiness?.states, ["initial", "primary", "exception", "recovered"], `Incomplete readiness states: ${id}`);
  assert.ok(contract.readiness?.recovery?.trim(), `Missing recovery: ${id}`);
  assert.ok(contract.readiness?.keyboard?.trim(), `Missing keyboard route: ${id}`);
  assert.ok(contract.readiness?.riskCapabilities?.length, `Missing risk capability: ${id}`);
  if (categoryNumber === "18") {
    assert.ok(contract.business.responsibilities?.length >= 2, `Missing responsibility boundaries: ${id}`);
    assert.ok(contract.business.crossModuleRule?.trim(), `Missing cross-module rule: ${id}`);
    assert.ok(contract.business.timeline?.length >= 3, `Missing event timeline: ${id}`);
    assert.ok(contract.business.compensation?.trim(), `Missing compensation: ${id}`);
    for (const capability of ["system-impact", "responsibility-boundary", "event-timeline", "compensation"]) {
      assert.ok(contract.readiness.riskCapabilities.includes(capability), `Missing ${capability}: ${id}`);
    }
  }
}

console.log(JSON.stringify({ enterprise: "pass", renderers: 90, contracts: 90 }));
