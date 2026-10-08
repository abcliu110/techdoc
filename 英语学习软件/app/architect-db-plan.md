# 英语学习软件 数据库维度扩展方案

> 版本：v1.0
> 日期：2026-10-07
> 目标：为新增 10 个语言关系维度扩展数据库表结构

---

## 一、现有表结构适配分析

### 1.1 现有表与维度的对应关系

| 维度 | 现有表 | 现有字段 | 扩展方式 |
|------|--------|----------|----------|
| 同义词 / 反义词 | word_relations | relation_type='synonym'/'antonym' | 已有，无需变更 |
| 上下位 / 部分整体 | word_relations | relation_type='hypernym'/'meronym' | relation_type 枚举扩展 |
| 易混词 | word_relations | relation_type='confusable' | 已有，无需变更 |
| 同词根 / 同词缀 | word_relations | relation_type='same_root'/'same_suffix' | 已有，无需变更 |
| 同发音模式 | word_relations | relation_type='homophone' | 已有，无需变更 |
| 同搭配 | word_collocations | coll_type 枚举 | coll_type 枚举扩展 |
| 同错因 | word_mistakes | mistake_type | 已有，无需变更 |
| 同构词法 | words | word_type | 已有，无需变更 |
| 同词源 | words | origin_language | 已有，无需变更 |
| 同字母组合 / 同发音模式 | phonics_patterns + word_phonics | — | 已有，无需变更 |

### 1.2 新增维度的存储策略

| 维度 | 存储策略 | 理由 |
|------|----------|------|
| 1. regional_variant | 扩展 word_relations | 同为词对关系，relation_type='regional_variant'，新增 dialect_pair 字段 |
| 2. meronym/holonym | 扩展 word_relations | 同为语义层级关系，relation_type='meronym'/'holonym'，direction='one_way' |
| 3. connotation | 扩展 word_senses | 情感色彩是义项级属性，添加 connotation 字段 |
| 4. same_preposition_collocation | 扩展 word_collocations | coll_type 新增 'prepositional_verb' |
| 5. false_friend | 扩展 word_relations | 同为词对关系，relation_type='false_friend'，新增 l1_pair 字段 |
| 6. same_syntax_frame | 新建 same_syntax_frames | 同 frame_code 的词对需要显式存储，新增表 |
| 7. metaphor | 新建 metaphor_frames + word_metaphors | 隐喻框架是独立概念实体，不是简单的词对 |
| 8. polysemy_chain | 新建 sense_relations | 义项间语义派生链，需要 source_sense_id/target_sense_id |
| 9. connotation_group | 新建 connotation_groups + word_connotation_group | 同情感色彩词组，组是独立实体 |
| 10. back_formation | 扩展 word_relations | 同为词对关系，relation_type='back_derived' |

---

## 二、完整 DDL 变更方案

### 2.1 扩展现有表

#### ALTER 1：word_relations — 新增 relation_type 值、新增字段

```sql
-- 扩展 relation_type CHECK 约束（从 5 种扩展到 12 种）
-- SQLite 不支持 DROP CONSTRAINT，需重建表（数据迁移方案见后）

CREATE TABLE word_relations_new (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    source_word_id  INTEGER NOT NULL REFERENCES words(id),
    target_word_id  INTEGER NOT NULL REFERENCES words(id),
    relation_type   TEXT NOT NULL CHECK(relation_type IN (
        'synonym','antonym','hypernym','meronym','holonym',
        'confusable','regional_variant','false_friend',
        'same_syntax','back_derived',
        'same_root','same_suffix','homophone'
    )),
    direction       TEXT NOT NULL CHECK(direction IN ('symmetric','one_way','directed')),
    confusable_type TEXT CHECK(confusable_type IN ('spelling','sound','meaning','l1_transfer')),
    dialect_pair    TEXT CHECK(dialect_pair IN ('us_uk','us_au','uk_au','other')),
    l1_pair         TEXT CHECK(l1_pair IN ('zh_en','ja_en','fr_en','de_en','other')),
    frame_code      TEXT REFERENCES syntax_frames(frame_code),
    explanation     TEXT,
    UNIQUE(source_word_id, target_word_id, relation_type)
);

-- 迁移数据
INSERT INTO word_relations_new
    (id, source_word_id, target_word_id, relation_type, direction, confusable_type, explanation)
SELECT id, source_word_id, target_word_id, relation_type, direction, confusable_type, explanation
FROM word_relations;

-- 替换旧表
DROP TABLE word_relations;
ALTER TABLE word_relations_new RENAME TO word_relations;

-- 重建索引
CREATE INDEX idx_relations_source ON word_relations(source_word_id, relation_type);
CREATE INDEX idx_relations_target ON word_relations(target_word_id, relation_type);
```

