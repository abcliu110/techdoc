import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import {
  auditGeometrySnapshot,
  buildViewportMatrix,
  deriveGateStatus,
  extractCssBreakpoints,
} from '../prototype/geometry-audit.mjs';
import {
  blockedHitTarget,
  intentionalTruncation,
  legalHorizontalScroll,
  legalPortal,
  nestedHardClip,
  partiallyVisibleInLegalScroll,
  undeclaredHorizontalScroll,
  visibleTextOverflow,
  wrappedToolbarLabel,
} from './fixtures/geometry-snapshots.mjs';

const box = (left, top, width, height) => ({
  left,
  top,
  right: left + width,
  bottom: top + height,
  width,
  height,
});

const renderedNode = (overrides = {}) => ({
  id: 'root',
  parentId: null,
  schemaId: 'page',
  componentType: 'FormPage',
  rect: box(0, 0, 300, 200),
  visible: true,
  overflowX: 'visible',
  overflowY: 'visible',
  clientWidth: 300,
  clientHeight: 200,
  scrollWidth: 300,
  scrollHeight: 200,
  scrollEndReachable: true,
  isText: false,
  lineCount: 0,
  expectSingleLine: false,
  allowTruncation: false,
  interactive: false,
  hitTest: true,
  scrollOwner: null,
  scrollAxes: [],
  overlayOwner: null,
  overlayBoundary: null,
  ...overrides,
});

const ownershipTree = [
  { id: 'page', parentId: null, type: 'FormPage', title: 'Page' },
  { id: 'section', parentId: 'page', type: 'Section', title: 'Section' },
  { id: 'field', parentId: 'section', type: 'Button', title: 'Field' },
];

const contract = JSON.parse(await readFile(new URL('../design/visual-contract.json', import.meta.url), 'utf8'));
const withCompleteCoverage = (snapshot) => ({
  ...snapshot,
  coverage: {
    discoveredNodes: snapshot.nodes.length,
    expectedScannedNodes: snapshot.nodes.length,
    scannedNodes: snapshot.nodes.length,
    excludedNodes: 0,
    exclusionReasons: {},
  },
});
const audit = (snapshot) => auditGeometrySnapshot(withCompleteCoverage(snapshot), contract);
const rules = (snapshot) => audit(snapshot).findings.map((finding) => finding.rule);

test('a hard clipping ancestor fails the nested component subtree', () => {
  const result = audit(nestedHardClip);

  assert.ok(result.findings.some((finding) => finding.rule === 'ELEMENT_CLIPPED' && finding.schemaId === 'field'));
  assert.equal(result.components.field.status, 'FAIL');
  assert.equal(result.components.section.status, 'FAIL');
  assert.equal(result.components.page.status, 'FAIL');
});

test('a declared scroll owner keeps reachable nested content valid', () => {
  const result = audit(legalHorizontalScroll);

  assert.equal(result.status, 'PASS');
  assert.deepEqual(result.findings, []);
});

test('a partially visible target in reachable scrolling is deferred to scroll-state interaction checks', () => {
  const result = audit(partiallyVisibleInLegalScroll);

  assert.equal(result.status, 'PASS');
  assert.deepEqual(result.findings, []);
});

test('visible font overflow is not treated as clipped or as an undeclared scroller', () => {
  const result = audit(visibleTextOverflow);

  assert.equal(result.status, 'PASS');
  assert.deepEqual(result.findings, []);
});

test('explicit truncation policy suppresses overflow findings for supporting text', () => {
  const result = audit(intentionalTruncation);

  assert.equal(result.status, 'PASS');
  assert.deepEqual(result.findings, []);
});

test('overflow on an undeclared axis is a blocking finding', () => {
  assert.ok(rules(undeclaredHorizontalScroll).includes('UNDECLARED_SCROLL_X'));
});

test('a short toolbar label wrapping by character is rejected', () => {
  assert.ok(rules(wrappedToolbarLabel).includes('LABEL_WRAPPED'));
});

test('an interactive target blocked at all safe hit points is rejected', () => {
  assert.ok(rules(blockedHitTarget).includes('HIT_TARGET_BLOCKED'));
});

test('portal content uses its overlay boundary instead of a clipped DOM parent', () => {
  const result = audit(legalPortal);

  assert.equal(result.status, 'PASS');
  assert.deepEqual(result.findings, []);
});

test('CSS breakpoint neighbors are mandatory viewport samples', () => {
  const css = '@media (max-width: 1320px) {} @media (min-width: 481px) and (max-width: 700px) {}';
  assert.deepEqual(extractCssBreakpoints(css), [481, 700, 1320]);

  const widths = buildViewportMatrix(contract, css).map((viewport) => viewport.width);
  for (const width of [480, 481, 482, 699, 700, 701, 1319, 1320, 1321]) {
    assert.ok(widths.includes(width), `missing breakpoint sample ${width}`);
  }
});

test('gate status fails closed when evidence is missing or blocking findings remain', () => {
  assert.equal(deriveGateStatus({ mechanical: null, interaction: 'PASS', visual: 'PASS' }), 'BLOCKED');
  assert.equal(deriveGateStatus({ mechanical: 'FAIL', interaction: 'PASS', visual: 'PASS' }), 'FAIL');
  assert.equal(deriveGateStatus({ mechanical: 'PASS', interaction: 'PASS', visual: 'PASS' }), 'PASS');
});

