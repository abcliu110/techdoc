# -*- coding: utf-8 -*-
import sqlite3

db = r'D:\mywork\techdoc\英语学习软件\english_learning.sqlite3'
conn = sqlite3.connect(db)
cur = conn.cursor()

cur.execute("SELECT id, form, morph_type FROM morphemes")
morphemes = cur.fetchall()
print(f"morphemes: {len(morphemes)}")

cur.execute("SELECT id, lemma FROM words")
words = cur.fetchall()
print(f"words: {len(words)}")

cur.execute("SELECT word_id, position_no, surface_form FROM word_morphemes")
existing = set((r[0], r[1]) for r in cur.fetchall())
print(f"existing: {len(existing)}")

# 按类型排序：bound_root优先（更精确），然后root，前缀，后缀
type_order = {'bound_root': 0, 'root': 1, 'prefix': 2, 'suffix': 3}
morphs = sorted(morphemes, key=lambda x: (type_order.get(x[2], 99), -len(x[1])))
print(f"sorted morphs (top 5): {[(m[1], m[2]) for m in morphs[:5]]}")

matches = []
matched_words = set()

for wid, lemma in words:
    pos = 1
    used_ids = set()
    for mid, form, mtype in morphs:
        if mid in used_ids:
            continue
        sf = form.lstrip('-')
        # prefix: check startswith, suffix: check endswith, root/bound_root: check contains
        found = False
        if mtype == 'prefix' and lemma.startswith(sf):
            found = True
        elif mtype == 'suffix' and lemma.endswith(sf):
            found = True
        elif mtype in ('root', 'bound_root') and sf in lemma:
            found = True
        if found:
            key = (wid, pos)
            if key not in existing:
                matches.append((wid, mid, pos, sf))
                existing.add(key)
                matched_words.add(wid)
                used_ids.add(mid)
                pos += 1
                if pos > 5:
                    break

print(f"new matches: {len(matches)}, words: {len(matched_words)}")

# Insert
total = 0
for i in range(0, len(matches), 50):
    batch = matches[i:i+50]
    vals = ','.join(f"({r[0]},{r[1]},{r[2]},'{r[3]}')" for r in batch)
    sql = f"INSERT INTO word_morphemes (word_id, morpheme_id, position_no, surface_form) VALUES {vals}"
    try:
        cur.execute(sql)
        conn.commit()
        total += cur.rowcount
        print(f"  batch {i//50+1}: +{cur.rowcount}")
    except Exception as e:
        print(f"  batch {i//50+1} ERROR: {e}")

print(f"total inserted: {total}")
cur.execute("SELECT COUNT(*) FROM word_morphemes")
print(f"word_morphemes now: {cur.fetchone()[0]}")
conn.close()
