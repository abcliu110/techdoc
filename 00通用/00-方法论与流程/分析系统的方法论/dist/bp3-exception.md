# BP-3.2 业务异常处理

**系统**: kaci-pos-localserver (餐饮POS本地服务器)
**分析日期**: 2026-09-02
**分析依据**: BizErrorCode.java, CloudBizErrorCode.java, KdsErrorCodeEnum.java, ExceptionAdviceRegistry.java

---

## 异常类型清单

### 1. 支付类异常

| 异常码前缀 | 异常文本 | 业务含义 | 异常域 | 处理策略 | 触发条件 |
|-----------|---------|---------|-------|---------|---------|
| 0101010900 | INVALID_PAY_AMOUNT | 支付金额无效 | 支付域 | 人工介入 | 支付金额不符合规则 |
| 0101010902 | CHECK_ORDER_STATUS_ERROR | 订单状态校验错误 | 支付域 | 人工介入 | 订单状态不支持当前支付操作 |
| 0101010903 | PAY_AMOUNT_ERROR | 支付金额错误 | 支付域 | 人工介入 | 实际支付金额与订单金额不匹配 |
| 0101010908 | EXIST_PAYING_RECORD | 存在支付中记录 | 支付域 | 静默忽略/重试 | 存在未完成的支付 |
| 0101010910 | ORDER_PAY_UNCOMPLETED | 订单支付未完成 | 支付域 | 重试 | 订单存在未完成的支付流程 |
| 0101010911 | ORDER_PAY_NOT_EXIST | 订单支付记录不存在 | 支付域 | 人工介入 | 查询支付记录失败 |
| 0101010913 | REV_CHECKOUT_STATUS_ERROR | 反结账状态错误 | 支付域 | 人工介入 | 订单状态不支持反结账 |
| 0101010919 | REV_CHECKOUT_ORDER_ERROR | 反结账订单错误 | 支付域 | 人工介入 | 反结账操作失败 |
| 0101010920 | CALL_PAY_CENTER_ERROR | 调用支付中心错误 | 云端通信域 | 重试 | 支付中心调用失败 |
| 0101010944 | PAY_RETRY_SUBJECT_ERROR | 支付重试主体错误 | 支付域 | 人工介入 | 重试支付主体不匹配 |
| 0101010945 | PAY_RETRY_ERROR | 支付重试错误 | 支付域 | 重试 | 支付重试失败 |
| 0101010964 | PAY_REFUND_TIMEOUT | 支付退款超时 | 支付域 | 补偿 | 退款请求超时 |
| 0101010965 | PAY_REFUND_ERROR | 支付退款错误 | 支付域 | 补偿 | 退款执行失败 |
| 0101010969 | PAY_RETRY_PAYMENT_ERROR | 支付重试付款错误 | 支付域 | 人工介入 | 重试支付时付款失败 |
| 0101010970 | PAY_FAILED | 支付失败 | 支付域 | 人工介入 | 支付操作失败 |

### 2. 订单类异常

| 异常码前缀 | 异常文本 | 业务含义 | 异常域 | 处理策略 | 触发条件 |
|-----------|---------|---------|-------|---------|---------|
| 0101010103 | ORDER_NOT_EXIST | 订单不存在 | 订单域 | 人工介入 | 根据订单号查询订单失败 |
| 0101010107 | ORDER_STATUS_NOT_EXIST | 订单状态不存在 | 订单域 | 人工介入 | 订单状态数据异常 |
| 0101010113 | ORDER_DETAIL_NOT_EXIST | 订单详情不存在 | 订单域 | 人工介入 | 订单明细查询失败 |
| 0101010123 | INVALID_ORDER_NO | 无效的订单号 | 订单域 | 人工介入 | 订单号格式错误 |
| 0101010124 | ORDER_LOCK_ERROR | 订单锁定错误 | 订单域 | 重试 | 并发操作导致订单锁定失败 |
| 0101010125 | ORDER_STATUS_ERROR | 订单状态错误 | 订单域 | 人工介入 | 订单当前状态不支持操作 |
| 0101010145 | WAIT_CONFIRM_ORDER | 待确认订单 | 订单域 | 静默忽略 | 订单处于待确认状态 |
| 0101010127 | REV_CHECKOUT_NON_OPERATOR | 反结账非操作员 | 权限域 | 人工介入 | 非操作员执行反结账 |
| 0101010128 | TEST_ORDER_MARK_FAILED | 标记测试订单失败 | 订单域 | 静默忽略 | 测试订单标记异常 |

