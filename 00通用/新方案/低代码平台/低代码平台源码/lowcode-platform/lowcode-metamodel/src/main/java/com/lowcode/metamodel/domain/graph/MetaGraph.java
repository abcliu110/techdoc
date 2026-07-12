package com.lowcode.metamodel.domain.graph;

import java.util.List;
import java.util.Map;

/**
 * 已发布应用的不可变元数据图。
 *
 * <p>MetaGraph 是运行态唯一元数据来源。设计态草稿变化不能修改已经构建完成的图。
 */
public record MetaGraph(
    Long tenantId,
    String appCode,
    String metaVersion,
    Map<String, ObjectNode> objectsByCode,
    Map<String, List<RefEdge>> refsBySource,
    Map<String, List<RefEdge>> refsByTarget) {

  public MetaGraph {
    objectsByCode = Map.copyOf(objectsByCode);
    refsBySource = copyListMap(refsBySource);
    refsByTarget = copyListMap(refsByTarget);
  }

  public ObjectNode object(String objectCode) {
    ObjectNode node = objectsByCode.get(objectCode);
    if (node == null) {
      throw new MetaGraphNotFoundException("对象不存在：" + objectCode);
    }
    return node;
  }

  public List<RefEdge> refsFrom(String sourceCode) {
    return refsBySource.getOrDefault(sourceCode, List.of());
  }

  private static Map<String, List<RefEdge>> copyListMap(Map<String, List<RefEdge>> source) {
    return source.entrySet().stream().collect(
        java.util.stream.Collectors.toUnmodifiableMap(Map.Entry::getKey, entry -> List.copyOf(entry.getValue())));
  }
}
