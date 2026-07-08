/**
 * 表单设计器演示应用 - E2E 测试用
 * 使用 form-designer 包中的 FormDesigner 组件
 */
import React from 'react';
import ReactDOM from 'react-dom/client';
import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import { FormDesigner } from '../src';

const App: React.FC = () => {
  return (
    <ConfigProvider locale={zhCN}>
      <div style={{ height: '100vh', display: 'flex', flexDirection: 'column' }}>
        <div
          style={{
            padding: '12px 24px',
            background: '#001529',
            color: 'white',
            fontSize: '16px',
            fontWeight: 600,
          }}
        >
          🎨 表单设计器 - AI 可控性测试演示
        </div>
        <div style={{ flex: 1, overflow: 'hidden' }}>
          <FormDesigner />
        </div>
      </div>
    </ConfigProvider>
  );
};

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
