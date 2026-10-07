import React, { useState } from 'react';
import './Input.css';

interface InputProps {
  /** 输入框值 */
  value: string;
  /** 值变化回调 */
  onChange: (value: string) => void;
  /** 占位符 */
  placeholder?: string;
  /** 输入框类型 */
  type?: 'text' | 'number' | 'email' | 'password';
  /** data-testid */
  'data-testid'?: string;
  /** 是否禁用 */
  disabled?: boolean;
  /** 是否错误状态 */
  error?: boolean;
  /** 错误信息 */
  errorMessage?: string;
  /** 标签 */
  label?: string;
  /** 额外类名 */
  className?: string;
  /** 输入验证器 */
  validator?: (value: string) => boolean;
}

/**
 * 通用输入框组件
 * @description 提供统一的输入框样式和验证行为
 */
export const Input: React.FC<InputProps> = ({
  value,
  onChange,
  placeholder,
  type = 'text',
  'data-testid': dataTestId,
  disabled = false,
  error = false,
  errorMessage,
  label,
  className = '',
  validator,
}) => {
  const [touched, setTouched] = useState(false);
  const [internalError, setInternalError] = useState(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = e.target.value;
    onChange(newValue);

    if (validator) {
      setInternalError(!validator(newValue));
    }
  };

  const handleBlur = () => {
    setTouched(true);
    if (validator) {
      setInternalError(!validator(value));
    }
  };

  const showError = (touched || error) && (error || internalError);

  return (
    <div className={`input-wrapper ${className}`}>
      {label && (
        <label className="input-label" data-testid={`${dataTestId}-label`}>
          {label}
        </label>
      )}
      <input
        type={type}
        value={value}
        onChange={handleChange}
        onBlur={handleBlur}
        placeholder={placeholder}
        disabled={disabled}
        className={`input ${showError ? 'input-error' : ''}`}
        data-testid={dataTestId}
        aria-invalid={showError}
        aria-describedby={showError && dataTestId ? `${dataTestId}-error` : undefined}
      />
      {showError && errorMessage && (
        <span
          className="input-error-message"
          id={`${dataTestId}-error`}
          data-testid={`${dataTestId}-error-message`}
        >
          {errorMessage}
        </span>
      )}
    </div>
  );
};

export default Input;
