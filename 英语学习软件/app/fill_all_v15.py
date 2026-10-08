# -*- coding: utf-8 -*-
"""
v1.5 新增维度数据填充脚本
覆盖: meronym/holonym, regional_variant, prepositional_verb, false_friend,
      back_derived, metonymy, pseudo_cognate, allomorph, prepositional collocation
"""
import sqlite3

db = r'D:\mywork\techdoc\英语学习软件\english_learning.sqlite3'
conn = sqlite3.connect(db)
cur = conn.cursor()

def batch_insert(table, cols, rows, batch=80):
    total = 0
    for i in range(0, len(rows), batch):
        b = rows[i:i+batch]
        vals = ','.join('(' + ','.join(f"'{str(v)}'" if v is not None else 'NULL' for v in r) + ')' for r in b)
        sql = f"INSERT OR IGNORE INTO {table} ({','.join(cols)}) VALUES {vals}"
        cur.execute(sql)
        conn.commit()
        total += cur.rowcount
    return total

def insert_relations(rows):
    """word_relations 批量插入（无主键冲突问题，用 OR IGNORE）"""
    return batch_insert('word_relations',
        ['source_word_id','target_word_id','relation_type','direction','explanation'],
        rows)

# ── 获取词ID映射 ──────────────────────────────────────────────────────
cur.execute("SELECT id, lemma FROM words")
wm = {l: i for i, l in cur.fetchall()}
existing_rel = set()
cur.execute("SELECT source_word_id, target_word_id, relation_type FROM word_relations")
for s, t, rt in cur.fetchall():
    existing_rel.add((s, t, rt))

print(f"已有 word_relations: {len(existing_rel)} 条")

# ── 1. Meronym / Holonym（部分整体关系）───────────────────────────────
print("\n=== 1. Meronym/Holonym ===")
meronym_pairs = [
    # finger/hand/arm/body 系统
    ('finger','hand','手指是手的一部分'),('thumb','hand','拇指是手的一部分'),
    ('hand','arm','手是手臂的一部分'),('arm','body','手臂是身体的一部分'),
    ('leg','body','腿是身体的一部分'),('foot','leg','脚是小腿的一部分'),
    ('toe','foot','脚趾是脚的一部分'),('head','body','头是身体的一部分'),
    ('neck','body','脖子是身体的一部分'),('eye','head','眼睛是头的一部分'),
    ('nose','head','鼻子是头的一部分'),('mouth','head','嘴是头的一部分'),
    ('ear','head','耳朵是头的一部分'),('hair','head','头发是头的一部分'),
    ('page','book','页是书的一部分'),('chapter','book','章节是书的一部分'),
    ('sentence','paragraph','句子是段落的一部分'),('paragraph','essay','段落是文章的一部分'),
    ('word','sentence','词是句子的一部分'),('letter','word','字母是单词的一部分'),
    ('wheel','car','轮子是汽车的一部分'),('engine','car','发动机是汽车的一部分'),
    ('door','car','车门是汽车的一部分'),('seat','car','座椅是汽车的一部分'),
    ('window','house','窗户是房子的一部分'),('door','house','门是房子的一部分'),
    ('roof','house','屋顶是房子的一部分'),('wall','house','墙是房子的一部分'),
    ('floor','room','地板是房间的一部分'),('ceiling','room','天花板是房间的一部分'),
    ('petal','flower','花瓣是花的一部分'),('leaf','tree','叶子是树的一部分'),
    ('root','tree','根是树的一部分'),('branch','tree','树枝是树的一部分'),
    ('stem','flower','茎是花的一部分'),('ingredient','recipe','配料是食谱的一部分'),
    ('wheel','bicycle','轮子是自行车的一部分'),('handlebar','bicycle','车把是自行车的一部分'),
    ('saddle','bicycle','车座是自行车的一部分'),('chain','bicycle','链条是自行车的一部分'),
    ('screen','computer','屏幕是电脑的一部分'),('keyboard','computer','键盘是电脑的一部分'),
    ('mouse','computer','鼠标是电脑的一部分'),('CPU','computer','CPU是电脑的一部分'),
    ('screen','phone','屏幕是手机的一部分'),('battery','phone','电池是手机的一部分'),
    ('button','shirt','纽扣是衬衫的一部分'),('sleeve','shirt','袖子是衬衫的一部分'),
    ('collar','shirt','领子是衬衫的一部分'),('heel','shoe','鞋跟是鞋子的一部分'),
    ('sole','shoe','鞋底是鞋子的一部分'),('lace','shoe','鞋带是鞋子的一部分'),
    ('ingredient','food','配料是食物的一部分'),('salt','food','盐是食物的一部分'),
    ('team','class','队员是班级的一部分'),('student','class','学生是班级的一部分'),
    ('teacher','school','老师是学校的一部分'),('classroom','school','教室是学校的一部分'),
    ('chapter','course','章节是课程的一部分'),('lesson','course','课时是课程的一部分'),
    ('player','team','球员是球队的一员'),('captain','team','队长是球队的一员'),
    ('note','music','音符是音乐的一部分'),('beat','music','节拍是音乐的一部分'),
    ('scene','play','场景是戏剧的一部分'),('act','play','幕是戏剧的一部分'),
    ('scene','movie','场景是电影的一部分'),('episode','series','集是系列剧的一部分'),
    ('page','newspaper','页是报纸的一部分'),('headline','newspaper','标题是报纸的一部分'),
    ('story','magazine','故事是杂志的一部分'),('ad','magazine','广告是杂志的一部分'),
    ('ingredient','cake','配料是蛋糕的一部分'),('butter','cake','黄油是蛋糕的一部分'),
    ('flour','bread','面粉是面包的一部分'),('yeast','bread','酵母是面包的一部分'),
    ('carbon','water','碳是水的组成部分'),('hydrogen','water','氢是水的组成部分'),
    ('page','magazine','页是杂志的一部分'),('cover','book','封面是书的一部分'),
    ('spine','book','书脊是书的一部分'),('glue','book','胶水是书的一部分'),
    ('CPU','phone','处理器是手机的一部分'),('chip','computer','芯片是电脑的一部分'),
    ('wire','machine','电线是机器的一部分'),('gear','machine','齿轮是机器的一部分'),
    ('motor','machine','马达是机器的一部分'),('blade','fan','扇叶是风扇的一部分'),
    ('tube','toothpaste','管身是牙膏的一部分'),('cap','pen','笔帽是笔的一部分'),
    ('film','camera','胶卷是相机的一部分'),('lens','camera','镜头是相机的一部分'),
    ('wing','bird','翅膀是鸟的一部分'),('feather','bird','羽毛是鸟的一部分'),
    ('beak','bird','喙是鸟的一部分'),('tail','fish','尾巴是鱼的一部分'),
    ('fin','fish','鱼鳍是鱼的一部分'),('shell','turtle','壳是乌龟的一部分'),
    ('trunk','elephant','象鼻是大象的一部分'),('horn','rhino','角是犀牛的一部分'),
    ('fang','snake','毒牙是蛇的一部分'),('paw','dog','爪子是狗的一部分'),
    ('claw','cat','爪子是猫的一部分'),('mane','lion','鬃毛是狮子的一部分'),
    ('stripe','zebra','条纹是斑马的一部分'),('antler','deer','鹿角是鹿的一部分'),
    ('peel','orange','皮是橙子的一部分'),('seed','apple','籽是苹果的一部分'),
    ('skin','banana','皮是香蕉的一部分'),('core','apple','核是苹果的一部分'),
    ('crumb','cake','屑是蛋糕的一部分'),('frosting','cake','糖霜是蛋糕的一部分'),
    ('icing','cake','糖衣是蛋糕的一部分'),('cream','cake','奶油是蛋糕的一部分'),
    ('handle','knife','刀柄是刀的一部分'),('blade','knife','刀刃是刀的一部分'),
    ('point','pencil','笔尖是铅笔的一部分'),('eraser','pencil','橡皮是铅笔的一部分'),
    ('graphite','pencil','石墨是铅笔的芯'),('tip','pen','笔尖是笔的一部分'),
    ('ink','pen','墨水是笔的一部分'),('page','notebook','页是笔记本的一部分'),
    ('cover','notebook','封面是笔记本的一部分'),('binding','book','装订是书的一部分'),
]

