import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card, Button } from '../components/ui';
import { AppLayout } from '../components/layout/AppLayout';
import { createWebPlatform } from '../platform';
import { Ability } from '../domain/types/ability';
import './Home.css';

interface KnowledgePointInfo {
  id: string;
  name: string;
  description: string;
  ability: string;
  grade: number;
}

/**
 * 数学思想配置
 */
const MATH_CONCEPTS = [
  {
    id: 'number-shape-integration',
    name: '数形结合',
    description: '用图形理解数量关系，用数量刻画图形特征',
    emoji: '📐',
    route: 'fraction-comparison'
  },
  {
    id: 'unit-unification',
    name: '单位统一',
    description: '理解单位换算，掌握进率关系',
    emoji: '📏',
    route: 'unit-unification'
  },
  {
    id: 'whole-part-thinking',
    name: '整体部分思想',
    description: '理解整体与部分的关系',
    emoji: '🔄',
    route: 'whole-part-thinking'
  },
  {
    id: 'transformation',
    name: '转化化归思想',
    description: '将复杂问题转化为简单问题',
    emoji: '🔀',
    route: 'transformation'
  },
  {
    id: 'equation-reasoning',
    name: '等量关系与方程',
    description: '理解等量关系，用方程解决问题',
    emoji: '⚖️',
    route: 'equation-reasoning'
  }
];

/**
 * 首页组件
 * 显示数学思想选择和知识点列表
 */
export const HomePage: React.FC = () => {
  const navigate = useNavigate();
  const [knowledgePoints, setKnowledgePoints] = useState<KnowledgePointInfo[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const loadKnowledgePoints = async () => {
      const platform = createWebPlatform();
      const kps = await platform.contentRepo.listKnowledgePoints();
      setKnowledgePoints(kps);
      setIsLoading(false);
    };
    loadKnowledgePoints();
  }, []);

  const handleStartLearning = (knowledgePointId: string) => {
    navigate(`/learn/${knowledgePointId}`);
  };

  const handleViewProfile = () => {
    navigate('/profile');
  };

  const getAbilityLabel = (ability: string): string => {
    const labels: Record<string, string> = {
      [Ability.NUMBER_SHAPE_INTEGRATION]: '数形结合',
      [Ability.UNIT_UNIFICATION]: '单位统一',
      [Ability.WHOLE_PART_THINKING]: '整体部分思想',
      [Ability.TRANSFORMATION]: '转化化归思想',
      [Ability.EQUATION_REASONING]: '等量关系与方程',
    };
    return labels[ability] ?? ability;
  };

  return (
    <AppLayout title="数学学习">
      <div className="home-page">
        <section className="hero-section">
          <h2 className="hero-title">欢迎来到数学学习</h2>
          <p className="hero-subtitle">
            通过数形结合，深度理解数学概念
          </p>
        </section>

        <section className="concepts-section">
          <h3 className="section-title">数学思想</h3>
          <div className="concepts-grid">
            {MATH_CONCEPTS.map((concept) => (
              <Card
                key={concept.id}
                className="concept-card"
                onClick={() => handleStartLearning(concept.route)}
              >
                <div className="concept-icon">{concept.emoji}</div>
                <h4>{concept.name}</h4>
                <p>{concept.description}</p>
              </Card>
            ))}
            <Card className="concept-card" onClick={handleViewProfile}>
              <div className="concept-icon">📊</div>
              <h4>能力报告</h4>
              <p>查看你的能力成长和详细分析</p>
            </Card>
          </div>
        </section>

        <section className="topics-section">
          <h3 className="section-title">学习内容</h3>
          {isLoading ? (
            <div className="loading">加载中...</div>
          ) : (
            <div className="topics-grid">
              {knowledgePoints.map((kp) => (
                <Card
                  key={kp.id}
                  className="topic-card"
                  onClick={() => handleStartLearning(kp.id)}
                >
                  <div className="topic-emoji">📚</div>
                  <h4>{kp.name}</h4>
                  <p>{kp.description}</p>
                  <div className="topic-meta">
                    <span className="meta-tag">{getAbilityLabel(kp.ability)}</span>
                    <span className="meta-tag">三年级</span>
                  </div>
                  <Button variant="primary" size="sm">
                    开始学习
                  </Button>
                </Card>
              ))}
            </div>
          )}
        </section>
      </div>
    </AppLayout>
  );
};

export default HomePage;
