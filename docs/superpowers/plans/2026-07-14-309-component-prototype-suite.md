# 309 Component Prototype Suite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current template-heavy handbook suite with 309 explicitly registered, independently interactive component prototypes while preserving the existing 13 HTML entry points and visual shell.

**Architecture:** Add a dependency-free Node.js source layer under `prototype-suite/`. A shared shell owns navigation, lifecycle, accessibility, safe DOM helpers, and HTML generation; thirteen category modules own all 309 explicit renderer functions; one contract registry drives both static coverage checks and Playwright browser regression. Generated HTML stays standalone by embedding the category metadata, renderer source, shell runtime, and CSS.

**Tech Stack:** Node.js ESM and standard library, native HTML/CSS/JavaScript, Playwright already installed in the local tool environment, system Chrome fallback.

---

## File map

- Create `00通用/数据模型界面模式映射/prototype-suite/catalog.mjs`: category/file metadata and the 309 component definitions parsed from the existing handbooks.
- Create `00通用/数据模型界面模式映射/prototype-suite/dom.mjs`: escaping, safe element creation, labelled controls, cleanup registry, and mount token helpers.
- Create `00通用/数据模型界面模式映射/prototype-suite/styles.mjs`: the existing visual language plus shared prototype primitives.
- Create `00通用/数据模型界面模式映射/prototype-suite/shell.mjs`: handbook HTML builder and the shared browser runtime.
- Create thirteen files under `prototype-suite/categories/`: explicit renderer registry for each component in that category.
- Create `prototype-suite/contracts/interactions.mjs`: 309 explicit browser interaction contracts.
- Create `build-prototype-suite.mjs`: validates registries and generates the 13 handbooks plus total index.
- Create `test-prototype-suite.mjs`: static contract tests, security checks, generated-file checks, and optional browser execution.
- Modify the 13 existing handbook HTML files and `复杂UI组件交互原型手册-总索引.html`: generated output only.
- Modify `复杂UI组件交互原型手册-套件说明.md`: document the independent renderer and test guarantees.

## Task 1: Lock the failing suite contract

**Files:**
- Create: `00通用/数据模型界面模式映射/test-prototype-suite.mjs`
- Create: `00通用/数据模型界面模式映射/prototype-suite/contracts/regressions.mjs`

- [ ] **Step 1: Add the static failing assertions**

The test must import `catalog`, `renderersByCategory`, and `interactionContracts`, then assert:

```js
assert.equal(categories.length, 13);
assert.equal(components.length, 309);
assert.deepEqual(sortedRendererIds, sortedComponentIds);
assert.deepEqual(sortedContractIds, sortedComponentIds);
assert.equal(new Set(allRendererFunctions).size, 309);
for (const component of components) {
  assert.equal(typeof renderers[component.id], "function");
  assert.equal(interactionContracts[component.id].componentId, component.id);
  assert.ok(interactionContracts[component.id].steps.length > 0);
  assert.ok(interactionContracts[component.id].observe);
  assert.ok(interactionContracts[component.id].changed);
  assert.ok(interactionContracts[component.id].reset);
}
```

Add source guards that reject `defaultRenderer`, `fallbackRenderer`, and category dispatch ending in a generic `else` renderer.

- [ ] **Step 2: Add regression cases for all confirmed defects**

Register named cases for:

```text
table-select-all-checks-inputs
contenteditable-arrows-do-not-navigate
message-input-is-text-not-html
schema-invalid-input-is-rejected
rule-result-matches-all-inputs
decision-table-reads-cell-state
state-machine-reset-clears-step
hash-back-forward-rerenders
delayed-focus-cancelled-on-unmount
all-controls-have-accessible-names
```

- [ ] **Step 3: Run the test and verify RED**

Run:

```powershell
node .\test-prototype-suite.mjs --static
```

Expected: failure because `prototype-suite/catalog.mjs` and the renderer/contract registries do not exist.

## Task 2: Build the shared source and lifecycle layer

**Files:**
- Create: `prototype-suite/catalog.mjs`
- Create: `prototype-suite/dom.mjs`
- Create: `prototype-suite/styles.mjs`
- Create: `prototype-suite/shell.mjs`
- Create: `build-prototype-suite.mjs`

- [ ] **Step 1: Extract and freeze the current catalog**

Read each existing `const patterns=[...]` array and commit the exact `id`, `name`, `en`, `model`, `state`, `summary`, `boundary`, and `invariant` into `catalog.mjs`. Add assertions that category counts equal `25,34,20,30,20,25,20,20,25,20,20,20,30` and total 309.

