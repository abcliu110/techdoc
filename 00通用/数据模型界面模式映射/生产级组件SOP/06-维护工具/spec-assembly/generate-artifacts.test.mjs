import assert from "node:assert/strict";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { generateArtifacts } from "./generate-artifacts.mjs";
import { getPointer, readJson, stableJson } from "./shared.mjs";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = join(scriptDir, "..", "..");
const spec = readJson(join(root, "02-组件规范", "v2-candidates", "02-表格类", "02-data-grid.spec.json"));
const sop = readJson(join(root, "03-生产SOP", "组件实施SOP-v2-candidates", "02-data-grid.implementation-sop.json"));
const first = generateArtifacts(spec, sop);
const second = generateArtifacts(spec, sop);

assert.equal(first.specMarkdown, second.specMarkdown);
assert.equal(first.sopMarkdown, second.sopMarkdown);
assert.equal(stableJson(first.referenceCatalog), stableJson(second.referenceCatalog));
assert.equal(stableJson(first.traceability), stableJson(second.traceability));
for (const markdown of [first.specMarkdown, first.sopMarkdown]) {
  assert.match(markdown, /请勿手工编辑/u);
  assert.ok(markdown.includes(spec.specificationVersion));
  assert.ok(markdown.includes(sop.specification.digest));
}
for (const pointer of first.referenceCatalog.pointers) assert.ok(getPointer(spec, pointer).exists, pointer);

const expected = [
  ...Object.keys(spec.quality.oracles).map((key) => `/quality/oracles/${key}`),
  ...Object.keys(spec.quality.visualOracles).map((key) => `/quality/visualOracles/${key}`),
].sort();
assert.deepEqual(first.traceability.rows.map((row) => row.oracle), expected);
for (const row of first.traceability.rows) {
  assert.ok(row.steps.length > 0, row.oracle);
  assert.ok(row.evidenceKinds.length > 0, row.oracle);
}
assert.ok(first.traceability.links.length > 0);
for (const link of first.traceability.links) {
  assert.ok(getPointer(spec, link.implementationPointer).exists, link.implementationPointer);
  assert.ok(expected.includes(link.oracle), link.oracle);
  assert.ok(sop.steps.some((step) => step.key === link.step && step.implements.includes(link.implementationPointer) && step.verifies.includes(link.oracle) && step.evidenceKinds.includes(link.evidenceKind)));
}
assert.deepEqual(first.traceability.links, [...first.traceability.links].sort((left, right) =>
  left.implementationPointer.localeCompare(right.implementationPointer)
  || left.step.localeCompare(right.step)
  || left.oracle.localeCompare(right.oracle)
  || left.evidenceKind.localeCompare(right.evidenceKind)));

console.log(JSON.stringify({ status: "PASS", cases: 11 }, null, 2));
