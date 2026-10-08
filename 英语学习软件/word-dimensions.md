# 英文单词维度定义

> 版本：1.5.0
> 状态：草稿
> 用途：定义英语学习软件中英文单词的数据模型维度
> 对应设计文档：中小学英语学习App设计文档 v1.5

---

## 一、基本属性

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 单词拼写 | `word` | 单词原形，全部小写 | abandon |
| 音标（美） | `phonetic_us` | 美式发音音标 | /əˈbændən/ |
| 音标（英） | `phonetic_uk` | 英式发音音标 | /əˈbændən/ |
| 音频（美） | `audio_us` | 美式发音音频 URL | /audio/us/abandon.mp3 |
| 音频（英） | `audio_uk` | 英式发音音频 URL | /audio/uk/abandon.mp3 |

---

## 二、词性与释义

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 词性 | `pos` | Part of Speech，词性枚举 | noun, verb, adjective, adverb, preposition, conjunction, ... |
| 中文释义 | `meaning_cn` | 中文简明释义（义项级） | 放弃，遗弃；抛弃 |
| 英文释义 | `definition_en` | 英文释义（义项级，可选） | to leave somebody/something behind |
| 释义序号 | `sense_no` | 同一词条下的第几个义项（义项级） | 1, 2, 3 |
| 情感色彩 | `connotation` | 义项的情感倾向（义项级，v1.5新增） | positive / negative / neutral |

> 注：v1.5 新增 `connotation` 字段，记录义项的情感色彩。同一词的不同义项可能情感色彩不同，如 childish（贬义）vs childlike（褒义）。

---

## 三、语言关系维度（v1.5 扩展至 30 维）

### 3.1 形态与构成关系

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 同词根 | `same_root` | 相同词根的词 | act / action / active / actor / actual |
| 同词缀 | `same_suffix` / `same_prefix` | 相同前缀/后缀 | -tion / -ness / un- / re- |
| 同字母组合 | `same_letter_pattern` | 相同字母序列 | ee→/iː/ : see/meet/feet |
| 同构词法 | `word_type` | simple/derived/compound/converted | conversion: record(名/动) |
| 构词变体 | `allomorph_of` | 词素变体归并（morphemes 表） | im-/in-/il-/ir- 归并到 in- |
| 逆构词 | `back_derived` (relation_type) | 逆构词对 | editor→edit；automation→automate |
| 词素分解 | `word_morphemes` (表) | 词素在词中的位置和实际拼写 | act / -tion / -ive |

### 3.2 语音与拼读关系

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 同发音模式 | `homophone` | 同音异形 | there/their/they're · to/too/two |
| 同音素 | `same_phoneme` | 相同音素序列 | bit/beat · ship/sheep |
| 最小对立对 | `minimal_pair` | 仅一个音素不同 | pat/bat/cat |
| 发音相近易混 | `pronunciation_confusable` | 发音相似易混 | piece/peace · weather/whether |

### 3.3 语义关系

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 同义词 | `synonyms` | 意义相近 | big / large / huge / enormous |
| 反义词 | `antonyms` | 意义相反 | happy ↔ sad · increase ↔ decrease |
| 上下位 | `hypernym` (单向) | 下位→上位单向存储 | dog→animal· flower→plant |
| 部分整体 | `meronym` / `holonym` (单向) | 部分↔整体单向存储 | finger↔hand · page↔book |
| 易混词 | `confusables` | 视觉/听觉/意义/L1迁移混淆 | piece/peace · borrow/lend |
| 同错因 | `same_mistake_type` | 相同错误类型 | i/e混淆：recieve/beleive |
| 情感色彩 | `connotation` + `connotation_group` | 褒义/贬义/中性 | skinny(贬)/slim(中)/thin(中) |
| 同情感色彩组 | `connotation_group` (表) | 同一情感色彩的词组 | 褒义组：brilliant/excellent |
| 假朋友 | `false_friend` (relation_type) | 英汉翻译陷阱 | actual≠活跃的；sensible≠敏感的 |
| 形式相似无关 | `pseudo_cognate` (relation_type) | 跨语言形式相似陷阱 | sane≠same；quite≠quiet |
| 转喻关联 | `metonymy` (relation_type) | 以局部指代整体 | The White House→美国政府 |

### 3.4 搭配与使用关系

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 同搭配 | `collocations` | 固定搭配 | heavy rain / take a photo / make progress |
| 同介词搭配 | `prepositional_collocation` | 固定介词搭配（v1.5新增） | depend ON / consist OF / lead TO |
| 同句法结构 | `same_syntax_frame` (表) | 同一句法框架的词（v1.5新增） | believe/think/suggest (V+that-clause) |
| 语域变体 | `regional_variant` (relation_type) | 美英区域用词差异（v1.5新增） | flat/apartment · lift/elevator · rubbish/trash |

