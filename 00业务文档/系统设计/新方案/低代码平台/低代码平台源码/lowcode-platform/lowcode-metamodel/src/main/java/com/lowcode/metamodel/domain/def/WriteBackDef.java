package com.lowcode.metamodel.domain.def;

/** 反写占位结构。M0 禁止根据这类元数据执行副作用。 */
public record WriteBackDef(String writeBackCode, String sourceObjectCode, String targetObjectCode, boolean runtimeEnabled) {}
