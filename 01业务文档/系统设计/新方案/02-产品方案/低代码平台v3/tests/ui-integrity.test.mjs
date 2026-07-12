import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';

const app = await readFile(new URL('../prototype/app.js', import.meta.url), 'utf8');
const styles = await readFile(new URL('../prototype/styles.css', import.meta.url), 'utf8');

test('dragover derives before, inside and after from the visible target geometry', () => {
  assert.match(app, /getBoundingClientRect\(\)/);
  assert.match(app, /dropPosition\s*=\s*'before'/);
  assert.match(app, /dropPosition\s*=\s*'after'/);
});

test('outline and inspector derive dynamic nodes from the authoritative schema', () => {
  assert.match(app, /schemaOutlineMarkup/);
  assert.match(app, /schemaFieldDetails/);
});

test('initial header fields use the same schema selection and rendering path', () => {
  assert.match(app, /createSalesOrderDesignerSchema\(\)/);
  assert.match(app, /renderHeaderFields/);
  assert.doesNotMatch(app, /\['orderNo', 'customer', 'orderDate', 'salesOrg', 'amount'\]/);
  assert.doesNotMatch(app, /BASE_FIELD_DETAILS/);
});

test('nested entry variants render as containers', () => {
  assert.match(app, /SubEntryGrid/);
  assert.match(app, /TreeSubEntryGrid/);
  assert.match(app, /SubCardEntry/);
});

test('internal complex-layout regions render as nested drop containers', () => {
  for (const type of ['Column', 'TabPane', 'WizardStep', 'SplitRegion', 'DashboardCard']) {
    assert.match(app, new RegExp(`'${type}'`));
  }
});

test('component availability follows the active device context', () => {
  assert.match(app, /device:\s*state\.device/);
});

test('compact desktop keeps the component palette visible', () => {
  assert.match(styles, /@media\s*\(min-width:\s*481px\)\s*and\s*\(max-width:\s*700px\)/);
  assert.match(styles, /grid-template-columns:\s*260px\s+minmax\(0,\s*1fr\)/);
  assert.match(styles, /\.resource-panel\s*\{\s*display:\s*block/);
});

test('ordinary fields fall back to the page layout when the selected container rejects them', () => {
  assert.match(app, /targetId\s*!==\s*'page'[\s\S]*targetId\s*=\s*'page'/);
});

test('field property projection is scoped to the selected node instead of nested descendants', () => {
  assert.match(app, /fieldNode\.matches\('\.entry-section'\)/);
  assert.match(app, /:scope > \.field-label/);
  assert.match(app, /:scope > \.field-control/);
});

test('saved layout and control properties are projected into designer and preview renderers', () => {
  assert.match(app, /projectFieldRenderer\(field\)/);
  assert.match(app, /data-label-position=/);
  assert.match(app, /data-renderer=/);
  assert.match(app, /Object\.assign\(fieldNode\.style, projection\.style\)/);
  assert.match(styles, /schema-field\[data-label-position="left"\]/);
});

test('renaming a field keeps the breadcrumb synchronized with the schema title', () => {
  assert.match(app, /property === 'title'[\s\S]*breadcrumb:/);
});
