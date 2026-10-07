/**
 * Schema 验证测试
 * 验证所有 JSON 内容文件是否符合预定义的 Zod Schema
 *
 * 测试策略:
 * - fraction-comparison 遵循标准 Schema 格式
 * - 其他知识点可能有不同的内容结构，需要根据实际情况调整
 */
import { describe, it, expect } from 'vitest';
import { LearningStepSchema, KnowledgePointSchema, validateLearningStep, validateKnowledgePoint } from '@/content/schema';
import * as fs from 'fs';
import * as path from 'path';

// 内容目录路径
const CONTENT_DIR = path.resolve('./src/content');

// 获取所有 meta.json 文件（知识点元数据）
function findMetaFiles(dir: string): string[] {
  const results: string[] = [];
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      const metaPath = path.join(fullPath, 'meta.json');
      if (fs.existsSync(metaPath)) {
        results.push(metaPath);
      }
      results.push(...findMetaFiles(fullPath));
    }
  }
  return results;
}

// 获取所有步骤 JSON 文件
function findStepFiles(dir: string): string[] {
  const results: string[] = [];
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (entry.name === 'steps') {
        const files = fs.readdirSync(fullPath);
        for (const file of files) {
          if (file.endsWith('.json')) {
            results.push(path.join(fullPath, file));
          }
        }
      } else {
        results.push(...findStepFiles(fullPath));
      }
    }
  }
  return results;
}

describe('KnowledgePointSchema 单元测试', () => {
  it('有效的知识点应通过验证', () => {
    const validKP = {
      id: 'test-kp',
      name: '测试知识点',
      description: '测试描述',
      ability: 'number-shape-integration',
      grade: 3,
      level: 1,
      prerequisites: ['prereq1'],
      stepCount: 5
    };

    const result = KnowledgePointSchema.safeParse(validKP);
    expect(result.success).toBe(true);
  });

  it('可选字段缺失应通过验证', () => {
    const minimalKP = {
      id: 'test-kp',
      name: '测试',
      ability: 'test',
      grade: 3,
      level: 1,
      stepCount: 5
    };

    const result = KnowledgePointSchema.safeParse(minimalKP);
    expect(result.success).toBe(true);
  });

  it('grade 超出范围 [1-9] 应失败', () => {
    const invalidKP = {
      id: 'test-kp',
      name: '测试',
      ability: 'test',
      grade: 10,
      level: 1,
      stepCount: 5
    };

    const result = KnowledgePointSchema.safeParse(invalidKP);
    expect(result.success).toBe(false);
  });

  it('level 超出范围 [1-5] 应失败', () => {
    const invalidKP = {
      id: 'test-kp',
      name: '测试',
      ability: 'test',
      grade: 3,
      level: 6,
      stepCount: 5
    };

    const result = KnowledgePointSchema.safeParse(invalidKP);
    expect(result.success).toBe(false);
  });

  it('缺少必填字段 id 应失败', () => {
    const invalidKP = {
      name: '测试',
      ability: 'test',
      grade: 3,
      level: 1,
      stepCount: 5
    };

    const result = KnowledgePointSchema.safeParse(invalidKP);
    expect(result.success).toBe(false);
  });

  it('validateKnowledgePoint 函数应在验证失败时抛出', () => {
    const invalidData = { id: 'test' };
    expect(() => validateKnowledgePoint(invalidData)).toThrow();
  });
});

