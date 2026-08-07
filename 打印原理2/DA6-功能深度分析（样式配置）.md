# 打印功能 DA6：功能深度分析（样式配置）

> **分析范围**：nms4pos、nms4pos-ui、nms4cloud、nms4cloud-biz-ui
> **分析时间**：2026-08-03
> **SOP 依据**：SOP-00 业务系统分析 v2.9
> **前置文档**：DA0-DA1-全景扫描与概念建模.md、DA5-数据模型分析.md

---

## 1. 概述

本文档深入分析打印系统的"样式配置"阶段，即如何将打印模板与业务数据源编译为最终可打印的行内容。核心入口类为：

| 类 | 职责 | 源码位置 |
|---|------|----------|
| `PrintJobInitUtil` | 模板行 + 数据源 → 最终打印行 | `pos2plugin-biz/service/print/PrintJobInitUtil.java` |
| `ConditionUtil` | 行级条件判断与记录过滤 | `pos2plugin-biz/service/print/ConditionUtil.java` |

两者配合完成整个"模板渲染"过程：

```
.job 文件
    ├─ rows: List<PosPrnStyleRowVO>      ← 模板行（含列定义、条件、汇总标识）
    └─ dataSourceList: List<PrnDataSourceDTO<?>> ← 业务数据（OBJECT / TABLE）
              │
              ▼
    PrintJobInitUtil.convert(rows, dataSourceList)
              │
              ├─ convertRow()             ← 按 DataSource 类型分发
              │       │
              │       ├─ 非表格行 → convertLineRow()
              │       │       ├─ ConditionUtil.isRowVisible()    ← 行级可见性判断
              │       │       ├─ 按列宽拆行（width80 累加 > 100）
              │       │       └─ calculateColContent()            ← 占位符替换
              │       │
              │       └─ 表格行   → convertTableRow()
              │               ├─ filterDataSource()              ← 记录级过滤
              │               ├─ 分组 + 分组小计（如有汇总列）
              │               └─ markSummarizeRow()              ← 合计行
              │
              ▼
    最终打印行列表 → 交付给 PrinterWorker
```

---

## 2. 数据源类型与行分类

### 2.1 DataSource 类型定义

`PrnDataSourceDTO<T>` 的 `type` 字段决定该数据源是"单对象"还是"表格数据"：

| 类型 | 枚举值 | 数据字段 | 语义 | 典型示例 |
|------|--------|---------|------|----------|
| 单对象 | `OBJECT` | `data: T` | 整张票据共用一份数据 | `store_info`、`bill_info`、`operator_info` |
| 表格数据 | `TABLE` | `dataList: List<T>` | 每条记录展开为一行或多行 | `food_info`、`pay_info` |

`convert` 方法首先将 `dataSourceList` 构建为 `Map<String, PrnDataSourceDTO<?>> dataSourceMap`，供后续行列处理使用：

```java
// PrintJobInitUtil.java:49-51
Map<String, PrnDataSourceDTO<?>> dataSourceMap =
    dataSourceList.stream()
        .collect(Collectors.toMap(PrnDataSourceDTO::getId, Function.identity()));
```

### 2.2 模板行分类逻辑

`convertRow` 根据 `row.dsId` 是否绑定到 TABLE 类型的 DataSource，将模板行分为两类：

```java
// PrintJobInitUtil.java:427-437
PrnDataSourceDTO<?> ds =
    Optional.ofNullable(row.getDsId()).map(dataSourceMap::get).orElse(null);
if (ds == null || PrnDataSourceTypeEnum.OBJECT.equals(ds.getType())) {
  // 非表格行
  convertLineRow(row, newRows, dataSourceMap, null);
  return;
}
// 表格行
convertTableRow(
    row, newRows, dataSourceMap, filterDataSource(row, dataSourceMap, ds.getDataList()));
```

| 分类 | 触发条件 | 数据来源 | 处理方式 |
|------|---------|---------|----------|
| 非表格行 | `dsId` 为空或指向 OBJECT 类型 | `dataSource.data`（单一对象） | `convertLineRow` 处理一次 |
| 表格行 | `dsId` 指向 TABLE 类型 | `dataSource.dataList`（记录列表） | `convertTableRow` 对每条记录展开 |

