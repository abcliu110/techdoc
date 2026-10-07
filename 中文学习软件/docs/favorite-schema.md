# 汉字学习软件 - 收藏功能 Schema 文档

> 版本：v1.0.0  
> 创建日期：2026-10-06  
> 状态：正式版  
> 架构师：架构师 Agent  
> 契约版本：favorite-schema@1.0.0  
> 适用范围：汉字学习软件的收藏功能数据层设计与实现  

---

## 1. 概述

本文档定义收藏功能的完整数据Schema，包括实体模型、数据库表结构、Repository接口契约。本Schema基于以下上游契约：

- **交互契约**：`favorite-interaction@1.0.0`（见 `docs/favorite-interaction-contract.md`）
- **技术栈**：Flutter + sqflite_common_ffi + Riverpod

---

## 2. 数据模型

### 2.1 Favorite 实体

```dart
/// 收藏实体
///
/// 描述：用户收藏的汉字记录
///
/// 业务语义：
/// - 每个汉字只能被收藏一次（characterId 唯一约束）
/// - collectedAt 记录收藏时间，用于排序和统计
/// - note 为用户自定义备注
/// - tags 为用户自定义标签列表
class Favorite {
  /// 主键 ID
  final int id;

  /// 汉字 ID（外键 → characters.id）
  final int characterId;

  /// 收藏时间（ISO8601 格式，UTC）
  final String collectedAt;

  /// 用户备注（可选）
  final String? note;

  /// 自定义标签列表
  final List<String> tags;

  /// 创建时间（可选，用于数据库记录）
  final String? createdAt;
}
```

### 2.2 字段定义

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| `id` | `INTEGER` | PRIMARY KEY AUTOINCREMENT | 自增主键 |
| `character_id` | `INTEGER` | NOT NULL, UNIQUE, FK → characters(id) | 汉字外键，保证唯一性 |
| `collected_at` | `TEXT` | NOT NULL | 收藏时间，ISO8601 UTC |
| `note` | `TEXT` | NULLABLE | 用户备注，最大 500 字符 |
| `tags` | `TEXT` | NULLABLE, DEFAULT '' | 标签列表，逗号分隔存储 |
| `created_at` | `TEXT` | DEFAULT CURRENT_TIMESTAMP | 数据库记录创建时间 |

### 2.3 FavoriteStats 统计模型

```dart
/// 收藏统计
class FavoriteStats {
  final int totalCount;        // 总收藏数
  final int notLearnedCount;   // 未学习数
  final int learningCount;    // 学习中数
  final int masteredCount;    // 已掌握数
  final int level1Count;      // 难度1级数
  final int level2Count;      // 难度2级数
  final int level3Count;      // 难度3级数
  final int level4Count;      // 难度4级数

  /// 学习进度百分比
  double get masteryRate => totalCount > 0 ? masteredCount / totalCount : 0.0;
}
```

### 2.4 FavoriteFilter 筛选模型

```dart
/// 收藏筛选条件
class FavoriteFilter {
  /// 难度等级筛选（空=不筛选）
  final List<int> levels;

  /// 学习状态筛选（空=不筛选）
  final List<String> statuses;

  /// 主题词场 ID 筛选（null=不筛选）
  final String? themeId;

  /// 排序方式
  final FavoriteSortOrder sortOrder;

  /// 是否启用了筛选
  bool get hasActiveFilter => levels.isNotEmpty || statuses.isNotEmpty || themeId != null;
}
```

### 2.5 FavoriteSortOrder 排序枚举

```dart
/// 收藏排序方式
enum FavoriteSortOrder {
  collectedDesc('最新收藏'),    // 按收藏时间倒序（最新在前）
  collectedAsc('最早收藏'),     // 按收藏时间正序（最旧在前）
  pinyin('按拼音'),             // 按拼音排序
  levelAsc('难度低→高'),        // 按难度升序（简单在前）
  levelDesc('难度高→低'),       // 按难度降序（难在前）
  strokesAsc('笔画少→多'),      // 按笔画数升序
  strokesDesc('笔画多→少');     // 按笔画数降序

  const FavoriteSortOrder(this.label);
  final String label;
}
```

