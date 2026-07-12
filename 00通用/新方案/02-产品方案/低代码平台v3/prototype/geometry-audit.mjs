const DEFAULT_TOLERANCE = 1;

const DEFAULT_RULES = {
  ELEMENT_CLIPPED: 'P1',
  ELEMENT_OFFSCREEN: 'P1',
  TEXT_CLIPPED: 'P1',
  LABEL_WRAPPED: 'P1',
  HIT_TARGET_BLOCKED: 'P1',
  UNDECLARED_SCROLL_X: 'P1',
  UNDECLARED_SCROLL_Y: 'P1',
  SCROLL_END_UNREACHABLE: 'P1',
  AUDIT_TREE_INVALID: 'P1',
  AUDIT_COVERAGE_INCOMPLETE: 'P1',
};

const DEFAULT_CONTRACT = {
  maxAuditNodes: 5000,
  breakpointNeighborDelta: 1,
  defaultHeight: 800,
  requiredViewports: [],
  declaredScrollOwners: {},
  blockingSeverities: ['P0', 'P1'],
  rules: DEFAULT_RULES,
};

function finite(value, fallback = 0) {
  const number = Number(value);
  return Number.isFinite(number) ? number : fallback;
}

function normalizeRect(value) {
  if (!value) return null;
  const left = finite(value.left);
  const top = finite(value.top);
  const right = finite(value.right, left + finite(value.width));
  const bottom = finite(value.bottom, top + finite(value.height));
  return {
    left,
    top,
    right,
    bottom,
    width: Math.max(0, right - left),
    height: Math.max(0, bottom - top),
  };
}

function viewportRect(viewport) {
  return normalizeRect({ left: 0, top: 0, right: viewport.width, bottom: viewport.height });
}

function intersectRect(aValue, bValue) {
  const a = normalizeRect(aValue);
  const b = normalizeRect(bValue);
  if (!a || !b) return null;
  const result = normalizeRect({
    left: Math.max(a.left, b.left),
    top: Math.max(a.top, b.top),
    right: Math.min(a.right, b.right),
    bottom: Math.min(a.bottom, b.bottom),
  });
  return result.width > 0 && result.height > 0 ? result : null;
}

function containsRect(boundaryValue, rectValue, tolerance = DEFAULT_TOLERANCE) {
  const boundary = normalizeRect(boundaryValue);
  const rect = normalizeRect(rectValue);
  if (!boundary || !rect) return false;
  return rect.left >= boundary.left - tolerance
    && rect.top >= boundary.top - tolerance
    && rect.right <= boundary.right + tolerance
    && rect.bottom <= boundary.bottom + tolerance;
}

function isHardClip(value) {
  return value === 'hidden' || value === 'clip';
}

function isScrollable(value) {
  return value === 'auto' || value === 'scroll';
}

function intersectAxis(current, start, end) {
  if (!current) return { start, end };
  return { start: Math.max(current.start, start), end: Math.min(current.end, end) };
}

function axisViolation(rect, boundary, axis) {
  if (!boundary) return false;
  const start = axis === 'x' ? rect.left : rect.top;
  const end = axis === 'x' ? rect.right : rect.bottom;
  return start < boundary.start - DEFAULT_TOLERANCE || end > boundary.end + DEFAULT_TOLERANCE;
}

function axisOutside(rect, boundary, axis) {
  if (!boundary) return false;
  const start = axis === 'x' ? rect.left : rect.top;
  const end = axis === 'x' ? rect.right : rect.bottom;
  return end <= boundary.start || start >= boundary.end;
}

function buildSchemaIndex(schemaTree = []) {
  const byId = new Map();
  const children = new Map();
  for (const node of schemaTree) {
    if (!node?.id || byId.has(node.id)) continue;
    byId.set(node.id, node);
    if (!children.has(node.id)) children.set(node.id, []);
    if (node.parentId) {
      if (!children.has(node.parentId)) children.set(node.parentId, []);
      children.get(node.parentId).push(node.id);
    }
  }

  const pathCache = new Map();
  const pathFor = (id, visiting = new Set()) => {
    if (!id) return 'Unowned';
    if (pathCache.has(id)) return pathCache.get(id);
    if (visiting.has(id)) return `InvalidCycle/${id}`;
    const node = byId.get(id);
    if (!node) return id;
    const label = node.title || node.type || node.id;
    const path = node.parentId
      ? `${pathFor(node.parentId, new Set([...visiting, id]))}/${label}`
      : label;
    pathCache.set(id, path);
    return path;
  };
  return { byId, children, pathFor };
}

