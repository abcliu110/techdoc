const rect = (left, top, width, height) => ({
  left,
  top,
  right: left + width,
  bottom: top + height,
  width,
  height,
});

const baseNode = (overrides = {}) => ({
  id: 'node',
  parentId: null,
  schemaId: 'page',
  componentType: 'FormPage',
  rect: rect(0, 0, 300, 200),
  visible: true,
  overflowX: 'visible',
  overflowY: 'visible',
  clientWidth: 300,
  clientHeight: 200,
  scrollWidth: 300,
  scrollHeight: 200,
  scrollEndReachable: true,
  isText: false,
  text: '',
  lineCount: 0,
  expectSingleLine: false,
  allowTruncation: false,
  interactive: false,
  hitTest: true,
  scrollOwner: null,
  scrollAxes: [],
  overlayOwner: null,
  overlayBoundary: null,
  ...overrides,
});

const schemaTree = [
  { id: 'page', parentId: null, type: 'FormPage', title: 'Page' },
  { id: 'section', parentId: 'page', type: 'Section', title: 'Section' },
  { id: 'field', parentId: 'section', type: 'TextField', title: 'Field' },
];

export const nestedHardClip = {
  viewport: { width: 300, height: 200 },
  schemaTree,
  nodes: [
    baseNode({ id: 'root' }),
    baseNode({ id: 'section', parentId: 'root', schemaId: 'section', componentType: 'Section', rect: rect(10, 10, 180, 120), clientWidth: 180, clientHeight: 120, scrollWidth: 180, scrollHeight: 120 }),
    baseNode({ id: 'clip', parentId: 'section', schemaId: 'section', componentType: 'SectionBody', rect: rect(20, 20, 100, 80), clientWidth: 100, clientHeight: 80, scrollWidth: 100, scrollHeight: 80, overflowX: 'hidden', overflowY: 'hidden' }),
    baseNode({ id: 'field', parentId: 'clip', schemaId: 'field', componentType: 'TextField', rect: rect(90, 30, 70, 30), clientWidth: 70, clientHeight: 30, scrollWidth: 70, scrollHeight: 30, interactive: true }),
  ],
};

export const legalHorizontalScroll = {
  viewport: { width: 300, height: 200 },
  schemaTree,
  nodes: [
    baseNode({ id: 'root' }),
    baseNode({ id: 'scroller', parentId: 'root', schemaId: 'section', rect: rect(20, 20, 100, 80), clientWidth: 100, clientHeight: 80, scrollWidth: 300, scrollHeight: 80, overflowX: 'auto', overflowY: 'hidden', scrollOwner: 'entry-table-wrap', scrollAxes: ['x'] }),
    baseNode({ id: 'field', parentId: 'scroller', schemaId: 'field', rect: rect(220, 30, 60, 30), clientWidth: 60, clientHeight: 30, scrollWidth: 60, scrollHeight: 30, interactive: true, hitTest: false }),
  ],
};

export const partiallyVisibleInLegalScroll = {
  viewport: { width: 300, height: 200 },
  schemaTree,
  nodes: [
    baseNode({ id: 'root' }),
    baseNode({ id: 'scroller', parentId: 'root', schemaId: 'section', rect: rect(20, 20, 100, 80), clientWidth: 100, clientHeight: 80, scrollWidth: 300, scrollHeight: 80, overflowX: 'auto', overflowY: 'hidden', scrollOwner: 'entry-table-wrap', scrollAxes: ['x'] }),
    baseNode({ id: 'button', parentId: 'scroller', schemaId: 'field', componentType: 'Button', rect: rect(110, 30, 40, 30), clientWidth: 40, clientHeight: 30, scrollWidth: 40, scrollHeight: 30, interactive: true, hitTest: false }),
  ],
};

export const undeclaredHorizontalScroll = {
  ...legalHorizontalScroll,
  nodes: legalHorizontalScroll.nodes.map((node) => node.id === 'scroller'
    ? { ...node, scrollOwner: null, scrollAxes: [] }
    : { ...node }),
};

export const wrappedToolbarLabel = {
  viewport: { width: 300, height: 200 },
  schemaTree,
  nodes: [
    baseNode({ id: 'root' }),
    baseNode({
      id: 'label',
      parentId: 'root',
      schemaId: 'field',
      componentType: 'ToolbarButton',
      rect: rect(20, 20, 24, 42),
      clientWidth: 24,
      clientHeight: 42,
      scrollWidth: 24,
      scrollHeight: 42,
      isText: true,
      text: '平板',
      lineCount: 2,
      expectSingleLine: true,
      interactive: true,
    }),
  ],
};

export const blockedHitTarget = {
  viewport: { width: 300, height: 200 },
  schemaTree,
  nodes: [
    baseNode({ id: 'root' }),
    baseNode({ id: 'button', parentId: 'root', schemaId: 'field', componentType: 'Button', rect: rect(20, 20, 80, 32), clientWidth: 80, clientHeight: 32, scrollWidth: 80, scrollHeight: 32, interactive: true, hitTest: false }),
  ],
};

export const legalPortal = {
  viewport: { width: 300, height: 200 },
  schemaTree,
  nodes: [
    baseNode({ id: 'root' }),
    baseNode({ id: 'clip', parentId: 'root', schemaId: 'section', rect: rect(0, 0, 80, 50), clientWidth: 80, clientHeight: 50, scrollWidth: 80, scrollHeight: 50, overflowX: 'hidden', overflowY: 'hidden' }),
    baseNode({ id: 'portal', parentId: 'clip', schemaId: 'field', componentType: 'Popover', rect: rect(160, 50, 100, 80), clientWidth: 100, clientHeight: 80, scrollWidth: 100, scrollHeight: 80, overlayOwner: 'field', overlayBoundary: rect(0, 0, 300, 200), interactive: true }),
  ],
};

export const visibleTextOverflow = {
  viewport: { width: 300, height: 200 },
  schemaTree,
  nodes: [
    baseNode({ id: 'root' }),
    baseNode({
      id: 'icon',
      parentId: 'root',
      schemaId: 'field',
      componentType: 'Icon',
      rect: rect(20, 20, 20, 20),
      clientWidth: 20,
      clientHeight: 20,
      scrollWidth: 20,
      scrollHeight: 22,
      overflowY: 'visible',
      isText: true,
      text: '数',
      lineCount: 1,
    }),
  ],
};

export const intentionalTruncation = {
  viewport: { width: 300, height: 200 },
  schemaTree,
  nodes: [
    baseNode({ id: 'root' }),
    baseNode({
      id: 'subtitle',
      parentId: 'root',
      schemaId: 'field',
      componentType: 'PaletteSubtitle',
      rect: rect(20, 20, 80, 20),
      clientWidth: 80,
      clientHeight: 20,
      scrollWidth: 140,
      scrollHeight: 20,
      overflowX: 'hidden',
      isText: true,
      text: 'Complete protocol description',
      lineCount: 1,
      allowTruncation: true,
    }),
  ],
};

export { rect };
