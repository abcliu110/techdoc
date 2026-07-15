import assert from "node:assert/strict";
import { resolve } from "node:path";
import {
  classifyProductionSops,
  findMissingImplementationSops,
  findBrokenRelativeLinks,
  validateComponentImplementationSop,
  writesComponentSpecifications,
} from "./verify-specification-sop-separation.mjs";

const base = resolve("D:/example/docs/README.md");

assert.deepEqual(findBrokenRelativeLinks("[existing](child.md)", base, () => true), []);
assert.deepEqual(findBrokenRelativeLinks("[missing](child.md)", base, () => false), ["child.md"]);
assert.deepEqual(findBrokenRelativeLinks("[anchor](#part) [web](https://example.com)", base, () => false), []);

assert.equal(writesComponentSpecifications('readFileSync(join(root, "02-组件规范"), "utf8")'), false);
assert.equal(writesComponentSpecifications('writeFileSync(join(root, "02-组件规范", name), body)'), true);
assert.equal(writesComponentSpecifications('writeFileSync(\n  join(root, "02-组件规范", name),\n  body\n)'), true);
assert.equal(writesComponentSpecifications('renameSync(source, join(root, "02-组件规范", name))'), true);

assert.deepEqual(
  classifyProductionSops([
    "03-生产SOP/React组件生产交付SOP.md",
    "03-生产SOP/组件实施SOP/02-data-grid.implementation-sop.md",
  ], new Set(["02:data-grid"])),
  {
    general: ["03-生产SOP/React组件生产交付SOP.md"],
    component: ["03-生产SOP/组件实施SOP/02-data-grid.implementation-sop.md"],
  },
);
assert.throws(
  () => classifyProductionSops([
    "03-生产SOP/React组件生产交付SOP.md",
    "03-生产SOP/另一个总SOP.md",
  ], new Set()),
  /exactly one general production SOP/,
);
assert.throws(
  () => classifyProductionSops([
    "03-生产SOP/React组件生产交付SOP.md",
    "03-生产SOP/组件实施SOP/02-unknown.implementation-sop.md",
  ], new Set(["02:data-grid"])),
  /does not map to a catalog component/,
);
assert.deepEqual(
  findMissingImplementationSops([
    { componentKey: "02:data-grid", specificationStatus: "ImplementationReady" },
    { componentKey: "02:tree-grid", specificationStatus: "ReviewReady" },
  ], new Set()),
  ["02:data-grid"],
);
assert.doesNotThrow(() => validateComponentImplementationSop(`
> SOP 版本：0.1.0
> 对应组件：\`02:data-grid\`
> 对应规范：[spec](../../02-组件规范/02-表格类/02-data-grid.spec.json)
> 上位总流程：[general](../React组件生产交付SOP.md)
## 执行输入
## 不变量
## RED
## GREEN
## 停止条件
## 执行记录
`, "02:data-grid"));
assert.throws(
  () => validateComponentImplementationSop("# DataGrid 组件实施 SOP", "02:data-grid"),
  /SOP version/,
);
assert.throws(
  () => validateComponentImplementationSop(`
> SOP 版本：0.1.0
> 对应组件：\`02:data-grid\`
> 对应规范：[wrong](../../02-组件规范/02-表格类/02-tree-grid.spec.json)
> 上位总流程：[general](../React组件生产交付SOP.md)
执行输入 不变量 RED GREEN 停止条件 执行记录
`, "02:data-grid"),
  /own component specification/,
);

console.log(JSON.stringify({ status: "PASS", cases: 14 }, null, 2));
