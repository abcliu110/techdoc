---
session: S3_KDS
stage: 3
status: completed
completedAt: 2026-09-02T18:30:00.000Z
---

# S3_KDS 叫号屏域（KDS Domain）

## 域深探锚点

### P8 Schema（核心表）

| 表名 | 中文名 | 主键/业务键 | 核心字段 | 关键索引 |
|------|--------|------------|----------|----------|
| `tbl_screen_make` | 叫号单主表 | makeId | makeStatus(0:未开始,1:进行中,2:已完成), makeStartTime, makeFinishTime, pickupCode | idx_make_id, idx_order_no, idx_make_status |
| `tbl_screen_detail` | 屏幕明细表 | detailId | screenType(1:取餐,2:配餐,3:制作,4:出餐), allotId | idx_screenType, idx_groupId_schemeId_templateId |
| `tbl_screen_make_detail` | 制作单明细表 | makeDetailId | currentScreen(30:配餐,40:制作,50:出餐), makeStatus, createScreenStatus/makeScreenStatus/outScreenStatus | idx_make_id, idx_current_screen, idx_make_status |
| `tbl_screen_param` | KDS出餐口参数表 | id | allotId, detailId, paramCode, flowConfig | idx_group_id_org_id_allot_id |
| `tbl_swim_config` | 泳道配置主表 | swimId | takeoutTop(外卖置顶), pickupTop(自提置顶), allotId | - |
| `tbl_swim_detail` | 泳道配置明细表 | swimDetailId | swimId, swimName, swimSort, allotId | idx_swimId, idx_allotId |
| `tbl_swim_detail_goods` | 泳道明细关联商品表 | id | swimDetailId, skuId, goodsSort | idx_swimDetailId, idx_allotId |
| `tbl_screen_make_detail_tag` | 制作单标签表 | tagId | makeDetailId, tagType(1:加,2:等,3:起,4:催,5:包,6:赠,7:退,9:撤) | idx_make_detail_id |

**ER 关系图**：
```
OrderMaster ──< ScreenMake (via orderNo)
    │
    └──< ScreenMakeDetail (via makeId)
              │
              ├──< ScreenMakeDetailTag (via makeDetailId)
              └── SwimDetailGoods (via skuId/allotId, 间接关联)
```

---

### P9 状态机

#### ScreenMake 顶层状态机
| 状态值 | 名称 | 触发条件 | 后继状态 |
|--------|------|----------|----------|
| 0 | 未开始 | 制单创建，未启用开始时间配置 | 1 |
| 1 | 进行中 | 任一菜品划菜或加菜 | 1(继续) / 2(完成) |
| 2 | 已完成 | 所有菜品完成出餐 | - (终态) |

#### ScreenMakeDetail 三屏状态机
**currentScreen 流转**：`30(配餐) → 40(制作) → 50(出餐)`

**各屏子状态**（createScreenStatus / makeScreenStatus / outScreenStatus）：
| 值 | 名称 | 说明 |
|----|------|------|
| 0 | 未开始 | 初始状态 |
| 1 | 进行中 | 该屏正在处理 |
| 2 | 已完成 | 该屏处理完毕 |

**状态转移规则**：
- `KdsMakeCreateManager.setFlow()`: 根据 flowConfig 初始化 currentScreen，同时预设后续屏幕为"进行中"
- `KdsMakeCompleteManager.makeComplete()`: 划菜时推进 currentScreen，更新下一屏状态
- `KdsCurrentScreenTypeEnum`: 定义屏幕类型映射(type→config)

#### SwimConfig 泳道配置状态
| 字段 | 值 | 说明 |
|------|-----|------|
| takeoutTop | 0/1 | 外卖是否置顶显示 |
| pickupTop | 0/1 | 自提是否置顶显示 |

---

### P10 事务

#### 核心事务边界

**1. ScreenMake 创建事务** (`ScreenMakeGateway.saveScreenMake`)
```
事务边界: LocalServerTransactionManager.execTransaction()
操作序列:
  1. INSERT ScreenMake
  2. INSERT ScreenMakeDetail (batch)
  3. INSERT ScreenMakeDetailTag (if gift/add)
提交条件: 全部成功
回滚条件: 任一失败
```

