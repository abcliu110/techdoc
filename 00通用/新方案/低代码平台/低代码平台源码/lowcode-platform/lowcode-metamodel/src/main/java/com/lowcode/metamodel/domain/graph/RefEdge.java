package com.lowcode.metamodel.domain.graph;

/**
 * MetaGraph 引用边。
 */
public record RefEdge(String sourceCode, String sourcePath, String refType, String targetType, String targetCode) {}
