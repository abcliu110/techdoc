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

export function verifyDataGridV2(root) {
  const v2Root = join(root, "04-机器索引与Schema", "v2");
  const assemblyPath = join(v2Root, "assemblies", "02-data-grid.assembly.json");
  const effectivePath = join(v2Root, "effective-schemas", "02-data-grid.schema.json");
  const specRoot = join(root, "02-组件规范", "v2-candidates");
  const specPath = join(specRoot, "02-表格类", "02-data-grid.spec.json");
  const sopPath = join(root, "03-生产SOP", "组件实施SOP-v2-candidates", "02-data-grid.implementation-sop.json");
  const sopSchemaPath = join(v2Root, "core", "implementation-sop.schema.json");
  const spec = readJson(specPath);
  const sop = readJson(sopPath);

  const assembled = assembleEffectiveSchema(assemblyPath);
  assert.equal(stableJson(readJson(effectivePath)), stableJson(assembled), "Effective Schema is stale");
  const structuralIssues = validateSpecInstance(spec, effectivePath, { v2Root });
  const sopStructuralIssues = validateSpecInstance(sop, sopSchemaPath, { v2Root });
  const semanticIssues = validateSpecSemantics(spec, assembled);
  const referenceResult = validateSopReferences(sop, { sopPath, specificationsRoot: specRoot, effectiveSchema: assembled });
  assert.deepEqual(structuralIssues, [], "DataGrid structure is invalid");
  assert.deepEqual(sopStructuralIssues, [], "DataGrid SOP structure is invalid");
  assert.deepEqual(semanticIssues, [], "DataGrid semantics are invalid");
  assert.equal(referenceResult.status, "Passed", "DataGrid SOP references are invalid or stale");

  const artifacts = generateArtifacts(spec, sop);
  const expected = [
    [join(specRoot, "02-表格类", "02-data-grid.generated.md"), artifacts.specMarkdown],
    [join(root, "03-生产SOP", "组件实施SOP-v2-candidates", "02-data-grid.generated.md"), artifacts.sopMarkdown],
    [join(v2Root, "reference-catalogs", "02-data-grid.references.json"), stableJson(artifacts.referenceCatalog)],
    [join(specRoot, "02-表格类", "02-data-grid.traceability.json"), stableJson(artifacts.traceability)],
  ];
  for (const [path, content] of expected) assert.equal(readFileSync(path, "utf8"), content, `Generated artifact is stale: ${path}`);

  return {
    status: "PASS",
    componentKey: spec.component.key,
    specificationVersion: spec.specificationVersion,
    specificationStatus: spec.lifecycle.specificationStatus,
    implementationAllowed: spec.lifecycle.implementationAllowed,
    structuralIssues: structuralIssues.length + sopStructuralIssues.length,
    semanticIssues: semanticIssues.length,
    referenceStatus: referenceResult.status,
    generatedArtifacts: expected.length + 1,
    appliedProfiles: assembled["x-applied-profiles"].length,
    digest: referenceResult.specificationDigest,
  };
}

if (process.argv[1] && pathToFileURL(resolve(process.argv[1])).href === import.meta.url) {
  const scriptDir = dirname(fileURLToPath(import.meta.url));
  console.log(JSON.stringify(verifyDataGridV2(resolve(scriptDir, "..", "..")), null, 2));
}
