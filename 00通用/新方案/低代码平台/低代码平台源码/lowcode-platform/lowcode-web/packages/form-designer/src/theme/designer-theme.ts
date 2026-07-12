/**
 * 企业级低饱和色主题
 * 符合 T-207 表单设计器 UI 规范
 */
import type { ThemeConfig } from 'antd';

export const designerTheme: ThemeConfig['theme'] = {
  token: {
    // 主色 - 低饱和蓝
    colorPrimary: '#2563EB',
    colorInfo: '#2563EB',

    // 背景
    colorBgLayout: '#E8EDF4',
    colorBgContainer: '#FFFFFF',
    colorBgElevated: '#FFFFFF',
    colorBgSpotlight: '#F3F7FF',

    // 边框
    colorBorder: '#D8DEE8',
    colorBorderSecondary: '#E8EDF4',

    // 文本
    colorText: '#111827',
    colorTextSecondary: '#64748B',
    colorTextTertiary: '#94A3B8',
    colorTextQuaternary: '#CBD5E1',

    // 状态色
    colorSuccess: '#047857',
    colorWarning: '#B45309',
    colorError: '#B91C1C',

    // 字体
    fontFamily: '"Microsoft YaHei UI", "Segoe UI", Arial, sans-serif',
    fontSize: 12,

    // 尺寸
    borderRadius: 4,
    borderRadiusLG: 6,
    borderRadiusSM: 3,

    // 行高
    lineHeight: 1.5,

    // 控件高度
    controlHeight: 28,
    controlHeightLG: 32,
    controlHeightSM: 24,

    // 边距
    padding: 12,
    paddingLG: 16,
    paddingSM: 8,
    paddingXS: 4,

    // 间距
    margin: 12,
    marginLG: 16,
    marginSM: 8,
    marginXS: 4,

    // 投影
    boxShadow: '0 1px 3px rgba(0,0,0,0.08)',
    boxShadowSecondary: '0 4px 12px rgba(0,0,0,0.1)',
  },
  components: {
    Layout: {
      headerBg: '#FFFFFF',
      headerHeight: 48,
      bodyBg: '#E8EDF4',
    },
    Menu: {
      itemBg: 'transparent',
      itemSelectedBg: '#F3F7FF',
      itemSelectedColor: '#2563EB',
    },
    Button: {
      primaryShadow: 'none',
      defaultShadow: 'none',
    },
    Input: {
      paddingBlock: 2,
      paddingInline: 8,
    },
    Select: {
      optionSelectedBg: '#F3F7FF',
    },
    Table: {
      headerBg: '#F5F7FA',
      rowHoverBg: '#F3F7FF',
    },
    Tabs: {
      inkBarColor: '#2563EB',
      itemSelectedColor: '#2563EB',
      itemHoverColor: '#2563EB',
    },
  },
};
