import assert from "node:assert/strict";
import { resolve } from "node:path";
import { findBrokenRelativeLinks, writesComponentSpecifications } from "./verify-specification-sop-separation.mjs";

const base = resolve("D:/example/docs/README.md");

assert.deepEqual(findBrokenRelativeLinks("[existing](child.md)", base, () => true), []);
assert.deepEqual(findBrokenRelativeLinks("[missing](child.md)", base, () => false), ["child.md"]);
assert.deepEqual(findBrokenRelativeLinks("[anchor](#part) [web](https://example.com)", base, () => false), []);

assert.equal(writesComponentSpecifications('readFileSync(join(root, "02-组件规范"), "utf8")'), false);
assert.equal(writesComponentSpecifications('writeFileSync(join(root, "02-组件规范", name), body)'), true);
assert.equal(writesComponentSpecifications('writeFileSync(\n  join(root, "02-组件规范", name),\n  body\n)'), true);
assert.equal(writesComponentSpecifications('renameSync(source, join(root, "02-组件规范", name))'), true);

console.log(JSON.stringify({ status: "PASS", cases: 7 }, null, 2));
