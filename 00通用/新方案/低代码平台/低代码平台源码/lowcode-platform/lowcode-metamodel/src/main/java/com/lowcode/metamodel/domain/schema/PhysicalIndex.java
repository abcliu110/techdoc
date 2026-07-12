package com.lowcode.metamodel.domain.schema;

import java.util.List;

public record PhysicalIndex(String name, List<String> columnNames, boolean unique) {

  public PhysicalIndex {
    columnNames = List.copyOf(columnNames);
  }

  public static PhysicalIndex unique(String name, List<String> columnNames) {
    return new PhysicalIndex(name, columnNames, true);
  }

  public static PhysicalIndex normal(String name, List<String> columnNames) {
    return new PhysicalIndex(name, columnNames, false);
  }

  public String sqlFragment() {
    String prefix = unique ? "unique key " : "key ";
    return prefix + name + " (" + String.join(", ", columnNames) + ")";
  }
}
