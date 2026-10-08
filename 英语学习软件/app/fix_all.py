# -*- coding: utf-8 -*-
with open(r'D:\mywork\techdoc\英语学习软件\中小学英语学习App设计文档.md', 'r', encoding='utf-8') as f:
    content = f.read()

changes = []

# Fix 1: 3.1 五层分类架构补充"词根词缀"第5行
old_arch = """| 层次 | 核心对象 | 解决的问题 | 典型上层功能 |
|------|----------|------------|--------------|
| 词汇本体 | 词条、义项、词形、词素、发音 | 这个词是什么、由什么构成 | 单词卡、释义、跟读、拼写 |
| 语言关系 | 上下位、同反义、派生、搭配、易混 | 这个词和什么有关 | 词汇网络、辨析题、句型题 |
| 教学资源 | 课程、年级、单元、主题、词频、难度 | 什么时候教，教到什么程度 | 教材路径、分层推荐、单元练习 |
| 学习证据 | 技能、题型、错误、掌握度、复习状态 | 学生学会了什么 | 诊断、FSRS 复习调度、掌握报告 |"""

new_arch = """| 层次 | 核心对象 | 解决的问题 | 典型上层功能 |
|------|----------|------------|--------------|
| 词汇本体 | 词条、义项、词形、词素、发音 | 这个词是什么、由什么构成 | 单词卡、释义、跟读、拼写 |
| 语言关系 | 同根、同缀、同义，反义、上下位、搭配、易混 | 这个词和什么有关 | 词汇网络、辨析题、句型题 |
| 教学资源 | 课程、年级、单元、主题、词频、难度 | 什么时候教，教到什么程度 | 教材路径、分层推荐、单元练习 |
| 学习证据 | 技能、题型、错误、掌握度、复习状态 | 学生学会了什么 | 诊断、FSRS 复习调度、掌握报告 |
| 词根词缀 | 词根、词缀、词族、派生规则 | 通过构词法高效扩展词汇量 | 词族学习、前缀后缀、组合单词 |"""

if old_arch in content:
    content = content.replace(old_arch, new_arch)
    changes.append("Fix 1 OK: 3.1节补充词根词缀第5层")
else:
    changes.append("Fix 1 FAIL")

# Fix 2: 1.3用户分层补充高中行
old_users = """| 初中1-3年级（三级） | 12-15岁 | 综合运用与学业质量 | 高频词、词义辨析、系统构词法、词块产出 |

注：预备级课标"""

new_users = """| 初中1-3年级（三级） | 12-15岁 | 综合运用与学业质量 | 高频词、词义辨析、系统构词法、词块产出 |
| 高中1-3年级（高级） | 15-18岁 | 学术词汇与应试能力 | 学术词块、高考核心词、CET衔接、写作搭配 |

注：预备级课标"""

if old_users in content:
    content = content.replace(old_users, new_users)
    changes.append("Fix 2 OK: 1.3用户分层补充高中行")
else:
    changes.append("Fix 2 FAIL")

# Fix 3: 6.2词条数据量修正为2400-2800
old_6_2 = """| 词条（含词块） | 约1700（去重 lemma，含词块 250-300） |"""
new_6_2 = """| 词条（含词块） | 约2400-2800（K-12去重 lemma，含词块300-400） |"""

if old_6_2 in content:
    content = content.replace(old_6_2, new_6_2)
    changes.append("Fix 3 OK: 6.2词条数据量修正")
else:
    changes.append("Fix 3 FAIL")

# Fix 4: 6.2词素数据量修正（应与文档其他部分一致）
old_morph = """| 词素 | 词根120 / 前后缀80（含变体归并，按证据逐步录入） |"""
new_morph = """| 词素 | 词根200-300（含粘着词根）/ 前后缀100+（含变体归并，按证据逐步录入） |"""

if old_morph in content:
    content = content.replace(old_morph, new_morph)
    changes.append("Fix 4 OK: 6.2词素数据量修正")
else:
    changes.append("Fix 4 FAIL")

# Fix 5: 6.2补充词源故事优先级说明
old_story = """| 词源故事 | 200个 |"""
new_story = """| 词源故事 | 100-200个（高中段优先，高频词故事先行） |"""

if old_story in content:
    content = content.replace(old_story, new_story)
    changes.append("Fix 5 OK: 6.2词源故事说明")
else:
    changes.append("Fix 5 FAIL")

# Fix 6: 附录8.2主题群格式修正（去除多余逗号）
old_themes = """| 人与自我（self） | 个人情况、日常生活、兴趣爱好、情绪情感、计划安排、饮食健康、健康急救，语言学习 |
| 人与社会（society） | 家庭朋友、学校生活，人际交往、节假日、购物，文娱体育、旅游交通、通信网络、文学艺术，历史社会、职业工作、科学技术、热点话题 |
| 人与自然（nature） | 天气气候，自然世界、环境保护 |"""

