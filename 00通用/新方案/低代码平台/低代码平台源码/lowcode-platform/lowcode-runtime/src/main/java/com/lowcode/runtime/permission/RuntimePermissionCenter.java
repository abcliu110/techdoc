package com.lowcode.runtime.permission;

import com.lowcode.runtime.api.RuntimeRequestContext;
import com.lowcode.runtime.data.DynamicObjectDefinition;

/**
 * 运行态权限中心契约。
 *
 * <p>所有运行态数据操作都必须先通过这个统一入口，把显式租户/工作区/用户上下文收束成一个 {@link AccessView}。
 */
@FunctionalInterface
public interface RuntimePermissionCenter {

  AccessView authorize(RuntimeRequestContext requestContext, DynamicObjectDefinition definition);
}
