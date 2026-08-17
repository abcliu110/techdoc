# DA0 侦察报告 — 金蝶 K3Cloud 财务域

> 模板加载记录：已读取 `SOP-00-DA0-模板.md`。

## 一、线索清单（E-语料，非源码直读）
| 线索 | 证据位置 | 性质 |
|---|---|---|
| 凭证生成：VoucherGenerateService/BuildBusinessVoucher/ViewGlVoucher | 001财务 DA7 | E-语料（方法签名） |
| 结账改期：AdjustPeriodServiceHelper = 只读查询门面 | 001财务 DA7 + X-002-1 | E-语料 + 反证 |
| 操作框架：operationNumber+timingPoint+插件 | 001财务 DA7 DEC-002 | E-语料 |
| 核销：MatchServiceHelper；对账：CheckAccountBisServiceHelper | 001财务 DA7 | E-语料 |
| 多账簿：MulAcctBookFlex*/FlexAccount* | 001财务 DA7 | E-语料 |

## 二、候选事实（CF）
CF-01 财务=记账-对账-披露 一条链（A/B/C 组）
CF-02 期间=历史封闭的时间盒，改期=受控补偿通道（候选：全量锁 vs 局部可写）
CF-03 凭证=业务事实→会计事实的翻译产物（借=贷）
CF-04 余额=按"科目×期间×核算维度"的聚合投影
CF-05 平台=元数据+操作框架承载百种单据（零代码优先）

## 三、未知项（U，如实登记，禁止补造）
U-DA0-1 Schema 未实证（表结构=候选）
U-DA0-2 无运行证据（"实际会怎样"一律 R7 受限）
U-DA0-4 AR 独立服务面快照缺
U-DA0-5 GL 结账写入口未定位（F 级关键未知，见 DA8 6.1）

## 四、停止条件
取得服务端源码/运行/Schema 前，涉"写行为/表结构/实际发生"结论不升级为已证实。
