package com.lowcode.metamodel.domain.schema;

import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;

/**
 * 字段类型到 MySQL 列定义的 M0 映射。
 *
 * <p>Schema Sync 只能通过这个类消费字段类型策略，避免在计划器里散落多套字段类型判断。
 */
public class FieldTypeDdlMapper {

  public ColumnDefinition map(FieldDef field) {
    FieldOptionsDef options = field.options();
    return switch (field.fieldType()) {
      case TEXT -> varchar(field.code(), options == null || options.length() == null ? 255 : options.length());
      case TEXTAREA -> simple(field.code(), "text", null, null, null, field.code() + " text");
      case RICHTEXT, CODE -> simple(field.code(), "mediumtext", null, null, null, field.code() + " mediumtext");
      case INTEGER -> simple(field.code(), "bigint", null, null, null, field.code() + " bigint");
      case DECIMAL, CURRENCY -> decimal(field, options, 18, 4);
      case PERCENT -> simple(field.code(), "decimal", null, 9, 4, field.code() + " decimal(9,4)");
      case DATE -> simple(field.code(), "date", null, null, null, field.code() + " date");
      case DATETIME -> simple(field.code(), "datetime", null, null, 3, field.code() + " datetime(3)");
      case TIME -> simple(field.code(), "time", null, null, 3, field.code() + " time(3)");
      case SELECT -> varchar(field.code(), 64);
      case MULTISELECT, ATTACHMENT -> simple(field.code(), "json", null, null, null, field.code() + " json");
      case CHECKBOX -> simple(field.code(), "tinyint", null, null, null, field.code() + " tinyint");
      case LINK, USER, ORG -> varchar(field.code() + "_lid", 26);
      case AUTONUMBER -> varchar(field.code(), 64);
      case TABLE, MULTILINK, FORMULA -> null;
    };
  }

  public boolean m0PublishSupported(FieldDef field) {
    if (field.fieldType() == FieldTypeEnum.MULTILINK) {
      return false;
    }
    if (field.fieldType() == FieldTypeEnum.FORMULA && field.options() != null && Boolean.TRUE.equals(field.options().persisted())) {
      return false;
    }
    if (field.fieldType() == FieldTypeEnum.MULTISELECT && field.options() != null && Boolean.TRUE.equals(field.options().inFilter())) {
      return false;
    }
    return true;
  }

  private static ColumnDefinition varchar(String name, int length) {
    return simple(name, "varchar", length, null, null, name + " varchar(" + length + ")");
  }

  private static ColumnDefinition decimal(FieldDef field, FieldOptionsDef options, int defaultPrecision, int defaultScale) {
    int precision = options == null || options.precision() == null ? defaultPrecision : options.precision();
    int scale = options == null || options.scale() == null ? defaultScale : options.scale();
    return simple(field.code(), "decimal", null, precision, scale, field.code() + " decimal(" + precision + "," + scale + ")");
  }

  private static ColumnDefinition simple(
      String name, String typeName, Integer length, Integer precision, Integer scale, String sqlFragment) {
    return new ColumnDefinition(name, typeName, length, precision, scale, sqlFragment);
  }
}