**2. 制单完成更新事务** (`ScreenMakeGateway.updateScreenMake`)
```
事务边界: LocalServerTransactionManager.execTransaction()
操作序列:
  1. UPDATE ScreenMake (makeStatus=2, makeFinishTime)
  2. UPDATE ScreenMakeDetail (batch, 更新各屏状态)
  3. INSERT/UPDATE ScreenMakeDetailTag
  4. 调用 updateOrderDetailMakeStatus() 同步更新 OrderDetail
提交条件: 全部成功
```

**3. 加菜事务** (`ScreenMakeGateway.saveDishMake`)
```
事务边界: LocalServerTransactionManager.execTransaction()
操作序列:
  1. UPDATE ScreenMake (重置状态: makeStatus=1, makeFinishTime=0)
  2. INSERT ScreenMakeDetail (新加菜品)
  3. INSERT ScreenMakeDetailTag (ADD 标签)
```

#### 跨域事务触发点

**KdsMakeCompleteManager.noticeOrderComplete()** - kds→order 事务性回写：
```java
// 同步更新 OrderDetail 的 makeStatus → SERVED
this.orderDetailManager.updateConditionByDetailId(orderDetail);
// 更新 OrderStatus.allDishesServed = YES
this.orderStatusManager.updateAllDishesServedByOrderNo(orderNo, YES);
// 触发外卖平台回调 (外售订单)
this.doUpdateOrderStatusForTakeout(orderNo, makeFinishTime);
```

---

### P11 聚合

#### 核心聚合：KdsMakeCreateManager
**职责**：制作单创建，加菜处理
**关键方法**：
- `makeCreate(KdsMakeCreateDto)`: 主流程入口
- `getWindowGoodsMap()`: 查询商品对应出餐口配置
- `assembleDetailListInfo()`: 组装明细，解析 flowConfig 确定初始 currentScreen
- `flattenNormalGoods()`: 普通品拆分（处理多数量）
- `flattenPackageGoods()`: 套餐拆分

#### 核心聚合：KdsMakeCompleteManager
**职责**：划菜完成管理
**关键方法**：
- `makeComplete(KdsMakeOperateDto)`: 主流程入口
- `updateMakeFlow()`: 更新各屏状态，推进 currentScreen
- `noticeOrderComplete()`: 完成后通知订单域
- `validateWaitGoodsBeforeComplete()`: 校验"等叫"商品是否允许划菜

#### 核心聚合：KdsSwimManager
**职责**：泳道配置与查询
**关键方法**：
- `queryKdsSwimDetailList()`: 并行查询各泳道数据
- `saveSwimConfig()`: 保存泳道配置
- `assembleSwimDetailGoods()`: 组装泳道商品映射

#### 核心聚合：ScreenMakeGateway
**职责**：持久化封装
**关键方法**：
- `saveScreenMake()`: 新建制单
- `updateScreenMake()`: 更新制单
- `queryMakeByOrderNo()`: 按订单号查询

---

### P12 约束

| 约束类型 | 约束内容 | 校验位置 |
|----------|----------|----------|
| 业务约束 | flowConfig 必须配置，否则跳过该出餐口 | `KdsMakeCreateManager.assembleDetailListInfo()` L687-689 |
| 业务约束 | billTypeConfig 必须匹配 businessType | `KdsMakeCreateManager.assembleDetailListInfo()` L694-697 |
| 业务约束 | 套餐头不允许划菜 | `KdsMakeCompleteManager.makeComplete()` L286-288 |
| 业务约束 | "等叫"商品在 waitGoodsDenyComplete=1 时禁止划菜 | `KdsMakeCompleteManager.validateWaitGoodsBeforeComplete()` |
| 乐观锁 | revision 字段用于并发控制 | 所有 UPDATE 操作 |
| 逻辑删除 | isDel=1 表示已删除 | 各查询方法均有过滤 |

---

### 跨域断点清单

