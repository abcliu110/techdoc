import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card, Button } from '../components/ui';
import { AppLayout } from '../components/layout/AppLayout';
import { useAbilityProfile } from '../hooks/useAbilityProfile';
import { createWebPlatform } from '../platform';
import type { AbilityReport, RadarDataPoint, TrendDataPoint } from '../shared/interfaces';
import type { AbilityProfile } from '../domain/types/ability-profile';
import { EvidenceType, type LearningEvidence } from '../domain/types/learning-session';
import './Profile.css';

/**
 * 能力报告页面
 * 展示学生能力画像、雷达图、趋势和建议
 */
export const ProfilePage: React.FC = () => {
  const navigate = useNavigate();
  const { profile, isLoading, error, load, getLevelLabel, getAbilityName } = useAbilityProfile();
  const [report, setReport] = useState<AbilityReport | null>(null);
  const [commonMistakes, setCommonMistakes] = useState<string[]>([]);
  const [recommendations, setRecommendations] = useState<string[]>([]);

  // 加载能力画像
  useEffect(() => {
    load('default-user');
  }, [load]);

  // 生成能力报告数据
  useEffect(() => {
    if (!profile) return;

    // 生成雷达图数据
    const radarData: RadarDataPoint[] = profile.states.map((state) => ({
      ability: state.ability,
      level: state.level,
      maxLevel: 3,
      label: getAbilityName(state.ability),
    }));

    // 生成趋势数据（模拟）
    const trend = generateTrendData(profile);

    // 分析常见错误
    const mistakes = analyzeCommonMistakes(profile.totalEvidence);

    // 生成建议
    const recs = generateRecommendations(profile);

    setReport({
      profile,
      radarData,
      trend,
      commonMistakes: mistakes,
      recommendations: recs,
    });

    setCommonMistakes(mistakes);
    setRecommendations(recs);
  }, [profile, getAbilityName]);

  // 生成趋势数据
  const generateTrendData = (profile: AbilityProfile): TrendDataPoint[] => {
    // 尝试从平台获取真实趋势数据
    const platform = createWebPlatform();
    const loadRealTrend = async (): Promise<TrendDataPoint[]> => {
      try {
        if (platform.profileRepo && 'getAbilityTrend' in platform.profileRepo) {
          const trend = await (platform.profileRepo as { getAbilityTrend?: (userId: string, days?: number) => Promise<TrendDataPoint[]> }).getAbilityTrend?.(profile.userId, 7);
          if (trend && trend.length > 0) {
            return trend;
          }
        }
      } catch (e) {
        console.warn('Failed to load real trend data:', e);
      }
      return [];
    };

    // 如果有真实数据则使用，否则生成模拟数据作为后备
    loadRealTrend().then(realTrend => {
      if (realTrend.length > 0) {
        setReport(prev => prev ? { ...prev, trend: realTrend } : prev);
      }
    });

    // 生成模拟趋势数据（后备方案）
    const days = 7;
    const trend: TrendDataPoint[] = [];
    const now = Date.now();
    const dayMs = 24 * 60 * 60 * 1000;

    for (let i = days - 1; i >= 0; i--) {
      const date = new Date(now - i * dayMs);
      const dateStr = `${date.getMonth() + 1}/${date.getDate()}`;

      // 基于当前能力等级生成模拟数据
      const abilities: Record<string, number> = {};
      profile.states.forEach((state) => {
        const baseLevel = state.level;
        // 模拟逐渐增长的趋势
        const variation = Math.random() * 0.5 - 0.25;
        abilities[state.ability] = Math.max(0, Math.min(3, baseLevel - (i * 0.3) + variation));
      });

      trend.push({ date: dateStr, abilities });
    }

    return trend;
  };

  // 分析常见错误
  const analyzeCommonMistakes = (evidence: LearningEvidence[]): string[] => {
    const mistakes: string[] = [];

    const wrongAnswers = evidence.filter(
      (e) => e.type === EvidenceType.ANSWER && !(e.data as { isCorrect: boolean }).isCorrect
    );

    if (wrongAnswers.length > 0) {
      mistakes.push('答案计算需要仔细检查');
    }

    const hintUsage = evidence.filter(
      (e) => e.type === EvidenceType.HINT_USAGE
    );

    if (hintUsage.length > 0) {
      mistakes.push('可以尝试更多提示来理解概念');
    }

    if (evidence.length < 5) {
      mistakes.push('练习量不足，建议增加学习时间');
    }

    return mistakes;
  };

  // 生成学习建议
  const generateRecommendations = (profile: AbilityProfile): string[] => {
    const recs: string[] = [];
    const abilities = profile.states;

    // 找出最弱的能力
    const weakest = abilities
      .filter((s) => s.level < 2)
      .sort((a, b) => a.level - b.level)
      .slice(0, 2);

    weakest.forEach((state) => {
      if (state.level === 0) {
        recs.push(`建议从「${getAbilityName(state.ability)}」的基础概念开始学习`);
      } else {
        recs.push(`「${getAbilityName(state.ability)}」需要更多练习来巩固`);
      }
    });

    // 找出最强的能力
    const strongest = abilities
      .filter((s) => s.level >= 2)
      .sort((a, b) => b.level - a.level);

    if (strongest.length > 0 && strongest[0]) {
      recs.push(`你在「${getAbilityName(strongest[0].ability)}」方面表现优秀，可以挑战更高难度`);
    }

    if (recs.length === 0) {
      recs.push('开始你的数学学习之旅吧！');
    }

    return recs;
  };

  // 渲染雷达图
  const renderRadarChart = (data: RadarDataPoint[]) => {
    const size = 280;
    const center = size / 2;
    const maxRadius = size / 2 - 40;
    const angleStep = (2 * Math.PI) / data.length;

    // 计算每个点的位置
    const points = data.map((point, index) => {
      const angle = angleStep * index - Math.PI / 2;
      const radius = (point.level / point.maxLevel) * maxRadius;
      return {
        x: center + radius * Math.cos(angle),
        y: center + radius * Math.sin(angle),
        label: point.label,
        level: point.level,
      };
    });

    // 绘制网格线
    const gridLevels = [0.25, 0.5, 0.75, 1];
    const gridLines = gridLevels.map((level) => {
      const radius = level * maxRadius;
      return data.map((_, index) => {
        const angle = angleStep * index - Math.PI / 2;
        return `${center + radius * Math.cos(angle)},${center + radius * Math.sin(angle)}`;
      }).join(' ');
    });

    // 绘制数据区域
    const dataPoints = points.map((p) => `${p.x},${p.y}`).join(' ');

    return (
      <div className="radar-chart">
        <svg viewBox={`0 0 ${size} ${size}`} className="radar-svg">
          {/* 网格背景 */}
          {gridLines.map((line, index) => (
            <polygon
              key={index}
              points={line}
              fill="none"
              stroke="#e2e8f0"
              strokeWidth="1"
            />
          ))}

          {/* 轴线 */}
          {data.map((_, index) => {
            const angle = angleStep * index - Math.PI / 2;
            const x2 = center + maxRadius * Math.cos(angle);
            const y2 = center + maxRadius * Math.sin(angle);
            return (
              <line
                key={index}
                x1={center}
                y1={center}
                x2={x2}
                y2={y2}
                stroke="#e2e8f0"
                strokeWidth="1"
              />
            );
          })}

          {/* 数据区域 */}
          <polygon
            points={dataPoints}
            fill="rgba(59, 130, 246, 0.3)"
            stroke="#3b82f6"
            strokeWidth="2"
          />

          {/* 数据点 */}
          {points.map((point, index) => (
            <circle
              key={index}
              cx={point.x}
              cy={point.y}
              r="6"
              fill="#3b82f6"
              stroke="#fff"
              strokeWidth="2"
            />
          ))}

          {/* 标签 */}
          {points.map((point, index) => {
            const angle = angleStep * index - Math.PI / 2;
            const labelRadius = maxRadius + 25;
            const labelX = center + labelRadius * Math.cos(angle);
            const labelY = center + labelRadius * Math.sin(angle);
            return (
              <text
                key={index}
                x={labelX}
                y={labelY}
                textAnchor="middle"
                dominantBaseline="middle"
                className="radar-label"
              >
                {point.label}
              </text>
            );
          })}
        </svg>

        {/* 图例 */}
        <div className="radar-legend">
          {[0, 1, 2, 3].map((level) => (
            <span key={level} className="legend-item">
              <span className={`legend-level level-${level}`}>{level}</span>
              <span className="legend-text">{getLevelLabel(level)}</span>
            </span>
          ))}
        </div>
      </div>
    );
  };

  // 渲染趋势图
  const renderTrendChart = (data: TrendDataPoint[]) => {
    if (data.length === 0) {
      return (
        <div className="trend-placeholder">
          <p>暂无学习趋势数据</p>
        </div>
      );
    }

    const width = 600;
    const height = 200;
    const padding = { top: 20, right: 20, bottom: 40, left: 40 };
    const chartWidth = width - padding.left - padding.right;
    const chartHeight = height - padding.top - padding.bottom;

    // 获取所有能力类型
    const firstData = data[0];
    if (!firstData) {
      return (
        <div className="trend-placeholder">
          <p>暂无学习趋势数据</p>
        </div>
      );
    }
    const abilities = Object.keys(firstData.abilities);
    const colors = ['#3b82f6', '#22c55e', '#f59e0b', '#ef4444', '#8b5cf6'];
    const abilityColors: Record<string, string> = {};
    abilities.forEach((a, i) => {
      abilityColors[a] = colors[i % colors.length] ?? '#3b82f6';
    });

    // 绘制折线
    const xStep = chartWidth / Math.max(data.length - 1, 1);
    const yScale = chartHeight / 3; // 最大等级为3

    return (
      <div className="trend-chart-container">
        <svg viewBox={`0 0 ${width} ${height}`} className="trend-svg">
          {/* Y轴网格线 */}
          {[0, 1, 2, 3].map((level) => (
            <g key={level}>
              <line
                x1={padding.left}
                y1={padding.top + chartHeight - level * yScale}
                x2={width - padding.right}
                y2={padding.top + chartHeight - level * yScale}
                stroke="#e2e8f0"
                strokeWidth="1"
                strokeDasharray="4,4"
              />
              <text
                x={padding.left - 8}
                y={padding.top + chartHeight - level * yScale + 4}
                textAnchor="end"
                fontSize="12"
                fill="#6b7280"
              >
                {level}
              </text>
            </g>
          ))}

          {/* X轴标签 */}
          {data.map((point, index) => (
            <text
              key={index}
              x={padding.left + index * xStep}
              y={height - padding.bottom + 20}
              textAnchor="middle"
              fontSize="12"
              fill="#6b7280"
            >
              {point.date}
            </text>
          ))}

          {/* 每种能力的折线 */}
          {abilities.map((ability) => (
            <g key={ability}>
              {/* 折线 */}
              <polyline
                fill="none"
                stroke={abilityColors[ability]}
                strokeWidth="2"
                points={data
                  .map((point, index) => {
                    const level = (point.abilities as Record<string, number>)[ability] ?? 0;
                    return `${padding.left + index * xStep},${padding.top + chartHeight - level * yScale}`;
                  })
                  .join(' ')}
              />
              {/* 数据点 */}
              {data.map((point, index) => {
                const level = (point.abilities as Record<string, number>)[ability] ?? 0;
                return (
                  <circle
                    key={index}
                    cx={padding.left + index * xStep}
                    cy={padding.top + chartHeight - level * yScale}
                    r="4"
                    fill={abilityColors[ability]}
                    stroke="#fff"
                    strokeWidth="2"
                  />
                );
              })}
            </g>
          ))}
        </svg>

        {/* 图例 */}
        <div className="trend-legend">
          {abilities.map((ability) => (
            <span key={ability} className="trend-legend-item">
              <span
                className="trend-legend-color"
                style={{ backgroundColor: abilityColors[ability] }}
              />
              <span className="trend-legend-text">{getAbilityName(ability)}</span>
            </span>
          ))}
        </div>
      </div>
    );
  };

  const handleBackToHome = () => {
    navigate('/');
  };

  if (isLoading) {
    return (
      <AppLayout title="能力报告" showBack onBack={handleBackToHome}>
        <div className="profile-loading">加载中...</div>
      </AppLayout>
    );
  }

  if (error) {
    return (
      <AppLayout title="能力报告" showBack onBack={handleBackToHome}>
        <div className="profile-error">{error}</div>
      </AppLayout>
    );
  }

  if (!profile) {
    return (
      <AppLayout title="能力报告" showBack onBack={handleBackToHome}>
        <div className="profile-empty">
          <p>暂无能力数据</p>
          <Button onClick={handleBackToHome}>开始学习</Button>
        </div>
      </AppLayout>
    );
  }

  return (
    <AppLayout title="能力报告" showBack onBack={handleBackToHome}>
      <div className="profile-page">
        {/* 能力等级总览 */}
        <section className="profile-overview">
          <h2 className="section-title">能力等级</h2>
          <div className="ability-grid">
            {profile.states.map((state) => (
              <Card key={state.ability} className="ability-card">
                <div className="ability-name">{getAbilityName(state.ability)}</div>
                <div className={`ability-level level-${state.level}`}>
                  {getLevelLabel(state.level)}
                </div>
                <div className="ability-evidence">
                  已收集 {state.evidenceCount} 条证据
                </div>
              </Card>
            ))}
          </div>
        </section>

        {/* 雷达图 */}
        <section className="profile-radar">
          <h2 className="section-title">能力雷达图</h2>
          <Card className="radar-card">
            {report?.radarData && renderRadarChart(report.radarData)}
          </Card>
        </section>

        {/* 趋势图 */}
        {report?.trend && report.trend.length > 0 && (
          <section className="profile-trend">
            <h2 className="section-title">学习趋势</h2>
            <Card className="trend-card">
              <div className="trend-chart">
                {renderTrendChart(report.trend)}
              </div>
            </Card>
          </section>
        )}

        {/* 常见错误 */}
        {commonMistakes.length > 0 && (
          <section className="profile-mistakes">
            <h2 className="section-title">常见错误提示</h2>
            <Card className="mistakes-card">
              <ul className="mistakes-list">
                {commonMistakes.map((mistake, index) => (
                  <li key={index} className="mistake-item">
                    <span className="mistake-icon">!</span>
                    <span>{mistake}</span>
                  </li>
                ))}
              </ul>
            </Card>
          </section>
        )}

        {/* 学习建议 */}
        {recommendations.length > 0 && (
          <section className="profile-recommendations">
            <h2 className="section-title">学习建议</h2>
            <Card className="recommendations-card">
              <ul className="recommendations-list">
                {recommendations.map((rec, index) => (
                  <li key={index} className="recommendation-item">
                    <span className="recommendation-icon">*</span>
                    <span>{rec}</span>
                  </li>
                ))}
              </ul>
              <div className="recommendations-action">
                <Button variant="primary" onClick={handleBackToHome}>
                  开始学习
                </Button>
              </div>
            </Card>
          </section>
        )}
      </div>
    </AppLayout>
  );
};

export default ProfilePage;
