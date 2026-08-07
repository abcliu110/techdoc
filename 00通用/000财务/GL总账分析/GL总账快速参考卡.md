# K3Cloud GL总账分析 - 快速参考卡

## 核心实体速查

| FormID | 表名 | 类型 | 用途 |
|--------|------|------|------|
| GL_VOUCHER | GL_VOUCHER | 事实表 | 凭证表头 |
| GL_VOUCHERENTRY | GL_VOUCHERENTRY | 事实表 | 凭证分录 |
| BAS_BusinessVoucher | BAS_BusinessVoucher | 事实表 | 业务-凭证映射 |
| BD_AccountBook | T_BD_ACCTBOOK | 非事实表 | 账簿 |
| BD_Account | T_BD_ACCOUNT | 非事实表 | 会计科目 |
| BD_FiscalPeriod | 期间表 | 非事实表 | 会计期间 |
| AccountBalance | 余额表 | 派生表 | 科目余额 |

## 关键业务规则

| 规则ID | 描述 |
|--------|------|
| BR-GL-001 | 凭证必须借贷平衡（借方合计 = 贷方合计） |
| BR-GL-002 | 凭证日期必须在已打开的会计期间内 |
| BR-GL-003 | 分录科目必须在当前账簿的科目体系中存在 |
| BR-GL-004 | 凭证审核后才能过账 |
| BR-GL-005 | 期间结账后不能再新增/修改凭证 |

## 核心报表

| 报表名称 | FormID | 说明 |
|----------|--------|------|
| 总账 | GL_RPT_GeneralLedger | 按科目汇总的发生额和余额 |
| 明细账 | GL_RPT_SubLedger | 按科目+核算维度的明细 |
| 科目余额表 | GL_RPT_AccountBalance | 各科目期初/本期/期末余额 |
| 凭证汇总表 | GL_RPT_VoucherSummary | 凭证按日期/凭证字汇总 |

## 核心操作路径

### 凭证生成
```
业务单据审核 → VoucherGenerateService → IBuildVoucherService.BuildVoucher() 
→ GL_VOUCHER + GL_VOUCHERENTRY → BAS_BusinessVoucher
```

### 业务联查凭证
```
业务单据 → ViewGlVoucher → BAS_BusinessVoucher查询 
→ GL_VOUCHER联查
```

### 报表钻取
```
总账(CellDbClick) → 明细账 → 凭证联查
```

## 表间关系概要

```
BD_AccountBook (1) ──→ BD_AccountSystem (1)
BD_AccountBook (1) ──→ BD_Currency (1)
BD_AccountBook (1) ──→ BD_FiscalPeriod (N)
BD_AccountBook (1) ──→ GL_VOUCHER (N)
BD_Account (N) ──→ GL_VOUCHERENTRY (N)
BD_Account (N) ──→ AccountBalance (N)
GL_VOUCHER (1) ──→ GL_VOUCHERENTRY (N)
GL_VOUCHER (1) ──→ BAS_BusinessVoucher (N)
```

## 权限控制

| 操作 | 权限对象 | 权限ID |
|------|----------|--------|
| 查看凭证 | GL_VOUCHER | 6e44119a58cb4a8e86f6c385e14a17ad |
| 生成凭证 | Bas_MakeBizVchWizard | 按子系统动态获取 |
| 打印汇总 | GL_PRINTSUMMARY | f323992d896745fbaab4a2717c79ce2e |

## 源码快速定位

| 功能 | 文件路径 |
|------|----------|
| 凭证联查 | Business\FIN\01.Core\...\ViewGlVoucher.cs |
| 凭证生成 | Business\FIN\01.Core\...\VoucherGenerateService.cs |
| 总账报表 | Business\FIN\...\GL.Report.PlugIn.BillReport\GeneralLedger.cs |
| 明细账报表 | Business\FIN\...\GL.Report.PlugIn.BillReport\SubLedger.cs |
| 科目余额表 | Business\FIN\...\GL.Report.PlugIn.BillReport\AccountBalance.cs |
| 总账过滤 | Business\FIN\...\GL.Report.PlugIn\GeneralLedgerFilter.cs |
| 明细账过滤 | Business\FIN\...\GL.Report.PlugIn\SubLedgerFilter.cs |
