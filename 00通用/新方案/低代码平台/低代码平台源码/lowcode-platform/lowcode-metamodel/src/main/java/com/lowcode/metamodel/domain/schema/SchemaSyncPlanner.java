package com.lowcode.metamodel.domain.schema;

import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.service.MetaObjectDraft;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * T-004 的 DDL Plan 生成器。
 *
 * <p>M0 只生成计划和危险变更阻断，不执行数据库 DDL；真实执行、日志、状态机和 Reconciler 深度对账分后续增量实现。
 */
public class SchemaSyncPlanner {

  private final FieldTypeDdlMapper fieldTypeDdlMapper = new FieldTypeDdlMapper();

  public DdlPlan plan(SchemaSyncCommand command) {
    List<DdlStep> steps = new ArrayList<>();
    Map<String, PhysicalTable> currentByTable = new LinkedHashMap<>();
    for (PhysicalTable table : command.currentTables()) {
      currentByTable.put(table.tableName(), table);
    }
    for (MetaObjectDraft object : command.objects()) {
      String tableName = tableName(command.appCode(), object.code());
      PhysicalTable current = currentByTable.get(tableName);
      if (current == null) {
        addUnsupportedFieldSteps(object, tableName, steps);
        steps.add(createTableStep(steps.size() + 1, object, tableName));
      } else {
        addDiffSteps(object, current, steps);
      }
    }
    return new DdlPlan(command.tenantId(), command.appId(), steps);
  }

  private DdlStep createTableStep(int stepNo, MetaObjectDraft object, String tableName) {
    List<String> columns = new ArrayList<>(standardColumns());
    for (FieldDef field : object.fields()) {
      ColumnDefinition column = fieldTypeDdlMapper.map(field);
      if (column != null) {
        columns.add(column.sqlFragment());
      }
    }
    for (PhysicalIndex index : defaultIndexes(tableName, object)) {
      columns.add(index.sqlFragment());
    }
    String sql = "create table " + tableName + " (" + String.join(", ", columns) + ")";
    return new DdlStep(stepNo, DdlType.CREATE_TABLE, object.code(), tableName, null, sql, true);
  }

  private void addUnsupportedFieldSteps(MetaObjectDraft object, String tableName, List<DdlStep> steps) {
    for (FieldDef field : object.fields()) {
      if (!fieldTypeDdlMapper.m0PublishSupported(field)) {
        steps.add(
            new DdlStep(
                steps.size() + 1,
                DdlType.BLOCKED_UNSUPPORTED_FIELD_TYPE,
                object.code(),
                tableName,
                field.code(),
                "",
                false));
      }
    }
  }

  private void addDiffSteps(MetaObjectDraft object, PhysicalTable current, List<DdlStep> steps) {
    Map<String, PhysicalColumn> currentColumns = new LinkedHashMap<>();
    for (PhysicalColumn column : current.columns()) {
      currentColumns.put(column.name(), column);
    }
    Map<String, ColumnDefinition> expectedColumns = new LinkedHashMap<>();
    for (FieldDef field : object.fields()) {
      if (!fieldTypeDdlMapper.m0PublishSupported(field)) {
        steps.add(new DdlStep(steps.size() + 1, DdlType.BLOCKED_UNSUPPORTED_FIELD_TYPE, object.code(), current.tableName(), field.code(), "", false));
        continue;
      }
      ColumnDefinition expected = fieldTypeDdlMapper.map(field);
      if (expected != null) {
        expectedColumns.put(expected.name(), expected);
        PhysicalColumn physical = currentColumns.get(expected.name());
        if (physical == null) {
          steps.add(addColumnStep(steps.size() + 1, object.code(), current.tableName(), expected));
        } else {
          addCompatibilityStep(object.code(), current.tableName(), expected, physical, steps);
        }
      }
    }
    for (PhysicalColumn physical : current.columns()) {
      if (!isStandardColumn(physical.name()) && !expectedColumns.containsKey(physical.name())) {
        steps.add(
            new DdlStep(
                steps.size() + 1,
                DdlType.BLOCKED_DROP_COLUMN,
                object.code(),
                current.tableName(),
                physical.name(),
                "",
                false));
      }
    }
  }

  private DdlStep addColumnStep(int stepNo, String objectCode, String tableName, ColumnDefinition expected) {
    return new DdlStep(
        stepNo,
        DdlType.ADD_COLUMN,
        objectCode,
        tableName,
        expected.name(),
        "alter table " + tableName + " add column " + expected.sqlFragment(),
        true);
  }

