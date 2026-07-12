# Enterprise UI Quality Gate Design

## Goal

Prevent a parent layout from passing while nested controls are clipped, wrapped, offscreen, unreachable, or blocked. The gate must produce reproducible evidence and derive `PASS`, `FAIL`, or `BLOCKED` without a subjective completion claim.

## Scope

- Preserve the existing prototype and its current Node test baseline.
- Add a deterministic geometry audit that can inspect arbitrary nesting depth.
- Cover viewport boundaries, hard clipping ancestors, declared scroll owners, text clipping/wrapping, hit targets, and portal ownership.
- Generate viewport candidates from the executable contract and CSS breakpoint neighbors.
- Use screenshot review as a second gate, not as a replacement for geometry evidence.
- Add a reusable Codex skill that invokes the project gate instead of duplicating its algorithms.

## Architecture

The gate uses two related trees:

1. The Schema tree identifies component ownership and legal nesting.
2. The rendered DOM tree provides actual rectangles, clipping, scrolling, text lines, stacking, and hit-test evidence.

Rendered component roots expose `data-schema-id` and `data-component-type`. Portal content uses `data-overlay-owner` so findings can be attributed to the owning Schema component even when its DOM parent differs.

The browser collector converts the DOM into a serializable snapshot. A pure audit function walks that snapshot recursively. It propagates the effective hard clip from the viewport and `overflow: hidden/clip` ancestors, while treating declared `auto/scroll` containers as reachable content rather than immediate failures. Parent component status is derived from its own and descendant findings.

## Findings

Each finding contains a stable rule ID, severity, viewport, UI state, DOM locator, Schema path, measured actual value, expected contract, and optional screenshot reference. P0/P1 findings make the run fail. Missing browser, state, viewport, report, or visual-review evidence makes the run blocked.

Duplicate descendant symptoms caused by one clipped ancestor are collapsed to the nearest responsible component. This preserves useful root-cause evidence without flooding the report.

## Required Checks

- Four-direction viewport and hard-clip containment.
- Internal content clipping hidden by `overflow: hidden/clip`.
- Short interactive labels that wrap into multiple lines.
- Text whose scroll dimensions exceed its visible box without a declared truncation policy.
- Interactive controls that cannot receive pointer hits at their center or safe inset points.
- Scroll owners that overflow on undeclared axes or cannot reach their end.
- Portal and overlay content evaluated against its overlay host and viewport.
- Component subtree aggregation at arbitrary depth with cycle and node-count guards.

## Viewport And State Matrix

Required widths include declared work viewports, the minimum supported widths, and every CSS width breakpoint at `-1`, exact, and `+1` pixels. Mandatory states include design and preview, device variants, tabs/steps/expanded states, overlay-open states, scroll start/middle/end, and representative content pressure. Full Cartesian expansion is not required; mandatory risk combinations are always retained and remaining combinations may use pairwise sampling.

## Execution Levels

- Local edit: affected subtree, current viewport, and nearest breakpoint neighbors.
- Pre-delivery: all required viewports and critical states with deterministic findings.
- Milestone: pre-delivery gate plus screenshots, visual verdict, interaction replay, and independent review.

## Compatibility

The existing prototype behavior remains unchanged. Audit markers are additive. Existing tests remain the regression baseline. The old top-level geometry script is replaced by a compatible browser-evaluable entry that returns richer JSON.

## Acceptance

- Unit fixtures prove nested clipping, wrapping, blocked hits, undeclared scrolling, legal scrolling, and portal ownership.
- A browser fixture proves the collector catches rendered nested failures.
- The current designer is tested at breakpoint-adjacent widths, including the width that previously compressed toolbar labels.
- The report cannot be `PASS` when any mandatory evidence is absent or any P0/P1 remains.
- The reusable skill validates successfully and contains no copy of the audit algorithm.

