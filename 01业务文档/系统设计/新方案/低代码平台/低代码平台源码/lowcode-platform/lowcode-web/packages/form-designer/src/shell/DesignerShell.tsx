import React from 'react';
import { TopBar } from './TopBar';
import { LeftPanel } from './LeftPanel';
import { DesignerCanvas } from '../canvas/DesignerCanvas';
import { RightPanel } from './RightPanel';
import { BottomBar } from './BottomBar';

export function DesignerShell() {
  return (
    <div style={{
      height: '100vh',
      display: 'grid',
      gridTemplateRows: '48px minmax(0, 1fr) 26px',
      background: '#E8EDF4',
      overflow: 'hidden',
    }}>
      <TopBar />
      <div style={{ display: 'grid', gridTemplateColumns: '210px minmax(0, 1fr) 245px', minHeight: 0, overflow: 'hidden' }}>
        <LeftPanel />
        <DesignerCanvas />
        <RightPanel />
      </div>
      <BottomBar />
    </div>
  );
}
