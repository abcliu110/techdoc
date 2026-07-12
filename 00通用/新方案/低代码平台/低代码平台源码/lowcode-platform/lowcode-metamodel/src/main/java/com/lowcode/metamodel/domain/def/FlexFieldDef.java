package com.lowcode.metamodel.domain.def;

/** 弹性域占位结构。M0 防止它被当作无类型 JSON 逃生口。 */
public record FlexFieldDef(String flexCode, String applyToObject, boolean runtimeEnabled) {}
