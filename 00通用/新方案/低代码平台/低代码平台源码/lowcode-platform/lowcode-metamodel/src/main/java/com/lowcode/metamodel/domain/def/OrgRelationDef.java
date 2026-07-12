package com.lowcode.metamodel.domain.def;

/** 多组织关系占位结构。运行时权限语义从 M0 之后开始。 */
public record OrgRelationDef(String relationCode, String sourceObjectCode, boolean runtimeEnabled) {}
