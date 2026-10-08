# 中小学英语学习App设计文档

> 版本：v1.5
> 日期：2026-10-08
> 目标用户：小学1年级至高中3年级学生（K-12全覆盖）

## v1.5 修订说明

| 修订点 | v1.4 | v1.5 |
|--------|------|------|
| 语言关系维度 | 13维 | 扩展为30维，新增17个维度 |
| 介词专题 | — | 新增 3.3.16 节介词六维深度模型（语义/搭配/语法/隐喻/英汉对比/短语动词） |
| 理解深度模型 | — | 新增 3.3.17 节四阶段理解模型（L1-L5加工深度/四象限/三维整合） |
| 场景语义学 | — | 新增 3.3.18 节词义理解核心：每个词描述一个场景，场景要素替换驱动词义延伸 |
| 词源学 | — | 新增 3.3.19 节词源学：词的身世与多义统一、词根词缀系统性 |
| 框架语义学 | — | 新增 3.3.20 节框架语义学：词激活知识框架，buy/give/break 框架详解 |
| 韵律音义 | — | 新增 3.3.21 节音义学：sl-/gr-/fl- 等音义组合与拟声词 |
| 数据库 | — | 新增 4.3.7 节新表结构 |
| v1.4修订点 | — | 全部继承 |

## v1.4 修订说明

| 修订点 | v1.3 | v1.4 |
|--------|------|------|
| 朗读技术 | — | 新增 5.3 节 TTS 技术选型参考（Edge TTS / gTTS / pyttsx3 / 云 TTS 对比） |
| 发音评测 | — | 新增 5.3.3 节 GOP 分数 / ASR 对比 / 云服务 API 参考 |
| 参考来源 | — | 引用 GitHub 开源项目调研结果 |

## v1.3 修订说明

| 修订点 | v1.2 | v1.3 |
|--------|------|------|
| 目标学段 | 小学预备级～初中三年级 | 扩展为 K-12 小学～高中（含高中学段） |
| 词汇量口径 | ~1700词条（初中累计） | ~2400-2800词条（K-12累计去重，含高考大纲） |
| 用户分层 | 4个学段（小学1-2/3-4/5-6/初中） | 5个学段，新增高一～高三（高级） |
| CEFR目标 | A1-B1 | A1-B2（高中毕业≈B1-B2，高考≈B1-B2） |
| 高中新增内容 | — | 高中教材单元、CET-4/6过渡词表、学术词块、话题词汇深化 |
| 词族统计 | 初中达L5 | 高中完整L6，学术词族延伸 |
| 词块范围 | 小学词块为主 | 扩展学术词块（高中段）：take into consideration / in terms of 等 |
| 复习算法 | FSRS | 保持不变，参数针对高中学业压力优化 |
| v1.2修订点 | 全部继承 | 全部继承 |

---

## 一、产品定位

### 1.1 核心目标

帮助中小学学生高效记忆和掌握英语单词，解决"记不住、用不来、忘得快"三大问题。

### 1.2 学习闭环

```
┌─────────────────────────────────────────────────────────────┐
│                      学习闭环                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   测评 → 学习 → 练习 → 复习 → 测评                       │
│     ↑                                      │                │
│     └──────────────────────────────────────┘                │
│                                                             │
│   测评：VKS 自评冷启动 + 词汇量水平测试                   │
│   学习：建立词条、义项、词形与使用的连接                 │
│   练习：多题型巩固（听说读写）                          │
│   复习：FSRS 间隔调度 + 主动回忆                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 用户分层

| 年级 | 年龄 | 核心需求 | 学习特点 |
|------|------|----------|----------|
| 小学1-2年级（预备级） | 6-7岁 | 兴趣培养 | 游戏化、图形化、听说为主、词块输入 |
| 小学3-4年级（一级） | 8-9岁 | 基础积累 | 简单拼读、基础词汇、词块运用 |
| 小学5-6年级（二级） | 10-12岁 | 系统学习 | 高频透明后缀（-er/-ly/-tion）、语法搭配 |
| 初中1-3年级（三级） | 12-15岁 | 综合运用与学业质量 | 高频词、词义辨析、系统构词法、词块产出 |
| 高中1-3年级（高级） | 15-18岁 | 学术词汇与应试能力 | 学术词块、高考核心词、CET衔接、写作搭配 |

注：预备级课标无词汇量要求（以听说为主），本产品该学段内容为产品扩展词，录入时 `source_type='product_extension'`。词根词缀在小学高年级只教高频透明后缀，系统构词法放初中。

---

## 二、专家团队体系

### 2.1 团队架构

```
┌─────────────────────────────────────────────────────────────┐
│                      核心团队                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  语言学团队 ────────────────────────────────────────────      │
│  ├── 词汇学专家（词频、搭配、CEFR分级）                │
│  ├── 形态学专家（词素体系、构词法）                    │
│  ├── 语义学专家（词义关系、语义网络）                   │
│  ├── 语音学专家（发音规则、自然拼读）                   │
│  └── 词源学专家（词源故事、文化背景）                   │
│                                                             │
│  教育学团队 ────────────────────────────────────────────      │
│  ├── 二语习得专家（学习路径、i+1理论）                  │
│  ├── 词汇习得专家（词汇知识与使用证据模型）              │
│  ├── 教育心理学家（记忆与间隔复习）                       │
│  └── 语言测试专家（CEFR评估、水平测试）                  │
│                                                             │
│  技术团队 ────────────────────────────────────────────      │
│  ├── 产品经理                                            │
│  ├── UX设计师                                            │
│  ├── 开发工程师                                          │
│  └── 数据科学家                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 各专家职责与交付物

#### 词汇学专家

| 职责 | 交付物 |
|------|--------|
| 设计词频分级体系 | 基于 NGSL/EVP 的词频波段映射表（记录来源） |
| 确定CEFR对应关系 | A1-B1词汇对照表（覆盖目标学段） |
| 整理词语搭配 | 动宾搭配表、形容词搭配表、词块表 |
| 审核词义准确性 | 词汇释义标准 |

#### 形态学专家

| 职责 | 交付物 |
|------|--------|
| 分析词素体系 | 200-300词根（含粘着词根）、100+前后缀及变体归并 |
| 设计词族体系 | 按 Bauer & Nation Level 1-6 分层的词族表 |
| 制定构词规则 | 派生规则表、复合词规则表 |

#### 语义学专家

| 职责 | 交付物 |
|------|--------|
| 建立上下位网络 | 聚合概念层级树（替代扁平语义场） |
| 建立词义关系 | 同义词表、反义词表、部分整体词表 |
| 整理易混词 | 拼写/发音/意义/母语迁移四类易混词对 |

#### 语音学专家

| 职责 | 交付物 |
|------|--------|
| 标注音标 | 美式/英式双版本音标 |
| 制定发音规则 | 字母组合发音规则表 |
| 设计重音规则 | 重音模式分类表 |

#### 词源学专家

| 职责 | 交付物 |
|------|--------|
| 整理词源故事 | 100+词源故事 |
| 分析文化背景 | 词汇文化注释 |

#### 教育心理学家

| 职责 | 交付物 |
|------|--------|
| 设计复习算法 | FSRS 参数配置与调度规则 |
| 确定认知负荷 | 各年级认知负荷标准 |
| 设计激励机制 | 游戏化激励方案 |

---

## 三、单词分类体系

分类不是标签清单，而是驱动题型、内容检索、学习路径和复习算法的领域模型。所有分类必须归属于一个明确层次，并能映射到数据库实体。

### 3.1 五层分类架构

| 层次 | 核心对象 | 解决的问题 | 典型上层功能 |
|------|----------|------------|--------------|
| 词汇本体 | 词条、义项、词形、词素、发音 | 这个词是什么、由什么构成 | 单词卡、释义、跟读、拼写 |
| 语言关系 | 同根、同缀、同义，反义、上下位、搭配、易混 | 这个词和什么有关 | 词汇网络、辨析题、句型题 |
| 词根词缀 | 词根、词缀、词族、派生规则 | 通过构词法高效扩展词汇量 | 词族学习，前缀后缀、组合单词 |
| 教学资源 | 课程、年级、单元、主题、词频、难度 | 什么时候教、教到什么程度 | 教材路径、分层推荐、单元练习 |
| 学习证据 | 技能、题型、错误、掌握度、复习状态 | 学生学会了什么 | 诊断、FSRS 复习调度、掌握报告 |

### 3.2 词汇本体分类

#### 3.2.1 词条与义项

| 分类 | 说明 | 示例 |
|------|------|------|
| 词条（lemma） | 词典中的基本入口 | `run` |
| 义项（sense） | 一个具体的词义和用法 | `run`=跑；经营；运行 |
| 词块（chunk） | 作为整体习得的多词单位，一等词条类型 | `a cup of`、`look after`、`Thank you` |
| 词性 | 义项级属性，不放在词条级 | `record` 名词/动词 |
| 语域 | 义项的使用风格 | 正式、中性、口语、俚语 |
| 可数性 | 名词义项级属性 | `chicken` 可数/不可数 |
| 动词句型 | 义项的支配结构 | `give + 人 + 物` |

词条、义项和词形必须分开。一个词条可以有多个义项，一个义项可以有多个词形和多个搭配。

词块（Lewis 1993 词汇教学法）是儿童语言习得的基本单位，小学1-4年级词块占比应显著高于单词；词块作为独立词条进入学习流，不只作为义项的附属搭配。

#### 3.2.2 词形分类

| 类型 | 示例 |
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

注：短语动词形式（phrasal）和词块（chunk）的区别：短语动词是"动词+副词/介词"的可分整体（如 look after），词块是Lewis词汇教学法定义的多词预制件（如 a cup of / look forward to），两者有重叠但不等价。

#### 3.2.3 词素分类（新增）

词素是最小的音义结合单位，**独立于词条**建模，不进入词表：

| 词素类型 | 说明 | 示例 |
|----------|------|------|
| 自由词根 | 可独立成词 | `act`、`happy` |
| 粘着词根 | 不可独立成词 | `-ject-`（reject/inject）、`-port-` |
| 前缀 | 改变词义 | `un-`、`re-`、`dis-` |
| 后缀 | 常改变词性 | `-ness`、`-tion`、`-er` |
| 变体（allomorph） | 同词素的拼写变体，归并到主词素 | `im-/in-/il-/ir-` |

每个词记录词素分解序列（位置序），支撑"组合单词""拆分单词"题型和词族统计。

#### 3.2.4 语音与拼读分类

| 分类 | 必备数据 | 支撑功能 |
|------|----------|----------|
| 音标 | 英式/美式音标 | 发音展示 |
| 音素 | 音素序列、音素边界 | 听辨、发音分析 |
| 音节 | 音节拆分、音节数 | 分音节拼读 |
| 重音 | 重音位置和等级 | 重音练习 |
| 字母-音素对应 | 字母组合、对应音素、规则例外 | 自然拼读、听音拼写 |
| 发音变体 | 口音、语速、音频版本 | 多版本听辨 |

扩展：小学阶段可引入首音-韵脚（onset-rime）和六大音节类型作为拼读进阶维度。

### 3.3 语言关系分类

语言关系是单词与单词之间所有"相同"维度的集合。每个维度都是一个分类视角，可以把单词按某种相同特征归组，便于批量学习、对比辨析和题型设计。

#### 3.3.1 同词根（相同词根）

相同词根的词形成一个**词族（word family）**，是 Bauer & Nation L3-L6 的基础。以词根为中心展开，可以一次性学会一串派生词：

| 词根 | 词族示例 | 说明 |
|------|---------|------|
| `-act-` | act / action / active / activity / actor / actual / interact / react | "做、行动" |
| `-serv-` | serve / service / servant / preserve / observe / reserve | "服务、保持" |
| `-form-` | form / formal / formation / transform / reform / inform / perform | "形状、形式" |
| `-struct-` | construct / destruction / structure / instruct / obstruct | "建造" |
| `-pend-` | depend / suspend / expense / spend / appendix / compensate | "悬挂，花费" |
| `-ject-` | project / inject / reject / object / subject / eject / commit | "投掷" |
| `-duct-` | conduct / introduce / produce / reduce / deduce / induce / seduce | "引导" |
| `-vert-` | convert / advertise / divert / reverse / diverse / conversation | "转向" |
| `-scrib-` | describe / prescribe / subscribe / manuscript / script | "写" |
| `-spect-` | inspect / respect / spectator / expect / aspect / prospect | "看" |
| `-port-` | import / export / portable / transport / support / airport / passport | "携带、港口" |
| `-ced-/-cess-` | proceed / success / exceed / access / process / predecessor | "走" |
| `-sist-` | exist / resist / assist / consist / persist / insist | "站立" |
| `-plic-` | apply / supply / complicate / explicit / employ / duplicate | "折叠，用" |

#### 3.3.2 同词缀（相同前缀/后缀）

相同词缀的词通过派生规则关联，适合批量学习构词规律：

**名词后缀组：**

| 后缀 | 含义 | 示例 |
|------|------|------|
| `-tion / -sion` | 名词化 | nation / education / revolution / decision / expression |
| `-ness` | 名词化（性质/状态） | happiness / kindness / darkness / weakness |
| `-ment` | 名词化（行为/结果） | development / agreement / movement / argument |
| `-ity` | 名词化（性质） | activity / reality / ability / diversity |
| `-er / -or` | 人/物 | teacher / reader / actor / visitor |
| `-ance / -ence` | 名词化 | importance / confidence / difference / existence |
| `-ian / -ist` | 人/物（职业/信仰） | musician / historian / scientist / pianist |

**形容词后缀组：**

| 后缀 | 含义 | 示例 |
|------|------|------|
| `-ful` | 有…的 | beautiful / careful / helpful / successful |
| `-less` | 无…的 | careless / helpless / useless / endless |
| `-ous` | …的 | dangerous / famous / generous / various |
| `-ive` | …性的 | active / creative / positive / effective |
| `-able / -ible` | 可…的 | comfortable / possible / available / visible |

**动词后缀组：**

| 后缀 | 含义 | 示例 |
|------|------|------|
| `-ize / -ify` | 使…化 | modernize / simplify / organize / classify |
| `-en` | 使… | shorten / widen / deepen / strengthen |

**否定前缀组：**

| 前缀 | 含义 | 示例 |
|------|------|------|
| `un-` | 否定（本土词） | unhappy / unusual / undo / unfold |
| `in- / im- / il- / ir-` | 否定（拉丁词源） | invisible / impossible / illegal / irregular |
| `dis-` | 否定 | disagree / disappear / dishonest |
| `non-` | 非 | nonsense / nonstop / non-violent |

#### 3.3.3 同字母组合（相同字母序列）

相同字母组合的词通常有相同的发音规律，可以**拼读+拼写**联动学习：

| 字母组合 | 发音规律 | 示例 |
|----------|---------|------|
| `ee` | 几乎恒定 /iː/ | see / meet / feet / sleep / green / speech |
| `ea` | /iː/ 或 /e/ | read/heat/meat (iː) · bread/head (e) |
| `oo` | /uː/ 或 /ʊ/ | moon/food/cool (uː) · book/look/good (ʊ) |
| `-tion` | /ʃən/ | education / situation / revolution / information |
| `-sion` | /ʒən/ | decision / discussion / expression / permission |
| `-ful` | /fəl/ | beautiful / careful / helpful / wonderful |
| `-ness` | /nəs/ | happiness / kindness / darkness / illness |
| `ough` | 最多变 | rough(ʌf) / though(əʊ) / thought(ɔː) / through(aʊ) |

#### 3.3.4 同发音模式（相同音素）

发音相同但拼写不同的词（homophones）和最小对立对，是听力和辨析题的高价值素材：

| 类型 | 说明 | 示例 |
|------|------|------|
| 同音异形（homophones） | 发音相同，拼写不同 | there/their/they're · to/too/two · write/right/rite |
| 最小对立对（minimal pairs） | 仅一个音素不同 | bit/beat · ship/sheep · pat/bat/cat |
| 发音相近易混 | 发音相似容易混淆 | piece/peace · weather/whether · bare/bear |

#### 3.3.5 同词源（相同词源语系）

相同词源的词有相似的拼写和语义规律：

| 词源 | 特征 | 示例 |
|------|------|------|
| 日耳曼语（Germanic） | 英语固有核心词，短小朴素 | the / and / of / run / eat / water / hand / fire |
| 拉丁语（Latin） | 古罗马官方语言，约占50%词汇 | nation / form / act / serve / legal / quantum |
| 法语（French） | 诺曼征服后大量借入，宫廷/艺术词汇 | government / beautiful / cuisine / fashion |
| 希腊语（Greek） | 科技/学术/哲学词汇主要来源 | biology / philosophy / telegraph / telephone |
| 借词（Loanwords） | 从各语言借入 | tycoon/sushi（日）· tofu/kung fu（中）· algebra（阿拉伯） |

#### 3.3.6 同拼写模式（相同拼写规律）

相同拼写规律的词，可以总结规则批量避免拼写错误：

| 拼写规则 | 说明 | 示例 |
|----------|------|------|
| 双辅音字母 | 单辅音+元音+相同辅音+元音结构 | happen / letter / middle / summer / button |
| i before e | 规则：believe / thief / achieve；例外：weird / height / eight |
| 去e加后缀 | 辅e结尾+元音后缀去e | hope→hopeful / make→making · notice→noticeable（辅e保留） |
| y变i加后缀 | 辅音+y结尾，变y为i再加后缀 | happy→happiness / heavy→heavily（加-ing不变） |

#### 3.3.7 同义词（synonym）

意义相近的词，但用法和语体有细微差别，分组学习便于辨析：

| 同义组 | 细微差别说明 |
|--------|-------------|
| big / large / great / huge / enormous | big口语化；large正式；great带情感色彩；huge口语化程度高；enormous正式且程度极高 |
| small / little / tiny / slight | small客观描述；little带感情色彩；tiny极小；slight轻微/细小 |
| happy / joyful / cheerful / delighted | happy最通用；joyful充满喜悦；cheerful愉快开朗；delighted被某事感动 |

#### 3.3.8 反义词（antonym）

意义相反的词，对称关系存储：

| 反义组 | 示例 |
|--------|------|
| 温度 | hot ↔ cold · warm ↔ cool |
| 大小 | big ↔ small · large ↔ tiny · huge ↔ minute |
| 情感 | happy ↔ sad · joyful ↔ miserable · pleased ↔ displeased |
| 增减 | increase ↔ decrease · rise ↔ fall · grow ↔ shrink |

#### 3.3.9 易混词（confusable）

容易互相混淆的词对，按混淆原因分组：

| 混淆类型 | 原因 | 示例 |
|----------|------|------|
| 拼写相似 | 视觉上接近 | quiet / quite · accept / except · affect / effect · principal / principle |
| 发音相似 | 听觉上接近 | piece / peace · weather / whether · bare / bear |
| 意义相近但用法不同 | 意义接近但搭配不同 | weather / climate · journey / trip · method / way / approach |
| **L1迁移**（汉语负迁移） | 汉语同译导致的混淆 | look / see / watch（都=看）· borrow / lend（都=借）· say / speak / talk / tell（都=说）· take / bring / carry（都=拿）· spend / cost / pay（都=花钱） |

母语迁移类是辨析题和完形填空的高价值素材，单独标注 `confusable_type='l1_transfer'`。

#### 3.3.10 同错因（相同错误原因）

相同错误原因导致的拼写错误，归为一组便于诊断和纠正：