function schemaTreeProblems(schemaTree = []) {
  const problems = [];
  const byId = new Map();
  for (const node of schemaTree) {
    if (!node?.id) {
      problems.push('Schema component is missing an id');
      continue;
    }
    if (byId.has(node.id)) problems.push(`duplicate Schema component id: ${node.id}`);
    else byId.set(node.id, node);
  }
  for (const node of byId.values()) {
    if (node.parentId && !byId.has(node.parentId)) problems.push(`missing Schema parent: ${node.parentId}`);
  }
  const visited = new Set();
  const active = new Set();
  const visit = (id) => {
    if (active.has(id)) {
      problems.push(`Schema ownership cycle at ${id}`);
      return;
    }
    if (visited.has(id)) return;
    active.add(id);
    const parentId = byId.get(id)?.parentId;
    if (parentId && byId.has(parentId)) visit(parentId);
    active.delete(id);
    visited.add(id);
  };
  for (const id of byId.keys()) visit(id);
  return problems;
}

function treeProblems(nodes, maxNodes) {
  const problems = [];
  if (nodes.length > maxNodes) problems.push(`audit node limit exceeded: ${nodes.length} > ${maxNodes}`);
  const byId = new Map();
  for (const node of nodes) {
    if (!node?.id) {
      problems.push('rendered node is missing an id');
      continue;
    }
    if (byId.has(node.id)) problems.push(`duplicate rendered node id: ${node.id}`);
    byId.set(node.id, node);
  }
  for (const node of nodes) {
    if (node?.parentId && !byId.has(node.parentId)) problems.push(`missing rendered parent: ${node.parentId}`);
  }

  const visited = new Set();
  const active = new Set();
  const visit = (id) => {
    if (active.has(id)) {
      problems.push(`rendered tree cycle at ${id}`);
      return;
    }
    if (visited.has(id)) return;
    active.add(id);
    const parentId = byId.get(id)?.parentId;
    if (parentId && byId.has(parentId)) visit(parentId);
    active.delete(id);
    visited.add(id);
  };
  for (const id of byId.keys()) visit(id);
  return problems;
}

function coverageProblems(snapshot, nodes) {
  const coverage = snapshot?.coverage;
  if (!coverage || typeof coverage !== 'object') return ['traversal coverage evidence is missing'];

  const counts = ['discoveredNodes', 'expectedScannedNodes', 'scannedNodes', 'excludedNodes'];
  const problems = counts
    .filter((key) => !Number.isInteger(coverage[key]) || coverage[key] < 0)
    .map((key) => `${key} must be a non-negative integer`);
  if (problems.length > 0) return problems;

  const reasonCounts = Object.values(coverage.exclusionReasons || {});
  if (reasonCounts.some((count) => !Number.isInteger(count) || count < 0)) {
    problems.push('exclusion reason counts must be non-negative integers');
  }
  const explainedExclusions = reasonCounts.reduce((total, count) => total + count, 0);
  if (explainedExclusions !== coverage.excludedNodes) {
    problems.push(`excluded node reasons account for ${explainedExclusions} of ${coverage.excludedNodes}`);
  }
  if (coverage.expectedScannedNodes + coverage.excludedNodes !== coverage.discoveredNodes) {
    problems.push('expected scanned and excluded counts do not equal discovered nodes');
  }
  if (coverage.scannedNodes !== nodes.length) {
    problems.push(`reported scanned nodes ${coverage.scannedNodes} do not equal snapshot nodes ${nodes.length}`);
  }
  if (coverage.scannedNodes !== coverage.expectedScannedNodes) {
    problems.push(`scanned nodes ${coverage.scannedNodes} do not equal expected ${coverage.expectedScannedNodes}`);
  }
  if (snapshot?.truncated) problems.push('collector reached its node limit');
  return problems;
}

