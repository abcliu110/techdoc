# POS门店与云端表同步对应关系

## 1. 结论

POS 门店基础数据同步不是简单按同名表同步，而是分为两层映射：

1. 云端 `pos4cloud` 使用 ShardingSphere 配置，把业务逻辑表路由到实际云端表。
2. 门店 `pos3boot` 收到云端 Canal 事件后，按事件里的 `tbl_name` 查 `IncrementalSyncDataService.CLASS_MAP`，再落到本地实体和本地表。

因此排查同步问题时，应优先看 `tbl_name` 是什么，再查它在 `CLASS_MAP` 中对应的本地实体。

## 2. 同步链路

```text
云端数据库表变更
  -> nms4cloud-pos5sync 通过 Canal 采集变更
  -> 写入 Kafka topic: nms4cloud-pos5sync
  -> nms4cloud-pos4cloud 监听 Kafka
  -> 按消息里的 sid 通过 Netty 推给对应门店
  -> 门店 nms4cloud-pos3boot 接收 /sync/syncByCanalEvent
  -> IncrementalSyncDataService 根据 tbl_name 找本地实体
  -> 按 mid/sid/lid 更新或插入本地表
```

## 3. 云端事件表到门店本地表对应关系

| 云端事件表 tbl_name | 门店本地表 | 门店实体 | 数据类型 |
| --- | --- | --- | --- |
| `sc_mall_discount_dish` | `biz_discount_dish` | `BizDiscountDish` | 门店业务数据 |
| `sc_mall_discount_tbl_type` | `biz_discount_tbl_type` | `BizDiscountTblType` | 门店业务数据 |
| `sc_mall_discount` | `biz_discount` | `BizDiscount` | 门店业务数据 |
| `sc_mall_auto_order` | `pt_auto_order` | `PtAutoOrder` | 门店业务数据 |
| `sc_mall_gift_dish_reason` | `biz_gift_reason` | `BizGiftReason` | 门店业务数据 |
| `sc_mall_retreat_dish_reason` | `biz_retreat_reason` | `BizRetreatReason` | 门店业务数据 |
| `sc_pay_way` | `biz_pay_way` | `BizPayWay` | 门店业务数据 |
| `sc_business_hours` | `biz_business_hours` | `BizBusinessHours` | 门店业务数据 |
| `sc_merchant` | `sc_merchant` | `ScMerchant` | 总部/商户数据 |
| `sc_store` | `sc_store` | `ScStore` | 总部/门店数据 |
| `sc_usr` | `biz_user` | `BizUser` | 总部/用户数据 |
| `sc_config_of_shop` | `sys_config_data` | `SysConfigData` | 总部/门店配置 |
| `sc_permission` | `sys_user_data_scope` | `SysUserDataScope` | 用户数据权限，命名不直观 |
| `sys_permission` | `sys_permission` | `SysPermission` | 平台权限数据 |
| `sys_role` | `sys_role` | `SysRole` | 平台/角色数据 |
| `sys_role_permission` | `sys_role_permission` | `SysRolePermission` | 平台/角色权限数据 |
| `sys_role_data_scope` | `sys_role_data_scope` | `SysRoleDataScope` | 平台/角色数据范围 |
| `sys_user_role` | `sys_user_role` | `SysUserRole` | 平台/用户角色数据 |
| `pt_dish` | `pt_dish` | `PtDish` | 门店菜品数据 |
| `sc_dish` | `pt_dish` | `PtDish` | 云端旧表名/实际表名也落本地菜品 |
| `sc_dish_type` | `pt_dish_type` | `PtDishType` | 门店菜品分类 |
| `sc_dish_unit` | `pt_dish_unit` | `PtDishUnit` | 门店菜品单位 |
| `sc_dish_map` | `pt_dish_map` | `PtDishMap` | 门店套餐/菜品映射 |
| `caipingzuofa` | `pt_cookway` | `PtCookway` | 云端旧做法表名 |
| `pt_cookway` | `pt_cookway` | `PtCookway` | 门店做法 |
| `pt_cookway_type` | `pt_cookway_type` | `PtCookwayType` | 门店做法分类 |
| `pt_cook_ref` | `pt_cook_ref` | `PtCookRef` | 门店做法关联 |
| `pt_cook_type` | `pt_cook_type` | `PtCookType` | 门店做法类型 |
| `pt_dish_flavor` | `pt_dish_flavor` | `PtDishFlavor` | 门店菜品口味 |
| `pt_flavor_type` | `pt_flavor_type` | `PtFlavorType` | 门店口味分类 |
| `pt_dish_area` | `pt_dish_area` | `PtDishArea` | 门店菜品区域/部位 |
| `pt_dish_table_price` | `pt_dish_table_price` | `PtDishTablePrice` | 门店桌台价 |
| `pt_dish_price_special` | `pt_dish_price_special` | `PtDishPriceSpecial` | 门店特价 |
| `pt_festival` | `pt_festival` | `PtFestival` | 门店节假日 |
| `sc_tbl` | `pt_tbl` | `PtTbl` | 云端旧桌台表名 |
| `pt_tbl` | `pt_tbl` | `PtTbl` | 门店桌台 |
| `sc_tbl_area` | `pt_tbl_area` | `PtTblArea` | 云端旧桌台区域表名 |
| `pt_tbl_area` | `pt_tbl_area` | `PtTblArea` | 门店桌台区域 |
| `sc_tbl_type` | `pt_tbl_type` | `PtTblType` | 云端旧桌台类型表名 |
| `pt_tbl_type` | `pt_tbl_type` | `PtTblType` | 门店桌台类型 |
| `pos_dev` | `pos_dev` | `PosDev` | 门店设备 |
| `pos_prn_queue` | `pos_prn_queue` | `PosPrnQueue` | 门店打印队列 |
| `pos_prn_printer` | `pos_prn_printer` | `PosPrnPrinter` | 门店打印机 |
| `pos_dish_hide` | `pos_dish_hide` | `PosDishHide` | 门店菜品隐藏 |
| `pos_reason_type` | `pos_reason_type` | `PosReasonType` | 门店原因类型 |
| `pos_auto_discount` | `pos_auto_discount` | `PosAutoDiscount` | 门店自动折扣 |
| `pos_dept` | `pos_dept` | `PosDept` | 门店部门 |
| `pos_waiter_bill_setting` | `pos_waiter_bill_setting` | `PosWaiterBillSetting` | 门店服务员账单设置 |
| `pos_dish_to_prn_dept` | `pos_dish_to_prn_dept` | `PosDishToPrnDept` | 门店菜品打印部门 |
| `pos_customer_bill_setting` | `pos_customer_bill_setting` | `PosCustomerBillSetting` | 门店客户账单设置 |
| `pt_member_price` | `pt_member_price` | `PtMemberPrice` | 门店会员价 |

