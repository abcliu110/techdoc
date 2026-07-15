# DataGrid Specification Assembly Pilot Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and verify a Shadow v2 DataGrid specification pipeline that assembles normalized profiles, validates specification semantics, binds a component SOP by JSON Pointer and digest, and generates readable derived artifacts without changing v1 authority or allowing React implementation.

**Architecture:** JSON Schema Draft 2020-12 files define the structural vocabulary while small Node standard-library tools implement the documented keyword subset and project-specific semantic checks. Core Schema, profiles, assembly, DataGrid specification and SOP are authoritative inputs; effective Schema, reference catalog, Markdown and traceability are deterministic generated outputs. v1 remains untouched and its existing 38 specification tests plus 14 SOP separation tests are mandatory regressions.

**Tech Stack:** Formatted JSON, Node.js ESM, Node standard library (`assert`, `crypto`, `fs`, `path`, `url`), JSON Pointer, SHA-256; no new package or JSON Schema dependency.

---

## File Structure

Authoritative inputs:

- `04-机器索引与Schema/v2/core/component-spec.schema.json`: v2 component specification structural contract and supported-keyword declaration.
- `04-机器索引与Schema/v2/core/implementation-sop.schema.json`: structured component SOP contract.
- `04-机器索引与Schema/v2/profiles/categories/table.profile.json`: table-family required slots, risk floor and semantic checks.
- `04-机器索引与Schema/v2/profiles/capabilities/*.profile.json`: one constraint-only file for each DataGrid capability.
- `04-机器索引与Schema/v2/assemblies/02-data-grid.assembly.json`: ordered list of profiles used by DataGrid.
- `02-组件规范/v2-candidates/02-表格类/02-data-grid.spec.json`: complete proposed DataGrid v2 contract; stays `Draft` and `implementationAllowed=false`.
- `03-生产SOP/组件实施SOP-v2-candidates/02-data-grid.implementation-sop.json`: procedure-only SOP with specification pointers and digest.

Tools and tests:

- `06-维护工具/spec-assembly/shared.mjs`: stable JSON serialization, JSON Pointer, safe path and issue helpers shared by the bounded tools.
- `06-维护工具/spec-assembly/assemble-effective-schema.mjs` and `.test.mjs`: profile assembly and deterministic output.
- `06-维护工具/spec-assembly/validate-spec-instance.mjs` and `.test.mjs`: restricted JSON Schema structural validation.
- `06-维护工具/spec-assembly/validate-spec-semantics.mjs` and `.test.mjs`: cross-object and profile semantic validation.
- `06-维护工具/spec-assembly/validate-sop-references.mjs` and `.test.mjs`: path, version, pointer, digest, coverage and forbidden-duplication checks.
- `06-维护工具/spec-assembly/generate-artifacts.mjs` and `.test.mjs`: deterministic reference catalog, Markdown and traceability generation.
- `06-维护工具/spec-assembly/verify-datagrid-v2.mjs`: one read-only verification entry point for the complete Shadow pilot.

Generated outputs:

- `04-机器索引与Schema/v2/effective-schemas/02-data-grid.schema.json`
- `04-机器索引与Schema/v2/reference-catalogs/02-data-grid.references.json`
- `02-组件规范/v2-candidates/02-表格类/02-data-grid.generated.md`
- `02-组件规范/v2-candidates/02-表格类/02-data-grid.traceability.json`
- `03-生产SOP/组件实施SOP-v2-candidates/02-data-grid.generated.md`

## Task 1: Lock v1 and assemble the effective Schema

**Files:** Create the core Schema, seven profiles, assembly file, shared helper, assembler and assembler test listed above. Do not modify any v1 file.

- [x] **Step 1: Run the v1 baseline**

Run from `00通用/数据模型界面模式映射`:

```powershell
node .\生产级组件SOP\06-维护工具\validate-component-specifications.test.mjs
node .\生产级组件SOP\06-维护工具\validate-component-specifications.mjs
node .\生产级组件SOP\06-维护工具\verify-specification-sop-separation.test.mjs
node .\生产级组件SOP\06-维护工具\verify-specification-sop-separation.mjs
```

Expected: 38 specification cases pass, 5 v1 specifications validate, 14 SOP cases pass, 309 catalog entries remain covered, and implementationAllowed remains zero.

- [x] **Step 2: Write and run failing assembler tests**

Tests must assert deterministic byte output, all seven semantic profile keys, risk maximum `R2`, duplicate-profile rejection, profile-key mismatch rejection, v2-root escape rejection, incompatible-profile rejection and contradictory required-type rejection.

Run:

```powershell
node .\生产级组件SOP\06-维护工具\spec-assembly\assemble-effective-schema.test.mjs
```

Expected RED: assertion failure because the assembler does not exist or cannot yet produce the required effective Schema.

- [x] **Step 3: Implement the minimum assembler**

The implementation reads only the declared core/profile paths, resolves them below `04-机器索引与Schema/v2`, verifies profile identity from the semantic file name, unions and sorts requirements, selects the highest risk, rejects conflicts, and writes only the requested effective-Schema output. It must not write any core, profile, assembly or component-specification input.

- [x] **Step 4: Run GREEN and commit**

Expected: assembler tests pass and two consecutive CLI runs produce byte-identical output.

## Task 2: Add restricted structural validation

**Files:** Create `validate-spec-instance.mjs` and its test. Use `shared.mjs`; do not add a general JSON Schema abstraction or dependency.

- [x] **Step 1: Write and run failing structural tests**

