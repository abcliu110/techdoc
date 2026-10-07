import React, { useState } from 'react';
import { SplitCircle, FractionBar } from '../components/visuals';

/**
 * 交互测试页面
 * @description 用于测试可交互组件
 */
const InteractionTestPage: React.FC = () => {
  const [splitHighlight, setSplitHighlight] = useState<number[]>([]);
  const [barHighlight, setBarHighlight] = useState<number[]>([]);

  return (
    <div style={{ padding: '20px' }}>
      <h1>交互测试页面</h1>

      <section>
        <h2>分割圆测试</h2>
        <div data-testid="interactive-split-circle">
          <SplitCircle
            denominator={4}
            highlighted={splitHighlight}
            onHighlightChange={setSplitHighlight}
            data-testid="test-split-circle"
            interactive={true}
          />
        </div>
        <p data-testid="split-highlight-count">高亮数量: {splitHighlight.length}</p>
      </section>

      <section>
        <h2>分数条测试</h2>
        <div data-testid="interactive-fraction-bar">
          <FractionBar
            denominator={4}
            highlighted={barHighlight}
            onHighlightChange={setBarHighlight}
            data-testid="test-fraction-bar"
            interactive={true}
          />
        </div>
        <p data-testid="bar-highlight-count">高亮数量: {barHighlight.length}</p>
      </section>
    </div>
  );
};

export default InteractionTestPage;
