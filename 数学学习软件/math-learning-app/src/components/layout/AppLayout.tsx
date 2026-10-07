import React, { useEffect } from 'react';
import { useUIStore } from '../../stores/uiStore';
import './AppLayout.css';

interface AppLayoutProps {
  /** 子组件 */
  children: React.ReactNode;
  /** 页面标题 */
  title?: string;
  /** 是否显示返回按钮 */
  showBack?: boolean;
  /** 返回按钮回调 */
  onBack?: () => void;
}

/**
 * 应用布局组件
 * 提供统一的页面布局结构
 */
export const AppLayout: React.FC<AppLayoutProps> = ({
  children,
  title = '数学学习',
  showBack = false,
  onBack,
}) => {
  const { toast, hideToast } = useUIStore();

  // 自动隐藏 toast
  useEffect(() => {
    if (toast) {
      const timer = setTimeout(() => {
        hideToast();
      }, 3000);
      return () => clearTimeout(timer);
    }
    return undefined;
  }, [toast, hideToast]);

  return (
    <div className="app-layout">
      <header className="app-header">
        {showBack && (
          <button className="back-button" onClick={onBack}>
            ← 返回
          </button>
        )}
        <h1 className="app-title">{title}</h1>
      </header>

      <main className="app-main">{children}</main>

      {toast && (
        <div className={`toast toast-${toast.type}`}>
          {toast.message}
        </div>
      )}
    </div>
  );
};

export default AppLayout;
