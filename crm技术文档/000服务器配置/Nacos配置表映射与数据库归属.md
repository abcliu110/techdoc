# Nacos 配置表映射与数据库归属

## 范围与口径

- 配置源：D:\mywork\techdoc\服务部署文档\nacos_config_export\DEFAULT_GROUP 中的 22 份 DEFAULT_GROUP YAML 导出文件。
- 生成时间：2026-08-13。
- 本文仅记录配置中显式声明的 JDBC 数据库名和 ShardingSphere `actual-data-nodes` 路由；未声明路由规则的表无法由该配置反推出。
- 为避免泄露，本文不记录用户名、密码、私钥、Token、Redis/OSS/MQ 凭据或完整 JDBC 地址。
- `mycat` 是配置中的逻辑数据源名，JDBC 指向 `gylregdb`；该配置不能证明 Mycat 后端是否进一步分库分表。本文的“数据库”是应用配置可见的连接库名。
- `nms4cloud-payment.yaml` 中 `self` 数据源的键与注释同一行，常规 YAML 解析不稳定；其紧随 `pay` 数据源且 URL 同为 `a_payment`，文中以“同配置推断”标记。

## 配置文件

- nms4cloud-bi.yaml
- nms4cloud-biz.yaml
- nms4cloud-crm.yaml
- nms4cloud-docking.yaml
- nms4cloud-doctor.yaml
- nms4cloud-mall.yaml
- nms4cloud-mq.yaml
- nms4cloud-netty.yaml
- nms4cloud-order.yaml
- nms4cloud-payment.yaml
- nms4cloud-platform.yaml
- nms4cloud-pos.yaml
- nms4cloud-pos11lowcode.yaml
- nms4cloud-pos11report.yaml
- nms4cloud-pos4cloud.yaml
- nms4cloud-pos5sync.yaml
- nms4cloud-pos8book.yaml
- nms4cloud-pos9cash.yaml
- nms4cloud-product.yaml
- nms4cloud-shared.yaml
- nms4cloud-wechat.yaml
- nms4cloud-wms.yaml

## 数据源到数据库

| 配置文件 | 数据源名 | 引擎 | 数据库 | 证据 |
| --- | --- | --- | --- | --- | --- |
| nms4cloud-biz.yaml | biz | mysql | a_biz | direct |
| nms4cloud-biz.yaml | mycat | mysql | gylregdb | direct |
| nms4cloud-crm.yaml | crm | mysql | a_crm | direct |
| nms4cloud-crm.yaml | mycat | mysql | gylregdb | direct |
| nms4cloud-order.yaml | mycat | mysql | gylregdb | direct |
| nms4cloud-order.yaml | order | mysql | a_order | direct |
| nms4cloud-payment.yaml | mycat | mysql | gylregdb | direct |
| nms4cloud-payment.yaml | pay | mysql | a_payment | direct |
| nms4cloud-platform.yaml | mycat | mysql | gylregdb | direct |
| nms4cloud-platform.yaml | platform | mysql | a_platform | direct |
| nms4cloud-pos11report.yaml | biz | mysql | a_biz | direct |
| nms4cloud-pos11report.yaml | mycat | mysql | gylregdb | direct |
| nms4cloud-pos11report.yaml | platform | mysql | a_platform | direct |
| nms4cloud-pos11report.yaml | pos | mysql | a_pos | direct |
| nms4cloud-pos11report.yaml | pt | mysql | a_product | direct |
| nms4cloud-pos4cloud.yaml | biz | mysql | a_biz | direct |
| nms4cloud-pos4cloud.yaml | mycat | mysql | gylregdb | direct |
| nms4cloud-pos4cloud.yaml | platform | mysql | a_platform | direct |
| nms4cloud-pos4cloud.yaml | pos | mysql | a_pos | direct |
| nms4cloud-pos4cloud.yaml | pt | mysql | a_product | direct |
| nms4cloud-pos9cash.yaml | biz | mysql | a_biz | direct |
| nms4cloud-pos9cash.yaml | mycat | mysql | gylregdb | direct |
| nms4cloud-pos9cash.yaml | platform | mysql | a_platform | direct |
| nms4cloud-pos9cash.yaml | pos | mysql | a_pos | direct |
| nms4cloud-pos9cash.yaml | pt | mysql | a_product | direct |
| nms4cloud-product.yaml | mycat | mysql | gylregdb | direct |
| nms4cloud-product.yaml | pt | mysql | a_product | direct |
| nms4cloud-wechat.yaml | mycat | mysql | gylregdb | direct |
| nms4cloud-wechat.yaml | wechat | mysql | a_wechat | direct |
| nms4cloud-wms.yaml | mycat | mysql | gylregdb | direct |
| nms4cloud-wms.yaml | wms | mysql | a_wms | direct |

## 逻辑表到实际表

共提取到 525 条显式表路由记录。同一逻辑表在多个服务配置中重复出现时保留多条记录，以反映调用服务边界。