new_themes = """| 人与自我（self） | 个人情况、日常生活、兴趣爱好、情绪情感、计划安排、饮食健康、健康急救、语言学习 |
| 人与社会（society） | 家庭朋友、学校生活、人际交往、节假日、购物、文娱体育、旅游交通、通信网络、文学艺术、历史社会、职业工作、科学技术、热点话题 |
| 人与自然（nature） | 天气气候、自然世界、环境保护 |"""

if old_themes in content:
    content = content.replace(old_themes, new_themes)
    changes.append("Fix 6 OK: 附录8.2主题群格式修正")
else:
    changes.append("Fix 6 FAIL")

# Fix 7: 3.3.12搭配示例中"take"拼写错误
old_take = """| take + 名词 | take a photo / take a break / take notes / take medicine |"""
new_take = """| take + 名词 | take a photo / take a break / take notes / take medicine |"""

if old_take in content:
    # already correct in the file, no change needed
    changes.append("Fix 7 OK: take搭配示例已正确")
else:
    changes.append("Fix 7 FAIL")

# Fix 8: word_relations direction枚举值统一为one_way
old_dir = "direction       TEXT NOT NULL CHECK(direction IN ('symmetric','one_way','directed'))),"
new_dir = "direction       TEXT NOT NULL CHECK(direction IN ('symmetric','one_way','directed')),  -- symmetric=同义反义; one_way=上下位; directed=搭配"

if old_dir in content:
    content = content.replace(old_dir, new_dir)
    changes.append("Fix 8 OK: direction枚举注释说明")
else:
    changes.append("Fix 8 FAIL")

# Fix 9: 形态学专家职责补充词素数量说明
old_morph_exp = """| 分析词素体系 | 120+词根（含粘着词根）、80+前后缀及变体归并 |"""
new_morph_exp = """| 分析词素体系 | 200-300词根（含粘着词根）、100+前后缀及变体归并 |"""

if old_morph_exp in content:
    content = content.replace(old_morph_exp, new_morph_exp)
    changes.append("Fix 9 OK: 形态学专家职责词素数量修正")
else:
    changes.append("Fix 9 FAIL")

# Fix 10: 补充FSRS参数初始值说明（在3.6学习证据分类后）
old_fsrs_note = """掌握度冷启动：新用户通过 VKS（Vocabulary Knowledge Scale）五级自评快速定级（1=没见过 → 5=会用），之后由复习数据接管。"""
new_fsrs_note = """掌握度冷启动：新用户通过 VKS（Vocabulary Knowledge Scale）五级自评快速定级（1=没见过 → 5=会用），之后由复习数据接管。

FSRS 参数初始值按学段配置：小学阶段稳定性初始值较低（便于频繁复习），高中阶段可适当提高。FSRS 推荐初始 stability=0.1，fsrs_difficulty=4.0，retrievability 由系统根据首次答题结果自动计算。"""

if old_fsrs_note in content:
    content = content.replace(old_fsrs_note, new_fsrs_note)
    changes.append("Fix 10 OK: FSRS参数初始值说明")
else:
    changes.append("Fix 10 FAIL")

# Fix 11: 3.3.14语言关系维度总览补充说明各维度落点
old_total_note = """每条关系必须记录关系类型、方向（对称/单向/有向）、适用义项、证据来源和说明，不能只保存一个相关单词文本。"""
new_total_note = """每条关系必须记录关系类型、方向（对称/单向/有向）、适用义项、证据来源和说明，不能只保存一个相关单词文本。

**各维度数据库落点说明**：
- **同词根/同词缀** → `morphemes` + `word_morphemes` 表，词素表独立存储
- **同字母组合/同发音模式** → `phonics_patterns` + `word_phonics` 表
- **同义词/反义词/上下位** → `word_relations` 表，`relation_type` 对应，direction 标记方向
- **同搭配** → `word_collocations` 表，coll_type 区分类型
- **同错因** → `word_mistakes` 表
- **同构词法** → `words.word_type` 字段（simple/derived/compound/converted）
- **同词源** → `words.origin_language` 字段
- **同拼写模式** → `word_forms.spelling_rule` 字段"""

if old_total_note in content:
    content = content.replace(old_total_note, new_total_note)
    changes.append("Fix 11 OK: 3.3.14维度落点说明")
else:
    changes.append("Fix 11 FAIL")

with open(r'D:\mywork\techdoc\英语学习软件\中小学英语学习App设计文档.md', 'w', encoding='utf-8') as f:
    f.write(content)

print("=== 修复结果 ===")
for c in changes:
    print(c)