| 错误类型 | 典型错误 | 正确形式 |
|----------|---------|---------|
| i/e 混淆 | recieve / beleive / acheive | receive / believe / achieve |
| -tion 写成 -sion | attension / educatoin | attention / education |
| 双辅音遗漏 | hapen / leter / writting | happen / letter / writing |
| 名词动用重音 | 'REcord / 'PREsent | re'CORD / pre'SENT |

#### 3.3.11 同构词法类型

| 构词类型 | 说明 | 示例 |
|----------|------|------|
| 转化词（conversion） | 同一词形，不同词性，重音常变 | record (名/动) · present (名/动/形) · increase (名/动) |
| 派生词（derivation） | 词根+词缀构成新词 | happy→happiness · nation→national→international |
| 复合词（compounding） | 两个以上词组合 | sunrise / classroom / homework / bedroom |

#### 3.3.12 同搭配（collocation）

相同搭配模式的词，批量学习固定搭配：

| 搭配模式 | 示例 |
|----------|------|
| heavy + 名词 | heavy rain / heavy snow / heavy traffic / heavy smoker |
| take + 名词 | take a photo / take a break / take notes / take medicine |
| make + 名词 | make a decision / make progress / make a mistake / make money |
| pay + 介词 | pay attention to / pay a visit to / pay for |
| V + 介词固定 | believe IN / depend ON / consist OF / lead TO / result IN |

#### 3.3.13 上下位关系（hypernym）

上下位关系是语义聚合的核心——只存**一个方向**（source=下位词 → target=上位词），查询时反推：

| 上位词 | 下位词示例 |
|--------|-----------|
| animal | dog / cat / elephant / mammal / bird / fish |
| plant | tree / flower / grass / vegetable / rose / oak |
| emotion | happiness / sadness / anger / fear / joy / grief |
| vehicle | car / bus / truck / bicycle / train / airplane / ship |

上下位网络替代扁平语义场表：查询"动物类词"即查 animal 的全部下位词，无需独立语义场表。

#### 3.3.14 语言关系维度总览（v1.5 新增）

| 维度 | 分类标准 | 存储约定 | 核心价值 | 新增 |
|------|---------|---------|---------|------|
| 同词根 | 相同词根 | morphemes + word_morphemes | 词族扩展，构词法学习 | |
| 同词缀 | 相同前缀/后缀 | morphemes + word_morphemes | 派生规则批量掌握 | |
| 同字母组合 | 相同字母序列 | phonics_patterns + word_phonics | 拼读联动拼写 | |
| 同发音模式 | 相同音素 | word_pronunciations 关联 | 听力辨析题 | |
| 同词源 | 相同语系 | words.origin_language | 文化背景/词汇规律 | |
| 同拼写模式 | 相同拼写规律 | word_forms.spelling_rule | 避免拼写错误 | |
| 同义词 | 意义相近 | word_relations (symmetric) | 写作替换/辨析题 | |
| 反义词 | 意义相反 | word_relations (symmetric) | 对比记忆/完形填空 | |
| 易混词 | 视觉/听觉/意义/L1迁移 | word_relations (无向) + confusable_type | 高价值辨析题素材 | |
| 同错因 | 相同错误类型 | word_mistakes.mistake_type | 错误诊断和纠正 | |
| 同构词法 | 转化/派生/复合 | words.word_type | 构词规则学习 | |
| 同搭配 | 固定搭配 | word_collocations + coll_type | 地道表达/写作 | |
| 上下位 | 下位→上位单向 | word_relations (one_way) | 语义聚合/归类题 | |
| 部分整体 | 部分↔整体单向 | word_relations (one_way) relation_type=meronym/holonym | 整体性语义理解 | ★ 新增 |
| 语域变体 | 同一概念美英差异 | word_relations (symmetric) relation_type=regional_variant + dialect_pair | 跨区域精准用词 | ★ 新增 |
| 情感色彩 | 褒义/贬义/中性 | word_relations relation_type=connotation_variant；或 word_senses.connotation | 写作精准用词 | ★ 新增 |
| 同介词搭配 | 相同固定介词 | word_collocations coll_type='prepositional_verb'；或 word_preposition_collocation | 中国学生高频错点 | ★ 新增 |
| 假朋友 | 英汉翻译陷阱 | word_relations relation_type=false_friend + l1_pair='zh' | 翻译准确性 | ★ 新增 |
| 同句法结构 | 同一句法框架 | sense_syntax_frames + word_relations (same_syntax) | 产出性学习/造句 | ★ 新增 |
| 隐喻关联 | 同一概念隐喻框架 | metaphor_frames + word_metaphors | 深层理解英语思维 | ★ 新增 |
| 多义派生链 | 义项间语义延伸路径 | sense_relations polysemy_type=radiation/chaining | 一词多义学习路径 | ★ 新增 |
| 同情感色彩组 | 同一情感色彩词组 | connotation_groups + word_connotation_group | 情感色彩辨析 | ★ 新增 |
| 逆构词 | 逆构词对 | word_relations relation_type=back_derived | 构词法知识 | ★ 新增 |
| 同主题语境 | 同一情境高频共现词 | topic_clusters + word_topic_clusters | 情境化学习/写作 | ★ 新增 |
| 同难度层级 | 同一 CEFR/难度 | 已有 difficulty_level 字段，查询聚合 | 分级学习路径 | ★ 新增 |
| 同词频波段 | 同一词频波段 | 已有 frequency_level 字段，查询聚合 | 高频优先学习 | ★ 新增 |
| 同学习先备 | 相同前置词/规则 | prerequisite_groups + word_prerequisites | 学习路径依赖 | ★ 新增 |
| 转喻关联 | 以局部指代整体 | word_relations relation_type=metonymy | 阅读理解/写作 | ★ 新增 |
| 形式相似无关 | 跨语言形式相似陷阱 | word_relations relation_type=pseudo_cognate | 翻译准确性 | ★ 新增 |
| 构词变体 | 词素变体归并 | morphemes.allomorph_of | 词素体系完整性 | ★ 新增 |

每条关系必须记录关系类型、方向（对称/单向/有向）、适用义项、证据来源和说明，不能只保存一个相关单词文本。

**各维度数据库落点说明（v1.5 完整版）**：
- **同词根/同词缀** → `morphemes` + `word_morphemes` 表，词素表独立存储
- **同字母组合/同发音模式** → `phonics_patterns` + `word_phonics` 表
- **同义词/反义词/上下位/部分整体/语域变体/假朋友/逆构词/转喻/形式相似无关** → `word_relations` 表，`relation_type` 对应，direction 标记方向
- **同搭配/同介词搭配** → `word_collocations` 表，coll_type 区分类型
- **同错因** → `word_mistakes` 表
- **同构词法** → `words.word_type` 字段（simple/derived/compound/converted）
- **同词源** → `words.origin_language` 字段
- **同拼写模式** → `word_forms.spelling_rule` 字段
- **情感色彩** → `word_senses.connotation` 字段（新增），或 `word_relations` relation_type=connotation_variant
- **同句法结构** → `sense_syntax_frames` + `word_relations` relation_type=same_syntax（新增）
- **隐喻关联** → `metaphor_frames` + `word_metaphors` 表（新增，见 4.3.7）
- **多义派生链** → `sense_relations` 表（新增，见 4.3.7）
- **同情感色彩组** → `connotation_groups` + `word_connotation_group` 表（新增，见 4.3.7）
- **同主题语境** → `topic_clusters` + `word_topic_clusters` 表（新增，见 4.3.7）
- **同学习先备** → `prerequisite_groups` + `word_prerequisites` 表（新增，见 4.3.7）
- **构词变体** → `morphemes.allomorph_of` 字段（已有）
- **同难度层级/同词频波段** → 聚合查询已有字段，不新建表

### 3.3.15 新增维度详细说明（v1.5 新增）

#### 3.3.15.1 部分整体关系（Meronym / Holonym）

部分整体关系与上下位关系互补：上下位是"是什么"（is-a）的分类，部分整体是"由什么构成"（part-of）的构成关系。**只存一个方向**（source=部分 → target=整体），查询时反推：

| 部分词 | 整体词 | 示例 |
|--------|--------|------|
| finger | hand | 手指是手的一部分 |
| page | book | 页是书的一部分 |
| wheel | car | 轮子是车的一部分 |
| petal | flower | 花瓣是花的一部分 |
| ingredient | recipe | 配料是食谱的一部分 |

与上下位一起构成完整语义网络双轴。适用题型：归类题（"哪个不是…的一部分"）、完形填空。

#### 3.3.15.2 语域变体（Regional Variant）

同一概念的美式/英式用词差异，对中国学生尤其陌生，是高价值辨析题素材：

| 美式 | 英式 | 说明 |
|------|------|------|
| apartment | flat | 公寓 |
| elevator | lift | 电梯 |
| trash / garbage | rubbish | 垃圾 |
| sidewalk | pavement | 人行道 |
| cookies | biscuits | 饼干 |
| fries | chips | 薯条 |
| soccer | football | 足球（美式 football=橄榄球） |
| pants | trousers | 裤子（英式：pants=内裤；美式：pants=外裤/长裤） |
| candy | sweets | 糖果 |
| schedule | timetable | 时间表 |

存储约定：`dialect_pair` 字段标注对子方向（'us_uk'），source=美式词，target=英式词。对称关系存储。支撑题型：选词填空（根据语境判断美/英式）、阅读理解（跨区域文本）。

#### 3.3.15.3 情感色彩（Connotation）

同一中性词在不同语境下的褒义/贬义/中性色彩，对写作精准用词至关重要：

| 词 | 色彩 | 说明 |
|----|------|------|
| skinny | 贬义 | 瘦得不好看，皮包骨 |
| slim | 中性 | 苗条，健康 |
| thin | 中性偏贬 | 客观描述，偏瘦 |
| slender | 褒义 | 修长，优雅 |

| 词 | 色彩 | 说明 |
|----|------|------|
| childish | 贬义 | 幼稚的，像孩子一样不得体 |
| childlike | 褒义 | 天真的，像孩子一样纯真 |

| 词 | 色彩 | 说明 |
|----|------|------|
| ambitious | 褒义 | 有雄心壮志的 |
| ambitious | 贬义 | 野心勃勃的（视语境） |

| 词 | 色彩 | 说明 |
|----|------|------|
| curious | 褒义 | 好奇的，求知欲强 |
| curious | 贬义 | 八卦的，好管闲事的 |

存储约定：义项级 `connotation` 字段（positive/neutral/negative/mixed），可进一步在 `word_relations` 表中建立同色彩组（褒义词组/贬义词组），支撑"情感色彩辨析"题型。

#### 3.3.15.4 同介词搭配（Same Prepositional Collocation）

中国学生最容易出错的固定介词搭配，独立于普通搭配维度：

| 动词 | 固定介词 | 示例 |
|------|---------|------|
| depend | on | depend on sb./sth. |
| consist | of | consist of sth. |
| believe | in | believe in doing sth. |
| result | in | result in sth.（导致） |
| lead | to | lead to sth.（导致，注意 to 为介词） |
| listen | to | listen to sb. |
| wait | for | wait for sb. |
| search | for | search for sth. |
| succeed | in | succeed in doing |
| apologize | for | apologize for sth. |
| suffer | from | suffer from sth. |
| think | of / about | think of/about sth. |

> 注意：result in / lead to 后接动词要用 V-ing（leading to doing），不是 to do。

存储约定：`word_collocations` 表 `coll_type='prepositional_verb'`，或新建 `word_preposition_collocation` 表独立存储。支撑"选词填空"和"介词改错"题型。

#### 3.3.15.5 假朋友（False Friend）

英汉翻译中字面相似但含义不同的词，是翻译准确性的高价值陷阱：

| 英语词 | 假朋友陷阱 | 正确含义 |
|--------|-----------|---------|
| actually | "活跃地"（误） | 实际上，事实上 |
| considerate | "考虑的"（误） | 体贴的，考虑周到的 |
| considerable | "考虑的"（误） | 相当大的，可观的 |
| eventually | "最终地"（误） | 最终，终于（与 finally/in the end 同义） |
| sensible | "敏感的"（误） | 明智的，合理的 |
| expectant | "期待的"（部分正确） | 期待的；怀孕的（expectant mother=准妈妈） |
| mansion | " MANSION" | 豪宅（不是普通建筑，注意与 massive 区分） |
| once | "一次"（不完整） | 一旦；曾经（视语境） |
| quite | "安静地"（误） | 相当，很 |
| present | "礼物"（误：将形容词/动词义误用为名词） | 现在的（形容词）；礼物（名词，重音在 second syllable） |

存储约定：`word_relations` 表 `relation_type='false_friend'`，`l1_pair='zh'`（汉英假朋友），`explanation` 字段记录正确含义和常见误译。支撑翻译辨析题和完形填空。

#### 3.3.15.6 同句法结构（Same Syntactic Frame）

同一句法框架的词，支撑产出性学习（造句、写作）：

**动词 + that-clause：**
believe / think / suggest / hope / expect / suppose / imagine / realize

> I **believe** that he is honest. / I **think** that she will come.

**动词 + 宾语 + to-infinitive：**
want / expect / ask / tell / persuade / remind / advise / allow

> I **want** him to stay. / She **asked** me to wait.

**形容词 + to-infinitive：**
glad / happy / ready / eager / willing / sure / certain / likely

> I'm **glad** to see you. / She's **ready** to go.

**名词 + that-clause：**
fact / idea / news / hope / suggestion / belief / opinion

> It's a **fact** that the earth is round.

**动词 + 介词 + V-ing：**
think of / dream of / insist on / look forward to / consist of / depend on

> I **look forward to** hearing from you. / They **insist on** paying.

存储约定：已有 `syntax_frames` 表和 `sense_syntax_frames` 表，在此基础上增加 `word_relations` `relation_type='same_syntax'`（同一 frame_code 的词之间的关系）。支撑"同框架造句"和"句型转换"题型。

#### 3.3.15.7 隐喻关联（Metaphor）

概念隐喻框架（ Lakoff & Johnson）将分散的搭配和表达用统一的隐喻结构组织起来，有助于深层理解英语思维模式：

| 隐喻框架 | 词块示例 |
|---------|---------|
| TIME IS MONEY | spend time / waste time / invest time / save time / budget time |
| IDEAS ARE FOOD | digest an idea / food for thought / half-baked idea / swallow an idea |
| THE MIND IS A MACHINE | mind grinding away / mental gears / head is not working |
| LOVE IS A JOURNEY | our relationship has hit a dead end / we're going in different directions / it's a long road ahead |
| ARGUMENT IS WAR | I defended my position / I attacked his argument / she shot down my proposal |
| HAPPY IS UP / SAD IS DOWN | I'm feeling up / I'm down / that boosted my spirits / I fell into a depression |

存储约定：新建 `metaphor_frames` 表（frame_code, frame_name, explanation, source_version）和 `word_metaphors` 表（word_id, sense_id, frame_id, metaphor_expression, example）。支撑"隐喻连线题"和"阅读隐喻理解"题型。

#### 3.3.15.8 多义派生链（Polysemy Chain）

同一词不同义项之间的语义延伸路径，帮助理解一词多义的演变和学习顺序：

| 词 | 辐射型（radiation） | 连锁型（chaining） |
|----|---------------------|-------------------|
| run | 跑 → 跑开 → 逃亡 → 管理/经营 → 运转 → 发烧 | — |
| board | 木板 → 董事会 → 上（船/飞机） → 膳宿 | — |
| current | 水流 → 气流 → 当前/时下 | current → 当前的 → 流通的 |
| table | 桌子 → 表格 → 暂缓（table a proposal） | — |
| school | 学校 → 学派 → 一群（鱼） | — |

**辐射型**：核心义向四周扩散，各义项与核心义直接相关。
**连锁型**：义项之间依次延伸，后一个义项从前一个义项引申而来。

存储约定：新建 `sense_relations` 表（`source_sense_id`, `target_sense_id`, `polysemy_type`='radiation'/'chaining', `explanation`）。支撑"一词多义选择题"和"义项排序学习"。

#### 3.3.15.9 同情感色彩组（Connotation Group）

同一情感色彩的词归为一组，便于批量辨析和写作选词：

| 色彩 | 词组 |
|------|------|
| 强烈褒义 | brilliant / magnificent / superb / outstanding / phenomenal |
| 温和褒义 | good / nice / pleasant / satisfactory / decent |
| 强烈贬义 | terrible / awful / horrible / dreadful / pathetic |
| 温和贬义 | bad / poor / unsatisfactory / mediocre / inferior |
| 中性描述-大小 | big / large / small / little |
| 中性描述-价格 | cheap / expensive / affordable / reasonable |
| 中性描述-速度 | fast / slow / quick / rapid |
| 中性描述-外观 | pretty / ugly / average-looking / plain |

存储约定：新建 `connotation_groups` 表（id, group_name, connotation, description）和 `word_connotation_group` 表（word_id, sense_id, group_id）。支撑"情感色彩归类题"和"同义词替换（考虑语体）"。

#### 3.3.15.10 逆构词（Back-formation）

逆构词是从已有词逆向分析出更"基本"形式的词，属于构词法知识的一部分：

| 逆构词（后出） | 原词（先有） | 说明 |
|--------------|------------|------|
| edit | editor | 从 editor 逆构出 edit（先有"编辑者"概念，后造"编辑"动词） |
| automate | automation | 从 automation 逆构出 automate |
| donate | donation | 从 donation 逆构出 donate |
| diagnose | diagnosis | 从 diagnosis 逆构出 diagnose |
| e-mail | mailbox | 较新逆构 |
| enthuse | enthusiasm | 从 enthusiasm 逆构出动词 |
| babysit | babysitter | 从 babysitter 逆构出 babysit |

存储约定：`word_relations` 表 `relation_type='back_derived'`，`source_word_id`=逆构词（动词），`target_word_id`=原词（名词），`explanation` 说明逆构关系。支撑"构词法选择题"。

#### 3.3.15.11 同主题语境（Same Thematic Context）

同一情境下高频共现的词，形成"主题词簇"，区别于上下位语义关系（is-a），这是**共现统计**意义上的关联：

| 主题语境 | 高频共现词 |
|---------|-----------|
| 医疗健康 | doctor / hospital / medicine / patient / symptoms / diagnosis / treatment / prescription / surgery / nurse |
| 学校生活 | classroom / teacher / homework / exam / subject / grade / principal / recess / cafeteria / curriculum |
| 旅行旅游 | destination / passport / luggage / flight / hotel / reservation / sightseeing / itinerary / guidebook / souvenir |
| 环保自然 | climate / pollution / recycle / sustainability / ecosystem / renewable / carbon / greenhouse / biodiversity / deforestation |
| 科技创新 | algorithm / data / innovation / digital / artificial intelligence / cloud / network / automation / patent / startup |
| 家庭生活 | chores / grocery / mortgage / insurance / commute / childcare / household / appliance / renovation / pet |

存储约定：新建 `topic_clusters` 表（id, cluster_name, theme_group, description）和 `word_topic_clusters` 表（word_id, sense_id, cluster_id, co_occurrence_weight）。词簇数据来源：语料库共现统计 + 专家标注。支撑"情境选词填空"和"话题写作词汇"。

#### 3.3.15.12 同难度层级（Same Difficulty Level）

同一 CEFR 级别或同一固有难度的词，用于分级阅读、同级对比和渐进式学习路径：