mer_rows = []
for part, whole, note in meronym_pairs:
    pid = wm.get(part)
    wid = wm.get(whole)
    if pid and wid:
        k = (pid, wid, 'meronym')
        if k not in existing_rel:
            mer_rows.append((pid, wid, 'meronym', 'one_way', note))
            existing_rel.add(k)

m1 = insert_relations(mer_rows)
print(f"  meronym 新增: {m1} 条")

# ── 2. Regional Variant（美英差异）──────────────────────────────────
print("\n=== 2. Regional Variant ===")
regional_pairs = [
    ('apartment','flat','美式公寓 vs 英式公寓','us_uk'),
    ('elevator','lift','美式电梯 vs 英式电梯','us_uk'),
    ('trash','rubbish','美式垃圾 vs 英式垃圾','us_uk'),
    ('garbage','rubbish','美式垃圾 vs 英式垃圾','us_uk'),
    ('sidewalk','pavement','美式人行道 vs 英式人行道','us_uk'),
    ('cookies','biscuits','美式饼干 vs 英式饼干','us_uk'),
    ('fries','chips','美式薯条 vs 英式薯条','us_uk'),
    ('soccer','football','美式足球 vs 英式橄榄球','us_uk'),
    ('pants','trousers','美式裤子 vs 英式裤子','us_uk'),
    ('candy','sweets','美式糖果 vs 英式糖果','us_uk'),
    ('schedule','timetable','美式时间表 vs 英式时间表','us_uk'),
    ('gas','petrol','美式汽油 vs 英式汽油','us_uk'),
    ('truck','lorry','美式卡车 vs 英式卡车','us_uk'),
    ('zipper','zip','美式拉链 vs 英式拉链','us_uk'),
    ('can','tin','美式罐头 vs 英式罐头','us_uk'),
    ('store','shop','美式商店 vs 英式商店','us_uk'),
    ('subway','underground','美式地铁 vs 英式地铁','us_uk'),
    ('movie','film','美式电影 vs 英式电影','us_uk'),
    ('fall','autumn','美式秋天 vs 英式秋天','us_uk'),
    ('apartment','flat','美式公寓 vs 英式公寓','us_au'),
    ('holiday','holiday','美式假期 vs 英式假期（语义重叠）','us_au'),
    ('mobile','cell','手机','us_au'),
    ('mobile phone','cell phone','手机','us_uk'),
    ('bill','note','美式账单 vs 美钞','us_uk'),
    ('eraser','rubber','美式橡皮 vs 英式橡皮','us_uk'),
    ('cookie','biscuit','美式饼干 vs 英式饼干','us_uk'),
    ('cell phone','mobile phone','美式手机 vs 英式手机','us_uk'),
    ('football','soccer','美式足球=橄榄球 vs 英式足球','us_uk'),
    ('gray','grey','美式拼写 vs 英式拼写','us_uk'),
    ('honor','honour','美式拼写 vs 英式拼写','us_uk'),
    ('center','centre','美式拼写 vs 英式拼写','us_uk'),
    ('theater','theatre','美式拼写 vs 英式拼写','us_uk'),
    ('color','colour','美式拼写 vs 英式拼写','us_uk'),
    ('favor','favour','美式拼写 vs 英式拼写','us_uk'),
    ('behavior','behaviour','美式拼写 vs 英式拼写','us_uk'),
    ('organize','organise','美式拼写 vs 英式拼写','us_uk'),
    ('realize','realise','美式拼写 vs 英式拼写','us_uk'),
    ('analyze','analyse','美式拼写 vs 英式拼写','us_uk'),
    ('program','programme','美式程序 vs 英式节目','us_uk'),
    ('check','cheque','美式支票 vs 英式支票','us_uk'),
    ('disk','disc','美式磁盘 vs 英式光盘','us_uk'),
    ('aluminum','aluminium','美式铝 vs 英式铝','us_uk'),
    ('caliber','calibre','美式口径 vs 英式口径','us_uk'),
    ('defense','defence','美式防御 vs 英式防御','us_uk'),
    ('offense','offence','美式进攻 vs 英式进攻','us_uk'),
    ('license','licence','美式执照 vs 英式执照','us_uk'),
    ('practice','practise','美式实践 vs 英式实践','us_uk'),
    ('advice','advise','名词建议 vs 动词建议','us_uk'),
    ('device','devise','名词装置 vs 动词设计','us_uk'),
    ('lose','loose','丢失 vs 松的','us_uk'),
    ('lead','led','领导(动词) vs 领导(过去式)','us_uk'),
    ('principle','principal','原则 vs 校长/主要的','us_uk'),
    ('weather','whether','天气 vs 是否','us_uk'),
    ('quiet','quite','安静 vs 相当','us_uk'),
    ('past','passed','过去 vs 通过(动词)','us_uk'),
    ('personal','personnel','个人的 vs 人员的','us_uk'),
    ('statue','statute','雕像 vs 法规','us_uk'),
    ('later','latter','之后 vs 后者','us_uk'),
    ('except','accept','除了 vs 接受','us_uk'),
    ('affect','effect','影响(动词) vs 效果(名词)','us_uk'),
]

