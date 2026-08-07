# Form Designer Complete Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Deliver all 15 approved form-designer demo capabilities through a real browser-operable prototype.

**Architecture:** Keep production code unchanged. Build a dependency-free modular prototype with a pure document model, command/history layer, DOM renderer, local simulation adapters, and browser-level acceptance checks.

**Tech Stack:** HTML, CSS, ES modules, Python Playwright, system Chrome.

---

### Task 1: Lock the contract
- Create a static contract test asserting all required files, test hooks, schema layers, modes, commands, and simulation disclosures.
- Run it before implementation and confirm failure because PT-031 does not exist.

### Task 2: Implement document model and command layer
- Create `model.js` with sample sales-order schemas, tree operations, rules, versions, import/export and history.
- Keep formulas to a fixed operation whitelist.

### Task 3: Implement the workbench
- Create `index.html`, `styles.css`, and `app.js` with toolbar, palettes, outline, canvas, inspector, schema, rule, permission, workflow and version surfaces.
- Expose stable test hooks for every approved capability.

### Task 4: Implement preview and submission
- Render PC/tablet/mobile previews from the same document.
- Execute visible/required/readonly/fetch/calculate rules and simulated validation/submission.

### Task 5: Verify
- Run static contract checks.
- Run browser interaction scenarios at 1440×900 and 1920×1080.
- Check mobile preview, console health, overflow, drag/drop, history, rules, versions, import/export and submission.
- Capture design, rule, version and mobile-preview screenshots.