| 级别 | 特征 | 示例词 |
|------|------|--------|
| A1 | 最常用日常词，可手势交流 | water / house / run / big / happy |
| A2 | 基本社交和日常词汇 | hospital / climate / afford / improve |
| B1 | 中级，话题相关词汇 | sustainable / access / complex / conduct |
| B2 | 高级，可参与复杂对话 | significantly / nevertheless / alternative |
| C1 | 学术/专业词汇 | methodology / paradigm / hypothesis |
| C2 | 接近母语者水平 | — |

存储约定：已有 `word_senses.inherent_difficulty`（low/medium/high）和 `word_curriculum.cefr_level`（A1-B2）字段。查询时按 `difficulty_level` 或 `cefr_level` 聚合即可，不需要新建关系表。支撑"分级闯关"和"CEFR 水平测试"。

#### 3.3.15.13 同词频波段（Same Frequency Band）

同一词频波段的词，高频词优先学习，同频段词可以打包学习：

| 波段 | 覆盖比例 | 说明 |
|------|---------|------|
| 高频（top 1000） | 约85%文本覆盖率 | 核心基础词，优先学习 |
| 中频（1001-3000） | 约10%文本覆盖率 | 学业相关词 |
| 低频（3001-10000） | 约4%文本覆盖率 | 学术/专业词 |
| 稀有（10000+） | 约1% | 罕见词，仅查阅 |

存储约定：已有 `word_curriculum.frequency_level`（high/medium/low）和 `frequency_source` 字段。查询聚合即可，不需要新建关系表。支撑"高频词优先"和"词汇量评估"。

#### 3.3.15.14 同学习先备（Same Prerequisite）

同一前置要求（先掌握的词、规则或句型）的词，用于构建学习路径依赖图：

| 先备要求 | 示例词 |
|---------|--------|
| 需先掌握字母发音 | 进入自然拼读前必须掌握字母音 |
| 需先掌握 basic | basic → basic income / basic needs / basically |
| 需先掌握 light（光） | light → lighthouse / daylight / sunlight / spotlight |
| 需先掌握 -tion 后缀 | nation → education → educational |
| 需先掌握 there be | there be → there used to be / there seems to be |
| 需先掌握 make | make → make sense / make sure / make progress |

存储约定：新建 `prerequisite_groups` 表（id, prereq_type, prereq_description）和 `word_prerequisites` 表（word_id, sense_id, prereq_group_id, is_required）。支撑"学习路径推荐"和"先备诊断测试"。

#### 3.3.15.15 转喻关联（Metonymy）

以局部指代整体或以特征指代本体的修辞手法，对阅读理解和写作都有价值：

| 转喻表达 | 指代含义 | 说明 |
|---------|---------|------|
| The White House said... | 美国政府/总统 | 以建筑指代机构 |
| The bus is coming. | 公交车 | 以车指代交通工具 |
| The pen is mightier than the sword. | 写作/文字 vs 武力 | 以工具指代职业 |
| All hands on deck. | 所有船员 | 以手指代人 |
| I need a new set of wheels. | 汽车 | 以轮子指代车 |
| The crown has decided... | 皇室/君主 | 以王冠指代权力 |
| Hollywood is booming. | 美国电影产业 | 以地名指代产业 |
| The press covered the event. | 新闻媒体/记者 | 以印刷媒体指代新闻业 |

存储约定：`word_relations` 表 `relation_type='metonymy'`，`explanation` 字段记录转喻关系和指代含义。支撑"阅读理解隐含义"和"写作修辞"。

#### 3.3.15.16 形式相似语义无关（Pseudo-cognate）

跨语言形式相似但语义无关的词，与假朋友不同，更强调"形式看起来像同源词但实际不是"：

| 形似英语词 | 真实含义 | 中文相关词（混淆来源） |
|-----------|---------|----------------------|
| sane（健全的） | ≠ sane | sane ≠ 相同（same） |
| quite（相当） | ≠ quiet（安静的） | 拼写相近易混 |
| library（图书馆） | ≠ librarian | 词根相同但含义不同 |
| eventually（最终） | ≈ 最后 | 最终 vs 事件（event） |
| actual（实际的） | ≠ act（行为） | actual ≠ 实际的（误关联） |
| monument（纪念碑） | ≠ monster | 形似但无关联 |

存储约定：`word_relations` 表 `relation_type='pseudo_cognate'`，`explanation` 说明形式相似来源和正确含义。支撑"形似词辨析"题型。

#### 3.3.15.17 构词变体（Allomorph）

词素的拼写变体归并到主词素，是词素体系完整性的保证：

| 主词素 | 变体形式 | 示例词 |
|--------|---------|--------|
| 否定前缀 in- | im- | impossible, immoral |
| 否定前缀 in- | il- | illegal, illegible |
| 否定前缀 in- | ir- | irregular, irresponsible |
| 名词后缀 -tion | -sion | attention → tension, expression → discussion |
| 形容词后缀 -al | 保留 e 加 -ial | nature → natural, culture → cultural |
| 复数 -f/-fe | 变 v 加 -ves | leaf → leaves, knife → knives, life → lives |
| 过去式 -ed | 不规则变体 | go → went, buy → bought, write → wrote |
| 比较级 -er | 不规则 | good → better, bad → worse, many → more |

存储约定：已有的 `morphemes.allomorph_of` 字段。主词素（如 `in-`）的 `id` 作为变体词素（如 `im-`, `il-`, `ir-`）的 `allomorph_of` 值。支撑"词素拆分"和"组合单词"题型。

### 3.3.16 介词专题：六维深度模型

> 版本：v1.5 新增
> 说明：本节从语言学角度系统梳理英文介词的多维深度，是 3.3 节"语言关系维度"在介词这一核心词类上的专项深化，也是介词学习功能的理论基础。

#### 3.3.16.1 介词深度的六维框架

介词的复杂性不在于介词本身，而在于**多个维度同时交叉叠加**。系统掌握英文介词需要在六个维度上同时建立认知：

| 维度 | 核心问题 | 深度体现 |
|------|---------|---------|
| **语义维度** | 一个形式有多少个意义？意义之间如何关联？ | 多义密度（polysemy density）、辐射范畴结构 |
| **搭配维度** | 介词和什么词搭配产生什么含义？ | 介+形、介+动、介+名的固定搭配 |
| **语法维度** | 介词在句中承担什么句法角色？ | 介词悬空（stranding）、词汇化（grammaticalization） |
| **隐喻维度** | 空间意义如何映射到抽象概念？ | 空间→时间、空间→状态、空间→方式 |
| **英汉对比维度** | 英文介词和汉语表达如何对应？ | 对应矩阵的稀疏性、"介词=动词"替换现象 |
| **短语动词维度** | 介词/副词与动词组合产生什么新义？ | 不可预测的短语动词语义 |

#### 3.3.16.2 语义维度：多义密度与辐射范畴

**3.3.16.2.1 各介词的多义密度对比**

不同介词的多义丰富程度差异极大，多义密度直接决定学习难度：

| 介词 | 多义数量 | 语义密度评级 | 难度原因 |
|------|---------|------------|---------|
| of | 20+ | 极高 | 语义最抽象，范畴最大 |
| in | 15+ | 极高 | 时间/状态/方式同时覆盖 |
| on | 12+ | 高 | 状态激活和时间用法复杂 |
| to | 10+ | 高 | 方向延伸至目的/结果 |
| for | 8+ | 高 | 原型义与延伸义距离最远 |
| at | 8+ | 中高 | 精确点的隐喻扩展 |
| by | 6+ | 中 | 手段/邻近/被动句式 |
| from | 5+ | 中 | 来源→分离→原因 |
| with | 5+ | 中 | 伴随/工具/态度 |
| about | 4+ | 中低 | 关于/大约/原因 |

**3.3.16.2.2 of 的完整语义网络**

of 是英语中语义密度最高的介词，是介词学习的标志性难点：

| 用法类型 | 语义 | 示例 |
|---------|------|------|
| 分离/来源 | …之北/之南 | north **of** Beijing |
| 所属 | …的（整体与部分） | the leg **of** the table |
| 材料 | 由…制成 | a ring **of** gold |
| 内容 | 一…（内含物） | a bag **of** rice |
| 部分 | …之中的 | three **of** us |
| 起源 | 来自…时代 | a poet **of** Tang Dynasty |
| 同位 | 即…，名叫… | the city **of** Paris |
| 主题 | 关于，想起 | think **of**, talk **of** |
| 原因 | 因…而死/而死 | die **of** hunger |
| 剥夺 | 夺走…的… | rob sb. **of** sth. |
| 距离 | 在…范围之内 | within 5km **of** the station |
| 时间 | 偶尔（archaic） | **of** an evening |
| 描述 | 具有…特征的 | a man **of** wisdom |
| 格式/标准 | 以…形式 | a meeting **of** the committee |
| 集合 | …中的每一个 | each **of** them |
| 来源归属 | 属于（archaic） | the works **of** Shakespeare |

**3.3.16.2.3 介词辐射范畴结构**

每个介词形成一个**辐射范畴**：核心义（最具体、空间性最强）→ 中间义（部分抽象）→ 边缘义（高度抽象）。

**in 的辐射范畴示例：**

```
                         ┌─────────────────────────┐
                         │  核心义：容器内部        │
                         │  in the box            │
                         └───────────┬─────────────┘
                                     │ 隐喻映射（metaphorical mapping）
                 ┌───────────────────┼───────────────────┐
                 ▼                   ▼                   ▼
         ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
         │ 空间范围（区域）│  │   时间区域    │  │   状态包含    │
         │ in the city   │  │ in the morning│  │ in trouble    │
         │ in the world  │  │ in 2024       │  │ in danger     │
         └───────┬───────┘  └───────┬───────┘  └───────┬───────┘
                 │                  │                  │
                 ▼                  ▼                  ▼
         ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
         │ 衣着/穿着     │  │ 方式/形式     │  │ 原因/依据     │
         │ in uniform   │  │ in English   │  │ in response  │
         │ in red       │  │ in a hurry  │  │ in honor of  │
         └───────────────┘  └───────────────┘  └───────────────┘
```

**深度体现**：从"盒子里面"到"用英语"，中间经过了 4 层隐喻映射，每一层都是一个新的"意义"。学生必须理解这个网络才能灵活运用，而非逐条死记。

#### 3.3.16.3 搭配维度：固定搭配的知识结构

介词的深度不在于介词本身，而在于**它和什么词搭配**——这才是真正的学习难点。

**3.3.16.3.1 介词的三层搭配体系**

```
介词 + 名词 → 短语介词
  on purpose（故意）/ on sale（打折）/ on duty（值班）
  in trouble / in danger / in love / in a hurry
  at peace / at war / at stake / at risk / at will
  for good（永久）/ for sure（肯定）/ for granted（理所当然）

介词 + 动词 → 短语动词
  count on（指望）/ rely on（依赖）/ insist on（坚持）
  put on（穿上）/ look on（旁观）/ carry on（继续）
  come from（来自）/ hear from（收到…的消息）

介词 + 形容词 → 固定搭配
  based on（基于）/ dependent on（取决于）
  good at / bad at / keen on / fond of / tired of
  aware of / capable of / independent of / allergic to
```

**3.3.16.3.2 相似形容词的介词搭配完全不同**

介词+形容词固定搭配是介词学习最难的部分——没有任何规律可循。详细搭配示例见 **3.3.15.4 节**；以下是典型对照：

| 形容词 | 介词 | 例 |
|--------|------|------|
| good | **at** | good at math |
| bad | **at** | bad at languages |
| fond | **of** | fond of animals |
| keen | **on** | keen on music |
| tired | **of** | tired of this |
| aware | **of** | aware of danger |
| capable | **of** | capable of doing |
| skilled | **in** | skilled in programming |

> **介词在这里是不可预测的搭配常数**，必须逐一记忆。

**3.3.16.3.3 同一形容词的多介词搭配**

同一形容词后接不同介词，表达不同的语义细分：

| 形容词 | 介词 | 语义差异 |
|--------|------|---------|
| good | **at** | 擅长某技能 |
| good | **in** | 在某方面表现好 |
| good | **with** | 与某人相处好 |
| good | **to** | 对某人友善 |
| good | **for** | 对…有益 |
| good | **about** | 对…感觉好 |

#### 3.3.16.4 语法维度：句法角色与移位规则

**3.3.16.4.1 介词的句法角色**

| 句法角色 | 示例 | 特点 |
|---------|------|------|
| 介词短语（PP）作状语 | I sat **on the chair**. | 最常见 |
| 介词短语作定语 | The book **on the table** | 需后置修饰名词 |
| 介词短语作表语 | She is **in trouble**. | 状态表达 |
| 介词短语作补语 | I put it **in the box**. | 宾语补足语 |
| 介词悬空（Stranding） | Who are you waiting **for**? | 口语体可移位 |
| 介词作连词 | **Since** then, ... | 词汇功能转换 |
| 介词作副词 | Come **in**! / Go **on**! | 省略宾语后副词化 |
| 介词构成复合介词 | **in front of**, **because of** | 已词汇化 |

**3.3.16.4.2 介词悬空的规则体系**

介词悬空（Preposition Stranding）是英语特有的语法现象：**什么时候能悬空，什么时候不能**：

| 句型 | 悬空合法 | 说明 |
|------|---------|------|
| 疑问词引导 | Who are you waiting **for**? | ✅ 口语体常用 |
| 关系从句 | The book (that) I was looking **at**. | ✅ that 可省略 |
| 被动句 | The children were looked **after**. | ✅ by 可省略 |
| 不定式 | I have a lot to deal **with**. | ✅ 动词不定式后 |
| 宾语从句 | I don't know what he's talking **about**. | ✅ what/who/which 可 |
| 书面/正式语体 | **For** whom are you waiting? | ❌ 书面体需前置 |
| 关系代词which | The person to **which** I referred. | ❌ 正式语体不悬空 |
| that引导关系从句 | The person (that) I talked to. | ✅ that可省略 |

**深度体现**：介词悬空规则涉及**语体（口语 vs 书面）、从句类型、介词类型、疑问词类型**的四维交叉，学生需要精确掌握。

**3.3.16.4.3 介词的词汇化路径**

介词在历史演变中产生语法化（grammaticalization），这是介词深度的历史维度：

| 演变路径 | 示例 | 说明 |
|---------|------|------|
| 介词 → 连词 | **since**（从"自从"→"因为"） | 介词功能弱化为逻辑连词 |
| 介词 → 副词 | **in/out/up/down** 单独使用 | 省略宾语后副词化 |
| 介词 → 情态 | **without** + V-ing | 隐含否定，无"not" |
| 介词 → 形容词 | **on** + N → **ongoing** | 介词+名词构成形容词 |

#### 3.3.16.5 隐喻维度：空间图式到抽象映射

介词深度的最终体现是**空间语义到抽象概念的系统性隐喻映射**，这是认知语言学揭示的最深层结构。

**3.3.16.5.1 四大空间介词的意象图式对比**

| | **on** | **in** | **at** | **by** |
|--|--------|--------|--------|--------|
| 核心图式 | 接触面（支撑关系） | 容器内部 | 精确点 | 邻近/手段 |
| 空间 | on the table | in the room | at the corner | by the window |
| 时间粒度 | on Monday | in July, in 2024 | at 3pm, at night | — |
| 状态 | on purpose, on sale | in danger, in love | at peace, at work | — |
| 方式 | on foot | in English | — | by hand, by car |

**3.3.16.5.2 空间 → 时间的隐喻映射系统**

```
[空间域]  ─────────────────────────────────→  [时间域]
                                                      │
on the table ──────────────────────────────→ on Monday
  "接触表面"                              "日历上的接触点"
                                                      │
in the box ───────────────────────────────→ in 2024
  "容器内部"                              "年份的内部/范围内"
                                                      │
at the door ──────────────────────────────→ at 3 o'clock
  "精确空间点"                            "时间轴的精确一点"
                                                      │
from Beijing ────────────────────────────→ from now on
  "来源点"                                "起始点"
                                                      │
to Shanghai ─────────────────────────────→ from 9 to 5
  "目标点"                                "从某时到某时"
```

**3.3.16.5.3 空间 → 状态的隐喻映射系统**

| 空间图式 | 隐喻为状态 | 示例 |
|---------|-----------|------|
| in（内部） | 状态包含 | **in trouble**, in danger, in love, in pain |
| on（表面接触） | 状态激活/继续 | **on duty**, on purpose, on sale, on the way |
| at（精确点） | 状态定位 | **at peace**, at war, at stake, at risk |
| under（下方） | 被控制/被压迫状态 | **under control**, under pressure, under the weather |
| over（上方） | 掌控/超过/克服 | **over it**（克服了）, over the hill |
| out of（外部） | 脱离某种状态 | **out of danger**, out of order, out of patience |
| through（穿过） | 完成/经历 | **go through** difficulties, **sleep through** it |

**3.3.16.5.4 ON 的完整隐喻网络图**

```
                        [表面接触：初始状态]
                              on the table
                                   │
              ┌────────────────────┼────────────────────┐
              ▼                    ▼                    ▼
     [功能激活/运作中]      [继续进行]            [依赖关系]
     turn on the light      go on reading         count on sb.
     switch on             keep on trying        rely on sb.
     put on clothes        carry on              look on
              │                    │                    │
              ▼                    ▼                    ▼
     [发生/进行]            [临近/接近]          [依据/承诺]
     on purpose            on Monday             on my word
     on the increase       on the way            on the basis of
     on the run            on the point of       on this occasion
              │                    │                    │
              ▼                    ▼                    ▼
     [关于/话题]            [费用/请客]          [录制/广播]
     a book on physics     Dinner is on me       be on the air
     a lecture on history   This round is on me  The show is on
```

#### 3.3.16.6 英汉对比维度：中国学生的特殊难点

这是中国学生介词学习困难的核心来源——**介词在英汉两种语言中的编码方式完全不同**。

**3.3.16.6.1 对应矩阵的稀疏性**

英语介词和汉语介词/介词短语之间的对应关系极度稀疏（sparse mapping）：

| 语义 | 英语介词 | 汉语表达 | 对应类型 |
|------|---------|---------|---------|
| 空间-内部 | in | 在…里 | 部分对应 |
| 空间-表面 | on | 在…上 | 部分对应 |
| 空间-点 | at | 在（某点） | 部分对应 |
| 工具 | with | 用 | 部分对应 |
| 对象 | to | 给/向 | 部分对应 |
| 来源 | from | 从 | 较接近 |
| 排除 | except | 除了 | 接近 |
| 伴随 | with | 和/跟 | 部分对应 |
| 原因 | because of | 因为 | 汉语用连词 |
| 目的 | for / to | 为了 | 汉语用副词 |
| 关于 | about / on | 关于 | 接近 |

> **关键教学洞察**：对应率仅约 40-50%，超过一半的英语介词用法在汉语中没有直接对应。

**3.3.16.6.2 汉语"介词=动词"替换现象**

汉语中大量英语介词的功能由**动词**承担：

| 英语介词短语 | 汉语表达 | 认知差异 |
|------------|---------|---------|
| depend **on** | 依靠、依赖 | 英语介词，汉语动词 |
| listen **to** | 听（独立动词） | 英语分立，汉语合一 |
| look **at** | 看（独立动词） | 同上 |
| arrive **in/at** | 到达（独立动词） | 同上 |
| belong **to** | 属于（独立动词） | 同上 |
| suffer **from** | 遭受（独立动词） | 同上 |
| consist **of** | 由…组成（动词短语） | 同上 |

