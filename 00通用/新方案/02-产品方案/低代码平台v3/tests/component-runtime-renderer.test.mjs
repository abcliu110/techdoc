import test from 'node:test';
import assert from 'node:assert/strict';
import { COMPONENT_MANIFESTS } from '../prototype/component-registry.mjs';
import { renderInteractiveComponent } from '../prototype/component-runtime-renderer.mjs';
import { createComponentRuntimeState } from '../prototype/component-runtime-state.mjs';

const representativeTypes = [
  'TextField', 'ReferencePicker', 'EntryGrid', 'Tree', 'Image',
  'ActionBar', 'Chart', 'Iframe', 'Tabs',
];

test('every component family renders a real interactive runtime surface', () => {
  for (const type of representativeTypes) {
    const manifest = COMPONENT_MANIFESTS.find((item) => item.type === type);
    const html = renderInteractiveComponent(manifest, 'runtime', createComponentRuntimeState(manifest));
    assert.match(html, new RegExp(`data-runtime-component=["']${type}["']`));
    assert.match(html, /data-runtime-action=/);
    assert.doesNotMatch(html, />Label<|>Binding<|>Feedback</);
  }
});

test('configuration, failure and permission states expose executable controls', () => {
  const manifest = COMPONENT_MANIFESTS.find((item) => item.type === 'TextField');
  const state = createComponentRuntimeState(manifest);
  assert.match(renderInteractiveComponent(manifest, 'configure', state), /data-runtime-action="set-config"/);
  assert.match(renderInteractiveComponent(manifest, 'failure', state), /data-runtime-action="retry"/);
  assert.match(renderInteractiveComponent(manifest, 'permission', state), /data-runtime-action="set-permission"/);
});

test('complex component configuration projects its contract-specific controls', () => {
  const grid = COMPONENT_MANIFESTS.find((item) => item.type === 'TreeGrid');
  const extension = COMPONENT_MANIFESTS.find((item) => item.type === 'Iframe');
  const gridHtml = renderInteractiveComponent(grid, 'configure', createComponentRuntimeState(grid));
  const extensionHtml = renderInteractiveComponent(extension, 'configure', createComponentRuntimeState(extension));
  assert.match(gridHtml, /data-runtime-config="dataSource"/);
  assert.match(gridHtml, /data-runtime-config="pageSize"/);
  assert.match(extensionHtml, /data-runtime-config="sandbox"/);
});

test('planned components remain explicit and non-interactive', () => {
  const manifest = COMPONENT_MANIFESTS.find((item) => item.status === 'planned');
  const html = renderInteractiveComponent(manifest, 'runtime', createComponentRuntimeState(manifest));
  assert.match(html, /data-runtime-disabled="true"/);
  assert.doesNotMatch(html, /data-runtime-action=/);
});

test('all required components render at least one action declared by their runtime contract', async () => {
  const { getRuntimeContract } = await import('../prototype/component-runtime-contracts.mjs');
  for (const manifest of COMPONENT_MANIFESTS.filter((item) => item.status !== 'planned')) {
    const state = createComponentRuntimeState(manifest);
    const html = renderInteractiveComponent(manifest, 'runtime', state);
    const contract = getRuntimeContract(manifest);
    assert.ok(contract.actions.length > 0, manifest.type);
    for (const action of contract.actions) {
      assert.ok(html.includes(`data-runtime-action="${action}"`), `${manifest.type} must render declared action ${action}`);
    }
  }
});

test('data component renderer consumes the column model in design and runtime states', () => {
  const manifest = COMPONENT_MANIFESTS.find((item) => item.type === 'EntryGrid');
  let state = createComponentRuntimeState(manifest);
  state = executeComponentRuntimeAction(state, 'rename-column', { columnId: 'name', title: '物料名称' });
  state = executeComponentRuntimeAction(state, 'set-column-visible', { columnId: 'quantity', visible: false });
  const design = renderInteractiveComponent(manifest, 'design', state);
  const runtime = renderInteractiveComponent(manifest, 'runtime', state);
  assert.match(design, /data-runtime-action="add-column"/);
  assert.match(design, /data-runtime-action="rename-column"/);
  assert.match(design, /data-runtime-action="move-column-left"/);
  assert.match(design, /data-runtime-action="move-column-right"/);
  assert.match(design, /data-runtime-action="set-column-visible"/);
  assert.match(design, /物料名称/);
  assert.match(runtime, /物料名称/);
  assert.doesNotMatch(runtime, />数量</);
});

test('selection and layout state remain visibly projected after a runtime action', () => {
  const select = COMPONENT_MANIFESTS.find((item) => item.type === 'Select');
  const selectedState = { ...createComponentRuntimeState(select), selected: ['B'] };
  assert.match(renderInteractiveComponent(select, 'runtime', selectedState), /option value="B" selected/);

  const tabs = COMPONENT_MANIFESTS.find((item) => item.type === 'Tabs');
  const activeState = { ...createComponentRuntimeState(tabs), activeKey: 'item-2' };
  assert.match(renderInteractiveComponent(tabs, 'runtime', activeState), /区域 B \(当前\)/);
});
