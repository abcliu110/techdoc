
const fs = require('fs');
const path = require('path');
const base = 'D:/mywork/techdoc/00通用/00-方法论与流程';
const files = [
  'SOP-00-业务系统分析SOP总览.md',
  'SOP-01-前端整体分析.md',
  'SOP-02-后端整体分析.md',
  'SOP-03-核心业务流程分析.md',
  'SOP-04-功能点深度分析.md',
  'SOP-05-前后端对接分析.md',
  'SOP-06-数据模型分析.md',
  'SOP-07-综合评估与报告.md',
  'SOP-08-架构与业务设计启发式评审.md',
  'SOP-09-业务设计合理性评审.md',
  'SOP-10-业务演进多实现归一与重构迁移.md'
];
const l1p = path.join(base, '研发方法/业务系统分析-认知理论-L1.md');
const checks = [
  '业务系统分析-认知理论-L1', '深度八关', 'SC-P0', 'SC-P1', 'SEV-', '主文档',
  'SYS-ANALYSIS-CONTRACT-v2.12', 'SYS-ANALYSIS-CONTRACT-v2.10', 'SYS-ANALYSIS-CONTRACT-v2.9',
  'SOP-00-业务系统分析SOP总览.md` v2.10', 'SOP-00-业务系统分析SOP总览.md` v2.12',
  '精简路径', '标准路径', '完整路径', '时间盒', '分次执行', '事实/维度/规则',
  '默认执行链', 'DA0-DA8', '文档 20', '文档 21', '因果叙事', '未覆盖项',
  'P0', 'P1', 'P2', 'P3', '直接事实', '交叉验证', '假设'
];
function meta(t) {
  const lines = t.split(/\r?\n/);
  const out = [];
  for (let i=0;i<Math.min(40, lines.length);i++) {
    const l = lines[i];
    if (l.startsWith('#') || l.startsWith('>') || /版本|契约|CONTRACT|上位|总约束|定位|目的/.test(l)) out.push((i+1)+'|' + l);
  }
  return out;
}
function findLines(t, re, limit=6) {
  const lines = t.split(/\r?\n/);
  const hits = [];
  for (let i=0;i<lines.length;i++) if (re.test(lines[i])) { hits.push({n:i+1, l:lines[i].trim().slice(0,160)}); if (hits.length>=limit) break; }
  return hits;
}
const report = { l1: null, sops: [] };
if (fs.existsSync(l1p)) {
  const t = fs.readFileSync(l1p,'utf8');
  report.l1 = { ver: (t.match(/文档版本：[^\n]+/)||[])[0], hasEight: t.includes('深度八关'), hasSCP: t.includes('SC-P0'), hasSEV: t.includes('SEV-') };
}
for (const f of files) {
  const p = path.join(base, f);
  const t = fs.readFileSync(p, 'utf8');
  const c = {};
  for (const k of checks) c[k] = t.split(k).length-1;
  // heading dups
  const heads = {};
  t.split(/\r?\n/).forEach(l => { if (/^#{2,4} /.test(l)) { const h=l.replace(/^#+\s+/,'').trim(); heads[h]=(heads[h]||0)+1; }});
  const dups = Object.entries(heads).filter(([,v])=>v>1).map(([k,v])=>k+' x'+v);
  // completion-ish sentences
  const completion = findLines(t, /完成标准|分析完成|交付|门禁通过|G5/, 8);
  const p0depth = findLines(t, /P0.*切片|切片.*P0|P0\/P1 切片|P0切片/, 5);
  const p0sev = findLines(t, /P0.*严重|严重度.*P0|P0～P3|P0-P3 仅表示|P0～P3：只表示/, 5);
  const dual = findLines(t, /默认执行链|精简路径|DA0-DA8|文档 20/, 8);
  report.sops.push({
    f, chars: t.length, lines: t.split(/\r?\n/).length, mtime: fs.statSync(p).mtime.toISOString(),
    meta: meta(t), counts: c, dups: dups.slice(0,10), completion, p0depth, p0sev, dual
  });
}
// cross issues
const issues = [];
const s00 = report.sops[0];
if (s00.counts['SYS-ANALYSIS-CONTRACT-v2.12'] && report.sops.slice(1).some(s => s.counts['SYS-ANALYSIS-CONTRACT-v2.10'])) {
  issues.push({sev:'critical', id:'CONTRACT_SPLIT', msg:'SOP-00 is v2.12 while SOP-01..10 declare v2.10 compatibility'});
}
if (report.sops.every(s => (s.counts['业务系统分析-认知理论-L1']||0)===0)) {
  issues.push({sev:'critical', id:'NO_L1', msg:'No SOP references L1 cognitive theory true source'});
}
if ((s00.counts['精简路径']||0)>0 && (s00.counts['默认执行链']||0)+(s00.dual||[]).length>0) {
  issues.push({sev:'critical', id:'DUAL_TRACK', msg:'SOP-00 has both path selection and default full DA chain language'});
}
const p0both = report.sops.filter(s => (s.p0depth||[]).length && (s.p0sev||[]).length).map(s=>s.f);
if (p0both.length || ((s00.p0depth||[]).length && report.sops.some(s=>(s.p0sev||[]).length))) {
  issues.push({sev:'high', id:'P0_POLYSEMY', msg:'P0 used as slice-depth in SOP-00 and severity in other SOPs', files: p0both});
}
if (report.sops.some(s => s.dups && s.dups.length)) {
  issues.push({sev:'medium', id:'DUP_HEADINGS', msg:'Duplicate headings detected', files: report.sops.filter(s=>s.dups.length).map(s=>({f:s.f, dups:s.dups}))});
}
if ((s00.counts['深度八关']||0)===0 || (s00.counts['SC-P0']||0)===0) {
  issues.push({sev:'high', id:'S00_NOT_L1_GATES', msg:'SOP-00 lacks L1 depth-eight-gates / SC-P0 terminology despite being orchestrator'});
}
report.issues = issues;
fs.writeFileSync('D:/mywork/techdoc/_sop_rereview.json', JSON.stringify(report, null, 2), 'utf8');
console.log(JSON.stringify({issues, summary: report.sops.map(s => ({
  f:s.f, lines:s.lines,
  c12:s.counts['SYS-ANALYSIS-CONTRACT-v2.12'], c10:s.counts['SYS-ANALYSIS-CONTRACT-v2.10'],
  L1:s.counts['业务系统分析-认知理论-L1'], main:s.counts['主文档'], eight:s.counts['深度八关'], scp0:s.counts['SC-P0'],
  path:s.counts['精简路径'], da:s.counts['DA0-DA8'], p0:s.counts['P0'], dups:s.dups.length
}))}, null, 2));
