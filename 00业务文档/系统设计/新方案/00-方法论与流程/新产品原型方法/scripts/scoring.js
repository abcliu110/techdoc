/**
 * scoring.js — 评分计算模块
 *
 * 实现 5.2 节评分公式，7 维度加权求和
 * 含容差区间 [83,87] 边界复验逻辑
 */

const WEIGHTS = {
  visualCorrectness: 0.20,
  responsive: 0.15,
  visualHierarchy: 0.10,
  informationArchitecture: 0.10,
  consistency: 0.15,
  accessibility: 0.10,
  competitorAdvantage: 0.20,
};

const PASS_THRESHOLD = 85;
const COMPETITOR_MIN = 70;
const TOLERANCE_LOW = 83;
const TOLERANCE_HIGH = 87;

function scoreVisualCorrectness(domIssues) {
  const critical = domIssues.filter(i => i.severity === 'critical').length;
  const warning = domIssues.filter(i => i.severity === 'warning').length;
  return Math.max(0, 100 - critical * 25 - warning * 5);
}

function scoreResponsive(breakpointIssues) {
  const overflowBp = breakpointIssues
    .filter(bp => bp.issues.some(i => i.type === 'OVERFLOW_X' || i.type === 'OVERFLOW_Y_CLIPPED')).length;
  return Math.max(0, 100 - overflowBp * 25);
}

function scoreVisualHierarchy(llmScore) { return llmScore * 10; }

function scoreInformationArchitecture(taskPathDepth, productType = 'display') {
  const N = productType === 'tob' ? 5 : 3;
  return Math.max(0, 100 - Math.max(0, taskPathDepth - N) * 20);
}

function scoreConsistency(tokenUsageRate) { return tokenUsageRate * 100; }

function scoreAccessibility(criticalCount, seriousCount, hasExecutionFailure) {
  if (hasExecutionFailure) return 0;
  return Math.max(0, 100 - criticalCount * 30 - seriousCount * 10);
}

function scoreCompetitorAdvantage(mustHaveRate, differentiatorRate, innovationRate, painPointRate, mustHaveAllCovered) {
  if (!mustHaveAllCovered) return 0;
  return mustHaveRate * 40 + differentiatorRate * 25 + innovationRate * 20 + painPointRate * 15;
}

function calculateTotalScore(dimensions) {
  const total =
    dimensions.visualCorrectness * WEIGHTS.visualCorrectness +
    dimensions.responsive * WEIGHTS.responsive +
    dimensions.visualHierarchy * WEIGHTS.visualHierarchy +
    dimensions.informationArchitecture * WEIGHTS.informationArchitecture +
    dimensions.consistency * WEIGHTS.consistency +
    dimensions.accessibility * WEIGHTS.accessibility +
    dimensions.competitorAdvantage * WEIGHTS.competitorAdvantage;
  return parseFloat(total.toFixed(2));
}

function checkPass(totalScore, competitorScore, hasCritical) {
  return {
    passed: totalScore >= PASS_THRESHOLD && competitorScore >= COMPETITOR_MIN && !hasCritical,
    scorePassed: totalScore >= PASS_THRESHOLD,
    competitorPassed: competitorScore >= COMPETITOR_MIN,
    noCritical: !hasCritical,
    inToleranceZone: totalScore >= TOLERANCE_LOW && totalScore <= TOLERANCE_HIGH,
  };
}

function runScoring(input) {
  const dims = {
    visualCorrectness: scoreVisualCorrectness(input.domIssues),
    responsive: scoreResponsive(input.breakpointIssues),
    visualHierarchy: scoreVisualHierarchy(input.llmVisualScore),
    informationArchitecture: scoreInformationArchitecture(input.taskPathDepth, input.productType),
    consistency: scoreConsistency(input.tokenUsageRate),
    accessibility: scoreAccessibility(input.axeCritical, input.axeSerious, input.axeFailed),
    competitorAdvantage: scoreCompetitorAdvantage(
      input.competitor.mustHaveRate, input.competitor.differentiatorRate,
      input.competitor.innovationRate, input.competitor.painPointRate,
      input.competitor.mustHaveAllCovered
    ),
  };
  const totalScore = calculateTotalScore(dims);
  const hasCritical = input.domIssues.some(i => i.severity === 'critical') || input.axeFailed;
  const passResult = checkPass(totalScore, dims.competitorAdvantage, hasCritical);
  return { dimensions: dims, totalScore, ...passResult };
}

module.exports = { runScoring, calculateTotalScore, checkPass, WEIGHTS };