### 3.5 语义扩展关系

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 隐喻关联 | `metaphor` (表) | 概念隐喻框架下的词（v1.5新增） | TIME IS MONEY: spend/waste/invest time |
| 多义派生链 | `sense_relations` (表) | 义项间语义延伸路径（v1.5新增） | run: 跑→经营→运转→发烧（辐射型） |

### 3.6 词源与语系关系

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 词源 | `origin_language` | 词源语系 | germanic/latin/french/greek/loanword |
| 词源故事 | `etymology_story` | 词源趣味故事 | 100-200个（高中段优先） |
| 同词源 | `same_origin` | 相同语系的词 | — |

### 3.7 拼写关系

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 同拼写模式 | `spelling_rule` | 相同拼写规律 | 双辅音字母：happen/letter/middle |
| 同错因 | `same_mistake_type` | 相同拼写错误 | i/e混淆、-tion/-sion混淆 |

### 3.8 教学分类维度（非语言关系，查询聚合）

| 维度 | 字段名 | 说明 |
|------|--------|------|
| 同主题语境 | `topic_clusters` (表) | 同一情境高频共现词（v1.5新增） |
| 同难度层级 | `inherent_difficulty` / `cefr_level` | 同一 CEFR/难度的词（查询聚合） |
| 同词频波段 | `frequency_level` | 同一词频波段的词（查询聚合） |
| 同学习先备 | `word_prerequisites` (表) | 相同前置要求的词（v1.5新增） |

---

## 四、短语搭配

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 短语 | `phrases` | 含该词的常见短语（数组） | abandon ship, abandon hope |
| 短语中文 | `phrases_cn` | 短语对应的中文（数组） | 弃船，放弃希望 |
| 介词短语 | `prepositional_verb` | 固定介词搭配（v1.5新增） | depend on, consist of, lead to |
| 词块 | `chunk` | 作为整体习得的多词单位 | a cup of, look after, Thank you |

---

## 五、例句

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 例句英文 | `example_sentence` | 英文原句 | They had to abandon the ship. |
| 例句中文 | `example_translation` | 例句中文翻译 | 他们不得不弃船。 |
| 例句来源 | `example_source` | 例句出处（可选） | TOEFL, GRE, CNN |
| 已知词比例 | `known_word_ratio` | 可理解输入指标（v1.5新增） | ≥0.95（i+1 保证） |

> 注：每个例句独立一条记录，不是单词下的数组。v1.5 新增 `known_word_ratio` 字段，保证例句符合可理解输入原则。

---

## 六、记忆与辅助

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 助记提示 | `mnemonic` | 记忆技巧或联想 | 谐音"额版的"——把东西都版到一边去了 |
| 图片联想 | `image_url` | 联想图片 URL（可选） | /images/mnemonic/abandon.jpg |
| 词源故事 | `etymology_story` | 词源趣味故事 | 100-200个（高中段优先） |

---

## 七、使用频率

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 词频等级 | `frequency_band` | CEFR 或兰斯值区间 | A2, B1, C1 |
| 词频波段 | `frequency_level` | 高/中/低（NGSL/EVP 锚定） | high, medium, low |
| 兰斯值 | `lexile` | 兰斯阅读难度值（可选） | 850L |
| 词频排名 | `frequency_rank` | 在语料库中的排名（可选） | 2500 |

---

## 八、学习记录（用户私有数据）

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 掌握状态 | `mastery_status` | 学习进度状态 | new, learning, reviewing, mastered |
| 技能状态 | `skill_code` | 七大技能分类 | form_recognition / spelling / meaning_recall / ... |
| 首次学习时间 | `first_seen_at` | 首次遇到该词的时间 | 2024-01-01 |
| 下次复习时间 | `due_at` | FSRS 间隔重复下次复习时间 | 2024-01-03 |
| 正确次数 | `correct_count` | 正确回忆次数 | 3 |
| 错误次数 | `wrong_count` | 错误回忆次数 | 1 |
| 记忆稳定性 | `stability` | FSRS 记忆稳定性参数 | 0.1~∞ |
| 记忆难度 | `fsrs_difficulty` | FSRS 难度参数 | 1-10 |
| 可提取性 | `retrievability` | 当前可提取性 | 0-1 |

---

## 九、变体与相关

