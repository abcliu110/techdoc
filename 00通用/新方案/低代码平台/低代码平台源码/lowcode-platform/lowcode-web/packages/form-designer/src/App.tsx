/**
 * 表单设计器根组件
 * DndContext 已下沉到 DesignerCanvas（统一管理拖放）
 */
import React from 'react';
import { DesignerShell } from './shell/DesignerShell';

export default function App() {
  return <DesignerShell />;
}
