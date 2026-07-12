package com.lowcode.metamodel.domain.schema;

import java.util.List;

public record PublishPreparation(
    DdlPlan ddlPlan,
    List<PhysicalTable> physicalTables,
    PublishSnapshotSummary snapshotSummary,
    CommercialPublishReport commercialReport,
    RollbackPrecheckReport rollbackPrecheck) {

  public PublishPreparation {
    physicalTables = List.copyOf(physicalTables);
  }
}
