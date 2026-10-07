import React from 'react';
import './Card.css';

interface CardProps {
  /** 卡片标题 */
  title?: string;
  /** 卡片内容 */
  children: React.ReactNode;
  /** data-testid */
  'data-testid'?: string;
  /** 额外类名 */
  className?: string;
  /** 点击回调 */
  onClick?: () => void;
  /** 是否可点击 */
  clickable?: boolean;
  /** 卡片头部图标 */
  icon?: React.ReactNode;
  /** 底部操作区域 */
  footer?: React.ReactNode;
}

/**
 * 通用卡片组件
 * @description 用于展示分组信息和可点击的导航卡片
 */
export const Card: React.FC<CardProps> = ({
  title,
  children,
  'data-testid': dataTestId,
  className = '',
  onClick,
  clickable = false,
  icon,
  footer,
}) => {
  const handleClick = () => {
    if (clickable && onClick) {
      onClick();
    }
  };

  const cardClasses = [
    'card',
    clickable ? 'card-clickable' : '',
    className,
  ].filter(Boolean).join(' ');

  return (
    <div
      className={cardClasses}
      data-testid={dataTestId}
      onClick={handleClick}
      role={clickable ? 'button' : undefined}
      tabIndex={clickable ? 0 : undefined}
      onKeyDown={clickable ? (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          handleClick();
        }
      } : undefined}
    >
      {title && (
        <div className="card-header">
          {icon && <span className="card-icon">{icon}</span>}
          <h3 className="card-title">{title}</h3>
        </div>
      )}
      <div className="card-content">
        {children}
      </div>
      {footer && (
        <div className="card-footer">
          {footer}
        </div>
      )}
    </div>
  );
};

export default Card;