### 3. 会员类异常

| 异常码前缀 | 异常文本 | 业务含义 | 异常域 | 处理策略 | 触发条件 |
|-----------|---------|---------|-------|---------|---------|
| 0101010607 | GIFT_CARD_NOT_FOUND | 礼品卡未找到 | 会员域 | 人工介入 | 礼品卡信息查询失败 |
| 0101010612 | MEMBER_CARD_NOT_EXIST | 会员卡不存在 | 会员域 | 人工介入 | 会员卡验证失败 |
| 0101010622 | INVALID_CARD_STATUS | 无效的卡状态 | 会员域 | 人工介入 | 会员卡状态异常（已冻结/已注销） |
| 0101010613 | INVALID_UNPAID_AMOUNT | 无效的未付金额 | 会员域 | 人工介入 | 预授权金额校验失败 |
| 0101010615 | INVALID_CARD_NO | 无效的卡号 | 会员域 | 人工介入 | 会员卡号格式错误 |
| 0101010620 | INVALID_CARD_LEVEL_ID | 无效的卡级别ID | 会员域 | 人工介入 | 会员等级信息异常 |
| 0101010623 | INVALID_OLD_PWD | 无效的旧密码 | 会员域 | 人工介入 | 修改密码时旧密码错误 |
| 0101010624 | INVALID_NEW_PWD | 无效的新密码 | 会员域 | 人工介入 | 新密码不符合规则 |
| 0101010616 | INVALID_CUSTOMER_ID | 无效的客户ID | 会员域 | 人工介入 | 客户标识校验失败 |

### 4. 云端通信类异常

| 异常码前缀 | 异常文本 | 业务含义 | 异常域 | 处理策略 | 触发条件 |
|-----------|---------|---------|-------|---------|---------|
| 0101010001 | INNER_ERROR | 内部错误 | 系统域 | 人工介入 | 系统内部未知错误 |
| 0101010009 | HTTP_RESPONSE_NULL | HTTP响应为空 | 云端通信域 | 重试/补偿 | 调用云端服务返回空响应 |
| 0101010034 | NETWORK_EXCEPTION | 网络异常 | 云端通信域 | 重试/补偿 | 网络请求失败 |
| 0101010035 | PARSE_EXCEPTION | 解析异常 | 云端通信域 | 人工介入 | 响应数据解析失败 |
| 0101010036 | SHORT_ACCOUNT_NOT_FIND | 短账号未找到 | 云端通信域 | 人工介入 | 账号同步失败 |
| 0101010920 | CALL_PAY_CENTER_ERROR | 调用支付中心错误 | 云端通信域 | 重试 | 支付中心调用失败 |
| 0101010966 | VERIFY_RESPONSE_IS_EMPTY | 验证响应为空 | 云端通信域 | 重试 | 券码验证响应为空 |
| 0101010967 | VERIFY_STATUS_NOT_SUCCESS | 验证状态不成功 | 云端通信域 | 人工介入 | 券码验证失败 |

### 5. 业务校验类异常