- [ ] **Step 2: Implement safe DOM helpers**

Expose these exact helpers:

```js
escapeHtml(value)
el(tag, attributes, ...children)
button(label, action, options)
field(label, control)
setText(node, value)
cleanupScope()
mountToken()
```

`el()` must assign dynamic text through `textContent`, event listeners through `addEventListener`, and reject attribute names beginning with `on`.

- [ ] **Step 3: Implement the renderer context and lifecycle**

The shell must call one explicit renderer by component ID and supply:

```js
{
  stage,
  component,
  el,
  button,
  field,
  setStatus(text, state),
  toast(text),
  on(target, type, listener),
  timeout(listener, delay),
  token
}
```

Switch and reset must call cleanup, cancel timeouts, replace the stage, create a new token, and mount a fresh renderer.

- [ ] **Step 4: Implement navigation correctness**

Add search, nav buttons, previous/next, guarded arrow navigation, mobile menu, Esc, and `hashchange`. Guard arrow navigation when the event target is an input, textarea, select, button, `[contenteditable]`, or is composing.

- [ ] **Step 5: Implement standalone generation**

`build-prototype-suite.mjs` must import the catalog and category renderer sources, validate registry equality, embed the runtime into each HTML, generate the total index, and fail before writing when any component or contract is missing.

- [ ] **Step 6: Run the static test**

Expected: catalog and lifecycle assertions pass; renderer and contract coverage still fail because category files are not complete.

## Task 3: Implement 01 Layout, 02 Table, 03 Tree, and 04 Form

**Files:**
- Create: `prototype-suite/categories/01-layout.mjs`
- Create: `prototype-suite/categories/02-table.mjs`
- Create: `prototype-suite/categories/03-tree.mjs`
- Create: `prototype-suite/categories/04-form.mjs`
- Modify: `prototype-suite/contracts/interactions.mjs`

- [ ] **Step 1: Write explicit contracts for all 109 components**

Each contract must open the component by ID, perform its component-specific action, observe a named `[data-state]` value, assert a changed value, reset, and assert restoration.

- [ ] **Step 2: Implement 25 layout renderers**

Implement separate behavior for grid columns, row/column direction, flex grow, multicolumn count, split ratio, resize handle, dock zones, tab activation, accordion expansion, card density, masonry order, nested containers, dashboard widgets, draggable grid position, free canvas node position, configurable slots, editor pane visibility, responsive viewport, adaptive breakpoint, immersive mode, master/detail ratio, sidebar collapse, drawer lifecycle, multi-window focus, and saved workspace restore.

- [ ] **Step 3: Implement 34 table renderers**

Implement separate behavior for basic grid state, cell edit buffer, batch patch, tree expansion, master detail selection, row grouping, pivot axis/drill, cross-tab axis swap, OLAP drill path, virtual window start, infinite cursor/load/end, server page/page-size/request, sticky header/column scrolling, multilevel header collapse, column group collapse, column visibility, resize width, column reorder, row reorder, expandable row, inline detail, row selection, cell selection, clipboard copy/paste, column filter, multisort priority, aggregate/subtotal, frozen boundary, spreadsheet formula, property edit, key/value add, comparison highlight, matrix cell state, and data diff side/apply.

- [ ] **Step 4: Implement 20 tree renderers**

Implement separate behavior for normal selection, checkbox cascade, radio exclusivity, lazy loading, virtual tree window, search reveal, drag reparent, inline rename, context menu command, file operations, organization move, category assignment, region path, menu enable state, permission inheritance, dependency impact, relationship direction, outline heading activation, mind-map branch creation, and genealogy generation focus.

- [ ] **Step 5: Implement 30 form renderers**

Implement separate behavior for standard submit, dense layout, dynamic field addition, Schema validation/render, nested path update, repeat rows, master/detail totals, wizard state, step validation, tab dirty state, accordion errors, conditional visibility, field linkage, calculated field, composite validation, async validation with stale response protection, realtime validation, autosave status, multipage progress, survey score, conversational next question, matrix completeness, upload queue, signature strokes/clear, date range validation, cascading address, approval command, version diff selection, form designer field placement, and runtime preview submission.

- [ ] **Step 6: Run category static and browser tests**

Run:

```powershell
node .\test-prototype-suite.mjs --categories 01,02,03,04
```

Expected: 109/109 contracts pass, including select-all, contenteditable keyboard, async reset, and drawer cleanup regressions.

## Task 4: Implement 05 Query, 06 Selector, and 07 Editor

