import assert from 'node:assert/strict';
import test from 'node:test';
import { projectFieldRenderer, rendererStyleAttribute } from '../prototype/renderer-projection.mjs';

test('field layout properties project to concrete renderer styles', () => {
  const projection = projectFieldRenderer({
    width: '1/2', minWidth: '280 px', labelPosition: '左侧', align: '起始',
    margin: '8 / 4 / 8 / 4', padding: '2 / 6 / 2 / 6',
  });
  assert.deepEqual(projection.style, {
    gridColumn: 'span 2', minWidth: '280px', margin: '8px 4px 8px 4px',
    padding: '2px 6px 2px 6px', alignSelf: 'start',
  });
  assert.equal(projection.labelPosition, 'left');
  assert.match(rendererStyleAttribute(projection.style), /grid-column:span 2/);
});

test('control type selects a concrete renderer and invalid CSS fails closed', () => {
  assert.equal(projectFieldRenderer({ controlType: '多行文本' }).control, 'textarea');
  assert.equal(projectFieldRenderer({ controlType: '基础资料字段' }).control, 'reference');
  assert.equal(projectFieldRenderer({ minWidth: 'calc(100% - 1px)', margin: 'bad' }).style.minWidth, '0');
});
