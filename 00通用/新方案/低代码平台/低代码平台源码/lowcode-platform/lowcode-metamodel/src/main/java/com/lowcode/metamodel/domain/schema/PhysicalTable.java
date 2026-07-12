package com.lowcode.metamodel.domain.schema;

import java.util.List;

/**
 * 物理表登记快照。
 */
public record PhysicalTable(String tableName, List<PhysicalColumn> columns, List<PhysicalIndex> indexes) {

  public PhysicalTable(String tableName, List<PhysicalColumn> columns) {
    this(tableName, columns, List.of());
  }

  public PhysicalTable {
    columns = List.copyOf(columns);
    indexes = List.copyOf(indexes);
  }
}
