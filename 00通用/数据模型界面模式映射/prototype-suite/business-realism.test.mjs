import assert from "node:assert/strict";
import { components } from "./catalog.mjs";
import { interactionContracts } from "./contracts/interactions.mjs";

const expectedKeys = components.map((component) => component.key).sort();
assert.deepEqual(Object.keys(interactionContracts).sort(), expectedKeys);

let bLevel = 0;
let cLevel = 0;

const riskCapabilityByCategory = Object.freeze({
  "01": "navigation-context",
  "02": "data-integrity",
  "03": "navigation-context",
  "04": "data-integrity",
  "05": "data-integrity",
  "06": "navigation-context",
  "07": "authoring-recovery",
  "08": "authoring-recovery",
  "09": "authoring-recovery",
  "15": "navigation-context",
  "16": "safety-audit",
  "17": "safety-audit",
  "18": "system-impact",
});

for (const component of components) {
  const contract = interactionContracts[component.key];
  const readiness = contract.readiness;
  assert.ok(readiness, `Readiness metadata missing: ${component.key}`);
  assert.ok(Array.isArray(readiness.states), `Readiness states missing: ${component.key}`);
  for (const state of ["initial", "primary", "exception", "recovered"]) {
    assert.ok(readiness.states.includes(state), `Readiness state ${state} missing: ${component.key}`);
  }
  assert.ok(readiness.recovery?.trim(), `Recovery action missing: ${component.key}`);
  assert.ok(readiness.keyboard?.trim(), `Keyboard path missing: ${component.key}`);
  assert.ok(Array.isArray(readiness.riskCapabilities), `Risk capabilities missing: ${component.key}`);
  assert.ok(
    readiness.riskCapabilities.includes(riskCapabilityByCategory[component.categoryNumber]),
    `Risk capability ${riskCapabilityByCategory[component.categoryNumber]} missing: ${component.key}`,
  );
  const business = contract.business;
  assert.ok(business, `Business metadata missing: ${component.key}`);
  const expectedLevel = component.categoryNumber === "18" ? "C" : "B";
  assert.equal(business.level, expectedLevel, `Wrong realism level: ${component.key}`);
  assert.ok(business.role?.trim(), `Role missing: ${component.key}`);
  assert.ok(business.task?.trim(), `Task missing: ${component.key}`);
  assert.ok(business.rule?.trim(), `Decision rule missing: ${component.key}`);
  assert.ok(business.exception?.trim(), `Exception path missing: ${component.key}`);
  assert.ok(business.effect?.trim(), `Business effect missing: ${component.key}`);
  assert.ok(Array.isArray(business.objects), `Business objects missing: ${component.key}`);
  assert.ok(business.objects.length >= (expectedLevel === "C" ? 3 : 1), `Insufficient business objects: ${component.key}`);
  assert.ok(contract.steps.length >= 2, `At least two interaction paths required: ${component.key}`);
  const paths = new Set(contract.steps.map((step) => step.path));
  assert.ok(paths.has("primary"), `Primary path missing: ${component.key}`);
  assert.ok(paths.has("exception"), `Exception path missing: ${component.key}`);
  assert.ok(contract.steps.filter((step) => step.path === "primary").length >= 2, `Primary task chain too short: ${component.key}`);
  if (expectedLevel === "C") cLevel += 1;
  else bLevel += 1;
  if (expectedLevel === "C") {
    assert.ok(business.responsibilities?.length >= 2, `Responsibility boundaries missing: ${component.key}`);
    assert.ok(business.crossModuleRule?.trim(), `Cross-module rule missing: ${component.key}`);
    assert.ok(business.timeline?.length >= 3, `Event timeline missing: ${component.key}`);
    assert.ok(business.compensation?.trim(), `Compensation path missing: ${component.key}`);
  }
}

assert.equal(bLevel, 279);
assert.equal(cLevel, 30);
console.log(JSON.stringify({ businessRealism: "pass", levelB: bLevel, levelC: cLevel, components: components.length }));
