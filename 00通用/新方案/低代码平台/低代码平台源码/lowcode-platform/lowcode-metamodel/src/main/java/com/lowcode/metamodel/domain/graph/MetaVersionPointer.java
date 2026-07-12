package com.lowcode.metamodel.domain.graph;

import java.util.Optional;

/**
 * 当前版本指针接口。
 *
 * <p>真实实现可以接 Redis；M0 用接口锁定语义，Redis 不可用时 Provider 会回退仓储当前版本轮询。
 */
public interface MetaVersionPointer {

  Optional<String> findCurrent(Long tenantId, String appCode);
}
