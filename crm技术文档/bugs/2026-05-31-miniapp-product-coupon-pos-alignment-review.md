# 小程序商品券核券对齐 POS 代码评审问题记录

生成日期：2026-05-31

评审范围：
- `D:\mywork\nms4cloud`
- `D:\mywork\taro-mall`
- `D:\mywork\nms4pos`

评审结论：REQUEST CHANGES。当前小程序商品券核券链路还不能视为与 POS 核券对齐。

图谱与外部评审：
- `nms4cloud` 图谱已刷新：2026-05-30 23:34:51，9927 files / 61165 nodes。
- `taro-mall` 图谱已刷新：2026-05-30 23:34:11，562 files / 2524 nodes。
- `nms4pos` 图谱已刷新：2026-05-30 23:35:00，2545 files / 11751 nodes。
- Claude Code 参与失败：`omx ask claude` 返回 403，API Key 已过期。

## 20 个评审问题

1. HIGH：小程序商品券核券前端仍不可达。
   - `taro-mall/src/common/service/order/bill.ts` 新增 4 个 wrapper，但未发现业务调用方。
   - 支付页只过滤 `SWQ`，未形成商品券核券入口。

2. HIGH：购物车可用商品券查询信任前端传入手机号和 `cardLid`。
   - `ShoppingCartController#getAvailableProductCoupon` 使用 request 的 `phone/cardLid` 拼装查询。
   - 应完全使用登录态会员身份，避免查错会员券。

3. HIGH：平台券取消核销依赖前端回传 `verifyId/certificateId`。
   - POS 侧持久化 `DwdCoupon.writeOffId` 后再取消。
   - 小程序侧缺少服务端事实来源，取消链路可被前端参数影响。

4. HIGH：正式下单先保存订单/菜品，再调用外部平台核销。
   - 如果平台核销成功但本地后续事务失败，缺少补偿反核销。

5. HIGH：小程序侧没有对齐 POS 的核券审计字段。
   - POS 侧 `DwdCoupon` 有 `foodDetails/writeOffId/originalResp`。
   - 小程序侧订单菜品只新增 `couponNo/traceNo`，缺少等价审计与取消依据。

6. HIGH：预核销得到的平台凭证未落库。
   - `verifyToken/encryptedCode/channel/platformPrice` 在 `OrderFoodVO` 中流转。
   - `OrderFood` 实体未持久化这些字段。

7. HIGH：平台原始响应和核销凭证直接返回给小程序。
   - `ProductCouponPrepareVO.rawData`、`ProductCouponOrderVO.writeOffResultRawData/verifyId/certificateId` 扩大泄露和篡改面。

8. HIGH：购物车读取存在空指针风险。
   - `cartVO == null && sid < 0` 时仍可能访问 `cartVO.getOrder()`。

9. HIGH：订单金额核算疑似重复扣减商品券。
   - 行级 `promotionAmount` 已加入券优惠。
   - 订单头 `applyProductCouponAccounting` 又累加商品券优惠并扣 `paidAmount`。

10. HIGH：商品券正式核销缺少幂等锁和状态检查。
    - 购物车本地去重不能防止两个并发下单同时调用 CRM/平台 verify。

11. MEDIUM：平台券过期校验策略不一致。
    - 购物车读取只校验会员券。
    - 平台券 prepare token 过期留到下单时报错，用户体验和 POS 即时核券不同。

12. MEDIUM：平台菜品匹配使用 `LIKE` 召回再首个命中。
    - 多个菜品 `extNames` 相似时可能选错菜品。

13. MEDIUM：默认单位找不到时回退为 `dishCode`。
    - `dishCode` 不是单位 lid，后续可能错误通过或报错不稳定。

14. MEDIUM：平台券类型自动识别只靠券码长度或 URL。
    - 误判后会走错平台核券接口。

15. MEDIUM：取消会员商品券时 `couponNoList` 为空仍保留整单取消核销行为。
    - 新接口未强制商品券单券范围。

16. MEDIUM：小程序 `baseUrl` 把 3 个 appid 指到内网测试地址。
    - 存在线上构建误连内网的风险。

17. MEDIUM：CRM 启用了 MyBatis stdout SQL 日志。
    - 可能把券、会员、订单查询直接打到标准输出。

18. MEDIUM：编码显示问题需要更正和防回归。
    - 初始评审中看到 DTO/VO/注释/校验消息乱码。
    - 复核后确认相关 Java 源码按 UTF-8 解码是正常中文，乱码来自读取端按 GBK 展示。
    - 修复动作：新增回归测试，锁定商品券相关 Java 文件必须为 UTF-8 无 BOM，且不得包含常见 mojibake 标记。

19. MEDIUM：测试主要是源码字符串断言。
    - 没有验证金额、并发、核销失败补偿、取消反核销等核心行为。

20. LOW：`nms4pos` 本轮唯一改动与小程序核券对齐无关。
    - `ShiFangAiRecognitionService` 幂等缓存淘汰建议拆出独立提交。

## 建议处理顺序

1. 先处理阻塞项 3、4、5、6、9、10：服务端凭证持久化、正式核销幂等、失败补偿、金额核算。
2. 再处理小程序真实入口接入和前端参数信任边界。
3. 最后补充行为测试，不再只依赖源码字符串断言。

## 回滚建议

当前建议不要合并核券变更。若已进入测试环境，应先关闭小程序商品券核券入口或隐藏前端入口；后端保持旧优惠券支付链路不变，待 POS 对齐项补齐后再灰度。
