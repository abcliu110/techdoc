package com.lowcode.metamodel.domain.schema;

import com.lowcode.metamodel.domain.service.MetaObjectDraft;
import java.util.List;

/**
 * Schema Sync 计划命令。
 *
 * <p>对象来自 T-003 的元模型草稿；当前结构来自物理结构登记表。
 */
public record SchemaSyncCommand(
    Long tenantId,
    Long appId,
    String appCode,
    List<MetaObjectDraft> objects,
    List<PhysicalTable> currentTables) {

  public SchemaSyncCommand {
    objects = List.copyOf(objects);
    currentTables = List.copyOf(currentTables);
  }

  public static SchemaSyncCommand forObjects(
      Long tenantId, Long appId, String appCode, List<MetaObjectDraft> objects, List<PhysicalTable> currentTables) {
    return new SchemaSyncCommand(tenantId, appId, appCode, objects, currentTables);
  }
}