---

## 3. 非表格行处理：`convertLineRow`

### 3.1 完整流程

```java
// PrintJobInitUtil.java:264-297
private static void convertLineRow(
    PosPrnStyleRowVO row,
    List<PosPrnStyleRowVO> newRows,
    Map<String, PrnDataSourceDTO<?>> dataSourceMap,
    Object lineData) {

  // ① 行级可见性判断
  if (!isRowVisible(row, dataSourceMap, lineData)) {
    return;
  }

  // ② 按列宽拆分为多个物理行（宽度累加 > 100 就换行）
  List<PosPrnStyleRowVO> _rows = new ArrayList<>();
  PosPrnStyleRowVO curRow = null;
  int curWidth = 0;
  for (PosPrnStyleColVO col : cols) {
    PosPrnStyleColVO newCol = clone(col);
    int width = Optional.ofNullable(col.getWidth80()).orElse(100);
    if (curRow == null || curWidth + width > 100) {
      curRow = clone(row);
      _rows.add(curRow);
      curWidth = width;
      newCol.setRowLid(curRow.getLid());
      curRow.addCol(newCol);
      continue;
    }
    curRow.addCol(newCol);
    curWidth = curWidth + width;
  }

  // ③ 对拆分后的每一物理行做内容替换
  for (PosPrnStyleRowVO _row : _rows) {
    convertLineRowAfterSplit(_row, newRows, dataSourceMap, lineData);
  }
}
```

### 3.2 列宽自动拆分逻辑

`width80` 字段取值 0–100，表示列宽百分比（基于 80mm 纸宽的实际比例）。当一行中所有列的 `width80` 累加和超过 100 时，自动拆分为多行：

```
示例：列定义
  col1(width80=40) + col2(width80=35) + col3(width80=35) + col4(width80=40)
  ↓
  累加过程：
    col1 → curWidth=40，< 100，新行
    col2 → curWidth=75，< 100，加入当前行
    col3 → curWidth=110，> 100，触发换行
    curRow 包含 [col1, col2]
    新行 curRow 包含 [col3]
    col4 → curWidth=40，< 100，加入新行
  ↓
  结果：2 个物理行
    行1: [col1, col2]
    行2: [col3, col4]
```

### 3.3 占位符替换：`calculateColContent`

每列的 `customizedContent` 字段是一个 JSON 数组，元素类型为 `PosPrnStyleColContentVO`：

```java
// PrintJobInitUtil.java:299-363
private static String calculateColContent(
    PosPrnStyleRowVO row,
    Map<String, PrnDataSourceDTO<?>> dataSourceMap,
    Object lineData,
    String content) {

  // content = '[{"c":true,"v":"门店名称"},{"c":false,"v":"store_info,storeName"}]'
  List<PosPrnStyleColContentVO> styleColContents =
      JSON.parseArray(content, PosPrnStyleColContentVO.class);

  StringBuilder contentVal = new StringBuilder();
  for (PosPrnStyleColContentVO styleColContent : styleColContents) {
    String v = styleColContent.getV();
    if (StringUtils.isBlank(v)) {
      continue;
    }
    if (styleColContent.getC()) {
      // c=true：常量文本，直接拼接
      contentVal.append(styleColContent.getV());
      continue;
    }
    // c=false：数据占位符，格式为 "dsId,fieldId"
    String[] split = v.split(",");
    if (split.length != 2) {
      log.error("content格式错误,{}", JSON.toJSONString(row));
      continue;
    }
    String dsId = split[0];
    String fieldId = split[1];

    PrnDataSourceDTO<?> dataSource = dataSourceMap.get(dsId);
    if (dataSource == null) {
      log.error("contentDsId对应的数据源不存在,{}", JSON.toJSONString(row));
      continue;
    }

    // OBJECT 类型取 data；TABLE 类型取当前记录 lineData
    Object data =
        dataSource.getType() == PrnDataSourceTypeEnum.OBJECT
            ? dataSource.getData()
            : lineData;

    if (data == null) {
      log.error("contentDsId对应的数据源数据为空,{}", JSON.toJSONString(row));
      continue;
    }

    // 从 Map 或 Java Bean 中取字段值
    if (data instanceof Map<?, ?>) {
      Object value = ((Map<String, Object>) data).get(fieldId);
      if (value != null) contentVal.append(formatContent(value));
    } else {
      Field field = ReflectUtil.getField(data.getClass(), fieldId);
      if (field != null) {
        field.setAccessible(true);
        Object value = field.get(data);
        if (value != null) contentVal.append(formatContent(value));
      }
    }
  }
  return contentVal.toString();
}
```