| 异常码前缀 | 异常文本 | 业务含义 | 异常域 | 处理策略 | 触发条件 |
|-----------|---------|---------|-------|---------|---------|
| 0101010002 | INVALID_PARAMETER_FORMAT | 参数格式无效 | 参数校验域 | 人工介入 | 请求参数格式错误 |
| 0101010003 | INVALID_PARAMETER | 参数无效 | 参数校验域 | 人工介入 | 请求参数值不合法 |
| 0101010006 | INVALID_PARAMETER_LACK | 缺少参数 | 参数校验域 | 人工介入 | 必填参数缺失 |
| 0101010027 | NO_LOGIN_AUTH | 未登录授权 | 权限域 | 人工介入 | 用户未登录或Token过期 |
| 0101010032 | INVALID_RIGHT_CODE | 无效的权限码 | 权限域 | 人工介入 | 用户权限不足 |
| 0101010401 | EMPLOYEE_NOT_EXIST | 员工不存在 | 权限域 | 人工介入 | 员工信息验证失败 |
| 0101010402 | EMPLOYEE_DISABLED | 员工已禁用 | 权限域 | 人工介入 | 员工账号被禁用 |
| 0101010403 | INVALID_PASSWORD | 无效密码 | 权限域 | 人工介入 | 密码错误 |
| 0101010404 | TOKEN_NOT_EXIST | Token不存在 | 权限域 | 人工介入 | Token缺失 |
| 0101010405 | INVALID_TOKEN | 无效的Token | 权限域 | 人工介入 | Token格式或签名错误 |
| 0101010406 | TOKEN_OUT_OF_DATE | Token已过期 | 权限域 | 人工介入 | Token过期 |
| 0101010407 | VERSION_NOT_MATCH | 版本不匹配 | 版本域 | 人工介入 | 客户端版本过低 |

### 6. 数据库类异常

| 异常码前缀 | 异常文本 | 业务含义 | 异常域 | 处理策略 | 触发条件 |
|-----------|---------|---------|-------|---------|---------|
| 0101010005 | BAD_SQL_EXCEPTION | SQL异常 | 数据库域 | 人工介入 | 数据库查询失败 |
| 0101010201 | ALREADY_DAILY_SETTLEMENT | 已日结 | 日结域 | 静默忽略 | 订单已日结 |
| 0101010203 | DAILY_SETTLEMENT_ORDER_TOTAL_AMOUNT_0 | 日结订单总额为0 | 日结域 | 人工介入 | 日结金额异常 |
| 0101010204 | DAILY_FAILED_NON_ORDER | 日结失败无订单 | 日结域 | 静默忽略 | 日结时无订单 |

### 7. 桌台类异常

| 异常码前缀 | 异常文本 | 业务含义 | 异常域 | 处理策略 | 触发条件 |
|-----------|---------|---------|-------|---------|---------|
| 0101010501 | INVALID_TABLE | 无效的桌台 | 桌台域 | 人工介入 | 桌台信息校验失败 |
| 0101010503 | OPEN_TABLE_FAILED_TABLE_USING | 开台失败桌台使用中 | 桌台域 | 重试 | 桌台已被占用 |
| 0101010511 | INVALID_TABLE_STATUS | 无效的桌台状态 | 桌台域 | 人工介入 | 桌台状态异常 |
| 0101010520 | TABLE_NOT_EXIST | 桌台不存在 | 桌台域 | 人工介入 | 桌台查询失败 |
| 0101010518 | TABLE_OPERATION_LOCK | 桌台操作锁定 | 桌台域 | 重试 | 并发操作导致锁定 |
| 0101010537 | TABLE_STATUS_NOT_ALLOWED_OPERATE | 桌台状态不允许操作 | 桌台域 | 人工介入 | 当前桌台状态不支持操作 |
| 0101010538 | TABLE_OCCUPIED_BY_OTHER_ORDER | 桌台被其他订单占用 | 桌台域 | 重试 | 桌台被其他订单使用 |

### 8. 打印类异常

