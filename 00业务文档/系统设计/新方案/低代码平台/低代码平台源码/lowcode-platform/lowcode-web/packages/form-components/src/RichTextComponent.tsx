import React from 'react';

export interface RichTextComponentProps {
  value?: string;
  onChange?: (value: string) => void;
  disabled?: boolean;
}

export const RichTextComponent: React.FC<RichTextComponentProps> = ({
  value,
  onChange,
  disabled,
}) => {
  // 简化实现，生产环境应使用专业富文本编辑器（如quill、slate）
  return (
    <textarea
      value={value}
      onChange={(e) => onChange?.(e.target.value)}
      disabled={disabled}
      style={{ width: '100%', minHeight: '200px' }}
      placeholder="富文本编辑器（生产环境集成专业编辑器）"
    />
  );
};
