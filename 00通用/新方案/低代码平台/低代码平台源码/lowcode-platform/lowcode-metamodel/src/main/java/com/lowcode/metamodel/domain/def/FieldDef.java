package com.lowcode.metamodel.domain.def;

import com.lowcode.metamodel.domain.enums.FieldTypeEnum;

/**
 * `lc_meta_object.fields` 内的草稿字段定义。
 *
 * <p>这个 DTO 不是运行时数据列。字段是否映射到 MySQL、如何映射，由后续 Schema Sync 决定。
 */
public record FieldDef(
    String code,
    String name,
    FieldTypeEnum fieldType,
    boolean required,
    FieldOptionsDef options) {}
