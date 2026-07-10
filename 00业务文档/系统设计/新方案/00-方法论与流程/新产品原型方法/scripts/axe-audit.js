/**
 * axe-audit.js — axe-core 无障碍审计模块
 *
 * 功能：
 * - Playwright + axe-core 集成
 * - 对所有路由页面分别执行审计
 * - 输出结构化报告（critical / serious / 详细违规列表）
 * - 失败时判 0 分 + critical 缺陷（不跳过）
 */

const { chromium } = require('playwright');
const path = require('path');

const AXE_CORE_JS = require.resolve('axe-core');

/**
 * 执行 axe-core 审计
 * @param {string} url - 原型访问 URL（仅允许 localhost）
 * @param {string[]} routes - 需要审计的路由列表（如 ['/', '/orders', '/settings']）
 * @returns {Object} { criticalCount, seriousCount, violations, dimensionScore, passed }
 */
async function runAxeAudit(url, routes = ['/']) {
  // URL 安全校验
  const allowed = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?\//;
  if (!allowed.test(url)) {
    throw new Error('URL not allowed for axe audit: ' + url);
  }

  const browser = await chromium.launch();
  const page = await browser.newPage();

  // 注入 axe-core
  const axeSource = require('fs').readFileSync(AXE_CORE_JS, 'utf-8');

  const allViolations = [];
  const routeReports = [];

  for (const route of routes) {
    const fullUrl = url.replace(/\/$/, '') + route;
    try {
      await page.goto(fullUrl, { waitUntil: 'domcontentloaded', timeout: 15000 });
      await page.waitForTimeout(500); // 等待 hydration

      // 注入并执行 axe-core
      const results = await page.evaluate(async (source) => {
        // eslint-disable-next-line no-eval
        eval(source);
        // axe 全局变量在 eval 后可用
        return await window.axe.run(document, {
          runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa'] },
          resultTypes: ['violations'],
        });
      }, axeSource);

      const violations = results.violations || [];
      routeReports.push({
        route,
        violationCount: violations.length,
        violations: violations.map(v => ({
          id: v.id,
          impact: v.impact, // critical / serious / moderate / minor
          description: v.description,
          help: v.help,
          helpUrl: v.helpUrl,
          nodes: (v.nodes || []).map(n => ({
            target: n.target,
            html: n.html,
            failureSummary: n.failureSummary,
          })),
        })),
      });

      allViolations.push(...violations);
    } catch (e) {
      // axe-core 执行失败 → 判 0 分 + critical 缺陷（不跳过）
      routeReports.push({
        route,
        error: e.message,
        violationCount: -1, // -1 表示执行失败
      });
      allViolations.push({ impact: 'critical', id: 'axe-execution-failure', description: e.message });
    }
  }

  await browser.close();

  // 统计
  const criticalCount = allViolations.filter(v => v.impact === 'critical').length;
  const seriousCount = allViolations.filter(v => v.impact === 'serious').length;

  // 评分计算：100 - critical×30 - serious×10，下限 0
  const dimensionScore = Math.max(0, 100 - criticalCount * 30 - seriousCount * 10);

  // axe-core 执行失败 → 强制 0 分 + critical
  const hasExecutionFailure = routeReports.some(r => r.violationCount === -1);
  const finalScore = hasExecutionFailure ? 0 : dimensionScore;
  const passed = criticalCount === 0 && !hasExecutionFailure;

  return {
    criticalCount: hasExecutionFailure ? criticalCount + 1 : criticalCount,
    seriousCount,
    routeReports,
    dimensionScore: finalScore,
    passed,
    hasExecutionFailure,
  };
}

module.exports = { runAxeAudit };
