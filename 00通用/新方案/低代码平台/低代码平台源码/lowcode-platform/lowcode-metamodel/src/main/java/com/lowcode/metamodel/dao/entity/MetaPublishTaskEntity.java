package com.lowcode.metamodel.dao.entity;

/** 持久化发布任务行。后续任务用它实现幂等、fencing 和恢复。 */
public class MetaPublishTaskEntity extends BaseMetaEntity {

  /** 所属应用 ID。 */
  private Long appId;

  /** 发布提交的幂等键。 */
  private String taskNo;

  /** 可选来源版本。为空表示允许首次发布。 */
  private String sourceVersion;

  /** 必填目标版本。 */
  private String targetVersion;

  /** 持久化发布状态。更新必须校验 revision 和 fencing token。 */
  private String publishStatus;

  /** 当前 DDL 步骤。为空表示计划阶段尚未产出可执行步骤。 */
  private Integer currentStep;

  /** DDL 计划 ID。 */
  private String planId;

  /** 带版本的 DDL 计划快照 JSON。 */
  private String planJson;

  /** 发布 fencing token。过期 token 禁止推进状态机。 */
  private Long fencingToken;

  /** 目标元数据哈希，用于幂等重放和恢复检查。 */
  private String metaHash;

  /** 安全错误码。 */
  private String errorCode;

  /** 已脱敏错误消息。 */
  private String errorMessage;

  /** 可恢复错误详情 JSON。 */
  private String errorDetail;

  /** 用于串联发布任务、DDL 日志和诊断信息的追踪 ID。 */
  private String traceId;
}