## 4. 云端逻辑表到实际表路由

`nms4cloud-pos4cloud.yaml` 中配置了部分逻辑表到云端实际表的路由。典型对应如下：

| 逻辑表 | 云端实际表 |
| --- | --- |
| `biz_user` | `mycat.sc_usr` |
| `sys_config_data` | `mycat.sc_config_of_shop` |
| `sys_user_data_scope` | `mycat.sc_permission` |
| `sc_merchant` | `mycat.sc_merchant` |
| `sc_store` | `mycat.sc_store` |
| `pt_dish` | `mycat.sc_dish` |
| `pt_dish_type` | `mycat.sc_dish_type` |
| `pt_dish_unit` | `mycat.sc_dish_unit` |
| `pt_dish_map` | `mycat.sc_dish_map` |
| `pt_cookway` | `mycat.caipingzuofa` |
| `pt_cookway_type` | `mycat.zuofaleibie` |
| `biz_gift_reason` | `mycat.sc_mall_gift_dish_reason` |
| `biz_retreat_reason` | `mycat.sc_mall_retreat_dish_reason` |
| `biz_discount` | `mycat.sc_mall_discount` |
| `biz_discount_dish` | `mycat.sc_mall_discount_dish` |
| `biz_discount_tbl_type` | `mycat.sc_mall_discount_tbl_type` |
| `biz_pay_way` | `mycat.sc_pay_way` |
| `biz_income` | `mycat.sc_income` |
| `biz_income_type` | `mycat.sc_income_type` |
| `biz_department` | `mycat.sc_department` |
| `biz_business_hours` | `mycat.sc_business_hours` |
| `pt_tbl_type` | `mycat.sc_tbl_type` |
| `pt_tbl` | `mycat.sc_tbl` |
| `pt_tbl_area` | `mycat.sc_tbl_area` |
| `sys_brand` | `mycat.sc_brand` |

注意：第 4 节是云端应用自己的逻辑表路由；第 3 节是门店增量同步最终使用的事件表名到本地表映射。排查门店不同步时，第 3 节优先级更高。

## 5. 关键实现依据

- `nms4cloud-pos5sync/.../CanalWorker.java`
  - `connector.subscribe(".*\\..*")` 订阅所有库表变更。
  - 收到 Canal entries 后调用 `CanalEventService.handleCanalEvent(...)`。

- `nms4cloud-pos5sync/.../CanalEventService.java`
  - 从 Canal header 读取 `schemaName` 和 `tableName`。
  - 通过 `tablesToBeMonitoredServicePlus.needSync(tableName)` 判断表是否需要同步。
  - 从字段 `COMPANY_ID/MID`、`SHOP_ID/SID`、`LMNID/LID` 提取 `mid/sid/lid`。
  - 写入 Kafka 消息字段：`mid`、`sid`、`lid`、`tbl_name`、`type`、`log_file_name`、`content`。

- `nms4cloud-pos4cloud/.../KafkaListenerForSync.java`
  - 监听 Kafka topic `nms4cloud-pos5sync`。
  - 按 `canalEvent.sid + "_server"` 通过 Netty 推给对应门店。
  - 请求地址为 `/sync/syncByCanalEvent`。

- `nms4cloud-pos3boot/.../SyncByCanalEventConsumer.java`
  - 门店接收消息后转成 `CanalEventVO`。
  - 调用 `IncrementalSyncDataService.handleEvent(canalEvent)`。

- `nms4cloud-pos3boot/.../IncrementalSyncDataService.java`
  - `CLASS_MAP` 是云端事件表名到门店实体的核心映射。
  - 通用处理逻辑按 `lid` 先更新，更新不到再插入。
  - 删除事件按 `mid/sid/lid` 删除本地记录。
  - `PtTblArea`、`PtDish`、`PosDev` 有专用事件处理器。

## 6. 排查建议

当出现某张表不同步时，按下面顺序排查：

1. 确认云端实际变更表名，也就是 Canal 事件里的 `tbl_name`。
2. 查 `IncrementalSyncDataService.CLASS_MAP` 是否存在该 `tbl_name`。
3. 查本地实体 `@Table(value = "...")` 是否对应正确本地表。
4. 查该实体是否已注册到 `SyncBaseDataService.classMapper`。
5. 查该表是否需要特殊事件处理器，例如 `PtDish`、`PtTblArea`、`PosDev`。
6. 查门店本地 `mid/sid/lid` 字段是否能从事件 content 中解析出来。

