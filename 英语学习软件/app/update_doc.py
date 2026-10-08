# -*- coding: utf-8 -*-
with open(r'D:\mywork\techdoc\英语学习软件\中小学英语学习App设计文档.md', 'r', encoding='utf-8') as f:
    content = f.read()

# Find and replace section 3.3
marker_start = '### 3.3 语言关系分类'
idx = content.find(marker_start)
if idx == -1:
    print('Marker not found!')
    exit(1)

# Find next section marker (### 3.4)
idx_end = content.find('### 3.4 教学资源分类', idx)
if idx_end == -1:
    print('End marker not found!')
    exit(1)

new_section = '''### 3.3 语言关系分类

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

#### 3.3.14 语言关系维度总览

| 维度 | 分类标准 | 存储约定 | 核心价值 |
|------|---------|---------|---------|
| 同词根 | 相同词根 | 词素分解表独立存储，关系表关联 | 词族扩展，构词法学习 |
| 同词缀 | 相同前缀/后缀 | 前缀/后缀词素表 | 派生规则批量掌握 |
| 同字母组合 | 相同字母序列 | 拼读规则表 | 拼读联动拼写 |
| 同发音模式 | 相同音素 | 发音表关联 | 听力辨析题 |
| 同词源 | 相同语系 | 词源字段 | 文化背景/词汇规律 |
| 同拼写模式 | 相同拼写规律 | 拼写规则表 | 避免拼写错误 |
| 同义词 | 意义相近 | 对称关系存储 | 写作替换/辨析题 |
| 反义词 | 意义相反 | 对称关系存储 | 对比记忆/完形填空 |
| 易混词 | 视觉/听觉/意义/L1迁移 | 无向，标注类型 | 高价值辨析题素材 |
| 同错因 | 相同错误类型 | 错误类型字段 | 错误诊断和纠正 |
| 同构词法 | 转化/派生/复合 | 词条类型字段 | 构词规则学习 |
| 同搭配 | 固定搭配 | 搭配表 | 地道表达/写作 |
| 上下位 | 下位→上位单向 | 单向存储，查询反推 | 语义聚合/归类题 |

每条关系必须记录关系类型、方向（对称/单向/有向）、适用义项、证据来源和说明，不能只保存一个相关单词文本。

'''

content = content[:idx] + new_section + content[idx_end:]

with open(r'D:\mywork\techdoc\英语学习软件\中小学英语学习App设计文档.md', 'w', encoding='utf-8') as f:
    f.write(content)

print('done')