> **教学启示**：中国学生的问题是，看到 `depend` 知道是"依靠"，看到 `on` 知道是"在…上"，但合在一起 `depend on` 的意思无法从组合规则推导——**搭配产生了新义（compositionality failure）**。

**3.3.16.6.3 汉语"在"的英语三选一**

汉语的"在"是最大的介词学习陷阱——英语需要根据图式精确区分：

| 汉语"在" | 英语介词 | 选用依据 |
|---------|---------|---------|
| 在桌子上 | **on** the table | 表面接触（支撑关系） |
| 在盒子里 | **in** the box | 容器内部 |
| 在门口 | **at** the door | 精确点 |
| 在学校 | **at** the school | 作为地点（功能概念） |
| 在医院工作 | **at** the hospital | 工作功能性地点 |
| 在北京 | **in** Beijing | 城市（区域范围） |
| 在树下 | **under** the tree | 下方（不接触） |
| 在树上 | **in** the tree | 在树中（含内部空间）vs **on** the tree（在树表面，不常用） |
| 在电视上 | **on** TV | 表面（屏幕） |
| 在报纸上 | **in** the newspaper | 内容包含（在报纸中） |
| 在工作中 | **at** work | 精确状态点 |
| 在春天 | **in** spring | 时间范围 |
| 在星期一 | **on** Monday | 时间点（具体一天） |
| 在三点 | **at** 3 o'clock | 精确时间点 |

#### 3.3.16.7 短语动词维度：不可预测的组合

短语动词是介词深度最集中的爆发点——**介词/副词与动词的组合产生不可预测的新义**。

**3.3.16.7.1 短语动词的语义不可预测性**

| 短语动词 | 各部分字面义 | 实际义 | 可预测性 |
|---------|------------|--------|---------|
| break down | 打破+向下 | 故障/崩溃 | 部分可预测 |
| break in | 打破+进入 | 闯入/插话 | 部分可预测 |
| break up | 打破+上去 | 分手/解散 | 部分可预测 |
| break through | 打破+穿过 | 突破 | 部分可预测 |
| break off | 打破+离开 | 中断/断绝 | 部分可预测 |
| break out | 打破+出去 | 爆发 | 难以预测 |
| break away | 打破+离开 | 逃脱/脱离 | 难以预测 |
| break in on | 打破+进入+on | 打断（对话） | 完全不可预测 |

**3.3.16.7.2 及物性分化（Transitivity Split）**

同一短语动词，既可及物又不及物时，意思完全不同：

| 短语动词 | 不及物用法 | 及物用法 |
|---------|-----------|---------|
| **turn** up | 出现（He didn't turn up.） | 调大（Turn up the volume.） |
| **break** down | 故障（The car broke down.） | 分解（Break it down.） |
| **break** in | 闯入（Thieves broke in.） | 打断（Don't break in.） |
| **find** out | 发现（真相） | 查明（find out the truth） |
| **work** out | 想出/锻炼 | 算出（work out the problem.） |
| **look** forward to | 期待（不及物，接to） | — | 期待（to为介词，后接V-ing） |

**3.3.16.7.3 介词与副词的区分（Phrasal vs. Prepositional）**

| 类型 | 结构 | 可分性 | 示例 |
|------|------|--------|------|
| 短语动词（Phrasal Verb） | V + 副词 | 可分/不可分均可 | look up the word / look the word up |
| 介词动词（Prepositional Verb） | V + 介词 | 不可分 | look at the board（*look the board at ❌） |
| 双词动词（Phrasal-Prepositional） | V + 副词 + 介词 | 不可分 | look forward to（*look it forward to ❌） |

#### 3.3.16.8 介词六维深度总览

```
                    ┌─────────────────────────┐
                    │     介词深度六维模型      │
                    └────────────┬────────────┘
                                 │
        ┌────────┬─────────┬───┴───┬─────────┬────────┐
        ▼        ▼         ▼       ▼         ▼        ▼
    语义维度  搭配维度  语法维度  隐喻维度  英汉维度  短语维度
        │        │         │       │         │        │
    多义网络  介+形/动   悬空规则  空间→    对应稀疏  动词+介词
    辐射范畴  固定搭配   词汇化    抽象映射  编码差异  新义不可预测
        │        │         │       │         │        │
        └────────┴────┬────┴───┬───┴─────────┴────┬────┘
                      ▼       ▼                   ▼
               深度叠加：     语体差异：          学习难点：
               一个介词在      口语书面            介词的真实
               六个维度上      介词使用            掌握需要
               同时产生        差异显著            六维协同
               复杂性
```

#### 3.3.16.9 介词学习的认知路径

**四步认知习得路径：**

```
第一步：建立空间图式
  → on = 接触面（支撑关系）→ in = 容器内部
  → at = 精确点 → under = 下方（不接触）
  → over = 上方（覆盖/跨越）

第二步：空间图式 → 时间隐喻
  → on Monday（像在日历的某一天上）
  → in the morning（在上午这个时间段内）
  → at 3 o'clock（在时间轴的精确一点）

第三步：时间隐喻 → 状态/方式隐喻
  → in danger（处于危险状态容器内）
  → on purpose（把目的当作支撑面站上去）
  → in English（以英语这种形式/容器为载体）

第四步：建立多义网络
  → 看到任何介词，先还原空间图式，再推理隐喻方向
  → 搭配固定搭配，查介词-形容词/动词词典
  → 区分短语动词的及物性
```

#### 3.3.16.10 介词数据的数据库落点

介词六维模型在设计文档中的落地方式：

| 维度 | 对应设计文档维度 | 落地方式 |
|------|---------------|---------|
| 语义维度 | 多义派生链（sense_relations） | polysemy_type='radiation'，of/in/on 等高多义介词重点建网 |
| 搭配维度 | 同介词搭配（prepositional collocation） | word_collocations coll_type='prepositional_verb' |
| 语法维度 | 同句法结构（same_syntax_frames） | syntax_frames 'V+prep+V-ing' 等介词相关框架 |
| 隐喻维度 | 隐喻关联（metaphor_frames） | metaphor_frames 覆盖 in/on/at 等核心隐喻映射 |
| 英汉对比 | 易混词（L1迁移）+ 假朋友 | word_relations confusable_type='l1_transfer' + false_friend |
| 短语动词 | 同搭配 + 同错因 | word_collocations + word_mistakes.mistake_type='collocation' |

介词作为独立词类，专项学习路径需在介词词条下聚合六维数据，支持从**空间图式**出发、沿**隐喻映射**展开、通过**固定搭配**固化的认知学习路径。

### 3.3.17 理解深度模型：从分析到掌握

> 版本：v1.5 新增
> 说明：本节回答"六维分析是否等于深度理解"，提出理解单词的正确认知路径模型。

#### 3.3.17.1 分析 ≠ 理解

六维框架是**解构工具**，把一个词拆成多个面来观察。但拆开看≠真正理解——这是单词学习中最大的认知误区。

```
六维分析（知道关于这个词的什么）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  run = 跑 = 经营 = 发烧 = 运行
  ↓       ↓      ↓       ↓
懂搭配  懂用法  懂隐喻   懂语法
（知道） （知道） （知道） （知道）
         ↓
       六维全知道 ≠ 能在真实语境中准确使用
```

**判断标准**：能凭语感判断这个词"感觉对/不对"，但说不出为什么——这才是理解的起点。

#### 3.3.17.2 四阶段深度理解模型

语言习得研究（Laufer & Hulstijn, 2001；Nation, 2001）给出了深度理解的核心路径：

**阶段一：接触层（Encounter）**

在真实语境中遇到生词：

| 方式 | 说明 |
|------|------|
| 阅读中偶遇 | 阅读时根据上下文推测含义 |
| 听对话中捕捉 | 从真实对话中感知词的语调、语体 |
| 情境中观察 | 看到场景（医院、机场）时词汇自然激活 |

**阶段二：加工层（Processing）**

对接触到的词进行**刻意加工**，深度由浅到深分为五级：

| 加工深度 | 类型 | 示例 | 对应六维 |
|---------|------|------|---------|
| L1 最浅 | 形式注意 | 注意到拼写或发音 | 形态维度 |
| L2 | 形式+意义 | 查词典，记住了"跑" | 语义维度 |
| L3 | 语境搭配 | 记住 run a business 不是 run business | 搭配维度 |
| L4 | 使用限制 | 知道 run 用于具体情境，不能描述抽象计划 | 语法维度+语体 |
| L5 最深 | 多义网络+语体 | 能在 run 的 15+ 义项中准确选取 | 隐喻维度+英汉对比 |

> **核心洞察**：L3-L5 是深度理解的分水岭，恰好对应六维框架的搭配、语法、隐喻三个维度。单独背释义只能到达 L2。

**阶段三：固化层（Consolidation）**

通过**重复但不机械**的方式将理解转化为内化知识：

| 方法 | 作用 |
|------|------|
| 间隔复习（FSRS） | 在即将遗忘时提取，强化记忆 |
| 生成性练习 | 造句、写作（主动提取，而非再认） |
| 多语境重现 | 在阅读、听力、口语中多次遇到 |
| 对比辨析 | 与易混词/同义词做区分 |

**阶段四：迁移层（Transfer）**

能在从未见过的新语境中正确使用——这是深度理解的最终验证。

#### 3.3.17.3 四象限理解模型

| | **高语境化** | **低语境化** |
|--|-----------|-----------|
| **高迁移** | **象限IV：深度内化** 能从未见过的新语境中正确使用 | **象限III：机械记忆** 知道意思但无法迁移 |
| **低迁移** | **象限II：语境理解** 在真实情境中理解含义 | **象限I：浮光掠影** 偶遇后模糊感知 |

```
         高语境化
              ↑
              │
    象限III   │   象限IV
    机械记忆  │   深度内化
    (知道但  │   (能在新语境
     用不出)  │    正确使用)
    低迁移 ───┼─── 高迁移
    象限I    │   象限II
    浮光掠影  │   语境理解
    (模糊感知 │   (真实情境
     无法提取) │    中理解)
              │
              ↓
         低语境化

学习路径：I → II → III → IV（螺旋上升）
```

> 大多数背单词软件只覆盖 III/I（孤立的词-义配对），没有覆盖 II/IV（语境化和迁移）。

#### 3.3.17.4 接收性知识 vs 产出性知识

Paul Nation 区分了两类词汇知识——这是理解"深度"本质的最佳框架：

| 知识类型 | 维度 | 说明 | 测度 |
|---------|------|------|------|
| **接收性** | 形式 | 听到/看到能识别 | 听音辨词、看词认读 |
| **接收性** | 意义 | 能匹配释义 | 选义、选图 |
| **接收性** | 使用 | 能理解语境中的用法 | 阅读理解中理解含义 |
| **产出性** | 形式 | 能正确拼写和发音 | 听写、跟读 |
| **产出性** | 意义 | 能回忆出释义 | 无提示回忆 |
| **产出性** | 使用 | 能生成正确搭配和句型 | 造句、写作 |

```
接收性知识 ←─────→ 产出性知识
（看得懂）         （用得出）
    ↑                  ↑
    │    理解深度      │
    │    在于从左     │
    │    向右移动     │
    └────────────────┘

六维框架的作用：
  - 为"接收性理解"提供分析工具（搭配、隐喻、语体）
  - 为"产出性迁移"提供生成依据（固定搭配、句法框架、情感色彩）
```

#### 3.3.17.5 三维整合理解模型

以三维整合为主框架，以六维分析为教学工具：

| 维度 | 核心问题 | 内容 |
|------|---------|------|
| **形式之维** | 这个词长什么样？ | 发音→音标→音素→拼读规则→词素分解 |
| **意义之维** | 这个词描述了什么？ | 原型场景→多义派生链→隐喻映射网络 |
| **使用之维** | 这个词怎么用才对？ | 搭配约束+句法约束+语体约束+语域约束+情感约束 |

#### 3.3.17.6 理解模型在产品中的落地

| 理解阶段 | 对应产品功能 |
|---------|------------|
| 接触层 | 阅读/听力中的语境词汇卡片（i+1 例句） |
| 加工L3 | 搭配练习（选词填空、介词搭配） |
| 加工L4 | 句法约束练习（同框架造句） |
| 加工L5 | 隐喻连线、多义选择题 |
| 固化层 | FSRS 间隔复习（主动回忆） |
| 迁移层 | 写作辅助（AI 纠错）、口语输出评测 |

> **关键设计洞察**：大多数背词软件只做 L2（词-义配对），L3-L5 的加工深度才是深度理解的分水岭——产品需要专门设计 L3-L5 的练习题型，而不是让用户反复刷卡片。

### 3.3.18 词义理解的核心：场景语义学

> 版本：v1.5 新增
> 说明：本节回答"词义为什么会有各种延伸""延伸的规律是什么"——提出**场景语义学**（Scene Semantics）作为词义多维扩展的认知根源。

#### 3.3.18.1 核心命题：每个单词描述一个场景

**语言学发现**：人类语言中的词，在其认知根源上，都是对**感知场景（perceived scene）**的压缩编码。

这意味着：
- 每个词不是指向一个抽象概念，而是指向一个**可感知的场景**
- 多义（polysemy）不是"一个词有多个无关的意思"，而是**同一个场景被投射到了不同的感知域**

以 **run** 为例：

```
run 的原型场景（prototype scene）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        ┌─────────────────────────────────┐
        │      [人在地面上快速移动]        │
        │                                  │
        │   🏃 人 → → → 地面               │
        │   运动方向：水平向前              │
        │   速度：快于走路                  │
        │   动力：自身腿部驱动              │
        │   状态：双脚交替离地（run stride）│
        └─────────────────────────────────┘

场景要素（scene elements）：
  - 施事（agent）：人/动物
  - 动作（motion）：双脚交替离地
  - 路径（path）：水平方向
  - 动力（force）：自身驱动
  - 介质（medium）：地面/空气
```

所有 15+ 个 run 的义项，都从这一个原型场景出发，通过**场景要素的替换或叠加**产生：

```
run 的场景扩展网络
═══════════════════════════════════════════════
       [原型场景：人在地面上快速移动]
              │
  ┌───────────┼────────────┐
  │           │            │
  ▼           ▼            ▼
【人→物】    【人→机器】  【人→液体/抽象】
run a race   run a car    run a business
run a report  run an errand  run a school
run a fever  run an ad    run a risk
run a temperature  run a program  run an operation
  │           │            │
  ▼           ▼            ▼
场景替换：    场景替换：   场景替换：
施事从人      施事从人     施事从人
变为活动      变为机器     变为抽象组织
或事件        或系统       或身体状态
  │           │            │
  ▼           ▼            ▼
运动特征：    运动特征：   运动特征：
持续进行      持续运转     持续运作/存在
```

#### 3.3.18.2 场景要素替换：词义延伸的机制

词义延伸的本质是**场景要素的替换**——保留运动的核心特征（持续、动态、单向），替换施事、对象或介质：

| 替换要素 | 原型场景 | 延伸场景 | run 的义项 |
|---------|---------|---------|-----------|
| 施事 | 人 | 机器 | The engine **runs**. |
| 施事 | 人 | 液体 | The river **runs** fast. |
| 施事 | 人 | 抽象组织 | The company **runs** well. |
| 施事 | 人 | 身体状态 | She **ran** a fever. |
| 对象 | 无 | 事件 | **run** an errand / a risk / a competition |
| 路径 | 水平向前 | 遍布表面 | The road **runs** along the coast. |
| 状态 | 运动 | 失控/脱离 | The situation **ran** out of control. |
| 时间 | 持续 | 时间段 | The movie **ran** for two hours. |

#### 3.3.18.3 其他词的场景原型

**grasp（抓住）：**

```
原型场景：手部动作——手指合拢抓住某物
  施事：手/手指
  动作：合拢→包裹→固定
  对象：具体物体

场景延伸一：理解力——"抓住"抽象概念
  → grasp an idea（理解一个想法）
  → grasp the point（抓住要领）
  "理解"被编码为认知主体用思维"抓住"一个想法

场景延伸二：权力/控制——"抓住"权力
  → grasp power（抓住权力）
  → grasp at straws（抓住救命稻草）
  "抓"的动作图式投射到权力获取

场景延伸三：机会——"抓住"机会
  → grasp the opportunity
  → grasp at a chance
  机会被编码为可"抓住"的物体
```

**break（打破）：**

```
原型场景：完整物体 → 结构破坏 → 碎片/分离
  对象：完整物体
  动作：施加力 → 结构断裂
  结果：整体→碎片/分离

场景延伸一：法律/规则
  → break the law（破坏/违反法律）
  → break a promise（打破承诺）
  "结构完整性"→"规则的完整遵守"
  违反法律 = 在行为规范上"打破"了连续性

场景延伸二：状态中断
  → break the silence（打破沉默）
  → break a habit（戒除习惯）
  "物体断裂"→"状态的突然终结"

场景延伸三：身体/生理
  → break a leg（摔断腿）
  → break wind（放屁）
  身体结构的物理破坏

场景延伸四：技术/系统
  → break a code（破解密码）
  → break a system（攻破系统）
  "结构破坏"→"穿透安全屏障"
```

#### 3.3.18.4 为什么场景会延伸：认知经济性原理

人类选择用已有场景描述新事物，而不是创造新词，原因只有一个：**认知经济性（cognitive economy）**。

| 原理 | 说明 | 示例 |
|------|------|------|
| **最小努力原则** | 大脑倾向于复用已有场景，而非新建 | 用"抓住"（身体动作）描述"理解"（认知行为） |
| **体验连贯性** | 新体验通过旧场景理解 | "抓住机会"利用了"抓住物体"的身体体验 |
| **隐喻系统性** | 延伸不是随机的，而是系统性的 | 大量英语词用"上下""前后""内外"描述抽象状态 |
| **神经重复利用** | 大脑用同一批神经元处理空间和抽象概念 | 顶叶处理空间关系，也处理时间、数学和数量概念 |

#### 3.3.18.5 场景延伸的三种路径

| 延伸路径 | 机制 | run 的例子 | 数量占比 |
|---------|------|---------|---------|
| **相似性延伸** | 新场景与原型场景在结构上相似 | 机器运转→组织运营（都有"持续运转"的特征） | 约 50% |
| **因果性延伸** | 新场景是原型场景的因果结果 | run a risk（导致风险的行为） | 约 30% |
| **类属性延伸** | 新场景共享原型场景的类别特征 | run a temperature（呈现"run"的特征：上升+持续） | 约 20% |

#### 3.3.18.6 场景与六维框架的关系

场景语义学为六维分析提供了**统一的认知根源**：

| 六维框架维度 | 场景语义学解释 |
|------------|-------------|
| 语义维度（多义网络） | 同一原型场景的不同要素替换 |
| 搭配维度 | 特定场景中经常共现的其他词（run + business/risk/fever） |
| 语法维度 | 场景中施事-动作-对象的结构（及物/不及物） |
| 隐喻维度 | 场景从物理域到抽象域的跨域映射 |
| 英汉对比 | 英汉对同一场景的切分粒度不同（汉语"跑/奔/逃" vs 英语 run） |
| 语体维度 | 同一场景的不同说话者身份和正式程度 |

#### 3.3.18.7 场景语义学的产品落地

**核心教学设计**：让用户先看到**原型场景**（图像/动画），再推演延伸义，而非从释义出发。

