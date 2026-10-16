# Replace old JS block (lines 805-1337, 0-indexed: 804-1336) with new clean JS
with open(r'D:\mywork\techdoc\英语学习软件\app\prototype\index.html', 'r', encoding='utf-8') as f:
    lines = f.readlines()

print(f'Total lines: {len(lines)}')

# Verify boundaries
assert '<script>' in lines[804], 'Line 805 is not <script>'
assert 'var RELATION_DIMS = [' in lines[805], 'Line 806 is not start of JS'
assert '</script>' in lines[1336], 'Line 1337 is not </script>'
print('Boundaries verified')

# New JS content
NEW_JS = r'''<script>
var RELATION_DIMS = [
  { id: '同词根',     name: '同词根',    icon: '\uD83C\uDF31', color: '#10B981', group: 'body' },
  { id: '同词缀',     name: '同词缀',    icon: '\u2192',  color: '#4F46E5', group: 'body' },
  { id: '同词形',     name: '同词形',    icon: '\uD83D\uDDE4', color: '#6366F1', group: 'body' },
  { id: '同义项属性', name: '同义项',    icon: '\uD83D\uDCD6', color: '#7C3AED', group: 'body' },
  { id: '同认知负荷', name: '认知负荷',  icon: '\uD83E\uDDE0', color: '#DB2777', group: 'body' },
  { id: '同词块',     name: '词块',      icon: '\uD83D\uDCE6', color: '#0891B2', group: 'body' },
  { id: '同字母组合', name: '字母组合',  icon: '\uD83D\uDDE4', color: '#EA580C', group: 'phonology' },
  { id: '同发音模式', name: '发音模式',  icon: '\uD83D\uDD0A', color: '#DC2626', group: 'phonology' },
  { id: '同拼写模式', name: '拼写规则',  icon: '\u270F\uFE0F', color: '#9333EA', group: 'phonology' },
  { id: '同音节数',   name: '音节数',    icon: '\uD83C\uDFB5', color: '#BE185D', group: 'phonology' },
  { id: '同重音模式', name: '重音模式',  icon: '\uD83D\uDD42', color: '#B45309', group: 'phonology' },
  { id: '同词源',     name: '同词源',    icon: '\uD83C\uDDFB', color: '#C026D3', group: 'phonology' },
  { id: '同义词',     name: '同义词',    icon: '\u2248',  color: '#059669', group: 'semantic' },
  { id: '反义词',     name: '反义词',    icon: '\u2260',  color: '#DC2626', group: 'semantic' },
  { id: '上下位',     name: '上下位',    icon: '\u2B06\uFE0F', color: '#4F46E5', group: 'semantic' },
  { id: '易混词',     name: '易混词',    icon: '\u26A0\uFE0F', color: '#EA580C', group: 'semantic' },
  { id: '同错因',     name: '同错因',    icon: '\u274C', color: '#9333EA', group: 'semantic' },
  { id: '假朋友',     name: '假朋友',    icon: '\uD83D\uDC7B', color: '#BE185D', group: 'semantic' },
  { id: '多义派生链', name: '多义派生',  icon: '\uD83D\uDD00', color: '#7C3AED', group: 'semantic' },
  { id: '隐喻关联',   name: '隐喻关联',  icon: '\uD83D\uDD04', color: '#8B5CF6', group: 'semantic' },
  { id: '语体',       name: '语体',      icon: '\uD83C\uDFAD', color: '#06B6D4', group: 'register' },
  { id: '语域变体',   name: '语域变体',  icon: '\uD83C\uDDF3\uD83C\uDDFB', color: '#0284C7', group: 'register' },
  { id: '情感色彩',   name: '情感色彩',  icon: '\uD83D\uDC96', color: '#EC4899', group: 'register' },
  { id: '同句法结构', name: '句法结构',  icon: '\uD83D\uDCCF', color: '#0D9488', group: 'register' },
  { id: '同构词法',   name: '构词法',    icon: '\uD83E\uDDE9', color: '#D97706', group: 'derivation' },
  { id: '同搭配',     name: '同搭配',    icon: '\uD83E\uDD1D', color: '#10B981', group: 'derivation' },
  { id: '逆构词',     name: '逆构词',    icon: '\uD83D\uDD03', color: '#B45309', group: 'derivation' },
  { id: '转喻关联',   name: '转喻',      icon: '\uD83C\uDFFB', color: '#9333EA', group: 'derivation' },
  { id: '同主题语境', name: '主题语境',  icon: '\uD83C\uDDF0', color: '#059669', group: 'learning' },
  { id: '同难度层级', name: '难度层级',  icon: '\uD83D\uDCCA', color: '#6366F1', group: 'learning' },
  { id: '同词频波段', name: '词频波段',  icon: '\uD83D\uDCC8', color: '#EA580C', group: 'learning' },
  { id: '形式无关',   name: '形式无关',  icon: '\u2753', color: '#BE185D', group: 'learning' },
];

var WORDS = [
  {
    word: 'run', ph: '/rʌn/', pos: 'verb · noun', cn: '跑；奔跑 / 一次跑步',
    relations: ['同词根', '同字母组合', '同发音模式', '多义派生链', '易混词', '同搭配', '同词源'],
    hasMD: true,
    dims: ['dim1-semantic', 'dim2-collocation', 'dim3-grammar', 'dim4-metaphor', 'dim5-contrast', 'dim6-register'],
  },
  {
    word: 'grasp', ph: '/ɡrɑːsp/', pos: 'verb · noun', cn: '抓住；理解；掌握',
    relations: ['同词根', '同字母组合', '多义派生链', '隐喻关联', '易混词', '同搭配', '同构词法'],
    hasMD: true,
    dims: ['dim1-semantic', 'dim2-collocation', 'dim3-grammar', 'dim4-metaphor', 'dim5-contrast', 'dim6-register'],
  },
  {
    word: 'break', ph: '/breɪk/', pos: 'verb · noun', cn: '打破；损坏；休息',
    relations: ['同词根', '多义派生链', '隐喻关联', '同错因', '同搭配', '易混词'],
    hasMD: false,
  },
  {
    word: 'in', ph: '/ɪn/', pos: 'preposition · adverb', cn: '在…里面；在…期间',
    relations: ['同词根', '多义派生链', '隐喻关联', '同搭配', '易混词', '同错因'],
    hasMD: false,
  },
  {
    word: 'economy', ph: '/ɪˈkɒnəmi/', pos: 'noun', cn: '经济；节约',
    relations: ['同词根', '同词缀', '同义词', '反义词', '同搭配'],
    hasMD: false,
  },
];

// Markdown to HTML
function mdToHTML(md) {
  if (!md || !md.trim()) return '<p style="color:#94a3b8;font-size:13px;">暂无深度分析内容</p>';
  var lines = md.split('\n');
  var result = [];
  var tableRows = [];

  function flushTable() {
    if (tableRows.length === 0) return;
    if (tableRows.length === 1) { result.push('<p>' + tableRows[0] + '</p>'); tableRows = []; return; }
    var h = '<table><thead><tr>';
    var headers = tableRows[0].split('|').filter(function(c) { return c.trim(); });
    for (var hi = 0; hi < headers.length; hi++) h += '<th>' + headers[hi].trim() + '</th>';
    h += '</tr></thead><tbody>';
    for (var ri = 1; ri < tableRows.length; ri++) {
      if (tableRows[ri].indexOf('---') !== -1) continue;
      h += '<tr>';
      var cells = tableRows[ri].split('|');
      for (var ci = 1; ci < cells.length - 1; ci++) h += '<td>' + cells[ci].trim() + '</td>';
      h += '</tr>';
    }
    h += '</tbody></table>';
    result.push(h);
    tableRows = [];
  }

  for (var li = 0; li < lines.length; li++) {
    var trimmed = lines[li].trim();
    if (trimmed === '') { if (tableRows.length > 0) flushTable(); continue; }
    if (trimmed.indexOf('<pre>') !== -1) {
      if (tableRows.length > 0) flushTable();
      var pre = '';
      while (li < lines.length && lines[li].indexOf('</pre>') === -1) { pre += lines[li] + '\n'; li++; }
      pre += lines[li];
      result.push(pre);
      continue;
    }
    if (trimmed === '---') { if (tableRows.length > 0) flushTable(); result.push('<hr>'); continue; }
    if (trimmed.indexOf('### ') === 0) { if (tableRows.length > 0) flushTable(); result.push('<h3>' + trimmed.slice(4) + '</h3>'); continue; }
    if (trimmed.indexOf('#### ') === 0) { if (tableRows.length > 0) flushTable(); result.push('<h4>' + trimmed.slice(5) + '</h4>'); continue; }
    if (trimmed.indexOf('##### ') === 0) { if (tableRows.length > 0) flushTable(); result.push('<h5>' + trimmed.slice(6) + '</h5>'); continue; }
    if (trimmed.indexOf('> ') === 0) {
      if (tableRows.length > 0) flushTable();
      var bq = [];
      while (li < lines.length && lines[li].trim().indexOf('> ') === 0) { bq.push(lines[li].trim().slice(2)); li++; }
      li--;
      result.push('<blockquote><p>' + bq.join(' ') + '</p></blockquote>');
      continue;
    }
    if (trimmed.indexOf('|') !== -1) { tableRows.push(trimmed); continue; }
    if (tableRows.length > 0) flushTable();
    var p = trimmed.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>').replace(/\*(.+?)\*/g, '<em>$1</em>');
    result.push('<p>' + p + '</p>');
  }
  if (tableRows.length > 0) flushTable();
  return result.join('\n').replace(/<p>\s*<\/p>/g, '');
}

function getWordMD(word, dim) {
  var scripts = document.querySelectorAll('script[type="text/markdown"]');
  for (var i = 0; i < scripts.length; i++) {
    if (scripts[i].getAttribute('data-word') === word && scripts[i].getAttribute('data-dim') === dim) {
      return scripts[i].textContent;
    }
  }
  return '';
}

function renderWordList(wordsToShow) {
  var container = document.getElementById('word-list');
  var html = '';
  for (var wi = 0; wi < wordsToShow.length; wi++) {
    var w = wordsToShow[wi];
    var tagsHtml = '';
    for (var ri = 0; ri < w.relations.length; ri++) {
      for (var di = 0; di < RELATION_DIMS.length; di++) {
        if (RELATION_DIMS[di].id === w.relations[ri]) {
          var dim = RELATION_DIMS[di];
          tagsHtml += '<span class="dim-tag ' + getDimTagClass(dim.color) + '">' + dim.icon + ' ' + dim.id + '</span>';
          break;
        }
      }
    }
    var mdBtn = w.hasMD ? '<button onclick="event.stopPropagation();openWordDetail(\'' + w.word + '\')" style="padding:6px 12px;border-radius:99px;font-size:11px;font-weight:700;background:linear-gradient(135deg,#4F46E5,#6366F1);color:white;border:none;cursor:pointer;">\uD83E\uDE80 深度分析</button>' : '';
    html += '<div class="word-card" id="card-' + w.word + '">' +
      '<div class="word-card-header" onclick="toggleWordCard(\'' + w.word + '\')">' +
        '<div class="word-lemma">' + w.word + '</div>' +
        '<div class="word-meta"><div class="word-ph">' + w.ph + '</div><div class="word-pos">' + w.pos + ' · ' + w.cn + '</div></div>' +
        '<div style="display:flex;align-items:center;gap:8px;">' + mdBtn + '<div class="word-expand-icon">▼</div></div>' +
      '</div>' +
      '<div style="display:flex;flex-wrap:wrap;gap:6px;">' + tagsHtml + '</div>' +
      '<div class="word-detail" id="detail-' + w.word + '">' +
        '<p style="color:#94a3b8;font-size:13px;padding:8px 0;">' + (w.hasMD ? '点击上方"深度分析"按钮查看完整六维理解框架' : '暂无深度分析内容') + '</p>' +
      '</div>' +
    '</div>';
  }
  container.innerHTML = html;
}

function getDimTagClass(color) {
  var m = {'#10B981':'collocation','#4F46E5':'semantic','#6366F1':'semantic','#7C3AED':'metaphor','#DB2777':'semantic','#0891B2':'register','#EA580C':'phonology','#DC2626':'contrast','#9333EA':'metaphor','#BE185D':'phonology','#C026D3':'phonology','#059669':'collocation','#0284C7':'register','#EC4899':'phonology','#0D9488':'register','#D97706':'grammar'};
  return m[color] || 'semantic';
}

var expandedWord = null;
function toggleWordCard(word) {
  var detail = document.getElementById('detail-' + word);
  var card = document.getElementById('card-' + word);
  if (expandedWord && expandedWord !== word) {
    var prev = document.getElementById('detail-' + expandedWord);
    var prevCard = document.getElementById('card-' + expandedWord);
    if (prev) prev.style.display = 'none';
    if (prevCard) prevCard.classList.remove('expanded');
  }
  var isOpen = detail.style.display !== 'none';
  detail.style.display = isOpen ? 'none' : 'block';
  card.classList.toggle('expanded', !isOpen);
  expandedWord = isOpen ? null : word;
}

// State for detail page
var _curWord = null;
var _curDim = null;

var DIM_TAB_NAMES = {
  'dim1-semantic': '\uD83C\uDF7B\uFE0F 语义',
  'dim2-collocation': '\uD83E\uDD1D 搭配',
  'dim3-grammar': '\uD83D\uDD27 语法',
  'dim4-metaphor': '\uD83D\uDD04 隐喻',
  'dim5-contrast': '\uD83C\uDDE8\uD83C\uDDF3 英汉',
  'dim6-register': '\uD83C\uDFAD 语体',
};

function openWordDetail(word) {
  _curWord = word;
  _curDim = null;

  var w = null;
  for (var wi = 0; wi < WORDS.length; wi++) {
    if (WORDS[wi].word === word) { w = WORDS[wi]; break; }
  }
  if (!w || !w.hasMD) { showToast('暂无深度分析内容'); return; }

  var container = document.getElementById('page-detail');
  container.innerHTML = '';

  // Back button
  var backDiv = document.createElement('div');
  backDiv.style.cssText = 'display:flex;align-items:center;gap:8px;margin-bottom:12px;';
  var backBtn = document.createElement('button');
  backBtn.onclick = function() { showPage('words'); };
  backBtn.style.cssText = 'width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;background:#F1F5F9;border:none;font-size:16px;cursor:pointer;flex-shrink:0;';
  backBtn.textContent = '\u21A9';
  var backSpan = document.createElement('span');
  backSpan.style.cssText = 'font-size:15px;font-weight:600;color:#64748b;';
  backSpan.textContent = '返回单词列表';
  backDiv.appendChild(backBtn);
  backDiv.appendChild(backSpan);
  container.appendChild(backDiv);

  // Hero card
  var hero = document.createElement('div');
  hero.className = 'word-hero';
  hero.innerHTML =
    '<div class="word-hero-close" onclick="showPage(\'words\')">\u2715</div>' +
    '<div class="word-hero-lemma">' + w.word + '</div>' +
    '<div class="word-hero-ph">' + w.ph + ' · ' + w.pos + '</div>' +
    '<div class="word-hero-cn">' + w.cn + '</div>' +
    '<div class="word-hero-badges">' +
      '<span class="word-hero-badge">六维深度分析</span>' +
      '<span class="word-hero-badge">' + w.dims.length + '个维度</span>' +
      '<span class="word-hero-badge">认知语言学</span>' +
    '</div>';
  container.appendChild(hero);

  // Tabs container
  var tabsContainer = document.createElement('div');
  tabsContainer.className = 'dim-tabs';
  tabsContainer.id = 'detail-tabs';
  for (var ti = 0; ti < w.dims.length; ti++) {
    var dimId = w.dims[ti];
    var tab = document.createElement('div');
    tab.className = 'dim-tab' + (ti === 0 ? ' active' : '');
    tab.textContent = DIM_TAB_NAMES[dimId] || dimId;
    tab.setAttribute('data-dim', dimId);
    tab.onclick = (function(d) { return function() { switchDetailDim(d); }; })(dimId);
    tabsContainer.appendChild(tab);
  }
  container.appendChild(tabsContainer);

  // Content panel
  var contentPanel = document.createElement('div');
  contentPanel.className = 'dim-content active';
  contentPanel.id = 'detail-panel';
  var mdBody = document.createElement('div');
  mdBody.className = 'md-body';
  mdBody.style.marginTop = '16px';
  contentPanel.appendChild(mdBody);
  container.appendChild(contentPanel);

  // Switch to detail page
  document.querySelectorAll('.tab-item').forEach(function(t) { t.classList.remove('active'); });
  document.querySelectorAll('.page').forEach(function(p) { p.classList.remove('active'); });
  container.classList.add('active');
  var allTabs = document.querySelectorAll('.tab-item');
  if (allTabs[2]) allTabs[2].classList.add('active');

  // Load first dim
  _curDim = w.dims[0];
  mdBody.innerHTML = mdToHTML(getWordMD(word, w.dims[0]));
}

function switchDetailDim(dimId) {
  if (!_curWord) return;
  _curDim = dimId;

  // Update tab active state
  var tabs = document.querySelectorAll('#detail-tabs .dim-tab');
  for (var ti = 0; ti < tabs.length; ti++) {
    tabs[ti].classList.remove('active');
    if (tabs[ti].getAttribute('data-dim') === dimId) tabs[ti].classList.add('active');
  }

  // Load content
  var panel = document.getElementById('detail-panel');
  var mdBody = panel.querySelector('.md-body');
  if (!mdBody) {
    mdBody = document.createElement('div');
    mdBody.className = 'md-body';
    mdBody.style.marginTop = '16px';
    panel.appendChild(mdBody);
  }
  mdBody.innerHTML = mdToHTML(getWordMD(_curWord, dimId));
  panel.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function filterWords() {
  var q = document.getElementById('word-search').value.trim().toLowerCase();
  var filtered = q ? WORDS.filter(function(w) { return w.word.indexOf(q) !== -1 || w.cn.indexOf(q) !== -1; }) : WORDS;
  renderWordList(filtered);
}

function renderDimButtons() {
  var groups = {
    body: document.getElementById('grid-body'),
    phonology: document.getElementById('grid-phonology'),
    semantic: document.getElementById('grid-semantic'),
    register: document.getElementById('grid-register'),
    derivation: document.getElementById('grid-derivation'),
    learning: document.getElementById('grid-learning'),
  };
  for (var g in groups) { if (groups[g]) groups[g].innerHTML = ''; }

  for (var di = 0; di < RELATION_DIMS.length; di++) {
    var dim = RELATION_DIMS[di];
    var wordCount = 0;
    for (var wi = 0; wi < WORDS.length; wi++) {
      if (WORDS[wi].relations.indexOf(dim.id) !== -1) wordCount++;
    }
    if (wordCount === 0) continue;
    var btn = document.createElement('div');
    btn.className = 'dim-btn';
    btn.style.color = dim.color;
    btn.id = 'dim-btn-' + dim.id;
    btn.onclick = (function(id) { return function() { toggleDimFilter(id); }; })(dim.id);
    btn.innerHTML =
      '<div class="dim-btn-color-bar" style="background:' + dim.color + '"></div>' +
      '<div class="dim-btn-icon">' + dim.icon + '</div>' +
      '<div class="dim-btn-name">' + dim.name + '</div>' +
      '<div class="dim-btn-count">' + wordCount + '词</div>';
    if (groups[dim.group]) groups[dim.group].appendChild(btn);
  }
}

var activeDims = [];
function toggleDimFilter(dimId) {
  var btn = document.getElementById('dim-btn-' + dimId);
  var idx = activeDims.indexOf(dimId);
  if (idx === -1) { activeDims.push(dimId); btn.classList.add('active'); }
  else { activeDims.splice(idx, 1); btn.classList.remove('active'); }
  updateDimFilter();
}

function updateDimFilter() {
  var container = document.getElementById('active-dims');
  var bar = document.getElementById('active-dim-bar');
  var countEl = document.getElementById('filter-count');
  var resultList = document.getElementById('filtered-word-list');
  if (activeDims.length === 0) { container.classList.add('hidden'); return; }
  container.classList.remove('hidden');

  var chipsHtml = '';
  for (var ci = 0; ci < activeDims.length; ci++) {
    for (var di = 0; di < RELATION_DIMS.length; di++) {
      if (RELATION_DIMS[di].id === activeDims[ci]) {
        var dim = RELATION_DIMS[di];
        chipsHtml += '<div class="active-dim-chip" style="background:' + dim.color + '22;color:' + dim.color + ';border-color:' + dim.color + ';" onclick="toggleDimFilter(\'' + dim.id + '\')">' + dim.icon + ' ' + dim.name + '<span class="chip-close">\u2715</span></div>';
        break;
      }
    }
  }
  bar.innerHTML = chipsHtml;

  var filteredWords = WORDS.filter(function(w) {
    for (var ai = 0; ai < activeDims.length; ai++) {
      if (w.relations.indexOf(activeDims[ai]) === -1) return false;
    }
    return true;
  });
  countEl.textContent = filteredWords.length;

  var listHtml = '';
  for (var fi = 0; fi < filteredWords.length; fi++) {
    var fw = filteredWords[fi];
    listHtml += '<div class="word-list-compact" onclick="openWordDetail(\'' + fw.word + '\')">' +
      '<div class="wlc-word">' + fw.word + '</div>' +
      '<div class="wlc-info"><div class="wlc-cn">' + fw.cn + '</div><div class="wlc-pos">' + fw.pos + ' · ' + fw.ph + '</div></div>' +
      (fw.hasMD ? '<span style="font-size:11px;color:#4F46E5;">\uD83E\uDE80</span>' : '') +
      '<div class="wlc-arrow">\u2192</div></div>';
  }
  resultList.innerHTML = listHtml || '<div style="text-align:center;padding:40px;color:#94a3b8;"><div style="font-size:40px;margin-bottom:10px;">\uD83D\uDD0D</div>当前维度组合没有匹配单词</div>';
}

function clearDimFilter() {
  activeDims = [];
  var btns = document.querySelectorAll('.dim-btn.active');
  for (var bi = 0; bi < btns.length; bi++) btns[bi].classList.remove('active');
  updateDimFilter();
}

function switchTab(el, page) {
  var tabs = document.querySelectorAll('.tab-item');
  for (var ti = 0; ti < tabs.length; ti++) tabs[ti].classList.remove('active');
  el.classList.add('active');
  var pages = document.querySelectorAll('.page');
  for (var pi = 0; pi < pages.length; pi++) pages[pi].classList.remove('active');
  document.getElementById('page-' + page).classList.add('active');
}

function showPage(page) {
  var tabs = document.querySelectorAll('.tab-item');
  for (var ti = 0; ti < tabs.length; ti++) tabs[ti].classList.remove('active');
  var pages = document.querySelectorAll('.page');
  for (var pi = 0; pi < pages.length; pi++) pages[pi].classList.remove('active');
  document.getElementById('page-' + page).classList.add('active');
  var pageMap = { words: 0, dims: 1, detail: 2 };
  if (pageMap[page] !== undefined && tabs[pageMap[page]]) tabs[pageMap[page]].classList.add('active');
}

function showToast(msg) {
  var t = document.getElementById('toast');
  t.textContent = msg;
  t.classList.add('show');
  setTimeout(function() { t.classList.remove('show'); }, 2000);
}

renderWordList(WORDS);
renderDimButtons();
</script>'''

# Build new file: before (lines 0-803) + new JS + after (lines 1337-end)
new_lines = lines[0:804] + [NEW_JS + '\n'] + lines[1337:]

with open(r'D:\mywork\techdoc\英语学习软件\app\prototype\index.html', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print(f'Done! New file has {len(new_lines)} lines')
print(f'Before: {len(lines[0:804])} lines, New JS: 1 block, After: {len(lines[1337:])} lines')
