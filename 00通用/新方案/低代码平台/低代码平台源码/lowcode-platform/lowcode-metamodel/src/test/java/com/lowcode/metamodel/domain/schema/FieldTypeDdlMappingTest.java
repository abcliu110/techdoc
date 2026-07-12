package com.lowcode.metamodel.domain.schema;

import static org.assertj.core.api.Assertions.assertThat;

import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import org.junit.jupiter.api.Test;

class FieldTypeDdlMappingTest {

  private final FieldTypeDdlMapper mapper = new FieldTypeDdlMapper();

  @Test
  void map_二十二种字段类型_都有映射或明确阻断策略() {
    for (FieldTypeEnum fieldType : FieldTypeEnum.values()) {
      FieldDef field = new FieldDef(fieldType.code(), fieldType.code(), fieldType, false, options(fieldType));

      ColumnDefinition column = mapper.map(field);

      if (fieldType == FieldTypeEnum.TABLE || fieldType == FieldTypeEnum.MULTILINK || fieldType == FieldTypeEnum.FORMULA) {
        assertThat(column).as(fieldType.code()).isNull();
      } else {
        assertThat(column).as(fieldType.code()).isNotNull();
        assertThat(column.sqlFragment()).as(fieldType.code()).contains(fieldType == FieldTypeEnum.LINK ? "link_lid" : fieldType.code());
      }
    }
  }

  @Test
  void m0PublishSupported_高风险字段能力_按发布边界阻断() {
    assertThat(mapper.m0PublishSupported(new FieldDef("tags", "标签", FieldTypeEnum.MULTILINK, false, options(FieldTypeEnum.MULTILINK))))
        .isFalse();
    assertThat(mapper.m0PublishSupported(new FieldDef("labels", "标签", FieldTypeEnum.MULTISELECT, false, FieldOptionsDef.multiselect(1, true))))
        .isFalse();
    assertThat(mapper.m0PublishSupported(new FieldDef("total", "合计", FieldTypeEnum.FORMULA, false, FieldOptionsDef.formula(1, true))))
        .isFalse();
    assertThat(mapper.m0PublishSupported(new FieldDef("customer", "客户", FieldTypeEnum.LINK, false, options(FieldTypeEnum.LINK))))
        .isTrue();
  }

  private static FieldOptionsDef options(FieldTypeEnum fieldType) {
    return switch (fieldType) {
      case TEXT -> FieldOptionsDef.text(1, 255);
      case DECIMAL, CURRENCY -> FieldOptionsDef.decimal(1, 18, 4);
      case LINK, TABLE -> FieldOptionsDef.link(1, "target");
      case MULTILINK -> FieldOptionsDef.multilink(1, "target", "through_object");
      case MULTISELECT -> FieldOptionsDef.multiselect(1, false);
      case FORMULA -> FieldOptionsDef.formula(1, false);
      default -> new FieldOptionsDef(1);
    };
  }
}