function findingFor(rule, node, contract, schemaIndex, details = {}) {
  return {
    rule,
    severity: contract.rules?.[rule] || DEFAULT_RULES[rule] || 'P2',
    schemaId: node?.schemaId || null,
    componentType: node?.componentType || null,
    schemaPath: schemaIndex.pathFor(node?.schemaId),
    domId: node?.id || null,
    domPath: node?.domPath || null,
    ...details,
  };
}

function uniqueFindings(findings) {
  const seen = new Set();
  return findings.filter((finding) => {
    const key = [finding.rule, finding.schemaId, finding.domId, finding.axis].join(':');
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

function declaredAxes(node, contract) {
  const fromNode = Array.isArray(node.scrollAxes) ? node.scrollAxes : [];
  const fromContract = node.scrollOwner ? contract.declaredScrollOwners?.[node.scrollOwner] || [] : [];
  return new Set([...fromNode, ...fromContract]);
}

function outsideScrollableViewport(rect, scrollAncestors) {
  return scrollAncestors.some((ancestor) => {
    const axes = new Set(ancestor.axes || []);
    return (axes.has('x') && (rect.right <= ancestor.rect.left || rect.left >= ancestor.rect.right))
      || (axes.has('y') && (rect.bottom <= ancestor.rect.top || rect.top >= ancestor.rect.bottom));
  });
}

function partiallyVisibleInReachableScroll(rect, scrollAncestors) {
  return scrollAncestors.some((ancestor) => {
    if (ancestor.scrollEndReachable === false) return false;
    const axes = new Set(ancestor.axes || []);
    return (axes.has('x') && (rect.left < ancestor.rect.left - DEFAULT_TOLERANCE
      || rect.right > ancestor.rect.right + DEFAULT_TOLERANCE))
      || (axes.has('y') && (rect.top < ancestor.rect.top - DEFAULT_TOLERANCE
        || rect.bottom > ancestor.rect.bottom + DEFAULT_TOLERANCE));
  });
}

function inspectNode(node, context, contract, schemaIndex) {
  const findings = [];
  if (!node.visible) return { findings, childContext: context };

  const rect = normalizeRect(node.rect);
  const overlayBoundary = normalizeRect(node.overlayBoundary);
  const isOverlay = Boolean(node.overlayOwner || overlayBoundary);
  const logicalOwner = node.overlayOwner || context.logicalOwner || null;
  const findingNode = logicalOwner ? { ...node, schemaId: logicalOwner } : node;
  const activeViewport = isOverlay
    ? intersectRect(context.rootViewport, overlayBoundary) || context.rootViewport
    : context.viewport;
  const scrollAxes = isOverlay
    ? new Set()
    : new Set(context.scrollAncestors
      .filter((ancestor) => ancestor.scrollEndReachable !== false)
      .flatMap((ancestor) => ancestor.axes));
  const boundaryX = isOverlay
    ? { start: activeViewport.left, end: activeViewport.right }
    : context.clipX || (!scrollAxes.has('x') ? { start: activeViewport.left, end: activeViewport.right } : null);
  const boundaryY = isOverlay
    ? { start: activeViewport.top, end: activeViewport.bottom }
    : context.clipY || (!scrollAxes.has('y') ? { start: activeViewport.top, end: activeViewport.bottom } : null);
  const violatesX = rect && axisViolation(rect, boundaryX, 'x');
  const violatesY = rect && axisViolation(rect, boundaryY, 'y');

  if (rect && (violatesX || violatesY)) {
    const outside = (violatesX && axisOutside(rect, boundaryX, 'x'))
      || (violatesY && axisOutside(rect, boundaryY, 'y'));
    findings.push(findingFor(
      outside ? 'ELEMENT_OFFSCREEN' : 'ELEMENT_CLIPPED',
      findingNode,
      contract,
      schemaIndex,
      { actual: rect, expectedBoundary: { x: boundaryX, y: boundaryY } },
    ));
  }

  const axes = declaredAxes(node, contract);
  const overflowX = node.scrollWidth > node.clientWidth + DEFAULT_TOLERANCE;
  const overflowY = node.scrollHeight > node.clientHeight + DEFAULT_TOLERANCE;
  if (overflowX && node.overflowX !== 'visible' && !axes.has('x') && !node.allowClip && !node.allowTruncation) {
    findings.push(findingFor('UNDECLARED_SCROLL_X', findingNode, contract, schemaIndex, {
      axis: 'x',
      actual: { scrollWidth: node.scrollWidth, clientWidth: node.clientWidth, overflow: node.overflowX },
      expected: 'x overflow must have a declared scroll owner or clipping policy',
    }));
  }
  if (overflowY && node.overflowY !== 'visible' && !axes.has('y') && !node.allowClip && !node.allowTruncation) {
    findings.push(findingFor('UNDECLARED_SCROLL_Y', findingNode, contract, schemaIndex, {
      axis: 'y',
      actual: { scrollHeight: node.scrollHeight, clientHeight: node.clientHeight, overflow: node.overflowY },
      expected: 'y overflow must have a declared scroll owner or clipping policy',
    }));
  }
  if ((overflowX || overflowY) && node.scrollOwner && node.scrollEndReachable === false) {
    findings.push(findingFor('SCROLL_END_UNREACHABLE', findingNode, contract, schemaIndex, {
      actual: { scrollWidth: node.scrollWidth, scrollHeight: node.scrollHeight },
      expected: 'declared scroll owner reaches its final content edge',
    }));
  }

  if (node.isText && !node.allowTruncation) {
    const textClippedX = node.scrollWidth > node.clientWidth + DEFAULT_TOLERANCE
      && node.overflowX !== 'visible' && !axes.has('x');
    const textClippedY = node.scrollHeight > node.clientHeight + DEFAULT_TOLERANCE
      && node.overflowY !== 'visible' && !axes.has('y');
    if (textClippedX || textClippedY) {
      findings.push(findingFor('TEXT_CLIPPED', findingNode, contract, schemaIndex, {
        actual: {
          scrollWidth: node.scrollWidth,
          clientWidth: node.clientWidth,
          scrollHeight: node.scrollHeight,
          clientHeight: node.clientHeight,
        },
        expected: 'text remains readable or declares an intentional truncation policy',
      }));
    }
  }
  if (node.expectSingleLine && node.lineCount > 1) {
    findings.push(findingFor('LABEL_WRAPPED', findingNode, contract, schemaIndex, {
      actual: { text: node.text, lineCount: node.lineCount },
      expected: 'single-line task label',
    }));
  }
  const deferredToScrollState = rect && (outsideScrollableViewport(rect, context.scrollAncestors)
    || partiallyVisibleInReachableScroll(rect, context.scrollAncestors));
  if (node.interactive && node.hitTest === false && rect && !deferredToScrollState) {
    findings.push(findingFor('HIT_TARGET_BLOCKED', findingNode, contract, schemaIndex, {
      actual: 'no safe sample point reaches the target or its descendants',
      expected: 'at least one safe pointer hit point',
    }));
  }

  let clipX = isOverlay ? null : context.clipX;
  let clipY = isOverlay ? null : context.clipY;
  if (!isOverlay && rect && isHardClip(node.overflowX)) clipX = intersectAxis(clipX, rect.left, rect.right);
  if (!isOverlay && rect && isHardClip(node.overflowY)) clipY = intersectAxis(clipY, rect.top, rect.bottom);

  const scrollAncestors = isOverlay ? [] : [...context.scrollAncestors];
  if (rect && (isScrollable(node.overflowX) || isScrollable(node.overflowY)) && node.scrollOwner) {
    scrollAncestors.push({
      id: node.id,
      rect,
      axes: [...axes],
      scrollEndReachable: node.scrollEndReachable,
    });
    if (node.scrollEndReachable !== false) {
      if (axes.has('x')) clipX = null;
      if (axes.has('y')) clipY = null;
    }
  }

  return {
    findings,
    childContext: {
      viewport: activeViewport,
      rootViewport: context.rootViewport,
      clipX,
      clipY,
      scrollAncestors,
      logicalOwner,
    },
  };
}

function aggregateComponents(schemaIndex, findings, blockingSeverities) {
  const components = {};
  for (const [id, node] of schemaIndex.byId) {
    components[id] = {
      id,
      type: node.type,
      parentId: node.parentId || null,
      path: schemaIndex.pathFor(id),
      directFindings: 0,
      descendantFindings: 0,
      status: 'PASS',
    };
  }
  for (const finding of findings) {
    if (!finding.schemaId || !components[finding.schemaId]) continue;
    components[finding.schemaId].directFindings += 1;
    if (blockingSeverities.has(finding.severity)) components[finding.schemaId].status = 'FAIL';
  }

  const depth = (id) => schemaIndex.pathFor(id).split('/').length;
  for (const id of [...schemaIndex.byId.keys()].sort((a, b) => depth(b) - depth(a))) {
    const component = components[id];
    if (!component.parentId || !components[component.parentId]) continue;
    const parent = components[component.parentId];
    parent.descendantFindings += component.directFindings + component.descendantFindings;
    if (component.status === 'FAIL') parent.status = 'FAIL';
  }
  return components;
}

export function auditGeometrySnapshot(snapshot, suppliedContract = {}) {
  const contract = {
    ...DEFAULT_CONTRACT,
    ...suppliedContract,
    rules: { ...DEFAULT_RULES, ...(suppliedContract.rules || {}) },
    declaredScrollOwners: suppliedContract.declaredScrollOwners || {},
  };
  const viewport = {
    width: finite(snapshot?.viewport?.width),
    height: finite(snapshot?.viewport?.height),
  };
  const nodes = Array.isArray(snapshot?.nodes) ? snapshot.nodes : [];
  const schemaTree = Array.isArray(snapshot?.schemaTree) ? snapshot.schemaTree : [];
  const schemaIndex = buildSchemaIndex(schemaTree);
  const blockingSeverities = new Set(contract.blockingSeverities || ['P0', 'P1']);
  const findings = [];
  const problems = treeProblems(nodes, contract.maxAuditNodes);
  const schemaProblems = schemaTreeProblems(schemaTree);
  for (const problem of problems) {
    findings.push(findingFor('AUDIT_TREE_INVALID', { schemaId: snapshot?.schemaTree?.[0]?.id }, contract, schemaIndex, {
      actual: problem,
      expected: 'a finite acyclic rendered tree with stable ids',
    }));
  }
  for (const problem of schemaProblems) {
    findings.push(findingFor('AUDIT_TREE_INVALID', { schemaId: schemaTree[0]?.id }, contract, schemaIndex, {
      actual: problem,
      expected: 'a finite acyclic Schema ownership tree with stable unique ids',
    }));
  }

  const incompleteCoverage = coverageProblems(snapshot, nodes);
  if (incompleteCoverage.length > 0) {
    findings.push(findingFor('AUDIT_COVERAGE_INCOMPLETE', { schemaId: snapshot?.schemaTree?.[0]?.id }, contract, schemaIndex, {
      actual: { coverage: snapshot?.coverage || null, truncated: Boolean(snapshot?.truncated), problems: incompleteCoverage },
      expected: 'all discovered nodes are either scanned or excluded with complete reason counts',
    }));
  }

  if (viewport.width <= 0 || viewport.height <= 0) {
    findings.push(findingFor('AUDIT_TREE_INVALID', { schemaId: snapshot?.schemaTree?.[0]?.id }, contract, schemaIndex, {
      actual: viewport,
      expected: 'positive viewport dimensions',
    }));
  }

  if (problems.length === 0 && schemaProblems.length === 0 && viewport.width > 0 && viewport.height > 0) {
    const byId = new Map(nodes.map((node) => [node.id, node]));
    const children = new Map();
    for (const node of nodes) {
      if (!children.has(node.parentId || null)) children.set(node.parentId || null, []);
      children.get(node.parentId || null).push(node);
    }
    const visited = new Set();
    const walk = (node, context) => {
      if (visited.has(node.id)) return;
      visited.add(node.id);
      const inspected = inspectNode(node, context, contract, schemaIndex);
      findings.push(...inspected.findings);
      for (const child of children.get(node.id) || []) walk(child, inspected.childContext);
    };
    const roots = nodes.filter((node) => !node.parentId || !byId.has(node.parentId));
    const rootViewport = viewportRect(viewport);
    const context = {
      viewport: rootViewport,
      rootViewport,
      clipX: { start: rootViewport.left, end: rootViewport.right },
      clipY: { start: rootViewport.top, end: rootViewport.bottom },
      scrollAncestors: [],
      logicalOwner: null,
    };
    for (const root of roots) walk(root, context);
  }

  const deduplicated = uniqueFindings(findings);
  const components = aggregateComponents(schemaIndex, deduplicated, blockingSeverities);
  const status = deduplicated.some((finding) => blockingSeverities.has(finding.severity)) ? 'FAIL' : 'PASS';
  return {
    status,
    viewport,
    state: snapshot?.state || 'unknown',
    findings: deduplicated,
    components,
    metrics: {
      renderedNodes: nodes.length,
      schemaComponents: schemaIndex.byId.size,
      blockingFindings: deduplicated.filter((finding) => blockingSeverities.has(finding.severity)).length,
      coverage: snapshot?.coverage ? { ...snapshot.coverage, truncated: Boolean(snapshot?.truncated) } : null,
    },
  };
}

export function extractCssBreakpoints(cssText = '') {
  const widths = new Set();
  const pattern = /(?:min|max)-width\s*:\s*(\d+(?:\.\d+)?)px/gi;
  for (const match of cssText.matchAll(pattern)) widths.add(Math.round(Number(match[1])));
  return [...widths].sort((a, b) => a - b);
}

export function buildViewportMatrix(suppliedContract = {}, cssText = '') {
  const contract = { ...DEFAULT_CONTRACT, ...suppliedContract };
  const delta = Math.max(1, finite(contract.breakpointNeighborDelta, 1));
  const height = Math.max(1, finite(contract.defaultHeight, 800));
  const samples = new Map();
  const add = (viewport) => {
    const width = Math.max(1, Math.round(finite(viewport.width)));
    const sampleHeight = Math.max(1, Math.round(finite(viewport.height, height)));
    const key = `${width}x${sampleHeight}`;
    if (!samples.has(key)) samples.set(key, { ...viewport, width, height: sampleHeight });
  };
  for (const viewport of contract.requiredViewports || []) add(viewport);
  for (const breakpoint of extractCssBreakpoints(cssText)) {
    add({ width: breakpoint - delta, height, source: `${breakpoint}-delta` });
    add({ width: breakpoint, height, source: `${breakpoint}` });
    add({ width: breakpoint + delta, height, source: `${breakpoint}+delta` });
  }
  return [...samples.values()].sort((a, b) => a.width - b.width || a.height - b.height);
}

export function buildAuditMatrix(suppliedContract = {}, cssText = '') {
  const states = suppliedContract.requiredStates || [];
  const viewports = buildViewportMatrix(suppliedContract, cssText);
  return states.flatMap((state) => viewports.map((viewport) => ({ ...viewport, state })));
}

export function deriveGateStatus(evidence) {
  const required = ['mechanical', 'interaction', 'visual'];
  const values = required.map((key) => evidence?.[key]);
  if (values.includes('FAIL')) return 'FAIL';
  if (values.some((value) => value !== 'PASS')) return 'BLOCKED';
  return 'PASS';
}

export async function runQualityGateMatrix(options = {}) {
  const contract = { ...DEFAULT_CONTRACT, ...(options.contract || {}) };
  const samples = [];
  for (const candidate of buildAuditMatrix(contract, options.cssText || '')) {
    const viewport = { width: candidate.width, height: candidate.height };
    await options.setViewport?.(viewport);
    await options.setState?.(candidate.state);
    const report = await options.readMechanical?.({ state: candidate.state, viewport });
    const viewportMatches = report?.viewport?.width === viewport.width
      && report?.viewport?.height === viewport.height;
    const mechanical = viewportMatches && ['PASS', 'FAIL'].includes(report?.status)
      ? report.status
      : 'BLOCKED';
    const interaction = await options.verifyInteraction?.({ state: candidate.state, viewport, report }) ?? null;
    const visual = await options.verifyVisual?.({ state: candidate.state, viewport, report }) ?? null;
    samples.push({
      ...candidate,
      viewport,
      reportedViewport: report?.viewport || null,
      mechanical,
      interaction,
      visual,
      status: deriveGateStatus({ mechanical, interaction, visual }),
      findings: report?.findings || [],
    });
  }
  return {
    status: samples.some((sample) => sample.status === 'FAIL')
      ? 'FAIL'
      : samples.every((sample) => sample.status === 'PASS') ? 'PASS' : 'BLOCKED',
    samples,
  };
}

function elementPath(element) {
  if (element.dataset?.testid) return `[data-testid="${element.dataset.testid}"]`;
  if (element.dataset?.schemaId) return `[data-schema-id="${element.dataset.schemaId}"]`;
  if (element.id) return `#${element.id}`;
  const parts = [];
  let current = element;
  while (current?.nodeType === 1 && parts.length < 5) {
    const tag = current.tagName.toLowerCase();
    const siblings = current.parentElement
      ? [...current.parentElement.children].filter((sibling) => sibling.tagName === current.tagName)
      : [];
    const suffix = siblings.length > 1 ? `:nth-of-type(${siblings.indexOf(current) + 1})` : '';
    parts.unshift(`${tag}${suffix}`);
    current = current.parentElement;
  }
  return parts.join(' > ');
}

function roundRect(rect) {
  return {
    left: Math.round(rect.left * 100) / 100,
    top: Math.round(rect.top * 100) / 100,
    right: Math.round(rect.right * 100) / 100,
    bottom: Math.round(rect.bottom * 100) / 100,
    width: Math.round(rect.width * 100) / 100,
    height: Math.round(rect.height * 100) / 100,
  };
}

function lineCountFor(element, text, directOnly = false) {
  if (!text || typeof document === 'undefined') return 0;
  const textNodes = [];
  const collect = (node) => {
    for (const child of node.childNodes) {
      if (child.nodeType === Node.TEXT_NODE && child.textContent.trim()) textNodes.push(child);
      else if (!directOnly && child.nodeType === Node.ELEMENT_NODE) collect(child);
    }
  };
  collect(element);
  const tops = new Set();
  for (const textNode of textNodes) {
    const range = document.createRange();
    range.selectNodeContents(textNode);
    for (const rect of range.getClientRects()) {
      if (rect.width > 0 && rect.height > 0) tops.add(Math.round(rect.top));
    }
  }
  return tops.size;
}

function textFor(element, interactive) {
  const direct = [...element.childNodes]
    .filter((node) => node.nodeType === Node.TEXT_NODE)
    .map((node) => node.textContent)
    .join(' ')
    .replace(/\s+/g, ' ')
    .trim();
  const text = (direct || (interactive ? element.textContent : ''))?.replace(/\s+/g, ' ').trim() || '';
  return { direct, text };
}

function hitTestElement(element, rect) {
  if (typeof document === 'undefined' || rect.width <= 0 || rect.height <= 0) return false;
  const insetX = Math.min(4, rect.width / 4);
  const insetY = Math.min(4, rect.height / 4);
  const points = [
    [rect.left + rect.width / 2, rect.top + rect.height / 2],
    [rect.left + insetX, rect.top + insetY],
    [rect.right - insetX, rect.top + insetY],
    [rect.left + insetX, rect.bottom - insetY],
    [rect.right - insetX, rect.bottom - insetY],
  ];
  return points.some(([x, y]) => {
    if (x < 0 || y < 0 || x > innerWidth || y > innerHeight) return false;
    const target = document.elementFromPoint(x, y);
    return target === element || element.contains(target);
  });
}

function scrollEndReachable(element, axes) {
  if (axes.has('x') && (!Number.isFinite(element.scrollWidth) || element.clientWidth <= 0)) return false;
  if (axes.has('y') && (!Number.isFinite(element.scrollHeight) || element.clientHeight <= 0)) return false;
  return true;
}

function nearestOwner(element) {
  return element.closest('[data-schema-id], [data-schema-node], [data-field-id], [data-ui-component]');
}

function overlayBoundaryFor(element) {
  if (!element.dataset.overlayOwner) return null;
  const selector = element.dataset.overlayBoundary;
  const host = selector ? document.querySelector(selector) : null;
  return host ? roundRect(host.getBoundingClientRect()) : roundRect({
    left: 0,
    top: 0,
    right: innerWidth,
    bottom: innerHeight,
    width: innerWidth,
    height: innerHeight,
  });
}

export function collectGeometrySnapshot(options = {}) {
  if (typeof document === 'undefined') throw new Error('collectGeometrySnapshot requires a browser document');
  const root = options.root || document.body;
  const maxNodes = options.maxNodes || DEFAULT_CONTRACT.maxAuditNodes;
  const candidates = [root, ...root.querySelectorAll('*')];
  const activeModal = document.querySelector('[role="dialog"][aria-modal="true"]:not([hidden])');
  const elementIds = new Map();
  const nodes = [];
  const exclusionReasons = {};
  let excludedNodes = 0;
  for (const element of candidates) {
    if (nodes.length >= maxNodes) break;
    const style = getComputedStyle(element);
    const rect = element.getBoundingClientRect();
    const visible = !element.hidden
      && style.display !== 'none'
      && style.visibility !== 'hidden'
      && rect.width > 0
      && rect.height > 0;
    if (!visible) {
      const reason = element.hidden
        ? 'hidden-attribute'
        : style.display === 'none'
          ? 'display-none'
          : style.visibility === 'hidden'
            ? 'visibility-hidden'
            : 'zero-area';
      excludedNodes += 1;
      exclusionReasons[reason] = (exclusionReasons[reason] || 0) + 1;
      continue;
    }
    const id = `dom-${nodes.length + 1}`;
    elementIds.set(element, id);
    let parent = element.parentElement;
    while (parent && !elementIds.has(parent)) parent = parent.parentElement;
    const owner = nearestOwner(element);
    const interactive = (!activeModal || activeModal.contains(element))
      && element.matches('button, a[href], input, select, textarea, [role="button"], [tabindex]:not([tabindex="-1"])')
      && !element.matches(':disabled, [aria-disabled="true"]');
    const { direct, text } = textFor(element, interactive);
    const shortTaskLabel = interactive && Boolean(direct)
      && /^[\p{Script=Han}A-Za-z0-9%+\-]{2,6}$/u.test(text);
    const scrollAxes = (element.dataset.scrollAxes || '').split(',').map((axis) => axis.trim()).filter(Boolean);
    const axes = new Set(scrollAxes);
    const ownerId = owner?.dataset.schemaId
      || owner?.dataset.schemaNode
      || owner?.dataset.fieldId
      || owner?.dataset.uiComponent
      || null;
    nodes.push({
      id,
      parentId: parent ? elementIds.get(parent) : null,
      schemaId: ownerId,
      componentType: owner?.dataset.componentType || owner?.dataset.uiComponent || element.tagName,
      domPath: elementPath(element),
      rect: roundRect(rect),
      visible,
      overflowX: style.overflowX,
      overflowY: style.overflowY,
      clientWidth: element.clientWidth,
      clientHeight: element.clientHeight,
      scrollWidth: element.scrollWidth,
      scrollHeight: element.scrollHeight,
      scrollEndReachable: scrollEndReachable(element, axes),
      isText: Boolean(text),
      text,
      lineCount: lineCountFor(element, text, Boolean(direct)),
      expectSingleLine: element.dataset.auditSingleLine === 'true' || shortTaskLabel || style.whiteSpace === 'nowrap',
      allowTruncation: element.dataset.allowTruncation === 'true',
      allowClip: element.dataset.allowClipping === 'true',
      interactive,
      hitTest: interactive ? hitTestElement(element, rect) : true,
      scrollOwner: element.dataset.scrollOwner || null,
      scrollAxes,
      overlayOwner: element.dataset.overlayOwner || null,
      overlayBoundary: overlayBoundaryFor(element),
    });
  }
  return {
    viewport: { width: innerWidth, height: innerHeight },
    state: options.state || document.querySelector('[data-testid="designer-root"]')?.dataset.state || 'unknown',
    schemaTree: options.schemaTree || [],
    nodes,
    truncated: candidates.length > nodes.length + excludedNodes,
    coverage: {
      discoveredNodes: candidates.length,
      expectedScannedNodes: candidates.length - excludedNodes,
      scannedNodes: nodes.length,
      excludedNodes,
      exclusionReasons,
    },
  };
}

export function auditCurrentDocument(options = {}) {
  const contract = { ...DEFAULT_CONTRACT, ...(options.contract || {}) };
  const snapshot = collectGeometrySnapshot({ ...options, maxNodes: contract.maxAuditNodes });
  return auditGeometrySnapshot(snapshot, contract);
}

export { DEFAULT_CONTRACT, intersectRect };