| 异常码前缀 | 异常文本 | 业务含义 | 异常域 | 处理策略 | 触发条件 |
|-----------|---------|---------|-------|---------|---------|
| 0101011403 | PRINT_TEMPLATE_NULL | 打印模板为空 | 打印域 | 人工介入 | 打印模板未配置 |
| 0101011404 | PRINT_TEMPLATE_EXCEPTION | 打印模板异常 | 打印域 | 重试 | 模板渲染失败 |
| 0101011406 | PRINTER_NOTICE_EXCEPTION | 打印机通知异常 | 打印域 | 重试 | 打印机通信异常 |
| 0101011407 | PRINTER_JOB_EXCEPTION | 打印任务异常 | 打印域 | 重试 | 打印任务执行失败 |

### 9. KDS类异常

| 异常码前缀 | 异常文本 | 业务含义 | 异常域 | 处理策略 | 触发条件 |
|-----------|---------|---------|-------|---------|---------|
| 150010002 | LOCK_ERROR | 锁错误 | KDS域 | 重试 | 并发请求冲突 |
| 150010003 | REDIS_ERROR | Redis异常 | KDS域 | 补偿 | Redis连接或操作失败 |
| 150011001 | SAVE_SCREEN_ERROR | 保存屏幕明细异常 | KDS域 | 重试 | 屏幕数据保存失败 |
| 150011002 | QUERY_SCREEN_ERROR | 查询屏幕明细异常 | KDS域 | 重试 | 屏幕数据查询失败 |
| 150012001 | DISTRIBUTE_SCREEN_ERROR | 下发屏幕方案异常 | KDS域 | 人工介入 | 方案下发失败 |
| 150015001 | CALL_NUMBER_NOT_EXISTS_ERROR | 叫号单数据不存在 | KDS域 | 人工介入 | 叫号单查询失败 |

### 10. 促销/优惠类异常

| 异常码前缀 | 异常文本 | 业务含义 | 异常域 | 处理策略 | 触发条件 |
|-----------|---------|---------|-------|---------|---------|
| 0101011315 | PROMOTION_NOT_EXIST | 优惠不存在 | 促销域 | 人工介入 | 优惠信息验证失败 |
| 0101011319 | GOODS_NOT_DISCOUNT | 商品不参与折扣 | 促销域 | 静默忽略 | 商品不支持折扣 |
| 0101011320 | PROMOTION_COUPONS_NOT_EXIST | 优惠券不存在 | 促销域 | 人工介入 | 券码验证失败 |
| 0101011321 | BATCH_VERIFY_EXIST_SAME_COUPON | 批量验证存在相同券 | 促销域 | 静默忽略 | 重复使用同一券 |
| 0101010955 | CERTIFICATE_NO_HAS_BEEN_USED | 凭证号已被使用 | 促销域 | 人工介入 | 凭证重复使用 |

### 11. 外卖类异常

| 异常码前缀 | 异常文本 | 业务含义 | 异常域 | 处理策略 | 触发条件 |
|-----------|---------|---------|-------|---------|---------|
| 030070005 | ORDER_COMPLETED (云端) | 订单已完成 | 外卖域 | 静默忽略 | 重复推送订单 |
| 0101010951 | GROUP_BUYING_EXECUTE_ERROR | 团购执行错误 | 外卖域 | 人工介入 | 团购订单处理失败 |
| 0101010958 | GROUP_BUYING_VERIFY_FAILURE | 团购核销失败 | 外卖域 | 人工介入 | 团购券核销失败 |

### 12. 库存/沽清类异常

| 异常码前缀 | 异常文本 | 业务含义 | 异常域 | 处理策略 | 触发条件 |
|-----------|---------|---------|-------|---------|---------|
| 0101011500 | SOLD_OUT_GOODS_NON_EXISTS | 沽清商品不存在 | 库存域 | 人工介入 | 沽清设置查询失败 |
| 0101011508 | SOLD_OUT_SETTING_LOCK | 沽清设置锁定 | 库存域 | 重试 | 并发修改沽清设置 |

---

## 异常漏斗