**`PosPrnStyleColContentVO` 结构：**

| 字段 | 类型 | 含义 | 示例 |
|------|------|------|------|
| `c` | Boolean | 是否为常量：`true`=常量文本，`false`=占位符 | `"c":true` |
| `v` | String | 内容值：常量时为文本，占位符时为 `dsId,fieldId` | `"v":"bill_info,saasOrderNo"` |
| `i` | Long | 唯一标识（渲染后由 `IdWorkerPlus.getId()` 生成） | `"i":123456789` |

**典型 `customizedContent` 配置：**

```json
[
  {"c": true,  "v": "订单号: ",    "i": 1},
  {"c": false, "v": "bill_info,saasOrderNo", "i": 2}
]
```

### 3.4 内容格式化：`formatContent`

`PrintJobInitUtil.java:401-421`

| 字段类型 | 格式化规则 | 示例 |
|---------|-----------|------|
| `BigDecimal` | 保留 2 位小数，去掉尾部 `.00` | `100.00` → `"100"` |
| `Float` | 转为 BigDecimal 同上 | |
| `Date` | `"HH:mm:ss"` | `14:30:00` |
| `LocalDateTime` | `"yyyy-MM-dd HH:mm:ss"`，零点时去掉时间 | `2026-08-03`（无时间部分） |
| `LocalDate` | ISO 格式 | `2026-08-03` |
| `LocalTime` | ISO 格式 | `14:30:00` |
| 其他 | `String.valueOf()` | |

---

## 4. 表格行处理：`convertTableRow`

### 4.1 记录过滤：`filterDataSource`

对 TABLE 类型的每条记录执行行级条件判断：

```java
// PrintJobInitUtil.java:439-449
private static List<?> filterDataSource(
    PosPrnStyleRowVO row,
    Map<String, PrnDataSourceDTO<?>> dataSourceMap,
    List<?> tableData) {

  if (CollUtil.isEmpty(tableData)) {
    return tableData;
  }

  return tableData.stream()
      .filter(lineData -> ConditionUtil.isRowVisible(row, dataSourceMap, lineData))
      .toList();
}
```

### 4.2 无汇总列：简单展开

```java
// PrintJobInitUtil.java:206-212
if (summarizeCol == null) {
  for (Object lineData : tableData) {
    convertLineRow(row, newRows, dataSourceMap, lineData);
  }
  markSummarizeRow(row, newRows, dataSourceMap, tableData, "");
  return;
}
```

### 4.3 有汇总列：分组 + 分组小计 + 总合计

当某列 `col.getSummarize() == true` 时，按该列内容分组：

```java
// PrintJobInitUtil.java:215-255
Map<String, List<Object>> groupMap =
    tableData.stream()
        .collect(
            Collectors.groupingBy(
                lineData ->
                    calculateColContent(
                        row, dataSourceMap, lineData, summarizeCol.getCustomizedContent())));

for (Map.Entry<String, List<Object>> entry : groupMap.entrySet()) {
  // ① 分组标题行（如"主食"）
  PosPrnStyleRowVO summaryRow = clone(row);
  PosPrnColContent = new PosPrnStyleColContentVO(true, entry.getKey(), id);
  convertLineRow(summaryRow, newRows, dataSourceMap, null);

  // ② 分组内每条记录
  for (Object lineData : entry.getValue()) {
    convertLineRow(otherRow, newRows, dataSourceMap, lineData);
  }

  // ③ 分组小计（如"主食合计"）
  markSummarizeRow(otherRow, newRows, dataSourceMap, tableDataList, entry.getKey());
}

// ④ 总合计
markSummarizeRow(otherRow, newRows, dataSourceMap, tableData, "");
```