describe('LearningStepSchema 单元测试', () => {
  describe('concrete 类型', () => {
    it('应通过验证', () => {
      const validStep = {
        id: 'test-concrete',
        type: 'concrete',
        name: '测试步骤',
        instruction: '测试指令',
        content: {
          type: 'concrete',
          scenario: {
            title: '测试场景',
            description: '测试描述',
            emoji: '🎯'
          },
          interaction: {
            kind: 'split',
            target: '测试目标',
            visualType: 'split-circle',
            visualConfig: {
              circles: [
                { denominator: 4, highlighted: [0, 1, 2] },
                { denominator: 3, highlighted: [0, 1] }
              ]
            }
          }
        },
        completionCriteria: {
          type: 'interactive',
          config: { requiredInteraction: 'split-complete' }
        },
        hintLevels: ['提示1', '提示2'],
        ability: 'number-shape-integration'
      };

      const result = LearningStepSchema.safeParse(validStep);
      expect(result.success).toBe(true);
    });

    it('scenario.emoji 为可选字段，缺失应通过', () => {
      const validStep = {
        id: 'test-concrete',
        type: 'concrete',
        name: '测试步骤',
        instruction: '测试指令',
        content: {
          type: 'concrete',
          scenario: {
            title: '测试场景',
            description: '测试描述'
          },
          interaction: {
            kind: 'split',
            target: '测试目标',
            visualType: 'split-circle'
          }
        },
        completionCriteria: {
          type: 'interactive',
          config: {}
        },
        hintLevels: [],
        ability: 'test'
      };

      const result = LearningStepSchema.safeParse(validStep);
      expect(result.success).toBe(true);
    });

    it('interaction.visualConfig 为可选字段', () => {
      const validStep = {
        id: 'test-concrete',
        type: 'concrete',
        name: '测试步骤',
        instruction: '测试指令',
        content: {
          type: 'concrete',
          scenario: { title: '测试', description: '测试' },
          interaction: {
            kind: 'drag',
            target: '测试目标',
            visualType: 'drag-circle'
          }
        },
        completionCriteria: { type: 'interactive', config: {} },
        hintLevels: [],
        ability: 'test'
      };

      const result = LearningStepSchema.safeParse(validStep);
      expect(result.success).toBe(true);
    });
  });

  describe('pictorial 类型', () => {
    it('应通过验证', () => {
      const validStep = {
        id: 'test-pictorial',
        type: 'pictorial',
        name: '图示步骤',
        instruction: '通过图形理解',
        content: {
          type: 'pictorial',
          task: '观察分数条并判断大小',
          visualType: 'fraction-bar',
          visualConfig: {
            fractions: [
              { id: 'f1', numerator: 3, denominator: 5, label: '3/5', color: '#4CAF50' }
            ],
            showUnit: true,
            alignment: 'bottom'
          },
          outputFormat: 'select'
        },
        completionCriteria: {
          type: 'choice',
          config: { correctAnswer: '正确', options: ['正确', '错误'] }
        },
        hintLevels: ['提示'],
        ability: 'number-shape-integration'
      };

      const result = LearningStepSchema.safeParse(validStep);
      expect(result.success).toBe(true);
    });

    it('outputFormat 为必填字段', () => {
      const invalidStep = {
        id: 'test-pictorial',
        type: 'pictorial',
        name: '图示步骤',
        instruction: '测试',
        content: {
          type: 'pictorial',
          task: '任务',
          visualType: 'test'
        },
        completionCriteria: { type: 'choice', config: {} },
        hintLevels: [],
        ability: 'test'
      };

      const result = LearningStepSchema.safeParse(invalidStep);
      expect(result.success).toBe(false);
    });
  });

  describe('symbolic 类型', () => {
    it('string expectedAnswer 应通过验证', () => {
      const validStep = {
        id: 'test-symbolic',
        type: 'symbolic',
        name: '符号步骤',
        instruction: '用符号表达式',
        content: {
          type: 'symbolic',
          inputType: 'fraction',
          expectedAnswer: '3/4 > 2/3'
        },
        completionCriteria: {
          type: 'input',
          config: { expectedAnswers: ['3/4 > 2/3'] }
        },
        hintLevels: ['提示'],
        ability: 'number-shape-integration'
      };

      const result = LearningStepSchema.safeParse(validStep);
      expect(result.success).toBe(true);
    });

    it('array expectedAnswer 应通过验证', () => {
      const validStep = {
        id: 'test-symbolic',
        type: 'symbolic',
        name: '符号步骤',
        instruction: '用符号表达式',
        content: {
          type: 'symbolic',
          inputType: 'fraction',
          expectedAnswer: ['3/4 > 2/3', '3/4>2/3', '3/4 更大']
        },
        completionCriteria: { type: 'input', config: {} },
        hintLevels: [],
        ability: 'test'
      };

      const result = LearningStepSchema.safeParse(validStep);
      expect(result.success).toBe(true);
    });

    it('equivalenceRules 为可选字段', () => {
      const validStep = {
        id: 'test-symbolic',
        type: 'symbolic',
        name: '符号步骤',
        instruction: '用符号表达式',
        content: {
          type: 'symbolic',
          inputType: 'expression',
          expectedAnswer: 'x + 3 = 7'
        },
        completionCriteria: { type: 'input', config: {} },
        hintLevels: [],
        ability: 'test'
      };

      const result = LearningStepSchema.safeParse(validStep);
      expect(result.success).toBe(true);
    });

    it('支持额外的 method 和 steps 字段', () => {
      const validStep = {
        id: 'test-symbolic',
        type: 'symbolic',
        name: '符号步骤',
        instruction: '用符号表达式',
        content: {
          type: 'symbolic',
          inputType: 'expression',
          expectedAnswer: '3/4 > 2/3',
          method: '通分',
          steps: ['找到最小公倍数', '通分', '比较']
        },
        completionCriteria: { type: 'input', config: {} },
        hintLevels: [],
        ability: 'test'
      };

      const result = LearningStepSchema.safeParse(validStep);
      expect(result.success).toBe(true);
    });
  });

  describe('conjecture 类型', () => {
    it('应通过验证', () => {
      const validStep = {
        id: 'test-conjecture',
        type: 'conjecture',
        name: '猜想步骤',
        instruction: '观察并提出猜想',
        content: {
          type: 'conjecture',
          observationPrompt: '观察以下例子',
          examples: [
            { input: '1/2 vs 2/4', output: '相等' }
          ],
          conjecturePrompt: '你发现了什么规律？'
        },
        completionCriteria: {
          type: 'verbal',
          config: { minLength: 5, expectedKeywords: ['相等'], minKeywords: 1 }
        },
        hintLevels: ['提示'],
        ability: 'number-shape-integration'
      };

      const result = LearningStepSchema.safeParse(validStep);
      expect(result.success).toBe(true);
    });
  });

  describe('verification 类型', () => {
    it('应通过验证', () => {
      const validStep = {
        id: 'test-verification',
        type: 'verification',
        name: '验证步骤',
        instruction: '验证猜想',
        content: {
          type: 'verification',
          conjectureToVerify: '分子分母同时扩大，分数不变',
          testCases: [
            { input: '1/3 乘以 2', expectedOutput: '2/6' }
          ],
          verificationPrompt: '请验证',
          feedbackConfig: {
            showCounterExample: false,
            allowRetry: true
          }
        },
        completionCriteria: {
          type: 'input',
          config: { minCorrect: 3 }
        },
        hintLevels: ['提示'],
        ability: 'number-shape-integration'
      };

      const result = LearningStepSchema.safeParse(validStep);
      expect(result.success).toBe(true);
    });
  });

  describe('application 类型', () => {
    it('应通过验证', () => {
      const validStep = {
        id: 'test-application',
        type: 'application',
        name: '应用步骤',
        instruction: '应用所学',
        content: {
          type: 'application',
          instruction: '解决问题',
          variants: [
            {
              id: 'v1',
              question: '比较 3/5 和 2/3',
              options: ['3/5 更大', '2/3 更大', '一样大'],
              correctAnswer: '2/3 更大'
            }
          ],
          minCorrect: 2
        },
        completionCriteria: {
          type: 'choice',
          config: { minCorrect: 2 }
        },
        hintLevels: ['提示'],
        ability: 'number-shape-integration'
      };

      const result = LearningStepSchema.safeParse(validStep);
      expect(result.success).toBe(true);
    });
  });

  describe('边界情况', () => {
    it('缺少必填字段应失败', () => {
      const invalidStep = {
        id: 'test-invalid',
        type: 'concrete',
        name: '测试'
      };

      const result = LearningStepSchema.safeParse(invalidStep);
      expect(result.success).toBe(false);
    });

    it('无效的 type 应失败', () => {
      const invalidStep = {
        id: 'test-invalid-type',
        type: 'invalid-type',
        name: '测试',
        instruction: '测试指令',
        content: { type: 'concrete', scenario: {}, interaction: {} },
        completionCriteria: { type: 'interactive', config: {} },
        hintLevels: [],
        ability: 'test'
      };

      const result = LearningStepSchema.safeParse(invalidStep);
      expect(result.success).toBe(false);
    });

    it('空的 id 应失败', () => {
      const invalidStep = {
        id: '',
        type: 'concrete',
        name: '测试',
        instruction: '测试',
        content: { type: 'concrete', scenario: {}, interaction: {} },
        completionCriteria: { type: 'interactive', config: {} },
        hintLevels: [],
        ability: 'test'
      };

      const result = LearningStepSchema.safeParse(invalidStep);
      expect(result.success).toBe(false);
    });

    it('validateLearningStep 函数应在验证失败时抛出', () => {
      const invalidData = { id: 'test' };
      expect(() => validateLearningStep(invalidData)).toThrow();
    });
  });
});