| 维度 | 字段名 | 说明 | 示例 |
|------|--------|------|------|
| 复数/变形 | `inflections` | 名词复数、动词变形等（可选） | abandons, abandoned, abandoning |
| 拼写变体 | `variant` | 美英/其他拼写差异 | color / colour |
| 相关词 | `related_words` | 词族内的相关词（可选） | abandonment |
| 美英发音差异 | `dialect` (us/uk/other) | 音标和音频的方言差异 | — |

---

## 十、数据模型关系说明

```
Word（单词词条）
  ├── WordSense（每个义项为一个 sense，义项级）
  │     ├── meaning_cn, definition_en, pos, register
  │     ├── connotation（v1.5新增：positive/negative/neutral）
  │     ├── sense_examples[]（已知词比例 ≥0.95）
  │     ├── sense_syntax_frames[]（句法框架）
  │     ├── word_collocations[]（搭配，含介词搭配 v1.5）
  │     ├── word_mistakes[]（错因分析）
  │     ├── word_themes[]（主题挂接）
  │     ├── word_curriculum[]（教材映射）
  │     ├── sense_relations[]（多义派生链 v1.5新增）
  │     └── word_metaphors[]（隐喻关联 v1.5新增）
  ├── Etymology（词源）
  │     ├── origin_language（germanic/latin/french/greek/loanword）
  │     └── etymology_story（词源故事）
  ├── WordMorphemes[]（词素分解，含位置和实际拼写）
  ├── WordForms[]（词形变化）
  ├── WordPronunciations[]（发音，含美英差异）
  ├── PhonicsPatterns[]（拼读规则）
  ├── WordRelations[]（语言关系）
  │     ├── synonym / antonym（对称）
  │     ├── hypernym / meronym / holonym（单向）
  │     ├── confusable（含 l1_transfer 类型）
  │     ├── regional_variant + dialect_pair（美英差异 v1.5新增）
  │     ├── false_friend + l1_pair（假朋友 v1.5新增）
  │     ├── back_derived（逆构词 v1.5新增）
  │     ├── same_syntax（同句法结构 v1.5新增）
  │     ├── metonymy（转喻 v1.5新增）
  │     └── pseudo_cognate（形式相似无关 v1.5新增）
  ├── ConnotationGroups[]（情感色彩组 v1.5新增）
  ├── TopicClusters[]（主题词簇 v1.5新增）
  ├── WordPrerequisites[]（学习先备 v1.5新增）
  └── UserWordProgress[]（用户学习记录，一对多）
```

---

## 十一、维度价值与实现优先级（v1.5）

| 优先级 | 维度 | 教学价值 | 实现成本 | 说明 |
|--------|------|---------|---------|------|
| 高 | 同介词搭配 | 高（中国学生高频错点） | 低 | 搭配表新增 coll_type |
| 高 | 情感色彩 | 高（写作精准用词） | 低 | word_senses 新增字段 |
| 高 | 语域变体 | 高（中国学生弱项） | 低 | word_relations 扩展 |
| 高 | 部分整体关系 | 中高（语义完整性） | 低 | word_relations 扩展 |
| 中 | 同句法结构 | 高（产出性学习） | 中 | 新建 same_syntax_frames 表 |
| 中 | 同主题语境 | 中（情境化学习） | 高 | 新建 topic_clusters 表 |
| 中 | 隐喻关联 | 中高（深层理解） | 高 | 新建 metaphor_frames 表 |
| 中 | 假朋友 | 高（翻译准确性） | 低 | word_relations 扩展 |
| 中 | 多义派生链 | 中（一词多义学习） | 中 | 新建 sense_relations 表 |
| 中 | 转喻关联 | 中（阅读理解） | 低 | word_relations 扩展 |
| 低 | 逆构词 | 中（构词法知识） | 低 | word_relations 扩展 |
| 低 | 形式相似无关 | 中（翻译准确性） | 低 | word_relations 扩展 |
| 低 | 同难度层级 | 中（学习路径） | 低 | 查询聚合已有字段 |
| 低 | 同词频波段 | 中（高频优先） | 低 | 查询聚合已有字段 |
| 低 | 同学习先备 | 中（学习路径） | 中 | 新建 prerequisite_groups 表 |
| 低 | 同情感色彩组 | 中（情感辨析） | 中 | 新建 connotation_groups 表 |

---

## 十二、后续待确认

- [ ] 助记提示由人工维护还是 AI 生成？
- [ ] 例句是否需要支持多层级（初中高），不同难度不同例句？
- [ ] 是否需要支持一词多义的独立学习（每个 sense 单独复习）？
- [ ] 词频数据来源：COCA, BNC, iWeb, 还是自定义？
- [ ] 隐喻框架的数量和覆盖范围？
- [ ] 假朋友关系的数据来源：专家标注还是已有词典资源？
