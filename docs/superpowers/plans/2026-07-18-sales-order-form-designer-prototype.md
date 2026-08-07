# Sales Order Form Designer Prototype Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Build one directly openable, interactive enterprise sales-order form designer prototype.

**Architecture:** A single self-contained HTML file owns the in-memory Data Schema, UI Schema, Rule Schema, history stack, rendering, and interactions. It does not call a backend or modify production modules.

**Tech Stack:** HTML5, CSS, vanilla JavaScript, local browser automation.

---

### Task 1: Build the standalone prototype

**Files:**
- Superseded by: `低代码平台/表单设计器/11-设计工作台与交互/08-页面与交互清单/原型/PT-031可双击演示.html`

- [ ] Implement the fixed 1440x900 enterprise IDE shell with toolbar, activity rail, resource panel, canvas, inspector, and status bar.
- [ ] Model Data Schema, UI Schema, and Rule Schema separately in JavaScript.
- [ ] Render basic information fields and the order-line grid from UI Schema references.
- [ ] Implement field selection, label/required/readonly editing, unused-field insertion, undo, redo, preview, save, and publish.
- [ ] Add stable `data-testid` hooks and root `data-prototype` / dynamic `data-state`.

### Task 2: Verify the rendered prototype

**Evidence:**
- Create screenshot outside production source under `.tmp/prototype-check/`.

- [ ] Open the standalone HTML at 1440x900.
- [ ] Assert `document.body.scrollWidth <= document.body.clientWidth`.
- [ ] Assert the console contains no errors.
- [ ] Exercise: select customer field -> rename -> undo -> redo -> preview.
- [ ] Assert the root state changes to preview and capture a screenshot.
