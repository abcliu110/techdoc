package com.lowcode.metamodel.dao.entity;

/** DDL 执行日志行。T-002 先建表，便于后续发布恢复能力依赖它。 */
public class DdlLogEntity extends BaseMetaEntity {

  /** 所属应用 ID。 */
  private Long appId;

  /** 归属该 DDL 步骤的发布任务号。 */
  private String taskNo;

  /** 发布流水线生成的 DDL 计划 ID。 */
  private String planId;

  /** 计划内步骤序号。 */
  private Integer stepNo;

  /** DDL 类型，例如 CREATE_TABLE 或 ADD_COLUMN。 */
  private String ddlType;

  /** 可选的受影响对象编码。 */
  private String objectCode;

  /** 可选的受影响物理表名。 */
  private String tableName;

  /** 可选的受影响物理列名。 */
  private String columnName;

  /** 安全 SQL 模板。参数和敏感值禁止内联。 */
  private String sqlTemplate;

  /** started/success/failed 状态。运行时状态推进不属于 T-002。 */
  private String executeStatus;

  /** 执行失败时的安全错误码。 */
  private String errorCode;

  /** 已脱敏错误消息。 */
  private String errorMessage;

  /** 跨步骤排查用的追踪 ID。 */
  private String traceId;
}
