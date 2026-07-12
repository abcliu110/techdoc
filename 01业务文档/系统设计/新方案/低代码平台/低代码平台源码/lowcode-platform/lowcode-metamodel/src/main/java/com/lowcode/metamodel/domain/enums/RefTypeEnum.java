package com.lowcode.metamodel.domain.enums;

/** 抽取到 lc_meta_ref 的引用索引类型。 */
public enum RefTypeEnum implements CodeEnum {
  FIELD_LINK_OBJECT("field_link_object"),
  FIELD_FETCH_FROM("field_fetch_from"),
  OBJECT_EXTENSION_BASE("object_extension_base"),
  DOCUMENT_CONVERSION_OBJECT("document_conversion_object"),
  WRITEBACK_OBJECT("writeback_object"),
  LINK_TRACE_OBJECT("link_trace_object"),
  FLEX_FIELD_OBJECT("flex_field_object"),
  ORG_RELATION_OBJECT("org_relation_object"),
  CODE_RULE_OBJECT("code_rule_object"),
  REPORT_DATASET("report_dataset"),
  PRINT_TEMPLATE_OBJECT("print_template_object"),
  MENU_TARGET("menu_target"),
  PACKAGE_DEPENDENCY("package_dependency");

  private final String code;

  RefTypeEnum(String code) {
    this.code = code;
  }

  @Override
  public String code() {
    return code;
  }
}
