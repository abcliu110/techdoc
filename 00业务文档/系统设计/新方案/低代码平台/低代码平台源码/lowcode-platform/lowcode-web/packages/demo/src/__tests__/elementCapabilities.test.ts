import { describe, expect, it } from 'vitest';
import {
  ELEMENT_CAPABILITY_MATRIX,
  ELEMENT_TYPES,
  getElementCapability,
} from '../elementCapabilities';

const REQUIRED_OPERATIONS = [
  'add',
  'select',
  'drag',
  'configureProps',
  'resize',
  'delete',
  'preview',
] as const;

describe('element capability matrix', () => {
  it('defines every designer element type exactly once', () => {
    expect(ELEMENT_TYPES).toEqual([
      'input',
      'inputNumber',
      'select',
      'datePicker',
      'checkbox',
      'radio',
      'switch',
      'button',
      'textarea',
      'upload',
      'cascader',
      'timePicker',
      'rangePicker',
      'autoComplete',
      'rate',
      'tag',
      'card',
      'tabs',
      'collapse',
      'divider',
      'subTable',
      'richText',
      'tree',
      'transfer',
      'slider',
      'colorPicker',
      'calendar',
    ]);

    expect(Object.keys(ELEMENT_CAPABILITY_MATRIX).sort()).toEqual([...ELEMENT_TYPES].sort());
  });

  it('defines required human operations and browser-test hooks for every element', () => {
    for (const elementType of ELEMENT_TYPES) {
      const capability = getElementCapability(elementType);

      expect(capability.type).toBe(elementType);
      expect(capability.label.length).toBeGreaterThan(0);
      expect(capability.category).toMatch(/^(basic|advanced|layout|display)$/);
      expect(capability.testIds.palette).toBe(`palette-${elementType}`);
      expect(capability.testIds.canvasNode).toBe('canvas-node');
      expect(capability.testIds.dragHandle).toBe('drag-handle');

      for (const operation of REQUIRED_OPERATIONS) {
        expect(capability.operations[operation], `${elementType}.${operation}`).toBeDefined();
        expect(capability.operations[operation].humanAction.length).toBeGreaterThan(0);
        expect(capability.operations[operation].aiAction.length).toBeGreaterThan(0);
        expect(capability.operations[operation].assertion.length).toBeGreaterThan(0);
      }
    }
  });

  it('marks containers with drop zones and child layout controls', () => {
    const containers = ELEMENT_TYPES.filter((type) => getElementCapability(type).acceptsChildren);

    expect(containers).toEqual(['card', 'tabs', 'collapse']);

    for (const elementType of containers) {
      const capability = getElementCapability(elementType);

      expect(capability.testIds.dropZone).toBe(`drop-zone-${elementType}`);
      expect(capability.propertyControls).toContain('childLayout');
      expect(capability.propertyControls).toContain('gap');
    }
  });

  it('does not define internal API hooks as AI actions', () => {
    const forbidden = /__designerController|addField|moveField|updateField|setProps|localStorage|schema|dispatch/i;

    for (const capability of Object.values(ELEMENT_CAPABILITY_MATRIX)) {
      for (const operation of Object.values(capability.operations)) {
        expect(operation.aiAction).not.toMatch(forbidden);
      }
    }
  });
});
