# -*- coding: utf-8 -*-
"""Eric 财务文档排版辅助函数（定稿版）。

规格：仿宋正文与数字+Palatino 英文，1.35 倍行距，段后 0，首行缩进 2 字符，
数字中文无空格（autoSpace 关闭），黑色标题，浅蓝 #DCE6F1 表头/合计行，
三线表+tblGrid+垂直居中+跨页表头重复。

用法：
    from docx_helpers import *
    doc = new_doc('2026年6月经营分析报告')
    h1(doc, '一、核心结论'); body(doc, '……')
    table(doc, '表 1：……（单位：万元）', headers, rows, widths_cm)
"""
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_LINE_SPACING, WD_COLOR_INDEX
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.section import WD_ORIENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

INK = RGBColor(0x33, 0x33, 0x33)
GRAY = RGBColor(0x80, 0x80, 0x80)
HEADER_FILL = 'DCE6F1'   # 表头/合计行浅蓝
ZEBRA_FILL = 'F5F8FC'    # 长表隔行浅底（同色系更淡）

# macOS 字体名；Windows 环境替换为 '仿宋'/'黑体'
FANG, HEI = 'STFangsong', 'Heiti SC'
LATIN, LATIN_H = 'Palatino', 'Arial'


def set_run(run, size=10.5, east=FANG, ascii_f=FANG, color=INK, bold=False):
    """中文与数字用仿宋；英文单词请经 write_text 走 Palatino。"""
    run.font.size = Pt(size)
    run.font.bold = bold
    run.font.color.rgb = color
    run.font.name = ascii_f
    run._element.rPr.rFonts.set(qn('w:eastAsia'), east)
    return run


import re as _re

def write_text(p, text, **kw):
    """按内容写 run：纯英文片段用 Palatino，中文和数字用仿宋。"""
    kw.pop('ascii_f', None)
    for seg in _re.split(r'([A-Za-z][A-Za-z \-\.]*[A-Za-z]|[A-Za-z])', text):
        if not seg:
            continue
        is_en = bool(_re.match(r'^[A-Za-z]', seg))
        set_run(p.add_run(seg), ascii_f=(LATIN if is_en else FANG), **kw)
    return p


def _no_autospace(p):
    """关闭 Word 自动加的中西文间距（用户要求数字与中文完全贴合）。"""
    ppr = p._p.get_or_add_pPr()
    for tag in ('w:autoSpaceDE', 'w:autoSpaceDN'):
        e = OxmlElement(tag)
        e.set(qn('w:val'), '0')
        ppr.append(e)


def _field(par, instr, size=9):
    r = par.add_run()
    for t, txt in (('begin', None), (None, instr), ('end', None)):
        if t:
            e = OxmlElement('w:fldChar'); e.set(qn('w:fldCharType'), t)
        else:
            e = OxmlElement('w:instrText'); e.text = txt
        r._element.append(e)
    set_run(r, size, color=GRAY)


def new_doc(title):
    """A4 + 页边距 + 页眉(文档标题+细线) + 页脚(第X页 共Y页) + 主标题。"""
    doc = Document()
    s = doc.sections[0]
    s.page_width, s.page_height = Cm(21), Cm(29.7)
    s.top_margin = s.bottom_margin = Cm(2.54)
    s.left_margin = s.right_margin = Cm(2.8)

    hp = s.header.paragraphs[0]
    hp.alignment = WD_ALIGN_PARAGRAPH.CENTER
    set_run(hp.add_run(title), 9, color=GRAY)
    pbdr = OxmlElement('w:pBdr'); b = OxmlElement('w:bottom')
    b.set(qn('w:val'), 'single'); b.set(qn('w:sz'), '4')
    b.set(qn('w:color'), 'BFBFBF')
    pbdr.append(b); hp._p.get_or_add_pPr().append(pbdr)

    fp = s.footer.paragraphs[0]
    fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
    set_run(fp.add_run('第 '), 9, color=GRAY)
    _field(fp, 'PAGE')
    set_run(fp.add_run(' 页  共 '), 9, color=GRAY)
    _field(fp, 'NUMPAGES')
    set_run(fp.add_run(' 页'), 9, color=GRAY)

    # 主标题：18pt 黑体加粗黑色居中，段前段后 0.5 行
    p = doc.add_paragraph(); p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    pf = p.paragraph_format
    pf.space_before = pf.space_after = Pt(11)
    set_run(p.add_run(title), 18, east=HEI, ascii_f=LATIN_H, bold=True)
    _no_autospace(p)
    return doc


