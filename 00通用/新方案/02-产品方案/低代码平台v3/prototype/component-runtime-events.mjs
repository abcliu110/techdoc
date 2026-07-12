const CHANGE_ACTIONS = new Set(['set-value', 'select', 'set-config', 'add-file']);

export function runtimeActionEventName(action) {
  return CHANGE_ACTIONS.has(action) ? 'change' : 'click';
}

export function runtimeActionPayload(control) {
  const action = control.dataset.runtimeAction;
  if (action === 'set-value' || action === 'select') return { value: control.dataset.runtimeValue ?? control.value };
  if (action === 'set-config') return { key: control.dataset.runtimeConfig, value: control.type === 'checkbox' ? control.checked : control.value };
  if (action === 'add-file') return { file: control.files?.[0] };
  if (action === 'remove-file') return { name: control.dataset.runtimeFile };
  if (action === 'remove-row') return { rowId: control.dataset.runtimeRow };
  if (action === 'expand' || action === 'select-node') return { key: control.dataset.runtimeKey };
  if (action === 'set-permission') return { permission: control.dataset.runtimePermission };
  return {};
}

