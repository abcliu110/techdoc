# Embed HTML content into index.html using <template> elements
# Strategy: <template> elements are completely ignored by browser, JS reads via .innerHTML
# No escaping issues, no network, no CDN, no </script> problems

import os, re

PROTOTYPE_DIR = r'D:\mywork\techdoc\英语学习软件\app\prototype'
INDEX_HTML = os.path.join(PROTOTYPE_DIR, 'index.html')
MD_DIR = os.path.join(PROTOTYPE_DIR, 'md')

def md_to_html(md):
    lines = md.split('\n')
    result = []
    table_rows = []

    def flush_table():
        if not table_rows: return ''
        if len(table_rows) == 1:
            return '<p>' + table_rows[0] + '</p>'
        headers = [c.strip() for c in table_rows[0].split('|') if c.strip()]
        h = '<table><thead><tr>'
        for hdr in headers: h += '<th>' + hdr + '</th>'
        h += '</tr></thead><tbody>'
        for row in table_rows[1:]:
            if '---' in row: continue
            cells = [c.strip() for c in row.split('|')]
            h += '<tr>'
            for cell in cells[1:-1]: h += '<td>' + cell + '</td>'
            h += '</tr>'
        h += '</tbody></table>'
        return h

    def inline(text):
        text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)
        text = re.sub(r'\*(.+?)\*', r'<em>\1</em>', text)
        text = re.sub(r'`([^`]+)`', r'<code>\1</code>', text)
        return text

    i = 0
    while i < len(lines):
        t = lines[i].strip()

        # Triple backtick code blocks -> <pre>
        if t.startswith('```'):
            if table_rows: result.append(flush_table()); table_rows = []
            code_lines = []
            i += 1
            while i < len(lines) and not lines[i].strip().startswith('```'):
                code_lines.append(lines[i])
                i += 1
            i += 1
            result.append('<pre>' + '\n'.join(code_lines) + '</pre>')
            continue

        if t == '':
            if table_rows: result.append(flush_table()); table_rows = []
            i += 1; continue
        if t == '---':
            if table_rows: result.append(flush_table()); table_rows = []
            result.append('<hr>'); i += 1; continue
        if t.startswith('### '):
            if table_rows: result.append(flush_table()); table_rows = []
            result.append('<h3>' + t[4:] + '</h3>'); i += 1; continue
        if t.startswith('#### '):
            if table_rows: result.append(flush_table()); table_rows = []
            result.append('<h4>' + t[5:] + '</h4>'); i += 1; continue
        if t.startswith('##### '):
            if table_rows: result.append(flush_table()); table_rows = []
            result.append('<h5>' + t[6:] + '</h5>'); i += 1; continue
        if t.startswith('> '):
            if table_rows: result.append(flush_table()); table_rows = []
            result.append('<blockquote><p>' + inline(t[2:]) + '</p></blockquote>'); i += 1; continue
        if '|' in t:
            table_rows.append(t); i += 1; continue
        if table_rows: result.append(flush_table()); table_rows = []
        result.append('<p>' + inline(t) + '</p>'); i += 1

    if table_rows: result.append(flush_table())
    return '\n'.join(result)


# Load and convert all md files
dims = [
    ('run', 'semantic'),
    ('run', 'collocation'),
    ('run', 'grammar'),
    ('run', 'metaphor'),
    ('run', 'contrast'),
    ('run', 'register'),
]

template_blocks = []
for word, dim in dims:
    filepath = os.path.join(MD_DIR, word + '-' + dim + '.md')
    if not os.path.exists(filepath):
        print(f'WARNING: {filepath} not found')
        continue
    with open(filepath, 'r', encoding='utf-8') as f:
        md_content = f.read()
    html_content = md_to_html(md_content)
    tpl_id = 'tpl-' + word + '-' + dim
    template_blocks.append('<template id="' + tpl_id + '">\n' + html_content + '\n</template>')
    print(f'  {tpl_id}: {len(html_content)} chars')

templates_html = '\n\n'.join(template_blocks)
print(f'Total template HTML: {len(templates_html)} chars\n')

# Read index.html
with open(INDEX_HTML, 'r', encoding='utf-8') as f:
    html = f.read()

# 1. Remove CDN marked.js
html = re.sub(r'<script src="https://cdn\.jsdelivr\.net/npm/marked/marked\.min\.js"></script>\n?', '', html)

