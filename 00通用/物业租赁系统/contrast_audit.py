#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""对比度自检脚本（WCAG 2.1）—— 支持 CSS 变量展开
用法：python contrast_audit.py 文件.html [更多文件...]
判定：正文小字 4.5:1；图形/非文字要素 3:1（脚本按 4.5 检查文字、按 3.0 检查折线/圆点类图形色）
输出：所有低于门槛的"前景色 × 背景色"组合；0 项即全部达标。
局限：跨 CSS 规则继承的背景需人工确认一次（脚本只能读到同一条规则里的 background）。
"""
import re, sys

def lum(h):
    h = h.lstrip('#')
    r, g, b = [int(h[i:i+2], 16) / 255 for i in (0, 2, 4)]
    f = lambda c: c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b)

def cr(a, b):
    la, lb = lum(a), lum(b)
    hi, lo = max(la, lb), min(la, lb)
    return round((hi + 0.05) / (lo + 0.05), 2)

def load(path):
    return open(path, encoding='utf-8').read().split('\n')

def vars_of(lines):
    v = {}
    for l in lines:
        for m in re.finditer(r'(--[\w-]+)\s*:\s*(#[0-9a-fA-F]{6})', l):
            v[m.group(1)] = m.group(2)
    return v

def expand(val, V):
    m = re.match(r'var\((--[\w-]+)\)', val)
    return V.get(m.group(1), '') if m else val

TOKEN = r'(?:var\(--[\w-]+\)|#[0-9a-fA-F]{6})'

def audit(path, t_text=4.5, t_graphic=3.0):
    lines = load(path); V = vars_of(lines); bad = []
    for i, line in enumerate(lines, 1):
        # 1) SVG 文字 fill（白底）
        for m in re.finditer(r'<text[^>]*fill="(#[0-9a-fA-F]{6})"[^>]*>(.*?)</text>', line):
            c = cr(m.group(1), '#ffffff')
            if c < t_text:
                bad.append((i, f"SVG文字 {m.group(1)} / #ffffff", c, re.sub(r'<[^>]+>', '', m.group(2))[:18]))
        # 2) 同一 CSS 规则内的 color + background（含变量展开）
        fg = re.search(r'(?:^|;)color:(' + TOKEN + r')', line)
        bg = re.search(r'background:(' + TOKEN + r')', line)
        if fg and bg:
            f, b = expand(fg.group(1), V), expand(bg.group(1), V)
            if f and b and not f.lower() in ('#ffffff', '#fff'):
                c = cr(f, b)
                if c < t_text:
                    bad.append((i, f"{f} / {b}", c, line.strip()[:60]))
        # 3) 数据系列图形（折线/路径/节点圆点）：对象为白底
        for m in re.finditer(r'<(polyline|path|circle)\b[^>]*?(?:stroke|fill)="(#[0-9a-fA-F]{6})"', line):
            if 'marker' in line:
                continue
            c = cr(m.group(2), '#ffffff')
            if c < t_graphic:
                bad.append((i, f"系列图形 {m.group(1)} {m.group(2)} / #ffffff", c, line.strip()[:60]))
                break
    print(f"=== {path} ===")
    for i, what, c, ctx in bad:
        print(f"  L{i:<5} {what} = {c}  {ctx}")
    print(f"  低于门槛项：{len(bad)}")
    return len(bad)

if __name__ == '__main__':
    files = sys.argv[1:] or ['一图看懂_使用权资产与租赁负债.html', '一图看懂_使用权资产全生命周期.html']
    total = sum(audit(f) for f in files)
    print(f"\n合计不合格项：{total}（0 即全部达标）")