| 功能 | 场景语义学落地方式 |
|------|----------------|
| 单词卡片 | 优先展示原型场景图像（run → 人奔跑的画面），而非中文释义 |
| 义项学习 | 展示义项时先还原场景要素替换路径（机器→组织→身体状态） |
| 多义练习 | 给出一个新场景，让用户判断用哪个义项（场景-义项匹配） |
| 隐喻连线 | 给出隐喻句（如 "grasp the opportunity"），让用户还原物理场景 |
| 写作辅助 | AI 纠错时，如果用错义项，还原正确场景让学生对比 |
| 词汇量诊断 | 不测"认识多少词"，而测"能激活多少场景" |

> **设计原则**：词义学习的终极目标是让用户看到 **run** 时，脑中首先浮现的是"人在地面快速移动"的**动态画面**，而非"跑/v."的**文字标签**。文字标签是场景的压缩符号，场景才是理解的核心。

### 3.3.19 词源学（Etymology）

> 版本：v1.5 新增
> 说明：本节探讨词源学如何帮助深度理解词义——知道一个词的"身世"，往往能同时理解它的多个义项。

#### 3.3.19.1 核心思想：词源是时间的切片

**词源学（Etymology）**研究词的历史演变——词的诞生、形式变化、意义转移。词源学的独特价值在于：**它让零散的义项在时间轴上重新串联成一条故事线，记忆效果远好于孤立背诵**。

```
传统背词（无效）：
  candidate → 候选人 → 记忆
  ↑ 候选人和 white 有什么关系？不知道

词源学习（有效）：
  candidate
  ├── 拉丁语 candidatus = 穿白袍的人
  ├── 古罗马竞选者穿白色托加袍（toga candida）以示清白
  ├── 白色 → 纯洁 → 无私 → 适合担任公职
  └── 候选人是"洁白无瑕之人"
       ↓
  义项之间的历史脉络打通了
```

#### 3.3.19.2 词源统一多义的经典案例

**disaster（灾难）：**

```
disaster 来自希腊语
├── dis- = 坏（bad）
├── aster = 星星（star）
└── 字面义：坏星星（bad star）
     ↓
古希腊人认为星星影响人间命运
"坏星星" = 预示不幸的天象
     ↓
英文 disaster = 任何灾难（地震、洪水、经济崩溃）
     ↓
词源解释了为什么 disaster 比普通"坏运气"程度更重
```

**ambition（雄心/野心）：**

```
ambition 来自拉丁语
├── ambire = 四处走动（amb- = around + ire = to go）
├── 字面义：四处走动（拉票行为）
└── 历史背景：古罗马政治家为竞选公职四处走动拉票
     ↓
四处走动 → 有目标感 → 渴望成功 → 野心/雄心
     ↓
ambition 有双重色彩：
  褒义：雄心壮志（w ambitious plans）
  贬义：野心勃勃（political ambition）
两个义项在词源上同根，理解其一即理解其二
```

**serendipity（意外发现美好事物的运气）：**

```
serendipity 来自专有名词
├── Serendip = 锡兰（斯里兰卡的古称）
└── 来源：Horace Walpole 的小说《锡兰三王子历险记》
         （The Three Princes of Serendip）
         王子们总能凭智慧和运气意外发现好东西
     ↓
英文 serendipity = 意外发现珍奇事物的运气
     ↓
这是英文中少数以虚构故事命名的词之一
理解了故事，就记住了词
```

#### 3.3.19.3 高频英语词源的分类

**一、古希腊语来源（Science / Philosophy / Medicine）**

| 词 | 希腊词根 | 字面义 | 现代含义 |
|----|---------|--------|---------|
| philosophy | philo（爱）+ sophos（智慧） | 热爱智慧 | 哲学 |
| biology | bios（生命）+ logia（研究） | 生命之学 | 生物学 |
| psychology | psyche（灵魂/心灵）+ logos（研究） | 心灵之学 | 心理学 |
| democracy | demos（人民）+ kratos（统治） | 人民统治 | 民主 |
| telemedicine | tele（远）+ medeia（医术） | 远程医术 | 远程医疗 |
| geography | geo（地）+ graphia（描述） | 地球描述 | 地理学 |
| thermometer | thermos（热）+ metron（测量） | 热测量 | 温度计 |

**二、拉丁语来源（Law / Religion / Administration）**

| 词 | 拉丁词根 | 字面义 | 现代含义 |
|----|---------|--------|---------|
| campus | campus = 场地（原指城市广场） | 开阔场地 | 校园 |
| salary | sal（盐） | 盐（作为津贴） | 工资 |
| veto | veto = 我禁止 | 我禁止 | 否决权 |
| agenda | agere = 做（gerundive 形式） | 待做的事 | 议程 |
| candidate | candidatus = 穿白袍的人 | 穿白衣的竞选者 | 候选人 |
| specimen | specere = 看 | 看的东西 | 样本 |
| manuscript | manus（手）+ scripta（写） | 手写的 | 手稿 |
| amateur | amare = 爱 | 凭爱好做的人 | 业余爱好者 |

**三、法语来源（Culture / Cuisine / Literature）**

| 词 | 法语来源 | 说明 | 现代含义 |
|----|---------|------|---------|
| restaurant | restaurer = 恢复 | 恢复体力的地方 | 餐厅 |
| memoir | memoire = 记忆 | 回忆录 | 回忆录 |
| silhouette | Silhouette（人名） | 18世纪财政部长，侧影画像 | 轮廓 |
| entrepreneur | entrepreneur = 承担者 | 承担企业风险的人 | 企业家 |
| rendezvous | rendez = 安排 + vous = 你们 | 约定地点 | 约会地点 |

**四、日耳曼语来源（Core / Everyday / Body）**

| 词 | 日耳曼词根 | 说明 | 现代含义 |
|----|---------|------|---------|
| lord | hlaf（面包）+ weard（守护者） | 面包守护者 = 封建领主 | 主 |
| lord 的另一解 | hlaf（loaf 面包古义） | 供养者 | 同上 |
| woman | wif（女性）+ man（人） | 女性之人 | 女人 |
| Thursday | Thor（雷神）+ day | 雷神之日 | 周四 |
| Wednesday | Woden（奥丁）+ day | 奥丁之日 | 周三 |

#### 3.3.19.4 词源前缀和后缀的系统性

词根词缀的记忆如果结合词源，效果成倍增强：

**否定前缀 de-/dis-：**

| 词 | 词源 | 含义 | 延伸词 |
|----|------|------|-------|
| deactivate | de-（否定）+ activate | 关闭 | deactivate a bomb |
| demilitarize | de-（否定）+ military | 非军事化 | demilitarize the zone |
| disinfect | dis-（否定）+ infect | 消毒 | disinfect the wound |
| disengage | dis-（否定）+ engage | 脱离 | disengage the clutch |

**方向前缀 e-/ex-（向外）：**

| 词 | 词源 | 含义 | 延伸词 |
|----|------|------|-------|
| eject | e-（出）+ ject（扔） | 弹出 | eject from a plane |
| exhale | ex-（出）+ hale（呼吸） | 呼气 | exhale deeply |
| emigrate | e-（出）+ migrate（迁移） | 移民出境 | emigrate to the US |
| excavate | ex-（出）+ cavare（挖空） | 挖掘 | excavate a site |

**数字前缀：**

| 前缀 | 来源 | 含义 | 词例 |
|------|------|------|------|
| uni- | Latin unus（一） | 一 | uniform, universe, unicorn |
| bi- | Latin bis（两次） | 二 | bicycle, bilingual, binoculars |
| tri- | Latin tres（三） | 三 | triangle, tricycle, trilogy |
| multi- | Latin multus（多） | 多 | multiply, multicolor, multimedia |
| semi- | Latin semis（半） | 半 | semiconductor, semicircle |

#### 3.3.19.5 词源学的产品落地

| 功能 | 词源学落地方式 |
|------|-------------|
| 单词卡片 | 加入词源故事（30-50词/义项），动画展示词源演变 |
| 词根学习 | 从词根词源出发，批量学习派生词（etymology tree） |
| 义项辨析 | 展示多义词各义项如何在词源上统一 |
| 趣味挑战 | 词源猜谜（给出词源描述，让学生猜词） |
| 写作提升 | 介绍拉丁/法语来源词更正式，用于正式写作 |

#### 3.3.19.6 词源学与现有表结构的结合

词源学不改变现有表结构，而是扩展 `words.etymology_story` 字段的应用深度：

- 每个高频词（CEFR A1-B1 核心词）的 etymology_story 字段应包含词源叙述
- 词源叙述格式：`词源语言 → 原始形式 → 字面义 → 历史演变 → 现代义`
- 词根词缀的 etymology 关联通过 `morphemes` 表已有的 `meaning_cn` 字段记录

### 3.3.20 框架语义学（Frame Semantics）

> 版本：v1.5 新增
> 说明：本节探讨框架语义学——理解一个词不是理解它的定义，而是激活一个完整的**知识框架**（knowledge frame）。与场景语义学互补：场景描述身体感知根源，框架描述社会知识网络。

#### 3.3.20.1 核心思想：词激活"场景包"

认知语言学家 Charles Fillmore（1977）提出**框架语义学（Frame Semantics）**：理解一个词，**不是理解它的定义，而是激活一个预先存在于大脑中的知识框架**。

```
传统理解：
  buy = 买（一个动作）

框架理解：
  buy → 激活"商业交易"框架
       ┌─────────────────────────────────┐
       │       COMMERCIAL EVENT           │
       │       （商业交易事件框架）        │
       │                                  │
       │   BUYER ←─── 金钱 ───→ SELLER  │
       │     │                │           │
       │     ↓                ↓           │
       │  买到某物           卖出某物      │
       │                                  │
       │  [物品：GOODS]                   │
       │  [价格：PRICE]                   │
       │  [地点：STORE]                   │
       │  [方式：PAYMENT]                 │
       │  [时间：TRANSACTION TIME]        │
       └─────────────────────────────────┘
```

#### 3.3.20.2 buy 框架的详细展开

buy 框架中的核心角色（frame elements）：

| 框架角色 | 说明 | 在例句中的体现 |
|---------|------|-------------|
| Buyer | 买方 | I bought it. |
| Goods | 商品 | I bought a book. |
| Seller | 卖方 | I bought it from John. |
| Price | 价格 | I bought it for $20. |
| Means | 支付方式 | I bought it with my credit card. |
| Place | 交易地点 | I bought it online. |
| Time | 交易时间 | I bought it last week. |

**buy 各义项激活的框架要素替换：**

| 义项 | Buyer | Goods | Seller | 框架要素替换 |
|------|-------|-------|--------|------------|
| buy a book | 人 | 书籍 | 书店 | 完整框架 |
| buy time | 人 | 时间 | —（无卖方） | 时间被当作商品 |
| buy an idea | 人 | 想法 | 说服者 | 想法被当作商品 |
| buy a story | 人 | 说法 | 叙述者 | 说法被当作商品 |
| buy trouble | 人 | 麻烦 | — | 麻烦被当作可交易的东西 |
| buy someone off | 人 | 金钱（贿赂） | 被收买者 | 用钱收买人 |

#### 3.3.20.3 常用词激活的核心框架

**GIVE 框架（给予）：**

```
┌─────────────────────────────────────┐
│        GIVE EVENT                    │
│        （给予事件框架）               │
│                                      │
│   GIVER ──── GIFT ───→ RECIPIENT   │
│                                      │
│  [原因：REASON] [方式：MEANS]       │
│  [地点：PLACE] [时间：TIME]          │
└─────────────────────────────────────┘

give 的多义：
  give a book（给予实物）
  give a lecture（给予演讲）
  give a smile（给予微笑）
  give trouble（给予麻烦）
  give way（让步）
  give in（屈服）
  give up（放弃）
  → 所有义项共享"给予"框架，只是 Gift 的类型不同
```

**BREAK 框架（破坏）：**

```
┌─────────────────────────────────────┐
│       BREAK EVENT                    │
│       （破坏事件框架）                │
│                                      │
│   BREAKER → FORCE → INTEGRITY BROKEN │
│                                      │
│  [对象：OBJECT] [程度：EXTENT]      │
│  [工具：INSTRUMENT] [方式：MANNER]  │
└─────────────────────────────────────┘

break 的多义（与 3.3.18.3 对照）：
  break a glass（物理破坏）
  break a promise（规则破坏）
  break a habit（状态中断）
  break a leg（身体破坏）
  break a code（穿透屏障）
  → 所有义项共享"完整性被破坏"框架
```

**KNOW 框架（认知）：**

```
┌─────────────────────────────────────┐
│        COGNITION EVENT               │
│        （认知事件框架）               │
│                                      │
│   COGNIZER ── KNOWLEDGE ── FACET   │
│                                      │
│  [内容：CONTENT]                     │
│  [证据：EVIDENCE]                   │
│  [程度：DEGREE]                     │
└─────────────────────────────────────┘

know 的多义：
  know a fact（知道事实）
  know a person（认识人）
  know how to do（知道如何做）
  know one's way around（熟悉某地）
  → 所有义项共享"认知者与被认知内容的连接"框架
```

#### 3.3.20.4 框架语义学 vs 场景语义学

| | 场景语义学 | 框架语义学 |
|--|----------|----------|
| 核心单位 | 感知场景（perceived scene） | 知识框架（knowledge frame） |
| 激活内容 | 视觉/动作/空间意象 | 角色、关系、脚本 |
| 典型例子 | run = 人在地面快速移动的画面 | buy = 交易双方+商品+金钱框架 |
| 侧重点 | 身体化（感知体验） | 社会性（百科知识） |
| 对多义的解释 | 场景要素替换 | 框架要素替换 |
| 互补关系 | 提供感知根源 | 提供社会知识网络 |

**两者共同解释多义**：
- 场景语义学解释"为什么是这个形状"（身体感知根源）
- 框架语义学解释"为什么激活这些角色"（社会知识网络）

#### 3.3.20.5 框架语义学的产品落地

| 功能 | 框架语义学落地方式 |
|------|-----------------|
| 义项学习 | 学习义项时展示"激活了哪些框架角色" |
| 完形填空 | 设计"缺少框架中某个角色的句子"，让用户填充 |
| 写作辅助 | 根据框架，提示用户完善句子的框架角色（buyer, goods, price...） |
| 义项消歧 | 输入句子时，根据框架角色判断应激活哪个义项 |

#### 3.3.20.6 框架语义学的数据库落点

框架语义学扩展现有表结构：

- **新建 `word_frames` 表**：记录词激活的框架名称（基于 FrameNet）
- **扩展 `word_senses` 表**：`frame_id` 字段关联到具体框架中的角色
- **框架数据来源**：可参考 FrameNet（Berkeley FrameNet 项目），已有约 1,200 个英文框架

### 3.3.21 韵律与音义（Sound Symbolism / Phonestheme）

> 版本：v1.5 新增
> 说明：本节探讨英语中某些音组合（phonestheme）带有系统性情感或语义联想——这是单词的"声音心理学"，是学生完全不知道的认知盲区。

#### 3.3.21.1 核心思想：声音也有含义

传统语言学认为：词的声音和意义之间没有必然联系（arbitrariness），语言符号是任意的。

但认知语言学发现：英语中存在大量**音义关联（sound symbolism）**——某些音组合带有系统性的情感或语义联想：

```
"A word is known by the company it keeps." — Firth
"A sound is known by the meanings it brings." — 认知语言学

传统观点（任意性）：
  dog [dɒg] → 狗 ← 音和义之间没有联系

认知语言学观点（理据性）：
  dog 中的 [d-] 音开头 → 多数 [d-] 词有"向下/沉重"感
  glide / drop / drive / drag / drip / draw / drain
  ↓
  dog 的 [d-] 暗示一种"沉重/下坠"的存在感
```

#### 3.3.21.2 音义组合（Phonestheme）的系统性

**sl- 系列：贬义/滑腻/负面**

| sl- 词 | 含义 | 共同特征 |
|--------|------|---------|
| slip | 滑倒 | 滑腻感 |
| slide | 滑动 | 滑腻感 |
| slither | 蜿蜒滑行 | 滑腻感 |
| slick | 光滑的/圆滑的 | 滑腻感；亦可指人圆滑（贬义） |
| slander | 诽谤 | 负面 |
| sluggish | 迟钝的 | 负面 |
| sleazy | 脏乱 | 负面 |

**gr- 系列：力量/抓取/摩擦**

| gr- 词 | 含义 | 共同特征 |
|--------|------|---------|
| grab | 抓取 | 力量感 |
| grasp | 抓紧 | 力量感 |
| grip | 紧握 | 力量感 |
| grind | 研磨 | 摩擦感 |
| growl | 咆哮 | 力量感（动物） |
| grunt | 嘟囔 | 力量感 |
| gregarious | 群居的 | 聚集感 |
| grumble | 抱怨 | 低沉声音 |

**fl- 系列：轻盈/飞行/流动**

| fl- 词 | 含义 | 共同特征 |
|--------|------|---------|
| fly | 飞 | 轻盈/飞行 |
| float | 漂浮 | 轻盈/流动 |
| flutter | 飘动 | 轻盈/不规律 |
| flick | 轻弹 | 轻盈/快速 |
| flare | 闪耀 | 轻盈/光 |
| flip | 翻转 | 轻盈/快速 |
| flood | 洪水 | 流动 |
| flow | 流动 | 流动 |
| fluid | 液体 | 流动 |

**sn- 系列：负面/嗅觉/蛇类**

| sn- 词 | 含义 | 共同特征 |
|--------|------|---------|
| sniff | 嗅 | 嗅觉 |
| snore | 打鼾 | 负面/声音 |
| sneak | 偷偷摸摸/鬼祟 | 负面（sneak 可作动词或名词） |
| snake | 蛇 | 蛇形/负面 |
| snarl | 咆哮 | 负面/声音 |
| sniffle | 抽鼻子 | 负面 |
| snide | 讽刺的 | 负面 |

**cr- 系列：力量/挤压/破碎**

| cr- 词 | 含义 | 共同特征 |
|--------|------|---------|
| crash | 撞碎/崩溃 | 力量感（瞬间猛烈撞击导致结构破坏） |
| crush | 压碎 | 力量感 |
| crack | 裂缝 | 力量感 |
| crumble | 崩塌 | 力量感 |
| crisp | 脆的 | 力量感（声音） |
| crawl | 爬行 | 力量感（挤压身体） |
| crave | 渴望 | 强烈欲望 |

**wr- 系列：扭曲/暴力/困扰**

| wr- 词 | 含义 | 共同特征 |
|--------|------|---------|
| writhe | 扭曲 | 扭曲感 |
| wring | 拧 | 扭曲感 |
| wrestle | 摔跤 | 扭曲/斗争 |
| wrench | 猛拧 | 扭曲感 |
| wrangle | 争吵 | 扭曲/争执 |
| wrap | 包裹 | 包围感 |
| wreckage | 残骸 | 破坏感 |
| wrist | 手腕 | 扭曲关节 |

**-ump 韵脚：沉闷/笨重/圆形**

| -ump 词 | 含义 | 共同特征 |
|---------|------|---------|
| bump | 碰撞 | 沉闷 |
| thump | 重击 | 沉闷 |
| lump | 肿块 | 笨重/圆形 |
| dump | 倾倒 | 笨重 |
| clump | 丛 | 笨重/聚集 |
| slump | 衰落 | 沉重/下降 |
| plump | 丰满的 | 圆形/沉重 |
| frump | 衣着老土 | 沉重/负面 |

