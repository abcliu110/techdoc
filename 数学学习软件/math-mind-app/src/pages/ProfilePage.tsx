import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button, Card } from '../components/ui';
import { useProfileStore } from '../stores';
import { Ability, AbilityLevel, AbilityProfile, RadarDataPoint } from '../domain/types';
import './ProfilePage.css';

/** 能力信息映射 */
const ABILITY_INFO: Record<Ability, { name: string; icon: string; color: string }> = {
  [Ability.NUMBER_SHAPE_INTEGRATION]: { name: '数形结合', icon: '📐', color: '#4f46e5' },
  [Ability.UNIT_UNIFICATION]: { name: '单位统一', icon: '⚖️', color: '#0891b2' },
  [Ability.WHOLE_PART]: { name: '整体与部分', icon: '🧩', color: '#059669' },
  [Ability.TRANSFORMATION]: { name: '转化与化归', icon: '🔄', color: '#d97706' },
  [Ability.EQUATION_BALANCE]: { name: '等量关系与方程', icon: '⚡', color: '#dc2626' },
};

/** 等级标签 */
const LEVEL_LABELS = ['未开始', '初步感知', '正在发展', '已掌握'];

/**
 * 生成雷达图数据
 */
function generateRadarData(profile: AbilityProfile | null): RadarDataPoint[] {
  const abilities = Object.values(Ability);
  return abilities.map((ability) => {
    const state = profile?.states.find((s) => s.ability === ability);
    return {
      ability,
      level: state?.level ?? AbilityLevel.NOT_STARTED,
      maxLevel: AbilityLevel.MASTERED,
      label: ABILITY_INFO[ability].name,
    };
  });
}

/**
 * 雷达图SVG组件
 */
const RadarChart: React.FC<{ data: RadarDataPoint[] }> = ({ data }) => {
  const size = 300;
  const centerX = size / 2;
  const centerY = size / 2;
  const radius = 100;
  const angleStep = (2 * Math.PI) / data.length;

  // 计算每个点的位置
  const points = data.map((d, i) => {
    const angle = i * angleStep - Math.PI / 2;
    const levelRatio = d.level / d.maxLevel;
    const x = centerX + radius * levelRatio * Math.cos(angle);
    const y = centerY + radius * levelRatio * Math.sin(angle);
    return { x, y, ...d };
  });

  // 生成外边框六边形顶点
  const borderPoints = data.map((_, i) => {
    const angle = i * angleStep - Math.PI / 2;
    const x = centerX + radius * Math.cos(angle);
    const y = centerY + radius * Math.sin(angle);
    return `${x},${y}`;
  });

  // 生成数据多边形顶点
  const dataPoints = points.map((p) => `${p.x},${p.y}`).join(' ');

  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} className="radar-chart">
      {/* 外边框 */}
      <polygon
        points={borderPoints.join(' ')}
        fill="none"
        stroke="#e5e7eb"
        strokeWidth="1"
      />

      {/* 内部网格 */}
      {[0.25, 0.5, 0.75, 1].map((ratio, i) => (
        <polygon
          key={i}
          points={data.map((_, j) => {
            const angle = j * angleStep - Math.PI / 2;
            const x = centerX + radius * ratio * Math.cos(angle);
            const y = centerY + radius * ratio * Math.sin(angle);
            return `${x},${y}`;
          }).join(' ')}
          fill="none"
          stroke="#e5e7eb"
          strokeWidth="0.5"
          strokeDasharray="4,4"
        />
      ))}

      {/* 数据区域 */}
      <polygon
        points={dataPoints}
        fill="rgba(79, 70, 229, 0.2)"
        stroke="#4f46e5"
        strokeWidth="2"
      />

      {/* 数据点 */}
      {points.map((p, i) => (
        <circle
          key={i}
          cx={p.x}
          cy={p.y}
          r={6}
          fill={ABILITY_INFO[p.ability].color}
          stroke="white"
          strokeWidth="2"
        />
      ))}

      {/* 标签 */}
      {data.map((d, i) => {
        const angle = i * angleStep - Math.PI / 2;
        const labelRadius = radius + 30;
        const x = centerX + labelRadius * Math.cos(angle);
        const y = centerY + labelRadius * Math.sin(angle);
        const anchor = x < centerX - 10 ? 'end' : x > centerX + 10 ? 'start' : 'middle';

        return (
          <text
            key={i}
            x={x}
            y={y}
            textAnchor={anchor}
            dominantBaseline="middle"
            className="radar-label"
          >
            {d.label}
          </text>
        );
      })}
    </svg>
  );
};

