# -*- coding: utf-8 -*-
import sqlite3
db = r'D:\mywork\techdoc\英语学习软件\english_learning.sqlite3'
conn = sqlite3.connect(db)
cur = conn.cursor()
morphs = cur.execute('SELECT id, form, morph_type FROM morphemes').fetchall()
for m in sorted(morphs, key=lambda x: x[1]):
    print(m)
conn.close()
