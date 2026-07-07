package com.lowcode.metamodel.domain.schema;

import java.util.List;

/**
 * Reconciler 检测报告。
 */
public record ReconcileReport(List<ReconcileDiff> differences) {

  public ReconcileReport {
    differences = List.copyOf(differences);
  }

  public boolean clean() {
    return differences.isEmpty();
  }
}
