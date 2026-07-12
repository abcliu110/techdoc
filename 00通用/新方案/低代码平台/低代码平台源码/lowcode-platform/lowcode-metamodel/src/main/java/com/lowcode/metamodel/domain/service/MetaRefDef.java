package com.lowcode.metamodel.domain.service;

/**
 * 元数据引用索引项。
 *
 * <p>引用索引可以从对象草稿重建，不能成为事实源；删除影响分析只消费它加速判断。
 */
public record MetaRefDef(
    Long tenantId,
    Long appId,
    String sourceType,
    String sourceCode,
    String sourcePath,
    String refType,
    String targetType,
    String targetCode) {}
