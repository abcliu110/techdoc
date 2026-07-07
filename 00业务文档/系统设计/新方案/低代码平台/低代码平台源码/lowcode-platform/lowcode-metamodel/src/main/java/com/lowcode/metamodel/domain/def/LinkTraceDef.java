package com.lowcode.metamodel.domain.def;

/** 上查/下查追踪占位结构。M0 不暴露运行时查询行为。 */
public record LinkTraceDef(String traceCode, String sourceObjectCode, String targetObjectCode, boolean runtimeEnabled) {}
