package com.lowcode.metamodel.domain.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.def.ObjectExtensionDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import com.lowcode.metamodel.domain.enums.ObjectTypeEnum;
import java.util.List;
import org.junit.jupiter.api.Test;

class ObjectExtensionMergeServiceTest {

  private final ObjectExtensionMergeService service = new ObjectExtensionMergeService();

  @Test
  void merge_按固定扩展层顺序合并新增字段并生成报告() {
    MetaObjectDraft baseObject =
        new MetaObjectDraft(
            1L,
            10L,
            "customer",
            "客户",
            ObjectTypeEnum.DOCUMENT,
            List.of(field("name", "名称"), field("mobile", "手机号")));

    List<ObjectExtensionDef> extensions =
        List.of(
            extension("industry_profile", "industry_template", "industry_pkg", "industry_code"),
            extension("customer_profile", "customer", "customer_pkg", "customer_level"),
            extension("plugin_profile", "plugin", "plugin_pkg", "plugin_score"));

    ObjectExtensionMergeReport report = service.merge(baseObject, extensions);

    assertThat(report.blocked()).isFalse();
    assertThat(report.mergedFields()).extracting(FieldDef::code)
        .containsExactly("name", "mobile", "industry_code", "customer_level", "plugin_score");
    assertThat(report.appliedExtensions()).extracting(ObjectExtensionDef::extensionCode)
        .containsExactly("industry_profile", "customer_profile", "plugin_profile");
  }

  @Test
  void merge_覆盖系统字段和跨层同名字段_阻断发布并返回冲突详情() {
    MetaObjectDraft baseObject =
        new MetaObjectDraft(
            1L,
            10L,
            "customer",
            "客户",
            ObjectTypeEnum.DOCUMENT,
            List.of(field("name", "名称"), field("mobile", "手机号")));

    List<ObjectExtensionDef> extensions =
        List.of(
            extension("customer_override", "customer", "customer_pkg", "name"),
            extension("customer_conflict", "customer", "customer_pkg", "risk_level"),
            extension("plugin_conflict", "plugin", "plugin_pkg", "risk_level"));

    ObjectExtensionMergeReport report = service.merge(baseObject, extensions);

    assertThat(report.blocked()).isTrue();
    assertThat(report.blockingErrors()).extracting(ValidationError::code)
        .contains("LC-META-EXT-001", "LC-META-EXT-002");
    assertThat(report.blockingErrors()).extracting(ValidationError::path)
        .contains(
            "objectExtensions[customer_override].fields[name]",
            "objectExtensions[plugin_conflict].fields[risk_level]");
  }

  private static ObjectExtensionDef extension(
      String extensionCode, String sourceKind, String packageCode, String fieldCode) {
    return new ObjectExtensionDef(
        extensionCode,
        "customer",
        sourceKind,
        packageCode,
        "1.0.0",
        "field_add",
        "reject",
        List.of(field(fieldCode, fieldCode)),
        true);
  }

  private static FieldDef field(String code, String name) {
    return new FieldDef(code, name, FieldTypeEnum.TEXT, false, FieldOptionsDef.text(1, 64));
  }
}
