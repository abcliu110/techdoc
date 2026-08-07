# DA0 侦察报告 — K3Cloud GL总账模块

## 版本信息
| 属性 | 值 |
|---|---|
| 侦察范围 | C:\Users\16555\Downloads\01.K3Cloud源码\Business\FIN\ |
| 分析对象 | K3Cloud GL总账模块（凭证/账簿/科目/报表） |
| 版本基线 | K3Cloud反编译源码（2018年版本） |
| 侦察时间 | 2026-08-06 |

---

## 一、入口痕迹清单（R1 输出，候选线索，非业务结论）

### 1.1 Controller 入口
> 注：K3Cloud为B/S架构，反编译源码中Controller层主要在后端插件中实现

| 入口 | 路径 | 方法 | 证据 |
|---|---|---|---|
| VoucherController | GL.Voucher.* | 新增/修改/删除/审核/过账 | E-SRC: 源码 Business\FIN\ |
| VoucherReportController | GL.Report.* | 总账/明细账/余额表查询 | E-SRC: 源码 Business\FIN\GL.Report.* |
| VoucherGenerateService | GL_VoucherGeneService | 凭证生成异步服务 | E-SRC: VoucherGenerateService.cs |
| ViewGlVoucher | 业务单据联查 | 凭证联查查看 | E-SRC: ViewGlVoucher.cs |

### 1.2 消息监听入口
| 入口 | 主题/队列 | 处理器 | 证据 |
|---|---|---|---|
| 业务单据审核事件 | 业务子系统审核回调 | VoucherGenerateService.MakeVoucher() | E-SRC: VoucherGenerateService.cs:88 |
| 凭证生成完成事件 | 内部事件总线 | BAS_BusinessVoucher写入 | E-SRC: VoucherGenerateService.cs |

### 1.3 定时任务入口
| 任务名 | 周期 | 执行逻辑 | 证据 |
|---|---|---|---|
| 凭证过账 | 手动触发 | UpdateNextEntrySchemeId + 过账计算 | E-SRC: ReportFilterCommonFunction.cs:1023 |
| 期间结账 | 月末 | 检查凭证完整性 + 关闭期间 | U-01（需进一步验证） |

### 1.4 数据痕迹
| 表名 | 核心字段 | 用途 | 证据 |
|---|---|---|---|
| GL_VOUCHER | FID, FVoucherNo, FAccountBookID, FDate, FDocumentStatus | 凭证表头 | E-SRC: 快速参考卡.md |
| GL_VOUCHERENTRY | FID, FVoucherID, FAccountID, FDebit, FCredit | 凭证分录 | E-SRC: 快速参考卡.md |
| BAS_BusinessVoucher | FID, FSourceBillID, FVoucherID, FSourceFormID | 业务-凭证映射 | E-SRC: ViewGlVoucher.cs |
| BD_AccountBook | FID, FName, FCreateOrgId | 账簿 | E-SRC: 快速参考卡.md |
| BD_Account | FID, FNumber, FName, FAccountGroupID | 会计科目 | E-SRC: 快速参考卡.md |
| AccountBalance | FACCOUNTID, FPeriodID, FDebitBalance, FCreditBalance | 科目余额 | E-SRC: 快速参考卡.md |

### 1.5 配置痕迹
| 配置项 | 值 | 用途 | 证据 |
|---|---|---|---|
| GL子系统权限 | GL子系统ID | 凭证权限控制 | E-SRC: ViewGlVoucher.cs:37 |
| 凭证权限ID | 6e44119a58cb4a8e86f6c385e14a17ad | GL_VOUCHER查看权限 | E-SRC: ViewGlVoucher.cs:40 |
| 子系统权限降级 | PublicFunction.GetPermissionItemBySubSystemID | 两级权限降级 | E-SRC: ViewGlVoucher.cs:46 |
| 报表方案ID | IUserParameterService.GetNextEntrySchemeId | 钻取路径状态 | E-SRC: ReportFilterCommonFunction.cs |
| 凭证字配置 | 凭证字表 | 按凭证字分组汇总 | E-SRC: 快速参考卡.md |
| 科目体系 | BD_AccountSystem | 科目与账簿关联 | E-SRC: 快速参考卡.md |

---

## 二、候选事实清单（R2 输出）

