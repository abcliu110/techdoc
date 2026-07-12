package com.lowcode.metamodel.domain.service;

import static org.assertj.core.api.Assertions.assertThat;

import com.lowcode.metamodel.domain.def.CodeRuleDef;
import com.lowcode.metamodel.domain.def.CommercialMetadataDef;
import com.lowcode.metamodel.domain.def.ConversionDef;
import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.def.LicensePolicyDef;
import com.lowcode.metamodel.domain.def.ObjectExtensionDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import com.lowcode.metamodel.domain.enums.ObjectTypeEnum;
import java.util.List;
import org.junit.jupiter.api.Test;

class MetaObjectDraftServiceTest {

  private final MetaObjectDraftService service = new MetaObjectDraftService();

  @Test
  void saveDraft_合法对象_可以读取字段和自动关系() {
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "订单",
            ObjectTypeEnum.DOCUMENT,
            List.of(
                field("customer", "客户", FieldTypeEnum.LINK, FieldOptionsDef.link(1, "customer")),
                field("amount", "金额", FieldTypeEnum.DECIMAL, FieldOptionsDef.decimal(1, 18, 4))));

    MetaObjectDraft saved = service.saveDraft(order);

    assertThat(saved.revision()).isEqualTo(1L);
    assertThat(service.get(1L, 10L, "order").fields()).extracting(FieldDef::code).containsExactly("customer", "amount");
    assertThat(service.get(1L, 10L, "order").relations()).extracting(MetaRelationDef::targetObjectCode).containsExactly("customer");
  }

  @Test
  void validateDraft_重复字段编码_返回字段路径错误() {
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "订单",
            ObjectTypeEnum.DOCUMENT,
            List.of(
                field("amount", "金额一", FieldTypeEnum.DECIMAL, FieldOptionsDef.decimal(1, 18, 4)),
                field("amount", "金额二", FieldTypeEnum.DECIMAL, FieldOptionsDef.decimal(1, 18, 4))));

    ValidationReport report = service.validateDraft(order);

    assertThat(report.passed()).isFalse();
    assertThat(report.errors()).anySatisfy(error -> {
      assertThat(error.path()).isEqualTo("fields[1].code");
      assertThat(error.code()).isEqualTo("LC-META-1001");
    });
  }

  @Test
  void validateApp_多链接字段_草稿允许保存但发布前阻断() {
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "订单",
            ObjectTypeEnum.DOCUMENT,
            List.of(field("tags", "标签", FieldTypeEnum.MULTILINK, FieldOptionsDef.multilink(1, "tag", "order_tag"))));

    assertThat(service.validateDraft(order).passed()).isTrue();
    service.saveDraft(order);

    ValidationReport report = service.validateApp(1L, 10L);

    assertThat(report.passed()).isFalse();
    assertThat(report.errors()).anySatisfy(error -> {
      assertThat(error.path()).isEqualTo("objects[order].fields[0].fieldType");
      assertThat(error.code()).isEqualTo("LC-META-3001");
    });
  }

  @Test
  void validateApp_link目标对象不存在_发布前返回引用不存在错误() {
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "订单",
            ObjectTypeEnum.DOCUMENT,
            List.of(field("customer", "客户", FieldTypeEnum.LINK, FieldOptionsDef.link(1, "customer"))));
    service.saveDraft(order);

    ValidationReport report = service.validateApp(1L, 10L);

    assertThat(report.passed()).isFalse();
    assertThat(report.errors()).anySatisfy(error -> {
      assertThat(error.path()).isEqualTo("objects[order].fields[0].options.targetObjectCode");
      assertThat(error.code()).isEqualTo("LC-META-1101");
    });
  }

  @Test
  void validateDraft_fetchFrom路径不存在_返回字段路径错误() {
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "订单",
            ObjectTypeEnum.DOCUMENT,
            List.of(
                field("customer", "客户", FieldTypeEnum.LINK, FieldOptionsDef.link(1, "customer")),
                field("customer_level", "客户等级", FieldTypeEnum.TEXT, FieldOptionsDef.fetchFrom(1, "customer.missing_level"))));

    ValidationReport report = service.validateDraft(order);

    assertThat(report.passed()).isFalse();
    assertThat(report.errors()).anySatisfy(error -> {
      assertThat(error.path()).isEqualTo("fields[1].options.fetchFrom");
      assertThat(error.code()).isEqualTo("LC-META-1101");
    });
  }

  @Test
  void validateDraft_状态机多个初始状态_返回状态机错误() {
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "订单",
            ObjectTypeEnum.DOCUMENT,
            List.of(field("name", "名称", FieldTypeEnum.TEXT, FieldOptionsDef.text(1, 128))))
            .withStates(
                List.of(
                    new MetaStateDef("draft", true, false, List.of(new MetaTransitionDef("submit", "draft", "submitted"))),
                    new MetaStateDef("submitted", true, false, List.of())));

    ValidationReport report = service.validateDraft(order);

    assertThat(report.passed()).isFalse();
    assertThat(report.errors()).anySatisfy(error -> {
      assertThat(error.path()).isEqualTo("states");
      assertThat(error.code()).isEqualTo("LC-META-1301");
    });
  }

  @Test
  void validateDraft_状态流转目标不存在_返回状态机错误() {
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "订单",
            ObjectTypeEnum.DOCUMENT,
            List.of(field("name", "名称", FieldTypeEnum.TEXT, FieldOptionsDef.text(1, 128))))
            .withStates(List.of(new MetaStateDef("draft", true, false, List.of(new MetaTransitionDef("submit", "draft", "missing")))));

    ValidationReport report = service.validateDraft(order);

    assertThat(report.passed()).isFalse();
    assertThat(report.errors()).anySatisfy(error -> {
      assertThat(error.path()).isEqualTo("states[0].transitions[0].toState");
      assertThat(error.code()).isEqualTo("LC-META-1301");
    });
  }

  @Test
  void validateApp_商业元数据只做结构校验_不因发布门禁提前阻断并保留引用索引() {
    CommercialMetadataDef commercialMetadata =
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
                        List.of(field("customer_grade", "客户等级", FieldTypeEnum.TEXT, FieldOptionsDef.text(1, 64))),
                        true)))
            .withConversions(List.of(new ConversionDef("order_to_delivery", "order", "delivery", true)))
            .withCodeRules(List.of(new CodeRuleDef("order_no", "order", true)))
            .withLicensePolicies(
                List.of(
                    new LicensePolicyDef(
                        "online",
                        "read_only",
                        true,
                        true,
                        false,
                        true)));
    MetaObjectDraft order =
        new MetaObjectDraft(
            1L,
            10L,
            "order",
            "订单",
            ObjectTypeEnum.DOCUMENT,
            List.of(field("name", "名称", FieldTypeEnum.TEXT, FieldOptionsDef.text(1, 128))))
            .withCommercialMetadata(commercialMetadata);
    service.saveDraft(new MetaObjectDraft(1L, 10L, "customer", "客户", ObjectTypeEnum.DOCUMENT, List.of()));
    service.saveDraft(new MetaObjectDraft(1L, 10L, "delivery", "发货单", ObjectTypeEnum.DOCUMENT, List.of()));
    service.saveDraft(order);

    ValidationReport report = service.validateApp(1L, 10L);

    assertThat(report.passed()).isTrue();
    assertThat(report.errors()).isEmpty();
    assertThat(service.refsFrom(1L, 10L, "order")).extracting(MetaRefDef::refType)
        .contains("OBJECT_EXTENSION_BASE", "DOCUMENT_CONVERSION_OBJECT", "CODE_RULE_OBJECT");
  }

  private static FieldDef field(String code, String name, FieldTypeEnum fieldType, FieldOptionsDef options) {
    return new FieldDef(code, name, fieldType, false, options);
  }
}
