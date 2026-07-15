# Component Specification and SOP Separation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the mixed 309-file SOP set with a structure where component specifications define the required result and a separate production SOP defines the delivery process.

**Architecture:** Keep the approved production governance as the process authority. Introduce immutable source facts and hand-authored/frozen component specifications as separate artifacts; generated indexes may reference them but may not overwrite frozen specifications or certification progress. A strict validator rejects generic core actions, unfrozen implementation contracts presented as executable specifications, risk contradictions, duplicate/missing components, and process content copied into every component specification.

**Tech Stack:** Markdown, JSON Schema, Node.js ESM, built-in `node:assert`, existing `prototype-suite/catalog.browser.json`.

---

### Task 1: Lock the New Information Architecture With a Failing Test

**Files:**
- Modify: `00通用/数据模型界面模式映射/生产级组件SOP/05-维护工具/verify-component-sops.mjs`
- Test: `00通用/数据模型界面模式映射/生产级组件SOP/05-维护工具/verify-component-sops.mjs`

- [ ] **Step 1: Change the validator contract before changing documents**

Require these directories and exact responsibilities:

```text
00-统一生产规范/      shared result constraints
01-类别规范/          13 category-specific result constraints
02-组件规范/          309 component result specifications
03-生产SOP/           one delivery process, no component copies
04-机器索引与Schema/  references and validation contracts
05-证据规范/          versioned evidence contract
06-维护工具/          non-destructive validation/migration tools
07-历史迁移记录/      legacy mixed-SOP audit and mapping
```

The validator must assert:

```javascript
assert.equal(componentSpecifications.length, 309);
assert.equal(categorySpecifications.length, 13);
assert.equal(productionSops.length, 1);
assert.ok(spec.api.status === "frozen" || spec.lifecycle === "Draft");
assert.notEqual(spec.primaryFlow.steps[0].action, "load context");
assert.ok(spec.primaryFlow.steps.every((step) => step.control && step.observable));
assert.ok(spec.exceptionFlows.every((flow) => flow.trigger && flow.blockedEffect && flow.recovery && flow.oracle));
assert.ok(spec.risk.triggers.every((trigger) => !contradicts(spec.risk.level, trigger)));
assert.ok(!markdown.includes("G1 登记定级"));
```

- [ ] **Step 2: Run the validator and observe RED**

Run:

```powershell
node .\生产级组件SOP\05-维护工具\verify-component-sops.mjs
```

Expected: FAIL because the current tree contains mixed component SOPs, repeated Gate tables, generic core steps, and no frozen component specification schema.

### Task 2: Preserve the Current Audit Trail Without Treating It as Authority

**Files:**
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/07-历史迁移记录/README.md`
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/07-历史迁移记录/mixed-sop-audit.json`
- Modify: `00通用/数据模型界面模式映射/生产级组件SOP/05-维护工具/generate-component-sops.mjs`

- [ ] **Step 1: Record confirmed defects**

Record these measured facts:

```json
{
  "componentDocuments": 309,
  "apiNotFrozen": 309,
  "allSevenGatesUnstarted": 309,
  "genericCompositeCoreActions": 90,
  "genericStructuredCoreActions": 84,
  "legacyMiddleRendererTest": "FAIL",
  "classification": "migration-input-not-component-specification"
}
```

- [ ] **Step 2: Make the old generator non-destructive**

Replace full-tree writes with a migration command that writes only to `07-历史迁移记录/generated/`. It must refuse to write under `02-组件规范/`.

- [ ] **Step 3: Verify the refusal behavior**

Run the migration tool with `02-组件规范` as the output path and expect a non-zero exit with `Frozen specifications cannot be generated or overwritten`.

### Task 3: Define the Machine-Readable Component Specification Contract

