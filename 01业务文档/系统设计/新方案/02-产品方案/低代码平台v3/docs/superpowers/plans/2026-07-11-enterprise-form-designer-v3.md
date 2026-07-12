# Enterprise Form Designer V3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Build a working enterprise form designer with a complete manifest-driven component library, real Schema mutations, validated drag and drop, synchronized outline/inspector/preview, and responsive verification.

**Architecture:** Keep the existing dependency-free HTML/CSS/ES module prototype. Introduce a single component registry, a pure immutable Schema engine, and a UI adapter that renders the component panel, outline, canvas and inspector from shared state. Native pointer/drag events produce drop intents; only accepted Schema transactions update the UI and history.

**Tech Stack:** HTML, CSS, browser ES modules, Node.js built-in test runner, agent-browser.

---

### Task 1: Component registry

**Files:**
- Create: `prototype/component-registry.mjs`
- Create: `tests/component-registry.test.mjs`

- [ ] Write failing tests that assert at least 64 unique manifests, ten categories, search aliases, page/device support, and separate manifests for EntryGrid, SubEntryGrid, TreeEntryGrid, TreeGrid and TreePicker.
- [ ] Run `node --test tests/component-registry.test.mjs` and confirm failure because the registry is missing.
- [ ] Implement frozen manifests and helpers `getManifest`, `searchComponents`, `getAvailability`.
- [ ] Verify the test passes and no duplicate type exists.

### Task 2: Immutable Schema engine

**Files:**
- Create: `prototype/schema-engine.mjs`
- Create: `tests/schema-engine.test.mjs`

- [ ] Write failing tests for material insertion, before/inside/after placement, sibling reorder, cross-container move, cycle rejection, unknown type rejection, invalid parent rejection and unchanged source Schema after failure.
- [ ] Run the test and confirm expected failures.
- [ ] Implement normalized nodes, immutable transactions, full-tree validation and explicit reason codes.
- [ ] Verify all Schema engine tests pass.

### Task 3: History and selection state

**Files:**
- Modify: `prototype/designer-state.mjs`
- Modify: `tests/designer-state.test.mjs`

- [ ] Add failing tests for selection synchronization, transaction history, undo, redo, dirty state and device/business-state context.
- [ ] Run the tests and confirm the missing behavior fails.
- [ ] Extend state without removing existing workspace and publish-validation behavior.
- [ ] Verify legacy and new state tests pass.

### Task 4: Designer workbench rendering

**Files:**
- Modify: `prototype/index.html`
- Modify: `prototype/styles.css`
- Modify: `prototype/app.js`
- Modify: `tests/prototype-contract.test.mjs`

- [ ] Add failing static-contract assertions for component category navigation, search, availability badges, outline tree, breadcrumb, canvas drop zones, inspector tabs, preview/device controls and debug panel.
- [ ] Render the component panel from the registry rather than hard-coded cards.
- [ ] Render the canvas and outline from Schema; update inspector and breadcrumb from the shared selected node.
- [ ] Keep existing object/rule/permission workspaces accessible.
- [ ] Verify static contracts and state tests pass.

### Task 5: Real drag and drop

**Files:**
- Modify: `prototype/app.js`
- Modify: `prototype/styles.css`
- Create: `tests/drag-contract.test.mjs`

- [ ] Add failing contract tests for draggable materials/nodes, encoded source IDs, target IDs, before/inside/after positions, rejection messages and keyboard add/move commands.
- [ ] Implement native dragstart/dragover/drop and pointer-safe drop-zone rendering.
- [ ] Route every drop through the Schema engine, then push history and synchronize selection.
- [ ] Show explicit rejection reasons and leave Schema unchanged on failure.
- [ ] Verify drag contracts and all unit tests pass.

### Task 6: Inspector, preview and persistence

**Files:**
- Modify: `prototype/app.js`
- Modify: `prototype/styles.css`
- Create: `tests/persistence-preview.test.mjs`

- [ ] Add failing tests for property updates, device overrides, business-state overrides, serialization round trip and preview renderer selection.
- [ ] Implement inspector property updates as Schema transactions.
- [ ] Persist versioned Schema to localStorage and support reset/import/export.
- [ ] Implement design/preview switch with desktop/tablet/mobile widths and create/edit/view/approve contexts.
- [ ] Verify round-trip and preview tests pass.

### Task 7: Browser and visual verification

**Files:**
- Modify: `tests/geometry-check.js` only if the new stable geometry requires updated selectors.
- Create: `reports/v3-browser-verification-2026-07-11.md`

- [ ] Run `node --test tests/*.test.mjs` and record totals.
- [ ] Start `python -m http.server 4173 --bind 127.0.0.1` in `prototype`.
- [ ] Use agent-browser to test component search, legal material drop, invalid SubEntryGrid drop, reorder, cross-container move, undo, redo, outline selection, inspector edit and preview switch.
- [ ] Capture and inspect 1280x800, 1440x900, 1920x1080 and mobile screenshots.
- [ ] Confirm no blank canvas, overlap, clipping, console error or failed network request.
- [ ] Write the evidence report and keep known external-service limitations explicit.

## Completion Gate

- Component panel is registry-driven and exposes the complete catalog with ready/conditional/planned states.
- A successful drop changes serialized Schema; animation alone is not success.
- Invalid drops preserve Schema and explain the exact reason.
- Canvas, outline, breadcrumb and inspector share one selected node.
- Undo/redo and serialization round trip are proven by tests.
- Desktop and mobile screenshots are visually reviewed.