---

## 3. 数据库表结构

### 3.1 favorites 表

```sql
CREATE TABLE favorites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_id INTEGER NOT NULL UNIQUE,
    collected_at TEXT NOT NULL,
    note TEXT,
    tags TEXT DEFAULT '',
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (character_id) REFERENCES characters(id)
);
```

### 3.2 索引设计

```sql
-- 字符 ID 唯一索引（业务唯一性）
CREATE UNIQUE INDEX idx_favorites_character ON favorites(character_id);

-- 收藏时间索引（用于排序查询）
CREATE INDEX idx_favorites_collected_at ON favorites(collected_at);

-- 标签模糊查询索引（未来扩展）
CREATE INDEX idx_favorites_tags ON favorites(tags);
```

### 3.3 数据完整性约束

| 约束类型 | 字段 | 说明 |
|---------|------|------|
| UNIQUE | `character_id` | 每个汉字只能被收藏一次 |
| FOREIGN KEY | `character_id` → `characters(id)` | 引用完整性，级联删除 |
| NOT NULL | `character_id`, `collected_at` | 必填字段 |

### 3.4 存储格式

- **tags 字段**：存储为逗号分隔字符串，如 `"常用,考试,易错"`
- **时间字段**：存储为 ISO8601 UTC 字符串，如 `"2026-10-06T12:00:00.000Z"`

---

## 4. Repository 接口契约

### 4.1 FavoriteRepository 接口

```dart
/// 收藏数据仓库
///
/// 职责：
/// - 收藏的增删改查
/// - 收藏统计
/// - 筛选和排序
///
/// 技术要求：
/// - 所有方法异步返回
/// - 使用 ConflictAlgorithm.ignore 处理重复收藏
abstract class FavoriteRepository {
  // ==================== 基础操作 ====================

  /// 检查汉字是否已收藏
  ///
  /// 参数：
  /// - [characterId] 汉字 ID
  ///
  /// 返回：true 表示已收藏
  Future<bool> isFavorited(int characterId);

  /// 添加收藏
  ///
  /// 参数：
  /// - [characterId] 汉字 ID（必填）
  /// - [note] 备注（可选）
  /// - [tags] 标签列表（可选）
  ///
  /// 返回：插入成功返回新记录 ID，0 表示已存在（未重复插入）
  /// 错误：字符 ID 不存在时抛出异常
  Future<int> addFavorite(
    int characterId, {
    String? note,
    List<String>? tags,
  });

  /// 取消收藏
  ///
  /// 参数：
  /// - [characterId] 汉字 ID
  ///
  /// 注意：不存在的收藏调用会静默成功
  Future<void> removeFavorite(int characterId);

  /// 切换收藏状态
  ///
  /// 参数：
  /// - [characterId] 汉字 ID
  ///
  /// 返回：切换后的收藏状态（true=已收藏，false=未收藏）
  Future<bool> toggleFavorite(int characterId);

  // ==================== 查询操作 ====================

  /// 获取所有收藏记录（不含汉字详情）
  ///
  /// 返回：按收藏时间倒序排列
  Future<List<Favorite>> getAllFavorites();

  /// 获取收藏的汉字 ID 列表
  ///
  /// 返回：按收藏时间倒序排列的 ID 列表
  Future<List<int>> getFavoriteCharacterIds();

  /// 获取收藏的汉字列表（带 Character 详情）
  ///
  /// 参数：
  /// - [filter] 筛选条件（可选）
  ///
  /// 返回：符合筛选条件的汉字列表
  Future<List<Character>> getFavoriteCharacters({FavoriteFilter? filter});

  /// 获取收藏数量
  ///
  /// 返回：总收藏数
  Future<int> getCount();

  /// 获取收藏统计
  ///
  /// 返回：包含各维度统计的 FavoriteStats
  Future<FavoriteStats> getStats();

  // ==================== 扩展操作 ====================

  /// 更新收藏备注
  ///
  /// 参数：
  /// - [characterId] 汉字 ID
  /// - [note] 新备注（null=清除备注）
  Future<void> updateNote(int characterId, String? note);

  /// 更新收藏标签
  ///
  /// 参数：
  /// - [characterId] 汉字 ID
  /// - [tags] 新标签列表（空列表=清除标签）
  Future<void> updateTags(int characterId, List<String> tags);

  /// 获取需要复习的收藏汉字
  ///
  /// 说明：返回已学习但需要复习的收藏汉字
  ///
  /// 返回：需要复习的汉字 ID 列表，按复习时间排序
  Future<List<int>> getFavoritesForReview();
}
```

