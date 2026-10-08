# -*- coding: utf-8 -*-
with open(r'D:\mywork\techdoc\英语学习软件\app\fill_all.py', 'r', encoding='utf-8') as f:
    content = f.read()

old = "coll_rows.append((next_id_coll, sid, 'verb_object', verb, None, f'{verb} + {noun} 搭配'))"
new = "coll_rows.append((next_id_coll, sid, 'verb_object', f'{verb} {noun}', None, f'{verb} + {noun} 搭配', None, 'v1.0'))"
content = content.replace(old, new)

old2 = "coll_rows.append((next_id_coll, sid, 'adj_noun', None, adj, f'{adj} + {noun} 搭配'))"
new2 = "coll_rows.append((next_id_coll, sid, 'adj_noun', f'{adj} {noun}', None, f'{adj} + {noun} 搭配', None, 'v1.0'))"
content = content.replace(old2, new2)

old3 = "c_added = batch_insert('word_collocations', ['id','sense_id','coll_type','verb','adjective','pattern'], coll_rows)"
new3 = "c_added = batch_insert('word_collocations', ['id','sense_id','coll_type','collocation','complement_pattern','example','example_cn','source_version'], coll_rows)"
content = content.replace(old3, new3)

with open(r'D:\mywork\techdoc\英语学习软件\app\fill_all.py', 'w', encoding='utf-8') as f:
    f.write(content)
print('Done')