reg_rows = []
for us, uk, note, dialect in regional_pairs:
    uid = wm.get(us)
    kid = wm.get(uk)
    if uid and kid:
        k = (uid, kid, 'regional_variant')
        if k not in existing_rel:
            reg_rows.append((uid, kid, 'regional_variant', 'symmetric', note))
            # 同时插入反向（对称）
            k2 = (kid, uid, 'regional_variant')
            if k2 not in existing_rel:
                reg_rows.append((kid, uid, 'regional_variant', 'symmetric', note))
                existing_rel.add(k2)
            existing_rel.add(k)

m2 = insert_relations(reg_rows)
print(f"  regional_variant 新增: {m2} 条")

# ── 3. Prepositional Verb Collocation（介词动词搭配）─────────────────
print("\n=== 3. Prepositional Verb Collocation ===")
# 检查现有 coll_type
cur.execute("SELECT DISTINCT coll_type FROM word_collocations")
existing_ct = {r[0] for r in cur.fetchall()}
print(f"  现有 coll_type: {existing_ct}")

# 介词动词搭配 → 直接 insert 到 word_collocations
preposition_verbs = [
    ('depend','on','depend on sb./sth.','取决于...'),
    ('consist','of','consist of sth.','由...组成'),
    ('believe','in','believe in doing sth.','相信...'),
    ('result','in','result in sth.','导致...'),
    ('lead','to','lead to sth.（to为介词）','导致...'),
    ('listen','to','listen to sb./sth.','听...'),
    ('wait','for','wait for sb./sth.','等待...'),
    ('search','for','search for sth.','搜索...'),
    ('succeed','in','succeed in doing','在...成功'),
    ('apologize','for','apologize for sth.','为...道歉'),
    ('suffer','from','suffer from sth.','遭受...'),
    ('think','of','think of sth.','想到...'),
    ('think','about','think about sth.','考虑...'),
    ('dream','of','dream of doing','梦想...'),
    ('insist','on','insist on doing','坚持...'),
    ('look','forward','look forward to doing','期待...'),
    ('object','to','object to sth.','反对...'),
    ('react','to','react to sth.','对...反应'),
    ('apply','for','apply for sth.','申请...'),
    ('apply','to','apply to sth.','适用于...'),
    ('believe','in','believe in sb.','信任某人'),
    ('consist','in','consist in sth.','在于...'),
    ('rely','on','rely on sb./sth.','依赖...'),
    ('count','on','count on sb.','依靠...'),
    ('knock','at','knock at the door','敲...'),
    ('arrive','at','arrive at a place','到达...'),
    ('arrive','in','arrive in a city','到达...'),
    ('aim','at','aim at sth.','瞄准...'),
    ('laugh','at','laugh at sb.','嘲笑...'),
    ('smile','at','smile at sb.','对...微笑'),
    ('worry','about','worry about sth.','担心...'),
    ('care','about','care about sth.','关心...'),
    ('hear','of','hear of sb./sth.','听说...'),
    ('hear','about','hear about sth.','得知...'),
    ('approve','of','approve of sth.','赞成...'),
    ('warn','of','warn of sth.','警告...'),
    ('remind','of','remind sb. of sth.','使...想起...'),
    ('die','of','die of disease','死于...'),
    ('die','from','die from cause','因...而死'),
    ('recover','from','recover from illness','从...康复'),
    ('suffer','from','suffer from illness','患有...'),
    ('protect','from','protect from danger','保护...免受'),
    ('prevent','from','prevent from doing','阻止...'),
    ('stop','from','stop from doing','阻止...'),
    ('distinguish','from','distinguish A from B','区分A和B'),
    ('separate','from','separate from','与...分离'),
    ('differ','from','differ from','与...不同'),
    ('borrow','from','borrow from sb.','向...借'),
    ('demand','of','demand of sb.','要求...'),
    ('ask','for','ask for help','请求...'),
    ('pay','for','pay for sth.','为...付钱'),
    ('spend','on','spend money on sth.','把钱花在...'),
    ('thank','for','thank for sth.','为...感谢'),
    ('blame','for','blame for sth.','因...责备'),
    ('excuse','for','excuse for sth.','...的理由'),
    ('praise','for','praise for sth.','因...赞扬'),
    ('criticize','for','criticize for doing','因...批评'),
    ('punish','for','punish for doing','因...惩罚'),
    ('reward','with','reward with sth.','用...奖励'),
    ('exchange','for','exchange for sth.','交换...'),
    ('mistake','for','mistake A for B','把A误认为B'),
    ('confuse','with','confuse A with B','混淆A和B'),
    ('replace','with','replace A with B','用B替换A'),
    ('exchange','with','exchange with sb.','与...交换'),
    ('associate','with','associate with sth.','与...联系'),
    ('compare','with','compare A with B','将A与B比较'),
    ('compete','with','compete with sb.','与...竞争'),
    ('deal','with','deal with sth.','处理...'),
    ('meet','with','meet with sb.','与...会面'),
    ('agree','with','agree with sb./sth.','同意...'),
    ('disagree','with','disagree with','不同意...'),
    ('argue','with','argue with sb.','与...争论'),
    ('fight','with','fight with sb.','与...打架'),
    ('quarrel','with','quarrel with sb.','与...争吵'),
    ('tamper','with','tamper with sth.','擅自改动...'),
    ('interfere','with','interfere with sth.','干扰...'),
    ('mess','with','mess with sth.','乱动...'),
    ('reason','with','reason with sb.','与...讲道理'),
    ('begin','with','begin with sth.','以...开始'),
    ('end','with','end with sth.','以...结束'),
    ('start','with','start with sth.','以...开始'),
    ('finish','with','finish with sth.','完成...'),
    ('help','with','help with sth.','帮助做...'),
    ('struggle','with','struggle with sth.','与...斗争'),
    ('agree','on','agree on sth.','就...达成一致'),
    ('concentrate','on','concentrate on sth.','专注于...'),
    ('focus','on','focus on sth.','聚焦于...'),
    ('rely','upon','rely upon（正式）','依靠...'),
    ('count','upon','count upon（正式）','依赖...'),
    ('act','on','act on advice','按建议行动'),
    ('base','on','base on sth.','基于...'),
    ('decide','on','decide on sth.','决定...'),
    ('insist','upon','insist upon sth.','坚持...'),
    ('comment','on','comment on sth.','评论...'),
    ('depend','upon','depend upon（正式）','取决于...'),
    ('comment','upon','comment upon（正式）','评论...'),
    ('reflect','on','reflect on sth.','反思...'),
    ('reflect','upon','reflect upon（正式）','反思...'),
    ('remark','on','remark on sth.','评论...'),
    ('touch','on','touch on sth.','涉及...'),
    ('impinge','on','impinge on sth.','侵犯...'),
    ('infringe','on','infringe on sth.','侵犯...'),
    ('intrude','on','intrude on sth.','打扰...'),
    ('preside','over','preside over sth.','主持...'),
    ('laugh','off','laugh off sth.','对...一笑置之'),
    ('play','with','play with sth.','玩...'),
    ('talk','with','talk with sb.','与...交谈'),
    ('talk','to','talk to sb.','对...说话'),
    ('supply','with','supply with sth.','供给...'),
    ('provide','with','provide with sth.','提供...'),
    ('equip','with','equip with sth.','装备...'),
    ('fill','with','fill with sth.','装满...'),
    ('cover','with','cover with sth.','覆盖...'),
    ('replace','by','replace A by B','用B替换A'),
]

