import codecs

path = r'd:\mywork\techdoc\crm技术文档\02-积分权益接口与控制逻辑.md'
with codecs.open(path, 'r', 'utf-8') as f:
    content = f.read()

# 1. 4.2 时段校验补充不重叠说明
old1 = '13. 若 `availableTimeType = 2`，`availableTimeSlots` 必须非空，且每段：\n   - `startTime` 必填\n   - `endTime` 必填\n   - 格式必须为 `HH:mm`\n   - `endTime > startTime`'
new1 = '13. 若 `availableTimeType = 2`，`availableTimeSlots` 必须非空，且每段：\n   - `startTime` 必填\n   - `endTime` 必填\n   - 格式必须为 `HH:mm`\n   - `endTime > startTime`\n   - 多段时段之间不可重叠（RULE-011）'
content = content.replace(old1, new1, 1)

# 2. 4.2 补充 orderSceneLimit/orderChannelLimit 枚举校验
old2 = '14. 若 `wecomExclusiveEnabled = 1`，`wecomExclusiveType` 必填，且当前允许值为：\n    - `1`：企微好友或企微群客\n    - `2`：企微好友\n    - `3`：企微群客\n    - `4`：企微双粉'
new2 = '14. 若 `wecomExclusiveEnabled = 1`，`wecomExclusiveType` 必填，且当前允许值为：\n    - `1`：企微好友或企微群客\n    - `2`：企微好友\n    - `3`：企微群客\n    - `4`：企微双粉\n15. `orderSceneLimit` 若有值，每个逗号分隔的编码必须为合法值：`DINE_IN`、`DELIVERY`、`SELF_PICKUP`、`TAKEOUT`（RULE-013）\n16. `orderChannelLimit` 若有值，每个逗号分隔的编码必须为合法值：`STORE_POS`、`WECHAT_MINIAPP`、`ALIPAY_MINIAPP`、`DOUYIN_MINIAPP`、`MERCHANT_CENTER`、`SELF_SERVICE`、`QR_CASHIER`（RULE-013）\n17. `earningSpecifiedProductLids` 若有值，所有商品 ID 必须在当前商户下存在且有效（RULE-030）'
content = content.replace(old2, new2, 1)

# 3. 4.3 时段校验补充不重叠说明
old3 = '10. 若 `deductTimeType = 2`，`deductTimeSlots` 必须非空，且每段：\n    - `startTime` 必填\n    - `endTime` 必填\n    - 格式必须为 `HH:mm`\n    - `endTime > startTime`\n11. 若 `productLimitEnabled = 1`：'
new3 = '10. 若 `deductTimeType = 2`，`deductTimeSlots` 必须非空，且每段：\n    - `startTime` 必填\n    - `endTime` 必填\n    - 格式必须为 `HH:mm`\n    - `endTime > startTime`\n    - 多段时段之间不可重叠（RULE-011）\n11. 若 `productLimitEnabled = 1`：'
content = content.replace(old3, new3, 1)

# 4. 4.3 补充商品存在性校验和场景渠道校验
old4 = '12. 上述开关、类型、范围字段若传入非法枚举编码，会在 JSON 反序列化阶段直接失败'
new4 = '12. 上述开关、类型、范围字段若传入非法枚举编码，会在 JSON 反序列化阶段直接失败\n13. `deductSceneLimit` 若有值，每个逗号分隔的编码必须为合法值：`DINE_IN`、`DELIVERY`、`SELF_PICKUP`、`TAKEOUT`（RULE-013）\n14. `deductChannelLimit` 若有值，每个逗号分隔的编码必须为合法值：`STORE_POS`、`WECHAT_MINIAPP`、`ALIPAY_MINIAPP`、`DOUYIN_MINIAPP`、`MERCHANT_CENTER`、`SELF_SERVICE`、`QR_CASHIER`（RULE-013）\n15. `deductSpecifiedProductLids` 若有值，所有商品 ID 必须在当前商户下存在且有效（RULE-030）\n16. `deductExcludeProductLids` 若有值，所有商品 ID 必须在当前商户下存在且有效（RULE-030）'
content = content.replace(old4, new4, 1)

# 5. 新增 4.5 节：planLid 存在性校验
old5 = '## 5. 当前代码未实现为 CRUD 校验的规则'
new5 = '### 4.5 planLid 存在性校验\n\n新增和修改时均生效：\n\n1. `planLid` 对应的会员卡类型必须在当前商户（`mid`）下存在且有效（RULE-029）\n2. 若不存在则报错：「会员卡类型不存在或不属于当前商户」\n\n## 5. 当前代码未实现为 CRUD 校验的规则'
content = content.replace(old5, new5, 1)

# 6. 第5节：删除已实现的条目（2、3、7、8），重新编号
old6 = '''以下规则在需求文档中存在，但当前接口的增删改查层**尚未**实现：

1. 全局开关关闭时是否自动忽略子规则字段
2. 时段多段之间不可重叠
3. 订单场景、订单渠道枚举合法性校验
4. 商品/分类/排除商品之间更细的联动校验
5. `ruleDescription` 按"200个汉字"语义精确校验（当前是按 600 字节）
6. 生日与会员日倍率是否取较大值、不叠加
7. planLid 存在性校验：planLid 对应的会员卡类型必须在当前商户下存在且有效（RULE-029，当前代码尚未实现）
8. 商品存在性校验：earningSpecifiedProductLids、deductSpecifiedProductLids、deductExcludeProductLids 中所有引用的商品 ID 必须在当前商户下存在且有效（RULE-030，当前代码尚未实现）
9. 执行态规则：'''
new6 = '''以下规则在需求文档中存在，但当前接口的增删改查层**尚未**实现：

1. 全局开关关闭时是否自动忽略子规则字段
2. 商品/分类/排除商品之间更细的联动校验
3. `ruleDescription` 按"200个汉字"语义精确校验（当前是按 600 字节）
4. 生日与会员日倍率是否取较大值、不叠加
5. 执行态规则：'''
content = content.replace(old6, new6, 1)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(content)
print('Done')
