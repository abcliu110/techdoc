# Convert markdown to HTML and embed into index.html as JS variable
# Key insight: HTML content in JS strings must escape </script> as <\/script>

import os, re

PROTOTYPE_DIR = r'D:\mywork\techdoc\英语学习软件\app\prototype'
INDEX_HTML = os.path.join(PROTOTYPE_DIR, 'index.html')

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
            # Skip the closing ```
            i += 1
            pre_content = '\n'.join(code_lines)
            result.append('<pre>' + pre_content + '</pre>')
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


def escape_js_str(s):
    """Escape for JS double-quoted string literal."""
    # </script> in JS string: HTML parser sees it as end of script tag.
    # Fix: escape backslash -> JS sees \\/ as literal \/, HTML parser sees <\/ not </
    s = s.replace('\\', '\\\\')      # backslash -> \\
    s = s.replace('"', '\\"')          # double quote -> \"
    s = s.replace('\n', '\\n')        # newline
    s = s.replace('\r', '\\r')          # carriage return
    s = s.replace('\t', '\\t')        # tab
    s = s.replace('</script>', '<\\/script>')  # CRITICAL: prevents early script close
    return s


# Load md files
MD_DIR = os.path.join(PROTOTYPE_DIR, 'md')
dims = [
    ('run', 'semantic',     'md/run-semantic.md'),
    ('run', 'collocation',  'md/run-collocation.md'),
    ('run', 'grammar',      'md/run-grammar.md'),
    ('run', 'metaphor',     'md/run-metaphor.md'),
    ('run', 'contrast',     'md/run-contrast.md'),
    ('run', 'register',     'md/run-register.md'),
]

html_data = {}
for word, dim, filepath in dims:
    path = os.path.join(PROTOTYPE_DIR, filepath)
    with open(path, 'r', encoding='utf-8') as f:
        md_content = f.read()
    html_data[(word, dim)] = md_to_html(md_content)
    print(f'  {filepath} -> {len(html_data[(word, dim)])} chars')

# Build JS
js_lines = ['var MD_CONTENT = {']
for (word, dim), html in sorted(html_data.items()):
    key = word + '|' + dim
    escaped = escape_js_str(html)
    js_lines.append('  "' + key + '": "' + escaped + '",')
js_lines.append('};')
js_data = '\n'.join(js_lines)
print(f'Total JS data: {len(js_data)} chars\n')

# Read index.html
with open(INDEX_HTML, 'r', encoding='utf-8') as f:
    html = f.read()

# Remove CDN marked.js - no longer needed
html = re.sub(r'<script src="https://cdn\.jsdelivr\.net/npm/marked/marked\.min\.js"></script>\n?', '', html)

# Insert/replace MD_CONTENT before RELATION_DIMS
insert_before = 'var RELATION_DIMS = ['
pos = html.find(insert_before)
if pos == -1:
    print('ERROR: cannot find RELATION_DIMS')
    exit(1)

if 'var MD_CONTENT = {' in html:
    start = html.find('var MD_CONTENT = {')
    end = html.find('};', start) + 2
    html = html[:start] + js_data + '\n\n' + html[end:]
    print('Replaced existing MD_CONTENT')
else:
    html = html[:pos] + js_data + '\n\n' + html[pos:]
    print('Inserted new MD_CONTENT')

# Update getWordMD to use MD_CONTENT dict
new_getWordMD = '''function getWordMD(word, dim) {
  return MD_CONTENT[word + '|' + dim] || '';
}'''

idx = html.find('function getWordMD')
if idx != -1:
    # Find the function body
    brace = html.index('{', idx)
    depth = 1
    i = brace + 1
    while i < len(html) and depth > 0:
        if html[i] == '{': depth += 1
        elif html[i] == '}': depth -= 1
        i += 1
    html = html[:idx] + new_getWordMD + html[i:]
    print('Replaced getWordMD function')
else:
    print('WARNING: getWordMD not found')

# Remove old script[type="text/markdown"] blocks
before = len(html)
html = re.sub(r'<script type="text/markdown"[^>]*>[\s\S]*?</script>\n?', '', html)
removed = before - len(html)
if removed > 0:
    print(f'Removed {removed} chars of old script blocks')

# Remove old script[type="text/html"] blocks
html = re.sub(r'<script type="text/html"[^>]*>[\s\S]*?</script>\n?', '', html)

# Remove loadMD function (no longer needed)
old_loadMD = re.search(r'function loadMD\(url, callback\).*?\}\s*\n', html, re.DOTALL)
if old_loadMD:
    html = html[:old_loadMD.start()] + html[old_loadMD.end():]
    print('Removed loadMD function')

# Remove mdCache (no longer needed)
html = re.sub(r'var mdCache = \{\};\n', '', html)

with open(INDEX_HTML, 'w', encoding='utf-8') as f:
    f.write(html)

print('\nDone!')
