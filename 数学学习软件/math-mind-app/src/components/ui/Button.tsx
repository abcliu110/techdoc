import React from 'react';
import './Button.css';

interface ButtonProps {
  /** 按钮文本 */
  children: React.ReactNode;
  /** 按钮变体 */
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  /** 按钮尺寸 */
  size?: 'sm' | 'md' | 'lg';
  /** 是否禁用 */
  disabled?: boolean;
  /** 点击回调 */
  onClick?: () => void;
  /** 按钮类型 */
  type?: 'button' | 'submit' | 'reset';
  /** data-testid */
  'data-testid'?: string;
  /** 额外类名 */
  className?: string;
  /** 是否显示加载状态 */
  loading?: boolean;
}

/**
 * 通用按钮组件
 * @description 提供统一的按钮样式和交互行为
 */
export const Button: React.FC<ButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  disabled = false,
  onClick,
  type = 'button',
  'data-testid': dataTestId,
  className = '',
  loading = false,
}) => {
  const handleClick = () => {
    if (disabled || loading) return;
    onClick?.();
  };

  return (
    <button
      type={type}
      className={`btn btn-${variant} btn-${size} ${className}`}
      disabled={disabled || loading}
      onClick={handleClick}
      data-testid={dataTestId}
    >
      {loading ? <span className="btn-spinner" /> : null}
      <span className={loading ? 'btn-text-loading' : ''}>{children}</span>
    </button>
  );
};

export default Button;
