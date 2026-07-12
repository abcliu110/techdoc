const EVENTS = new Set(['load', 'change', 'blur', 'submit', 'row-add', 'row-remove']);
const OPERATORS = new Set(['equals', 'notEquals', 'notEmpty', 'empty', 'greaterThan', 'lessThan', 'contains']);
const ACTIONS = new Set(['setValue', 'setVisible', 'setReadonly', 'setRequired', 'message', 'validate', 'refreshReference']);

const clone = (value) => globalThis.structuredClone
  ? globalThis.structuredClone(value)
  : JSON.parse(JSON.stringify(value));

function normalizeRule(rule, index) {
  return {
    id: rule.id || `R-${index + 1}`,
    title: rule.title || `规则 ${index + 1}`,
    kind: rule.kind === 'business' ? 'business' : 'ui',
    enabled: rule.enabled !== false,
    trigger: rule.trigger || { event: 'change', source: '' },
    conditionGroup: rule.conditionGroup || { id: 'root', logic: 'all', conditions: [] },
    actions: Array.isArray(rule.actions) ? rule.actions : [],
    dependsOn: Array.isArray(rule.dependsOn) ? rule.dependsOn : [],
  };
}

export function createRuleBuilderState(overrides = {}) {
  const rules = (overrides.rules || []).map(normalizeRule);
  return {
    rules,
    selectedRuleId: overrides.selectedRuleId || rules[0]?.id || null,
    sampleData: {},
    lastRun: null,
    ...overrides,
    rules,
  };
}

export function selectedRule(state) {
  return state.rules.find((rule) => rule.id === state.selectedRuleId) || null;
}

function updateSelectedRule(state, updater) {
  const index = state.rules.findIndex((rule) => rule.id === state.selectedRuleId);
  if (index < 0) return state;
  const nextRule = updater(clone(state.rules[index]));
  if (!nextRule) return state;
  const rules = state.rules.slice();
  rules[index] = nextRule;
  return { ...state, rules };
}

function findConditionGroup(group, id) {
  if (!group) return null;
  if ((group.id || 'root') === id) return group;
  for (const item of group.conditions || []) {
    if (Array.isArray(item.conditions)) {
      const found = findConditionGroup(item, id);
      if (found) return found;
    }
  }
  return null;
}

function validCondition(condition) {
  return Boolean(condition?.field && OPERATORS.has(condition.operator));
}

function evaluateCondition(condition, sampleData) {
  const actual = sampleData[condition.field];
  switch (condition.operator) {
    case 'equals': return actual === condition.value;
    case 'notEquals': return actual !== condition.value;
    case 'notEmpty': return actual !== undefined && actual !== null && actual !== '';
    case 'empty': return actual === undefined || actual === null || actual === '';
    case 'greaterThan': return Number(actual) > Number(condition.value);
    case 'lessThan': return Number(actual) < Number(condition.value);
    case 'contains': return String(actual ?? '').includes(String(condition.value ?? ''));
    default: return false;
  }
}

function evaluateGroup(group, sampleData, trace) {
  const results = (group.conditions || []).map((item) => {
    if (Array.isArray(item.conditions)) return evaluateGroup(item, sampleData, trace);
    const result = evaluateCondition(item, sampleData);
    trace.push({ conditionId: item.id || null, field: item.field, operator: item.operator, result });
    return result;
  });
  if (!results.length) return true;
  return group.logic === 'any' ? results.some(Boolean) : results.every(Boolean);
}

function applyActions(actions) {
  const effects = {};
  for (const action of actions) {
    if (action.type === 'setValue') effects[action.target] = action.value;
    if (action.type === 'setVisible') effects[`visible:${action.target}`] = Boolean(action.value);
    if (action.type === 'setReadonly') effects[`readonly:${action.target}`] = Boolean(action.value);
    if (action.type === 'setRequired') effects[`required:${action.target}`] = Boolean(action.value);
    if (action.type === 'message') effects[`message:${action.id}`] = action.value;
    if (action.type === 'validate') effects[`validation:${action.target}`] = action.value;
    if (action.type === 'refreshReference') effects[`refresh:${action.target}`] = true;
  }
  return effects;
}

