import test from 'node:test';
import assert from 'node:assert/strict';
import {
  runtimeActionEventName,
  runtimeActionPayload,
} from '../prototype/component-runtime-events.mjs';

test('value, selection, configuration and file actions use change events', () => {
  for (const action of ['set-value', 'select', 'set-config', 'add-file']) {
    assert.equal(runtimeActionEventName(action), 'change');
  }
  assert.equal(runtimeActionEventName('expand'), 'click');
});

test('column inputs use change while structural column commands use click', () => {
  for (const action of ['rename-column', 'set-column-type', 'set-column-visible']) assert.equal(runtimeActionEventName(action), 'change');
  for (const action of ['add-column', 'remove-column', 'move-column-left', 'move-column-right']) assert.equal(runtimeActionEventName(action), 'click');
});

test('column action payload carries the edited column identity and value', () => {
  const input = { dataset: { runtimeColumn: 'amount', runtimeAction: 'rename-column' }, value: '含税金额', checked: true };
  assert.deepEqual(runtimeActionPayload(input), { columnId: 'amount', title: '含税金额' });
  input.dataset.runtimeAction = 'set-column-type';
  input.value = 'money';
  assert.deepEqual(runtimeActionPayload(input), { columnId: 'amount', type: 'money' });
  input.dataset.runtimeAction = 'set-column-visible';
  input.checked = false;
  assert.deepEqual(runtimeActionPayload(input), { columnId: 'amount', visible: false });
});

test('runtime action payload reads live form values and component metadata', () => {
  assert.deepEqual(runtimeActionPayload({
    dataset: { runtimeAction: 'set-value' },
    value: 'new value',
  }), { value: 'new value' });
  assert.deepEqual(runtimeActionPayload({
    dataset: { runtimeAction: 'set-config', runtimeConfig: 'required' },
    type: 'checkbox',
    checked: true,
  }), { key: 'required', value: true });
  assert.deepEqual(runtimeActionPayload({
    dataset: { runtimeAction: 'add-file' },
    files: [{ name: 'contract.pdf', size: 42 }],
  }), { file: { name: 'contract.pdf', size: 42 } });
  assert.deepEqual(runtimeActionPayload({
    dataset: { runtimeAction: 'expand', runtimeKey: 'root' },
  }), { key: 'root' });
});