/**
 * 能力画像页面组件
 */
const ProfilePage: React.FC = () => {
  const navigate = useNavigate();
  const { profile, loadProfile } = useProfileStore();
  const [radarData, setRadarData] = useState<RadarDataPoint[]>([]);

  // 初始化示例画像数据
  useEffect(() => {
    const sampleProfile: AbilityProfile = {
      userId: 'default-user',
      states: [
        { ability: Ability.NUMBER_SHAPE_INTEGRATION, level: AbilityLevel.DEVELOPING, evidenceCount: 5, lastPracticedAt: Date.now() },
        { ability: Ability.UNIT_UNIFICATION, level: AbilityLevel.AWARE, evidenceCount: 2, lastPracticedAt: Date.now() - 86400000 },
        { ability: Ability.WHOLE_PART, level: AbilityLevel.NOT_STARTED, evidenceCount: 0, lastPracticedAt: 0 },
        { ability: Ability.TRANSFORMATION, level: AbilityLevel.NOT_STARTED, evidenceCount: 0, lastPracticedAt: 0 },
        { ability: Ability.EQUATION_BALANCE, level: AbilityLevel.NOT_STARTED, evidenceCount: 0, lastPracticedAt: 0 },
      ],
      updatedAt: Date.now(),
    };
    loadProfile(sampleProfile);
  }, [loadProfile]);

  // 生成雷达图数据
  useEffect(() => {
    setRadarData(generateRadarData(profile));
  }, [profile]);

  const handleGoHome = () => {
    navigate('/');
  };

  return (
    <div className="profile-page" data-testid="page-profile">
      <header className="profile-header">
        <button className="back-button" onClick={handleGoHome} data-testid="btn-back">
          ← 返回
        </button>
        <h1 className="page-title">能力画像</h1>
      </header>

      <main className="profile-content">
        <section className="radar-section">
          <h2 className="section-title">能力分布</h2>
          <Card data-testid="card-radar" className="radar-card">
            <div className="radar-container">
              <RadarChart data={radarData} />
            </div>
            <div className="radar-legend">
              <div className="legend-item">
                <span className="legend-level" style={{ backgroundColor: '#e5e7eb' }} />
                <span>未开始 (0)</span>
              </div>
              <div className="legend-item">
                <span className="legend-level" style={{ backgroundColor: '#bfdbfe' }} />
                <span>初步感知 (1)</span>
              </div>
              <div className="legend-item">
                <span className="legend-level" style={{ backgroundColor: '#818cf8' }} />
                <span>正在发展 (2)</span>
              </div>
              <div className="legend-item">
                <span className="legend-level" style={{ backgroundColor: '#4f46e5' }} />
                <span>已掌握 (3)</span>
              </div>
            </div>
          </Card>
        </section>

        <section className="abilities-section">
          <h2 className="section-title">能力详情</h2>
          <div className="abilities-grid">
            {Object.entries(ABILITY_INFO).map(([ability, info]) => {
              const state = profile?.states.find((s) => s.ability === ability);
              const level = state?.level ?? AbilityLevel.NOT_STARTED;
              const evidenceCount = state?.evidenceCount ?? 0;

              return (
                <Card
                  key={ability}
                  data-testid={`card-ability-detail-${ability}`}
                  className="ability-detail-card"
                  icon={<span style={{ fontSize: '24px' }}>{info.icon}</span>}
                  title={info.name}
                >
                  <div className="ability-detail">
                    <div className="ability-level">
                      <span className="level-label">等级</span>
                      <div className="level-indicator">
                        <div
                          className="level-bar"
                          style={{
                            width: `${(level / AbilityLevel.MASTERED) * 100}%`,
                            backgroundColor: info.color,
                          }}
                        />
                      </div>
                      <span className="level-text">{LEVEL_LABELS[level] ?? '未知'}</span>
                    </div>
                    <div className="ability-evidence">
                      <span className="evidence-label">学习证据</span>
                      <span className="evidence-value">{evidenceCount} 条</span>
                    </div>
                    {state?.lastPracticedAt ? (
                      <div className="ability-last-practiced">
                        <span className="last-practiced-label">最近练习</span>
                        <span className="last-practiced-value">
                          {new Date(state.lastPracticedAt).toLocaleDateString('zh-CN')}
                        </span>
                      </div>
                    ) : null}
                  </div>
                </Card>
              );
            })}
          </div>
        </section>

        <section className="actions-section">
          <Button variant="primary" size="lg" onClick={handleGoHome}>
            开始学习
          </Button>
        </section>
      </main>
    </div>
  );
};

export default ProfilePage;
