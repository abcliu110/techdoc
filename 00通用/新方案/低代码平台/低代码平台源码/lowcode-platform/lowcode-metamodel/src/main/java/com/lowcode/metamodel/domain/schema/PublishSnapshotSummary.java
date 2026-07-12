package com.lowcode.metamodel.domain.schema;

import java.util.List;

public record PublishSnapshotSummary(
    Long tenantId,
    Long appId,
    int objectCount,
    int fieldCount,
    int tableCount,
    List<String> tableNames,
    List<String> fieldRefs) {

  public PublishSnapshotSummary {
    tableNames = List.copyOf(tableNames);
    fieldRefs = List.copyOf(fieldRefs);
  }
}
