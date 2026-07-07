package com.lowcode.metamodel.domain.def;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import org.junit.jupiter.api.Test;

class CommercialMetadataDtoCoverageTest {

  private final ObjectMapper objectMapper = new ObjectMapper();

  @Test
  void commercialMetadata_shouldCarryAllM0ReservedStructures() {
    CommercialMetadataDef metadata =
        CommercialMetadataDef.empty(1)
            .withObjectExtensions(
                List.of(
                    new ObjectExtensionDef(
                        "ext",
                        "customer",
                        "customer",
                        "sales_pkg",
                        "1.0.0",
                        "field_add",
                        "reject",
                        List.of(new FieldDef("customer_level", "客户等级", com.lowcode.metamodel.domain.enums.FieldTypeEnum.TEXT, false, new FieldOptionsDef(1))),
                        false)))
            .withLinkConfigs(List.of(new LinkConfigDef("order_customer", "order", "customer", false)))
            .withConversions(List.of(new ConversionDef("order_invoice", "order", "invoice", false)))
            .withWriteBacks(List.of(new WriteBackDef("invoice_amount", "invoice", "order", false)))
            .withLinkTraces(List.of(new LinkTraceDef("trace_order", "order", "invoice", false)))
            .withFlexFields(List.of(new FlexFieldDef("aux", "order", false)))
            .withOrgRelations(List.of(new OrgRelationDef("sales_org", "order", false)))
            .withCodeRules(List.of(new CodeRuleDef("order_no", "order", false)))
            .withReports(List.of(new ReportDef("order_report", "report.view", "report.order.title", true, false)))
            .withPrintTemplates(List.of(new PrintTemplateDef("order_print", "order", "print.execute", "print.order.title", true, false)))
            .withMenus(List.of(new MenuDef("order_menu", "menu.view", "menu.order.title", "page", "order_page", "desktop", true, false)))
            .withI18nResources(List.of(new I18nResourceDef("order.title", "zh-CN", "订单", false)))
            .withPackageManifests(
                List.of(
                    new PackageManifestDef(
                        "sales_pkg",
                        "1.0.0",
                        List.of(new PackageDependencyDef("base_pkg", "1.0.0")),
                        "Commercial",
                        List.of("customer"),
                        List.of("ext"),
                        List.of("order_menu"),
                        List.of("order_report"),
                        List.of("report.view"),
                        new PackageCompatibilityDef("1.0.0", "1.0.x", "stable-1"),
                        false)))
            .withLicensePolicies(List.of(new LicensePolicyDef("offline", "read_only", true, true, true, false)));

    assertThat(metadata.linkConfigs()).hasSize(1);
    assertThat(metadata.writeBacks()).hasSize(1);
    assertThat(metadata.packageManifests()).hasSize(1);
    assertThat(metadata.objectExtensions().getFirst().fields()).hasSize(1);
  }

  @Test
  void appSnapshot_shouldCarryObjectsRolesAndCommercialMetadataWithVersion() {
    AppSnapshotDef snapshot =
        new AppSnapshotDef(
            1,
            1001L,
            "sales",
            "v1",
            List.of(),
            List.of(),
            List.of(),
            List.of(),
            List.of(),
            CommercialMetadataDef.empty(1));

    JsonNode json = objectMapper.valueToTree(snapshot);

    assertThat(json.get("_v").asInt()).isEqualTo(1);
    assertThat(json.get("appCode").asText()).isEqualTo("sales");
    assertThat(json.get("commercial").get("_v").asInt()).isEqualTo(1);
  }
}
