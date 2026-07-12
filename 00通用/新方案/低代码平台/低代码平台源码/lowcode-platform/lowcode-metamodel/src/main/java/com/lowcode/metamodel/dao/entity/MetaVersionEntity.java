package com.lowcode.metamodel.dao.entity;

import java.time.LocalDateTime;

/** 已发布元数据快照行。M0 保存快照主要用于兼容性测试。 */
public class MetaVersionEntity extends BaseMetaEntity {

  /** 所属应用 ID。 */
  private Long appId;

  /** 发布流水线选择的稳定版本号。 */
  private String versionNo;

  /** 发布状态编码。状态推进由 T-004 实现。 */
  private String publishStatus;

  /** 带版本的应用全量元数据快照 JSON。 */
  private String snapshot;

  /** 发布时间；为空表示快照尚未发布。 */
  private LocalDateTime publishedAt;
}