**Files:**
- Create: `prototype-suite/categories/05-query.mjs`
- Create: `prototype-suite/categories/06-selector.mjs`
- Create: `prototype-suite/categories/07-editor.mjs`
- Modify: `prototype-suite/contracts/interactions.mjs`

- [ ] **Step 1: Add contracts for all 65 components**

Every contract must target a component-specific action: no contract may use only generic add/reset actions.

- [ ] **Step 2: Implement 20 query renderers**

Cover condition addition, nested group operator, logic tree nesting, filter apply/clear, compact quick filter, facet counts, saved-query save/load, saved-view columns, template parameters, dynamic query fields, DSL parse/error, full-text term highlighting, autocomplete choice, smart suggestion acceptance, date range, numeric range, tag toggling, cross-field comparison, aggregate having rule, and query-history restore.

- [ ] **Step 3: Implement 25 selector renderers**

Cover searchable single select, multiselect tokens, tag creation, cascade path, tree selection, table row selection, tree-table selection, transfer movement, ordered transfer, organization path, user availability, department scope, role scope, permission scope, related record preview, master-data code selection, map coordinate selection, date, date range, time slot conflict, color value, icon preview, expression result, variable binding, and composite-object summary.

- [ ] **Step 4: Implement 20 editor renderers**

Cover rich-text format, Markdown preview, code run/error, JSON validation/tree, YAML validation, formula evaluation, expression variables, SQL execute/result, visual query clauses, template interpolation, email subject/body preview, document outline, table-cell editing, key/value add, rule condition/action, script console, diff accept/reject, diagram node/edge, image annotation, and schema edit/validation.

- [ ] **Step 5: Run category tests**

Run `node .\test-prototype-suite.mjs --categories 05,06,07` and require 65/65 pass.

## Task 5: Implement 08 Low-code and 09 Flow/Rule

**Files:**
- Create: `prototype-suite/categories/08-lowcode.mjs`
- Create: `prototype-suite/categories/09-flow.mjs`
- Modify: `prototype-suite/contracts/interactions.mjs`

- [ ] **Step 1: Add contracts for all 45 components**

Contracts must explicitly cover invalid Schema rejection, back/forward navigation, rule input consistency, decision-cell execution, state-machine reset, device preview state, publish lifecycle, and non-overlapping diagram insertion.

- [ ] **Step 2: Implement 20 low-code renderers**

Cover page layout placement, form field configuration, report dimensions/measures, dashboard widget data, mobile safe-area preview, data-source connection/test, event chain, action parameters, expression test, component props/slots/events/variants, theme tokens, template instantiation, page tree reparent, navigation route update, device preview, schema parse/last-valid state, design-system version/deprecation, page version diff/revision, publish precheck/environment/progress/result, and runtime component binding.

- [ ] **Step 3: Implement 25 flow/rule renderers**

Cover workflow edge creation, BPMN gateway path, state transition legality/reset, rule evaluation against every input, decision-table cell state and hit policy, expression evaluation, approval branch, service orchestration order, data pipeline stage state, event route, integration retry, task assignment, timer schedule, compensation path, dependency impact, ER relationship, class association, sequence message order, use-case actor link, network topology health, org graph reporting line, mind-map branch, concept relation type, node ports/edges, and infinite-canvas pan/zoom.

- [ ] **Step 4: Run category and regression tests**

Run `node .\test-prototype-suite.mjs --categories 08,09 --regressions` and require 45/45 plus all named regressions pass.

## Task 6: Implement 15 Navigation and 16 Permission

**Files:**
- Create: `prototype-suite/categories/15-navigation.mjs`
- Create: `prototype-suite/categories/16-permission.mjs`
- Modify: `prototype-suite/contracts/interactions.mjs`

- [ ] **Step 1: Add contracts for all 40 components**

- [ ] **Step 2: Implement 20 navigation renderers**

Cover sidebar collapse, top-menu submenu, tab create/close/dirty, ribbon group activation, command search/execute, global search result navigation, breadcrumb ancestor jump, mega-menu group selection, recent-visit restore, favorite add/remove, wizard step, stepper validation, guided-tour target, workspace switch, multi-workspace persistence, context-menu placement/action, keyboard binding conflict, history back/forward, route guard, and navigation permission visibility.

- [ ] **Step 3: Implement 20 permission renderers**

Cover permission matrix cells, role grant diff, organization move, data-scope filter, field mask/edit, row-policy evaluation, menu permission, button permission, API scope, resource grant expiry, inheritance override, permission simulation, audit trace, conditional grant, tenant isolation, data range preview, policy priority, ACL ordering, credential rotate/revoke, and access-request approval.

