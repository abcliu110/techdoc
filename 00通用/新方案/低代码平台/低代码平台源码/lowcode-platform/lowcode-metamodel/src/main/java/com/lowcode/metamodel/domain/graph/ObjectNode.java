package com.lowcode.metamodel.domain.graph;

import java.util.Map;

/**
 * MetaGraph 对象节点。
 */
public record ObjectNode(
    String code,
    String name,
    String tableName,
    Map<String, FieldNode> fieldsByCode,
    Map<String, RelationNode> relationsByCode) {

  public ObjectNode {
    fieldsByCode = Map.copyOf(fieldsByCode);
    relationsByCode = Map.copyOf(relationsByCode);
  }
}
