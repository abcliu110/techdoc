import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const prototypeRoot = resolve(here, '../prototype');

test('prototype exposes stable workbench regions and test hooks', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');

  for (const hook of [
    'designer-root',
    'topbar',
    'workspace-nav',
    'resource-panel',
    'design-canvas',
    'property-inspector',
    'analysis-panel',
    'preview-dialog',
    'publish-dialog',
  ]) {
    assert.match(html, new RegExp(`data-testid=["']${hook}["']`));
  }
});

test('prototype keeps UI code native and references no remote runtime assets', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  assert.doesNotMatch(html, /https?:\/\//);
  assert.match(html, /styles\.css/);
  assert.match(html, /app\.js/);
});

test('clickable non-button canvas regions expose keyboard semantics', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  assert.match(html, /data-testid="field-entries"[^>]*role="button"[^>]*tabindex="0"/);
});

test('finding count exposes a stable hook for state synchronization', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  assert.match(html, /data-testid="finding-count"/);
});

test('prototype labels unmeasured runtime data and local persistence honestly', async () => {
  const html = await readFile(resolve(prototypeRoot, 'index.html'), 'utf8');
  const app = await readFile(resolve(prototypeRoot, 'app.js'), 'utf8');

  assert.match(html, /rel="icon" href="data:,"/);
  assert.doesNotMatch(app, /\d+\s*ms|交互性能评分|已写入设计服务/);
  assert.match(app, /未测量/);
  assert.match(app, /本地原型/);
});