def body(doc, text, indent=True, align=WD_ALIGN_PARAGRAPH.JUSTIFY, **font):
    """正文：小四 12pt 仿宋，1.35 倍行距，段后 0，首行缩进 2 字符。"""
    p = doc.add_paragraph(); p.alignment = align
    pf = p.paragraph_format
    pf.line_spacing_rule = WD_LINE_SPACING.MULTIPLE
    pf.line_spacing = 1.35
    pf.space_after = Pt(0)
    pf.widow_control = True
    if indent:
        pf.first_line_indent = Pt(24)
    _no_autospace(p)
    write_text(p, text, **font)
    return p


def _heading(doc, text, size, before, after):
    p = doc.add_paragraph()
    pf = p.paragraph_format
    pf.keep_with_next = True
    pf.space_before, pf.space_after = Pt(before), Pt(after)
    _no_autospace(p)
    set_run(p.add_run(text), size, east=HEI, ascii_f=LATIN_H, bold=True)
    return p


def h1(doc, text):
    """一级标题「一、」12pt 黑体黑色。"""
    return _heading(doc, text, 12, 6, 3)


def h2(doc, text):
    """二级标题「（一）」11pt 黑体黑色。"""
    return _heading(doc, text, 11, 4, 2)


def note_para(doc, text, size=9):
    """表注/辅助说明：9pt 灰色。"""
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(4)
    p.paragraph_format.space_after = Pt(10)
    _no_autospace(p)
    set_run(p.add_run(text), size, color=GRAY)
    return p


def _bd(name, parent, sz=None, val='single', color='333333'):
    e = OxmlElement(name)
    e.set(qn('w:val'), val)
    if val != 'nil':
        e.set(qn('w:sz'), str(sz)); e.set(qn('w:color'), color)
    parent.append(e)


