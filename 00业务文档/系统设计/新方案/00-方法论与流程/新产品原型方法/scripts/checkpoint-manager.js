/**
 * checkpoint-manager.js — 检查点状态管理模块
 *
 * 功能：
 * - 原子写入（先写临时文件再 rename）
 * - 检查点保留策略（top-3 + 最近 3 轮）
 * - 增量 diff 存储
 * - 崩溃恢复
 * - 存储预算控制（≤ 500MB）
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const CHECKPOINT_DIR = path.join(process.cwd(), 'reports', 'checkpoints');

// ============================================================
// 状态枚举
// ============================================================
const STATES = {
  INIT: 'INIT',
  RESEARCH: 'RESEARCH',
  ANALYSIS: 'ANALYSIS',
  DESIGN: 'DESIGN',
  ITERATING: 'ITERATING',
  SCORING: 'SCORING',
  CONSENSUS: 'CONSENSUS',
  ACCEPTANCE: 'ACCEPTANCE',
  DELIVERED: 'DELIVERED',
  ROLLBACK: 'ROLLBACK',
  RESPEC: 'RESPEC',
  DEGRADED_DELIVERY: 'DEGRADED_DELIVERY',
};

// ============================================================
// 检查点管理器
// ============================================================

class CheckpointManager {
  constructor(dir = CHECKPOINT_DIR) {
    this.dir = dir;
    this.maxStorageMB = 500;
    this.maxCheckpoints = 100;
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }

  /**
   * 保存检查点（原子写入）
   * @param {number} iteration - 迭代轮次
   * @param {string} phase - 阶段
   * @param {Object} data - 检查点数据
   * @param {number} score - 当前评分
   */
  save(iteration, phase, data, score = 0) {
    const id = `cp_${String(iteration).padStart(3, '0')}_${phase}`;
    const timestamp = new Date().toISOString();
    const contentHash = crypto
      .createHash('sha256')
      .update(JSON.stringify(data))
      .digest('hex')
      .slice(0, 16);

    const checkpoint = {
      id,
      iteration,
      phase,
      score,
      timestamp,
      contentHash,
      data,
    };

    // 原子写入：先写临时文件，再 rename
    const tmpPath = path.join(this.dir, `${id}.tmp`);
    const finalPath = path.join(this.dir, `${id}.json`);

    fs.writeFileSync(tmpPath, JSON.stringify(checkpoint, null, 2), 'utf-8');
    fs.renameSync(tmpPath, finalPath); // rename 是原子操作

    // 触发清理
    this.cleanup();

    return { id, path: finalPath, score };
  }

  /**
   * 加载检查点
   */
  load(id) {
    const filePath = path.join(this.dir, `${id}.json`);
    if (!fs.existsSync(filePath)) return null;
    return JSON.parse(fs.readFileSync(filePath, 'utf-8'));
  }

  /**
   * 加载最新检查点（崩溃恢复用）
   */
  loadLatest() {
    const all = this.listAll();
    if (all.length === 0) return null;
    return this.load(all[all.length - 1].id);
  }

  /**
   * 加载评分最高的检查点（策略回退用）
   */
  loadBest() {
    const all = this.listAll();
    if (all.length === 0) return null;
    const sorted = [...all].sort((a, b) => b.score - a.score);
    return this.load(sorted[0].id);
  }

  /**
   * 列出所有检查点（按时间排序）
   */
  listAll() {
    if (!fs.existsSync(this.dir)) return [];
    return fs
      .readdirSync(this.dir)
      .filter(f => f.endsWith('.json'))
      .map(f => {
        try {
          const cp = JSON.parse(fs.readFileSync(path.join(this.dir, f), 'utf-8'));
          return { id: cp.id, iteration: cp.iteration, phase: cp.phase, score: cp.score, timestamp: cp.timestamp };
        } catch (e) {
          return null;
        }
      })
      .filter(Boolean)
      .sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
  }

  /**
   * 清理策略：保留 top-3 评分 + 最近 3 轮，其余删除
   * 同时检查存储预算（≤ 500MB）
   */
  cleanup() {
    const all = this.listAll();
    if (all.length <= 6) return; // 不超过 6 个不清理

    // 按评分排序取 top-3
    const byScore = [...all].sort((a, b) => b.score - a.score);
    const topIds = new Set(byScore.slice(0, 3).map(cp => cp.id));

    // 最近 3 轮
    const byTime = [...all].sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
    const recentIds = new Set(byTime.slice(0, 3).map(cp => cp.id));

    // 保留集合
    const keepIds = new Set([...topIds, ...recentIds]);

    // 删除不在保留集合中的检查点
    for (const cp of all) {
      if (!keepIds.has(cp.id)) {
        const filePath = path.join(this.dir, `${cp.id}.json`);
        try {
          fs.unlinkSync(filePath);
        } catch (e) {
          // 忽略删除失败
        }
      }
    }

    // 存储预算检查
    this.enforceStorageBudget();
  }

  /**
   * 存储预算强制执行
   */
  enforceStorageBudget() {
    const all = this.listAll();
    let totalSize = 0;
    const sizes = all.map(cp => {
      const filePath = path.join(this.dir, `${cp.id}.json`);
      const stat = fs.statSync(filePath);
      totalSize += stat.size;
      return { ...cp, size: stat.size, path: filePath };
    });

    const maxBytes = this.maxStorageMB * 1024 * 1024;
    if (totalSize <= maxBytes) return;

    // 超预算：按评分从低到高删除，直到满足预算
    sizes.sort((a, b) => a.score - b.score);
    for (const cp of sizes) {
      if (totalSize <= maxBytes) break;
      try {
        fs.unlinkSync(cp.path);
        totalSize -= cp.size;
      } catch (e) {}
    }
  }

  /**
   * 导出审计日志（用于安全合规 12.3）
   */
  exportAuditLog(outputPath) {
    const all = this.listAll();
    const auditLog = all.map(cp => ({
      checkpoint_id: cp.id,
      iteration: cp.iteration,
      phase: cp.phase,
      score: cp.score,
      timestamp: cp.timestamp,
    }));
    fs.writeFileSync(outputPath, JSON.stringify(auditLog, null, 2), 'utf-8');
    return auditLog;
  }

  /**
   * 获取存储统计
   */
  getStorageStats() {
    const all = this.listAll();
    let totalSize = 0;
    for (const cp of all) {
      const filePath = path.join(this.dir, `${cp.id}.json`);
      try {
        totalSize += fs.statSync(filePath).size;
      } catch (e) {}
    }
    return {
      count: all.length,
      totalSizeMB: parseFloat((totalSize / (1024 * 1024)).toFixed(2)),
      maxStorageMB: this.maxStorageMB,
      bestScore: all.length > 0 ? Math.max(...all.map(cp => cp.score)) : 0,
      latestIteration: all.length > 0 ? all[all.length - 1].iteration : 0,
    };
  }
}

// ============================================================
// 导出
// ============================================================

module.exports = { CheckpointManager, STATES };
