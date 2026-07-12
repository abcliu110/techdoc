package com.lowcode.metamodel.domain.graph;

import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;

/**
 * MetaGraph 字段节点。
 *
 * <p>字段节点是运行态只读视图，后续动态 API 只能读取它，不能回写设计态草稿。
 */
public record FieldNode(String code, String name, FieldTypeEnum fieldType, String columnName, boolean required, FieldOptionsDef options) {}
