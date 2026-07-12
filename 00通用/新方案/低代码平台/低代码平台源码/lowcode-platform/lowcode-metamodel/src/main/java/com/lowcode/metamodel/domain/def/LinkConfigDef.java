package com.lowcode.metamodel.domain.def;

/** 链路配置占位结构。M0 只保存意图，不执行运行时追踪。 */
public record LinkConfigDef(String linkCode, String sourceObjectCode, String targetObjectCode, boolean runtimeEnabled) {}
