import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    // 不使用jsdom，只测试纯逻辑
    environment: 'node',
  },
});