| 异常类型 | 被处理 | 补偿路径 | 静默忽略 | 可能导致不一致 |
|---------|-------|---------|---------|--------------|
| **支付超时 0101010964** | 是 | CompensateOrderTakeoutTask异步补偿 | 否 | 资金状态不一致 |
| **支付失败 0101010970** | 是 | 人工介入 | 否 | 订单状态不一致 |
| **网络异常 0101010034** | 是 | 重试机制 | 否 | 数据同步延迟 |
| **订单锁定 0101010124** | 是 | 重试 | 否 | 操作冲突 |
| **桌台锁定 0101010518** | 是 | 重试 | 否 | 台位状态不一致 |
| **打印异常 0101011407** | 是 | RetryPrintJobHandler重试 | 否 | 票据缺失 |
| **KDS锁错误 150010002** | 是 | 重试 | 否 | 操作冲突 |
| **Redis异常 150010003** | 是 | 缓存重建 | 否 | 性能下降 |
| **日结订单 0101010201** | 是 | 无需处理 | 是 | 无 |
| **待确认订单 0101010145** | 是 | 无需处理 | 是 | 无 |
| **商品不折扣 0101011319** | 是 | 无需处理 | 是 | 无 |
| **团购重复券 0101011321** | 是 | 无需处理 | 是 | 无 |
| **订单已完成 030070005** | 是 | 无需处理 | 是 | 无 |
| **SQL异常 0101010005** | 是 | 抛出BusinessException | 否 | 数据状态未知 |
| **参数无效 0101010003** | 是 | 拒绝请求 | 否 | 请求被拒绝 |

---

## 未被妥善处理的异常

### 1. 底层异常被静默处理

| 异常类型 | 触发位置 | 问题描述 | 风险等级 |
|---------|---------|---------|---------|
| ReadTimeoutException | PosServerExceptionHandler.exceptionCaught() | 仅记录日志后关闭连接，无业务补偿 | **高** |
| NullPointerException | 各Service层 | 可能导致数据处理中断 | **高** |
| NumberFormatException | 参数解析 | 用户输入格式错误被当作系统异常 | **中** |
| IOException | 网络IO | 仅记录日志，无重试或补偿 | **高** |

### 2. 异常处理缺陷

#### 2.1 PosServerExceptionHandler 网络超时处理

```java
// 位置: PosServerExceptionHandler.java:18-26
if (cause instanceof ReadTimeoutException) {
    PosServerExceptionHandler.log.error("Read timeout, closing connection....................");
}
else {
    PosServerExceptionHandler.log.error("Unhandled exception: {}", cause.getMessage());
}
ctx.close();
```

**问题**:
- ReadTimeoutException被静默处理，只关闭连接
- 无业务状态回滚或补偿机制
- 支付流程中的超时可能导致资金不一致

**影响**:
- 支付请求超时后，客户端认为失败但服务端可能已处理
- 订单状态与支付状态可能不一致

#### 2.2 OtherExceptionHandler 异常吞没

```java
// 位置: OtherExceptionHandler.java:22-28
public void process(final FullHttpRequest request, final Exception exception, final ChannelHandlerContext channelHandlerContext) {
    OtherExceptionHandler.log.error("exception:", exception);
    final BaseResponse<String> responseDetail = BaseResponse.fail(ApiCode.OTHER_EXCEPTION);
    responseDetail.setMsg(exception.getMessage());
    final FullHttpResponse response = HttpResponseUtils.getHttpResponseByRes(request, responseDetail.toJSONString(), HttpResponseStatus.INTERNAL_SERVER_ERROR);
    channelHandlerContext.writeAndFlush(response);
}
```

**问题**:
- 异常被转换为通用错误响应
- 原始异常信息可能被截断
- 无差异化处理策略

#### 2.3 HttpClientUtil 网络异常处理

```java
// 位置: HttpClientUtil.java:60-70
if (!response.isSuccessful()) {
    throw new BusinessException("0101010034", response.code() + "_" + response.message());
}
// ...
catch (final Exception e) {
    throw new BusinessException("0101010034");
}
```

