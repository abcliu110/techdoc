package com.lowcode.metamodel.dao.entity;

/** 业务对象元数据聚合。它只描述结构，绝不保存运行时业务数据。 */
public class MetaObjectEntity extends BaseMetaEntity {

  /** 所属应用 ID。所有对象查询还必须同时绑定租户 ID。 */
  private Long appId;

  /** 稳定对象编码，用于元数据引用和快照。 */
  private String code;

  /** 面向用户展示的对象名称。 */
  private String name;

  /** 动态物理表名，预留给 Schema Sync 任务使用。 */
  private String tableName;

  /** 对象类型编码。保持数值形态以匹配 M0 DDL。 */
  private Integer objectType;

  /** standard/template/custom/extension；默认值由 DDL 约束。 */
  private String objectCategory;

  /** system/vendor/customer 来源层。M0 只存储，不执行分层合并。 */
  private String sourceKind;

  /** 受控扩展层的基准对象编码；为空表示没有基准对象。 */
  private String baseObjectCode;

  /** none/copy/extension_layer；M0 只保存策略，不执行继承。 */
  private String extensionPolicy;

  /** 对象生命周期状态编码。 */
  private Integer status;

  /** 带版本的字段定义 JSON。实体层刻意保持文本形态。 */
  private String fields;

  /** 带版本的关系定义 JSON。 */
  private String relations;

  /** 带版本的状态机 JSON。 */
  private String states;

  /** 带版本的动作元数据 JSON。M0 不执行动作。 */
  private String actions;

  /** 带版本的规则元数据 JSON。M0 不运行规则。 */
  private String rules;

  /** 带版本的对象配置 JSON，可包含商业能力占位 DTO。 */
  private String options;
}
