import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

const html = await readFile(new URL('../prototype/index.html', import.meta.url), 'utf8');
const app = await readFile(new URL('../prototype/app.js', import.meta.url), 'utf8');
const styles = await readFile(new URL('../prototype/styles.css', import.meta.url), 'utf8');
const runtime = await readFile(new URL('../prototype/quality-gate-runtime.mjs', import.meta.url), 'utf8');
const audit = await readFile(new URL('../prototype/geometry-audit.mjs', import.meta.url), 'utf8');
const visualContract = JSON.parse(await readFile(new URL('../design/visual-contract.json', import.meta.url), 'utf8'));
const browserEntry = await readFile(new URL('./geometry-check.js', import.meta.url), 'utf8');

test('workbench and business components expose stable audit ownership', () => {
  assert.match(html, /data-ui-component="app-shell"/);
  assert.match(html, /data-ui-component="canvas-toolbar"/);
  assert.match(html, /data-schema-id="page"[^>]*data-component-type="FormPage"/);
  assert.match(html, /data-schema-id="entries"[^>]*data-component-type="EntryGrid"/);
});

test('all intentional scroll and overlay boundaries declare their ownership', () => {
  assert.match(html, /data-scroll-owner="canvas-scroll"[^>]*data-scroll-axes="x,y"/);
  assert.match(html, /data-scroll-owner="entry-table-wrap"[^>]*data-scroll-axes="x"/);
  assert.match(html, /data-overlay-owner="app-shell"/);
  assert.deepEqual(visualContract.declaredScrollOwners['preview-surface'], ['x', 'y']);
  assert.deepEqual(visualContract.declaredScrollOwners['publish-content'], ['y']);
  assert.match(runtime, /MutationObserver/);
  assert.match(runtime, /quality-gate-json/);
  assert.match(runtime, /addEventListener\('scroll'/);
  assert.match(audit, /export function buildAuditMatrix/);
  assert.match(audit, /export async function runQualityGateMatrix/);
  assert.match(audit, /aria-modal="true"/);
  assert.doesNotMatch(audit, /element\.scrollLeft\s*=/);
  assert.doesNotMatch(audit, /element\.scrollTop\s*=/);
});

test('dynamic Schema markup preserves Schema and component identity', () => {
  assert.match(app, /data-schema-id="\$\{node\.id\}"/);
  assert.match(app, /data-component-type="\$\{node\.type\}"/);
});

test('browser geometry entry delegates to the recursive audit module', () => {
  assert.match(browserEntry, /enterpriseQualityGate/);
  assert.match(browserEntry, /quality gate runtime unavailable/);
  assert.doesNotMatch(browserEntry, /regions\.every/);
});

test('the page preloads a read-only quality gate runtime for browser verification', () => {
  assert.match(html, /quality-gate-runtime\.mjs/);
  assert.match(html, /data-testid="quality-gate-json"/);
  assert.match(runtime, /auditCurrentDocument/);
  assert.match(runtime, /window\.enterpriseQualityGate/);
  assert.match(runtime, /addEventListener\('resize'/);
  assert.match(runtime, /afterStableFrame/);
});

test('responsive layout has explicit compact-desktop and two-row toolbar modes', () => {
  assert.match(styles, /@media\s*\(min-width:\s*701px\)\s*and\s*\(max-width:\s*1079px\)/);
  assert.match(styles, /@media\s*\(min-width:\s*1080px\)\s*and\s*\(max-width:\s*1500px\)/);
  assert.match(styles, /grid-template-rows:\s*repeat\(2,\s*1fr\)/);
});

test('palette and inspector use shrinkable grid tracks instead of clipped fixed calculations', () => {
  assert.match(styles, /\.component-palette[^}]*grid-template-columns:\s*minmax\(0,\s*1fr\)/s);
  assert.match(styles, /\.property-inspector[^}]*grid-template-rows:[^}]*minmax\(0,\s*1fr\)/s);
  assert.match(styles, /\.inspector-body[^}]*height:\s*auto/s);
});

test('reference values shrink independently from their fixed trailing affordance', () => {
  assert.match(app, /class="field-control-value"[^>]*data-allow-truncation="true"/);
  assert.match(styles, /\.field-control-value[^}]*min-width:\s*0[^}]*text-overflow:\s*ellipsis/s);
  assert.match(styles, /\.field-control\s*>\s*b[^}]*flex:\s*0\s+0\s+auto/s);
});
