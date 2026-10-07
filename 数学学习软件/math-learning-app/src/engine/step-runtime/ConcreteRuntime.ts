import type { LearningStep, ConcreteContent } from '../../domain/types/learning-step';
import type {
  StepRuntime,
  StepRuntimeState,
  InteractionEvent,
  InteractionResult,
  ValidationResult,
} from './StepRuntime';

/**
 * 具象操作运行时
 * 处理图形操作、拖拽等具象交互
 */
export class ConcreteRuntime implements StepRuntime {
  private content: ConcreteContent | null = null;
  private state: StepRuntimeState = {
    stepId: '',
    data: {},
    completed: false,
    hintsUsed: 0,
    attempts: 0,
  };

  initialize(step: LearningStep): void {
    this.content = step.content as ConcreteContent;
    this.state = {
      stepId: step.id,
      data: {},
      completed: false,
      hintsUsed: 0,
      attempts: 0,
    };
  }

  getState(): StepRuntimeState {
    return { ...this.state };
  }

  handleInteraction(interaction: InteractionEvent): InteractionResult {
    if (!this.content) {
      return { success: false, message: '运行时未初始化' };
    }

    this.state.attempts++;

    const expectedKind = this.content.interaction.kind;

    // 检查交互类型是否匹配
    if (interaction.type !== expectedKind) {
      return {
        success: false,
        message: `期望交互类型: ${expectedKind}`,
      };
    }

    // 处理不同类型的交互
    switch (interaction.type) {
      case 'tap':
        return this.handleTap(interaction);
      case 'drag':
        return this.handleDrag(interaction);
      case 'split':
        return this.handleSplit(interaction);
      case 'select':
        return this.handleSelect(interaction);
      default:
        return { success: false, message: '不支持的交互类型' };
    }
  }

  private handleTap(interaction: InteractionEvent): InteractionResult {
    // 记录点击位置
    this.state.data = {
      ...this.state.data,
      lastTap: interaction.payload,
    };
    return { success: true };
  }

  private handleDrag(interaction: InteractionEvent): InteractionResult {
    // 记录拖拽结果
    this.state.data = {
      ...this.state.data,
      dragResult: interaction.payload,
    };
    return { success: true };
  }

  private handleSplit(interaction: InteractionEvent): InteractionResult {
    const payload = interaction.payload as {
      circleIndex: number;
      segmentIndex: number;
      highlighted: boolean;
    };

    const key = `circle_${payload.circleIndex}_segment_${payload.segmentIndex}`;
    this.state.data = {
      ...this.state.data,
      [key]: payload.highlighted,
    };

    // 检查是否完成所有预期的分割
    const visualConfig = this.content?.interaction.visualConfig as {
      circles?: Array<{ denominator: number; highlighted: number[] }>;
    } | undefined;
    const circles = visualConfig?.circles ?? [];

    let allComplete = true;
    for (const circle of circles) {
      for (const expectedSegment of circle.highlighted) {
        const segmentKey = `circle_${circles.indexOf(circle)}_segment_${expectedSegment}`;
        if (!this.state.data[segmentKey]) {
          allComplete = false;
          break;
        }
      }
    }

    if (allComplete) {
      this.state.completed = true;
      return {
        success: true,
        message: '完成！',
        data: { completed: true },
      };
    }

    return { success: true };
  }

  private handleSelect(interaction: InteractionEvent): InteractionResult {
    this.state.data = {
      ...this.state.data,
      selected: interaction.payload,
    };
    return { success: true };
  }

  isComplete(): boolean {
    return this.state.completed;
  }

  validate(): ValidationResult {
    if (!this.content) {
      return { valid: false, errors: ['运行时未初始化'] };
    }

    // 验证交互是否完成
    if (!this.state.completed) {
      return { valid: false, errors: ['请完成交互操作'] };
    }

    return { valid: true };
  }
}
