const fs = require('fs');
const path = require('path');
const log = (msg) => { try { fs.appendFileSync('D:\\mywork\\techdoc\\.tmp_listdist.out.txt', msg + '\r\n'); } catch (e) {} };
try { fs.writeFileSync('D:\\mywork\\techdoc\\.tmp_listdist.out.txt', ''); } catch (e) {}
log('BEGIN');
const candidates = [
  'D:\\mywork\\techdoc\\00通用\\00-方法论与流程\\分析系统的方法论\\dist1',
  'D:\\mywork\\techdoc\\00通用\\00-方法论与流程\\分析系统的方法论\\dist',
  'D:\\mywork\\techdoc\\00通用\\00-方法论与流程\\分析系统的方法论',
  'D:\\mywork\\techdoc\\00通用\\00-方法论与流程',
];
for (const c of candidates) {
  let exists = false, isDir = false, children = 0;
  try { exists = fs.existsSync(c); if (exists) { isDir = fs.statSync(c).isDirectory(); if (isDir) children = fs.readdirSync(c).length; } } catch (e) { log('ERR ' + c + ' ' + e.message); continue; }
  log(c + ' | exists=' + exists + ' isDir=' + isDir + ' children=' + children);
  if (isDir) {
    try {
      fs.readdirSync(c).forEach(n => {
        const p = c + '\\' + n;
        let kind = '?';
        try { kind = fs.statSync(p).isDirectory() ? 'dir' : 'file'; } catch (e) { kind = 'err'; }
        log('   - ' + kind + ' ' + n);
      });
    } catch (e) { log('LIST_ERR ' + e.message); }
  }
}
log('END');
process.exit(0);