- [ ] **Step 4: Run category tests**

Run `node .\test-prototype-suite.mjs --categories 15,16` and require 40/40 pass.

## Task 7: Implement 17 Collaboration and 18 Business

**Files:**
- Create: `prototype-suite/categories/17-collaboration.mjs`
- Create: `prototype-suite/categories/18-business.mjs`
- Modify: `prototype-suite/contracts/interactions.mjs`

- [ ] **Step 1: Add contracts for all 50 components**

- [ ] **Step 2: Implement 20 collaboration renderers**

Cover safe instant-message send, group mention, comment resolve, threaded reply collapse, document annotation anchor, image annotation coordinates, notification read state, notification-center filtering, online presence, typing indicator timeout, collaborative cursor movement, conflict choose/merge, optimistic-update rollback, activity timeline filter, operation-log detail, audit-trail chain, ticket conversation status, feedback rating/submit, toast queue, and activity-feed pagination.

- [ ] **Step 3: Implement 30 business renderers**

Cover SKU combination generation, order line totals, order amount recalculation, order-state tracking, stock allocation capacity, inventory transfer balance, price-rule priority, promotion eligibility, settlement reconciliation, invoice tax/total, voucher debit-credit balance, expense approval limit, shift conflict, payroll calculation, recruitment stages, sales funnel move, customer profile segment, contract milestone, project task dependency, logistics tracking, work-order SLA, medical appointment slot, course scheduling conflict, room allocation, warehouse location capacity, seat selection legend/state, resource booking collision, product configurator compatibility, device monitor alarm, and alarm-rule threshold evaluation.

- [ ] **Step 4: Run security and category tests**

Run `node .\test-prototype-suite.mjs --categories 17,18 --security` and require 50/50 pass. The XSS probe must create no executable element and no body marker.

## Task 8: Generate all handbooks and update documentation

**Files:**
- Modify: all 13 handbook HTML files
- Modify: `复杂UI组件交互原型手册-总索引.html`
- Modify: `复杂UI组件交互原型手册-套件说明.md`

- [ ] **Step 1: Generate the suite**

Run:

```powershell
node .\build-prototype-suite.mjs
```

Expected JSON: `categories: 13`, `components: 309`, `renderers: 309`, `contracts: 309`, `files: 14`.

- [ ] **Step 2: Verify no stale generic runtime remains**

Search generated files for the old generic dispatcher and reject matches for `else stage.innerHTML=gridHtml`, `else stage.innerHTML=formHtml`, and direct user-input `insertAdjacentHTML`.

- [ ] **Step 3: Update suite documentation**

Replace the template-reuse statement with the explicit renderer/contract guarantee, add the build and test commands, and state that shared code is limited to the shell and primitive helpers.

## Task 9: Run the full 309-item browser gate

**Files:**
- Modify only if failures require a targeted fix in the owning category module or shared runtime.

- [ ] **Step 1: Start the local server**

Run `python -m http.server 8765 --bind 127.0.0.1` in the handbook directory.

- [ ] **Step 2: Run every interaction contract on desktop**

Run `node .\test-prototype-suite.mjs --browser --url http://127.0.0.1:8765 --viewport 1440x900` and require `309 passed, 0 failed` with no console errors.

- [ ] **Step 3: Run the responsive suite**

Run the mobile matrix at `390x844`, including menu open/close, no document-level horizontal overflow, reachable local canvas scrolling, and 44px primary targets.

- [ ] **Step 4: Run full static verification again**

Run `node .\test-prototype-suite.mjs --all` and require all static, regression, security, accessibility, generated-file, desktop, and mobile checks to pass.

- [ ] **Step 5: Inspect representative screenshots**

Capture at least one screenshot from every category plus before/after evidence for virtual grid, async form validation, low-code publish, state machine, navigation command palette, safe chat, and warehouse location capacity.

## Task 10: Final review and handoff

**Files:**
- Review all files changed by Tasks 1-9.

- [ ] **Step 1: Recheck the 309-key equality and generated diff**

Confirm no missing or extra component IDs and no unrelated files changed.

- [ ] **Step 2: Review for over-sharing**

Reject any category renderer that only forwards its component to a generic behavior renderer. Primitive helpers are allowed; behavior ownership must remain in the named renderer.

- [ ] **Step 3: Report verification and rollback**

Report exact pass counts, changed files, preserved legacy entry points, independent-renderer guarantee, remaining risks, and rollback by restoring the prior HTML directory or reverting the new source/build files.
