import React from 'react';
import './Card.css';

interface CardProps {
  /** 卡片标题 */
  title?: string;
  /** 卡片内容 */
  children: React.ReactNode;
  /** 额外类名 */
  className?: string;
  /** 点击回调 */
  onClick?: () => void;
}

/**
 * 通用卡片组件
 * - 用于包裹内容块
 * - 可选标题和点击事件
 */
export const Card: React.FC<CardProps> = ({
  title,
  children,
  className = '',
  onClick,
}) => {
  const isClickable = !!onClick;

  return (
    <div
      className={`card ${isClickable ? 'card-clickable' : ''} ${className}`}
      onClick={onClick}
      role={isClickable ? 'button' : undefined}
      tabIndex={isClickable ? 0 : undefined}
    >
      {title && <h3 className="card-title">{title}</h3>}
      <div className="card-content">{children}</div>
    </div>
  );
};

export default Card;