**问题**:
- 所有网络异常统一抛出NETWORK_EXCEPTION
- 无重试机制
- 无法区分超时、DNS错误、连接拒绝等不同错误

### 3. 缺失的补偿机制

| 缺失场景 | 当前行为 | 建议补偿 |
|---------|---------|---------|
| 支付超时无响应 | 仅记录日志 | 发起支付状态查询，确认后回滚或确认 |
| 订单创建后网络中断 | 异常抛出 | 记录待处理队列，定时补偿 |
| 会员余额更新失败 | 异常抛出 | 事务回滚，提示用户重试 |
| 打印任务发送后无响应 | 无处理 | 定时查询打印状态，重试或告警 |

---

## 异常处理架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                      HTTP/Netty入口                              │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                   ExceptionAdviceRegistry                        │
│  ┌─────────────────┬──────────────────────────────────┐        │
│  │ 异常类型        │ 处理器                            │        │
│  ├─────────────────┼──────────────────────────────────┤        │
│  │ BusinessException│ BusinessExceptionHandler         │        │
│  │ SQLException    │ SQLExceptionHandler               │        │
│  │ NullPointerException│ NullPointExceptionHandler     │        │
│  │ SocketTimeoutException│ OtherExceptionHandler       │        │
│  │ IOException     │ OtherExceptionHandler             │        │
│  │ 其他异常        │ ParamsExceptionHandler (兜底)     │        │
│  └─────────────────┴──────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    处理器处理策略                                │
│  ┌────────────────┬───────────────────────────────────┐        │
│  │ 处理器         │ 策略                              │        │
│  ├────────────────┼───────────────────────────────────┤        │
│  │ BusinessException│ 设置错误码+消息+数据             │        │
│  │ SQLException   │ 记录日志，返回SQL_EXCEPTION       │        │
│  │ NullPoint      │ 记录日志，返回NULL_POINTER        │        │
│  │ OtherException │ 记录日志，返回OTHER_EXCEPTION     │        │
│  └────────────────┴───────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    异步补偿/重试机制                              │
│  ┌────────────────┬───────────────────────────────────┐        │
│  │ 机制           │ 说明                              │        │
│  ├────────────────┼───────────────────────────────────┤        │
│  │ CompensateOrderTakeoutTask│ 外卖订单异步补偿任务    │        │
│  │ PayRetryHandler │ 支付重试处理器                   │        │
│  │ CashPledgeRetryHandler│ 押金重试处理器               │        │
│  │ RetryPrintJobHandler│ 打印重试处理器                 │        │
│  │ RetryRejectedExecutionHandler│ 线程池拒绝重试       │        │
│  │ NotifyAppletService│ 小程序通知重试                 │        │
│  └────────────────┴───────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

---

## 异常码前缀域划分

| 前缀范围 | 域 | 说明 |
|---------|-----|-----|
| 000 | 成功 | 操作成功 |
| 001 | 失败 | 操作失败（通用） |
| 01010100xx | 系统/参数 | 系统级错误和参数校验 |
| 01010101xx | 订单 | 订单相关业务 |
| 01010102xx | 日结 | 日结相关业务 |
| 01010103xx | 设备 | 设备绑定相关 |
| 01010104xx | 权限/认证 | 员工认证和权限 |
| 01010105xx | 桌台 | 桌台管理 |
| 01010106xx | 会员/卡 | 会员卡管理 |
| 01010107xx | RFID标签 | 标签操作 |
| 01010108xx | 商品/菜品 | 商品管理 |
| 01010109xx | 支付 | 支付相关 |
| 01010110xx | 退款 | 退款相关 |
| 01010111xx | 赠品 | 赠品相关 |
| 01010112xx | 班次 | 班次管理 |
| 01010113xx | 促销/优惠 | 优惠活动 |
| 01010114xx | 打印 | 打印相关 |
| 01010115xx | 沽清 | 沽清设置 |
| 01010116xx | 撤台 | 撤台相关 |
| 01010117xx | KDS | 厨房显示屏 |
| 01010118xx | 转菜 | 转菜相关 |
| 01010119xx | 确认 | 确认操作 |
| 01010120xx | 退款原因 | 退款原因 |
| 01010121xx | 押金 | 押金管理 |
| 01010122xx | 酒水 | 酒水相关 |
| 01010123xx | 泳道 | 泳道配置 |
| 01010124xx | 预订 | 预订相关 |
| 01010125xx | 云打印 | 云打印配置 |
| 01010126xx | 订单完成 | 订单完成状态 |
| 03007xxxx | 云端外卖 | 云端外卖平台 |
| 15001xxxx | KDS错误 | KDS特定错误码 |

