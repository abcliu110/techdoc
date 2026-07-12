package com.lowcode.metamodel.domain.def;

import java.util.List;

/**
 * 标准对象扩展元数据占位结构。
 *
 * <p>`runtimeEnabled=false` 是 M0 安全边界的一部分：平台可以保存这类元数据，但不能执行继承或合并行为。
 */
public record ObjectExtensionDef(
    String extensionCode,
    String baseObjectCode,
    String sourceKind,
    String packageCode,
    String packageVersion,
    String extensionType,
    String conflictPolicy,
    List<FieldDef> fields,
    boolean runtimeEnabled) {

  public ObjectExtensionDef {
    fields = fields == null ? List.of() : List.copyOf(fields);
  }

  public ObjectExtensionDef(String extensionCode, String baseObjectCode, boolean runtimeEnabled) {
    this(
        extensionCode,
        baseObjectCode,
        "customer",
        null,
        null,
        "field_add",
        "reject",
        List.of(),
        runtimeEnabled);
  }
}
