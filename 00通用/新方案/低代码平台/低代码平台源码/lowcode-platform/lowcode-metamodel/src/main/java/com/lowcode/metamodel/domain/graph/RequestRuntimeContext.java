package com.lowcode.metamodel.domain.graph;

/**
 * 请求级运行上下文。
 *
 * <p>上下文创建后固定 MetaGraph 和 metaHash，后续服务只能消费这个对象，不能重新读取 latest。
 */
public record RequestRuntimeContext(Long tenantId, String userLid, MetaGraph metaGraph, String metaHash, String traceId) {

  public static RequestRuntimeContext open(Long tenantId, String userLid, MetaGraph metaGraph, String traceId) {
    return new RequestRuntimeContext(tenantId, userLid, metaGraph, metaGraph.metaVersion(), traceId);
  }

  public void assertRequestMetaHash(String requestMetaHash) {
    if (!metaHash.equals(requestMetaHash)) {
      throw new MetaVersionStaleException("元数据版本已过期，请刷新后重试");
    }
  }
}
