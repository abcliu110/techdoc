package com.lowcode.metamodel.domain.def;

/**
 * 单据转换元数据占位结构。
 *
 * <p>M0 只记录来源对象和目标对象意图，禁止触发转换副作用。
 */
public record ConversionDef(
    String conversionCode, String sourceObjectCode, String targetObjectCode, boolean runtimeEnabled) {}