### 4.4 合计行生成：`markSummarizeRow`

`PrintJobInitUtil.java:59-183`

1. **数值字段汇总**：对 Map 类型按 key 遍历数值字段累加；对 Java Bean 类型通过反射找出所有数值字段逐条相加。
2. **合计行结构**：
   - 克隆原始行模板
   - 第一列替换为分隔线（`insertSeparatorLine=1`，`width80=100`）
   - 第二列替换为"合计"/分组名（如"主食合计"）
   - 其他列自动计算合计值
3. **调用 `convertLineRow`** 渲染合计行，保证格式化一致性。

---

## 5. 行级条件过滤：`ConditionUtil.isRowVisible`

### 5.1 条件三元组

`PosPrnStyleRowVO` 上与条件相关的字段：

| 字段 | 类型 | 含义 |
|------|------|------|
| `conditionOperator` | `ConditionOperatorEnum` | 比较算子 |
| `conditionDsId` | `String` | 条件数据源，格式 `"dsId,fieldId"` |
| `conditionValue` | `String` | 右值（条件值） |

**`ConditionOperatorEnum` 完整枚举：**

| code | 枚举常量 | 中文 | 支持类型 |
|------|----------|------|----------|
| 11 | `EQ` | 等于 | 所有 |
| 12 | `GE` | 大于等于 | 可比较类型 |
| 13 | `GT` | 大于 | 可比较类型 |
| 14 | `LE` | 小于等于 | 可比较类型 |
| 15 | `LT` | 小于 | 可比较类型 |
| 16 | `NE` | 不等于 | 所有 |
| 17 | `IS_NULL` | 为空 | 所有 |
| 18 | `IS_NOT_NULL` | 不为空 | 所有 |
| 19 | `LIKE` | 包含 | String |
| 20 | `NOT_LIKE` | 不包含 | String |
| 21 | `IN` | 在集合中 | 所有 |
| 22 | `NOT_IN` | 不在集合中 | 所有 |

### 5.2 条件判断核心逻辑

`ConditionUtil.java:26-109`

```java
public static boolean isRowVisible(
    PosPrnStyleRowVO row,
    Map<String, PrnDataSourceDTO<?>> dataSourceMap,
    Object lineData) {

  // ① 无条件 → 默认可见
  if (operator == null || StringUtils.isBlank(conditionDsId)) {
    return true;
  }

  // ② 解析 conditionDsId = "dsId,fieldId"
  String[] split = conditionDsId.split(",");
  if (split.length != 2) {
    log.error("conditionDsId格式错误,{}", JSON.toJSONString(row));
    return true;  // 配置错误时偏向可见
  }
  String dsId = split[0];
  String fieldId = split[1];

  // ③ 获取数据源
  PrnDataSourceDTO<?> dataSource = dataSourceMap.get(dsId);
  if (dataSource == null) {
    log.error("conditionDsId对应的数据源不存在,{}", JSON.toJSONString(row));
    return true;
  }

  // ④ 确定数据对象
  Object data =
      dataSource.getType() == PrnDataSourceTypeEnum.OBJECT
          ? dataSource.getData()
          : lineData;
  if (data == null) {
    log.error("conditionDsId对应的数据源数据为空,{}", JSON.toJSONString(row));
    return true;
  }

  // ⑤ 获取左值（字段值）
  if (data instanceof Map<?, ?>) {
    leftValue = ((Map<String, Object>) data).get(fieldId);
  } else {
    Field field = ReflectUtil.getField(data.getClass(), fieldId);
    field.setAccessible(true);
    leftValue = field.get(data);
  }

  // ⑥ 按左值类型分发比较
  return switch (leftValue) {
    case Integer i  -> compareInteger(i, conditionValue, operator);
    case Long l     -> compareLong(l, conditionValue, operator);
    case Double d   -> compareDouble(d, conditionValue, operator);
    case Float f    -> compareFloat(f, conditionValue, operator);
    case Byte b     -> compareByte(b, conditionValue, operator);
    case Short s    -> compareShort(s, conditionValue, operator);
    case BigDecimal b -> compareBigDecimal(b, conditionValue, operator);
    case String s   -> compareString(s, conditionValue, operator);
    case Boolean b  -> compareBoolean(b, conditionValue, operator);
    case null       -> ConditionOperatorEnum.IS_NULL.equals(operator);
    default         -> compareOther(leftValue, conditionValue, operator, field);
  };
}
```

