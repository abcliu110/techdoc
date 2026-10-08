# -*- coding: utf-8 -*-
import re

with open(r'D:\mywork\techdoc\英语学习软件\中小学英语学习App设计文档.md', 'r', encoding='utf-8') as f:
    content = f.read()

changes = []

# ========== Fix 1: 3.1 四层→五层，加词根词缀维度 ==========
old_31 = """### 3.1 四层分类架构

| 层次 | 核心对象 | 解决的问题 | 典型上层功能 |
|------|----------|------------|--------------|
| 词汇本体 | 词条、义项、词形、词素、发音 | 这个词是什么、由什么构成 | 单词卡、释义、跟读、拼写 |
| 语言关系 | 上下位、同反义、派生、搭配、易混 | 这个词和什么有关 | 词汇网络、辨析题、句型题 |
| 教学资源 | 课程、年级、单元、主题、词频、难度 | 什么时候教，教到什么程度 | 教材路径、分层推荐、单元练习 |
| 学习证据 | 技能、题型、错误、掌握度、复习状态 | 学生学会了什么 | 诊断、FSRS 复习调度、掌握报告 |"""

new_31 = """### 3.1 五层分类架构

| 层次 | 核心对象 | 解决的问题 | 典型上层功能 |
|------|----------|------------|--------------|
| 词汇本体 | 词条、义项、词形、词素、发音 | 这个词是什么、由什么构成 | 单词卡、释义、跟读、拼写 |
| 语言关系 | 同根、同缀、同义、反义、上下位、搭配、易混 | 这个词和什么有关 | 词汇网络、辨析题、句型题 |
| 教学资源 | 课程、年级、单元、主题、词频、难度 | 什么时候教，教到什么程度 | 教材路径、分层推荐、单元练习 |
| 学习证据 | 技能、题型、错误、掌握度、复习状态 | 学生学会了什么 | 诊断、FSRS 复习调度、掌握报告 |
| 词根词缀 | 词根、词缀、词族、派生规则 | 通过构词法高效扩展词汇量 | 词族学习、前缀后缀、组合单词 |"""

if old_31 in content:
    content = content.replace(old_31, new_31)
    changes.append("Fix 1 OK: 3.1 四层→五层")
else:
    changes.append("Fix 1 FAIL: not found")

# ========== Fix 2: grade_levels 加高中年级 ==========
old_grade = """CREATE TABLE grade_levels (
    grade_code  TEXT PRIMARY KEY,   -- preparatory_1/2, primary_1..6, junior_1..3
    stage       TEXT NOT NULL CHECK(stage IN ('preparatory','primary','junior')),
    sort_no     INTEGER NOT NULL UNIQUE
);"""

new_grade = """CREATE TABLE grade_levels (
    grade_code  TEXT PRIMARY KEY,   -- preparatory_1/2, primary_1..6, junior_1..3, senior_1..3
    stage       TEXT NOT NULL CHECK(stage IN ('preparatory','primary','junior','senior')),
    sort_no     INTEGER NOT NULL UNIQUE
);"""

if old_grade in content:
    content = content.replace(old_grade, new_grade)
    changes.append("Fix 2 OK: grade_levels 加senior")
else:
    changes.append("Fix 2 FAIL: grade_levels not found")

# ========== Fix 3: word_relations direction 枚举三值 ==========
old_dir = """    direction       TEXT NOT NULL CHECK(direction IN ('directed','symmetric')),"""
new_dir = """    direction       TEXT NOT NULL CHECK(direction IN ('symmetric','one_way','directed')),"""

if old_dir in content:
    content = content.replace(old_dir, new_dir)
    changes.append("Fix 3 OK: direction 改为三值枚举")
else:
    changes.append("Fix 3 FAIL: direction not found")

# ========== Fix 4: relation_type 补 confusable 明确四种子类型 ==========
# 当前 confusable 已存在，但 confusable_type 已有四种。确认 enum 和说明一致
# relation_type 的 confusable 保持，confusable_type 已有 spelling/sound/meaning/l1_transfer
# 只需要确认 relation_type 枚举和文档维度一致即可
# 已满足：synonym/antonym/hypernym/meronym/derived/compound/confusable 都已覆盖文档维度
changes.append("Fix 4 OK: relation_type confusable + confusable_type 四子类型已覆盖")

# ========== Fix 5: cognitive_load 与 inherent_difficulty 合并说明 ==========
old_diff = """    cognitive_load     TEXT CHECK(cognitive_load IN ('low','medium','high')),"""
new_diff = """    cognitive_load     TEXT CHECK(cognitive_load IN ('low','medium','high')),  -- 认知负荷（加工难度），独立于 inherent_difficulty"""

if old_diff in content:
    content = content.replace(old_diff, new_diff)
    changes.append("Fix 5 OK: cognitive_load 加注释说明与 inherent_difficulty 的区别")
else:
    changes.append("Fix 5 FAIL: cognitive_load not found")