#### 3.3.21.3 音义感知的教学价值

**价值一：词义推断的辅助工具**

听到一个未知词时，即使不知道具体含义，也能通过音义组合猜出情感方向：

```
学生听到一个新词 "slippery"：
  1. 听到 [sl-] 开头
  2. 联想到 sl- 系列词的共同特征：滑腻/贬义
  3. 猜：这个词可能和"滑"或"负面"有关
  4. 对照语境，确认：slippery = 滑的（确实和"滑"有关）
  
效果：音义感知提供了一层"预判"
     让学习者不再是零基础面对生词
```

**价值二：写作中情感色彩的精确控制**

```
描述一个场景："雨后的路面"

不用音义感知：
  The road was wet. （中性描述）

用音义感知：
  想要滑的感觉 → slippery（sl- 音）
  想要泥泞感 → muddy
  想要光亮感 → glistening

sl- 的音义让学生意识到：
  选词不仅是选意思，也是选声音带来的情感色彩
```

**价值三：减少拼写错误**

```
slip / slap / slipper / slender
  都是 sl- 系列，都有"滑/细"的感觉
  → 对 sl- 词族的整体感知减少了拼写混淆

gr- 系列：grab / grape / grief / graduate
  都是 gr- 系列，都有"力量/抓取"的感觉
  → 对 gr- 词族的整体感知减少了拼写混淆
```

#### 3.3.21.4 其他音义现象

**辅音丛与情感：**

| 音组合 | 情感/语义联想 | 词例 |
|--------|------------|------|
| -ng | 余韵/持续 | long, ring, sing, hang, among |
| -ee | 小/亲昵 | coffee, bootee, nominee |
| -er | 施事/比较 | runner, faster, teacher |
| -le | 动作感 | sparkle, twinkle, trickle |

**拟声词（Onomatopoeia）：**

| 词 | 模拟声音 | 说明 |
|----|---------|------|
| splash | 哗啦 | 水溅声 |
| crash | 砰 | 碰撞声 |
| boom | 隆隆 | 爆炸/雷声 |
| hiss | 嘶嘶 | 气体/蛇声 |
| buzz | 嗡嗡 | 昆虫/机器声 |
| clang | 叮当 | 金属声 |
| drip | 滴答 | 水滴声 |
| rustle | 沙沙 | 纸张/树叶声 |

**拟声词的认知维度**：
- 不同语言对同一声音的拟声词不同（"狗叫"：英语 bow-wow，汉语 汪汪，日语 ワンワン）
- 这说明拟声词也是**理据性**的，但不是普遍的，而是语言特有的

#### 3.3.21.5 韵律音义的产品落地

| 功能 | 韵律音义落地方式 |
|------|----------------|
| 词汇卡片 | 标注音义组合（sl-/gr-/fl-...），展示同系列词 |
| 音义猜词游戏 | 给出音义描述，让学生从多个选项中选出正确的新词 |
| 写作辅助 | 根据情感色彩，提示可选的音义词（想要贬义？试试 sl- 词） |
| 拼写训练 | 以音义组合为单位训练（不是逐词背，而是整组学） |
| 听力理解 | 听到 sl- 词时提醒：这个词可能有负面/滑腻的语义色彩 |

#### 3.3.21.6 韵律音义的数据库落点

- **新建 `phonestheme_groups` 表**：记录音义组合及其语义联想（sl-/gr-/fl-...）
- **扩展 `words` 表**：`phonestheme_code` 字段关联到音义组合分组
- 已有 `phonics_patterns` 表可复用，音义组合与拼读规则是两个不同维度

### 3.4 教学资源分类

| 分类 | 说明 |
|------|------|
| 课程来源 | 课标、教材、产品扩展、试验词 |
| 教材版本 | 地区、出版社、版本、年级、单元、顺序（单元独立成表） |
| 难度 | **固有难度**（义项自身属性）与**课程难度**（某课程要求下的难度）分开记录，各自保留来源 |
| 主题 | 对齐2022课标三大主题群：人与自我/人与社会/人与自然 → 子主题（见附录8.2） |
| 词频 | 锚定 NGSL 波段与 EVP 分级，映射为高/中/低，必须记录来源语料 |
| 先备关系 | 学习该词前需要掌握的词、规则或句型 |
| 内容资源 | 例句、图片、音频、动作、练习素材及其版本；例句标注已知词比例 |

CEFR、年级和词频是不同维度，不互相替代；每个维度必须保留来源和版本。

i+1 落地：例句标注 `known_word_ratio`（学生已掌握词数/总词数），学习路径优先推送 ≥0.95 的例句，保证可理解输入。

### 3.5 各学段学习模式配置

| 学段 | 学习特点 | 推荐内容形式 | 核心学习模式 |
|------|---------|-------------|-------------|
| 小学1-2年级 | 图形化、听说为主、游戏化 | 词块音频、图形词卡、动画 | 词块整体输入、亲子共学 |
| 小学3-4年级 | 简单拼读、基础词汇 | 简单拼读动画、词块运用、跟读 | 词块运用、简单拼读启蒙 |
| 小学5-6年级 | 系统学习、高频后缀 | 高频后缀（-er/-ly/-tion）、搭配学习、拼写 | 词缀启蒙、搭配学习 |
| 初中7-9年级 | 综合运用、构词法、词义辨析 | 系统构词法、词义辨析、完形填空、词块产出 | 词族扩展、构词规则、辨析题 |
| 高中10-12年级 | 学术词汇、CET衔接、写作输出 | 学术词块、高考核心词、CET过渡词、写作搭配 | 学术词块、写作搭配、词义精确辨析 |

注：小学低年级不要求拼写，以听说和词块整体习得为主；系统构词法和词素拆分从初中开始；高中阶段重点在学术词汇和写作输出。

### 3.6 学习证据分类

| 技能 | skill_code | 接受性证据 | 产出性证据 |
|------|------------|------------|------------|
| 形式 | form_recognition / spelling | 看词认读、识别词根词缀 | 拼写、词形变化、组合单词 |
| 声音 | sound_recognition / pronunciation | 听音辨词 | 跟读、发音评测 |
| 意义 | meaning_recall | 看词选义、听词选图 | 无提示回忆义项 |
| 使用 | usage | 句内选择 | 补全或生成句子 |
| 关系 | relation | 识别词族、同反义 | 解释关系或完成构词 |

学习状态不属于单词的静态分类，而是用户针对某个义项和某项技能产生的动态证据。

掌握度冷启动：新用户通过 VKS（Vocabulary Knowledge Scale）五级自评快速定级（1=没见过 → 5=会用），之后由复习数据接管。

FSRS 参数初始值按学段配置：小学阶段稳定性初始值较低（便于频繁复习），高中阶段可适当提高。FSRS 推荐初始 stability=0.1，fsrs_difficulty=4.0，retrievability 由系统根据首次答题结果自动计算。

### 3.7 分类驱动的最小闭环

1. 根据课程和先备关系选取目标义项。
2. 使用发音、词形和释义完成输入与识别。
3. 使用词形、拼读、搭配和句型生成练习。
4. 记录义项级、技能级的正确性、FSRS 评级、提示、信心和反应时间。
5. 由 FSRS 根据记忆状态（stability/difficulty）计算该义项该技能的下一次到期时间。

复杂词源和完整语义网络属于扩展内容，不得替代词义、词形、发音和使用关系。

---

## 四、数据库设计

### 4.1 设计原则

| 原则 | 说明 |
|------|------|
| 高频查询直接字段 | lemma、规范化词条、义项词性和教材映射等高频字段直接存储 |
| 多对多用关联表 | 教材、主题和语言关系使用独立表 |
| 词素独立于词条 | 词根词缀存 morphemes，不进 words，避免污染词表 |
| 计数口径统一 | 词汇量以 lemma 计数，词形/拼写变体不重复计；掌握度统计以 L6 词族为单位 |
| 少用JSON | 复杂结构优先关联表，不用JSON |
| 索引优化 | 高频查询字段建索引；UNIQUE 约束自带索引，不重复建 |
| 支持多用户 | 学习进度关联用户ID |

单词数据采用"词条（lemma）→义项（sense）→词形（form）→关系（relation）"四层结构，词素（morpheme）作为与词条平行的独立维度。
`words` 只保存词条身份，`word_senses` 保存可教学的具体义项；例句、搭配和语言关系统一绑定到义项，避免把一词多义压缩到一个中文释义字段。

### 4.2 数据库实体关系

```text
grade_levels ── textbook_units ── curricula
syntax_frames（句法框架字典）
themes（三大主题群 → 子主题）
morphemes（词素，独立于词条）

words
  ├── word_senses
  │     ├── sense_examples（例句，含已知词比例）
  │     ├── sense_syntax_frames ── syntax_frames
  │     ├── word_collocations
  │     ├── exercise_items ── exercise_options
  │     └── user_sense_skill_progress ── review_records
  ├── word_forms ── word_pronunciations
  ├── word_morphemes ── morphemes
  ├── word_relations（义项之间）
  ├── word_curriculum ── textbook_units / grade_levels
  ├── word_themes ── themes
  └── word_assets ── content_assets

users ── parent_student（家长-学生关联）
users ── user_vks_assessments（VKS 自评定级）

word_phonics ── phonics_patterns
```

这是设计阶段的唯一正式模型。

### 4.3 表结构设计

#### 4.3.1 词条、义项和词形

```sql
CREATE TABLE words (
    id               BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    lemma            TEXT NOT NULL,
    normalized_lemma TEXT NOT NULL,
    word_type        TEXT NOT NULL CHECK(word_type IN ('simple','derived','compound','converted','phrase','chunk')),
    family_level     INTEGER CHECK(family_level BETWEEN 1 AND 6),  -- Bauer & Nation 词族层级，L6=全部词缀
    origin_language  TEXT CHECK(origin_language IN ('germanic','latin','french','greek','loanword','unknown')),
    etymology_story  TEXT,
    content_status   TEXT NOT NULL CHECK(content_status IN ('draft','reviewed','published','withdrawn')),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(normalized_lemma)
);

CREATE TABLE word_senses (
    id                 BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    word_id            BIGINT NOT NULL REFERENCES words(id),
    sense_no           INTEGER NOT NULL CHECK(sense_no > 0),
    meaning_cn         TEXT NOT NULL,
    definition_en      TEXT,
    pos                TEXT NOT NULL CHECK(pos IN ('noun','verb','adjective','adverb','pronoun','preposition','conjunction','determiner','numeral','auxiliary','modal','interjection','particle','phrase')),
    register           TEXT NOT NULL CHECK(register IN ('formal','neutral','informal','slang')),
    countability       TEXT CHECK(countability IN ('countable','uncountable','both','not_applicable')),
    transitivity       TEXT CHECK(transitivity IN ('transitive','intransitive','both','not_applicable')),
    inherent_difficulty TEXT CHECK(inherent_difficulty IN ('low','medium','high')),  -- 义项固有难度
    cognitive_load     TEXT CHECK(cognitive_load IN ('low','medium','high')),  -- 认知负荷（加工难度），独立于 inherent_difficulty
    is_primary         BOOLEAN NOT NULL DEFAULT FALSE,
    usage_note         TEXT,
    source_version     TEXT NOT NULL,
    review_status      TEXT NOT NULL CHECK(review_status IN ('draft','reviewed','published','withdrawn')),
    UNIQUE(word_id, sense_no),
    UNIQUE(word_id, id)  -- 超键：供组合外键强制 sense 必须属于该 word，勿删
);

CREATE TABLE word_forms (
    id               BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    word_id          BIGINT NOT NULL REFERENCES words(id),
    form             TEXT NOT NULL,
    form_type        TEXT NOT NULL CHECK(form_type IN ('base','plural','possessive','third_person','past','past_participle','present_participle','comparative','superlative','variant','phrasal')),
    spelling_rule    TEXT,
    is_irregular     BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(word_id, form, form_type),
    UNIQUE(word_id, id)  -- 超键：供组合外键使用，勿删
);

-- 例句独立成表：一个义项多条例句，可挂音频，标注已知词比例
CREATE TABLE sense_examples (
    id               BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    sense_id         BIGINT NOT NULL REFERENCES word_senses(id),
    sentence_en      TEXT NOT NULL,
    sentence_cn      TEXT,
    known_word_ratio NUMERIC(4,3) CHECK(known_word_ratio BETWEEN 0 AND 1),  -- i+1 可理解输入指标
    difficulty       TEXT CHECK(difficulty IN ('low','medium','high')),
    audio_asset_id   BIGINT REFERENCES content_assets(id),
    source_version   TEXT NOT NULL,
    review_status    TEXT NOT NULL CHECK(review_status IN ('draft','reviewed','published','withdrawn')),
    UNIQUE(sense_id, sentence_en)
);
```

#### 4.3.2 词素（新增）

```sql
CREATE TABLE morphemes (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    form            TEXT NOT NULL,          -- un / act / -ject-
    morph_type      TEXT NOT NULL CHECK(morph_type IN ('root','bound_root','prefix','suffix')),
    meaning_cn      TEXT NOT NULL,
    allomorph_of    BIGINT REFERENCES morphemes(id),  -- im-/in-/il- 归并到主词素
    productivity    TEXT CHECK(productivity IN ('high','medium','low')),
    grade_introduce TEXT REFERENCES grade_levels(grade_code),  -- 建议引入学段
    source_version  TEXT NOT NULL,
    UNIQUE(form, morph_type)
);

CREATE TABLE word_morphemes (
    word_id      BIGINT NOT NULL REFERENCES words(id),
    morpheme_id  BIGINT NOT NULL REFERENCES morphemes(id),
    position_no  INTEGER NOT NULL CHECK(position_no > 0),
    surface_form TEXT NOT NULL,             -- 词素在该词中的实际拼写片段
    PRIMARY KEY(word_id, position_no),
    UNIQUE(word_id, morpheme_id, position_no)
);
```

#### 4.3.3 发音与自然拼读

```sql
CREATE TABLE content_assets (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    asset_type      TEXT NOT NULL CHECK(asset_type IN ('audio','image','animation')),
    asset_uri       TEXT NOT NULL,
    checksum        TEXT NOT NULL,
    license_note    TEXT,
    review_status   TEXT NOT NULL CHECK(review_status IN ('draft','reviewed','published','withdrawn')),
    UNIQUE(checksum)
);

CREATE TABLE word_assets (
    word_id         BIGINT NOT NULL REFERENCES words(id),
    sense_id        BIGINT NOT NULL REFERENCES word_senses(id),
    asset_id        BIGINT NOT NULL REFERENCES content_assets(id),
    purpose         TEXT NOT NULL CHECK(purpose IN ('pronunciation','meaning','example','phonics')),
    PRIMARY KEY(word_id, sense_id, asset_id, purpose),
    FOREIGN KEY(word_id, sense_id) REFERENCES word_senses(word_id, id)
);

CREATE TABLE word_pronunciations (
    id               BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    word_id          BIGINT NOT NULL REFERENCES words(id),
    form_id          BIGINT NOT NULL REFERENCES word_forms(id),
    dialect          TEXT NOT NULL CHECK(dialect IN ('us','uk','other')),
    ipa              TEXT NOT NULL,
    phoneme_sequence TEXT,
    syllables        TEXT NOT NULL,
    syllable_count   INTEGER NOT NULL CHECK(syllable_count > 0),
    stress_pattern   TEXT,
    audio_asset_id   BIGINT REFERENCES content_assets(id),
    is_primary       BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE(form_id, dialect, ipa),
    FOREIGN KEY(word_id, form_id) REFERENCES word_forms(word_id, id)
);

CREATE TABLE phonics_patterns (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    pattern         TEXT NOT NULL,
    pattern_type    TEXT NOT NULL CHECK(pattern_type IN ('consonant','vowel','r_controlled','silent_letter','exception')),
    pronunciation   TEXT NOT NULL,
    rule_text       TEXT NOT NULL,
    grade_level     TEXT REFERENCES grade_levels(grade_code),
    UNIQUE(pattern, pronunciation)
);

CREATE TABLE word_phonics (
    form_id         BIGINT NOT NULL REFERENCES word_forms(id),
    pattern_id      BIGINT NOT NULL REFERENCES phonics_patterns(id),
    position_no     INTEGER NOT NULL CHECK(position_no > 0),
    evidence_note   TEXT,
    PRIMARY KEY(form_id, pattern_id, position_no)
);
```

#### 4.3.4 年级、教材、主题和语言关系