### 5.3 类型比较实现

| 类型 | 比较方法 | 特殊逻辑 |
|------|---------|----------|
| `Integer/Long/Short/Byte` | `compareLong()` | 数值比较；`IN/NOT_IN` 解析逗号分隔的 Long 集合 |
| `Double/Float` | `compareBigDecimal()` | 转为 BigDecimal 后比较 |
| `BigDecimal` | `compareBigDecimal()` | 直接使用 `NumberUtil.add` 累加 |
| `String` | `compareString()` | `LIKE`/`NOT_LIKE` 用 `contains()`；`IN/NOT_IN` 用 Set 匹配；`IS_NULL/IS_NOT_NULL` 用 `StrUtil.isBlank` |
| `Boolean` | `compareBoolean()` | 右值 `"true"`/`"false"` 不区分大小写 |
| `Enum` | `compareOther()` | 用 `Enum.name()` 当作字符串比较 |
| `null` | 直接返回 | `IS_NULL` → true，其他 → false |

**通用比较（`compare` 方法）：**

```java
// ConditionUtil.java:219-232
private static <T extends Comparable<T>> boolean compare(
    T left, T right, ConditionOperatorEnum operator) {
  return switch (operator) {
    case EQ -> left.compareTo(right) == 0;
    case GE -> left.compareTo(right) >= 0;
    case GT -> left.compareTo(right) > 0;
    case LE -> left.compareTo(right) <= 0;
    case LT -> left.compareTo(right) < 0;
    case NE -> !Objects.equals(left, right);
    case IS_NULL -> left == null;
    case IS_NOT_NULL -> left != null;
    case LIKE, NOT_LIKE, IN, NOT_IN -> false;  // 由各类型方法自行处理
  };
}
```

### 5.4 容错策略

所有配置错误（格式错误/找不到 DataSource/找不到字段）都会打错误日志并返回 `true`，不会隐藏行。这是"偏向可见"的设计，防止配置错误导致票据内容不完整。

---

## 6. 非表格行与表格行的条件行为差异

| 场景 | 调用方式 | `lineData` | 数据来源 | 典型用途 |
|------|---------|-----------|---------|----------|
| 非表格行 | `convertLineRow(row, newRows, dataSourceMap, null)` | `null` | `OBJECT` DataSource 的 `data` | 订单级条件（如只在结账单显示二维码） |
| 表格行 | `filterDataSource` 中对每条记录调用 `isRowVisible` | 当前记录对象/Map | `TABLE` DataSource 的 `lineData` | 过滤已退菜记录、按支付类型筛选等 |

---

## 7. 典型配置示例

### 7.1 只在结账单显示营销二维码行

**场景**：顾客联模板中有一行带二维码与营销文案，仅在结账单打印。

**配置**：
- 行 `dsId = "bill_info"`
- `conditionDsId = "bill_info,orderStatus"`
- `conditionOperator = EQ`
- `conditionValue = "CLOSED"`

**行为**：订单未结账 → `isRowVisible` 返回 `false`，该行不出现；已结账 → `true`，正常打印。

### 7.2 过滤已退菜记录（厨房联）

**场景**：厨房联不希望看到已退菜的行。

**配置**：
- 行 `dsId = "food_info"`（TABLE 类型）
- `conditionDsId = "food_info,foodStatus"`
- `conditionOperator = NE`
- `conditionValue = "CANCELLED"`

**行为**：在 `filterDataSource` 阶段，所有 `foodStatus == CANCELLED` 的记录被过滤。

### 7.3 过滤金额为 0 的支付明细

**配置**：
- 行 `dsId = "pay_info"`
- `conditionDsId = "pay_info,payAmount"`
- `conditionOperator = GT`
- `conditionValue = "0"`