**Files:**
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/04-机器索引与Schema/component-spec.schema.json`
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/04-机器索引与Schema/component-spec-index.json`
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/06-维护工具/validate-component-specifications.mjs`

- [ ] **Step 1: Define required specification fields**

The schema must require:

```json
{
  "identity": {},
  "purpose": {},
  "boundaries": {},
  "dataContract": {},
  "publicApi": {},
  "stateMachine": {},
  "primaryFlow": {},
  "exceptionFlows": [],
  "keyboardAndFocus": {},
  "accessibility": {},
  "visualAndResponsive": {},
  "performance": {},
  "security": {},
  "compatibility": {},
  "acceptanceOracles": [],
  "risk": {},
  "sourceTrace": {}
}
```

Each primary step must include `actor`, `precondition`, `control`, `action`, `stateTransition`, `observable`, and `oracle`. Each exception must include a reproducible trigger, prohibited side effect, retained user state, recovery action, focus result, and assertion.

- [ ] **Step 2: Reject unknown implementation decisions**

A Draft specification may carry unresolved decisions only in a structured `openDecisions` array and cannot be passed to implementation. An `ImplementationReady` specification must have zero open decisions and `publicApi.status = frozen`.

- [ ] **Step 3: Run schema tests**

Use one valid fixture and fixtures missing API, state transition, exception oracle, visual behavior, and risk evidence. Expected: valid fixture passes; each invalid fixture fails at its exact missing field.

### Task 4: Separate Shared Standards, Category Standards, and Production SOP

**Files:**
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/00-统一生产规范/README.md`
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/01-类别规范/*.md`
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/03-生产SOP/React组件生产交付SOP.md`
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/05-证据规范/README.md`

- [ ] **Step 1: Move result constraints to shared standards**

Shared standards own TypeScript API stability, controlled state semantics, error recovery, WCAG 2.2 AA, visual tokens, responsive support, SSR boundaries, package exports, compatibility, and default evidence requirements.

- [ ] **Step 2: Keep category behavior in category standards**

Each of the 13 category standards owns category-specific semantics such as grid row identity, tree navigation, form validation, editor undo history, permission deny precedence, or offline replay.

- [ ] **Step 3: Keep process only in the production SOP**

The production SOP owns Gate 1-7, RED/GREEN, approvals, artifact promotion, deviation, freeze, release, and rollback. Component specifications link to it but do not copy Gate tables.

### Task 5: Create Five Review Candidates Before Scaling

**Files:**
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/02-组件规范/02-表格类/02-data-grid.spec.json`
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/02-组件规范/04-表单与数据录入类/04-async-validation-form.spec.json`
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/02-组件规范/15-导航与工作区类/15-breadcrumb.spec.json`
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/02-组件规范/16-权限与组织管理类/16-permission-matrix.spec.json`
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/02-组件规范/18-业务领域复合组件/18-stock-allocation.spec.json`
- Test: `00通用/数据模型界面模式映射/生产级组件SOP/06-维护工具/validate-component-specifications.mjs`

- [x] **Step 1: Author five differentiated vertical-slice specifications**

Cover R1 navigation, R2 data identity, R2 asynchronous race recovery, R3 permission/tenant security, and R3 inventory conservation/concurrency. Each candidate specifies a proposed React API, state machine, real component actions, reproducible failures, forbidden side effects, retained state, recovery focus, measurable behavior, and acceptance oracles.

- [x] **Step 2: Keep review candidates non-executable**

Expected: all five are `ReviewReady`, `publicApi.status=proposed`, `approval.status=pending`, and carry explicit `openDecisions`. `ImplementationReady=0` and `implementationAllowed=0` until independent review occurs.

- [ ] **Step 3: Human review gate before any implementation**

Review each candidate for product semantics, React API, accessibility, test oracle, feasibility, and risk. R3 candidates additionally require domain/security review. Review may change the proposal; it must not be simulated by a generator or AI self-approval.

### Task 6: Build a Complete Maturity Index Without Inventing Specifications

**Files:**
- Create: `00通用/数据模型界面模式映射/生产级组件SOP/06-维护工具/build-component-spec-index.mjs`
- Modify: `00通用/数据模型界面模式映射/生产级组件SOP/04-机器索引与Schema/component-spec-index.json`

- [x] **Step 1: Index all catalog identities**

Index all 309 catalog keys. A key without a reviewed specification is `Backlog` with explicit blockers and `specPath=null`; coverage in the index is not specification coverage.

- [x] **Step 2: Prevent generated authority**

The builder only reads existing specifications and writes the machine index. It does not create or overwrite component specifications, statuses, approvals, APIs, primary controls, exception triggers, or final risk.

- [x] **Step 3: Run strict validation**

Expected output: 309 indexed components, 5 `ReviewReady`, 304 `Backlog`, zero `ImplementationReady`, zero implementation allowed, and five valid component specifications.

### Task 7: Archive the Mixed Structure and Make the New Model Authoritative

**Files:**
- Archive: `00通用/数据模型界面模式映射/生产级组件SOP/01-类别SOP/`
- Archive: `00通用/数据模型界面模式映射/生产级组件SOP/02-组件SOP/`
- Replace: `00通用/数据模型界面模式映射/生产级组件SOP/03-机器索引/`
- Replace: `00通用/数据模型界面模式映射/生产级组件SOP/04-模板与证据规范/`
- Replace: `00通用/数据模型界面模式映射/生产级组件SOP/05-维护工具/`

- [x] **Step 1: Preserve the old material as non-authoritative evidence**

Move old mixed documents, index, templates, and generator under `07-历史迁移记录/mixed-sop/`. Record the measured defects and label the set `migration-input-not-component-specification`.

- [x] **Step 2: Remove obsolete authoritative paths**

The root must no longer expose `01-类别SOP` or `02-组件SOP`; the old destructive generator must not exist under the authoritative maintenance directory.

- [x] **Step 3: Run final structural verification**

Expected:

```json
{
  "catalogComponents": 309,
  "indexedComponents": 309,
  "componentSpecifications": 5,
  "reviewReady": 5,
  "backlog": 304,
  "implementationAllowed": 0,
  "categorySpecifications": 13,
  "productionSops": 1,
  "duplicateKeys": 0,
  "genericCoreActions": 0,
  "brokenLinks": 0,
  "destructiveGenerators": 0
}
```
