import test from 'node:test';
import assert from 'node:assert/strict';
import {
  analyzeRuleDependencies,
  createRuleBuilderState,
  executeRuleBuilderCommand,
  selectedRule,
} from '../prototype/rule-builder-state.mjs';

const baseRule = {
  id: 'R-001',
  title: '客户变更带出信用信息',
  kind: 'ui',
  enabled: true,
  trigger: { event: 'change', source: 'customer' },
  conditionGroup: {
    logic: 'all',
    conditions: [{ id: 'C-001', field: 'customer', operator: 'notEmpty', value: null }],
  },
  actions: [{ id: 'A-001', type: 'setValue', target: 'creditLimit', value: 50000 }],
};

test('rule authoring keeps trigger, nested conditions and ordered actions in authoritative state', () => {
  let state = createRuleBuilderState({ rules: [baseRule] });
  state = executeRuleBuilderCommand(state, 'set-trigger', { event: 'blur', source: 'customer' });
  state = executeRuleBuilderCommand(state, 'add-condition', {
    parentGroupId: 'root',
    condition: { id: 'C-002', field: 'amount', operator: 'greaterThan', value: 10000 },
  });
  state = executeRuleBuilderCommand(state, 'add-condition-group', {
    parentGroupId: 'root', group: { id: 'G-002', logic: 'any' },
  });
  state = executeRuleBuilderCommand(state, 'add-condition', {
    parentGroupId: 'G-002',
    condition: { id: 'C-003', field: 'status', operator: 'equals', value: 'draft' },
  });
  state = executeRuleBuilderCommand(state, 'add-action', {
    action: { id: 'A-002', type: 'message', target: 'form', value: '信用额度已刷新' },
  });

  const rule = selectedRule(state);
  assert.deepEqual(rule.trigger, { event: 'blur', source: 'customer' });
  assert.equal(rule.conditionGroup.conditions.length, 3);
  assert.equal(rule.conditionGroup.conditions[2].conditions[0].id, 'C-003');
  assert.deepEqual(rule.actions.map((action) => action.id), ['A-001', 'A-002']);
});

test('rule execution evaluates condition tree and exposes trace plus visible effects', () => {
  let state = createRuleBuilderState({ rules: [baseRule] });
  state = executeRuleBuilderCommand(state, 'set-sample-value', { field: 'customer', value: 'CUST-01' });
  state = executeRuleBuilderCommand(state, 'run-rule');

  assert.equal(state.lastRun.status, 'matched');
  assert.equal(state.lastRun.ruleId, 'R-001');
  assert.equal(state.lastRun.trace[0].conditionId, 'C-001');
  assert.deepEqual(state.lastRun.effects.creditLimit, 50000);

  state = executeRuleBuilderCommand(state, 'set-sample-value', { field: 'customer', value: '' });
  state = executeRuleBuilderCommand(state, 'run-rule');
  assert.equal(state.lastRun.status, 'not-matched');
  assert.deepEqual(state.lastRun.effects, {});
});

test('invalid authoring payloads fail closed and preserve the previous object', () => {
  const state = createRuleBuilderState({ rules: [baseRule] });
  assert.equal(executeRuleBuilderCommand(state, 'select-rule', { ruleId: 'missing' }), state);
  assert.equal(executeRuleBuilderCommand(state, 'set-trigger', { event: 'arbitrary-js' }), state);
  assert.equal(executeRuleBuilderCommand(state, 'add-condition', {
    parentGroupId: 'missing', condition: { field: 'amount', operator: 'equals', value: 1 },
  }), state);
  assert.equal(executeRuleBuilderCommand(state, 'add-action', {
    action: { type: 'eval', target: 'window', value: 'alert(1)' },
  }), state);
});

test('dependency analysis reports a concrete cycle and otherwise returns execution order', () => {
  const acyclic = analyzeRuleDependencies([
    { ...baseRule, id: 'R-001', dependsOn: [] },
    { ...baseRule, id: 'R-002', dependsOn: ['R-001'] },
    { ...baseRule, id: 'R-003', dependsOn: ['R-002'] },
  ]);
  assert.equal(acyclic.hasCycle, false);
  assert.deepEqual(acyclic.executionOrder, ['R-001', 'R-002', 'R-003']);

  const cyclic = analyzeRuleDependencies([
    { ...baseRule, id: 'R-001', dependsOn: ['R-003'] },
    { ...baseRule, id: 'R-002', dependsOn: ['R-001'] },
    { ...baseRule, id: 'R-003', dependsOn: ['R-002'] },
  ]);
  assert.equal(cyclic.hasCycle, true);
  assert.deepEqual(new Set(cyclic.cycle), new Set(['R-001', 'R-002', 'R-003']));
});

test('duplicate and removal commands maintain a selectable rule catalogue', () => {
  let state = createRuleBuilderState({ rules: [baseRule] });
  state = executeRuleBuilderCommand(state, 'duplicate-rule');
  assert.equal(state.rules.length, 2);
  assert.equal(state.selectedRuleId, 'R-001-COPY-1');
  assert.equal(selectedRule(state).title, '客户变更带出信用信息（副本）');

  state = executeRuleBuilderCommand(state, 'remove-rule');
  assert.equal(state.rules.length, 1);
  assert.equal(state.selectedRuleId, 'R-001');
});