#### ALTER 2：word_senses — 新增 connotation 字段

```sql
ALTER TABLE word_senses
ADD COLUMN connotation TEXT CHECK(connotation IN ('positive','negative','neutral'));
```

#### ALTER 3：word_collocations — 扩展 coll_type 枚举、新增字段

```sql
-- 扩展 coll_type CHECK 约束（从 7 种扩展到 9 种）
-- 同样需要重建表迁移

CREATE TABLE word_collocations_new (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    sense_id            INTEGER NOT NULL REFERENCES word_senses(id),
    collocation         TEXT NOT NULL,
    coll_type           TEXT NOT NULL CHECK(coll_type IN (
        'verb_object','adjective_noun','noun_noun','preposition',
        'phrasal_verb','sentence_frame','prepositional_verb',
        'adverb_verb','other'
    )),
    complement_pattern  TEXT,
    example             TEXT NOT NULL,
    example_cn          TEXT,
    source_version      TEXT DEFAULT 'v1.0',
    UNIQUE(sense_id, collocation)
);

INSERT INTO word_collocations_new
    (id, sense_id, collocation, coll_type, example, example_cn, coll_pattern)
SELECT id, sense_id, collocation, coll_type, example, example_cn, coll_pattern
FROM word_collocations;

DROP TABLE word_collocations;
ALTER TABLE word_collocations_new RENAME TO word_collocations;

CREATE INDEX idx_collocations_sense ON word_collocations(sense_id);
```

### 2.2 新建表

#### CREATE 1：syntax_frames — 句法框架字典（前置依赖表）

```sql
CREATE TABLE syntax_frames (
    frame_code  TEXT PRIMARY KEY,
    pattern     TEXT NOT NULL,
    description TEXT,
    examples    TEXT,
    UNIQUE(pattern)
);
```

#### CREATE 2：same_syntax_frames — 同句法结构词对

```sql
CREATE TABLE same_syntax_frames (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    frame_code      TEXT NOT NULL REFERENCES syntax_frames(frame_code),
    source_word_id  INTEGER NOT NULL REFERENCES words(id),
    target_word_id  INTEGER NOT NULL REFERENCES words(id),
    source_sense_id INTEGER REFERENCES word_senses(id),
    target_sense_id INTEGER REFERENCES word_senses(id),
    explanation     TEXT,
    UNIQUE(source_word_id, target_word_id, frame_code)
);

CREATE INDEX idx_ssf_frame ON same_syntax_frames(frame_code);
CREATE INDEX idx_ssf_source ON same_syntax_frames(source_word_id);
CREATE INDEX idx_ssf_target ON same_syntax_frames(target_word_id);
```

#### CREATE 3：metaphor_frames — 隐喻框架

```sql
CREATE TABLE metaphor_frames (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    frame_code  TEXT NOT NULL UNIQUE,
    frame_name  TEXT NOT NULL,
    source_domain TEXT NOT NULL,
    target_domain TEXT NOT NULL,
    explanation TEXT NOT NULL,
    example     TEXT,
    UNIQUE(source_domain, target_domain)
);
```