test('a truncated DOM snapshot fails closed with coverage evidence', () => {
  const result = auditGeometrySnapshot({
    viewport: { width: 300, height: 200 },
    schemaTree: ownershipTree,
    nodes: [renderedNode()],
    truncated: true,
    coverage: {
      discoveredNodes: 2,
      expectedScannedNodes: 2,
      scannedNodes: 1,
      excludedNodes: 0,
      exclusionReasons: {},
    },
  }, contract);

  assert.equal(result.status, 'FAIL');
  assert.ok(result.findings.some((finding) => finding.rule === 'AUDIT_COVERAGE_INCOMPLETE'
    && /node limit/i.test(JSON.stringify(finding.actual))));
  assert.equal(result.metrics.coverage.truncated, true);
});

test('hard clipping boundaries remain intersected with the viewport for every descendant', () => {
  const result = auditGeometrySnapshot({
    viewport: { width: 300, height: 200 },
    schemaTree: ownershipTree,
    nodes: [
      renderedNode(),
      renderedNode({ id: 'clip', parentId: 'root', schemaId: 'section', rect: box(250, 20, 100, 80), clientWidth: 100, clientHeight: 80, scrollWidth: 100, scrollHeight: 80, overflowX: 'hidden', overflowY: 'hidden' }),
      renderedNode({ id: 'field', parentId: 'clip', schemaId: 'field', rect: box(320, 30, 20, 20), clientWidth: 20, clientHeight: 20, scrollWidth: 20, scrollHeight: 20 }),
    ],
  }, contract);

  assert.ok(result.findings.some((finding) => finding.schemaId === 'field' && finding.rule === 'ELEMENT_OFFSCREEN'));
  assert.equal(result.components.field.status, 'FAIL');
});

test('overlay boundaries cannot authorize content outside the viewport', () => {
  const result = auditGeometrySnapshot({
    viewport: { width: 300, height: 200 },
    schemaTree: ownershipTree,
    nodes: [
      renderedNode(),
      renderedNode({ id: 'portal', parentId: 'root', schemaId: 'field', componentType: 'Popover', rect: box(320, 20, 40, 40), clientWidth: 40, clientHeight: 40, scrollWidth: 40, scrollHeight: 40, overlayOwner: 'field', overlayBoundary: box(300, 0, 200, 200) }),
    ],
  }, contract);

  assert.ok(result.findings.some((finding) => finding.schemaId === 'field' && finding.rule === 'ELEMENT_OFFSCREEN'));
  assert.equal(result.components.field.status, 'FAIL');
});

test('overlay findings are attributed to the declared logical owner', () => {
  const result = auditGeometrySnapshot(withCompleteCoverage({
    viewport: { width: 300, height: 200 },
    schemaTree: ownershipTree,
    nodes: [
      renderedNode(),
      renderedNode({ id: 'portal', parentId: 'root', schemaId: 'section', componentType: 'Popover', rect: box(320, 20, 40, 40), clientWidth: 40, clientHeight: 40, scrollWidth: 40, scrollHeight: 40, overlayOwner: 'field', overlayBoundary: box(0, 0, 300, 200) }),
    ],
  }), contract);

  assert.ok(result.findings.some((finding) => finding.rule === 'ELEMENT_OFFSCREEN' && finding.schemaId === 'field'));
  assert.equal(result.components.field.status, 'FAIL');
});

test('invalid Schema ownership trees fail on duplicate ids, missing parents and cycles', () => {
  const invalidTrees = [
    [...ownershipTree, { id: 'field', parentId: 'page', type: 'TextField', title: 'Duplicate' }],
    [{ id: 'page', parentId: 'missing', type: 'FormPage', title: 'Page' }],
    [
      { id: 'page', parentId: 'field', type: 'FormPage', title: 'Page' },
      { id: 'field', parentId: 'page', type: 'Button', title: 'Field' },
    ],
  ];

  for (const schemaTree of invalidTrees) {
    const result = auditGeometrySnapshot({ viewport: { width: 300, height: 200 }, schemaTree, nodes: [renderedNode()] }, contract);
    assert.equal(result.status, 'FAIL');
    assert.ok(result.findings.some((finding) => finding.rule === 'AUDIT_TREE_INVALID'));
  }
});

test('audit fails closed when traversal coverage evidence is absent', () => {
  const result = auditGeometrySnapshot(legalHorizontalScroll, contract);

  assert.equal(result.status, 'FAIL');
  assert.ok(result.findings.some((finding) => finding.rule === 'AUDIT_COVERAGE_INCOMPLETE'));
});

test('audit fails closed when the collector reaches its node limit', () => {
  const snapshot = withCompleteCoverage(legalHorizontalScroll);
  snapshot.truncated = true;
  snapshot.coverage.discoveredNodes += 1;
  snapshot.coverage.expectedScannedNodes += 1;

  const result = auditGeometrySnapshot(snapshot, contract);

  assert.equal(result.status, 'FAIL');
  assert.ok(result.findings.some((finding) => finding.rule === 'AUDIT_COVERAGE_INCOMPLETE'));
});

test('audit fails closed when excluded nodes lack complete reason counts', () => {
  const snapshot = withCompleteCoverage(legalHorizontalScroll);
  snapshot.coverage.discoveredNodes += 1;
  snapshot.coverage.excludedNodes = 1;

  const result = auditGeometrySnapshot(snapshot, contract);

  assert.equal(result.status, 'FAIL');
  assert.ok(result.findings.some((finding) => finding.rule === 'AUDIT_COVERAGE_INCOMPLETE'));
});

test('audit exposes internally consistent traversal coverage in its metrics', () => {
  const snapshot = withCompleteCoverage(legalHorizontalScroll);
  const result = auditGeometrySnapshot(snapshot, contract);

  assert.deepEqual(result.metrics.coverage, { ...snapshot.coverage, truncated: false });
});