Cover every supported keyword actually declared by the core Schema: `type`, `required`, `properties`, `additionalProperties`, `items`, `minItems`, `uniqueItems`, `enum`, `const`, `pattern`, `minLength`, `minimum`, `allOf`, and file `$ref`. Assert stable issue codes and JSON Pointers. Also assert immediate failure for an unknown Schema keyword, missing `$ref`, `$ref` outside v2, wrong component key, missing profile pointer and an extra contract property.

- [x] **Step 2: Implement the bounded validator**

The validator must fail closed on unsupported keywords, resolve only local JSON files below v2, return sorted `{code,pointer,message}` issues, and apply `x-required-pointers` after the standard subset. It must explicitly identify itself as a project subset rather than claiming full Draft 2020-12 conformance.

- [x] **Step 3: Run GREEN and commit**

Run the structural test followed by the assembler test. Expected: both pass with no warning and no writes outside generated directories.

## Task 3: Author and semantically validate the DataGrid v2 candidate

**Files:** Create `02-data-grid.spec.json`, `validate-spec-semantics.mjs` and its test.

- [x] **Step 1: Write and run failing semantic tests**

Start from the candidate fixture and independently mutate it to prove rejection of: transition state not declared, exception state/region/action/oracle not declared, oracle reference not declared, missing presentation for a user-visible state, missing region referenced by a presentation, unregistered profile semantic check, selection not bound to row identity, a required capability without an oracle, and insufficient R2 approval roles.

- [x] **Step 2: Author the complete candidate specification**

The candidate must preserve v1 scope and API decisions while correcting semantic keys to `data`, `rowSelection.onChange`, and retry with the same `DataGridQuery` plus a new `queryId`. It must define semantic-key maps for API, states, regions and oracles; structured layout and token contracts; state-view presentation for all user-visible states; responsive contracts at 390, 768, 1280 and 1440 plus adjacent-width checks; structured performance budgets; visual oracles for alignment, reachability, clipping, retained state, fixed-column boundaries and focus visibility; and pending independent approval. Keep lifecycle `Draft` and `implementationAllowed=false`.

- [x] **Step 3: Implement registered semantic checks**

Implement only checks requested by the assembled profiles plus the general referential checks. No profile may fill in a missing API type, visual value, threshold or approval answer.

- [x] **Step 4: Run GREEN and commit**

Run assembly, structural and semantic tests, then validate the real DataGrid candidate. Expected: all pass and the candidate remains ineligible for implementation.

## Task 4: Bind a procedure-only SOP to the specification

**Files:** Create the SOP Schema, SOP candidate, reference validator and its test.

- [x] **Step 1: Write and run failing SOP-reference tests**

Assert stable failure for a path outside `02-组件规范/v2-candidates`, component-key mismatch, version mismatch, malformed/missing pointer, forbidden `implements` or `verifies` partition, uncovered required oracle, stale digest, approved stale SOP, and duplicated contract terms including `from rows`, `onSelectionChange`, `querySnapshot`, a TypeScript signature and a numeric threshold.

- [x] **Step 2: Implement path, pointer, digest and duplication validation**

Canonicalize the parsed specification with recursively sorted object keys, hash the UTF-8 canonical JSON with SHA-256, resolve JSON Pointers with RFC 6901 escaping, and return `Passed`, `Failed` or `Stale`. A digest mismatch must always make the SOP stale and prevent approval. Free text is scanned only for objective forbidden forms and the specification's declared legacy aliases; semantic answers remain in specification pointers.

- [x] **Step 3: Author the structured SOP candidate**

Each step contains a stable key, an operation verb, specification pointers in `implements`, oracle pointers in `verifies`, evidence kinds and instructions about sequence or method. It must contain no API payload/type, state result, visual value, quality threshold or Given/When/Then conclusion. Bind the exact candidate version and generated digest, keep status `Draft`, and cover every required behavioral and visual oracle.

- [x] **Step 4: Run GREEN and commit**

Run SOP structural and reference tests plus the real SOP validator. Expected: `Passed`; known v1 drift terms cannot appear as an independent SOP copy.

## Task 5: Generate readable artifacts and traceability

**Files:** Create the artifact generator, test, one-shot verifier and all generated outputs.

- [x] **Step 1: Write and run failing generation tests**

Assert deterministic bytes across two builds, a generated-file warning, source version and digest in both Markdown files, every reference-catalog pointer resolving, and traceability rows linking each required oracle to at least one SOP step and evidence kind.

- [x] **Step 2: Implement the minimum generator**

Generate fixed-section specification Markdown, procedure Markdown, the sorted pointer catalog and sorted traceability JSON. Write only the five declared generated outputs and derive every contract answer from the JSON inputs.

- [x] **Step 3: Add the one-shot verifier**

`verify-datagrid-v2.mjs` must assemble in memory, compare the checked-in generated effective Schema, structurally and semantically validate the real candidate, validate the SOP and digest, regenerate artifacts in memory, compare every checked-in generated file, and return a compact PASS summary. It must not rewrite files.

- [x] **Step 4: Run the complete verification matrix**

Run all five v2 test files, the one-shot verifier, the four v1 commands, `git diff --check`, JSON parsing for every new JSON file, and scans for mojibake/replacement characters/continuous question marks. Expected: all pass; v1 has 5 ReviewReady and 304 Backlog entries, no implementation is allowed, and only DataGrid v2 Shadow files plus this plan/design are changed.

- [x] **Step 5: Commit generated artifacts and documentation**

Use exact path lists. Record that v1 remains authoritative, v2 is a Shadow candidate, no React code was created, and approval is still pending.

## Rollback

The v2 pilot is isolated below `v2/` and `v2-candidates/`. Rollback is deletion or reversion of those new paths and their tool directory; no v1 index, Schema, specification, SOP or admission behavior needs restoration. Generated files can always be rebuilt from authoritative v2 inputs.
