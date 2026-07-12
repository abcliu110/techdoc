package com.lowcode.metamodel.domain.schema;

import static org.assertj.core.api.Assertions.assertThat;

import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import com.lowcode.metamodel.domain.enums.ObjectTypeEnum;
import com.lowcode.metamodel.domain.service.MetaObjectDraft;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.junit.jupiter.api.Test;

class SchemaSyncPlanTest {

  private final SchemaSyncPlanner planner = new SchemaSyncPlanner();

  @Test
  void standardColumnDefinitionsStayAlignedWithPhysicalColumns() {
    List<String> ddlColumnNames =
        SchemaSyncPlanner.standardColumns().stream()
            .map(SchemaSyncPlanTest::firstToken)
            .toList();
    List<String> physicalColumnNames =
        SchemaSyncPlanner.standardPhysicalColumns().stream()
            .map(PhysicalColumn::name)
            .toList();

    assertThat(ddlColumnNames).containsExactlyElementsOf(physicalColumnNames);
    for (PhysicalColumn column : SchemaSyncPlanner.standardPhysicalColumns()) {
      String ddl = SchemaSyncPlanner.standardColumns().get(physicalColumnNames.indexOf(column.name()));
      assertThat(ddl).contains(column.typeName());
      if (column.length() != null) {
        assertThat(ddl).contains("(" + column.length() + ")");
      }
      if (column.scale() != null) {
        assertThat(ddl).contains("(" + column.scale() + ")");
      }
    }
  }

  @Test
  void plan_新对象_生成建表并包含系统列和业务字段() {
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "订单",
            ObjectTypeEnum.DOCUMENT,
            List.of(
                new FieldDef("name", "名称", FieldTypeEnum.TEXT, true, FieldOptionsDef.text(1, 128)),
                new FieldDef("customer", "客户", FieldTypeEnum.LINK, false, FieldOptionsDef.link(1, "customer"))));

    DdlPlan plan = planner.plan(SchemaSyncCommand.forObjects(1L, 10L, "crm", List.of(order), List.of()));

    assertThat(plan.executable()).isTrue();
    assertThat(plan.steps()).anySatisfy(step -> {
      assertThat(step.type()).isEqualTo(DdlType.CREATE_TABLE);
      assertThat(step.sql()).contains("create table lc_crm_order");
      assertThat(step.sql()).contains("owner_user_lid varchar(26)");
      assertThat(step.sql()).contains("workspace_id bigint not null");
      assertThat(step.sql()).contains("owner_dept_lid varchar(26)");
      assertThat(step.sql()).contains("owner_org_path varchar(512)");
      assertThat(step.sql()).contains("name varchar(128)");
      assertThat(step.sql()).contains("customer_lid varchar(26)");
      assertThat(step.sql()).contains("delete_token bigint not null default 0");
    });
  }

  @Test
  void plan_多链接字段_生成不可执行阻断项但保留同对象其他字段计划() {
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "订单",
            ObjectTypeEnum.DOCUMENT,
            List.of(
                new FieldDef("name", "名称", FieldTypeEnum.TEXT, true, FieldOptionsDef.text(1, 128)),
                new FieldDef("tags", "标签", FieldTypeEnum.MULTILINK, false, FieldOptionsDef.multilink(1, "tag", "order_tag"))));

    DdlPlan plan = planner.plan(SchemaSyncCommand.forObjects(1L, 10L, "crm", List.of(order), List.of()));

    assertThat(plan.executable()).isFalse();
    assertThat(plan.steps()).anySatisfy(step -> {
      assertThat(step.type()).isEqualTo(DdlType.CREATE_TABLE);
      assertThat(step.sql()).contains("name varchar(128)");
    });
    assertThat(plan.steps()).anySatisfy(step -> {
      assertThat(step.type()).isEqualTo(DdlType.BLOCKED_UNSUPPORTED_FIELD_TYPE);
      assertThat(step.executable()).isFalse();
      assertThat(step.columnName()).isEqualTo("tags");
    });
  }

  @Test
  void plan_已有字段被删除或缩短_只生成阻断项不生成危险DDL() {
    PhysicalTable current =
        new PhysicalTable(
            "lc_crm_order",
            List.of(
                new PhysicalColumn("name", "varchar", 255, null, null),
                new PhysicalColumn("legacy_code", "varchar", 64, null, null)));
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "订单",
            ObjectTypeEnum.DOCUMENT,
            List.of(new FieldDef("name", "名称", FieldTypeEnum.TEXT, true, FieldOptionsDef.text(1, 128))));

    DdlPlan plan = planner.plan(SchemaSyncCommand.forObjects(1L, 10L, "crm", List.of(order), List.of(current)));

    assertThat(plan.executable()).isFalse();
    assertThat(plan.steps()).anySatisfy(step -> assertThat(step.type()).isEqualTo(DdlType.BLOCKED_NARROW_COLUMN));
    assertThat(plan.steps()).anySatisfy(step -> assertThat(step.type()).isEqualTo(DdlType.BLOCKED_DROP_COLUMN));
    assertThat(plan.steps()).noneSatisfy(step -> assertThat(step.sql()).containsIgnoringCase("drop column"));
  }

  private static String firstToken(String ddlFragment) {
    Matcher matcher = Pattern.compile("^([a-z][a-z0-9_]*)\\s+").matcher(ddlFragment);
    if (!matcher.find()) {
      throw new IllegalArgumentException("Invalid column fragment: " + ddlFragment);
    }
    return matcher.group(1);
  }
}