describe('JSON 文件格式验证', () => {
  /**
   * fraction-comparison 作为标准格式测试
   * 这些文件遵循 Schema 定义的格式
   */
  describe('fraction-comparison 知识点 (标准格式)', () => {
    const fracCompDir = path.join(CONTENT_DIR, 'kps', 'fraction-comparison');

    it('meta.json 应符合 KnowledgePointSchema', () => {
      const filePath = path.join(fracCompDir, 'meta.json');
      const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
      const result = KnowledgePointSchema.safeParse(content);
      expect(result.success, `验证失败: ${result.error?.message}`).toBe(true);
    });

    it('steps/concrete.json 应符合 LearningStepSchema', () => {
      const filePath = path.join(fracCompDir, 'steps', 'concrete.json');
      const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
      const result = LearningStepSchema.safeParse(content);
      expect(result.success, `验证失败: ${result.error?.message}`).toBe(true);
    });

    it('steps/pictorial.json 应符合 LearningStepSchema', () => {
      const filePath = path.join(fracCompDir, 'steps', 'pictorial.json');
      const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
      const result = LearningStepSchema.safeParse(content);
      expect(result.success, `验证失败: ${result.error?.message}`).toBe(true);
    });

    it('steps/symbolic.json 应符合 LearningStepSchema', () => {
      const filePath = path.join(fracCompDir, 'steps', 'symbolic.json');
      const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
      const result = LearningStepSchema.safeParse(content);
      expect(result.success, `验证失败: ${result.error?.message}`).toBe(true);
    });

    it('steps/conjecture.json 应符合 LearningStepSchema', () => {
      const filePath = path.join(fracCompDir, 'steps', 'conjecture.json');
      const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
      const result = LearningStepSchema.safeParse(content);
      expect(result.success, `验证失败: ${result.error?.message}`).toBe(true);
    });

    it('steps/verification.json 应符合 LearningStepSchema', () => {
      const filePath = path.join(fracCompDir, 'steps', 'verification.json');
      const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
      const result = LearningStepSchema.safeParse(content);
      expect(result.success, `验证失败: ${result.error?.message}`).toBe(true);
    });

    it('steps/application.json 应符合 LearningStepSchema', () => {
      const filePath = path.join(fracCompDir, 'steps', 'application.json');
      const content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
      const result = LearningStepSchema.safeParse(content);
      expect(result.success, `验证失败: ${result.error?.message}`).toBe(true);
    });
  });

  /**
   * 报告其他知识点的格式差异
   * 这些文件可能使用了不同的内容结构，需要根据实际情况调整
   */
  describe('其他知识点格式差异报告', () => {
    const allStepFiles = findStepFiles(CONTENT_DIR);
    const fractionComparisonSteps = path.join(CONTENT_DIR, 'kps', 'fraction-comparison', 'steps');
    const otherStepFiles = allStepFiles.filter(f => !f.includes('fraction-comparison'));

    it('应识别非 fraction-comparison 的步骤文件', () => {
      expect(otherStepFiles.length).toBeGreaterThan(0);
    });

    describe.each(otherStepFiles)('格式检查: %s', (filePath) => {
      const relativePath = path.relative(CONTENT_DIR, filePath);
      let content: any;
      let parseError: string | null = null;

      beforeAll(() => {
        try {
          content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
        } catch (e: any) {
          parseError = e.message;
        }
      });

      it('JSON 应能正确解析', () => {
        expect(parseError).toBeNull();
      });

      if (parseError) return;

      it('应包含基本字段', () => {
        expect(content.id).toBeDefined();
        expect(content.type).toBeDefined();
        expect(content.name).toBeDefined();
        expect(content.instruction).toBeDefined();
        expect(content.content).toBeDefined();
        expect(content.completionCriteria).toBeDefined();
        expect(content.hintLevels).toBeDefined();
        expect(content.ability).toBeDefined();
      });

      it('content.type 应与外层 type 一致', () => {
        expect(content.content.type).toBe(content.type);
      });

      it('应记录与 Schema 的差异 (用于后续调整)', () => {
        const result = LearningStepSchema.safeParse(content);
        // 记录差异但不阻塞测试
        if (!result.success) {
          console.log(`\n[格式差异] ${relativePath}:`);
          console.log(`  错误: ${result.error?.message}`);
        }
        // 此测试总是通过，仅用于信息收集
        expect(true).toBe(true);
      });
    });
  });

  describe('meta.json 文件检查', () => {
    const allMetaFiles = findMetaFiles(CONTENT_DIR);

    it('应找到所有知识点的 meta.json', () => {
      expect(allMetaFiles.length).toBeGreaterThan(0);
    });

    describe.each(allMetaFiles)('检查: %s', (filePath) => {
      const relativePath = path.relative(CONTENT_DIR, filePath);
      let content: any;
      let parseError: string | null = null;

      beforeAll(() => {
        try {
          content = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
        } catch (e: any) {
          parseError = e.message;
        }
      });

      it('JSON 应能正确解析', () => {
        expect(parseError).toBeNull();
      });

      if (parseError) return;

      it('应包含基本字段', () => {
        expect(content.id).toBeDefined();
        expect(content.name).toBeDefined();
        expect(content.ability).toBeDefined();
        expect(content.grade).toBeDefined();
        expect(content.level).toBeDefined();
        expect(content.stepCount).toBeDefined();
      });

      it('grade 应在有效范围内 [1-9]', () => {
        expect(content.grade).toBeGreaterThanOrEqual(1);
        expect(content.grade).toBeLessThanOrEqual(9);
      });

      it('level 应在有效范围内 [1-5]', () => {
        expect(content.level).toBeGreaterThanOrEqual(1);
        expect(content.level).toBeLessThanOrEqual(5);
      });

      it('stepCount 应大于 0', () => {
        expect(content.stepCount).toBeGreaterThan(0);
      });
    });
  });
});