```sql
-- 年级维表：替代 TEXT + LIKE 'junior%' 的脆弱写法
CREATE TABLE grade_levels (
    grade_code  TEXT PRIMARY KEY,   -- preparatory_1/2, primary_1..6, junior_1..3, senior_1..3
    stage       TEXT NOT NULL CHECK(stage IN ('preparatory','primary','junior','senior')),
    sort_no     INTEGER NOT NULL UNIQUE
);

CREATE TABLE curricula (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    source_type     TEXT NOT NULL CHECK(source_type IN ('standard','textbook','product_extension','pilot')),
    source_name     TEXT NOT NULL,
    version         TEXT NOT NULL,
    region          TEXT,
    UNIQUE(source_type, source_name, version, region)
);

-- 教材单元独立成表
CREATE TABLE textbook_units (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    curriculum_id   BIGINT NOT NULL REFERENCES curricula(id),
    grade_level     TEXT NOT NULL REFERENCES grade_levels(grade_code),
    unit_code       TEXT NOT NULL,
    unit_title      TEXT,
    theme_id        BIGINT REFERENCES themes(id),
    sort_no         INTEGER,
    UNIQUE(curriculum_id, grade_level, unit_code)
);

CREATE TABLE word_curriculum (
    id               BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    word_id          BIGINT NOT NULL REFERENCES words(id),
    sense_id         BIGINT NOT NULL REFERENCES word_senses(id),
    unit_id          BIGINT NOT NULL REFERENCES textbook_units(id),
    grade_level      TEXT NOT NULL REFERENCES grade_levels(grade_code),
    order_no         INTEGER,
    cefr_level       TEXT CHECK(cefr_level IN ('A1','A2','B1','B2','C1','C2')),
    frequency_level  TEXT CHECK(frequency_level IN ('high','medium','low')),
    frequency_source TEXT,          -- 词频来源语料：NGSL / EVP / 自建教材语料
    difficulty_level TEXT CHECK(difficulty_level IN ('low','medium','high')),  -- 课程难度
    required_level   TEXT CHECK(required_level IN ('recognize','understand','produce')),
    UNIQUE(word_id, sense_id, unit_id),
    FOREIGN KEY(word_id, sense_id) REFERENCES word_senses(word_id, id)
);

-- 主题：对齐2022课标三大主题群
CREATE TABLE themes (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    theme_code      TEXT NOT NULL,
    theme_name_cn   TEXT NOT NULL,
    theme_group     TEXT NOT NULL CHECK(theme_group IN ('self','society','nature')),  -- 人与自我/人与社会/人与自然
    parent_id       BIGINT REFERENCES themes(id),
    version         TEXT NOT NULL,
    UNIQUE(theme_code, version)
);

CREATE TABLE word_themes (
    word_id         BIGINT NOT NULL REFERENCES words(id),
    sense_id        BIGINT NOT NULL REFERENCES word_senses(id),
    theme_id        BIGINT NOT NULL REFERENCES themes(id),
    PRIMARY KEY(word_id, sense_id, theme_id),
    FOREIGN KEY(word_id, sense_id) REFERENCES word_senses(word_id, id)
);

-- 语言关系：词素关系由 morphemes 表表达，不在此表
-- 派生(derived)和复合(compound)由 words.word_type 提供，不在此表冗余存储
-- 约定：hypernym 只存 source=下位词 → target=上位词，hyponym 查询反推，不重复存储
-- 同字母组合、同发音模式、同拼写模式分别由 phonics_patterns 和 word_mistakes 表承载
CREATE TABLE word_relations (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    source_word_id  BIGINT NOT NULL REFERENCES words(id),
    target_word_id  BIGINT NOT NULL REFERENCES words(id),
    source_sense_id BIGINT NOT NULL REFERENCES word_senses(id),
    target_sense_id BIGINT NOT NULL REFERENCES word_senses(id),
    relation_type   TEXT NOT NULL CHECK(relation_type IN ('synonym','antonym','hypernym','meronym','confusable')),  -- derived/compound 由 words.word_type 提供；v1.5 扩展类型见 4.3.7.8 节 word_relations_v2
    direction       TEXT NOT NULL CHECK(direction IN ('symmetric','one_way','directed')),  -- symmetric=同义反义; one_way=上下位; directed=搭配
    confusable_type TEXT CHECK(confusable_type IN ('spelling','sound','meaning','l1_transfer')),  -- 仅 relation_type='confusable' 时必填
    evidence_source TEXT NOT NULL,
    explanation     TEXT,
    UNIQUE(source_word_id, target_word_id, source_sense_id, target_sense_id, relation_type),
    FOREIGN KEY(source_word_id, source_sense_id) REFERENCES word_senses(word_id, id),
    FOREIGN KEY(target_word_id, target_sense_id) REFERENCES word_senses(word_id, id)
);

-- 句法框架字典表
CREATE TABLE syntax_frames (
    frame_code  TEXT PRIMARY KEY,   -- SVO / V+that-clause / Adj+to-infinitive ...
    pattern     TEXT NOT NULL,      -- "Verb + that-clause"
    description TEXT,               -- 框架说明
    examples    TEXT,               -- 框架示例句
    UNIQUE(pattern)
);

CREATE TABLE sense_syntax_frames (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    sense_id        BIGINT NOT NULL REFERENCES word_senses(id),
    frame_code      TEXT NOT NULL REFERENCES syntax_frames(frame_code),
    example         TEXT,
    UNIQUE(sense_id, frame_code)
);

CREATE TABLE word_collocations (
    id                  BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    sense_id            BIGINT NOT NULL REFERENCES word_senses(id),
    collocation         TEXT NOT NULL,
    coll_type           TEXT NOT NULL CHECK(coll_type IN ('verb_object','adjective_noun','noun_noun','preposition','phrasal_verb','sentence_frame','other')),  -- v1.5 扩展为 9 种，见 4.3.7.8 节 word_collocations_v2
    complement_pattern  TEXT,
    example             TEXT NOT NULL,
    example_cn          TEXT,
    source_version      TEXT NOT NULL,
    UNIQUE(sense_id, collocation)
);

CREATE TABLE word_mistakes (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    sense_id        BIGINT REFERENCES word_senses(id),
    mistake_type    TEXT NOT NULL CHECK(mistake_type IN ('spelling','pronunciation','meaning','collocation','grammar')),
    wrong_form      TEXT NOT NULL,
    explanation     TEXT NOT NULL,
    UNIQUE(sense_id, mistake_type, wrong_form)
);
```

#### 4.3.5 题目（新增）

```sql
CREATE TABLE exercise_items (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    sense_id        BIGINT NOT NULL REFERENCES word_senses(id),
    skill_code      TEXT NOT NULL CHECK(skill_code IN ('form_recognition','sound_recognition','spelling','pronunciation','meaning_recall','usage','relation')),
    exercise_type   TEXT NOT NULL CHECK(exercise_type IN ('choice','spelling','listening','pronunciation','sentence','relation')),
    stem            TEXT NOT NULL,          -- 题干
    example_id      BIGINT REFERENCES sense_examples(id),
    audio_asset_id  BIGINT REFERENCES content_assets(id),
    difficulty      TEXT CHECK(difficulty IN ('low','medium','high')),
    review_status   TEXT NOT NULL CHECK(review_status IN ('draft','reviewed','published','withdrawn')),
    UNIQUE(sense_id, skill_code, exercise_type, stem)
);

CREATE TABLE exercise_options (
    item_id     BIGINT NOT NULL REFERENCES exercise_items(id),
    option_no   INTEGER NOT NULL CHECK(option_no > 0),
    option_text TEXT NOT NULL,
    is_correct  BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY(item_id, option_no)
);
```

#### 4.3.6 用户与学习证据

```sql
CREATE TABLE users (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    username        TEXT NOT NULL UNIQUE,
    password_hash   TEXT,
    phone           TEXT UNIQUE,
    role            TEXT NOT NULL DEFAULT 'student' CHECK(role IN ('student','parent','teacher','admin')),
    grade_level     TEXT REFERENCES grade_levels(grade_code),
    target_cefr     TEXT CHECK(target_cefr IN ('A1','A2','B1','B2','C1','C2')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 家长-学生关联（支撑家长端）
CREATE TABLE parent_student (
    parent_id   BIGINT NOT NULL REFERENCES users(id),
    student_id  BIGINT NOT NULL REFERENCES users(id),
    relation    TEXT NOT NULL CHECK(relation IN ('father','mother','guardian','other')),
    PRIMARY KEY(parent_id, student_id)
);

-- VKS 五级自评：新用户掌握度冷启动
CREATE TABLE user_vks_assessments (
    id          BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(id),
    sense_id    BIGINT NOT NULL REFERENCES word_senses(id),
    vks_level   INTEGER NOT NULL CHECK(vks_level BETWEEN 1 AND 5),  -- 1=没见过 2=见过 3=能回忆 4=认识不会用 5=会用
    assessed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, sense_id)
);

-- 学习进度：FSRS 记忆状态模型
CREATE TABLE user_sense_skill_progress (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id),
    sense_id        BIGINT NOT NULL REFERENCES word_senses(id),

    skill_code      TEXT NOT NULL CHECK(skill_code IN ('form_recognition','sound_recognition','spelling','pronunciation','meaning_recall','usage','relation')),
    status          TEXT NOT NULL DEFAULT 'unknown' CHECK(status IN ('unknown','learning','review','mastered','forgotten')),

    mastery_score   INTEGER NOT NULL DEFAULT 0 CHECK(mastery_score BETWEEN 0 AND 100),

    last_reviewed_at TIMESTAMPTZ,
    due_at          TIMESTAMPTZ,
    review_count   INTEGER NOT NULL DEFAULT 0 CHECK(review_count >= 0),
    correct_count  INTEGER NOT NULL DEFAULT 0 CHECK(correct_count >= 0),
    wrong_count    INTEGER NOT NULL DEFAULT 0 CHECK(wrong_count >= 0),

    -- FSRS 三参数记忆状态（替代 SM-2 的 interval_days/ease_factor）
    stability       NUMERIC(8,3) NOT NULL DEFAULT 0 CHECK(stability >= 0),        -- 记忆稳定性（天，浮点，支持分钟级）
    fsrs_difficulty NUMERIC(4,2) CHECK(fsrs_difficulty BETWEEN 1 AND 10),          -- FSRS 难度 1-10
    retrievability  NUMERIC(5,4) CHECK(retrievability BETWEEN 0 AND 1),            -- 当前可提取性
    scheduler_version TEXT NOT NULL,

    UNIQUE(user_id, sense_id, skill_code),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE review_records (
    id                BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    progress_id       BIGINT NOT NULL REFERENCES user_sense_skill_progress(id),
    exercise_item_id  BIGINT REFERENCES exercise_items(id),  -- 错题可归因到具体题目
    reviewed_at       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    result            TEXT NOT NULL CHECK(result IN ('correct','wrong','hesitate','skipped')),
    fsrs_rating       TEXT CHECK(fsrs_rating IN ('again','hard','good','easy')),
    response_time_ms  INTEGER CHECK(response_time_ms >= 0),
    confidence        INTEGER CHECK(confidence BETWEEN 1 AND 5),
    hint_used         BOOLEAN NOT NULL DEFAULT FALSE,
    exercise_type     TEXT NOT NULL CHECK(exercise_type IN ('choice','spelling','listening','pronunciation','sentence','relation')),
    algorithm_version TEXT NOT NULL,
    client_event_id   TEXT NOT NULL UNIQUE
);
```

### 4.3.7 理解深度模型 — 新增 3.3.17 节四阶段理解模型（L1-L5加工深度/四象限/三维整合）
| 场景语义学 — 新增 3.3.18 节词义理解核心：每个词描述一个场景，场景要素替换驱动词义延伸

> 以下表结构由架构师子 agent 分析设计，覆盖新增 17 个维度的存储方案。

#### 4.3.7.1 句法框架字典（syntax_frames）——前置依赖表

已有 `sense_syntax_frames` 关联到具体义项，此表为独立框架字典。
表结构定义见 4.3.4 节；以下为常用框架数据示例：

```sql
-- 常用框架数据示例（syntax_frames 表，见 4.3.4）
INSERT INTO syntax_frames (frame_code, pattern, description, examples) VALUES
('V+that',   'Verb + that-clause',          '部分动词后接 that 宾语从句',  'believe/think/suggest/expect + that ...'),
('V+O+to',   'Verb + Object + to-infinitive','动词+宾语+to不定式',         'want/ask/tell/remind + sb. + to do'),
('Adj+to',   'Adjective + to-infinitive',    '形容词+to不定式结构',          'glad/happy/ready/sure + to ...'),
('N+that',   'Noun + that-clause',           '名词+that从句',               'fact/idea/news/hope + that ...'),
('V+prep+V-ing','Verb + Preposition + V-ing', '动词+介词+V-ing',             'think of / look forward to / insist on ...');
```

#### 4.3.7.2 同句法结构词对（same_syntax_frames）

同一 `frame_code` 下的词归为一组，支撑句型生成和语法辨析题：

```sql
CREATE TABLE same_syntax_frames (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    frame_code      TEXT NOT NULL REFERENCES syntax_frames(frame_code),
    source_word_id  BIGINT NOT NULL REFERENCES words(id),
    target_word_id  BIGINT NOT NULL REFERENCES words(id),
    source_sense_id BIGINT REFERENCES word_senses(id),
    target_sense_id BIGINT REFERENCES word_senses(id),
    explanation     TEXT,
    UNIQUE(source_word_id, target_word_id, frame_code)
);

CREATE INDEX idx_ssf_frame ON same_syntax_frames(frame_code);
CREATE INDEX idx_ssf_source ON same_syntax_frames(source_word_id);
CREATE INDEX idx_ssf_target ON same_syntax_frames(target_word_id);
```

#### 4.3.7.3 隐喻框架（metaphor_frames + word_metaphors）

概念隐喻框架（Lakoff & Johnson），支撑深层语义理解：

```sql
CREATE TABLE metaphor_frames (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    frame_code      TEXT NOT NULL UNIQUE,
    frame_name      TEXT NOT NULL,         -- "TIME IS MONEY"
    source_domain   TEXT NOT NULL,         -- "TIME"
    target_domain   TEXT NOT NULL,         -- "MONEY"
    explanation     TEXT NOT NULL,
    example         TEXT,
    UNIQUE(source_domain, target_domain)
);

-- 常用隐喻框架数据示例
INSERT INTO metaphor_frames (frame_code, frame_name, source_domain, target_domain, explanation, example) VALUES
('TIME_MONEY',    'TIME IS MONEY',        'TIME',     'MONEY',     '时间被概念化为金钱，可花费、投资、浪费、节省',         'spend time / waste time / invest time / save time'),
('LOVE_JOURNEY',  'LOVE IS A JOURNEY',   'LOVE',     'JOURNEY',   '爱情被概念化为旅行，有起点、终点、障碍',             'our relationship hit a dead end / it''s a long road ahead'),
('ARGUMENT_WAR',  'ARGUMENT IS WAR',     'ARGUMENT', 'WAR',       '争论被概念化为战争，有进攻、防守、失败',             'I defended my position / she shot down my proposal'),
('MIND_MACHINE',  'THE MIND IS A MACHINE','MIND',     'MACHINE',   '心智被概念化为机器，有运转、卡住、磨损状态',         'mind grinding away / mental gears not working'),
('IDEAS_FOOD',    'IDEAS ARE FOOD',       'IDEAS',    'FOOD',      '想法被概念化为食物，有消化、品尝、品尝/变质',       'digest an idea / food for thought / half-baked idea');

CREATE TABLE word_metaphors (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    word_id         BIGINT NOT NULL REFERENCES words(id),
    sense_id        BIGINT NOT NULL REFERENCES word_senses(id),
    frame_id        BIGINT NOT NULL REFERENCES metaphor_frames(id),
    role_in_frame   TEXT NOT NULL CHECK(role_in_frame IN ('source','target','modifier')),
    example         TEXT,
    UNIQUE(word_id, sense_id, frame_id, role_in_frame),
    FOREIGN KEY(word_id, sense_id) REFERENCES word_senses(word_id, id)
);

CREATE INDEX idx_wm_word ON word_metaphors(word_id);
CREATE INDEX idx_wm_frame ON word_metaphors(frame_id);
CREATE INDEX idx_wm_sense ON word_metaphors(sense_id);
```

#### 4.3.7.4 义项间语义关系（sense_relations）——多义派生链

同一词不同义项之间的语义延伸路径（辐射型/连锁型）：

```sql
CREATE TABLE sense_relations (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    source_sense_id BIGINT NOT NULL REFERENCES word_senses(id),
    target_sense_id BIGINT NOT NULL REFERENCES word_senses(id),
    relation_type   TEXT NOT NULL CHECK(relation_type IN ('polysemy_chain','metaphorical_ext','specialization','generalization')),
    polysemy_type   TEXT CHECK(polysemy_type IN ('radiation','chaining','both')),
    explanation     TEXT,
    UNIQUE(source_sense_id, target_sense_id, relation_type)
);

-- polysemy_chain：多义派生链（辐射型：核心义→各衍生义；连锁型：义项依次延伸）
-- metaphorical_ext：隐喻延伸（literal→metaphorical）
-- specialization：语义的专门化（broad→narrow）
-- generalization：语义的一般化（narrow→broad）

CREATE INDEX idx_sr_source ON sense_relations(source_sense_id, relation_type);
CREATE INDEX idx_sr_target ON sense_relations(target_sense_id);
```

#### 4.3.7.5 情感色彩组（connotation_groups + word_connotation_group）

同一情感色彩的词归组，便于批量辨析和写作选词：

```sql
CREATE TABLE connotation_groups (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    connotation     TEXT NOT NULL CHECK(connotation IN ('positive','negative','neutral')),
    group_label     TEXT NOT NULL,         -- "size_positive_large" / "intelligence_positive"
    description     TEXT,
    source_version  TEXT DEFAULT 'v1.0',
    UNIQUE(connotation, group_label)
);

-- 常用情感色彩组数据示例
INSERT INTO connotation_groups (connotation, group_label, description) VALUES
('positive', 'size_positive_large',  '表示"大"的褒义词'),
('negative', 'size_negative_large',  '表示"大"的贬义词'),
('positive', 'intelligence_positive', '表示"聪明"的褒义词'),
('negative', 'intelligence_negative', '表示"笨"的贬义词'),
('neutral',  'size_neutral',         '表示"大/小"的中性词');

CREATE TABLE word_connotation_group (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    word_id         BIGINT NOT NULL REFERENCES words(id),
    sense_id        BIGINT NOT NULL REFERENCES word_senses(id),
    group_id        BIGINT NOT NULL REFERENCES connotation_groups(id),
    nuance_note     TEXT,                 -- 细微差别说明
    UNIQUE(word_id, sense_id, group_id),
    FOREIGN KEY(word_id, sense_id) REFERENCES word_senses(word_id, id)
);

CREATE INDEX idx_wcg_word ON word_connotation_group(word_id);
CREATE INDEX idx_wcg_group ON word_connotation_group(group_id);
CREATE INDEX idx_wcg_sense ON word_connotation_group(sense_id);
```

#### 4.3.7.6 主题词簇（topic_clusters + word_topic_clusters）——同主题语境

同一情境下高频共现的词，用于情境化学习和写作话题词汇：

```sql
CREATE TABLE topic_clusters (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    cluster_name    TEXT NOT NULL,         -- "healthcare" / "school_life"
    theme_group     TEXT CHECK(theme_group IN ('self','society','nature')),
    description     TEXT,
    source_version  TEXT NOT NULL,
    UNIQUE(cluster_name, source_version)
);

CREATE TABLE word_topic_clusters (
    id                  BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    word_id             BIGINT NOT NULL REFERENCES words(id),
    sense_id            BIGINT NOT NULL REFERENCES word_senses(id),
    cluster_id          BIGINT NOT NULL REFERENCES topic_clusters(id),
    co_occurrence_weight NUMERIC(5,4) CHECK(co_occurrence_weight BETWEEN 0 AND 1),  -- 共现权重
    UNIQUE(word_id, sense_id, cluster_id),
    FOREIGN KEY(word_id, sense_id) REFERENCES word_senses(word_id, id)
);

CREATE INDEX idx_wtc_word ON word_topic_clusters(word_id);
CREATE INDEX idx_wtc_cluster ON word_topic_clusters(cluster_id);
```

#### 4.3.7.7 学习先备关系（prerequisite_groups + word_prerequisites）——同学习先备

同一前置要求（先掌握的词、规则或句型）的词，构建学习路径依赖图：

```sql
CREATE TABLE prerequisite_groups (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    prereq_type     TEXT NOT NULL CHECK(prereq_type IN ('vocabulary','rule','syntax','phonics')),
    prereq_code     TEXT NOT NULL,         -- "basic-light" / "suffix-tion" / "there-be"
    description     TEXT,
    source_version  TEXT NOT NULL,
    UNIQUE(prereq_type, prereq_code, source_version)
);

CREATE TABLE word_prerequisites (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    word_id         BIGINT NOT NULL REFERENCES words(id),
    sense_id        BIGINT NOT NULL REFERENCES word_senses(id),
    prereq_group_id BIGINT NOT NULL REFERENCES prerequisite_groups(id),
    is_required     BOOLEAN NOT NULL DEFAULT TRUE,  -- TRUE=必须先掌握，FALSE=建议先掌握
    UNIQUE(word_id, sense_id, prereq_group_id),
    FOREIGN KEY(word_id, sense_id) REFERENCES word_senses(word_id, id)
);

CREATE INDEX idx_wp_word ON word_prerequisites(word_id);
CREATE INDEX idx_wp_prereq ON word_prerequisites(prereq_group_id);
```

#### 4.3.7.8 现有表扩展（ALTER）

以下变更在保持历史数据兼容的前提下扩展现有表：

**word_relations 扩展**（relation_type 扩展 + 新增字段）：

