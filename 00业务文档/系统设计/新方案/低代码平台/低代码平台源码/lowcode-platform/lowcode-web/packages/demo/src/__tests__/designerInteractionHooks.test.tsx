import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it, vi } from 'vitest';
import { ELEMENT_TYPES, getElementCapability } from '../elementCapabilities';

const srcRoot = resolve(__dirname, '..');

describe('designer real interaction hooks', () => {
  it('renders a stable palette handle for every defined element type', () => {
    const source = readFileSync(resolve(srcRoot, 'ComponentPanelEnhanced.tsx'), 'utf8');

    for (const elementType of ELEMENT_TYPES) {
      const capability = getElementCapability(elementType);

      expect(source).toContain(`type: '${elementType}'`);
      expect(source).toContain(`data-testid={\`palette-\${type}\`}`);
      expect(source).toContain('aria-label={`添加${label}`}');
      expect(source).toContain('data-component-type={type}');
      expect(source).toContain('draggable="true"');
    }
  });

  it('renders canvas node, drag handle, and delete button hooks for human-equivalent automation', () => {
    const source = readFileSync(resolve(srcRoot, 'SortableFieldItem.tsx'), 'utf8');
    vi.fn();

    expect(source).toContain('data-testid="canvas-node"');
    expect(source).toContain('data-node-id={field.id}');
    expect(source).toContain('data-node-type={field.type}');
    expect(source).toContain('aria-label={`字段：${field.label}`}');
    expect(source).toContain('data-testid="drag-handle"');
    expect(source).toContain('aria-label={`拖动字段：${field.label}`}');
    expect(source).toContain('data-testid="delete-node-button"');
    expect(source).toContain('aria-label={`删除字段：${field.label}`}');
  });

  it('renders canvas root and container drop zone hooks for drag targets', () => {
    const designerSource = readFileSync(resolve(srcRoot, 'FormDesignerNested.tsx'), 'utf8');
    const renderFieldsSource = readFileSync(resolve(srcRoot, 'RenderFields.tsx'), 'utf8');

    expect(designerSource).toContain('data-testid="canvas-root"');
    expect(designerSource).toContain('aria-label="设计画布"');
    expect(renderFieldsSource).toContain('data-testid={`drop-zone-${containerType}`}');
    expect(renderFieldsSource).toContain('data-container-id={containerId}');
  });

  it('renders property panel hooks for setting label and size through real controls', () => {
    const source = readFileSync(resolve(srcRoot, 'PropertyPanel.tsx'), 'utf8');

    expect(source).toContain('data-testid="property-panel"');
    expect(source).toContain('data-testid="prop-label"');
    expect(source).toContain('data-testid="prop-field-id"');
    expect(source).toContain('data-testid="prop-width"');
    expect(source).toContain('data-testid="prop-height"');
    expect(source).toContain('aria-label="字段高度"');
  });
});