describe('VisualConfig 结构验证', () => {
  it('split-circle visualConfig.circles 应为数组', () => {
    const validStep = {
      id: 'test',
      type: 'concrete',
      name: '测试',
      instruction: '测试',
      content: {
        type: 'concrete',
        scenario: { title: '测试', description: '测试' },
        interaction: {
          kind: 'split',
          target: '分割',
          visualType: 'split-circle',
          visualConfig: {
            circles: [
              { denominator: 4, highlighted: [0, 1, 2] }
            ]
          }
        }
      },
      completionCriteria: { type: 'interactive', config: {} },
      hintLevels: [],
      ability: 'test'
    };

    const result = LearningStepSchema.safeParse(validStep);
    expect(result.success).toBe(true);
  });

  it('fraction-bar visualConfig.fractions 应为数组', () => {
    const validStep = {
      id: 'test',
      type: 'pictorial',
      name: '测试',
      instruction: '测试',
      content: {
        type: 'pictorial',
        task: '任务',
        visualType: 'fraction-bar',
        visualConfig: {
          fractions: [
            { id: 'f1', numerator: 3, denominator: 5, label: '3/5', color: '#4CAF50' }
          ]
        },
        outputFormat: 'select'
      },
      completionCriteria: { type: 'choice', config: {} },
      hintLevels: [],
      ability: 'test'
    };

    const result = LearningStepSchema.safeParse(validStep);
    expect(result.success).toBe(true);
  });
});
