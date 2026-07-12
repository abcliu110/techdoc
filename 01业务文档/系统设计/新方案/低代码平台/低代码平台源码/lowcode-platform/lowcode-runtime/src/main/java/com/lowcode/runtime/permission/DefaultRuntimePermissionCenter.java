package com.lowcode.runtime.permission;

import com.lowcode.runtime.api.RuntimeRequestContext;
import com.lowcode.runtime.data.DynamicObjectDefinition;
import com.lowcode.runtime.data.RuntimeDataErrorCode;
import com.lowcode.runtime.data.RuntimeDataException;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * M1 默认权限中心实现。
 *
 * <p>在正式权限中心接入前，它保留演示对象的既有权限语义，但不再允许运行态入口绕过显式上下文。
 */
public class DefaultRuntimePermissionCenter implements RuntimePermissionCenter {

  @Override
  public AccessView authorize(RuntimeRequestContext requestContext, DynamicObjectDefinition definition) {
    requireExplicitContext(requestContext);
    Map<String, FieldAccess> fieldAccess = new HashMap<>();
    Set<String> roleCodes = requestContext.roleCodes() == null ? Set.of() : requestContext.roleCodes();
    if (roleCodes.isEmpty()) {
      definition.fields().keySet().forEach(field -> fieldAccess.put(field, FieldAccess.NONE));
      return new AccessView(
          requestContext.objectCode(),
          Set.of(),
          Map.copyOf(fieldAccess),
          DataScope.self(),
          Set.of(),
          requestContext.metaHash(),
          1L,
          new AccessExplain(false, List.of("运行态默认权限拒绝")));
    }

    definition.fields().keySet().forEach(field -> fieldAccess.put(field, "secret_amount".equals(field) ? FieldAccess.NONE : FieldAccess.WRITE));
    Set<String> allowedActions = definition.stateMachine() == null
        ? Set.of()
        : definition.stateMachine().allowedActionsFor(roleCodes);
    LinkedHashSet<Operation> operations = new LinkedHashSet<>(List.of(
        Operation.READ,
        Operation.CREATE,
        Operation.UPDATE,
        Operation.DELETE,
        Operation.EXPORT,
        Operation.IMPORT));
    if (!allowedActions.isEmpty()) {
      operations.add(Operation.TRANSITION);
    }
    return new AccessView(
        requestContext.objectCode(),
        Set.copyOf(operations),
        Map.copyOf(fieldAccess),
        DataScope.self(),
        allowedActions,
        requestContext.metaHash(),
        1L,
        AccessExplain.allow("运行态默认权限通过"));
  }

  private void requireExplicitContext(RuntimeRequestContext requestContext) {
    if (requestContext.tenantId() == null) {
      throw new RuntimeDataException(RuntimeDataErrorCode.TENANT_REQUIRED, "租户不能为空");
    }
    if (requestContext.workspaceId() == null) {
      throw new RuntimeDataException(RuntimeDataErrorCode.TENANT_REQUIRED, "工作区不能为空");
    }
    if (requestContext.userLid() == null || requestContext.userLid().isBlank()) {
      throw new RuntimeDataException(RuntimeDataErrorCode.TENANT_REQUIRED, "用户不能为空");
    }
  }
}
