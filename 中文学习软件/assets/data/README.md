# 汉字字库数据

## 数据格式

字库数据存储在 SQLite 数据库中，包含以下核心字段：

### characters 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER | 主键 |
| character | TEXT | 汉字 |
| pinyin | TEXT | 拼音 |
| radical | TEXT | 部首 |
| strokes | INTEGER | 笔画数 |
| frequency | INTEGER | 字频（越小越常用） |
| six_book | INTEGER | 六书分类（1-6） |
| phonetic | TEXT | 声旁（形声字） |
| semantic | TEXT | 形旁（形声字） |
| origin_jiaguwen | TEXT | 甲骨文图片路径 |
| origin_jinwen | TEXT | 金文图片路径 |
| origin_xiaozhuan | TEXT | 小篆图片路径 |
| original_meaning | TEXT | 本义 |
| extended_meanings | TEXT | 引申义（逗号分隔） |
| level | INTEGER | 难度级别（1-4） |
| sources | TEXT | 来源标记（逗号分隔） |

### 六书分类代码

| 代码 | 分类 |
|------|------|
| 1 | 象形 |
| 2 | 指事 |
| 3 | 会意 |
| 4 | 形声 |
| 5 | 转注 |
| 6 | 假借 |

### 难度级别

| 级别 | 范围 | 说明 |
|------|------|------|
| 1 | 字频 1-500 | 超高频字，最基础 |
| 2 | 字频 501-1000 | 高频字 |
| 3 | 字频 1001-2000 | 常用字 |
| 4 | 字频 2001-3500+ | 次常用字 |

## 初始数据

请参考 `init_data.dart` 文件获取初始字库数据。

## 字源数据

字源图片建议从以下免费资源获取：
- 甲骨文：开源甲骨文字库
- 金文：《殷周金文集成》数字化版本
- 小篆：《说文解字》字形

图片存储在 `assets/images/origin/` 目录下，按汉字 ID 命名。
