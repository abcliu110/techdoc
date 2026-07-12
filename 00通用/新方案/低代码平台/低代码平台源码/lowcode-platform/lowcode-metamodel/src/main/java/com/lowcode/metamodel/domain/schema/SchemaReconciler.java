package com.lowcode.metamodel.domain.schema;

import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.service.MetaObjectDraft;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Schema Reconciler 初版。
 *
 * <p>M0 先对元对象期望结构和物理登记结构做差异检测；information_schema 三方对账和自动修复后续再接入。
 */
public class SchemaReconciler {

  private final FieldTypeDdlMapper fieldTypeDdlMapper = new FieldTypeDdlMapper();

  public ReconcileReport detect(SchemaSyncCommand command) {
    List<ReconcileDiff> differences = new ArrayList<>();
    Map<String, PhysicalTable> currentByTable = new LinkedHashMap<>();
    for (PhysicalTable table : command.currentTables()) {
      currentByTable.put(table.tableName(), table);
    }
    for (MetaObjectDraft object : command.objects()) {
      String tableName = "lc_" + command.appCode() + "_" + object.code();
      PhysicalTable current = currentByTable.get(tableName);
      if (current == null) {
        differences.add(new ReconcileDiff(ReconcileDiffType.MISSING_TABLE, tableName, null, "物理表登记缺失"));
      } else {
        detectColumnDiff(object, current, differences);
      }
    }
    return new ReconcileReport(differences);
  }

  private void detectColumnDiff(MetaObjectDraft object, PhysicalTable current, List<ReconcileDiff> differences) {
    Map<String, PhysicalColumn> currentColumns = new LinkedHashMap<>();
    for (PhysicalColumn column : current.columns()) {
      currentColumns.put(column.name(), column);
    }
    Map<String, ColumnDefinition> expectedColumns = new LinkedHashMap<>();
    for (PhysicalColumn column : SchemaSyncPlanner.standardPhysicalColumns()) {
      expectedColumns.put(column.name(), toExpectedColumn(column));
    }
    for (FieldDef field : object.fields()) {
      ColumnDefinition expected = fieldTypeDdlMapper.map(field);
      if (expected != null) {
        expectedColumns.put(expected.name(), expected);
      }
    }
    for (String expectedName : expectedColumns.keySet()) {
      if (!currentColumns.containsKey(expectedName)) {
        differences.add(new ReconcileDiff(ReconcileDiffType.MISSING_COLUMN, current.tableName(), expectedName, "物理列登记缺失"));
      } else {
        detectTypeDiff(current.tableName(), expectedColumns.get(expectedName), currentColumns.get(expectedName), differences);
      }
    }
    for (PhysicalColumn currentColumn : current.columns()) {
      if (!expectedColumns.containsKey(currentColumn.name())) {
        differences.add(new ReconcileDiff(ReconcileDiffType.EXTRA_COLUMN, current.tableName(), currentColumn.name(), "物理列多余"));
      }
    }
  }

  private ColumnDefinition toExpectedColumn(PhysicalColumn column) {
    return new ColumnDefinition(
        column.name(),
        column.typeName(),
        column.length(),
        column.precision(),
        column.scale(),
        column.name() + " " + column.typeName());
  }

  private void detectTypeDiff(
      String tableName, ColumnDefinition expected, PhysicalColumn current, List<ReconcileDiff> differences) {
    if (!expected.typeName().equalsIgnoreCase(current.typeName())) {
      differences.add(new ReconcileDiff(ReconcileDiffType.TYPE_CHANGED, tableName, expected.name(), "物理列类型族变化"));
      return;
    }
    if ("varchar".equalsIgnoreCase(expected.typeName())) {
      compareInteger(tableName, expected.name(), expected.length(), current.length(), differences);
    }
    if ("decimal".equalsIgnoreCase(expected.typeName())) {
      compareInteger(tableName, expected.name(), expected.precision(), current.precision(), differences);
      compareInteger(tableName, expected.name(), expected.scale(), current.scale(), differences);
    }
  }

  private void compareInteger(
      String tableName, String columnName, Integer expected, Integer current, List<ReconcileDiff> differences) {
    if (expected == null || current == null || expected.equals(current)) {
      return;
    }
    if (expected > current) {
      differences.add(new ReconcileDiff(ReconcileDiffType.TYPE_WIDENED, tableName, columnName, "物理列容量需要扩大"));
    } else {
      differences.add(new ReconcileDiff(ReconcileDiffType.TYPE_NARROWED, tableName, columnName, "物理列容量缩小被阻断"));
    }
  }
}