### 4.2 方法签名速查表

| 方法 | 输入 | 输出 | 异常处理 |
|------|------|------|----------|
| `isFavorited` | `int characterId` | `Future<bool>` | 无 |
| `addFavorite` | `int characterId, {String? note, List<String>? tags}` | `Future<int>` | FK 约束异常 |
| `removeFavorite` | `int characterId` | `Future<void>` | 无 |
| `toggleFavorite` | `int characterId` | `Future<bool>` | 无 |
| `getAllFavorites` | - | `Future<List<Favorite>>` | 无 |
| `getFavoriteCharacterIds` | - | `Future<List<int>>` | 无 |
| `getFavoriteCharacters` | `FavoriteFilter? filter` | `Future<List<Character>>` | 无 |
| `getCount` | - | `Future<int>` | 无 |
| `getStats` | - | `Future<FavoriteStats>` | 无 |
| `updateNote` | `int characterId, String? note` | `Future<void>` | 无收藏记录 |
| `updateTags` | `int characterId, List<String> tags` | `Future<void>` | 无收藏记录 |
| `getFavoritesForReview` | - | `Future<List<int>>` | 无 |

---

## 5. SQL 查询模板

### 5.1 基础查询

```sql
-- 检查收藏
SELECT EXISTS(
  SELECT 1 FROM favorites WHERE character_id = ?
);

-- 添加收藏
INSERT INTO favorites (character_id, collected_at, note, tags)
VALUES (?, ?, ?, ?)
ON CONFLICT(character_id) DO NOTHING;

-- 取消收藏
DELETE FROM favorites WHERE character_id = ?;
```

### 5.2 带筛选的查询

```sql
-- 按难度筛选并排序
SELECT c.*, f.collected_at, f.note, f.tags,
       COALESCE(up.status, 0) as learn_status
FROM characters c
INNER JOIN favorites f ON c.id = f.character_id
LEFT JOIN user_progress up ON c.id = up.character_id
WHERE c.level IN (1, 2)  -- 难度筛选
ORDER BY f.collected_at DESC;

-- 按主题筛选
SELECT c.*, f.collected_at, f.note, f.tags
FROM characters c
INNER JOIN favorites f ON c.id = f.character_id
INNER JOIN character_themes ct ON c.id = ct.character_id
WHERE ct.theme_id = ?
ORDER BY f.collected_at DESC;
```

### 5.3 统计查询

```sql
-- 总收藏数
SELECT COUNT(*) FROM favorites;

-- 按难度统计
SELECT c.level, COUNT(*) as count
FROM favorites f
INNER JOIN characters c ON f.character_id = c.id
GROUP BY c.level;

-- 按学习状态统计
SELECT COALESCE(up.status, 0) as status, COUNT(*) as count
FROM favorites f
LEFT JOIN user_progress up ON f.character_id = up.character_id
GROUP BY COALESCE(up.status, 0);
```

---

## 6. 版本兼容性策略

