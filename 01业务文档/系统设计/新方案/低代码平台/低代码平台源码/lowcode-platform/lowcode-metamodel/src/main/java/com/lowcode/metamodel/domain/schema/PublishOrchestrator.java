package com.lowcode.metamodel.domain.schema;

import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.service.MetaObjectDraft;
import java.util.ArrayList;
import java.util.List;

public class PublishOrchestrator {

  private final SchemaSyncPlanner planner = new SchemaSyncPlanner();
  private final FieldTypeDdlMapper fieldTypeDdlMapper = new FieldTypeDdlMapper();
  private final CommercialPublishValidator commercialPublishValidator = new CommercialPublishValidator();
  private final RollbackPrecheckService rollbackPrecheckService = new RollbackPrecheckService();

  public PublishPreparation prepare(SchemaSyncCommand command) {
    DdlPlan plan = planner.plan(command);
    List<PhysicalTable> tables = expectedPhysicalTables(command);
    return new PublishPreparation(
        plan,
        tables,
        snapshotSummary(command, tables),
        commercialPublishValidator.validate(command.objects()),
        rollbackPrecheckService.inspect(plan));
  }

  private List<PhysicalTable> expectedPhysicalTables(SchemaSyncCommand command) {
    List<PhysicalTable> tables = new ArrayList<>();
    for (MetaObjectDraft object : command.objects()) {
      String tableName = SchemaSyncPlanner.tableName(command.appCode(), object.code());
      List<PhysicalColumn> columns = new ArrayList<>(SchemaSyncPlanner.standardPhysicalColumns());
      for (FieldDef field : object.fields()) {
        ColumnDefinition column = fieldTypeDdlMapper.map(field);
        if (column != null) {
          columns.add(
              new PhysicalColumn(column.name(), column.typeName(), column.length(), column.precision(), column.scale()));
        }
      }
      tables.add(new PhysicalTable(tableName, columns, SchemaSyncPlanner.defaultIndexes(tableName, object)));
    }
    return tables;
  }

  private static PublishSnapshotSummary snapshotSummary(SchemaSyncCommand command, List<PhysicalTable> tables) {
    List<String> tableNames = tables.stream().map(PhysicalTable::tableName).toList();
    List<String> fieldRefs =
        command.objects().stream()
            .flatMap(object -> object.fields().stream().map(field -> object.code() + ":" + field.code()))
            .toList();
    int fieldCount = command.objects().stream().mapToInt(object -> object.fields().size()).sum();
    return new PublishSnapshotSummary(
        command.tenantId(), command.appId(), command.objects().size(), fieldCount, tables.size(), tableNames, fieldRefs);
  }
}