  private void addCompatibilityStep(
      String objectCode, String tableName, ColumnDefinition expected, PhysicalColumn physical, List<DdlStep> steps) {
    if (!expected.typeName().equalsIgnoreCase(physical.typeName())) {
      steps.add(new DdlStep(steps.size() + 1, DdlType.BLOCKED_CHANGE_TYPE, objectCode, tableName, expected.name(), "", false));
      return;
    }
    if (expected.length() != null && physical.length() != null && expected.length() < physical.length()) {
      steps.add(new DdlStep(steps.size() + 1, DdlType.BLOCKED_NARROW_COLUMN, objectCode, tableName, expected.name(), "", false));
    }
    if (expected.precision() != null
        && physical.precision() != null
        && (expected.precision() < physical.precision() || expected.scale() < physical.scale())) {
      steps.add(new DdlStep(steps.size() + 1, DdlType.BLOCKED_NARROW_COLUMN, objectCode, tableName, expected.name(), "", false));
    }
  }

  static String tableName(String appCode, String objectCode) {
    return "lc_" + safeName(appCode) + "_" + safeName(objectCode);
  }

  private static String safeName(String code) {
    if (code == null || !code.matches("[a-z][a-z0-9_]*")) {
      throw new IllegalArgumentException("编码只能使用小写字母、数字和下划线，且必须以字母开头");
    }
    return code;
  }

  static List<String> standardColumns() {
    return List.of(
        "id bigint primary key",
        "tenant_id bigint not null",
        "workspace_id bigint not null",
        "app_id bigint not null",
        "object_id bigint not null",
        "lid varchar(26) not null",
        "state_code varchar(64)",
        "owner_user_lid varchar(26)",
        "owner_dept_lid varchar(26)",
        "owner_org_path varchar(512)",
        "revision bigint not null default 0",
        "deleted tinyint not null default 0",
        "deleted_at datetime(3)",
        "delete_token bigint not null default 0",
        "create_time datetime(3) not null",
        "create_by bigint not null",
        "update_time datetime(3) not null",
        "update_by bigint not null");
  }

  static List<PhysicalColumn> standardPhysicalColumns() {
    return List.of(
        new PhysicalColumn("id", "bigint", null, null, null),
        new PhysicalColumn("tenant_id", "bigint", null, null, null),
        new PhysicalColumn("workspace_id", "bigint", null, null, null),
        new PhysicalColumn("app_id", "bigint", null, null, null),
        new PhysicalColumn("object_id", "bigint", null, null, null),
        new PhysicalColumn("lid", "varchar", 26, null, null),
        new PhysicalColumn("state_code", "varchar", 64, null, null),
        new PhysicalColumn("owner_user_lid", "varchar", 26, null, null),
        new PhysicalColumn("owner_dept_lid", "varchar", 26, null, null),
        new PhysicalColumn("owner_org_path", "varchar", 512, null, null),
        new PhysicalColumn("revision", "bigint", null, null, null),
        new PhysicalColumn("deleted", "tinyint", null, null, null),
        new PhysicalColumn("deleted_at", "datetime", null, null, 3),
        new PhysicalColumn("delete_token", "bigint", null, null, null),
        new PhysicalColumn("create_time", "datetime", null, null, 3),
        new PhysicalColumn("create_by", "bigint", null, null, null),
        new PhysicalColumn("update_time", "datetime", null, null, 3),
        new PhysicalColumn("update_by", "bigint", null, null, null));
  }

  static List<PhysicalIndex> defaultIndexes(String tableName, MetaObjectDraft object) {
    List<PhysicalIndex> indexes = new ArrayList<>();
    indexes.add(PhysicalIndex.unique("uk_" + tableName + "_tenant_workspace_lid_alive", List.of("tenant_id", "workspace_id", "lid", "delete_token")));
    indexes.add(
        PhysicalIndex.normal(
            "idx_" + tableName + "_tenant_workspace_deleted_create_time", List.of("tenant_id", "workspace_id", "deleted", "create_time")));
    indexes.add(
        PhysicalIndex.normal(
            "idx_" + tableName + "_tenant_workspace_deleted_state", List.of("tenant_id", "workspace_id", "deleted", "state_code")));
    indexes.add(
        PhysicalIndex.normal(
            "idx_" + tableName + "_tenant_workspace_owner_user_lid", List.of("tenant_id", "workspace_id", "owner_user_lid")));
    indexes.add(
        PhysicalIndex.normal(
            "idx_" + tableName + "_tenant_workspace_owner_dept_lid", List.of("tenant_id", "workspace_id", "owner_dept_lid")));
    for (FieldDef field : object.fields()) {
      switch (field.fieldType()) {
        case AUTONUMBER ->
            indexes.add(
                PhysicalIndex.unique(
                    "uk_" + tableName + "_tenant_" + field.code() + "_alive",
                    List.of("tenant_id", "workspace_id", field.code(), "delete_token")));
        case LINK ->
            indexes.add(
                PhysicalIndex.normal(
                    "idx_" + tableName + "_tenant_deleted_" + field.code() + "_lid",
                    List.of("tenant_id", "workspace_id", "deleted", field.code() + "_lid")));
        default -> {
        }
      }
    }
    return indexes;
  }

  private static boolean isStandardColumn(String name) {
    return standardColumns().stream().anyMatch(column -> column.startsWith(name + " "));
  }
}