<table>
<thead><tr><th>配置文件</th><th>逻辑表</th><th>数据源</th><th>实际表</th><th>数据库</th><th>证据</th></tr></thead>
<tbody>
<tr><td>nms4cloud-biz.yaml</td><td>biz_business_hours</td><td>mycat</td><td>sc_business_hours</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_department</td><td>mycat</td><td>sc_department</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_discount</td><td>mycat</td><td>sc_mall_discount</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_discount_dish</td><td>mycat</td><td>sc_mall_discount_dish</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_discount_tbl_type</td><td>mycat</td><td>sc_mall_discount_tbl_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_gift_reason</td><td>mycat</td><td>sc_mall_gift_dish_reason</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_income</td><td>mycat</td><td>sc_income</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_income_type</td><td>mycat</td><td>sc_income_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_key_value</td><td>biz</td><td>biz_key_value</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_pay_way</td><td>mycat</td><td>sc_pay_way</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_receipt_bind</td><td>biz</td><td>biz_receipt_bind</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_retreat_reason</td><td>mycat</td><td>sc_mall_retreat_dish_reason</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_shop_group</td><td>biz</td><td>biz_shop_group</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_sms_config</td><td>biz</td><td>biz_sms_config</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_sms_msg_content</td><td>mycat</td><td>sms_msg_content</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_sms_msg_style</td><td>mycat</td><td>sms_msg_style</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_sms_send_record</td><td>biz</td><td>biz_sms_send_record</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_user_map</td><td>biz</td><td>biz_user_map</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_user_storage</td><td>biz</td><td>biz_user_storage</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>biz_usr_merchant</td><td>mycat</td><td>biz_usr_merchant</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>invoice_info_store</td><td>biz</td><td>invoice_info_store</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>plat_areas</td><td>biz</td><td>plat_areas</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>plat_cities</td><td>biz</td><td>plat_cities</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>plat_provinces</td><td>biz</td><td>plat_provinces</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>sc_merchant</td><td>mycat</td><td>sc_merchant</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>sc_product_price</td><td>mycat</td><td>sc_product_price</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>sc_product_price_set</td><td>mycat</td><td>sc_product_price_set</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>sc_reg_dog</td><td>mycat</td><td>sc_reg_dog</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>sc_reg_dog_recharge_record</td><td>mycat</td><td>sc_reg_dog_recharge_record</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>sc_store</td><td>mycat</td><td>sc_store</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>sc_store_and_product</td><td>mycat</td><td>sc_store_and_product</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>sc_store_and_product_flow</td><td>mycat</td><td>sc_store_and_product_flow</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>store_intro_content</td><td>biz</td><td>store_intro_content</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>store_intro_group</td><td>biz</td><td>store_intro_group</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>sys_brand</td><td>mycat</td><td>sc_brand</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>wx_color</td><td>biz</td><td>wx_color</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>wx_componet</td><td>biz</td><td>wx_componet</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>wx_componet_item</td><td>biz</td><td>wx_componet_item</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>wx_navigation</td><td>biz</td><td>wx_navigation</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>wx_page</td><td>biz</td><td>wx_page</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>wx_program_template</td><td>biz</td><td>wx_program_template</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-biz.yaml</td><td>wx_template_label</td><td>biz</td><td>wx_template_label</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_actuator</td><td>crm</td><td>crm_actuator</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_actuator_coupon</td><td>crm</td><td>crm_actuator_coupon</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_actuator_record</td><td>crm</td><td>crm_actuator_record</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_advertising_scheme</td><td>mycat</td><td>crm_advertising_scheme</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_advertising_scheme_and_shop</td><td>mycat</td><td>crm_advertising_scheme_and_shop</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_advertising_scheme_item</td><td>mycat</td><td>crm_advertising_scheme_item</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_birthday_record</td><td>crm</td><td>crm_birthday_record</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_birthday_rule</td><td>crm</td><td>crm_birthday_rule</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card</td><td>mycat</td><td>crm_card</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_balance</td><td>crm</td><td>crm_card_balance</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_cost_task</td><td>crm</td><td>crm_card_cost_task</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_grade_record</td><td>crm</td><td>crm_card_grade_record</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_level</td><td>mycat</td><td>crm_card_level</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_level_and_cash_back</td><td>mycat</td><td>crm_card_level_and_cash_back</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_level_and_more_recharge</td><td>mycat</td><td>crm_card_level_and_more_recharge</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_level_and_overlord_meal</td><td>mycat</td><td>crm_card_level_and_overlord_meal</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_map</td><td>crm</td><td>crm_card_map</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_op_record</td><td>mycat</td><td>crm_card_op_record</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_points_record</td><td>mycat</td><td>crm_card_points_record</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_record</td><td>mycat</td><td>crm_card_record</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_type</td><td>mycat</td><td>crm_card_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_type_free_rule</td><td>mycat</td><td>crm_card_type_free_rule</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_upgrade_record</td><td>crm</td><td>crm_card_upgrade_record</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_card_wx_user</td><td>crm</td><td>crm_card_wx_user</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_cash_back</td><td>mycat</td><td>crm_card_level_and_cash_back</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_cash_back_food</td><td>mycat</td><td>sc_mall_cash_back_food</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_consume_coupon_food</td><td>mycat</td><td>sc_mall_consume_coupon_food</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_consumption_coupon_limit</td><td>crm</td><td>crm_consumption_coupon_limit</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_consumption_coupon_rule</td><td>crm</td><td>crm_consumption_coupon_rule</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_coupon</td><td>mycat</td><td>sc_mall_coupon</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_coupon_dish</td><td>crm</td><td>crm_coupon_dish</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_coupon_festival</td><td>mycat</td><td>sc_mall_coupon_festival</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_coupon_hours</td><td>mycat</td><td>sc_mall_coupon_hours</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_coupon_map</td><td>mycat</td><td>sc_mall_coupon_map</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_coupon_order</td><td>mycat</td><td>sc_mall_coupon_order</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_coupon_proportion_item</td><td>mycat</td><td>sc_coupon_proportion_item</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_coupon_purchase</td><td>mycat</td><td>sc_mall_coupon_purchase</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_coupon_task</td><td>crm</td><td>crm_coupon_task</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_deal_task</td><td>crm</td><td>crm_deal_task</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_deal_task_item</td><td>crm</td><td>crm_deal_task_item</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_envelope_proportion</td><td>mycat</td><td>sc_envelope_proportion</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_festival</td><td>mycat</td><td>sc_mall_festival</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_filter</td><td>crm</td><td>crm_filter</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_filter_item</td><td>crm</td><td>crm_filter_item</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_gift_coupon_food</td><td>mycat</td><td>sc_mall_gift_coupon_food</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_invitation_reward</td><td>mycat</td><td>sc_invitation_reward</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_join_activity</td><td>mycat</td><td>crm_join_activity</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_join_activity_shop</td><td>mycat</td><td>crm_join_activity_shop</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_large_turntable</td><td>mycat</td><td>sc_large_turntable</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_large_turntable_item</td><td>mycat</td><td>sc_large_turntable_item</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_member</td><td>mycat</td><td>crm_member</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_new_gift</td><td>mycat</td><td>sc_new_gift</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_new_gift_store</td><td>mycat</td><td>sc_new_gift_store</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_overlord_once</td><td>crm</td><td>crm_overlord_once</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_overlord_store</td><td>crm</td><td>crm_overlord_store</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_point_exchange</td><td>mycat</td><td>sc_mall_point_exchange</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_red_envelope</td><td>mycat</td><td>sc_mall_red_envelope</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_reward_record</td><td>crm</td><td>crm_reward_record</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_reward_rule</td><td>crm</td><td>crm_reward_rule</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_save_rule</td><td>mycat</td><td>crm_save_rule</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_save_rule_interval</td><td>mycat</td><td>crm_save_rule_interval</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_shop_in_card_type</td><td>mycat</td><td>crm_shop_in_card_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_store_divide_record</td><td>crm</td><td>crm_store_divide_record</td><td>a_crm</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>crm_store_in_coupon</td><td>mycat</td><td>sc_store_in_mall_coupon</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-crm.yaml</td><td>pos_give_bill</td><td>mycat</td><td>pos_give_bill</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-order.yaml</td><td>order_bill</td><td>order</td><td>order_bill</td><td>a_order</td><td>direct</td></tr>
<tr><td>nms4cloud-order.yaml</td><td>order_comment</td><td>order</td><td>order_comment</td><td>a_order</td><td>direct</td></tr>
<tr><td>nms4cloud-order.yaml</td><td>order_food</td><td>order</td><td>order_food</td><td>a_order</td><td>direct</td></tr>
<tr><td>nms4cloud-order.yaml</td><td>order_free_food_record</td><td>order</td><td>order_free_food_record</td><td>a_order</td><td>direct</td></tr>
<tr><td>nms4cloud-order.yaml</td><td>order_pay</td><td>order</td><td>order_pay</td><td>a_order</td><td>direct</td></tr>
<tr><td>nms4cloud-order.yaml</td><td>order_rebate</td><td>order</td><td>order_rebate</td><td>a_order</td><td>direct</td></tr>
<tr><td>nms4cloud-order.yaml</td><td>order_taste</td><td>order</td><td>order_taste</td><td>a_order</td><td>direct</td></tr>
<tr><td>nms4cloud-payment.yaml</td><td>pay_channel</td><td>pay</td><td>pay_channel</td><td>a_payment</td><td>direct</td></tr>
<tr><td>nms4cloud-payment.yaml</td><td>pay_order</td><td>self</td><td>pay_order</td><td>a_payment</td><td>inferred-from-same-config</td></tr>
<tr><td>nms4cloud-payment.yaml</td><td>pay_store_and_channel</td><td>pay</td><td>pay_store_and_channel</td><td>a_payment</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>biz_user</td><td>mycat</td><td>sc_usr</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>inst_user</td><td>mycat</td><td>sc_inst_adm</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sc_inst_and_product</td><td>mycat</td><td>sc_inst_and_product</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sc_inst_finance_bill</td><td>mycat</td><td>sc_inst_finance_bill</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sc_inst_op_log</td><td>mycat</td><td>sc_inst_op_log</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sc_inst_recharge_set</td><td>mycat</td><td>sc_inst_recharge_set</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sc_product_price</td><td>mycat</td><td>sc_product_price</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sc_product_price_set</td><td>mycat</td><td>sc_product_price_set</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sc_reg_dog</td><td>mycat</td><td>sc_reg_dog</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sc_reg_dog_recharge_record</td><td>mycat</td><td>sc_reg_dog_recharge_record</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sc_store_and_product</td><td>mycat</td><td>sc_store_and_product</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sc_store_and_product_flow</td><td>mycat</td><td>sc_store_and_product_flow</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sys_config_data</td><td>mycat</td><td>sc_config_of_shop</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sys_inst</td><td>mycat</td><td>sc_inst</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sys_merchant</td><td>mycat</td><td>sc_merchant</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sys_store</td><td>mycat</td><td>sc_store</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-platform.yaml</td><td>sys_user_data_scope</td><td>mycat</td><td>sc_permission</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>Bi_DianCaiPiCi</td><td>mycat</td><td>bi_diancaipici</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_business_hours</td><td>mycat</td><td>sc_business_hours</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_department</td><td>mycat</td><td>sc_department</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_discount</td><td>mycat</td><td>sc_mall_discount</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_discount_dish</td><td>mycat</td><td>sc_mall_discount_dish</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_discount_tbl_type</td><td>mycat</td><td>sc_mall_discount_tbl_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_gift_reason</td><td>mycat</td><td>sc_mall_gift_dish_reason</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_income</td><td>mycat</td><td>sc_income</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_income_type</td><td>mycat</td><td>sc_income_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_key_value</td><td>biz</td><td>biz_key_value</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_pay_way</td><td>mycat</td><td>sc_pay_way</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_receipt_bind</td><td>biz</td><td>biz_receipt_bind</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_retreat_reason</td><td>mycat</td><td>sc_mall_retreat_dish_reason</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_shop_group</td><td>biz</td><td>biz_shop_group</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_sms_config</td><td>biz</td><td>biz_sms_config</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_sms_msg_content</td><td>mycat</td><td>sms_msg_content</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_sms_msg_style</td><td>mycat</td><td>sms_msg_style</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_sms_send_record</td><td>biz</td><td>biz_sms_send_record</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_user</td><td>mycat</td><td>sc_usr</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_user_map</td><td>biz</td><td>biz_user_map</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_user_storage</td><td>biz</td><td>biz_user_storage</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>biz_usr_merchant</td><td>mycat</td><td>biz_usr_merchant</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>CaiShiFa</td><td>mycat</td><td>caishifa</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>FuKuanQingKuang</td><td>mycat</td><td>fukuanqingkuang</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>invoice_info_store</td><td>biz</td><td>invoice_info_store</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>JiaoBanXinXi</td><td>mycat</td><td>jiaobanxinxi</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>plat_areas</td><td>biz</td><td>plat_areas</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>plat_cities</td><td>biz</td><td>plat_cities</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>plat_provinces</td><td>biz</td><td>plat_provinces</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_app_ver</td><td>pos</td><td>pos_app_ver</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_auto_discount</td><td>pos</td><td>pos_auto_discount</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_dev</td><td>pos</td><td>pos_dev</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_dish_hide</td><td>pos</td><td>pos_dish_hide</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_group_dish_book</td><td>pos</td><td>pos_group_dish_book</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_group_dish_book_release</td><td>pos</td><td>pos_group_dish_book_release</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_overtime_interval_config</td><td>pos</td><td>pos_overtime_interval_config</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_package_config</td><td>pos</td><td>pos_package_config</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_pricing_by_time</td><td>pos</td><td>pos_pricing_by_time</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_pricing_by_time_mode</td><td>pos</td><td>pos_pricing_by_time_mode</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_pricing_by_time_period</td><td>pos</td><td>pos_pricing_by_time_period</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_pricing_by_time_timeout</td><td>pos</td><td>pos_pricing_by_time_timeout</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_prn_style_col</td><td>pos</td><td>pos_prn_style_col</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_prn_style_row</td><td>pos</td><td>pos_prn_style_row</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_reason_type</td><td>pos</td><td>pos_reason_type</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pos_time_period_config</td><td>pos</td><td>pos_time_period_config</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>print_job_type_switch</td><td>pos</td><td>print_job_type_switch</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_auto_order</td><td>mycat</td><td>sc_mall_auto_order</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_cookway</td><td>mycat</td><td>caipingzuofa</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_cookway_type</td><td>mycat</td><td>zuofaleibie</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_dish</td><td>mycat</td><td>sc_dish</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_dish_area</td><td>pt</td><td>pt_dish_area</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_dish_map</td><td>mycat</td><td>sc_dish_map</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_dish_price_special</td><td>pt</td><td>pt_dish_price_special</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_dish_table_price</td><td>pt</td><td>pt_dish_table_price</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_dish_type</td><td>mycat</td><td>sc_dish_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_dish_unit</td><td>mycat</td><td>sc_dish_unit</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_festival</td><td>pt</td><td>pt_festival</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_tbl</td><td>mycat</td><td>sc_tbl</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_tbl_area</td><td>mycat</td><td>sc_tbl_area</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>pt_tbl_type</td><td>mycat</td><td>sc_tbl_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sc_inst_and_product</td><td>mycat</td><td>sc_inst_and_product</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sc_inst_finance_bill</td><td>mycat</td><td>sc_inst_finance_bill</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sc_inst_op_log</td><td>mycat</td><td>sc_inst_op_log</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sc_inst_recharge_set</td><td>mycat</td><td>sc_inst_recharge_set</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sc_merchant</td><td>mycat</td><td>sc_merchant</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sc_product_price</td><td>mycat</td><td>sc_product_price</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sc_product_price_set</td><td>mycat</td><td>sc_product_price_set</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sc_reg_dog</td><td>mycat</td><td>sc_reg_dog</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sc_reg_dog_recharge_record</td><td>mycat</td><td>sc_reg_dog_recharge_record</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sc_store</td><td>mycat</td><td>sc_store</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sc_store_and_product</td><td>mycat</td><td>sc_store_and_product</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sc_store_and_product_flow</td><td>mycat</td><td>sc_store_and_product_flow</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>store_intro_content</td><td>biz</td><td>store_intro_content</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>store_intro_group</td><td>biz</td><td>store_intro_group</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sys_brand</td><td>mycat</td><td>sc_brand</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sys_config_data</td><td>mycat</td><td>sc_config_of_shop</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>sys_user_data_scope</td><td>mycat</td><td>sc_permission</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>takeout_aggregation_platform_channel</td><td>pos</td><td>takeout_aggregation_platform_channel</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>wx_color</td><td>biz</td><td>wx_color</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>wx_componet</td><td>biz</td><td>wx_componet</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>wx_componet_item</td><td>biz</td><td>wx_componet_item</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>wx_navigation</td><td>biz</td><td>wx_navigation</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>wx_page</td><td>biz</td><td>wx_page</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>wx_program_template</td><td>biz</td><td>wx_program_template</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>wx_template_label</td><td>biz</td><td>wx_template_label</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>XiaoFeiCaiPing</td><td>mycat</td><td>xiaofeicaiping</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>XiaoFeiDan</td><td>mycat</td><td>xiaofeidan</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos11report.yaml</td><td>ZuoFaInShiFa</td><td>mycat</td><td>zuofainshifa</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>Bi_DianCaiPiCi</td><td>mycat</td><td>bi_diancaipici</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_business_hours</td><td>mycat</td><td>sc_business_hours</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_department</td><td>mycat</td><td>sc_department</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_discount</td><td>mycat</td><td>sc_mall_discount</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_discount_dish</td><td>mycat</td><td>sc_mall_discount_dish</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_discount_tbl_type</td><td>mycat</td><td>sc_mall_discount_tbl_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_gift_reason</td><td>mycat</td><td>sc_mall_gift_dish_reason</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_income</td><td>mycat</td><td>sc_income</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_income_type</td><td>mycat</td><td>sc_income_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_key_value</td><td>biz</td><td>biz_key_value</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_pay_way</td><td>mycat</td><td>sc_pay_way</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_receipt_bind</td><td>biz</td><td>biz_receipt_bind</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_retreat_reason</td><td>mycat</td><td>sc_mall_retreat_dish_reason</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_shop_group</td><td>biz</td><td>biz_shop_group</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_sms_config</td><td>biz</td><td>biz_sms_config</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_sms_msg_content</td><td>mycat</td><td>sms_msg_content</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_sms_msg_style</td><td>mycat</td><td>sms_msg_style</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_sms_send_record</td><td>biz</td><td>biz_sms_send_record</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_user</td><td>mycat</td><td>sc_usr</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_user_map</td><td>biz</td><td>biz_user_map</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_user_storage</td><td>biz</td><td>biz_user_storage</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>biz_usr_merchant</td><td>mycat</td><td>biz_usr_merchant</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>CaiShiFa</td><td>mycat</td><td>caishifa</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>FuKuanQingKuang</td><td>mycat</td><td>fukuanqingkuang</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>invoice_info_store</td><td>biz</td><td>invoice_info_store</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>JiaoBanXinXi</td><td>mycat</td><td>jiaobanxinxi</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>plat_areas</td><td>biz</td><td>plat_areas</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>plat_cities</td><td>biz</td><td>plat_cities</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>plat_provinces</td><td>biz</td><td>plat_provinces</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_app_ver</td><td>pos</td><td>pos_app_ver</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_approval_config</td><td>pos</td><td>pos_approval_config</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_approval_order</td><td>pos</td><td>pos_approval_order</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_auto_discount</td><td>pos</td><td>pos_auto_discount</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_dev</td><td>pos</td><td>pos_dev</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_dish_hide</td><td>pos</td><td>pos_dish_hide</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_group_dish_book</td><td>pos</td><td>pos_group_dish_book</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_group_dish_book_release</td><td>pos</td><td>pos_group_dish_book_release</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_overtime_interval_config</td><td>pos</td><td>pos_overtime_interval_config</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_package_config</td><td>pos</td><td>pos_package_config</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_pricing_by_time</td><td>pos</td><td>pos_pricing_by_time</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_pricing_by_time_mode</td><td>pos</td><td>pos_pricing_by_time_mode</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_pricing_by_time_period</td><td>pos</td><td>pos_pricing_by_time_period</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_pricing_by_time_timeout</td><td>pos</td><td>pos_pricing_by_time_timeout</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_prn_style_col</td><td>pos</td><td>pos_prn_style_col</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_prn_style_row</td><td>pos</td><td>pos_prn_style_row</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_promote_rule</td><td>pos</td><td>pos_promote_rule</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_reason_type</td><td>pos</td><td>pos_reason_type</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pos_time_period_config</td><td>pos</td><td>pos_time_period_config</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>print_job_type_switch</td><td>pos</td><td>print_job_type_switch</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_auto_order</td><td>mycat</td><td>sc_mall_auto_order</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_cookway</td><td>mycat</td><td>caipingzuofa</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_cookway_type</td><td>mycat</td><td>zuofaleibie</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_dish</td><td>mycat</td><td>sc_dish</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_dish_area</td><td>pt</td><td>pt_dish_area</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_dish_map</td><td>mycat</td><td>sc_dish_map</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_dish_price_special</td><td>pt</td><td>pt_dish_price_special</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_dish_table_price</td><td>pt</td><td>pt_dish_table_price</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_dish_type</td><td>mycat</td><td>sc_dish_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_dish_unit</td><td>mycat</td><td>sc_dish_unit</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_festival</td><td>pt</td><td>pt_festival</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_tbl</td><td>mycat</td><td>sc_tbl</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_tbl_area</td><td>mycat</td><td>sc_tbl_area</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>pt_tbl_type</td><td>mycat</td><td>sc_tbl_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sc_inst_and_product</td><td>mycat</td><td>sc_inst_and_product</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sc_inst_finance_bill</td><td>mycat</td><td>sc_inst_finance_bill</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sc_inst_op_log</td><td>mycat</td><td>sc_inst_op_log</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sc_inst_recharge_set</td><td>mycat</td><td>sc_inst_recharge_set</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sc_merchant</td><td>mycat</td><td>sc_merchant</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sc_product_price</td><td>mycat</td><td>sc_product_price</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sc_product_price_set</td><td>mycat</td><td>sc_product_price_set</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sc_reg_dog</td><td>mycat</td><td>sc_reg_dog</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sc_reg_dog_recharge_record</td><td>mycat</td><td>sc_reg_dog_recharge_record</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sc_store</td><td>mycat</td><td>sc_store</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sc_store_and_product</td><td>mycat</td><td>sc_store_and_product</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sc_store_and_product_flow</td><td>mycat</td><td>sc_store_and_product_flow</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>store_intro_content</td><td>biz</td><td>store_intro_content</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>store_intro_group</td><td>biz</td><td>store_intro_group</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sys_brand</td><td>mycat</td><td>sc_brand</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sys_config_data</td><td>mycat</td><td>sc_config_of_shop</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>sys_user_data_scope</td><td>mycat</td><td>sc_permission</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>takeout_aggregation_platform_channel</td><td>pos</td><td>takeout_aggregation_platform_channel</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>wx_color</td><td>biz</td><td>wx_color</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>wx_componet</td><td>biz</td><td>wx_componet</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>wx_componet_item</td><td>biz</td><td>wx_componet_item</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>wx_navigation</td><td>biz</td><td>wx_navigation</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>wx_page</td><td>biz</td><td>wx_page</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>wx_program_template</td><td>biz</td><td>wx_program_template</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>wx_template_label</td><td>biz</td><td>wx_template_label</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>XiaoFeiCaiPing</td><td>mycat</td><td>xiaofeicaiping</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>XiaoFeiDan</td><td>mycat</td><td>xiaofeidan</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos4cloud.yaml</td><td>ZuoFaInShiFa</td><td>mycat</td><td>zuofainshifa</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>Bi_DianCaiPiCi</td><td>mycat</td><td>bi_diancaipici</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_business_hours</td><td>mycat</td><td>sc_business_hours</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_department</td><td>mycat</td><td>sc_department</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_discount</td><td>mycat</td><td>sc_mall_discount</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_discount_dish</td><td>mycat</td><td>sc_mall_discount_dish</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_discount_tbl_type</td><td>mycat</td><td>sc_mall_discount_tbl_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_gift_reason</td><td>mycat</td><td>sc_mall_gift_dish_reason</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_income</td><td>mycat</td><td>sc_income</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_income_type</td><td>mycat</td><td>sc_income_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_key_value</td><td>biz</td><td>biz_key_value</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_pay_way</td><td>mycat</td><td>sc_pay_way</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_receipt_bind</td><td>biz</td><td>biz_receipt_bind</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_retreat_reason</td><td>mycat</td><td>sc_mall_retreat_dish_reason</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_shop_group</td><td>biz</td><td>biz_shop_group</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_sms_config</td><td>biz</td><td>biz_sms_config</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_sms_msg_content</td><td>mycat</td><td>sms_msg_content</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_sms_msg_style</td><td>mycat</td><td>sms_msg_style</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_sms_send_record</td><td>biz</td><td>biz_sms_send_record</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_user</td><td>mycat</td><td>sc_usr</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_user_map</td><td>biz</td><td>biz_user_map</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_user_storage</td><td>biz</td><td>biz_user_storage</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>biz_usr_merchant</td><td>mycat</td><td>biz_usr_merchant</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>CaiShiFa</td><td>mycat</td><td>caishifa</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>FuKuanQingKuang</td><td>mycat</td><td>fukuanqingkuang</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>invoice_info_store</td><td>biz</td><td>invoice_info_store</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>JiaoBanXinXi</td><td>mycat</td><td>jiaobanxinxi</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>plat_areas</td><td>biz</td><td>plat_areas</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>plat_cities</td><td>biz</td><td>plat_cities</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>plat_provinces</td><td>biz</td><td>plat_provinces</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_app_ver</td><td>pos</td><td>pos_app_ver</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_dev</td><td>pos</td><td>pos_dev</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_dish_hide</td><td>pos</td><td>pos_dish_hide</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_group_dish_book</td><td>pos</td><td>pos_group_dish_book</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_group_dish_book_release</td><td>pos</td><td>pos_group_dish_book_release</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_overtime_interval_config</td><td>pos</td><td>pos_overtime_interval_config</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_package_config</td><td>pos</td><td>pos_package_config</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_pricing_by_time</td><td>pos</td><td>pos_pricing_by_time</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_pricing_by_time_mode</td><td>pos</td><td>pos_pricing_by_time_mode</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_pricing_by_time_period</td><td>pos</td><td>pos_pricing_by_time_period</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_pricing_by_time_timeout</td><td>pos</td><td>pos_pricing_by_time_timeout</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_prn_style_col</td><td>pos</td><td>pos_prn_style_col</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_prn_style_row</td><td>pos</td><td>pos_prn_style_row</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_reason_type</td><td>pos</td><td>pos_reason_type</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pos_time_period_config</td><td>pos</td><td>pos_time_period_config</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>print_job_type_switch</td><td>pos</td><td>print_job_type_switch</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_auto_order</td><td>mycat</td><td>sc_mall_auto_order</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_cookway</td><td>mycat</td><td>caipingzuofa</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_cookway_type</td><td>mycat</td><td>zuofaleibie</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_dish</td><td>mycat</td><td>sc_dish</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_dish_area</td><td>pt</td><td>pt_dish_area</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_dish_map</td><td>mycat</td><td>sc_dish_map</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_dish_price_special</td><td>pt</td><td>pt_dish_price_special</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_dish_table_price</td><td>pt</td><td>pt_dish_table_price</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_dish_type</td><td>mycat</td><td>sc_dish_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_dish_unit</td><td>mycat</td><td>sc_dish_unit</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_festival</td><td>pt</td><td>pt_festival</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_tbl</td><td>mycat</td><td>sc_tbl</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_tbl_area</td><td>mycat</td><td>sc_tbl_area</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>pt_tbl_type</td><td>mycat</td><td>sc_tbl_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sc_inst_and_product</td><td>mycat</td><td>sc_inst_and_product</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sc_inst_finance_bill</td><td>mycat</td><td>sc_inst_finance_bill</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sc_inst_op_log</td><td>mycat</td><td>sc_inst_op_log</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sc_inst_recharge_set</td><td>mycat</td><td>sc_inst_recharge_set</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sc_merchant</td><td>mycat</td><td>sc_merchant</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sc_product_price</td><td>mycat</td><td>sc_product_price</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sc_product_price_set</td><td>mycat</td><td>sc_product_price_set</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sc_reg_dog</td><td>mycat</td><td>sc_reg_dog</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sc_reg_dog_recharge_record</td><td>mycat</td><td>sc_reg_dog_recharge_record</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sc_store</td><td>mycat</td><td>sc_store</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sc_store_and_product</td><td>mycat</td><td>sc_store_and_product</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sc_store_and_product_flow</td><td>mycat</td><td>sc_store_and_product_flow</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>store_intro_content</td><td>biz</td><td>store_intro_content</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>store_intro_group</td><td>biz</td><td>store_intro_group</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sys_brand</td><td>mycat</td><td>sc_brand</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sys_config_data</td><td>mycat</td><td>sc_config_of_shop</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>sys_user_data_scope</td><td>mycat</td><td>sc_permission</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>takeout_aggregation_platform_channel</td><td>pos</td><td>takeout_aggregation_platform_channel</td><td>a_pos</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>wx_color</td><td>biz</td><td>wx_color</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>wx_componet</td><td>biz</td><td>wx_componet</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>wx_componet_item</td><td>biz</td><td>wx_componet_item</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>wx_navigation</td><td>biz</td><td>wx_navigation</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>wx_page</td><td>biz</td><td>wx_page</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>wx_program_template</td><td>biz</td><td>wx_program_template</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>wx_template_label</td><td>biz</td><td>wx_template_label</td><td>a_biz</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>XiaoFeiCaiPing</td><td>mycat</td><td>xiaofeicaiping</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>XiaoFeiDan</td><td>mycat</td><td>xiaofeidan</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-pos9cash.yaml</td><td>ZuoFaInShiFa</td><td>mycat</td><td>zuofainshifa</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_area_period</td><td>pt</td><td>pt_area_period</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_auto_order</td><td>mycat</td><td>sc_mall_auto_order</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_buffet</td><td>mycat</td><td>sc_buffet</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_buffet_food</td><td>mycat</td><td>sc_dish_buffet</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_card_type_free_rule</td><td>pt</td><td>pt_card_type_free_rule</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_cook_ref</td><td>pt</td><td>pt_cook_ref</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_cook_type</td><td>pt</td><td>pt_cook_type</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_cookway</td><td>mycat</td><td>caipingzuofa</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_cookway_type</td><td>mycat</td><td>zuofaleibie</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_data_sync_record</td><td>pt</td><td>pt_data_sync_record</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_dish</td><td>mycat</td><td>sc_dish</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_dish_area</td><td>pt</td><td>pt_dish_area</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_dish_flavor</td><td>pt</td><td>pt_dish_flavor</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_dish_map</td><td>mycat</td><td>sc_dish_map</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_dish_table_price</td><td>pt</td><td>pt_dish_table_price</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_dish_type</td><td>mycat</td><td>sc_dish_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_dish_unit</td><td>mycat</td><td>sc_dish_unit</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_flavor_type</td><td>pt</td><td>pt_flavor_type</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_free_rule_dish</td><td>pt</td><td>pt_free_rule_dish</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_image_compress</td><td>pt</td><td>pt_image_compress</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_member_price</td><td>pt</td><td>pt_member_price</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_qr_bind</td><td>mycat</td><td>sc_qr_bind</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_qr_code</td><td>mycat</td><td>sc_qr_code</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_queue</td><td>pt</td><td>pt_queue</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_queue_open</td><td>pt</td><td>pt_queue_open</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_queue_record</td><td>pt</td><td>pt_queue_record</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_tbl</td><td>mycat</td><td>sc_tbl</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_tbl_area</td><td>mycat</td><td>sc_tbl_area</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_tbl_area_dish</td><td>pt</td><td>pt_tbl_area_dish</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_tbl_type</td><td>mycat</td><td>sc_tbl_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-product.yaml</td><td>pt_x_spec_price</td><td>pt</td><td>pt_x_spec_price</td><td>a_product</td><td>direct</td></tr>
<tr><td>nms4cloud-wechat.yaml</td><td>wx_merchant_config</td><td>mycat</td><td>sc_store_wx_info</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>order_item_depart_relate</td><td>wms</td><td>order_item_depart_relate</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_assist_cost</td><td>wms</td><td>sc_assist_cost</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_auto_deduct_task</td><td>wms</td><td>sc_auto_deduct_task</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_bill_invoice_order</td><td>wms</td><td>sc_bill_invoice_order</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_bill_invoice_ref</td><td>wms</td><td>sc_bill_invoice_ref</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_bill_pay_item</td><td>wms</td><td>sc_bill_pay_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_bill_stock</td><td>wms</td><td>sc_bill_stock</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_check_prohibit</td><td>wms</td><td>sc_check_prohibit</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_client</td><td>mycat</td><td>sc_client</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_client_type</td><td>mycat</td><td>sc_client_type</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_deduct_goods</td><td>wms</td><td>sc_deduct_goods</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_deduct_product</td><td>wms</td><td>sc_deduct_product</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_deduct_rule</td><td>wms</td><td>sc_deduct_rule</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_delivery_order</td><td>wms</td><td>sc_delivery_order</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_delivery_order_item</td><td>wms</td><td>sc_delivery_order_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_delivery_order_store</td><td>wms</td><td>sc_delivery_order_store</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_delivery_quote</td><td>wms</td><td>sc_delivery_quote</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_delivery_rule</td><td>wms</td><td>sc_delivery_rule</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_depart_order</td><td>wms</td><td>sc_depart_order</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_depart_order_item</td><td>wms</td><td>sc_depart_order_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_goods</td><td>wms</td><td>sc_goods</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_goods_img</td><td>wms</td><td>sc_goods_img</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_goods_in_department</td><td>mycat</td><td>sc_goods_in_department</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_goods_in_warehouse</td><td>wms</td><td>sc_goods_in_warehouse</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_goods_route_rule</td><td>mycat</td><td>sc_goods_route_rule</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_goods_sales_delivery_record</td><td>mycat</td><td>sc_goods_sales_delivery_record</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_goods_store</td><td>wms</td><td>sc_goods_store</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_goods_type</td><td>wms</td><td>sc_goods_type</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_goods_unit</td><td>wms</td><td>sc_goods_unit</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_history_order</td><td>wms</td><td>sc_history_order</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_history_order_item</td><td>wms</td><td>sc_history_order_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_history_remark</td><td>wms</td><td>sc_history_remark</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_invoice_attachment</td><td>wms</td><td>sc_invoice_attachment</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_item_attachment</td><td>wms</td><td>sc_item_attachment</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_order_template</td><td>wms</td><td>sc_order_template</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_order_template_item</td><td>wms</td><td>sc_order_template_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_organ_target</td><td>wms</td><td>sc_organ_target</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_pay_task</td><td>wms</td><td>sc_pay_task</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_prepay_checked_item</td><td>wms</td><td>sc_prepay_checked_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_prepay_order</td><td>wms</td><td>sc_prepay_order</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_prepay_order_item</td><td>wms</td><td>sc_prepay_order_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_product</td><td>wms</td><td>sc_product</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_product_cost</td><td>wms</td><td>sc_product_cost</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_product_raw</td><td>wms</td><td>sc_product_raw</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_product_resource</td><td>wms</td><td>sc_product_resource</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_product_sale_cost</td><td>wms</td><td>sc_product_sale_cost</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_product_sale_profit</td><td>wms</td><td>sc_product_sale_profit</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_product_type</td><td>wms</td><td>sc_product_type</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_product_unit</td><td>wms</td><td>sc_product_unit</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_quote_order</td><td>wms</td><td>sc_quote_order</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_quote_order_item</td><td>wms</td><td>sc_quote_order_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_quote_order_store</td><td>wms</td><td>sc_quote_order_store</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_quote_order_supplier</td><td>wms</td><td>sc_quote_order_supplier</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_rdc_order</td><td>wms</td><td>sc_rdc_order</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_rdc_order_item</td><td>wms</td><td>sc_rdc_order_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_sale_cost_relate</td><td>wms</td><td>sc_sale_cost_relate</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_account_period</td><td>wms</td><td>sc_st_account_period</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_bill</td><td>wms</td><td>sc_st_bill</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_bill_item</td><td>wms</td><td>sc_st_bill_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_check_bill</td><td>wms</td><td>sc_st_check_bill</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_check_bill_item</td><td>wms</td><td>sc_st_check_bill_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_convert_bill</td><td>mycat</td><td>sc_st_convert_bill</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_convert_bill_item_in</td><td>mycat</td><td>sc_st_convert_bill_item_in</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_convert_bill_item_out</td><td>mycat</td><td>sc_st_convert_bill_item_out</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_goods_day_book</td><td>wms</td><td>sc_st_goods_day_book</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_goods_summary</td><td>wms</td><td>sc_st_goods_summary</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_item_change</td><td>mycat</td><td>sc_st_item_change</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_item_change_fjz</td><td>mycat</td><td>sc_st_item_change_fjz</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_type_summary</td><td>wms</td><td>sc_st_type_summary</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_st_unit</td><td>mycat</td><td>sc_st_unit</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_stock_snapshot_of_month</td><td>wms</td><td>sc_stock_snapshot_of_month</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_store_order</td><td>wms</td><td>sc_store_order</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_store_order_item</td><td>wms</td><td>sc_store_order_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_supplier</td><td>wms</td><td>sc_supplier</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_supplier_apply</td><td>wms</td><td>sc_supplier_apply</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_supplier_goods</td><td>mycat</td><td>sc_supplier_goods</td><td>gylregdb</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_supplier_quote</td><td>wms</td><td>sc_supplier_quote</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_supplier_relate</td><td>wms</td><td>sc_supplier_relate</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_supplier_store</td><td>wms</td><td>sc_supplier_store</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_supplier_type</td><td>wms</td><td>sc_supplier_type</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_tbl_area</td><td>wms</td><td>sc_tbl_area</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_warehouse</td><td>wms</td><td>sc_warehouse</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_weight_img</td><td>wms</td><td>sc_weight_img</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>sc_weight_record</td><td>wms</td><td>sc_weight_record</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>wms_bom</td><td>wms</td><td>wms_bom</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>wms_bom_item</td><td>wms</td><td>wms_bom_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>wms_cost_order</td><td>wms</td><td>wms_cost_order</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>wms_cost_order_item</td><td>wms</td><td>wms_cost_order_item</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>wms_deduct_setting</td><td>wms</td><td>wms_deduct_setting</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>wms_depart_goods</td><td>wms</td><td>wms_depart_goods</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>wms_goods_last_price</td><td>wms</td><td>wms_goods_last_price</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>wms_label_unit</td><td>wms</td><td>wms_label_unit</td><td>a_wms</td><td>direct</td></tr>
<tr><td>nms4cloud-wms.yaml</td><td>wms_user_goods</td><td>wms</td><td>wms_user_goods</td><td>a_wms</td><td>direct</td></tr>
</tbody>
</table>

## 数据库汇总

| 数据库 | 显式路由记录数 | 涉及配置数 |
| --- | ---: | ---: |
| a_biz | 80 | 4 |
| a_crm | 24 | 1 |
| a_order | 7 | 1 |
| a_payment | 3 | 1 |
| a_pos | 56 | 3 |
| a_product | 29 | 4 |
| a_wms | 81 | 1 |
| gylregdb | 245 | 9 |

## 使用说明

- 查询应用 SQL 中的逻辑表时，先在本表中按“配置文件 + 逻辑表”定位，再使用“实际表”和“数据库”定位数据。
- `actual-data-nodes` 以 `数据源名.实际表` 表示。数据源名由同一配置的 `spring.shardingsphere.datasource` URL 反查数据库名。
- 同名逻辑表在不同服务中的路由以各自配置为准；不要仅凭表名推断跨服务存储位置。
- 配置导出可能过期。执行生产数据查询或迁移前，应以目标环境当前 Nacos 配置和 `information_schema.tables` 复核。
