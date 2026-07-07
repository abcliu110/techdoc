package com.lowcode.metamodel.domain.schema;

import static org.assertj.core.api.Assertions.assertThat;

import com.lowcode.metamodel.domain.def.CommercialMetadataDef;
import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.def.I18nResourceDef;
import com.lowcode.metamodel.domain.def.MenuDef;
import com.lowcode.metamodel.domain.def.ObjectExtensionDef;
import com.lowcode.metamodel.domain.def.PackageCompatibilityDef;
import com.lowcode.metamodel.domain.def.PackageDependencyDef;
import com.lowcode.metamodel.domain.def.PackageManifestDef;
import com.lowcode.metamodel.domain.def.PrintTemplateDef;
import com.lowcode.metamodel.domain.def.ReportDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import com.lowcode.metamodel.domain.enums.ObjectTypeEnum;
import com.lowcode.metamodel.domain.service.MetaObjectDraft;
import com.lowcode.metamodel.domain.service.ValidationError;
import java.util.List;
import org.junit.jupiter.api.Test;

class PublishOrchestratorTest {

  @Test
  void prepare_newObject_returnsPlanPhysicalTableAndSnapshotSummary() {
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "Order",
            ObjectTypeEnum.DOCUMENT,
            List.of(
                new FieldDef("order_no", "Order No", FieldTypeEnum.AUTONUMBER, true, new FieldOptionsDef(1)),
                new FieldDef("customer", "Customer", FieldTypeEnum.LINK, false, FieldOptionsDef.link(1, "customer")),
                new FieldDef("amount", "Amount", FieldTypeEnum.DECIMAL, false, FieldOptionsDef.decimal(1, 18, 4))));

    PublishPreparation preparation =
        new PublishOrchestrator().prepare(SchemaSyncCommand.forObjects(1L, 10L, "crm", List.of(order), List.of()));

    assertThat(preparation.ddlPlan().executable()).isTrue();
    assertThat(preparation.ddlPlan().steps())
        .anySatisfy(
            step -> {
              assertThat(step.type()).isEqualTo(DdlType.CREATE_TABLE);
              assertThat(step.sql()).contains("tenant_id bigint not null");
              assertThat(step.sql()).contains("workspace_id bigint not null");
              assertThat(step.sql()).contains("lid varchar(26) not null");
              assertThat(step.sql()).contains("revision bigint not null default 0");
              assertThat(step.sql()).contains("deleted tinyint not null default 0");
              assertThat(step.sql()).contains("state_code varchar(64)");
              assertThat(step.sql()).contains("order_no varchar(64)");
              assertThat(step.sql()).contains("customer_lid varchar(26)");
              assertThat(step.sql()).contains("amount decimal(18,4)");
              assertThat(step.sql()).contains("unique key uk_lc_crm_order_tenant_workspace_lid_alive (tenant_id, workspace_id, lid, delete_token)");
              assertThat(step.sql()).contains("unique key uk_lc_crm_order_tenant_order_no_alive (tenant_id, workspace_id, order_no, delete_token)");
              assertThat(step.sql()).contains("key idx_lc_crm_order_tenant_workspace_deleted_create_time (tenant_id, workspace_id, deleted, create_time)");
              assertThat(step.sql()).doesNotContain("deleted_at)");
            });

    PhysicalTable table = preparation.physicalTables().getFirst();
    assertThat(table.tableName()).isEqualTo("lc_crm_order");
    assertThat(table.columns()).extracting(PhysicalColumn::name)
        .contains("tenant_id", "workspace_id", "lid", "revision", "deleted", "state_code", "order_no", "customer_lid", "amount");
    assertThat(table.indexes())
        .contains(
            PhysicalIndex.unique("uk_lc_crm_order_tenant_workspace_lid_alive", List.of("tenant_id", "workspace_id", "lid", "delete_token")),
            PhysicalIndex.unique("uk_lc_crm_order_tenant_order_no_alive", List.of("tenant_id", "workspace_id", "order_no", "delete_token")),
            PhysicalIndex.normal("idx_lc_crm_order_tenant_workspace_deleted_create_time", List.of("tenant_id", "workspace_id", "deleted", "create_time")));

    assertThat(preparation.snapshotSummary())
        .isEqualTo(
            new PublishSnapshotSummary(
                1L,
                10L,
                1,
                3,
                1,
                List.of("lc_crm_order"),
                List.of("order:order_no", "order:customer", "order:amount")));
    assertThat(preparation.commercialReport().blockingErrors()).isEmpty();
    assertThat(preparation.rollbackPrecheck().blocked()).isFalse();
  }

  @Test
  void prepare_商业发布门禁缺依赖缺权限缺文案缺移动兼容_进入发布报告并阻断() {
    MetaObjectDraft customer =
        new MetaObjectDraft(
            1L,
            10L,
            "customer",
            "客户",
            ObjectTypeEnum.DOCUMENT,
            List.of(new FieldDef("name", "名称", FieldTypeEnum.TEXT, false, FieldOptionsDef.text(1, 64))));
    MetaObjectDraft customization =
        new MetaObjectDraft(
            1L,
            10L,
            "customer_customization",
            "客户定制",
            ObjectTypeEnum.DOCUMENT,
            List.of())
            .withCommercialMetadata(
                CommercialMetadataDef.empty(1)
                    .withObjectExtensions(
                        List.of(
                            new ObjectExtensionDef(
                                "customer_ext",
                                "customer",
                                "customer",
                                "sales_pkg",
                                "1.0.0",
                                "field_add",
                                "reject",
                                List.of(
                                    new FieldDef(
                                        "customer_level",
                                        "客户等级",
                                        FieldTypeEnum.TEXT,
                                        false,
                                        FieldOptionsDef.text(1, 64))),
                                true)))
                    .withReports(List.of(new ReportDef("sales_report", "report.view", "report.sales.title", true, true)))
                    .withPrintTemplates(
                        List.of(new PrintTemplateDef("sales_print", "customer", "print.execute", "print.sales.title", false, true)))
                    .withMenus(
                        List.of(
                            new MenuDef(
                                "sales_menu",
                                null,
                                "menu.sales.title",
                                "report",
                                "sales_report",
                                "mobile",
                                false,
                                true)))
                    .withI18nResources(List.of(new I18nResourceDef("print.sales.title", "zh-CN", "销售打印", true)))
                    .withPackageManifests(
                        List.of(
                            new PackageManifestDef(
                                "sales_pkg",
                                "1.0.0",
                                List.of(new PackageDependencyDef("base_pkg", "1.0.0")),
                                "Commercial",
                                List.of("customer"),
                                List.of("customer_ext"),
                                List.of("sales_menu"),
                                List.of("sales_report"),
                                List.of("print.execute"),
                                new PackageCompatibilityDef("1.0.0", "1.0.x", "stable-1"),
                                true))));

    PublishPreparation preparation =
        new PublishOrchestrator().prepare(
            SchemaSyncCommand.forObjects(1L, 10L, "crm", List.of(customer, customization), List.of()));

    assertThat(preparation.commercialReport().blocked()).isTrue();
    assertThat(preparation.commercialReport().blockingErrors()).extracting(ValidationError::code)
        .contains("LC-META-PKG-001", "LC-META-PUBLISH-001");
    assertThat(preparation.commercialReport().warnings()).extracting(ValidationError::code)
        .contains("LC-META-PUBLISH-002", "LC-META-PUBLISH-003");
    assertThat(preparation.commercialReport().extensionMergeReports()).singleElement()
        .satisfies(report -> assertThat(report.mergedFields()).extracting(FieldDef::code).contains("customer_level"));
  }
}