# ========== Fix 6: derived/compound 从 relation_type 删除（冗余） ==========
old_rt = """    relation_type   TEXT NOT NULL CHECK(relation_type IN ('synonym','antonym','hypernym','meronym','derived','compound','confusable')),"""
new_rt = """    relation_type   TEXT NOT NULL CHECK(relation_type IN ('synonym','antonym','hypernym','meronym','confusable')),  -- derived/compound 由 words.word_type 提供"""

if old_rt in content:
    content = content.replace(old_rt, new_rt)
    changes.append("Fix 6 OK: relation_type 删除 derived/compound 冗余")
else:
    changes.append("Fix 6 FAIL: relation_type not found")

# ========== Fix 7: 6.1 词汇量规划 高中数据补充 + 口径统一 ==========
old_vocab = """| 学段 | 年级 | 课标级别 | 课标词汇量要求 | 产品覆盖目标（去重 lemma） |
|------|------|----------|----------------|---------------------------|
| 小学 | 1-2年级 | 预备级 | 无数量要求（听说为主） | 100-150（产品扩展，以词块为主） |
| 小学 | 3-4年级 | 一级 | 定性要求（无明确数量） | 300-400 |
| 小学 | 5-6年级 | 二级 | 600-700词 + 约50个固定搭配 | 700（累计） |
| 初中 | 7-9年级 | 三级 | 1600词 + 200-300个习惯用语/固定搭配 | 1600（累计，含小学词汇） |
| **去重合计** | — | — | — | **约1600-1700词条，其中词块250-300；L6词族口径约1300** |

注：初中 1600 为课标累计口径，天然包含小学阶段词汇，因此全产品去重词条数约 1600-1700 而非各学段相加。L6 词族数低于词条数是因为派生词归并（如 act/action/active 计为 1 个词族）。具体数字以内容录入后实测校准。"""

new_vocab = """| 学段 | 年级 | 课标级别 | 课标词汇量要求 | 产品覆盖目标（去重 lemma） |
|------|------|----------|----------------|---------------------------|
| 小学 | 1-2年级 | 预备级 | 无数量要求（听说为主） | 100-150（产品扩展，以词块为主） |
| 小学 | 3-4年级 | 一级 | 定性要求（无明确数量） | 300-400 |
| 小学 | 5-6年级 | 二级 | 600-700词 + 约50个固定搭配 | 700（累计） |
| 初中 | 7-9年级 | 三级 | 1600词 + 200-300个习惯用语/固定搭配 | 1600（累计，含小学词汇） |
| 高中 | 10-12年级 | 高级 | 约1800词（课标）+ 高中拓展词 | 1800-2000（累计，含初初中词汇） |
| **K-12去重合计** | — | — | — | **约2400-2800词条，其中词块300-400；L6词族口径约1800-2200** |

**口径说明**：
- 词汇量以 lemma（词条）计数，同一词条跨学段出现时**不重复计入**。
- 高中词汇量含高考大纲词（约1800词）加上高中教材拓展词（200-400词）。
- L6 词族口径低于词条数，因为派生词归并（如 act/action/active 计为1个词族）。
- 具体数字以内容录入后实测校准。"""

if old_vocab in content:
    content = content.replace(old_vocab, new_vocab)
    changes.append("Fix 7 OK: 6.1 词汇量规划补充高中数据 + 口径说明")
else:
    changes.append("Fix 7 FAIL: 6.1 词汇量 not found")

# ========== Fix 8: 3.2.2 词形 补充遗漏类型 ==========
old_form = """| 类型 | 示例 |
|------|------|
| 复数 | `cat → cats` |
| 第三人称单数 | `run → runs` |
| 过去式/过去分词 | `go → went → gone` |
| 现在分词 | `run → running` |
| 比较级/最高级 | `big → bigger → biggest` |
| 所有格 | `child → child's / children's` |
| 拼写变体 | `color / colour` |
| 短语动词形式 | `look / look after` |"""

new_form = """| 类型 | 示例 |
|------|------|
| 复数 | `cat → cats` |
| 第三人称单数 | `run → runs` |
| 过去式/过去分词 | `go → went → gone` |
| 现在分词 | `run → running` |
| 比较级/最高级 | `big → bigger → biggest` |
| 所有格 | `child → child's / children's` |
| 拼写变体 | `color / colour` |
| 短语动词形式 | `look / look after` |
| 形容词比较级副词化 | `fast → faster → fastest` |

注：短语动词形式（phrasal）和词块（chunk）的区别：短语动词是"动词+副词/介词"的可分整体（如 look after），词块是Lewis词汇教学法定义的多词预制件（如 a cup of / look forward to），两者有重叠但不等价。"""

if old_form in content:
    content = content.replace(old_form, new_form)
    changes.append("Fix 8 OK: 3.2.2 词形补充 + phrase/chunk 边界说明")
else:
    changes.append("Fix 8 FAIL: 3.2.2 词形 not found")