### 6.1 Schema 版本

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| 1.0.0 | 2026-10-06 | 初始版本，定义核心字段 |

### 6.2 向前兼容性

- **新增字段**：使用 DEFAULT 值，新增字段必须有默认值或 NULLABLE
- **新增表**：不影响现有功能
- **新增索引**：不影响现有查询性能

### 6.3 向后兼容性

- **不删除字段**：历史数据保留
- **不修改约束**：现有约束不收紧
- **不修改类型**：字段类型保持一致

### 6.4 迁移策略

```sql
-- v1.0.0 → v1.1.0 示例（添加 category 字段）
ALTER TABLE favorites ADD COLUMN category TEXT DEFAULT NULL;

-- 数据迁移（如果有）
UPDATE favorites SET category = 'default' WHERE category IS NULL;
```

---

## 7. 性能要求

| 指标 | 要求 | 说明 |
|------|------|------|
| 收藏响应时间 | < 50ms | 本地数据库操作 |
| 列表查询时间 | < 200ms | 100 条数据，带筛选 |
| 统计查询时间 | < 100ms | 聚合查询 |
| 最大收藏数 | 5000 | 合理使用场景上限 |

---

## 8. 实现参考

完整实现参考代码文件：

| 文件 | 路径 | 说明 |
|------|------|------|
| Favorite 实体 | `lib/data/models/favorite.dart` | 实体模型 |
| FavoriteRepository | `lib/data/repositories/favorite_repository.dart` | 数据仓库实现 |
| FavoriteProvider | `lib/features/favorites/providers/favorite_provider.dart` | Riverpod 状态管理 |
| 数据库初始化 | `lib/core/database/database_helper.dart` | 表创建语句 |

---

## 9. 验收条件

### 9.1 功能验收

| 编号 | 条件 | 验证方法 |
|------|------|----------|
| V1 | 汉字只能被收藏一次 | 重复 addFavorite 返回 0 |
| V2 | 收藏后 isFavorited 返回 true | 单元测试 |
| V3 | 取消收藏后 isFavorited 返回 false | 单元测试 |
| V4 | getFavoriteCharacters 返回带 Character 详情 | 集成测试 |
| V5 | 筛选条件正确过滤结果 | 单元测试 |
| V6 | 统计结果准确 | 单元测试 |
| V7 | updateNote/updateTags 正确更新 | 单元测试 |
| V8 | getFavoritesForReview 返回需复习汉字 | 集成测试 |

### 9.2 性能验收

| 编号 | 条件 | 验证方法 |
|------|------|----------|
| P1 | 100 条收藏列表加载 < 200ms | 性能测试 |
| P2 | 收藏操作 < 50ms | 性能测试 |

### 9.3 数据完整性验收

| 编号 | 条件 | 验证方法 |
|------|------|----------|
| D1 | 删除汉字时收藏记录被级联删除 | FK 约束测试 |
| D2 | character_id 唯一性约束生效 | 尝试重复收藏 |

---

## 10. 交付物清单

- [x] Favorite 实体模型定义
- [x] 数据库表结构（CREATE TABLE 语句）
- [x] 索引设计
- [x] Repository 接口契约
- [x] SQL 查询模板
- [x] 版本兼容性策略
- [x] 性能要求
- [x] 验收条件

---

## 11. 参考文档

| 文档 | 路径 | 版本 |
|------|------|------|
| 交互契约 | `docs/favorite-interaction-contract.md` | v1.0.0 |
| 汉字学习 App 设计文档 | `汉字学习App设计文档.md` | v1.0 |
| 多 Agent 协作指南 | `D:/mywork/techdoc/00通用/多Agent角色通信协作指南.md` | v2.1.1 |

---

*文档版本历史*

| 版本 | 日期 | 修改内容 | 作者 |
|------|------|----------|------|
| 1.0.0 | 2026-10-06 | 初始版本，定义收藏功能完整 Schema | 架构师 Agent |