# 获取 sense_id
cur.execute("SELECT ws.id, w.lemma FROM word_senses ws JOIN words w ON ws.word_id=w.id")
sm = {l: s for s, l in cur.fetchall()}

# 检查现有 collocations
cur.execute("SELECT sense_id, collocation FROM word_collocations")
existing_coll = {(r[0], r[1]) for r in cur.fetchall()}

pv_rows = []
next_id = cur.execute("SELECT MAX(id) FROM word_collocations").fetchone()[0] or 0
added = 0
for items in preposition_verbs:
    if len(items) == 4:
        verb, prep, pattern, note = items
    else:
        continue
    coll_str = f'{verb} {prep}'
    sid = sm.get(verb)
    if sid and (sid, coll_str) not in existing_coll:
        next_id += 1
        pv_rows.append((next_id, sid, coll_str, 'prepositional_verb', None, pattern, note, 'v1.5'))
        existing_coll.add((sid, coll_str))
        added += 1

pv_batch = batch_insert('word_collocations',
    ['id','sense_id','collocation','coll_type','complement_pattern','example','example_cn','source_version'],
    pv_rows)
print(f"  prepositional_verb 新增: {pv_batch} 条")

# ── 4. False Friend（假朋友）────────────────────────────────────────
print("\n=== 4. False Friend ===")
false_friends = [
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
    ('quite','不是"安静"而是"相当"','quite相当，quiet安静'),
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
false_friend_pairs = [
    ('actual','actually','actual是形容词"实际的"，actually是副词"实际上"','l1_transfer'),
    ('sensible','sensitive','sensible是"明智的"，sensitive是"敏感的"','l1_transfer'),
    ('considerate','considerable','considerate是"体贴的"，considerable是"相当大的"','l1_transfer'),
    ('historic','historical','historic是"历史性的"，historical是"历史的"','l1_transfer'),
    ('economic','economical','economic是"经济上的"，economical是"节约的"','l1_transfer'),
    ('electric','electrical','electric是"电动的"，electrical是"电气的"','l1_transfer'),
    ('alternate','alternative','alternate是"交替的"，alternative是"替代的"','l1_transfer'),
    ('classic','classical','classic是"经典的"，classical是"古典的"','l1_transfer'),
    ('envious',' ENVIOUS','envious是"羡慕的"，envious=嫉妒的（拼写变体）','l1_transfer'),
    ('imply','infer','imply暗示，infer推断（方向不同）','meaning'),
    ('ensure','insure','ensure确保，insure保险','meaning'),
    ('appraise','apprise','appraise评估，apprise通知','meaning'),
    ('discreet','discrete','discreet谨慎，discrete分离的','spelling'),
    ('definite','definitive','definite明确，definitive权威的','meaning'),
    ('disinterested','uninterested','disinterested公正，uninterested不感兴趣','meaning'),
    ('elicit','illicit','elicit引出，illicit非法的','spelling'),
    ('loose','lose','loose松的，lose丢失','spelling'),
    ('past','passed','past过去/介词，passed通过（动词）','meaning'),
    ('principal','principle','principal校长/主要的，principle原则','spelling'),
    ('stationary','stationery','stationary固定的，stationery文具','spelling'),
    ('weather','whether','weather天气，whether是否','spelling'),
    ('accept','except','accept接受，except除了','spelling'),
    ('affect','effect','affect影响（动），effect效果（名）','meaning'),
    ('advice','advise','advice建议（名），advise建议（动）','spelling'),
    ('device','devise','device装置（名），devise设计（动）','spelling'),
    ('licence','license','licence执照（英），license许可（美/动词）','spelling'),
    ('practise','practice','practise实践（动/英），practice实践（名/美）','spelling'),
    ('quiet','quite','quiet安静，quite相当','spelling'),
    ('lead','led','lead领导（现/名），led领导（过去）','spelling'),
    ('wear','where','wear穿，where哪里','spelling'),
    ('which','witch','which哪个，witch女巫','spelling'),
    ('their','there','their他们的，there那里','spelling'),
    ('through','threw','through穿过，threw扔（过去）','spelling'),
    ('write','right','write写，right正确/右边','spelling'),
    ('no','know','no不，know知道','spelling'),
    ('be','bee','be是，bee蜜蜂','spelling'),
    ('four','for','four四，for为了','spelling'),
    ('eight','ate','eight八，ate吃（过去）','spelling'),
    ('meet','meat','meet遇见，meat肉','spelling'),
    ('weak','week','weak弱的，week周','spelling'),
    ('son','sun','son儿子，sun太阳','spelling'),
    ('blue','blew','blue蓝色，blew吹（过去）','spelling'),
    ('hear','here','hear听，here这里','spelling'),
    ('night','knight','night夜晚，knight骑士','spelling'),
    ('plain','plane','plain平原，plane飞机','spelling'),
    ('altar','alter','altar祭坛，alter改变','spelling'),
    ('born','borne','born出生，borne携带（过去分词）','spelling'),
    ('council','counsel','council委员会，counsel律师','spelling'),
    ('dessert','desert','dessert甜点，desert沙漠/抛弃','spelling'),
    ('farther','further','farther更远（距离），further进一步（程度）','meaning'),
    ('emigrant','immigrant','emigrant移出者，immigrant移入者','meaning'),
    ('ensure','assure','ensure确保，assure使确信','meaning'),
    ('complement','compliment','complement补充，compliment称赞','spelling'),
    ('clash','crash','clash冲突，crash坠毁','spelling'),
    ('intense','intensive','intense强烈的，intensive集约的','meaning'),
]

for w1, w2, note, ctype in false_friend_pairs:
    id1 = wm.get(w1)
    id2 = wm.get(w2)
    if id1 and id2:
        k = (id1, id2, 'false_friend')
        if k not in existing_rel:
            ff_rows.append((id1, id2, 'false_friend', 'symmetric', note))
            existing_rel.add(k)
            # 对称
            k2 = (id2, id1, 'false_friend')
            if k2 not in existing_rel:
                ff_rows.append((id2, id1, 'false_friend', 'symmetric', note))
                existing_rel.add(k2)

m4 = insert_relations(ff_rows)
print(f"  false_friend 新增: {m4} 条")

# ── 5. Back-formation（逆构词）───────────────────────────────────────
print("\n=== 5. Back-formation ===")
back_derived = [
    ('edit','editor','从editor逆构出edit（先有"编辑者"，后造"编辑"动词）'),
    ('automate','automation','从automation逆构出automate'),
    ('donate','donation','从donation逆构出donate'),
    ('diagnose','diagnosis','从diagnosis逆构出diagnose'),
    ('babysit','babysitter','从babysitter逆构出babysit'),
    ('enthuse','enthusiasm','从enthusiasm逆构出enthuse动词'),
    ('e-mail','mailbox','较新逆构用法（从mailbox逆构e-mail）'),
    ('televise','television','从television逆构出televise'),
    ('orientate','orientation','从orientation逆构出orientate（英式）'),
    ('laser','light amplification by stimulated emission of radiation','从缩写逆构出laser实际词'),
    ('radar','radio detection and ranging','从缩写逆构出radar'),
    ('scuba','self-contained underwater breathing apparatus','从缩写逆构出scuba'),
    ('medivac','medical evacuation','从缩写逆构出medivac'),
    ('comsci','computer science','从computer science逆构出comsci（口语）'),
    ('guesstimate','guess+estimate','从guess+estimate组合逆构出guesstimate'),
    ('netiquette','network+etiquette','从network+etiquette组合逆构出netiquette'),
    ('broadband','broad+band','从broad+band组合逆构出broadband'),
    ('smog','smoke+fog','从smoke+fog组合逆构出smog'),
    ('brunch','breakfast+lunch','从breakfast+lunch组合逆构出brunch'),
    ('motel','motor+hotel','从motor+hotel组合逆构出motel'),
    ('chunnel','channel+tunnel','从channel+tunnel组合逆构出chunnel'),
    ('franc','franc（法郎缩写）','从franc逆构'),
    ('gent','gentleman','从gentleman逆构出gent（非标准）'),
    ('repo','repossess','从repossess逆构出repo（美口语）'),
    ('demo','demonstration','从demonstration逆构出demo（口语）'),
    ('expo','exposition','从exposition逆构出expo'),
    ('memo','memorandum','从memorandum逆构出memo'),
    ('memo','memorandum','从memorandum逆构出memo'),
    ('specs','specifications','从specifications逆构出specs'),
    ('flu','influenza','从influenza逆构出flu'),
    ('phone','telephone','从telephone逆构出phone（截短逆构）'),
    ('bus','omnibus','从omnibus逆构出bus（截短）'),
    ('plane','aeroplane','从aeroplane截短逆构出plane'),
    ('bike','bicycle','从bicycle截短逆构出bike'),
    ('fridge','refrigerator','从refrigerator截短逆构出fridge'),
    ('gym','gymnasium','从gymnasium截短逆构出gym'),
    ('lab','laboratory','从laboratory截短逆构出lab'),
    ('ad','advertisement','从advertisement截短逆构出ad'),
    ('ad','advertisement','从advertisement截短逆构出ad'),
    ('lib','library','从library截短逆-lib'),
    ('vet','veterinarian','从veterinarian截短逆构出vet'),
    ('prof','professor','从professor截短逆构出prof'),
    ('math','mathematics','从mathematics截短逆构出math（美）'),
    ('maths','mathematics','从mathematics截短逆构出maths（英）'),
    ('polio','poliomyelitis','从poliomyelitis逆构出polio'),
    ('vic','victoria','从victoria逆构出vic（澳大利亚城市）'),
    ('mike','microphone','从microphone截短逆构出mike'),
    ('memo','memorandum','从memorandum截短逆构出memo'),
]

bd_rows = []
for derived, original, note in back_derived:
    did = wm.get(derived)
    oid = wm.get(original)
    if did and oid:
        k = (did, oid, 'back_derived')
        if k not in existing_rel:
            bd_rows.append((did, oid, 'back_derived', 'one_way', note))
            existing_rel.add(k)

m5 = insert_relations(bd_rows)
print(f"  back_derived 新增: {m5} 条")

# ── 6. Metonymy（转喻关联）──────────────────────────────────────────
print("\n=== 6. Metonymy ===")
metonymy_pairs = [
    ('White House','government','白宫代指美国政府','metonymy'),
    ('government','president','政府代指总统决策层','metonymy'),
    ('crown','royalty','王冠代指皇室/君主','metonymy'),
    ('Hollywood','film industry','好莱坞代指美国电影产业','metonymy'),
    ('Wall Street','financial district','华尔街代指美国金融界','metonymy'),
    ('press','journalists','新闻界代指记者群体','metonymy'),
    ('press','newspapers','出版界代指报纸媒体','metonymy'),
    ('Pentagon','military','五角大楼代指美国军方','metonymy'),
    ('Downing Street','British government','唐宁街代指英国政府','metonymy'),
    ('Elysee','French government','爱丽舍宫代指法国政府','metonymy'),
    ('pen','writer','笔代指作者/写作能力','metonymy'),
    ('sword','military force','剑代指军事力量','metonymy'),
    ('crown','monarchy','王冠代指王权','metonymy'),
    ('hand','worker','手代指工人/劳动力','metonymy'),
    ('wheels','car','轮子代指汽车','metonymy'),
    ('wheels','transport','轮子代指交通工具','metonymy'),
    ('bus','bus service','公交车代指公交服务','metonymy'),
    ('phone','telephone call','电话代指通话','metonymy'),
    ('book','reservation','预订（book a table=订桌位）','metonymy'),
    ('table','meeting','桌子代指会议（put on the table=提交讨论）','metonymy'),
    ('head','leader','头代指领导','metonymy'),
    ('heart','center','心脏代指中心/核心','metonymy'),
    ('eye','viewpoint','眼睛代指观点/看法','metonymy'),
    ('mouth','speech','嘴代指发言/话语权','metonymy'),
    ('face','dignity','面子代指尊严/体面','metonymy'),
    ('back','support','后背代指支持','metonymy'),
    ('foot','bottom','脚代指底部','metonymy'),
    ('mouth','river','河口（mouth of the river）','metonymy'),
    ('teeth','saw','锯齿（teeth of a saw）','metonymy'),
    ('leaf','pages','书页（leaf of a book，诗语）','metonymy'),
    ('glass','mirror','玻璃杯代指镜子','metonymy'),
    ('bread','food','面包代指食物/生计','metonymy'),
    ('silver','money','银代指金钱/财富','metonymy'),
    ('ivory','elephant','象牙代指大象（保护语境）','metonymy'),
    ('blue','sadness','蓝色代指悲伤（音乐/艺术语境）','metonymy'),
    ('red','danger','红色代指危险','metonymy'),
    ('green','environment','绿色代指环保/自然','metonymy'),
    ('gray','depression','灰色代指抑郁','metonymy'),
]

met_rows = []
for met, target, note, rtype in metonymy_pairs:
    mid = wm.get(met)
    tid = wm.get(target)
    if mid and tid:
        k = (mid, tid, 'metonymy')
        if k not in existing_rel:
            met_rows.append((mid, tid, 'metonymy', 'symmetric', note))
            existing_rel.add(k)

m6 = insert_relations(met_rows)
print(f"  metonymy 新增: {m6} 条")

# ── 7. Pseudo-cognate（形式相似语义无关）────────────────────────────
print("\n=== 7. Pseudo-cognate ===")
pseudo_cognate_pairs = [
    ('sane','same','sane健全≠same相同（形似）','pseudo_cognate'),
    ('quite','quiet','quite相当≠quiet安静（形似）','pseudo_cognate'),
    ('actually','actual','actually实际上≠actual实际的（有无ly）','pseudo_cognate'),
    ('library','librarian','library图书馆≠librarian图书馆员（词根同义不同）','pseudo_cognate'),
    ('eventually','event','eventually最终≠event事件（词根同但后缀不同）','pseudo_cognate'),
    ('actual','act','actual实际的≠act行为（词根相关但非同一词）','pseudo_cognate'),
    ('monument','monster','monument纪念碑≠monster怪物（形似）','pseudo_cognate'),
    ('chord','cord','chord和弦≠cord绳子（形似）','pseudo_cognate'),
    ('dessert','desert','dessert甜点≠desert沙漠（形似）','pseudo_cognate'),
    ('principal','principle','principal校长≠principle原则（形似）','pseudo_cognate'),
    ('rain','reign','rain雨≠reign统治（形似）','pseudo_cognate'),
    ('rain','rein','rain雨≠rein缰绳（形似）','pseudo_cognate'),
    ('site','sight','site场所≠sight视力（形似）','pseudo_cognate'),
    ('complement','compliment','complement补充≠compliment称赞（形似）','pseudo_cognate'),
    ('continuous','continual','continuous持续的≠continual频繁的（有区别）','pseudo_cognate'),
    ('historic','historical','historic历史性的≠historical历史的（有区别）','pseudo_cognate'),
    ('economic','economical','economic经济的≠economical节约的（有区别）','pseudo_cognate'),
    ('respectful','respectable','respectful尊敬的≠respectable值得尊敬的（有区别）','pseudo_cognate'),
    ('sensible','sensitive','sensible明智的≠sensitive敏感的（有区别）','pseudo_cognate'),
    ('eligible','illiterate','eligible合格的≠illiterate文盲的（形似但无关）','pseudo_cognate'),
    ('ingenious','ingenuous','ingenious独创的≠ingenuous天真的（形似）','pseudo_cognate'),
    ('imply','infer','imply暗示≠infer推断（方向不同）','pseudo_cognate'),
    ('stationary','stationery','stationary固定的≠stationery文具（形似）','pseudo_cognate'),
    ('personal','personnel','personal个人的≠personnel人员的（形似）','pseudo_cognate'),
    (' Statue ','statute','statue雕像≠statute法规（形似）','pseudo_cognate'),
    ('accommodate','accommodate','accommodate是唯一正确拼写（cc=mm）','pseudo_cognate'),
    ('embarrass','embarass','embarrass是正确拼写（rr=ss）','pseudo_cognate'),
]

pc_rows = []
for w1, w2, note, rtype in pseudo_cognate_pairs:
    w1 = w1.strip()
    w2 = w2.strip()
    id1 = wm.get(w1)
    id2 = wm.get(w2)
    if id1 and id2:
        k = (id1, id2, 'pseudo_cognate')
        if k not in existing_rel:
            pc_rows.append((id1, id2, 'pseudo_cognate', 'symmetric', note))
            existing_rel.add(k)

m7 = insert_relations(pc_rows)
print(f"  pseudo_cognate 新增: {m7} 条")

# ── 8. Allomorph（构词变体）→ 填充 word_morphemes ─────────────────
print("\n=== 8. Allomorph（扩展 word_morphemes）===")
# 在 morphemes 表已有词素的基础上，扩展 allomorph 关系
# 先检查 morphemes 表结构
cur.execute("PRAGMA table_info(morphemes)")
morph_rows = cur.execute("SELECT id, form, morph_type FROM morphemes").fetchall()
morphs = {m[1]: (m[0], m[2]) for m in morph_rows}
print(f"  morphemes已有: {len(morphs)} 个词素")

# 检查 word_morphemes 现有关联
cur.execute("SELECT word_id, morpheme_id, position_no FROM word_morphemes")
existing_wm = {(r[0], r[1]) for r in cur.fetchall()}
print(f"  已有word_morphemes关联: {len(existing_wm)}")

allomorph_mappings = [
    ('impossible','in-','否定前缀in-的同化变体im-'),
    ('immoral','in-','否定前缀in-的同化变体im-'),
    ('impolite','in-','否定前缀in-的同化变体im-'),
    ('impatient','in-','否定前缀in-的同化变体im-'),
    ('imperfect','in-','否定前缀in-的同化变体im-'),
    ('illegal','in-','否定前缀in-的同化变体il-'),
    ('illiterate','in-','否定前缀in-的同化变体il-'),
    ('illogical','in-','否定前缀in-的同化变体il-'),
    ('irregular','in-','否定前缀in-的同化变体ir-'),
    ('irresponsible','in-','否定前缀in-的同化变体ir-'),
    ('irrelevant','in-','否定前缀in-的同化变体ir-'),
    ('irreplaceable','in-','否定前缀in-的同化变体ir-'),
    ('irreversible','in-','否定前缀in-的同化变体ir-'),
    ('unhappy','un-','否定前缀un-'),
    ('undo','un-','否定前缀un-'),
    ('unlock','un-','否定前缀un-'),
    ('untie','un-','否定前缀un-'),
    ('unclear','un-','否定前缀un-'),
    ('unusual','un-','否定前缀un-'),
    ('unfair','un-','否定前缀un-'),
    ('unfold','un-','否定前缀un-'),
    ('rewrite','re-','重复前缀re-'),
    ('return','re-','重复前缀re-'),
    ('review','re-','重复前缀re-'),
    ('rebuild','re-','重复前缀re-'),
    ('retell','re-','重复前缀re-'),
    ('rethink','re-','重复前缀re-'),
    ('reappear','re-','重复前缀re-'),
    ('disagree','dis-','否定前缀dis-'),
    ('disappear','dis-','否定前缀dis-'),
    ('disallow','dis-','否定前缀dis-'),
    ('disconnect','dis-','否定前缀dis-'),
    ('disapprove','dis-','否定前缀dis-'),
    ('disbelieve','dis-','否定前缀dis-'),
    ('discard','dis-','否定前缀dis-'),
    ('disclose','dis-','否定前缀dis-'),
    ('discover','dis-','否定前缀dis-（发现=揭开）'),
    ('education','-tion','名词后缀-tion'),
    ('attention','-tion','名词后缀-tion'),
    ('question','-tion','名词后缀-tion'),
    ('nation','-tion','名词后缀-tion'),
    ('action','-tion','名词后缀-tion'),
    ('reaction','-tion','名词后缀-tion'),
    ('tradition','-tion','名词后缀-tion'),
    ('situation','-tion','名词后缀-tion'),
    ('pollution','-tion','名词后缀-tion'),
    ('decision','-sion','名词后缀-sion'),
    ('television','-sion','名词后缀-sion'),
    ('conclusion','-sion','名词后缀-sion'),
    ('invasion','-sion','名词后缀-sion'),
    ('explosion','-sion','名词后缀-sion'),
    ('expansion','-sion','名词后缀-sion'),
    ('quickly','-ly','副词后缀-ly'),
    ('slowly','-ly','副词后缀-ly'),
    ('happily','-ly','副词后缀-ly'),
    ('sadly','-ly','副词后缀-ly'),
    ('easily','-ly','副词后缀-ly'),
    ('beautifully','-ly','副词后缀-ly'),
    ('carefully','-ly','副词后缀-ly'),
    ('completely','-ly','副词后缀-ly'),
    ('carelessly','-ly','副词后缀-ly'),
    ('comfortable','-able','形容词后缀-able'),
    ('possible','-ible','形容词后缀-ible'),
    ('terrible','-ible','形容词后缀-ible'),
    ('invisible','-ible','形容词后缀-ible'),
    ('available','-able','形容词后缀-able'),
    ('reasonable','-able','形容词后缀-able'),
    ('valuable','-able','形容词后缀-able'),
    ('reliable','-ible','形容词后缀-ible'),
    ('responsible','-ible','形容词后缀-ible'),
    ('receive','-ceive','词根-ceive/-cept 变体'),
    ('perceive','-ceive','词根-ceive 变体'),
    ('conceive','-ceive','词根-ceive 变体'),
    ('deceive','-ceive','词根-ceive 变体'),
]

am_rows = []
pos = 1
for word, morpheme, note in allomorph_mappings:
    wid = wm.get(word)
    mid = morphs.get(morpheme)
    if wid and mid:
        mid_id = mid[0]
        key = (wid, mid_id)
        if key not in existing_wm:
            am_rows.append((wid, mid_id, pos, morpheme))
            existing_wm.add(key)
            pos += 1
            if pos > 5: pos = 1

am_added = 0
for i in range(0, len(am_rows), 50):
    b = am_rows[i:i+50]
    vals = ','.join(f"({r[0]},{r[1]},{r[2]},'{r[3]}')" for r in b)
    sql = f"INSERT OR IGNORE INTO word_morphemes (word_id,morpheme_id,position_no,surface_form) VALUES {vals}"
    cur.execute(sql)
    conn.commit()
    am_added += cur.rowcount

print(f"  allomorph/词素变体 word_morphemes 新增: {am_added} 条")

# ── 最终统计 ─────────────────────────────────────────────────────────
conn.commit()
print("\n=== 最终验证 ===")
for tbl in ['word_relations','word_collocations','word_morphemes','syntax_frames',
            'same_syntax_frames','metaphor_frames','word_metaphors',
            'connotation_groups','word_connotation_group',
            'topic_clusters','word_topic_clusters',
            'prerequisite_groups','word_prerequisites']:
    cur.execute(f"SELECT COUNT(*) FROM {tbl}")
    print(f"  {tbl}: {cur.fetchone()[0]}")

# 验证所有 relation_type 覆盖
cur.execute("SELECT relation_type, COUNT(*) FROM word_relations GROUP BY relation_type ORDER BY COUNT(*) DESC")
print("\n  关系类型分布:")
for rt, cnt in cur.fetchall():
    print(f"    {rt}: {cnt}")

# 验证 coll_type 分布
cur.execute("SELECT coll_type, COUNT(*) FROM word_collocations GROUP BY coll_type ORDER BY COUNT(*) DESC")
print("\n  搭配类型分布:")
for ct, cnt in cur.fetchall():
    print(f"    {ct}: {cnt}")

conn.close()
print("\n全部完成！")
