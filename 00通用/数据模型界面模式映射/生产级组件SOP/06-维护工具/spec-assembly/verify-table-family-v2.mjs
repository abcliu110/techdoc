import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { assembleEffectiveSchema } from "./assemble-effective-schema.mjs";
import { generateArtifacts } from "./generate-artifacts.mjs";
import { readJson, stableJson } from "./shared.mjs";
import { validateSopReferences } from "./validate-sop-references.mjs";
import { validateSpecInstance } from "./validate-spec-instance.mjs";
import { validateSpecSemantics } from "./validate-spec-semantics.mjs";

const components = ["02-tree-grid", "02-master-detail-grid"];

export function verifyTableFamilyV2(root) {
  const v2Root = join(root, "04-机器索引与Schema", "v2");
  const specRoot = join(root, "02-组件规范", "v2-candidates");
  const sopRoot = join(root, "03-生产SOP", "组件实施SOP-v2-candidates");
  const sopSchemaPath = join(v2Root, "core", "implementation-sop.schema.json");
  const results = [];

  for (const stem of components) {
    const assemblyPath = join(v2Root, "assemblies", `${stem}.assembly.json`);
    const effectivePath = join(v2Root, "effective-schemas", `${stem}.schema.json`);
    const specPath = join(specRoot, "02-表格类", `${stem}.spec.json`);
    const sopPath = join(sopRoot, `${stem}.implementation-sop.json`);
    const spec = readJson(specPath);
    const sop = readJson(sopPath);
    const assembled = assembleEffectiveSchema(assemblyPath);

    assert.equal(stableJson(readJson(effectivePath)), stableJson(assembled), `Effective Schema is stale: ${stem}`);
    assert.deepEqual(validateSpecInstance(spec, effectivePath, { v2Root }), [], `Specification structure is invalid: ${stem}`);
    assert.deepEqual(validateSpecInstance(sop, sopSchemaPath, { v2Root }), [], `SOP structure is invalid: ${stem}`);
    assert.deepEqual(validateSpecSemantics(spec, assembled), [], `Specification semantics are invalid: ${stem}`);
    const referenceResult = validateSopReferences(sop, { sopPath, specificationsRoot: specRoot, effectiveSchema: assembled });
    assert.equal(referenceResult.status, "Passed", `SOP references are invalid or stale: ${stem}`);

    const artifacts = generateArtifacts(spec, sop);
    const expected = [
      [join(specRoot, "02-表格类", `${stem}.generated.md`), artifacts.specMarkdown],
      [join(sopRoot, `${stem}.generated.md`), artifacts.sopMarkdown],
      [join(v2Root, "reference-catalogs", `${stem}.references.json`), stableJson(artifacts.referenceCatalog)],
      [join(specRoot, "02-表格类", `${stem}.traceability.json`), stableJson(artifacts.traceability)],
    ];
    for (const [path, content] of expected) assert.equal(readFileSync(path, "utf8"), content, `Generated artifact is stale: ${path}`);

    results.push({
      componentKey: spec.component.key,
      specificationVersion: spec.specificationVersion,
      implementationAllowed: spec.lifecycle.implementationAllowed,
      specificationStatus: spec.lifecycle.specificationStatus,
      appliedProfiles: assembled["x-applied-profiles"].length,
      digest: referenceResult.specificationDigest,
      generatedArtifacts: expected.length + 1,
    });
  }

  return { status: "PASS", components: results };
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  const scriptDir = dirname(fileURLToPath(import.meta.url));
  console.log(JSON.stringify(verifyTableFamilyV2(resolve(scriptDir, "..", "..")), null, 2));
}
