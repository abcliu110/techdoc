package com.lowcode.metamodel.dao.entity;

import java.time.LocalDateTime;

/**
 * 元数据持久化行的公共标准列。
 *
 * <p>M0 刻意让这个类保持简单：它只映射 Flyway 标准列，不添加 ORM 注解、生命周期回调或运行时行为。
 * 这些选择属于后续 Mapper 实现任务，不属于 T-002 静态契约。
 */
public abstract class BaseMetaEntity {

  /** 雪花主键。所有元数据表都用 BIGINT 存储。 */
  private Long id;

  /** 租户隔离键。所有元数据查询都必须绑定该值。 */
  private Long tenantId;

  /** 乐观锁版本。更新语句必须匹配并递增该值。 */
  private Long revision;

  /** 软删除标记。M0 元数据契约刻意不包含物理删除。 */
  private Boolean deleted;

  /** 软删除时间。禁止参与唯一键，因为 NULL 语义不适合作唯一约束。 */
  private LocalDateTime deletedAt;

  /** 唯一索引墓碑值。未删除行使用 0，删除行写入唯一值。 */
  private Long deleteToken;

  /** 创建审计时间。 */
  private LocalDateTime createTime;

  /** 创建人审计 ID。 */
  private Long createBy;

  /** 最后更新时间。 */
  private LocalDateTime updateTime;

  /** 最后更新人 ID。 */
  private Long updateBy;
}
