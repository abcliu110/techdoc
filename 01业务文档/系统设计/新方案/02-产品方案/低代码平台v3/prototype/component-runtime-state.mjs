const PERMISSIONS = new Set(['allow', 'readonly', 'hidden']);

export function createComponentRuntimeState(manifest) {
  if (!manifest?.type) throw new TypeError('A component manifest is required');
  return Object.freeze({
    componentType: manifest.type,
    category: manifest.category,
    value: '',
    selected: [],
    rows: [{ id: 'ROW-1', name: '示例数据', quantity: 1 }],
    files: [],
    comments: [],
    page: 1,
    playing: false,
    expanded: [],
    activeKey: 'item-1',
    commandCount: 0,
    refreshCount: 0,
    error: manifest.status === 'planned' ? 'component-planned' : null,
    recovered: false,
    permission: 'allow',
    config: { label: manifest.title, required: false, binding: manifest.dataBinding === 'none' ? '' : `${manifest.type}.value`, pageSize: 20, selectionMode: 'single', dataSource: 'sample-data', sandbox: true },
  });
}

export function executeComponentRuntimeAction(state, action, payload = {}) {
  switch (action) {
    case 'set-value': return { ...state, value: payload.value ?? '' };
    case 'select': return { ...state, selected: payload.values ? [...payload.values] : payload.value ? [payload.value] : [] };
    case 'toggle': return { ...state, value: !Boolean(state.value) };
    case 'add-row': {
      const next = state.rows.length + 1;
      return { ...state, rows: [...state.rows, { id: `ROW-${next}`, name: `新增数据 ${next}`, quantity: 1 }] };
    }
    case 'remove-row': return { ...state, rows: state.rows.filter((row) => row.id !== payload.rowId) };
    case 'expand': return { ...state, expanded: state.expanded.includes(payload.key) ? state.expanded.filter((key) => key !== payload.key) : [...state.expanded, payload.key] };
    case 'select-node': return { ...state, activeKey: payload.key || state.activeKey };
    case 'trigger-command': return { ...state, commandCount: state.commandCount + 1 };
    case 'retry': return { ...state, error: null, recovered: true };
    case 'set-error': return { ...state, error: payload.error || 'runtime-error', recovered: false };
    case 'set-config': return { ...state, config: { ...state.config, [payload.key]: payload.value } };
    case 'set-permission': return PERMISSIONS.has(payload.permission) ? { ...state, permission: payload.permission } : state;
    case 'add-file': return payload.file ? { ...state, files: [...state.files, { name: payload.file.name || '未命名文件', size: payload.file.size || 0 }] } : state;
    case 'remove-file': return { ...state, files: state.files.filter((file) => file.name !== payload.name) };
    case 'next-page': return { ...state, page: state.page + 1 };
    case 'previous-page': return { ...state, page: Math.max(1, state.page - 1) };
    case 'toggle-play': return { ...state, playing: !state.playing };
    case 'add-comment': return { ...state, comments: [...state.comments, payload.value || `新评论 ${state.comments.length + 1}`] };
    case 'set-location': return { ...state, value: payload.value || '31.2304,121.4737' };
    case 'refresh': return { ...state, refreshCount: state.refreshCount + 1 };
    default: return state;
  }
}
