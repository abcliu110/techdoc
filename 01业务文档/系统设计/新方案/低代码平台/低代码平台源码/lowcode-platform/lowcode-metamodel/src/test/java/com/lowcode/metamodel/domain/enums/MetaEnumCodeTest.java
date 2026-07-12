package com.lowcode.metamodel.domain.enums;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.junit.jupiter.api.Test;

class MetaEnumCodeTest {

  @Test
  void fieldTypeEnum_shouldContainTwentyTwoStableCodes() {
    List<String> codes = Arrays.stream(FieldTypeEnum.values()).map(FieldTypeEnum::code).toList();

    assertThat(codes)
        .containsExactlyInAnyOrder(
            "text",
            "textarea",
            "richtext",
            "code",
            "integer",
            "decimal",
            "percent",
            "currency",
            "date",
            "datetime",
            "time",
            "select",
            "multiselect",
            "checkbox",
            "link",
            "table",
            "multilink",
            "autonumber",
            "user",
            "org",
            "attachment",
            "formula");
  }

  @Test
  void commercialEnums_shouldExposeRequiredCodes() {
    assertThat(codes(ObjectCategoryEnum.values())).contains("standard", "template", "custom", "extension");
    assertThat(codes(MetaSourceKindEnum.values())).contains("system", "vendor", "customer");
    assertThat(codes(ExtensionPolicyEnum.values())).contains("none", "copy", "extension_layer");
    assertThat(codes(TraceDirectionEnum.values())).contains("upstream", "downstream", "bidirectional");
    assertThat(codes(DeviceScopeEnum.values())).contains("desktop", "mobile", "all");
    assertThat(codes(LicenseModeEnum.values())).contains("none", "offline", "online", "hybrid");
  }

  @Test
  void allEnums_shouldHaveUniqueCodesAndNeverUseOrdinalAsCode() {
    assertUniqueStableCodes(FieldTypeEnum.values());
    assertUniqueStableCodes(ObjectTypeEnum.values());
    assertUniqueStableCodes(ObjectStatusEnum.values());
    assertUniqueStableCodes(RelationTypeEnum.values());
    assertUniqueStableCodes(DeletePolicyEnum.values());
    assertUniqueStableCodes(StateTypeEnum.values());
    assertUniqueStableCodes(ActionTypeEnum.values());
    assertUniqueStableCodes(ActionScopeEnum.values());
    assertUniqueStableCodes(RuleTriggerEnum.values());
    assertUniqueStableCodes(RuleTypeEnum.values());
    assertUniqueStableCodes(PublishStatusEnum.values());
    assertUniqueStableCodes(RoleTypeEnum.values());
    assertUniqueStableCodes(DatasourceTypeEnum.values());
    assertUniqueStableCodes(PluginStatusEnum.values());
    assertUniqueStableCodes(RefTypeEnum.values());
    assertUniqueStableCodes(MetaSourceTypeEnum.values());
    assertUniqueStableCodes(MetaTargetTypeEnum.values());
    assertUniqueStableCodes(ObjectCategoryEnum.values());
    assertUniqueStableCodes(MetaSourceKindEnum.values());
    assertUniqueStableCodes(ExtensionPolicyEnum.values());
    assertUniqueStableCodes(ExtensionTypeEnum.values());
    assertUniqueStableCodes(ConflictPolicyEnum.values());
    assertUniqueStableCodes(TraceDirectionEnum.values());
    assertUniqueStableCodes(TracePermissionPolicyEnum.values());
    assertUniqueStableCodes(ConversionIdempotencyStrategyEnum.values());
    assertUniqueStableCodes(WriteBackTriggerTimingEnum.values());
    assertUniqueStableCodes(WriteBackCompensationPolicyEnum.values());
    assertUniqueStableCodes(FlexValueTypeEnum.values());
    assertUniqueStableCodes(OrgRoleTypeEnum.values());
    assertUniqueStableCodes(OrgTimePolicyEnum.values());
    assertUniqueStableCodes(CodeRuleGapPolicyEnum.values());
    assertUniqueStableCodes(ReportExportPolicyEnum.values());
    assertUniqueStableCodes(TemplateDataSnapshotPolicyEnum.values());
    assertUniqueStableCodes(MenuTargetTypeEnum.values());
    assertUniqueStableCodes(DeviceScopeEnum.values());
    assertUniqueStableCodes(I18nFallbackPolicyEnum.values());
    assertUniqueStableCodes(PackageSourceKindEnum.values());
    assertUniqueStableCodes(LicenseModeEnum.values());
    assertUniqueStableCodes(LicenseDegradePolicyEnum.values());
  }

  private static List<String> codes(CodeEnum[] values) {
    return Arrays.stream(values).map(CodeEnum::code).toList();
  }

  private static void assertUniqueStableCodes(CodeEnum[] values) {
    Set<String> seen = new HashSet<>();
    for (int i = 0; i < values.length; i++) {
      String code = values[i].code();
      assertThat(code).isNotBlank();
      assertThat(code).isNotEqualTo(String.valueOf(i));
      assertThat(seen.add(code)).isTrue();
    }
  }
}