#### CREATE 4：word_metaphors — 词-隐喻框架关联

```sql
CREATE TABLE word_metaphors (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    word_id     INTEGER NOT NULL REFERENCES words(id),
    sense_id    INTEGER NOT NULL REFERENCES word_senses(id),
    frame_id    INTEGER NOT NULL REFERENCES metaphor_frames(id),
    role_in_frame TEXT NOT NULL CHECK(role_in_frame IN ('source','target','modifier')),
    example     TEXT,
    UNIQUE(word_id, sense_id, frame_id, role_in_frame)
);

CREATE INDEX idx_wm_word ON word_metaphors(word_id);
CREATE INDEX idx_wm_frame ON word_metaphors(frame_id);
CREATE INDEX idx_wm_sense ON word_metaphors(sense_id);
```

#### CREATE 5：sense_relations — 义项间语义关系（多义派生链）

```sql
CREATE TABLE sense_relations (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    source_sense_id INTEGER NOT NULL REFERENCES word_senses(id),
    target_sense_id INTEGER NOT NULL REFERENCES word_senses(id),
    relation_type   TEXT NOT NULL CHECK(relation_type IN ('polysemy_chain','metaphorical_ext','specialization','generalization')),
    polysemy_type   TEXT CHECK(polysemy_type IN ('radiation','chaining','both')),
    explanation     TEXT,
    UNIQUE(source_sense_id, target_sense_id, relation_type)
);

CREATE INDEX idx_sr_source ON sense_relations(source_sense_id, relation_type);
CREATE INDEX idx_sr_target ON sense_relations(target_sense_id);
```

#### CREATE 6：connotation_groups — 情感色彩组

```sql
CREATE TABLE connotation_groups (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    connotation TEXT NOT NULL CHECK(connotation IN ('positive','negative','neutral')),
    group_label TEXT NOT NULL,
    description TEXT,
    source_version TEXT DEFAULT 'v1.0',
    UNIQUE(connotation, group_label)
);
```

#### CREATE 7：word_connotation_group — 词-情感色彩组关联

```sql
CREATE TABLE word_connotation_group (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    word_id         INTEGER NOT NULL REFERENCES words(id),
    sense_id        INTEGER NOT NULL REFERENCES word_senses(id),
    group_id        INTEGER NOT NULL REFERENCES connotation_groups(id),
    nuance_note     TEXT,
    UNIQUE(word_id, sense_id, group_id)
);

CREATE INDEX idx_wcg_word ON word_connotation_group(word_id);
CREATE INDEX idx_wcg_group ON word_connotation_group(group_id);
CREATE INDEX idx_wcg_sense ON word_connotation_group(sense_id);
```

---

## 三、维度总览表（更新版 3.3.14）

### 3.3.14 语言关系维度总览（含新增维度）