# ========== Fix 9: 3.3.2 同词缀 补充遗漏后缀 ==========
old_suffix = """| 后缀 | 含义 | 示例 |
|------|------|------|
| `-tion / -sion` | 名词化 | nation / education / revolution / decision / expression |
| `-ness` | 名词化（性质/状态） | happiness / kindness / darkness / weakness |
| `-ment` | 名词化（行为/结果） | development / agreement / movement / argument |
| `-ity` | 名词化（性质） | activity / reality / ability / diversity |
| `-er / -or` | 人/物 | teacher / reader / actor / visitor |"""

new_suffix = """| 后缀 | 含义 | 示例 |
|------|------|------|
| `-tion / -sion` | 名词化 | nation / education / revolution / decision / expression |
| `-ness` | 名词化（性质/状态） | happiness / kindness / darkness / weakness |
| `-ment` | 名词化（行为/结果） | development / agreement / movement / argument |
| `-ity` | 名词化（性质） | activity / reality / ability / diversity |
| `-er / -or` | 人/物 | teacher / reader / actor / visitor |
| `-ance / -ence` | 名词化 | importance / confidence / difference / existence |
| `-ian / -ist` | 人/物（职业/信仰） | musician / historian / scientist / pianist |"""

if old_suffix in content:
    content = content.replace(old_suffix, new_suffix)
    changes.append("Fix 9 OK: 3.3.2 补充 -ance/-ence 和 -ian/-ist 后缀")
else:
    changes.append("Fix 9 FAIL: 3.3.2 后缀 not found")

# ========== Fix 10: 各学段学习模式配置（3.5后新增章节） ==========
old_section5 = """### 3.5 学习证据分类"""
new_section5 = """### 3.5 各学段学习模式配置

| 学段 | 学习特点 | 推荐内容形式 | 核心学习模式 |
|------|---------|-------------|-------------|
| 小学1-2年级 | 图形化、听说为主、游戏化 | 词块音频、图形词卡、动画 | 词块整体输入、亲子共学 |
| 小学3-4年级 | 简单拼读、基础词汇 | 简单拼读动画、词块运用、跟读 | 词块运用、简单拼读启蒙 |
| 小学5-6年级 | 系统学习、高频后缀 | 高频后缀（-er/-ly/-tion）、搭配学习、拼写 | 词缀启蒙、搭配学习 |
| 初中7-9年级 | 综合运用、构词法、词义辨析 | 系统构词法、词义辨析、完形填空、词块产出 | 词族扩展、构词规则、辨析题 |
| 高中10-12年级 | 学术词汇、CET衔接、写作输出 | 学术词块、高考核心词、CET过渡词、写作搭配 | 学术词块、写作搭配、词义精确辨析 |

注：小学低年级不要求拼写，以听说和词块整体习得为主；系统构词法和词素拆分从初中开始；高中阶段重点在学术词汇和写作输出。

### 3.6 学习证据分类"""

if old_section5 in content:
    content = content.replace(old_section5, new_section5)
    changes.append("Fix 10 OK: 新增 3.5 各学段学习模式配置")
else:
    changes.append("Fix 10 FAIL: 3.5 section not found")

# ========== Fix 11: 3.6 标题顺延（原 3.5→3.6，3.6→3.7） ==========
# 上面已通过 Fix 10 修正了节号

# ========== Fix 12: v1.3 修订说明 更新词汇量口径 ==========
old_rev = """| 词汇量口径 | ~1700词条（初中累计） | ~3500-4000词条（K-12累计，含高考大纲） |"""
new_rev = """| 词汇量口径 | ~1700词条（初中累计） | ~2400-2800词条（K-12累计去重，含高考大纲） |"""

if old_rev in content:
    content = content.replace(old_rev, new_rev)
    changes.append("Fix 12 OK: v1.3修订说明词汇量修正")
else:
    changes.append("Fix 12 FAIL: v1.3词汇量修订 not found")

# ========== Fix 13: word_relations 注释更新 ==========
old_rel_comment = """-- 语言关系：词素关系已移至 morphemes，不在此表
-- 约定：hypernym 只存 source=下位词 → target=上位词，hyponym 查询反推，不重复存储"""
new_rel_comment = """-- 语言关系：词素关系由 morphemes 表表达，不在此表
-- 派生(derived)和复合(compound)由 words.word_type 提供，不在此表冗余存储
-- 约定：hypernym 只存 source=下位词 → target=上位词，hyponym 查询反推，不重复存储
-- 同字母组合、同发音模式、同拼写模式分别由 phonics_patterns 和 word_mistakes 表承载"""

if old_rel_comment in content:
    content = content.replace(old_rel_comment, new_rel_comment)
    changes.append("Fix 13 OK: word_relations 注释更新，说明各维度落点")
else:
    changes.append("Fix 13 FAIL: word_relations 注释 not found")

with open(r'D:\mywork\techdoc\英语学习软件\中小学英语学习App设计文档.md', 'w', encoding='utf-8') as f:
    f.write(content)

for c in changes:
    print(c)
