# ADR-LOWCODE-OUTBOX-001: 本地 Outbox 副作用总线

Status: proposed

Date: 2026-07-06

## Context

低代码平台运行时会产生通知、Webhook、外部 API 调用、缓存广播、规则日志等副作用。这些副作用如果在各模块中直接同步调用或各建重试机制，会导致主事务状态不可解释、重复发送、租户上下文丢失和审计断链。

首版不引入 MQ 中间件，可靠异步统一使用本地 outbox 表。

## Decision

所有外部副作用必须写入本地 outbox，与业务写同事务提交，再由统一调度器投递。

```text
business transaction:
  validate permission
  write dynamic record
  write audit main event
  write outbox event
commit

dispatcher:
  claim event with DB lock/fencing
  rebuild ExecutionContext from ctx summary
  deliver with retry/backoff
  dead-letter after max attempts
```

Outbox 事件必须包含 `tenantId`、`appId`、`eventType`、`idempotencyKey`、`traceId`、`metaHash`、`ctxSummary`、`retryCount`、`nextRetryAt`、`lastError`。

## Consequences

- API 写入、规则副作用、通知、Webhook、缓存广播不得在主事务中直接调用外部系统。
- Outbox dispatcher 必须支持重试、死信、人工重放和幂等。
- 异步消费侧不得依赖 ThreadLocal 继承上下文，必须从 `ctxSummary` 重建 `ExecutionContext`。
- 审计主记录同事务；可延迟的通知投递日志走 outbox 结果事件。

## Rejected

Rejected: 直接同步调用外部副作用 | 请求延迟和外部故障会污染业务事务，失败恢复不可解释。

Rejected: M0/M1 直接引入 MQ | 增加运维复杂度；首版本地 outbox 足以支撑商用最小可靠性。

## Verification

- 业务提交成功但投递失败时，outbox 保留待重试事件。
- 重复调度同一事件只产生一次外部可见副作用。
- 死信事件可人工重放并带原始 traceId。
- 双租户 outbox 投递不得串租户上下文。

