import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { StepFeedback } from './StepFeedback';

/**
 * StepFeedback 组件单元测试
 * @description 测试步骤反馈组件的渲染和交互
 */
describe('StepFeedback', () => {
  describe('渲染测试', () => {
    it('应该正确渲染成功反馈', () => {
      render(<StepFeedback type="success" message="操作成功！" />);

      const feedback = screen.getByTestId('feedback-success');
      expect(feedback).toBeInTheDocument();
      expect(feedback).toHaveTextContent('操作成功！');
      expect(feedback).toHaveClass('step-feedback-success');
    });

    it('应该正确渲染错误反馈', () => {
      render(<StepFeedback type="error" message="操作失败！" />);

      const feedback = screen.getByTestId('feedback-error');
      expect(feedback).toBeInTheDocument();
      expect(feedback).toHaveTextContent('操作失败！');
      expect(feedback).toHaveClass('step-feedback-error');
    });

    it('应该正确渲染提示反馈', () => {
      render(<StepFeedback type="hint" message="提示信息" />);

      const feedback = screen.getByTestId('feedback-hint');
      expect(feedback).toBeInTheDocument();
      expect(feedback).toHaveTextContent('提示信息');
      expect(feedback).toHaveClass('step-feedback-hint');
    });

    it('应该正确渲染信息反馈', () => {
      render(<StepFeedback type="info" message="信息内容" />);

      const feedback = screen.getByTestId('feedback-info');
      expect(feedback).toBeInTheDocument();
      expect(feedback).toHaveTextContent('信息内容');
      expect(feedback).toHaveClass('step-feedback-info');
    });
  });

  describe('图标显示', () => {
    it('成功反馈应该显示正确的图标', () => {
      render(<StepFeedback type="success" message="成功" />);

      const icon = screen.getByText('🎉');
      expect(icon).toBeInTheDocument();
      expect(icon).toHaveClass('step-feedback-icon');
    });

    it('错误反馈应该显示正确的图标', () => {
      render(<StepFeedback type="error" message="错误" />);

      const icon = screen.getByText('❌');
      expect(icon).toBeInTheDocument();
    });

    it('提示反馈应该显示正确的图标', () => {
      render(<StepFeedback type="hint" message="提示" />);

      const icon = screen.getByText('💡');
      expect(icon).toBeInTheDocument();
    });

    it('信息反馈应该显示正确的图标', () => {
      render(<StepFeedback type="info" message="信息" />);

      const icon = screen.getByText('ℹ️');
      expect(icon).toBeInTheDocument();
    });
  });

  describe('消息内容', () => {
    it('应该正确显示消息文本', () => {
      const testMessage = '这是一个测试消息';
      render(<StepFeedback type="success" message={testMessage} />);

      const messageElement = screen.getByText(testMessage);
      expect(messageElement).toBeInTheDocument();
      expect(messageElement).toHaveClass('step-feedback-message');
    });

    it('应该支持空消息', () => {
      render(<StepFeedback type="info" message="" />);

      const feedback = screen.getByTestId('feedback-info');
      expect(feedback).toBeInTheDocument();
      // 空消息时，消息元素可能存在但内容为空
    });

    it('应该支持长消息文本', () => {
      const longMessage = '这是一段很长的反馈消息，用于测试组件是否能正确处理长文本内容。'.repeat(5);
      render(<StepFeedback type="success" message={longMessage} />);

      const feedback = screen.getByTestId('feedback-success');
      expect(feedback).toHaveTextContent(longMessage);
    });
  });

  describe('CSS类名', () => {
    it('每个反馈类型应该有对应的CSS类名', () => {
      const types: Array<'success' | 'error' | 'hint' | 'info'> = ['success', 'error', 'hint', 'info'];

      types.forEach(type => {
        render(<StepFeedback type={type} message="测试" />);
        const feedback = screen.getByTestId(`feedback-${type}`);
        expect(feedback).toHaveClass(`step-feedback-${type}`);
      });
    });
  });

  describe('组件结构', () => {
    it('应该包含图标和消息两个子元素', () => {
      render(<StepFeedback type="success" message="测试" />);

      const feedback = screen.getByTestId('feedback-success');
      const icon = feedback.querySelector('.step-feedback-icon');
      const message = feedback.querySelector('.step-feedback-message');

      expect(icon).toBeInTheDocument();
      expect(message).toBeInTheDocument();
    });
  });
});
