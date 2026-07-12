import { auditCurrentDocument } from './geometry-audit.mjs';

const contractUrl = new URL('../design/visual-contract.json', import.meta.url);
let reportRevision = 0;

function parseDesignerSchema() {
  const output = document.querySelector('[data-testid="schema-json"]');
  if (!output?.value) return [];
  try {
    const schema = JSON.parse(output.value);
    return Object.values(schema.nodes || {}).map((node) => ({
      id: node.id,
      parentId: node.parentId,
      type: node.type,
      title: node.props?.title || node.type,
    }));
  } catch {
    return [];
  }
}

function ownerId(element) {
  return element?.dataset.schemaId
    || element?.dataset.uiComponent
    || element?.dataset.fieldId
    || null;
}

function collectOwnershipTree() {
  const nodes = new Map(parseDesignerSchema().map((node) => [node.id, node]));
  const owners = document.querySelectorAll('[data-schema-id], [data-ui-component], [data-field-id]');
  for (const element of owners) {
    const id = ownerId(element);
    if (!id || nodes.has(id)) continue;
    const parentElement = element.parentElement?.closest('[data-schema-id], [data-ui-component], [data-field-id]');
    nodes.set(id, {
      id,
      parentId: ownerId(parentElement),
      type: element.dataset.componentType || 'UIComponent',
      title: element.getAttribute('aria-label') || element.dataset.testid || id,
    });
  }
  return [...nodes.values()];
}

function reportOutput() {
  return document.querySelector('[data-testid="quality-gate-json"]');
}

function writeReport(report) {
  const output = reportOutput();
  if (!output) return;
  output.value = JSON.stringify(report);
  output.dataset.status = report.status;
}

function completeReport(report) {
  return {
    ...report,
    generatedAt: new Date().toISOString(),
    revision: ++reportRevision,
  };
}

async function loadContract() {
  const response = await fetch(contractUrl, { cache: 'no-store' });
  if (!response.ok) throw new Error(`visual contract unavailable: ${response.status}`);
  return response.json();
}

async function run() {
  try {
    const contract = await loadContract();
    const report = completeReport(auditCurrentDocument({ contract, schemaTree: collectOwnershipTree() }));
    writeReport(report);
    return report;
  } catch (error) {
    const report = completeReport({
      status: 'BLOCKED',
      findings: [],
      error: error instanceof Error ? error.message : String(error),
    });
    writeReport(report);
    return report;
  }
}

function afterStableFrame(callback) {
  requestAnimationFrame(() => requestAnimationFrame(callback));
}

let auditGeneration = 0;

function scheduleAudit() {
  const generation = ++auditGeneration;
  afterStableFrame(() => {
    if (generation !== auditGeneration) return;
    void run();
  });
}

const scrollPositions = new WeakMap();

function rememberScrollPositions() {
  document.querySelectorAll('[data-scroll-owner]').forEach((element) => {
    scrollPositions.set(element, { left: element.scrollLeft, top: element.scrollTop });
  });
}

function handleScroll(event) {
  const element = event.target;
  if (!(element instanceof Element) || !element.matches('[data-scroll-owner]')) return;
  const current = { left: element.scrollLeft, top: element.scrollTop };
  const previous = scrollPositions.get(element);
  scrollPositions.set(element, current);
  if (previous && previous.left === current.left && previous.top === current.top) return;
  scheduleAudit();
}

function mutationAffectsAudit(mutation) {
  const output = reportOutput();
  return mutation.target !== output && !output?.contains(mutation.target);
}

function startWatching() {
  rememberScrollPositions();
  const root = document.querySelector('[data-testid="designer-root"]') || document.body;
  const observer = new MutationObserver((mutations) => {
    if (mutations.some(mutationAffectsAudit)) scheduleAudit();
  });
  observer.observe(root, { attributes: true, childList: true, characterData: true, subtree: true });
  document.addEventListener('scroll', handleScroll, true);
  return observer;
}

const ready = new Promise((resolve) => {
  const execute = () => {
    startWatching();
    afterStableFrame(() => resolve(run()));
  };
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', execute, { once: true });
  else execute();
});

window.addEventListener('resize', scheduleAudit);
window.enterpriseQualityGate = { run, ready };
