#!/usr/bin/env node
/**
 * check-sop-consistency.mjs
 * 业务系统分析 SOP 文档体系机械校验（元规范 §5.2 版本一致性门禁的可执行层）
 *
 * 校验项：
 *  C1 每个 SOP 文档头部版本 == 修订记录表格最后一行版本
 *  C2 上位约束引用 SOP-00 当前版本（v3.11），且无 "vv" 笔误
 *  C3 头部无 "总约束："（术语统一为"上位约束"）
 *  C4 修订记录表格：版本按出现顺序非递减（无乱序）、无重复版本号
 *  C5 修订记录表头包含"修改人"列，数据行均有修改人
 *  C6 模板文件引用的主体版本 == 主体头部版本
 *  C7 文档 20/21 对 SOP-00 的引用版本滞后 <= 1 个大版本（当前 v3.11）
 *  C8 元规范头部版本 == 元规范修订记录最后一行版本
 *  C9 文档 21 无 "v3.x" 类模糊版本引用
 *
 * 用法：node check-sop-consistency.mjs [目录]
 * 退出码：0 = 全部通过；1 = 存在 FAIL
 */
import fs from 'node:fs';
import path from 'node:path';

const dir = process.argv[2] || process.cwd();
const SOP00 = 'SOP-00-业务系统分析SOP总览.md';
const META = '研发方法/元规范-业务系统分析SOP编写规范.md';
const SOP00_CURRENT = 'v3.11';

let failures = [];
let checks = [];

function check(id, ok, msg) {
  checks.push({ id, ok, msg });
  if (!ok) failures.push(`${id}: ${msg}`);
}

function norm(v) {
  // "| **v3.11** |" / "| v3.1 |" / "v3.0" -> "3.11"
  const m = String(v).match(/(\d+)\.(\d+)/);
  return m ? [Number(m[1]), Number(m[2])] : null;
}

function cmp(a, b) {
  if (!a || !b) return 0;
  return a[0] - b[0] || a[1] - b[1];
}

function read(p) {
  try {
    return fs.readFileSync(p, 'utf8');
  } catch {
    return null;
  }
}

function headVersion(text) {
  // 兼容：> 版本：v3.1 / > **版本**：v3.1 / | 文档版本 | v3.11 |
  const m = text.match(/(?:版本\**\s*[：:]|\|\s*文档版本\s*\|)\s*\**v?(\d+\.\d+)/);
  return m ? `v${m[1]}` : null;
}

function revRows(text) {
  // 修订记录表格数据行：| 版本 | 日期 | ...（版本列/日期列允许加粗 **）
  const rows = [];
  const lines = text.split('\n');
  for (const line of lines) {
    const m = line.match(/^\|\s*\**v?(\d+\.\d+)\**\s*\|\s*\**(\d{4}-\d{2}-\d{2})\**\s*\|/);
    if (m) rows.push({ ver: `v${m[1]}`, date: m[2], line });
  }
  return rows;
}

// ---------- 主体 SOP 文档 ----------
const sopFiles = [
  'SOP-00-业务系统分析SOP总览.md', 'SOP-01-前端整体分析.md', 'SOP-02-后端整体分析.md',
  'SOP-03-核心业务流程分析.md', 'SOP-04-功能点深度分析.md', 'SOP-05-前后端对接分析.md',
  'SOP-06-数据模型分析.md', 'SOP-07-综合评估与报告.md', 'SOP-08-架构与业务设计启发式评审.md',
  'SOP-09-业务设计合理性评审.md', 'SOP-10-业务演进多实现归一与重构迁移.md',
];

for (const f of sopFiles) {
  const p = path.join(dir, f);
  const t = read(p);
  if (!t) { check(`C1-${f}`, false, '文件不存在'); continue; }

  const hdr = headVersion(t);
  const rows = revRows(t);
  const last = rows.length ? rows[rows.length - 1].ver : null;

  // C1 头部版本 == 修订记录最后一行
  check(`C1-${f}`, hdr === last, `头部版本 ${hdr} ${hdr === last ? '==' : '!='} 修订记录最后一行 ${last}`);

  if (f !== SOP00) {
    // C2 上位约束（SOP-00 自身无"上位约束"概念，跳过）
    const up = t.match(/^>\s*\**上位约束\**\s*[：:]\s*`?SOP-00-业务系统分析SOP总览\.md`?\s*(v[\d.]+)/m);
    if (up) {
      check(`C2-${f}`, up[1] === SOP00_CURRENT, `上位约束 ${up[1]} 应为 ${SOP00_CURRENT}`);
    } else {
      check(`C2-${f}`, false, '未找到上位约束引用');
    }
    check(`C2b-${f}`, !/vv\d/.test(t), /vv\d/.test(t) ? '存在 vv 笔误' : '无 vv 笔误');

    // C3 术语统一
    check(`C3-${f}`, !/^总约束\s*[：:]/m.test(t), /^总约束\s*[：:]/m.test(t) ? '头部仍用"总约束"' : '头部术语统一为"上位约束"');
  }

  // C4 修订记录非递减 + 无重复
  let monotonic = true, dup = null;
  const seen = new Set();
  for (const r of rows) {
    if (seen.has(r.ver)) { dup = r.ver; break; }
    seen.add(r.ver);
  }
  for (let i = 1; i < rows.length; i++) {
    if (cmp(rev(rows[i - 1].ver), rev(rows[i].ver)) > 0) { monotonic = false; break; }
  }
  check(`C4-${f}`, monotonic, monotonic ? '修订记录按版本非递减' : '修订记录乱序（后行版本 < 前行版本）');
  check(`C4b-${f}`, !dup, dup ? `修订记录存在重复版本号 ${dup}` : '修订记录无重复版本号');

  // C5 修改人列
  const hasCol = /^\|\s*版本\s*\|\s*日期\s*\|\s*修改内容\s*\|\s*修改人\s*\|/m.test(t);
  const missingWho = rows.filter(r => !/\|\s*(?:AI|-)\s*\|\s*$/.test(r.line));
  check(`C5-${f}`, hasCol, hasCol ? '修订记录表有"修改人"列' : '修订记录表缺"修改人"列');
  check(`C5b-${f}`, missingWho.length === 0, missingWho.length ? `${missingWho.length} 行缺修改人` : '全部行有修改人');
}

