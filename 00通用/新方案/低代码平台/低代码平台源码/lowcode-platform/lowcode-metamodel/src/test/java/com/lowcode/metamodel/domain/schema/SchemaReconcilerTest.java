package com.lowcode.metamodel.domain.schema;

import static org.assertj.core.api.Assertions.assertThat;

import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import com.lowcode.metamodel.domain.enums.ObjectTypeEnum;
import com.lowcode.metamodel.domain.service.MetaObjectDraft;
import java.util.List;
import org.junit.jupiter.api.Test;

class SchemaReconcilerTest {

  private final SchemaReconciler reconciler = new SchemaReconciler();

  @Test
  void detect_登记表缺失目标表_返回缺表差异() {
    MetaObjectDraft order = object("order", List.of(field("name", FieldTypeEnum.TEXT, FieldOptionsDef.text(1, 128))));

    ReconcileReport report = reconciler.detect(SchemaSyncCommand.forObjects(1L, 10L, "crm", List.of(order), List.of()));

    assertThat(report.differences()).singleElement().satisfies(diff -> {
      assertThat(diff.type()).isEqualTo(ReconcileDiffType.MISSING_TABLE);
      assertThat(diff.tableName()).isEqualTo("lc_crm_order");
    });
  }

  @Test
  void detect_登记表缺列和多余列_返回列级差异() {
    MetaObjectDraft order = object("order", List.of(field("name", FieldTypeEnum.TEXT, FieldOptionsDef.text(1, 128))));
    PhysicalTable current =
        new PhysicalTable(
            "lc_crm_order",
            List.of(
                new PhysicalColumn("id", "bigint", null, null, null),
                new PhysicalColumn("legacy_code", "varchar", 64, null, null)));

    ReconcileReport report = reconciler.detect(SchemaSyncCommand.forObjects(1L, 10L, "crm", List.of(order), List.of(current)));

    assertThat(report.differences()).extracting(ReconcileDiff::type).contains(ReconcileDiffType.MISSING_COLUMN, ReconcileDiffType.EXTRA_COLUMN);
  }

  @Test
  void detect_建表计划标准列齐全_不把系统列误判为多余列() {
    MetaObjectDraft order = object("order", List.of(field("name", FieldTypeEnum.TEXT, FieldOptionsDef.text(1, 128))));
    List<PhysicalColumn> columns = new java.util.ArrayList<>(SchemaSyncPlanner.standardPhysicalColumns());
    columns.add(new PhysicalColumn("name", "varchar", 128, null, null));
    PhysicalTable current = new PhysicalTable("lc_crm_order", columns);

    ReconcileReport report = reconciler.detect(SchemaSyncCommand.forObjects(1L, 10L, "crm", List.of(order), List.of(current)));

    assertThat(report.differences()).isEmpty();
  }

  @Test
  void detect_varchar长度缩短_返回缩列阻断差异() {
    MetaObjectDraft order = object("order", List.of(field("name", FieldTypeEnum.TEXT, FieldOptionsDef.text(1, 64))));
    PhysicalTable current =
        new PhysicalTable(
            "lc_crm_order",
            List.of(
                new PhysicalColumn("id", "bigint", null, null, null),
                new PhysicalColumn("name", "varchar", 128, null, null)));

    ReconcileReport report = reconciler.detect(SchemaSyncCommand.forObjects(1L, 10L, "crm", List.of(order), List.of(current)));

    assertThat(report.differences()).anySatisfy(diff -> {
      assertThat(diff.type()).isEqualTo(ReconcileDiffType.TYPE_NARROWED);
      assertThat(diff.columnName()).isEqualTo("name");
    });
  }

  @Test
  void detect_text变varchar_返回类型改变阻断差异() {
    MetaObjectDraft order = object("order", List.of(field("description", FieldTypeEnum.TEXTAREA, null)));
    PhysicalTable current =
        new PhysicalTable(
            "lc_crm_order",
            List.of(
                new PhysicalColumn("id", "bigint", null, null, null),
                new PhysicalColumn("description", "varchar", 255, null, null)));

    ReconcileReport report = reconciler.detect(SchemaSyncCommand.forObjects(1L, 10L, "crm", List.of(order), List.of(current)));

    assertThat(report.differences()).anySatisfy(diff -> {
      assertThat(diff.type()).isEqualTo(ReconcileDiffType.TYPE_CHANGED);
      assertThat(diff.columnName()).isEqualTo("description");
    });
  }

  @Test
  void detect_decimal精度扩大_返回可执行扩列差异() {
    MetaObjectDraft order = object("order", List.of(field("amount", FieldTypeEnum.DECIMAL, FieldOptionsDef.decimal(1, 18, 4))));
    PhysicalTable current =
        new PhysicalTable(
            "lc_crm_order",
            List.of(
                new PhysicalColumn("id", "bigint", null, null, null),
                new PhysicalColumn("amount", "decimal", null, 12, 4)));

    ReconcileReport report = reconciler.detect(SchemaSyncCommand.forObjects(1L, 10L, "crm", List.of(order), List.of(current)));

    assertThat(report.differences()).anySatisfy(diff -> {
      assertThat(diff.type()).isEqualTo(ReconcileDiffType.TYPE_WIDENED);
      assertThat(diff.columnName()).isEqualTo("amount");
    });
  }

  private static MetaObjectDraft object(String code, List<FieldDef> fields) {
    return new MetaObjectDraft(1L, 10L, code, code, ObjectTypeEnum.DOCUMENT, fields);
  }

  private static FieldDef field(String code, FieldTypeEnum fieldType, FieldOptionsDef options) {
    return new FieldDef(code, code, fieldType, false, options);
  }
}
