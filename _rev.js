
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
const l1 = 'D:/mywork/techdoc/00通用/00-方法论与流程/研发方法/业务系统分析-认知理论-L1.md';
const concepts = ['业务系统分析-认知理论-L1','认知理论（L1）','认知理论','主文档','深度八关','SC-P0','SC-P1','SC-P2','SC-P3','SEV-','事实/维度/规则','三元模型','时间盒','分次执行','精简路径','标准路径','完整路径','SYS-ANALYSIS-CONTRACT','E-SRC','因果叙事','未覆盖项','直接事实','交叉验证','DA0-','V0-','G0-','文档 20','文档 21','P0','P1','P2','P3','必须','禁止','不得'];
const rows = [];
for (const f of files) {
  const p = path.join(base, f);
  const t = fs.readFileSync(p, 'utf8');
  const lines = t.split(/\r?\n/);
  const head = lines.slice(0, 30).filter(x => x.startsWith('#') || x.startsWith('>') || /版本|契约|CONTRACT|定位|目的/.test(x));
  const counts = {};
  for (const c of concepts) counts[c] = t.split(c).length - 1;
  // P0 usage samples
  const p0 = [];
  const re = /.{0,20}P0.{0,30}/g;
  let m; let n=0;
  while ((m = re.exec(t)) && n < 4) { p0.push(m[0].replace(/\s+/g,' ')); n++; }
  // duplicate headings rough
  const heads = lines.filter(x => /^#{2,4} /.test(x)).map(x => x.replace(/^#+\s+/,'').trim());
  const seen = {};
  const dups = [];
  for (const h of heads) { seen[h]=(seen[h]||0)+1; }
  for (const [k,v] of Object.entries(seen)) if (v>1) dups.push(k+':'+v);
  rows.push({f, chars:t.length, lines:lines.length, head, counts, p0, dups:dups.slice(0,8)});
}
const l1t = fs.existsSync(l1) ? fs.readFileSync(l1,'utf8') : '';
const summary = {
  l1_exists: !!l1t,
  l1_ver: (l1t.match(/文档版本：v[0-9.]+/)||[])[0] || null,
  rows
};
fs.writeFileSync('D:/mywork/techdoc/_sop_review.json', JSON.stringify(summary, null, 2), 'utf8');
console.log('OK');