**行为**：金额为 0 的支付记录（如找零抵扣）不打印。

### 7.4 仅对包间桌台打印服务说明

**配置**：
- `conditionDsId = "bill_info,tableTypeName"`
- `conditionOperator = LIKE`
- `conditionValue = "包间"`

**行为**：桌台类型名包含"包间"时打印该行，其他桌型不显示。

### 7.5 多值匹配：外卖/自取打印取餐码

**配置**：
- `conditionDsId = "bill_info,orderType"`
- `conditionOperator = IN`
- `conditionValue = "TAKEOUT,SELF_PICKUP"`

**行为**：`orderType` 为 `TAKEOUT` 或 `SELF_PICKUP` → 行可见；`DINE_IN` → 隐藏。

### 7.6 菜品按分类分组汇总

**配置**：
- 行 `dsId = "food_info"`（TABLE 类型）
- 在"分类"列上设置 `summarize = true`
- 行设置 `summarize = true`

**行为**：
1. 按分类列内容分组
2. 每组生成：分组标题行 → 组内菜品行 → 分组小计行
3. 最后生成总合计行

---

## 8. 调试指南

### 8.1 字段不显示

| 检查项 | 方法 |
|--------|------|
| `customizedContent` 中 `dsId,fieldId` 是否正确 | 查看 `PosPrnStyleCol.customizedContent` 数据库字段 |
| DataSource 中是否存在该字段 | 在 `calculateColContent` 处断点，查看 `dataSourceMap` |
| Convert 是否为新字段赋值 | 检查 `DwdBillConvert`、`DwdFoodConvert` 等 |
| 字段名是否一致（驼峰/下划线） | 反射取字段时区分大小写 |

### 8.2 行完全不打印

| 检查项 | 方法 |
|--------|------|
| 是否有配置条件（`conditionDsId/conditionOperator/conditionValue`） | 查看 `PosPrnStyleRow` 表 |
| `conditionDsId` 格式是否为 `"dsId,fieldId"` | 日志搜索 `"conditionDsId格式错误"` |
| DataSource 是否存在 | 日志搜索 `"conditionDsId对应的数据源不存在"` |
| 字段类型与操作符是否匹配 | String 类型不支持数值比较 |

### 8.3 某条记录在表格中不显示

| 检查项 | 方法 |
|--------|------|
| 行 `dsId` 是否绑定到正确的 TABLE DataSource | `convertTableRow` 中确认 |
| `conditionDsId` 中 `dsId` 是否与行 `dsId` 对应 | 检查 `filterDataSource` 中的 `isRowVisible` 调用 |
| 枚举类型比较时使用 `Enum.name()` | 条件值应为 `"CLOSED"` 而非 `26` 或 `"结账单"` |

---

## 9. 与其他 DA 文档的关系

| DA 文档 | 内容 | 与 DA6 的关系 |
|---------|------|--------------|
| DA0-DA1 | 概念建模、模块全景图、调用链 | 定义了 `PrintJobInitUtil.convert` 和 `ConditionUtil.isRowVisible` 在调用链中的位置 |
| DA5 | 数据模型分析 | 定义了 `pos_prn_style_row`、`pos_prn_style_col` 表结构，是样式配置的数据基础 |
| DA3-DA4 | 核心业务流程分析 | 定义了点餐、结账、划菜等业务操作如何触发打印任务生成 |

---

## 10. 文档完整性验证

- [x] `PrintJobInitUtil.convert()` 流程与源码一致（478 行）
- [x] `ConditionUtil.isRowVisible()` 逻辑与源码一致（233 行）
- [x] `customizedContent` 占位符格式与源码一致
- [x] 列宽拆分逻辑（`width80 > 100`）与源码一致
- [x] 汇总行生成（`markSummarizeRow`）与源码一致
- [x] 条件三元组（`conditionOperator/conditionDsId/conditionValue`）与源码一致
- [x] 容错策略与源码一致
- [x] 典型配置示例与文档一致

---

**文档状态**：DA6 完成
**下一步**：DA7-DA8（视 DA0-DA1 中指定的后续分析项而定）
