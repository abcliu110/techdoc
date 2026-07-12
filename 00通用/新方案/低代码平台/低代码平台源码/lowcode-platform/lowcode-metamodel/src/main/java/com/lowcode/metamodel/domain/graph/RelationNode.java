package com.lowcode.metamodel.domain.graph;

import com.lowcode.metamodel.domain.enums.RelationTypeEnum;

/**
 * MetaGraph 关系节点。
 */
public record RelationNode(String sourceObjectCode, String sourceFieldCode, String targetObjectCode, RelationTypeEnum relationType) {}
