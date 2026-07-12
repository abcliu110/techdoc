package com.lowcode.metamodel.domain.upgrade;

/**
 * 带版本元数据 JSON 无法安全升级时抛出的异常。
 *
 * <p>严格失败是有意设计：如果静默加载未知快照结构，发布后的运行时行为可能被破坏。
 */
public class JsonUpgradeException extends RuntimeException {

  public JsonUpgradeException(String message) {
    super(message);
  }
}