```sql
-- SQLite 重建表迁移方案（SQLite 不支持 DROP CONSTRAINT）
-- 1. 创建新表（含新增字段和扩展的 CHECK 约束）
CREATE TABLE word_relations_v2 (
    id              BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    source_word_id  BIGINT NOT NULL REFERENCES words(id),
    target_word_id  BIGINT NOT NULL REFERENCES words(id),
    source_sense_id BIGINT NOT NULL REFERENCES word_senses(id),
    target_sense_id BIGINT NOT NULL REFERENCES word_senses(id),
    relation_type   TEXT NOT NULL CHECK(relation_type IN (
        'synonym','antonym','hypernym','meronym','holonym',
        'confusable','regional_variant','false_friend',
        'same_syntax','back_derived',
        'same_root','same_suffix','homophone'
    )),
    direction       TEXT NOT NULL CHECK(direction IN ('symmetric','one_way','directed')),
    confusable_type TEXT CHECK(confusable_type IN ('spelling','sound','meaning','l1_transfer')),
    dialect_pair    TEXT CHECK(dialect_pair IN ('us_uk','us_au','uk_au','other')),  -- 新增：区域变体对
    l1_pair         TEXT CHECK(l1_pair IN ('zh_en','ja_en','fr_en','de_en','other')), -- 新增：假朋友语言对
    frame_code      TEXT REFERENCES syntax_frames(frame_code),  -- 新增：同句法结构框架码
    evidence_source TEXT NOT NULL,
    explanation     TEXT,
    UNIQUE(source_word_id, target_word_id, source_sense_id, target_sense_id, relation_type),
    FOREIGN KEY(source_word_id, source_sense_id) REFERENCES word_senses(word_id, id),
    FOREIGN KEY(target_word_id, target_sense_id) REFERENCES word_senses(word_id, id)
);

-- 2. 迁移数据（原有 7 种 relation_type 全部兼容）
INSERT INTO word_relations_v2
    (id, source_word_id, target_word_id, source_sense_id, target_sense_id,
     relation_type, direction, confusable_type, evidence_source, explanation)
SELECT id, source_word_id, target_word_id, source_sense_id, target_sense_id,
       relation_type, direction, confusable_type, evidence_source, explanation
FROM word_relations;

-- 3. 替换旧表
DROP TABLE word_relations;
ALTER TABLE word_relations_v2 RENAME TO word_relations;

-- 4. 重建索引
CREATE INDEX idx_relations_source ON word_relations(source_word_id, relation_type);
CREATE INDEX idx_relations_target ON word_relations(target_word_id, relation_type);
```

**word_senses 扩展**（新增 connotation 字段）：

```sql
ALTER TABLE word_senses
ADD COLUMN connotation TEXT CHECK(connotation IN ('positive','negative','neutral'));
```

**word_collocations 扩展**（新增 coll_type 值）：

```sql
-- 重建表迁移方案
CREATE TABLE word_collocations_v2 (
    id                  BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    sense_id            BIGINT NOT NULL REFERENCES word_senses(id),
    collocation         TEXT NOT NULL,
    coll_type           TEXT NOT NULL CHECK(coll_type IN (
        'verb_object','adjective_noun','noun_noun','preposition',
        'phrasal_verb','sentence_frame','prepositional_verb',  -- prepositional_verb 新增
        'adverb_verb',  -- adverb_verb 新增
        'other'
    )),
    complement_pattern  TEXT,
    example             TEXT NOT NULL,
    example_cn          TEXT,
    source_version      TEXT NOT NULL,
    UNIQUE(sense_id, collocation)
);

INSERT INTO word_collocations_v2
    (id, sense_id, collocation, coll_type, complement_pattern, example, example_cn, source_version)
SELECT id, sense_id, collocation, coll_type, complement_pattern, example, example_cn, source_version
FROM word_collocations;

DROP TABLE word_collocations;
ALTER TABLE word_collocations_v2 RENAME TO word_collocations;

CREATE INDEX idx_collocations_sense ON word_collocations(sense_id);
```

#### 4.3.7.9 新增索引

新增表对应的索引，在建表语句中已包含；此外需在 4.4 索引设计节补充：

```sql
CREATE INDEX idx_srf_frame ON sense_relations(source_sense_id, relation_type);
CREATE INDEX idx_srf_target ON sense_relations(target_sense_id);
CREATE INDEX idx_wcg_word ON word_connotation_group(word_id);
CREATE INDEX idx_wcg_group ON word_connotation_group(group_id);
CREATE INDEX idx_wcg_sense ON word_connotation_group(sense_id);
CREATE INDEX idx_wtc_word ON word_topic_clusters(word_id);
CREATE INDEX idx_wtc_cluster ON word_topic_clusters(cluster_id);
CREATE INDEX idx_wp_word ON word_prerequisites(word_id);
CREATE INDEX idx_wp_prereq ON word_prerequisites(prereq_group_id);
```

### 4.4 索引设计

UNIQUE 约束（normalized_lemma、username、phone、checksum、phonics_patterns(pattern,pronunciation)、morphemes(form,morph_type)）由数据库自动建索引，不重复创建。

```sql
CREATE INDEX idx_senses_word ON word_senses(word_id);
CREATE INDEX idx_senses_pos ON word_senses(pos);
CREATE INDEX idx_forms_word ON word_forms(word_id);
CREATE INDEX idx_pronunciations_word ON word_pronunciations(word_id);
CREATE INDEX idx_examples_sense ON sense_examples(sense_id);
CREATE INDEX idx_word_assets_sense ON word_assets(sense_id);
CREATE INDEX idx_word_phonics_pattern ON word_phonics(pattern_id);
CREATE INDEX idx_word_morphemes_morpheme ON word_morphemes(morpheme_id);
CREATE INDEX idx_curriculum_grade ON word_curriculum(grade_level, unit_id, order_no);
CREATE INDEX idx_theme ON word_themes(theme_id);
CREATE INDEX idx_relations_source ON word_relations(source_word_id, relation_type);
CREATE INDEX idx_relations_target ON word_relations(target_word_id, relation_type);
CREATE INDEX idx_collocations_sense ON word_collocations(sense_id);
CREATE INDEX idx_exercise_sense ON exercise_items(sense_id, skill_code);
CREATE INDEX idx_progress_due ON user_sense_skill_progress(user_id, due_at, status);
CREATE INDEX idx_review_progress_time ON review_records(progress_id, reviewed_at);
-- v1.5 新增维度表索引
CREATE INDEX idx_srf_source ON sense_relations(source_sense_id, relation_type);
CREATE INDEX idx_srf_target ON sense_relations(target_sense_id);
CREATE INDEX idx_wcg_word ON word_connotation_group(word_id);
CREATE INDEX idx_wcg_group ON word_connotation_group(group_id);
CREATE INDEX idx_wcg_sense ON word_connotation_group(sense_id);
CREATE INDEX idx_wtc_word ON word_topic_clusters(word_id);
CREATE INDEX idx_wtc_cluster ON word_topic_clusters(cluster_id);
CREATE INDEX idx_wp_word ON word_prerequisites(word_id);
CREATE INDEX idx_wp_prereq ON word_prerequisites(prereq_group_id);
CREATE INDEX idx_wm_word ON word_metaphors(word_id);
CREATE INDEX idx_wm_frame ON word_metaphors(frame_id);
CREATE INDEX idx_wm_sense ON word_metaphors(sense_id);
CREATE INDEX idx_ssf_frame ON same_syntax_frames(frame_code);
CREATE INDEX idx_ssf_source ON same_syntax_frames(source_word_id);
CREATE INDEX idx_ssf_target ON same_syntax_frames(target_word_id);
```

### 4.5 典型查询示例

```sql
-- 查询某教材初中阶段、动物下位词、名词义项（上下位网络替代原语义场查询）
SELECT w.lemma, s.meaning_cn, s.pos
FROM words w
JOIN word_senses s ON s.word_id = w.id
JOIN word_curriculum wc ON wc.word_id = w.id AND wc.sense_id = s.id
JOIN grade_levels g ON g.grade_code = wc.grade_level
JOIN word_relations r ON r.source_sense_id = s.id AND r.relation_type = 'hypernym'
JOIN word_senses parent_sense ON parent_sense.id = r.target_sense_id
JOIN words parent ON parent.id = parent_sense.word_id
WHERE g.stage = 'junior'
  AND parent.normalized_lemma = 'animal'
  AND s.pos = 'noun';

-- 查询包含词根 act 的所有词及构词位置（词素表支撑"组合单词"题型）
SELECT w.lemma, wm.position_no, m.form, m.morph_type, wm.surface_form
FROM word_morphemes wm
JOIN morphemes m ON m.id = wm.morpheme_id
JOIN words w ON w.id = wm.word_id
WHERE m.form = 'act'
  AND m.morph_type = 'root'
ORDER BY w.lemma, wm.position_no;

-- 查询某用户当前到期的单词技能（FSRS 调度）
SELECT w.lemma, s.meaning_cn, p.skill_code, p.due_at, p.retrievability
FROM user_sense_skill_progress p
JOIN word_senses s ON s.id = p.sense_id
JOIN words w ON w.id = s.word_id
WHERE p.user_id = :user_id
  AND p.status IN ('learning', 'review')
  AND p.due_at <= CURRENT_TIMESTAMP
ORDER BY p.due_at
LIMIT 20;

-- 查询某义项已知词比例达标的例句（i+1 可理解输入）
SELECT sentence_en, sentence_cn, known_word_ratio
FROM sense_examples
WHERE sense_id = :sense_id
  AND known_word_ratio >= 0.95
  AND review_status = 'published'
ORDER BY known_word_ratio;

-- 查询某义项的搭配
SELECT w.lemma, c.collocation, c.example
FROM word_collocations c
JOIN word_senses s ON s.id = c.sense_id
JOIN words w ON w.id = s.word_id
WHERE s.id = :sense_id;

-- 查询同义义项
SELECT target.lemma, target_sense.meaning_cn
FROM word_relations r
JOIN words target ON target.id = r.target_word_id
JOIN word_senses target_sense ON target_sense.id = r.target_sense_id
WHERE r.source_sense_id = :sense_id
  AND r.relation_type = 'synonym';

-- 查询某用户的技能掌握统计
SELECT
    COUNT(*) FILTER (WHERE status = 'mastered') AS mastered_count,
    COUNT(*) FILTER (WHERE status = 'learning') AS learning_count,
    COUNT(*) FILTER (WHERE status = 'review') AS review_count,
    SUM(correct_count) AS total_correct,
    SUM(wrong_count) AS total_wrong
FROM user_sense_skill_progress
WHERE user_id = :user_id;
```

---

## 五、学习功能模块

### 5.1 核心学习流程

```
┌─────────────────────────────────────────────────────────────┐
│                    核心学习流程                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐            │
│   │  单词卡  │ → │  多维练习 │ → │  FSRS复习│            │
│   └─────────┘    └─────────┘    └─────────┘            │
│        │              │              │                    │
│        ↓              ↓              ↓                    │
│   形式/意义/使用     听说读写        记忆状态三参数        │
│   掌握证据           七技能          调度+主动回忆         │
│                                                             │
│   学习路径：                                                │
│   1. 看单词卡（听发音、看图片、读 i+1 例句）             │
│   2. 做练习题（听音辨词、看图选词、组合单词等）          │
│   3. 智能复习（FSRS 按 stability/difficulty 调度）      │
│   4. 阶段测评（VKS 复评 + 技能掌握报告）                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 学习模块设计

| 模块 | 功能 | 题型 |
|------|------|------|
| 单词学习 | 形式、意义、使用三类证据 | 跟读、跟写、选义、句内使用 |
| 词块学习 | 词块整体输入与产出 | 词块选义、补全词块、情境运用 |
| 拼读训练 | 字母组合发音 | 听音选词、拼写补全 |
| 词素学习 | 词根词缀拆分与组合 | 组合单词、拆分单词、判断词素义 |
| 语义网络 | 上下位、同义反义搭配 | 归类题、选同义词、完成搭配 |
| 语音练习 | 跟读、发音评测 | 跟读打分、最小对立对听辨 |
| 间隔复习 | FSRS 调度 + 主动回忆 | 按记忆状态智能推送复习 |

### 5.3 朗读技术选型参考

> 版本：v1.3 新增
> 来源：GitHub 开源项目调研（搜索词：gTTS、Edge TTS、pyttsx3、espeak、TTS pronunciation、English speaking practice）

#### 5.3.1 常见 TTS 技术对比

| 技术 | 优点 | 缺点 | 代表项目参考 |
|------|------|------|-------------|
| **Edge TTS**（微软 Edge read-aloud） | 音质好、免费、**离线可用** | 需要 `edge-tts` 库 | [xiaobei](https://github.com/TeamWiseFlow/xiaobei)、[anki_miner](https://github.com/0xzerolight/anki_miner) |
| **gTTS**（Google Translate TTS） | 免费、API 简单、支持多语言（含中文） | 需要联网、音质一般 | [sioyek-tts-extension](https://github.com/AB-hex/sioyek-tts-extension)、[ReadAlongWithChild](https://github.com/dheerajrhegde/ReadAlongWithChild)、[anki_miner](https://github.com/0xzerolight/anki_miner) |
| **pyttsx3** | 纯本地、不需要网络 | 音质较差、声音机械感强 | [VoiceCraft](https://github.com/parthgupta1208/VoiceCraft)、各类 Python 语音助手项目 |
| **火山引擎 / 阿里云 / 腾讯云 TTS** | 商用级音质、支持句级时间戳 | 需要 API Key、费用 | [xiaobei](https://github.com/TeamWiseFlow/xiaobei)（火山引擎 TTS） |

#### 5.3.2 推荐方案

**首选：Edge TTS（微软 Edge read-aloud）**

- 开源库 `edge-tts`，pip 安装，无需 API Key
- 支持句级时间戳（用于字幕对齐和发音评测）
- 音质接近真人朗读，可选男声/女声、不同地区口音
- Python 示例：

```python
import asyncio
from edge_tts import Communicate

async def main():
    audio_data = await Communicate("Hello, how are you?").presample()
    # audio_data 为原始音频字节，可直接播放或保存

asyncio.run(main())
```

**备选：gTTS + 本地缓存双轨**

- gTTS 离线缓存：首次联网合成后缓存音频文件，后续直接读取
- 参考 [anki_miner](https://github.com/0xzerolight/anki_miner) 的 `sentence_cache_stem_prefix` 缓存策略
- 缓存文件名可按句子 hash 命名，避免重复合成

#### 5.3.3 发音评测技术参考

| 方案 | 说明 | 参考项目 |
|------|------|---------|
| GOP 分数（Goodness of Pronunciation） | 基于音素对齐的发音质量评估，无需人工标注 | [GrammarML-EduAssessment](https://github.com/Ashish-Chokhani/GrammarML-EduAssessment) |
| 语音识别对比（ASR） | 将用户跟读转文字，与标准文本对比相似度 | [English_speaking_app](https://github.com/118abhi/English_speaking_app)、[emma-english-coach](https://github.com/Haojie-Corner/emma-english-coach) |
| 云服务 API | 阿里云/腾讯云/火山引擎发音评测 API | 商用方案，精度高，有免费额度 |

---


## 六、数据统计

### 6.1 词汇量规划

**计数口径**（全产品统一）：
- 词汇量以 **lemma（词条）** 计数，词形、拼写变体不重复计；
- 词块（chunk）作为独立词条类型单列统计；
- 同一词条跨学段重复出现时**不重复计入**总词汇量；
- 掌握度统计以 **Bauer & Nation L6 词族**为单位（Nation 的标准做法）；
- "核心词"不再单列，由 `required_level='produce'` 派生。

| 学段 | 年级 | 课标级别 | 课标词汇量要求 | 产品覆盖目标（去重 lemma） |
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
- 具体数字以内容录入后实测校准。

### 6.2 分类数据规划

| 分类维度 | 数据量 |
|----------|--------|
| 词条（含词块） | 约2400-2800（K-12去重 lemma，含词块300-400） |
| 义项 | 按词条和课程来源建立，允许一词多义 |
| 词形 | 复数、时态、比较级、拼写变体 |
| 词素 | 词根200-300（含粘着词根）/ 前后缀100+（含变体归并，按证据逐步录入） |
| 发音变体 | 英式/美式音标、音素和音频 |
| 拼读规则 | 字母组合与音素对应 |
| 句法框架 | 动词句型和补语结构 |
| 主题 | 24个子主题（归入三大主题群） |
| 上下位关系 | 3000+对（替代原语义场扁平表） |
| 同义词关系 | 5000+对 |
| 反义词关系 | 2000+对 |
| 易混词对 | 800+对（含 L1 迁移类标注） |
| 搭配关系 | 10000+条 |
| 假朋友关系 | 300+对（汉英假朋友为主） |
| 语域变体关系 | 200+对（美英差异词） |
| 部分整体关系 | 1000+对 |
| 逆构词关系 | 50+对 |
| 同句法结构词组 | 50+个框架，每个框架 10-50 词 |
| 隐喻框架 | 20-30 个概念隐喻框架 |
| 情感色彩组 | 30-50 个情感组，每组 5-20 词 |
| 多义派生链 | 500+条义项派生关系 |
| 主题词簇 | 50-80 个情境词簇 |
| 学习先备关系 | 200+条先备依赖 |
| 例句 | 每核心义项≥2句，known_word_ratio 全标注 |
| 词源故事 | 100-200个（高中段优先，高频词故事先行） |

---

## 七、开发计划

### 7.1 MVP阶段（2个月）

| 优先级 | 功能 | 说明 |
|--------|------|------|
| P0 | 单词正式模型 | 词条、义项、词形、词素、发音、关系和教材映射入库 |
| P0 | 单词学习 | 形式、意义和基本使用 |
| P0 | 基础练习 | 选词、拼写 |
| P1 | 学习进度 | 用户进度追踪（含 VKS 冷启动定级） |
| P1 | 间隔复习 | FSRS 自适应调度 + 主动回忆 |
| P1 | 词块学习 | 词块输入与产出 |
| P2 | 语义关联 | 上下位、同义反义词 |
| P2 | 词素学习 | 词根词缀拆分组合 |

### 7.2 完整版（4个月）

| 优先级 | 功能 | 说明 |
|--------|------|------|
| P1 | 语音练习 | 跟读、听音辨词、发音评测 |
| P1 | 主题学习 | 三大主题群24子主题词汇 |
| P1 | 词源故事 | 词源趣味故事 |
| P2 | 测评系统 | VKS 复评 + CEFR 水平测试 |
| P2 | 个性化推荐 | 基于学习数据推荐 |
| P3 | 家长端 | 监督学习报告（parent_student 关联） |

---

## 八、附录

### 8.1 CEFR等级使用边界

| 等级 | 本文用途 | 说明 |
|------|----------|------|
| A1-B1 | 能力描述参考 | 目标学段实际覆盖区间（中考约 A2+-B1），数据模型保留 A1-C2 全枚举但不承诺内容覆盖 |

课程词表、产品扩展词和试验词分开管理。每条词数据记录课程/教材来源、版本、适用学段、词形口径和证据来源；CEFR、年级和词频是不同维度，不互相替代。

### 8.2 主题体系（对齐2022课标三大主题群）

| 主题群 | 子主题 |
|--------|--------|
| 人与自我（self） | 个人情况、日常生活、兴趣爱好、情绪情感、计划安排、饮食健康、健康急救、语言学习 |
| 人与社会（society） | 家庭朋友、学校生活、人际交往、节假日、购物、文娱体育、旅游交通、通信网络、文学艺术、历史社会、职业工作、科学技术、热点话题 |
| 人与自然（nature） | 天气气候、自然世界、环境保护 |

教材单元挂接主题（textbook_units.theme_id），词汇按义项挂接主题（word_themes），两条链路可对账。

---

*文档版本：v1.5*
*修订日期：2026-10-08*
