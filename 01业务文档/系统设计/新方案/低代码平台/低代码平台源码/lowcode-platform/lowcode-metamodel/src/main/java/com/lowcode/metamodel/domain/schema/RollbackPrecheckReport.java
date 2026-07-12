package com.lowcode.metamodel.domain.schema;

import java.util.List;

/** 回滚预检报告。 */
public record RollbackPrecheckReport(
    boolean metadataRollbackSupported,
    boolean physicalRollbackAutoSupported,
    String physicalBoundary,
    List<RollbackRisk> blockingRisks) {

  public RollbackPrecheckReport {
    blockingRisks = List.copyOf(blockingRisks);
  }

  public boolean blocked() {
    return !blockingRisks.isEmpty();
  }
}