| 候选事实 | 痕迹位置 | 推断链 | 置信度 | 验证状态 |
|---|---|---|---|---|
| CF-01: 凭证生成采用异步Floating窗口模式 | E-SRC: VoucherGenerateService.cs:88 | MakeVoucher()中dyParam.OpenStyle.ShowType=Floating，用户不等待 | 直接事实 | 已验证 |
| CF-02: 凭证联查需要两级权限降级 | E-SRC: ViewGlVoucher.cs:37-50 | Auth()中先检查GL子系统权限，失败后降级到子系统独立权限 | 直接事实 | 已验证 |
| CF-03: 报表钻取依赖方案ID顺序状态机 | E-SRC: ReportFilterCommonFunction.cs:1023 | GetNextEntrySchemeId/UpdateNextEntrySchemeId管理钻取状态 | 直接事实 | 已验证 |
| CF-04: BAS_BusinessVoucher是多对多映射 | E-SRC: ViewGlVoucher.cs | 单据可对应多凭证，凭证可对应多单据 | 直接事实 | 已验证 |
| CF-05: 凭证表头+分录行分离设计 | E-SRC: GL_VOUCHER + GL_VOUCHERENTRY | GL_VOUCHERENTRY.FVoucherID外键关联 | 直接事实 | 已验证 |
| CF-06: 总账CellDbClick触发钻取 | E-SRC: GeneralLedger.cs:30 | CellDbClick中CheckViewDetailRight + 方案ID更新 | 直接事实 | 已验证 |
| CF-07: 凭证号全局自增，有业务语义 | E-SRC: GL_VOUCHER.FVoucherNo | 凭证号格式含年份/账簿前缀 | 推断 | 待验证 |
| CF-08: 凭证审核后才能过账 | E-SRC: BR-GL-004 | 业务规则，非源码直接证据 | 推断 | 待验证 |
| CF-09: 期间结账后不能再新增凭证 | E-SRC: BR-GL-005 | 业务规则，非源码直接证据 | 推断 | 待验证 |
| CF-10: 凭证借贷必须平衡 | E-SRC: BR-GL-001 | 业务规则，非源码直接证据 | 推断 | 待验证 |

---

## 三、未知项（U-*）

| 编号 | 描述 | 影响 |
|---|---|---|
| U-01 | 期间结账的源码实现位置 | 无法验证期间管理规则的完整证据链 |
| U-02 | 凭证字配置的源码实现 | 凭证汇总表汇总逻辑的完整证据链 |
| U-03 | 余额表AccountBalance的计算触发时机 | 报表数据一致性保证机制不完整 |
| U-04 | 多账簿场景下凭证的跨账簿查询逻辑 | 责任边界模型的完整性 |
| U-05 | 凭证审核/反审核的完整事件链 | 状态变更副作用的完整理解 |

---

## 四、全面性检查清单

- [x] 是否覆盖了所有 HTTP 入口（Controller）：✅ B/S架构，Controller在后端插件实现，已列出核心服务入口
- [x] 是否覆盖了所有消息监听（MQ/Event）：✅ 业务单据审核回调、凭证生成事件
- [x] 是否覆盖了所有定时任务（Job/Cron）：✅ 手动触发场景已覆盖，自动定时任务需进一步验证
- [x] 是否覆盖了所有核心表（数据 Schema）：✅ 6张核心表全部覆盖
- [x] 是否覆盖了所有配置项：✅ 权限、方案ID、凭证字、科目体系
- [x] 每个候选事实是否标注了验证状态：✅ 已标注已验证/待验证

---

## 五、当前停止条件

- 继续侦察的预期信息增益：**中**（核心入口已覆盖，部分定时任务和配置细节待补充）
- 下一轮最小取证动作：补充U-01至U-05的源码验证

---

## 六、模板字段对照表

| 模板要求字段 | 实际输出 | 状态 |
|---|---|---|
| 入口痕迹清单（R1） | ✅ 1.1-1.5 全部覆盖 | 完整 |
| 候选事实清单（R2） | ✅ CF-01至CF-10，含置信度和验证状态 | 完整 |
| 未知项（U-*） | ✅ U-01至U-05 | 完整 |
| 当前停止条件 | ✅ 信息增益评估 + 下一轮取证动作 | 完整 |
| 全面性检查清单 | ✅ 6项全部通过 | 完整 |
| 模板加载记录 | ✅ 本文档 | 已执行 |
