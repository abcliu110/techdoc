import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import {
  buildAuditMatrix,
  runQualityGateMatrix,
} from '../prototype/geometry-audit.mjs';

const contract = JSON.parse(await readFile(new URL('../design/visual-contract.json', import.meta.url), 'utf8'));

test('the executable matrix covers every required state and viewport candidate', () => {
  const css = '@media (max-width: 480px) {}';
  const matrix = buildAuditMatrix(contract, css);
  const expectedViewports = new Set([390, 479, 480, 481, 665, 768, 1024, 1280, 1440, 1920]);

  assert.equal(matrix.length, expectedViewports.size * contract.requiredStates.length);
  for (const state of contract.requiredStates) {
    const widths = new Set(matrix.filter((sample) => sample.state === state).map((sample) => sample.width));
    assert.deepEqual(widths, expectedViewports);
  }
});

test('matrix execution fails closed on viewport mismatch or missing evidence', async () => {
  const smallContract = {
    ...contract,
    requiredViewports: [{ width: 390, height: 844, name: 'mobile' }],
    requiredStates: ['design.mobile'],
  };
  const result = await runQualityGateMatrix({
    contract: smallContract,
    setViewport: async () => {},
    setState: async () => {},
    readMechanical: async () => ({ status: 'PASS', viewport: { width: 1280, height: 800 } }),
    verifyInteraction: async () => 'PASS',
    verifyVisual: async () => null,
  });

  assert.equal(result.status, 'BLOCKED');
  assert.equal(result.samples[0].mechanical, 'BLOCKED');
  assert.equal(result.samples[0].visual, null);
});

test('a confirmed sample failure dominates incomplete matrix evidence', async () => {
  const smallContract = {
    ...contract,
    requiredViewports: [{ width: 390, height: 844, name: 'mobile' }],
    requiredStates: ['design.mobile'],
  };
  const result = await runQualityGateMatrix({
    contract: smallContract,
    setViewport: async () => {},
    setState: async () => {},
    readMechanical: async ({ viewport }) => ({ status: 'FAIL', viewport }),
    verifyInteraction: async () => null,
    verifyVisual: async () => null,
  });

  assert.equal(result.status, 'FAIL');
  assert.equal(result.samples[0].status, 'FAIL');
});

test('matrix passes only when every required evidence channel passes', async () => {
  const smallContract = {
    ...contract,
    requiredViewports: [{ width: 390, height: 844, name: 'mobile' }],
    requiredStates: ['design.mobile'],
  };
  const calls = [];
  const result = await runQualityGateMatrix({
    contract: smallContract,
    setViewport: async (viewport) => calls.push(`viewport:${viewport.width}`),
    setState: async (state) => calls.push(`state:${state}`),
    readMechanical: async ({ viewport }) => ({ status: 'PASS', viewport }),
    verifyInteraction: async () => 'PASS',
    verifyVisual: async () => 'PASS',
  });

  assert.deepEqual(calls, ['viewport:390', 'state:design.mobile']);
  assert.equal(result.status, 'PASS');
  assert.equal(result.samples[0].status, 'PASS');
});
