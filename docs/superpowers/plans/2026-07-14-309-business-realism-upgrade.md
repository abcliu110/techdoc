# 309 Business Realism Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade all 309 independent HTML prototypes from state-change demos to production-grade interaction specifications, with one shared readiness floor, risk-tiered depth, 279 B-level task loops and 30 C-level system loops.

**Architecture:** Keep the existing generated standalone HTML architecture. Add one data-only business-world module and richer explicit contracts, while keeping every renderer function independent and placing all task rules and state transitions inside its owning category module.

**Tech Stack:** Native HTML/CSS/JavaScript, Node.js standard library, Python Playwright with system Chrome.

---

### Task 1: Business-realism gate and shared world

**Files:**
- Create: `00通用/数据模型界面模式映射/prototype-suite/business-world.mjs`
- Create: `00通用/数据模型界面模式映射/prototype-suite/business-realism.test.mjs`
- Modify: `00通用/数据模型界面模式映射/test-prototype-suite.mjs`
- Modify: `00通用/数据模型界面模式映射/prototype-suite/styles.mjs`

- [x] Write a failing static test that requires all 309 contracts to declare level, role, task, objects, rule, exception, effect, and at least two path-tagged steps.
- [x] Run `node .\\prototype-suite\\business-realism.test.mjs` and confirm it fails with `Business metadata missing: 01:grid-layout`.
- [x] Extend the failing gate so every contract declares applicable readiness states, recovery action, keyboard path and risk capabilities; require only states relevant to the component instead of a fixed synthetic matrix.
- [x] Add stable enterprise identities and non-behavior DOM primitives.
- [x] Add dense task, decision, alert, timeline, KPI and system-layout styles without changing navigation compatibility.
- [x] Wire the gate into `--static` and rerun it after category tasks are complete.

The shared readiness floor for all 309 components is: understandable initial context, 2-5 step primary flow, one relevant non-ideal path, an explicit recovery action, visible business result and reason, keyboard/focus semantics, desktop/mobile reachability, deterministic reset, no runtime errors and safe text rendering.

### Task 2: Layout, table, tree and form task loops

**Files:**
- Modify: `prototype-suite/categories/01-layout.mjs`
- Modify: `prototype-suite/categories/02-table.mjs`
- Modify: `prototype-suite/categories/03-tree.mjs`
- Modify: `prototype-suite/categories/04-form.mjs`
- Modify: `prototype-suite/contracts/interactions-core.mjs`

- [x] Replace all 109 simple demos with explicit B-level tasks using stable order, inventory, organization, warehouse and contract data.
- [x] Give every renderer a primary action plus exception/boundary action and a visible downstream effect.
- [x] For tables and forms, additionally cover applicable loading/empty/error, validation, dirty confirmation, batch boundaries and shared-record conflict behavior.
- [x] Write explicit business metadata and path-tagged steps for all 109 contracts.
- [x] Run the 109-item partition tests and browser category regression.

### Task 3: Query, selector, editor, low-code and flow task loops

**Files:**
- Modify: `prototype-suite/categories/05-query.mjs`
- Modify: `prototype-suite/categories/06-selector.mjs`
- Modify: `prototype-suite/categories/07-editor.mjs`
- Modify: `prototype-suite/categories/08-lowcode.mjs`
- Modify: `prototype-suite/categories/09-flow.mjs`
- Modify: `prototype-suite/contracts/middle-interactions.mjs`

- [x] Replace all 110 simple demos with explicit B-level operational tasks.
- [x] Preserve each component's query, selection, parsing, design or orchestration semantics.
- [x] Add normal and failure/boundary paths with visible result explanations.
- [x] For editors, low-code and flow components, additionally cover applicable undo/recovery, unsaved changes, validation location, preview/publish failure and version difference behavior.
- [x] Run the 110-item partition tests and browser category regression.

### Task 4: Navigation, permission and collaboration task loops

**Files:**
- Modify: `prototype-suite/categories/15-navigation.mjs`
- Modify: `prototype-suite/categories/16-permission.mjs`
- Modify: `prototype-suite/categories/17-collaboration.mjs`
- Modify: `prototype-suite/contracts/enterprise.mjs`

- [x] Replace all 60 simple demos with explicit B-level role tasks.
- [x] Make permission scope, collaboration safety and navigation context visible in the main UI.
- [x] Add success and denied/conflict/offline paths with audit or notification effects.
- [x] For permission and collaboration components, additionally prove scope, denial reason, audit trail, retry/replay and duplicate-action safety.
- [x] Run the 60-item category regression and XSS/accessibility checks.

### Task 5: Business composite system loops

**Files:**
- Modify: `prototype-suite/categories/18-business.mjs`
- Modify: `prototype-suite/contracts/enterprise.mjs`

- [x] Replace all 30 renderers with explicit C-level mini-systems containing at least three objects, two responsibilities, one cross-module rule and one event timeline.
- [x] Add operational main and exception paths, with amount, inventory, schedule, SLA or permission impact.
- [x] Prove responsibility boundaries, event timeline and a compensating/recovery path for every C-level mini-system.
- [x] Run the 30-item category regression and system-level contract assertions.

### Task 6: Build, browser matrix and documentation

**Files:**
- Modify: `build-prototype-suite.mjs`
- Modify: `prototype-suite/browser-regression.py`
- Modify: `prototype-suite/responsive-audit.py`
- Modify: `复杂UI组件交互原型手册-套件说明.md`
- Regenerate: 13 handbook HTML files and total index.

- [x] Build and verify 13 categories, 309 unique renderers, 309 rich contracts and 14 output files.
- [x] Run desktop 1440x900 and mobile 390x844 through both normal and exception contract paths.
- [x] Add nearest breakpoint neighbors and keyboard-only primary/recovery flows for representative low-risk components and every high-risk category.
- [x] Run confirmed security, history, lifecycle and accessibility regressions.
- [x] Capture representative evidence for every category and before/after/error states for high-risk components.
- [x] Scan for mojibake, unsafe dynamic HTML, fallback renderers and placeholder business data.
- [x] Update the suite explanation with B/C standards, business-world identities and remaining visual risks.
- [x] Persist a pre-delivery evidence report with exact commands, viewport/state matrix, console result, screenshots, findings and evidence gaps.
