package com.lowcode.common.tenant;

import com.lowcode.common.error.BizException;
import com.lowcode.common.error.ErrorCode;

/**
 * 请求级租户上下文。M0 只保留 ThreadLocal 形态，Web 绑定在后续 API 任务中补齐。
 *
 * <p>租户缺失必须快速失败，这是平台级安全规则：服务层不能在没有租户信息时静默退化成全局查询。这里刻意保持简单，
 * 因为 T-001 只是工程骨架；Servlet 过滤器、异步上下文传递和跨线程泄漏测试都属于后续 API/运行时任务。
 */
public final class TenantContext {

  private static final ThreadLocal<Long> TENANT_ID = new ThreadLocal<>();

  private TenantContext() {}

  public static void setTenantId(Long tenantId) {
    TENANT_ID.set(tenantId);
  }

  public static Long requireTenantId() {
    Long tenantId = TENANT_ID.get();
    if (tenantId == null) {
      // SECURITY: 缺失租户上下文是硬错误，不能伪装成空结果。
      throw new BizException(ErrorCode.TENANT_REQUIRED, ErrorCode.TENANT_REQUIRED.message());
    }
    return tenantId;
  }

  public static void clear() {
    TENANT_ID.remove();
  }
}
