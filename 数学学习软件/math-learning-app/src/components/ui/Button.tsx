import React from 'react';
import './Button.css';

interface ButtonProps {
  /** 按钮文本 */
  children: React.ReactNode;
  /** 按钮变体 */
  variant?: 'primary' | 'secondary' | 'ghost';
  /** 尺寸 */
  size?: 'sm' | 'md' | 'lg';
  /** 是否禁用 */
  disabled?: boolean;
  /** 点击回调 */
  onClick?: () => void;
  /** 类型 */
  type?: 'button' | 'submit' | 'reset';
  /** 额外类名 */
  className?: string;
}

/**
 * 通用按钮组件
 * - 只负责渲染，不包含业务逻辑
 * - 所有事件通过 props 传递
 */
export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  disabled = false,
  onClick,
  type = 'button',
  className = '',
}) => {
  return (
    <button
      type={type}
      className={`btn btn-${variant} btn-${size} ${className}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
};

export default Button;
