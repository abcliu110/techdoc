import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));

function run(args) {
  return spawnSync(process.execPath, [path.join(root, "test-prototype-suite.mjs"), ...args], {
    cwd: root,
    encoding: "utf8",
  });
}

const unknown = run(["--unknown"]);
assert.notEqual(unknown.status, 0, "Unknown CLI flags must fail instead of reporting a partial pass");

const categories = run(["--categories", "15,16"]);
assert.equal(categories.status, 0, categories.stderr);
const summary = JSON.parse(categories.stdout.trim().split(/\r?\n/).at(-1));
assert.equal(summary.components, 40, "Category filtering must report only the selected components");

console.log(JSON.stringify({ cli: "pass", unknownFlagRejected: true, selectedComponents: 40 }));