| 维度 | 分类标准 | 存储约定 | 核心价值 | 数据库落点 |
|------|---------|---------|---------|-----------|
| 同词根 | 相同词根 | 词素分解表独立存储，关系表关联 | 词族扩展，构词法学习 | morphemes + word_morphemes |
| 同词缀 | 相同前缀/后缀 | 前缀/后缀词素表 | 派生规则批量掌握 | morphemes + word_morphemes |
| 同字母组合 | 相同字母序列 | 拼读规则表 | 拼读联动拼写 | phonics_patterns + word_phonics |
| 同发音模式 | 相同音素 | 发音表关联；同音异形独立 relation_type | 听力辨析题 | word_pronunciations + word_relations(homophone) |
| 同词源 | 相同语系 | 词源字段 | 文化背景/词汇规律 | words.origin_language |
| 同拼写模式 | 相同拼写规律 | 拼写规则表 | 避免拼写错误 | word_forms.spelling_rule |
| 同义词 | 意义相近 | 对称关系存储 | 写作替换/辨析题 | word_relations('synonym') |
| 反义词 | 意义相反 | 对称关系存储 | 对比记忆/完形填空 | word_relations('antonym') |
| 易混词 | 视觉/听觉/意义/L1迁移 | 无向，标注类型 | 高价值辨析题素材 | word_relations('confusable') |
| 同错因 | 相同错误类型 | 错误类型字段 | 错误诊断和纠正 | word_mistakes |
| 同构词法 | 转化/派生/复合 | 词条类型字段 | 构词规则学习 | words.word_type |
| 同搭配 | 固定搭配 | 搭配表，类型细分 | 地道表达/写作 | word_collocations |
| 上下位 | 下位→上位单向 | 单向存储，查询反推 | 语义聚合/归类题 | word_relations('hypernym') |
| **区域变体** | 美式/英式用词差异 | 无向，标注 dialect_pair | 区域表达辨析 | **word_relations('regional_variant') + dialect_pair** |
| **部分整体** | 部分/整体关系 | 单向存储 | 语义聚合深化 | **word_relations('meronym'/'holonym')** |
| **情感色彩** | 褒义/贬义/中性 | 义项级字段+词组表 | 词汇使用语体辨析 | **word_senses.connotation + connotation_groups** |
| **同介词搭配** | 固定介词搭配 | 搭配类型扩展 | 动词介词搭配精准掌握 | **word_collocations('prepositional_verb')** |
| **假朋友** | 英汉翻译陷阱 | 无向，标注 l1_pair | 高价值翻译辨析题 | **word_relations('false_friend') + l1_pair** |
| **同句法结构** | 相同句法框架 | 独立表关联 frame_code | 句型生成/语法辨析 | **same_syntax_frames + syntax_frames** |
| **隐喻关联** | 概念隐喻框架下的词 | 隐喻框架表+关联表 | 深层语义理解/文化背景 | **metaphor_frames + word_metaphors** |
| **多义派生链** | 义项间语义延伸路径 | 义项关系表，标注辐射/链式 | 一词多义学习路径 | **sense_relations('polysemy_chain')** |
| **同情感色彩组** | 同一情感色彩的词组 | 情感组表+关联表 | 褒贬义词批量学习 | **connotation_groups + word_connotation_group** |
| **逆构词** | 逆构词对 | source=逆构词，target=原词 | 构词法深度学习 | **word_relations('back_derived')** |

---

## 四、字段含义说明

### word_relations 新增字段

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| dialect_pair | TEXT | 区域变体对 | 'us_uk' / 'us_au' / 'uk_au' |
| l1_pair | TEXT | 假朋友的语言对 | 'zh_en'（汉英） |
| frame_code | TEXT | 同句法结构框架码 | 'V+that-clause' |

### word_senses 新增字段

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| connotation | TEXT | 情感色彩 | 'positive' / 'negative' / 'neutral' |

### word_collocations 新增类型

| coll_type | 说明 | 示例 |
|-----------|------|------|
| prepositional_verb | 介词动词固定搭配 | depend ON / consist OF / believe IN |

---

## 五、实施顺序

1. **Phase 1（基础依赖）**：创建 syntax_frames（前置依赖）
2. **Phase 2（现有表扩展）**：重建 word_relations（relation_type 扩展+新字段）；ALTER word_senses；重建 word_collocations
3. **Phase 3（独立语义表）**：创建 metaphor_frames、sense_relations、connotation_groups
4. **Phase 4（关联表）**：创建 word_metaphors、word_connotation_group、same_syntax_frames

---

## 六、兼容性说明

- 现有 word_relations 数据中 relation_type 属于原 7 种范围，不受影响
- 新增字段（dialect_pair、l1_pair、frame_code）默认为 NULL，向后兼容
- 现有 word_collocations 的 coll_type 属于原 5 种范围，不受影响
- 新增 coll_type ('prepositional_verb'、'adverb_verb') 不会破坏现有数据
