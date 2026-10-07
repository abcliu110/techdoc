import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Card, Button } from '../components/ui';
import { Ability, AbilityInfo } from '../domain/types';
import './HomePage.css';

/** 五大数学思想主线信息 */
const ABILITY_LIST: AbilityInfo[] = [
  {
    id: Ability.NUMBER_SHAPE_INTEGRATION,
    name: '数形结合',
    description: '用图形表示数量关系，用数量刻画图形特征，实现抽象与直观的统一',
    color: '#4f46e5',
    icon: '📐',
    stepCount: 6,
  },
  {
    id: Ability.UNIT_UNIFICATION,
    name: '单位统一',
    description: '将不同单位的数量转化为相同单位，实现量的等价变换',
    color: '#0891b2',
    icon: '⚖️',
    stepCount: 6,
  },
  {
    id: Ability.WHOLE_PART,
    name: '整体与部分',
    description: '从整体视角分析部分关系，从部分特征推断整体性质',
    color: '#059669',
    icon: '🧩',
    stepCount: 6,
  },
  {
    id: Ability.TRANSFORMATION,
    name: '转化与化归',
    description: '将复杂问题转化为简单问题，将未知问题转化为已知问题',
    color: '#d97706',
    icon: '🔄',
    stepCount: 6,
  },
  {
    id: Ability.EQUATION_BALANCE,
    name: '等量关系与方程',
    description: '建立等量关系，用符号表示未知量，通过等式变形求解',
    color: '#dc2626',
    icon: '⚡',
    stepCount: 6,
  },
];

/**
 * 首页组件
 * @description 展示五大数学思想主线卡片，用户可选择开始学习
 */
const HomePage: React.FC = () => {
  const navigate = useNavigate();

  const handleStartLearning = (abilityId: string) => {
    navigate(`/learn/${abilityId}`);
  };

  const handleViewProfile = () => {
    navigate('/profile');
  };

  return (
    <div className="home-page" data-testid="page-home">
      <header className="home-header">
        <h1 className="home-title">数学思维启发系统</h1>
        <p className="home-subtitle">
          通过五大数学思想主线，开启深度学习之旅
        </p>
      </header>

      <main className="home-content">
        <section className="ability-section">
          <h2 className="section-title">选择学习主线</h2>
          <div className="ability-grid">
            {ABILITY_LIST.map((ability) => (
              <Card
                key={ability.id}
                data-testid={`card-ability-${ability.id}`}
                clickable
                onClick={() => handleStartLearning(ability.id)}
                icon={<span style={{ fontSize: '24px' }}>{ability.icon}</span>}
                title={ability.name}
                className="ability-card"
                footer={
                  <div className="ability-card-footer">
                    <span className="step-count">{ability.stepCount} 个学习步骤</span>
                    <Button
                      variant="primary"
                      size="sm"
                      data-testid={`btn-start-${ability.id}`}
                      onClick={() => {
                        handleStartLearning(ability.id);
                      }}
                    >
                      开始学习
                    </Button>
                  </div>
                }
              >
                <p className="ability-description">{ability.description}</p>
              </Card>
            ))}
          </div>
        </section>

        <section className="profile-section">
          <Card
            data-testid="card-view-profile"
            clickable
            onClick={handleViewProfile}
            icon={<span style={{ fontSize: '24px' }}>📊</span>}
            title="查看能力画像"
          >
            <p className="profile-description">
              了解你在各个数学思想主线上的发展状态和能力等级
            </p>
            <Button
              variant="secondary"
              data-testid="btn-view-profile"
              onClick={() => {
                handleViewProfile();
              }}
            >
              查看我的能力画像
            </Button>
          </Card>
        </section>
      </main>

      <footer className="home-footer">
        <p>数学思维启发型学习系统 v1.0</p>
      </footer>
    </div>
  );
};

export default HomePage;