def table(doc, caption, headers, rows, widths_cm, num_cols=None,
          zebra=None, note=None, size=10.5):
    """投行风三线表（定稿全规格）。

    headers: 表头列表; rows: 二维数据; widths_cm: 各列宽 cm
    num_cols: 数字列下标集合（右对齐，表头跟随右对齐），默认除第 0 列全部
    zebra: 隔行浅底，默认 >10 行自动开
    note: 表注文字（不含「注：」前缀请自带）
    """
    if num_cols is None:
        num_cols = set(range(1, len(headers)))
    if zebra is None:
        zebra = len(rows) > 10

    # 表题：表上方 10.5pt 黑体
    cp = doc.add_paragraph()
    cp.paragraph_format.space_before = Pt(10)
    cp.paragraph_format.space_after = Pt(4)
    cp.paragraph_format.keep_with_next = True
    _no_autospace(cp)
    set_run(cp.add_run(caption), 10.5, east=HEI, ascii_f=LATIN_H, bold=True)

    t = doc.add_table(rows=len(rows) + 1, cols=len(headers))
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    t.autofit = False
    tbl_pr = t._tbl.tblPr

    # tblGrid 列网格：必须写，只设 cell.width 部分渲染器会失效
    grid = OxmlElement('w:tblGrid')
    for w in widths_cm:
        gc = OxmlElement('w:gridCol')
        gc.set(qn('w:w'), str(int(w * 567)))
        grid.append(gc)
    if t._tbl.tblGrid is not None:
        t._tbl.remove(t._tbl.tblGrid)
    tbl_pr.addnext(grid)

    borders = OxmlElement('w:tblBorders')
    for n in ('w:top', 'w:left', 'w:bottom', 'w:right',
              'w:insideH', 'w:insideV'):
        _bd(n, borders, val='nil')
    tbl_pr.append(borders)

    def cell_border(cell, **kw):
        tc = cell._tc.get_or_add_tcPr()
        b = OxmlElement('w:tcBorders')
        for n, sz in kw.items():
            _bd('w:' + n, b, sz=sz)
        tc.append(b)

    def shade(cell, fill):
        sd = OxmlElement('w:shd')
        sd.set(qn('w:val'), 'clear'); sd.set(qn('w:fill'), fill)
        cell._tc.get_or_add_tcPr().append(sd)

    def prep(cell):
        tc = cell._tc.get_or_add_tcPr()
        va = OxmlElement('w:vAlign'); va.set(qn('w:val'), 'center')
        tc.append(va)
        for p in cell.paragraphs:
            p.paragraph_format.space_before = Pt(0)
            p.paragraph_format.space_after = Pt(0)
            _no_autospace(p)

    def rowh(row, h=420):
        trPr = row._tr.get_or_add_trPr()
        e = OxmlElement('w:trHeight')
        e.set(qn('w:val'), str(h)); e.set(qn('w:hRule'), 'atLeast')
        trPr.append(e)

    # 表头行：重复标题行 + 浅蓝底 + 表头跟随列对齐
    rowh(t.rows[0])
    t.rows[0]._tr.get_or_add_trPr().append(OxmlElement('w:tblHeader'))
    for j, h in enumerate(headers):
        c = t.cell(0, j); c.width = Cm(widths_cm[j]); prep(c)
        p = c.paragraphs[0]
        p.alignment = (WD_ALIGN_PARAGRAPH.RIGHT if j in num_cols
                       else WD_ALIGN_PARAGRAPH.LEFT)
        set_run(p.add_run(str(h)), size, east=HEI, ascii_f=LATIN_H, bold=True)
        cell_border(c, top=12, bottom=6)
        shade(c, HEADER_FILL)

    for i, row in enumerate(rows, start=1):
        rowh(t.rows[i])
        t.rows[i]._tr.get_or_add_trPr().append(OxmlElement('w:cantSplit'))
        is_total = str(row[0]).strip() in ('合计', '总计')
        for j, v in enumerate(row):
            c = t.cell(i, j); c.width = Cm(widths_cm[j]); prep(c)
            p = c.paragraphs[0]
            p.alignment = (WD_ALIGN_PARAGRAPH.RIGHT if j in num_cols
                           else WD_ALIGN_PARAGRAPH.LEFT)
            write_text(p, str(v), size=size, bold=is_total)
            if is_total:
                cell_border(c, top=6)
                shade(c, HEADER_FILL)
            elif zebra and i % 2 == 0:
                shade(c, ZEBRA_FILL)
            if i == len(rows):
                cell_border(c, bottom=12)
    if note:
        note_para(doc, note)
    return t


def landscape_section(doc):
    """新起横页节（宽表用），页眉页脚自动沿用。"""
    doc.add_section()
    s = doc.sections[-1]
    s.orientation = WD_ORIENT.LANDSCAPE
    s.page_width, s.page_height = Cm(29.7), Cm(21)
    s.top_margin = s.bottom_margin = Cm(2.54)
    s.left_margin = s.right_margin = Cm(2.8)
    return s


def portrait_section(doc):
    """横页后回到纵页。"""
    doc.add_section()
    s = doc.sections[-1]
    s.orientation = WD_ORIENT.PORTRAIT
    s.page_width, s.page_height = Cm(21), Cm(29.7)
    s.top_margin = s.bottom_margin = Cm(2.54)
    s.left_margin = s.right_margin = Cm(2.8)
    return s


def money(x, digits=2):
    """金额千分位（负数普通负号）。只用于金额/数量，编码类数字勿用。"""
    return f'{x:,.{digits}f}'


def highlight(run):
    """校对存疑标黄。"""
    run.font.highlight_color = WD_COLOR_INDEX.YELLOW
    return run
