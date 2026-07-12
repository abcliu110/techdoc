const RULE_FILTERS = new Set(['all', 'ui', 'business']);
const PAGE_TABS = new Set(['basic', 'delivery', 'attachments']);

export function createCommandState(overrides = {}) {
  return {
    settingsOpen: false,
    autoSave: true,
    defaultDevice: 'desktop',
    leftPanelCollapsed: false,
    analysisCollapsed: false,
    propertySections: {},
    ruleFilter: 'all',
    selectedRuleId: 'R-001',
    rules: [],
    activePageTab: 'basic',
    draftSaved: false,
    submitted: false,
    entryRows: [],
    columnSettingsOpen: false,
    activeDifferenceId: null,
    locatedFindingId: null,
    currentVersion: 18,
    candidateVersion: null,
    permissionPolicies: {},
    ...overrides,
  };
}

export function executeDesignerCommand(state, command, payload = {}) {
  switch (command) {
    case 'settings':
      return { ...state, settingsOpen: !state.settingsOpen };
    case 'set-auto-save':
      return typeof payload.enabled === 'boolean' ? { ...state, autoSave: payload.enabled } : state;
    case 'set-default-device':
      return ['desktop', 'tablet', 'mobile'].includes(payload.device) ? { ...state, defaultDevice: payload.device } : state;
    case 'collapse-left':
      return { ...state, leftPanelCollapsed: !state.leftPanelCollapsed };
    case 'collapse-analysis':
      return { ...state, analysisCollapsed: !state.analysisCollapsed };
    case 'toggle-property-section': {
      if (!payload.sectionId) return state;
      return {
        ...state,
        propertySections: {
          ...state.propertySections,
          [payload.sectionId]: !state.propertySections[payload.sectionId],
        },
      };
    }
    case 'filter-rules':
      return RULE_FILTERS.has(payload.filter) ? { ...state, ruleFilter: payload.filter } : state;
    case 'select-rule':
      return payload.ruleId ? { ...state, selectedRuleId: payload.ruleId } : state;
    case 'add-rule': {
      const nextNumber = state.rules.length + 1;
      const rule = payload.rule || { id: `R-NEW-${nextNumber}`, title: `新规则 ${nextNumber}`, enabled: false };
      return { ...state, rules: [...state.rules, rule], selectedRuleId: rule.id };
    }
    case 'select-page-tab':
      return PAGE_TABS.has(payload.tab) ? { ...state, activePageTab: payload.tab } : state;
    case 'save-draft':
      return { ...state, draftSaved: true };
    case 'submit-runtime':
      return { ...state, submitted: true };
    case 'add-entry-row': {
      const row = payload.row || { id: `ROW-${state.entryRows.length + 1}`, values: {} };
      return { ...state, entryRows: [...state.entryRows, row] };
    }
    case 'batch-fill': {
      if (!payload.values || typeof payload.values !== 'object') return state;
      return {
        ...state,
        entryRows: state.entryRows.map((row) => ({
          ...row,
          values: { ...row.values, ...payload.values },
        })),
      };
    }
    case 'column-settings':
      return { ...state, columnSettingsOpen: !state.columnSettingsOpen };
    case 'view-difference':
      return payload.differenceId ? { ...state, activeDifferenceId: payload.differenceId } : state;
    case 'locate-finding':
      return payload.findingId ? { ...state, locatedFindingId: payload.findingId } : state;
    case 'set-permission-policy': {
      if (!payload.fieldId || !payload.roleId || !['allow', 'deny'].includes(payload.export)) return state;
      return {
        ...state,
        permissionPolicies: {
          ...state.permissionPolicies,
          [payload.fieldId]: {
            ...(state.permissionPolicies[payload.fieldId] || {}),
            [payload.roleId]: { export: payload.export },
          },
        },
      };
    }
    case 'create-release': {
      const version = Number.isInteger(state.currentVersion) ? state.currentVersion + 1 : 1;
      return { ...state, candidateVersion: version };
    }
    default:
      return state;
  }
}

export function visibleRules(state) {
  if (state.ruleFilter === 'all') return state.rules;
  return state.rules.filter((rule) => rule.kind === state.ruleFilter);
}
