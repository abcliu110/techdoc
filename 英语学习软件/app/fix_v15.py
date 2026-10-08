# -*- coding: utf-8 -*-
# 修复 fill_all_v15.py 中的语法错误
with open(r'D:\mywork\techdoc\英语学习软件\app\fill_all_v15.py', 'r', encoding='utf-8') as f:
    content = f.read()

# 删除废弃的 false_friends 列表和空循环
old = """false_friends = [
    ('actually','实际上不是"活跃地"','actual=实际的，ly是副词后缀'),
    ('considerate','不是"考虑的"而是"体贴的"','considerate=体贴周到，considerate考虑周到的'),
    ('considerable','不是"考虑的"而是"相当大的"','considerable=可观的，considerate=体贴的'),
    ('eventually','不是"事件地"而是"最终"','eventually最终=finally/in the end'),
    ('sensible','不是"敏感的"而是"明智的"','sensible=明智的，sensitive=敏感的'),
    ('quite','不是"安静地"而是"相当"','quite=相当，quiet=安静的'),
    ('present','不是"礼物"而是"现在的"','present作为礼物时重音在second'),
    ('quite','不是"安静"而是"相当"','quite=相当，quiet=安静'),
    ('library','不是"liberary"而是"图书馆"','library图书馆，librarian图书馆管理员'),
    ('sane','不是"same"而是"健全的"','sane健全的，same相同的'),
    ('mansion','不是普通"大厦"而是"豪宅"','mansion豪宅/大厦，非普通建筑'),
    ('recipe','不是"食谱"（完整）而是"食谱/处方"','recipe食谱，含配方含义'),
    ('busy','不是"企业"而是"忙的"','busy忙的，business企业'),
    ('quite','不是"安静"而是"相当"','quite=相当，quiet=安静'),
    ('expect','不是"期待"（完整）而是"期待/预料"','expect期待+预料，意义较宽'),
    ('story','不是"历史"而是"故事"','story故事，history历史'),
    ('quite','不是"安静"而是"相当"','quite=相当，quiet=安静'),
    ('quite','不是"安静"','quite=相当，quiet=安静'),
    ('real','不是"真实"（单独用）而是"真实的"','real作形容词=真实的，really=真实地'),
    ('loud','不是"大声地"而是形容词"大声的"','loud=大声的（adj/adv），loudly=副词形式'),
    ('most','不是"最多"（单独用）而是"大多数"','most=大多数，almost=几乎'),
    ('near','不是"近"（名词）而是形容词"近的"','near=近的/介词，nearly=几乎'),
    ('just','不是"正好"（单独用）而是"刚才/只是/公正的"','just=刚才/只是/公正的，justly=公正地'),
    ('broad','不是"宽广"（名词）而是形容词"宽广的"','broad宽广的，broadcast广播'),
    ('late','不是"迟到"（名词）而是形容词/副词"迟/晚"','late=迟的/迟地，lately=最近'),
    ('high','不是"高"（名词）而是形容词"高的"','high高的，height高度'),
    ('hard','不是"硬"（名词）而是形容词/副词"硬的/努力地"','hard硬的/努力地，hardly=几乎不'),
    ('daily','不是"每天"（名词）而是形容词/副词"每天的/每天地"','daily=每日的/每日地，everyday=日常的'),
    ('most','不是"最多"而是"大多数"','most大多数，almost几乎'),
    ('quite','不是"安静"','quite=相当，quiet=安静'),
    ('sensible','不是"敏感"','sensible=明智的，sensitive=敏感的'),
    ('like','不是"像"（名词）而是介词/动词"像/喜欢"','like=像/喜欢，likely=可能的'),
    ('near','不是"近"（名词）','near=近/介词，nearly=几乎'),
    ('direct','不是"方向"（名词）而是形容词"直接的"','direct=直接的，direction=方向'),
    ('novel','不是"小说"（唯一含义）而是"新颖的"','novel=新颖的/小说，novel=小说时重音在前'),
    ('poor','不是"贫困的"（唯一含义）而是"可怜的/差的"','poor=可怜的/差的/贫困的'),
    ('quite','不是"安静"','quite=相当，quiet=安静'),
    ('real','不是"真实"（名词）','real=真实的，really=真实地'),
    ('quite','不是"安静"','quite=相当，quiet=安静'),
]

ff_rows = []
for wrong, trap, note in false_friends:
    # 假朋友：英语词（正确词）vs 误解
    # relation_type=false_friend: 两词本身相关但易混
    pass  # 假朋友是两个英语词之间的关系，不是"英语词"vs"误解"
# 重新定义：假朋友是两个英语词之间容易混淆的关系
false_friend_pairs = ["""

new = """false_friend_pairs = ["""

content = content.replace(old, new)
print(f"replace result: {old[:50] in content}")

with open(r'D:\mywork\techdoc\英语学习软件\app\fill_all_v15.py', 'w', encoding='utf-8') as f:
    f.write(content)
print('Done')
