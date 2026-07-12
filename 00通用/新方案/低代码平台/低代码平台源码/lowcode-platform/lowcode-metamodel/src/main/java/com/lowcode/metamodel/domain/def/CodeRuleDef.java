package com.lowcode.metamodel.domain.def;

/** 业务编码规则占位结构。M0 不分配业务编号。 */
public record CodeRuleDef(String ruleCode, String objectCode, boolean runtimeEnabled) {}