// ---------- 模板文件引用主体版本 ----------
const templates = [
  ['SOP-05-IX-模板.md', 'SOP-05-前后端对接分析.md'],
  ['SOP-06-DA-模板.md', 'SOP-06-数据模型分析.md'],
  ['SOP-07-EVAL-模板.md', 'SOP-07-综合评估与报告.md'],
  ['SOP-08-REV-模板.md', 'SOP-08-架构与业务设计启发式评审.md'],
  ['SOP-09-DR-模板.md', 'SOP-09-业务设计合理性评审.md'],
];
for (const [tmpl, main] of templates) {
  const tt = read(path.join(dir, tmpl));
  const mt = read(path.join(dir, main));
  if (!tt || !mt) { check(`C6-${tmpl}`, false, '文件缺失'); continue; }
  const ref = tt.match(/上位约束\**\s*[：:]\s*(SOP-\d+[^ ]*\.md)\s*v?(\d+\.\d+)/);
  const mainHdr = headVersion(mt);
  if (ref) {
    const matchMain = ref[1] === main;
    const matchVer = ref[2] === mainHdr?.replace('v', '');
    check(`C6-${tmpl}`, matchMain && matchVer, `模板引用 ${ref[1]} v${ref[2]}，主体实际 ${main} ${mainHdr} → ${matchMain && matchVer ? '一致' : '不一致'}`);
  } else {
    check(`C6-${tmpl}`, false, '模板未声明上位约束引用');
  }
}

// ---------- 文档 20/21 ----------
for (const f of ['20-方法论-系统分析SOP完整指南.md', '21-方法论-系统分析反向验证指南.md']) {
  const t = read(path.join(dir, f));
  if (!t) { check(`C7-${f}`, false, '文件不存在'); continue; }
  const refs = [...t.matchAll(/SOP-00[^`\n]*?(?:总览\.md`?)?\s*(v\d+\.\d+(?:\.\d+)?)/g)];
  const ok = refs.every(r => {
    const [maj] = r[1].replace('v', '').split('.').map(Number);
    return maj >= 2; // 大版本 2.x 及以上视为 ≤1 大版本滞后（当前 3.x）
  });
  check(`C7-${f}`, ok, refs.length ? `引用版本 ${refs.map(r => r[1]).join(', ')}` : '未找到对 SOP-00 的版本引用（需人工确认）');
  check(`C9-${f}`, !/SOP-00[^\n]*v\d+\.x/.test(t), /SOP-00[^\n]*v\d+\.x/.test(t) ? '存在 vX.x 模糊引用' : '无模糊版本引用');
  // C5 修改人列（文档 20/21 同样适用）
  const rowsD = revRows(t);
  const hasColD = /^\|\s*版本\s*\|\s*日期\s*\|\s*修改内容\s*\|\s*修改人\s*\|/m.test(t);
  const missingWhoD = rowsD.filter(r => !/\|\s*(?:AI|-)\s*\|\s*$/.test(r.line));
  check(`C5-${f}`, hasColD, hasColD ? '修订记录表有"修改人"列' : '修订记录表缺"修改人"列');
  check(`C5b-${f}`, missingWhoD.length === 0, missingWhoD.length ? `${missingWhoD.length} 行缺修改人` : '全部行有修改人');
}
// 文档 20 头部上位约束精确核对
{
  const t = read(path.join(dir, '20-方法论-系统分析SOP完整指南.md'));
  const up = t.match(/^\|\s*上位约束\s*\|\s*`SOP-00-业务系统分析SOP总览\.md`\s*v?(\d+\.\d+)/m);
  check('C7-20hdr', up?.[1] === '3.11', `文档 20 头部上位约束 ${up?.[1]} 应为 3.11`);
}

// ---------- 元规范 ----------
{
  const t = read(path.join(dir, META));
  if (t) {
    const hdr = headVersion(t);
    const rows = revRows(t);
    const last = rows.length ? rows[rows.length - 1].ver : null;
    check('C8-meta', hdr === last, `元规范头部版本 ${hdr} ${hdr === last ? '==' : '!='} 修订记录最后一行 ${last}`);
    const hasCol = /^\|\s*版本\s*\|\s*日期\s*\|\s*修改内容\s*\|\s*修改人\s*\|/m.test(t);
    check('C8b-meta', hasCol, hasCol ? '元规范修订记录表有"修改人"列' : '元规范修订记录表缺"修改人"列');
  } else {
    check('C8-meta', false, '元规范文件不存在');
  }
}

// ---------- 输出 ----------
for (const c of checks) {
  console.log(`${c.ok ? '✅' : '❌'} ${c.id} — ${c.msg}`);
}
console.log(`\n${checks.length - failures.length}/${checks.length} 通过`);
if (failures.length) {
  console.log(`\nFAIL（${failures.length}）:`);
  for (const f of failures) console.log('  - ' + f);
  process.exit(1);
}
process.exit(0);

function rev(v) {
  const m = String(v).match(/(\d+)\.(\d+)/);
  return m ? [Number(m[1]), Number(m[2])] : null;
}
