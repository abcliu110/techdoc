package com.lowcode.metamodel.domain.upgrade;

import com.lowcode.metamodel.domain.def.VersionedJson;

/**
 * 相邻 schema 版本之间的一步升级器。
 *
 * <p>升级器必须相邻（`fromVersion + 1 == toVersion`），这样缺失的历史迁移会在启动时暴露，而不是在客户请求期间暴露。
 */
public interface JsonUpgrader<T extends VersionedJson> {

  Class<T> targetType();

  int fromVersion();

  int toVersion();

  T upgrade(T oldValue);
}
