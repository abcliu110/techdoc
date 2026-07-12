package com.lowcode.metamodel.domain.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.common.error.BizException;
import com.lowcode.common.error.ErrorCode;
import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import com.lowcode.metamodel.domain.enums.ObjectTypeEnum;
import java.util.List;
import org.junit.jupiter.api.Test;

class MetaRefServiceTest {

  private final MetaObjectDraftService service = new MetaObjectDraftService();

  @Test
  void saveDraft_带期望版本_版本不一致时拒绝并保留旧引用() {
    service.saveDraft(object("customer", List.of(field("name", FieldTypeEnum.TEXT, FieldOptionsDef.text(1, 128)))));
    service.saveDraft(object("order", List.of(field("customer", FieldTypeEnum.LINK, FieldOptionsDef.link(1, "customer")))));

    MetaObjectDraft stale =
        object("order", List.of(field("customer", FieldTypeEnum.LINK, FieldOptionsDef.link(1, "supplier")))).withExpectedRevision(0L);

    assertThatThrownBy(() -> service.saveDraft(stale))
        .isInstanceOf(BizException.class)
        .extracting("errorCode")
        .isEqualTo(ErrorCode.META_CONFLICT);
    assertThat(service.refsFrom(1L, 10L, "order")).extracting(MetaRefDef::targetCode).containsExactly("customer");
  }

  @Test
  void refsFrom_保存对象后_按对象来源重建引用索引() {
    service.saveDraft(object("customer", List.of(field("name", FieldTypeEnum.TEXT, FieldOptionsDef.text(1, 128)))));
    service.saveDraft(object("order", List.of(field("customer", FieldTypeEnum.LINK, FieldOptionsDef.link(1, "customer")))));
    service.saveDraft(
        service.get(1L, 10L, "order")
            .withFields(List.of(field("supplier", FieldTypeEnum.LINK, FieldOptionsDef.link(1, "supplier"))))
            .withExpectedRevision(1L));

    assertThat(service.refsFrom(1L, 10L, "order"))
        .extracting(MetaRefDef::targetCode)
        .containsExactly("supplier");
  }

  @Test
  void analyzeDeleteObject_目标仍被引用_返回影响路径() {
    service.saveDraft(object("customer", List.of(field("name", FieldTypeEnum.TEXT, FieldOptionsDef.text(1, 128)))));
    service.saveDraft(object("order", List.of(field("customer", FieldTypeEnum.LINK, FieldOptionsDef.link(1, "customer")))));

    List<MetaRefDef> impacts = service.analyzeDeleteObject(1L, 10L, "customer");

    assertThat(impacts).singleElement().satisfies(ref -> {
      assertThat(ref.sourceCode()).isEqualTo("order");
      assertThat(ref.sourcePath()).isEqualTo("fields[0].options.targetObjectCode");
      assertThat(ref.targetCode()).isEqualTo("customer");
    });
  }

  private static MetaObjectDraft object(String code, List<FieldDef> fields) {
    return new MetaObjectDraft(1L, 10L, code, code, ObjectTypeEnum.DOCUMENT, fields);
  }

  private static FieldDef field(String code, FieldTypeEnum fieldType, FieldOptionsDef options) {
    return new FieldDef(code, code, fieldType, false, options);
  }
}
