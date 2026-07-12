import React from 'react';
import ReactDOM from 'react-dom/client';
import { ConfigProvider } from 'antd';
import App from './App';
import { designerTheme } from './theme/designer-theme';
import './styles/global.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <ConfigProvider theme={designerTheme}>
      <App />
    </ConfigProvider>
  </React.StrictMode>
);