---

## 关键发现与建议

### 1. 高风险异常

| 异常码 | 异常 | 风险描述 | 建议 |
|-------|------|---------|------|
| 0101010034 | NETWORK_EXCEPTION | 网络异常无差异化处理 | 区分超时、拒绝、DNS等类型 |
| 0101010964 | PAY_REFUND_TIMEOUT | 退款超时无补偿 | 实现退款状态轮询 |
| 0101010034 (ReadTimeout) | 网络超时 | 支付超时无处理 | 实现超时补偿机制 |
| 0101010005 | SQL_EXCEPTION | 数据库异常可能暴露内部信息 | 脱敏处理错误信息 |

### 2. 补偿机制现状

| 补偿类型 | 实现 | 覆盖范围 |
|---------|-----|---------|
| 异步补偿任务 | CompensateOrderTakeoutTask | 仅外卖订单 |
| 支付重试 | PayRetryHandler | 仅主动触发的重试 |
| 打印重试 | RetryPrintJobHandler | 打印任务 |
| 押金重试 | CashPledgeRetryHandler | 押金支付 |
| 线程池重试 | RetryRejectedExecutionHandler | 任务队列满时 |

**缺失的补偿**:
- 订单创建后网络中断
- 会员余额更新失败
- 优惠券核销失败
- 桌台状态变更失败

### 3. 异常处理改进建议

1. **增强异常分类**
   - 网络异常细分为：连接超时、读取超时、连接拒绝、DNS错误
   - 不同类型采用不同重试策略

2. **完善补偿机制**
   - 增加订单同步补偿任务
   - 增加会员操作补偿任务
   - 增加优惠券核销补偿任务

3. **异常日志增强**
   - 记录完整上下文（订单号、用户ID、操作类型）
   - 异常链路追踪

4. **告警机制**
   - 高频异常告警
   - 未处理异常告警
   - 补偿失败告警

---

## 附录：错误码文件位置

| 文件 | 路径 |
|-----|-----|
| BizErrorCode | `D:\kaci-pos-decompiled\kaci-pos-localserver\src\com\shouqianba\localserver\biz\common\error\BizErrorCode.java` |
| CloudBizErrorCode | `D:\kaci-pos-decompiled\kaci-pos-localserver\src\com\shouqianba\localserver\biz\common\error\CloudBizErrorCode.java` |
| KdsErrorCodeEnum | `D:\kaci-pos-decompiled\kaci-pos-localserver\src\com\shouqianba\localserver\common\enums\KdsErrorCodeEnum.java` |
| ExceptionAdviceRegistry | `D:\kaci-pos-decompiled\kaci-pos-localserver\src\com\shouqianba\localserver\web\registry\ExceptionAdviceRegistry.java` |
| BusinessException | `D:\kaci-pos-decompiled\kaci-pos-localserver\src\com\shouqianba\localserver\common\exception\BusinessException.java` |
| PosServerExceptionHandler | `D:\kaci-pos-decompiled\kaci-pos-localserver\src\com\shouqianba\localserver\web\server\PosServerExceptionHandler.java` |
| CompensateOrderTakeoutTask | `D:\kaci-pos-decompiled\kaci-pos-localserver\src\com\shouqianba\localserver\takeout\task\CompensateOrderTakeoutTask.java` |
