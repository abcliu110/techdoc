import { create } from 'zustand';

interface UIState {
  /** 移动端模式 */
  isMobile: boolean;
  /** 侧边栏展开状态 */
  sidebarExpanded: boolean;
  /** 当前提示索引 */
  currentHintIndex: number;
  /** Toast 消息 */
  toast: { message: string; type: 'success' | 'error' | 'info' } | null;
}

interface UIActions {
  /** 设置移动端模式 */
  setMobile: (isMobile: boolean) => void;
  /** 切换侧边栏 */
  toggleSidebar: () => void;
  /** 设置提示索引 */
  setHintIndex: (index: number) => void;
  /** 显示 Toast */
  showToast: (message: string, type: 'success' | 'error' | 'info') => void;
  /** 隐藏 Toast */
  hideToast: () => void;
}

type UIStore = UIState & UIActions;

export const useUIStore = create<UIStore>()((set) => ({
  isMobile: false,
  sidebarExpanded: true,
  currentHintIndex: -1,
  toast: null,

  setMobile: (isMobile) => set({ isMobile }),

  toggleSidebar: () =>
    set((state) => ({ sidebarExpanded: !state.sidebarExpanded })),

  setHintIndex: (index) => set({ currentHintIndex: index }),

  showToast: (message, type) => set({ toast: { message, type } }),

  hideToast: () => set({ toast: null }),
}));