# 2. Replace WORDS dims: remove 'file' field, keep only {id, label}
for w in ['run', 'grasp']:
    old_dims = """    dims: [
      { id: 'semantic',    label: '🏷️ 语义',    file: 'md/""" + w + """-semantic.md' },
      { id: 'collocation', label: '🤝 搭配',    file: 'md/""" + w + """-collocation.md' },
      { id: 'grammar',     label: '🔧 语法',    file: 'md/""" + w + """-grammar.md' },
      { id: 'metaphor',    label: '🔄 隐喻',    file: 'md/""" + w + """-metaphor.md' },
      { id: 'contrast',    label: '🇨🇳 英汉',   file: 'md/""" + w + """-contrast.md' },
      { id: 'register',    label: '🎭 语体',    file: 'md/""" + w + """-register.md' },
    ],"""
    new_dims = """    dims: [
      { id: 'semantic',    label: '🏷️ 语义' },
      { id: 'collocation', label: '🤝 搭配' },
      { id: 'grammar',     label: '🔧 语法' },
      { id: 'metaphor',    label: '🔄 隐喻' },
      { id: 'contrast',    label: '🇨🇳 英汉' },
      { id: 'register',    label: '🎭 语体' },
    ],"""
    if old_dims in html:
        html = html.replace(old_dims, new_dims)
        print(f'Updated WORDS dims for {w}')
    else:
        print(f'WARNING: WORDS dims pattern not found for {w}')

# 3. Replace loadMD function body to use templates instead of XHR
old_loadMD = """// ============================================================
// Markdown 内容缓存（加载一次，重复使用）
// ============================================================

  var xhr = new XMLHttpRequest();
  xhr.open('GET', url, true);
  xhr.onload = function() {
    if (xhr.status === 200 || xhr.status === 0) {
      mdCache[url] = xhr.responseText;
      callback(xhr.responseText);
    } else {
      callback('**加载失败：** ' + url);
    }
  };
  xhr.onerror = function() {
    callback('**加载失败：** ' + url);
  };
  xhr.send();
}"""

new_loadMD = """// ============================================================
// 从 <template> 读取 HTML 内容（无需网络）
// ============================================================
function loadMD(word, dim, callback) {
  var tpl = document.getElementById('tpl-' + word + '-' + dim);
  callback(tpl ? tpl.innerHTML : '<p style="color:#94a3b8;">暂无内容</p>');
}"""

if old_loadMD in html:
    html = html.replace(old_loadMD, new_loadMD)
    print('Replaced loadMD function')
else:
    print('WARNING: loadMD pattern not found, trying alternate...')
    # Try to find and replace the function body
    idx = html.find('var xhr = new XMLHttpRequest()')
    if idx != -1:
        # Find start of comment block before it
        start = html.rfind('// =================================', 0, idx)
        # Find end: the closing brace of the function
        brace_count = 0
        started = False
        end = idx
        for ci in range(idx, len(html)):
            if html[ci] == '{': brace_count += 1; started = True
            elif html[ci] == '}':
                brace_count -= 1
                if started and brace_count == 0:
                    end = ci + 1
                    break
        if start != -1:
            html = html[:start] + new_loadMD + '\n' + html[end:]
            print('Replaced loadMD via manual search')

# 4. Update callers: loadMD(dim.file, ...) -> loadMD(w.word, dim.id, ...)
# The call is: loadMD(dim.file, function(text) { ... })
# We need: loadMD(w.word, dim.id, function(html) { mdBody.innerHTML = html; })
html = html.replace('loadMD(dim.file, function(text) {', 'loadMD(w.word, dim.id, function(html) {')
html = html.replace('mdBody.innerHTML = marked.parse(text);', 'mdBody.innerHTML = html;')
print('Updated loadMD callers')

# 5. Insert templates before </body>
body_pos = html.rfind('</body>')
if body_pos == -1:
    print('ERROR: cannot find </body>')
    exit(1)
html = html[:body_pos] + '\n\n' + templates_html + '\n\n' + html[body_pos:]
print(f'Inserted {len(template_blocks)} <template> blocks')

with open(INDEX_HTML, 'w', encoding='utf-8') as f:
    f.write(html)

print('\nDone!')