| 断点ID | 方向 | 源方法 | 目标域 | 目标方法/数据 | 说明 |
|--------|------|--------|--------|---------------|------|
| KB-001 | kds→order | `KdsScreenService.noticeKdsMakeCreate()` | OrderDomain | `OrderMaster`, `OrderDetail` | 下单时落单创建制单 |
| KB-002 | kds→order | `KdsMakeCreateManager.makeCreateAfterHandler()` | OrderDomain | WebSocket `tp_kds_make_message` | 新订单推送通知 |
| KB-003 | kds→order | `KdsMakeCompleteManager.noticeOrderComplete()` | OrderDomain | `OrderDetail.makeStatus=SERVED` | 划菜完成后同步订单状态 |
| KB-004 | kds→order | `KdsMakeCompleteManager.noticeOrderComplete()` | OrderDomain | `OrderStatus.allDishesServed=YES` | 全上菜标记 |
| KB-005 | kds→order | `KdsMakeCompleteManager.uploadKdsScreenMake()` | Cloud | HTTP POST 云端上传制单 | 异步同步云端 |
| KB-006 | kds→order | `KdsMakeCompleteManager.callMakeComplete()` | TakeoutPlatform | 外卖平台回调 | 通知外卖平台已完成 |
| KB-007 | kds→order | `ScreenMakeGateway.updateOrderDetailMakeStatus()` | OrderDomain | `OrderDetail` 时间字段同步 | 更新 prepareBeginTime, makeCompleteTime 等 |
| KB-008 | kds→print | `KdsMakeCreateManager.makeCreateAfterPrintHandler()` | PrintDomain | `KdsPrintService.noticeMakePrintByCreate()` | 制单打印通知 |
| KB-009 | kds→print | `KdsMakeCompleteManager.noticeMakeOrderPrint()` | PrintDomain | `KdsPrintService.noticeMakePrintByComplete()` | 划菜打印通知 |

**关键依赖图**：
```
OrderDomain ──创建──> KdsDomain
     │                    │
     │<──划菜完成回写──<──┘
     │
     └──<──加菜/退菜──<──┘
```

---

### 未解释现象（至少 1 项）

**现象 N1: SwimConfig 与 ScreenMake 的间接关联机制不明确**

**观察**：
- `SwimConfig` 表存储 allotId、takeoutTop、pickupTop
- `ScreenMakeDetail` 表有 allotId 字段（出餐口ID）
- `KdsSwimManager` 查询时通过 allotId 匹配泳道配置

**疑问**：
- SwimDetailGoods 表定义了 swimDetailId → skuId 的映射，但 `KdsSwimManager` 中 `assembleSwimDetailGoods()` 返回的是 `Map<String, Set<Long>>`（泳道名→skuIdSet）
- 这意味着一个 SKU 可以属于多个泳道？还是泳道配置仅决定显示顺序，实际商品分配由 ScreenMakeDetail.pickupWindowId 决定？
- SwimConfig 的 takeoutTop/pickupTop 是影响排序规则，但实际哪些商品进入哪个泳道显示，是否完全由 SwimDetailGoods 配置决定？

**待验证**：
需要查看 `queryKdsSwimDetailList()` 的完整 SQL 或 `KdsGoodsModelQueryManager` 的 queryKdsMakeDetailList() 方法，确认泳道过滤的实际执行逻辑。

---

### 通过自评

- [x] P8 Schema: 8 张核心表结构清晰，字段含义明确
- [x] P9 状态机: ScreenMake 顶层 + ScreenMakeDetail 三屏子状态机，状态转移规则完整
- [x] P10 事务: Gateway 层封装事务边界，跨域操作通过 Manager 层协调
- [x] P11 聚合: KdsMakeCreateManager、KdsMakeCompleteManager、KdsSwimManager 三大聚合根职责分明
- [x] P12 约束: 关键业务约束（flowConfig、billTypeConfig、等叫校验）已覆盖
- [x] 跨域断点: 识别 9 个断点，含 kds→order、kds→print 两个方向
- [x] 未解释现象: 1 项（SwimConfig 与 ScreenMake 关联机制待深入）