export function executeRuleBuilderCommand(state, command, payload = {}) {
  switch (command) {
    case 'select-rule':
      return state.rules.some((rule) => rule.id === payload.ruleId)
        ? { ...state, selectedRuleId: payload.ruleId }
        : state;
    case 'set-trigger':
      if (!EVENTS.has(payload.event) || typeof payload.source !== 'string') return state;
      return updateSelectedRule(state, (rule) => ({ ...rule, trigger: { event: payload.event, source: payload.source } }));
    case 'add-condition':
      if (!payload.parentGroupId || !validCondition(payload.condition)) return state;
      return updateSelectedRule(state, (rule) => {
        const group = findConditionGroup(rule.conditionGroup, payload.parentGroupId);
        if (!group) return null;
        group.conditions.push({ ...payload.condition, id: payload.condition.id || `C-${Date.now()}` });
        return rule;
      });
    case 'add-condition-group':
      if (!payload.parentGroupId || !['all', 'any'].includes(payload.group?.logic)) return state;
      return updateSelectedRule(state, (rule) => {
        const parent = findConditionGroup(rule.conditionGroup, payload.parentGroupId);
        if (!parent) return null;
        parent.conditions.push({ id: payload.group.id || `G-${Date.now()}`, logic: payload.group.logic, conditions: [] });
        return rule;
      });
    case 'add-action':
      if (!ACTIONS.has(payload.action?.type) || !payload.action.target) return state;
      return updateSelectedRule(state, (rule) => ({
        ...rule,
        actions: [...rule.actions, { ...payload.action, id: payload.action.id || `A-${rule.actions.length + 1}` }],
      }));
    case 'set-sample-value':
      return typeof payload.field === 'string' && payload.field
        ? { ...state, sampleData: { ...state.sampleData, [payload.field]: payload.value } }
        : state;
    case 'run-rule': {
      const rule = selectedRule(state);
      if (!rule) return state;
      const trace = [];
      const matched = rule.enabled && evaluateGroup(rule.conditionGroup, state.sampleData, trace);
      return {
        ...state,
        lastRun: {
          ruleId: rule.id,
          status: matched ? 'matched' : 'not-matched',
          trace,
          effects: matched ? applyActions(rule.actions) : {},
        },
      };
    }
    case 'duplicate-rule': {
      const rule = selectedRule(state);
      if (!rule) return state;
      let sequence = 1;
      while (state.rules.some((item) => item.id === `${rule.id}-COPY-${sequence}`)) sequence += 1;
      const copy = clone(rule);
      copy.id = `${rule.id}-COPY-${sequence}`;
      copy.title = `${rule.title}（副本）`;
      copy.enabled = false;
      return { ...state, rules: [...state.rules, copy], selectedRuleId: copy.id };
    }
    case 'remove-rule': {
      if (!state.selectedRuleId) return state;
      const rules = state.rules.filter((rule) => rule.id !== state.selectedRuleId);
      if (rules.length === state.rules.length) return state;
      return { ...state, rules, selectedRuleId: rules[0]?.id || null, lastRun: null };
    }
    default:
      return state;
  }
}

export function analyzeRuleDependencies(rules) {
  const ids = new Set(rules.map((rule) => rule.id));
  const dependencyCount = new Map(rules.map((rule) => [rule.id, 0]));
  const dependents = new Map(rules.map((rule) => [rule.id, []]));
  for (const rule of rules) {
    for (const dependency of rule.dependsOn || []) {
      if (!ids.has(dependency)) continue;
      dependencyCount.set(rule.id, dependencyCount.get(rule.id) + 1);
      dependents.get(dependency).push(rule.id);
    }
  }
  const queue = rules.filter((rule) => dependencyCount.get(rule.id) === 0).map((rule) => rule.id);
  const executionOrder = [];
  while (queue.length) {
    const id = queue.shift();
    executionOrder.push(id);
    for (const dependent of dependents.get(id)) {
      dependencyCount.set(dependent, dependencyCount.get(dependent) - 1);
      if (dependencyCount.get(dependent) === 0) queue.push(dependent);
    }
  }
  const cycle = rules.map((rule) => rule.id).filter((id) => !executionOrder.includes(id));
  return { hasCycle: cycle.length > 0, cycle, executionOrder };
}
