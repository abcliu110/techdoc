import { describe, it, expect, beforeEach, vi } from 'vitest';
import { FileSystemContentRepository } from '../../src/platform/content/FileSystemContentRepository';
import type { KnowledgePointMeta, LearningStep } from '../../src/application/ports/ContentRepository';

describe('FileSystemContentRepository', () => {
  let repository: FileSystemContentRepository;

  beforeEach(() => {
    repository = new FileSystemContentRepository();
  });

  describe('listKnowledgePoints', () => {
    it('应该返回知识点列表', async () => {
      const points = await repository.listKnowledgePoints();
      expect(points).toBeDefined();
      expect(Array.isArray(points)).toBe(true);
    });

    it('知识点应有 id 和 name 属性', async () => {
      const points = await repository.listKnowledgePoints();
      if (points.length > 0) {
        expect(points[0]).toHaveProperty('id');
        expect(points[0]).toHaveProperty('name');
      }
    });
  });

  describe('findKnowledgePoint', () => {
    it('当知识点存在时应返回知识点', async () => {
      const points = await repository.listKnowledgePoints();
      if (points.length > 0) {
        const point = await repository.findKnowledgePoint(points[0].id);
        expect(point).not.toBeNull();
        expect(point?.id).toBe(points[0].id);
      }
    });

    it('当知识点不存在时应返回 null', async () => {
      const point = await repository.findKnowledgePoint('non-existent-id');
      expect(point).toBeNull();
    });
  });

  describe('findSteps', () => {
    it('当知识点存在时应返回步骤列表', async () => {
      const steps = await repository.findSteps('fraction-comparison');
      expect(steps).toBeDefined();
      expect(Array.isArray(steps)).toBe(true);
    });

    it('当知识点不存在时应返回空数组', async () => {
      const steps = await repository.findSteps('non-existent-kp');
      expect(steps).toEqual([]);
    });

    it('步骤应有必要的属性', async () => {
      const steps = await repository.findSteps('fraction-comparison');
      if (steps.length > 0) {
        const step = steps[0];
        expect(step).toHaveProperty('id');
        expect(step).toHaveProperty('type');
        expect(step).toHaveProperty('name');
        expect(step).toHaveProperty('content');
      }
    });
  });

  describe('findStep', () => {
    it('当步骤存在时应返回步骤', async () => {
      const steps = await repository.findSteps('fraction-comparison');
      if (steps.length > 0) {
        const stepId = steps[0].id;
        const step = await repository.findStep(stepId);
        expect(step).not.toBeNull();
        expect(step?.id).toBe(stepId);
      }
    });

    it('当步骤不存在时应返回 null', async () => {
      const step = await repository.findStep('non-existent-step');
      expect(step).toBeNull();
    });
  });
});
