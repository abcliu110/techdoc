import React from 'react';
import type {
  LearningStep,
  ConcreteContent,
  SymbolicContent,
  ConjectureContent,
  VerificationContent,
  ApplicationContent,
  PictorialContent,
} from '../../domain/types/learning-step';
import { StepType } from '../../domain/types/learning-step';
import { ConcreteStep } from './ConcreteStep';
import { SymbolicStep } from './SymbolicStep';
import { ConjectureStep } from './ConjectureStep';
import { ApplicationStep } from './ApplicationStep';
import { PictorialStep } from './PictorialStep';
import { VerificationStep } from './VerificationStep';
import './StepContainer.css';

interface StepContainerProps {
  /** 当前步骤 */
  step: LearningStep;
  /** 步骤索引 */
  stepIndex: number;
  /** 总步骤数 */
  totalSteps: number;
  /** 完成回调 */
  onComplete: (data: Record<string, unknown>) => void;
  /** 请求提示回调 */
  onHint?: () => void;
}

/**
 * 步骤容器组件
 * 根据步骤类型渲染对应的步骤组件
 */
export const StepContainer: React.FC<StepContainerProps> = ({
  step,
  stepIndex,
  totalSteps,
  onComplete,
  onHint,
}) => {
  const renderStep = () => {
    switch (step.type) {
      case StepType.CONCRETE:
        return (
          <ConcreteStep
            content={step.content as ConcreteContent}
            stepName={step.name}
            stepIndex={stepIndex}
            totalSteps={totalSteps}
            hintLevels={step.hintLevels}
            onComplete={onComplete}
            onHint={onHint}
          />
        );

      case StepType.SYMBOLIC:
        return (
          <SymbolicStep
            content={step.content as SymbolicContent}
            stepName={step.name}
            stepIndex={stepIndex}
            totalSteps={totalSteps}
            hintLevels={step.hintLevels}
            onComplete={onComplete}
            onHint={onHint}
          />
        );

      case StepType.CONJECTURE:
        return (
          <ConjectureStep
            content={step.content as ConjectureContent}
            stepName={step.name}
            stepIndex={stepIndex}
            totalSteps={totalSteps}
            hintLevels={step.hintLevels}
            onComplete={onComplete}
            onHint={onHint}
          />
        );

      case StepType.APPLICATION:
        return (
          <ApplicationStep
            content={step.content as ApplicationContent}
            stepName={step.name}
            stepIndex={stepIndex}
            totalSteps={totalSteps}
            hintLevels={step.hintLevels}
            onComplete={onComplete}
            onHint={onHint}
          />
        );

      case StepType.PICTORIAL:
        return (
          <PictorialStep
            content={step.content as PictorialContent}
            stepName={step.name}
            stepIndex={stepIndex}
            totalSteps={totalSteps}
            hintLevels={step.hintLevels}
            onComplete={onComplete}
            onHint={onHint}
          />
        );

      case StepType.VERIFICATION:
        return (
          <VerificationStep
            content={step.content as VerificationContent}
            stepName={step.name}
            stepIndex={stepIndex}
            totalSteps={totalSteps}
            hintLevels={step.hintLevels}
            onComplete={onComplete}
            onHint={onHint}
          />
        );

      default:
        return (
          <div className="step-placeholder">
            <p>步骤类型 "{step.type}" 的组件尚未实现</p>
            <p>步骤名称: {step.name}</p>
            <button onClick={() => onComplete({})}>跳过此步骤</button>
          </div>
        );
    }
  };

  return <div className="step-container">{renderStep()}</div>;
};

export default StepContainer;
