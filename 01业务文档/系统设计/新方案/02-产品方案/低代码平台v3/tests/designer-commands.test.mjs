import test from 'node:test';
import assert from 'node:assert/strict';
import {
  createCommandState,
  executeDesignerCommand,
  visibleRules,
} from '../prototype/designer-commands.mjs';

test('panel commands toggle independently', () => {
  let state = createCommandState();
  state = executeDesignerCommand(state, 'settings');
  state = executeDesignerCommand(state, 'collapse-left');
  state = executeDesignerCommand(state, 'collapse-analysis');
  state = executeDesignerCommand(state, 'toggle-property-section', { sectionId: 'layout' });
  assert.equal(state.settingsOpen, true);
  assert.equal(state.leftPanelCollapsed, true);
  assert.equal(state.analysisCollapsed, true);
  assert.equal(state.propertySections.layout, true);
});

test('designer settings update autosave and default device explicitly', () => {
  let state = createCommandState();
  state = executeDesignerCommand(state, 'set-auto-save', { enabled: false });
  state = executeDesignerCommand(state, 'set-default-device', { device: 'tablet' });
  assert.equal(state.autoSave, false);
  assert.equal(state.defaultDevice, 'tablet');
  assert.equal(executeDesignerCommand(state, 'set-default-device', { device: 'watch' }), state);
});

test('rule commands create, select and filter rules', () => {
  let state = createCommandState({
    rules: [
      { id: 'R-001', kind: 'ui' },
      { id: 'R-002', kind: 'business' },
    ],
  });
  state = executeDesignerCommand(state, 'filter-rules', { filter: 'business' });
  assert.deepEqual(visibleRules(state).map((rule) => rule.id), ['R-002']);
  state = executeDesignerCommand(state, 'select-rule', { ruleId: 'R-002' });
  state = executeDesignerCommand(state, 'add-rule');
  assert.equal(state.rules.length, 3);
  assert.equal(state.selectedRuleId, 'R-NEW-3');
});

test('runtime and entry commands change actual data', () => {
  let state = createCommandState();
  state = executeDesignerCommand(state, 'select-page-tab', { tab: 'delivery' });
  state = executeDesignerCommand(state, 'save-draft');
  state = executeDesignerCommand(state, 'submit-runtime');
  state = executeDesignerCommand(state, 'add-entry-row', { row: { id: 'ROW-1', values: { qty: 1 } } });
  state = executeDesignerCommand(state, 'batch-fill', { values: { warehouse: 'W-01' } });
  assert.equal(state.activePageTab, 'delivery');
  assert.equal(state.draftSaved, true);
  assert.equal(state.submitted, true);
  assert.deepEqual(state.entryRows[0].values, { qty: 1, warehouse: 'W-01' });
});

test('evidence commands retain target and derive candidate version', () => {
  let state = createCommandState({ currentVersion: 41 });
  state = executeDesignerCommand(state, 'view-difference', { differenceId: 'D-007' });
  state = executeDesignerCommand(state, 'locate-finding', { findingId: 'F-002' });
  state = executeDesignerCommand(state, 'create-release');
  assert.equal(state.activeDifferenceId, 'D-007');
  assert.equal(state.locatedFindingId, 'F-002');
  assert.equal(state.candidateVersion, 42);
});

test('invalid command payloads do not mutate state', () => {
  const state = createCommandState();
  assert.equal(executeDesignerCommand(state, 'filter-rules', { filter: 'unknown' }), state);
  assert.equal(executeDesignerCommand(state, 'select-page-tab', { tab: 'unknown' }), state);
  assert.equal(executeDesignerCommand(state, 'locate-finding'), state);
});

test('permission finding can close only after a complete policy is stored', () => {
  const state = createCommandState();
  const rejected = executeDesignerCommand(state, 'set-permission-policy', { fieldId: 'creditLimit' });
  assert.equal(rejected, state);
  const next = executeDesignerCommand(state, 'set-permission-policy', {
    fieldId: 'creditLimit', roleId: 'SalesManager', export: 'allow',
  });
  assert.deepEqual(next.permissionPolicies.creditLimit.SalesManager, { export: 'allow' });
});
