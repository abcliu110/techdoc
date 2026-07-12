# Enterprise UI Quality Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a deterministic, recursive visual quality gate for nested enterprise designer layouts and expose it through a reusable Codex skill.

**Architecture:** Collect rendered DOM facts in the browser, evaluate them with a pure recursive audit engine, and aggregate findings by Schema ownership. Generate viewport candidates from a JSON contract plus CSS breakpoint neighbors; use browser screenshots and visual review as independent evidence after mechanical checks.

**Tech Stack:** Browser DOM APIs, ES modules, Node built-in test runner, existing local HTTP server, Codex Browser skill.

---

### Task 1: Lock The Recursive Audit Contract

**Files:**
- Create: `tests/geometry-audit.test.mjs`
- Create: `tests/fixtures/geometry-snapshots.mjs`
- Create: `design/visual-contract.json`

- [ ] Write failing tests for nested hard clipping, legal scroll clipping, unexpected label wrapping, blocked hit targets, undeclared scroll axes, portal ownership, descendant aggregation, and breakpoint neighbors.
- [ ] Run `node --test tests/geometry-audit.test.mjs` and confirm failure because the audit module does not exist.

### Task 2: Implement The Pure Audit And DOM Collector

**Files:**
- Create: `prototype/geometry-audit.mjs`
- Modify: `tests/geometry-check.js`

- [ ] Implement rectangle intersection, clip propagation, scroll policy, text rules, hit-test results, finding deduplication, Schema path attribution, and subtree status.
- [ ] Implement DOM collection using computed style, client/scroll geometry, Range line boxes, pointer hit points, scroll-owner metadata, and overlay ownership.
- [ ] Replace the old top-level script with an async browser entry importing `geometry-audit.mjs`.
- [ ] Run the focused audit test and then all Node tests.

### Task 3: Add Rendered Failure Fixtures

**Files:**
- Create: `tests/fixtures/geometry.html`

- [ ] Add isolated cases for three-level clipping, wrapped Chinese toolbar text, legal nested scrolling, blocked pointer hits, and a portal overlay.
- [ ] Serve the project root and run the audit against every fixture case in a real browser.
- [ ] Confirm negative fixtures fail with their expected rule IDs and positive fixtures pass.

### Task 4: Map Schema And Layout Ownership

**Files:**
- Modify: `prototype/index.html`
- Modify: `prototype/app.js`
- Modify: `prototype/styles.css`

- [ ] Add stable Schema/component markers to static and dynamic component roots.
- [ ] Declare intended scroll owners and explicit truncation/wrapping exceptions.
- [ ] Preserve all existing drag, selection, preview, and persistence behavior.
- [ ] Run all Node tests.

### Task 5: Strengthen The Executable Contract

**Files:**
- Modify: `design/visual-contract.yaml`
- Modify: `prototype-method/tests/geometry-policy.yaml`
- Modify: `README.md`

- [ ] Make `visual-contract.json` the executable source for viewport, severity, state, scroll-owner, and exception rules.
- [ ] Record breakpoint-neighbor and descendant-subtree requirements in the human-readable artifacts.
- [ ] Remove completion wording that relies only on the previous three safe desktop screenshots.

### Task 6: Add The Reusable Skill

**Files:**
- Create: `C:/Users/16555/.codex/skills/enterprise-ui-quality-gate/SKILL.md`
- Create: `C:/Users/16555/.codex/skills/enterprise-ui-quality-gate/agents/openai.yaml`
- Create: `C:/Users/16555/.codex/skills/enterprise-ui-quality-gate/references/evidence-contract.md`

- [ ] Initialize the skill with the system skill creator.
- [ ] Make the skill call the project gate, Browser validation, and visual verdict in that order.
- [ ] Require failure-closed status derivation and prohibit subjective score overrides.
- [ ] Run `quick_validate.py` against the skill directory.

### Task 7: Browser Gate And Final Verification

**Files:**
- Create: `reports/quality-gate-report.json`
- Create: `reports/quality-gate-report.md`
- Create: `reports/screenshots/quality-gate-*.png`

- [ ] Audit the current designer at required viewports and every CSS breakpoint neighbor.
- [ ] Exercise design/preview, device, scroll, and overlay states.
- [ ] Fix P0/P1 findings in the owned V3 files and rerun until the mechanical gate passes or evidence forces `BLOCKED`.
- [ ] Run visual verdict on final desktop and compact screenshots.
- [ ] Run all Node tests and JavaScript syntax checks, then report remaining limitations honestly.

