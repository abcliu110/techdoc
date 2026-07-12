package com.lowcode.metamodel.domain.graph;

/**
 * MetaGraph 加载失败。
 *
 * <p>M0 用运行时异常表达加载阻断，后续接入统一错误模型时保持错误语义不变。
 */
public class MetaGraphLoadException extends RuntimeException {

  public MetaGraphLoadException(String message) {
    super(message);
  }

  public MetaGraphLoadException(String message, Throwable cause) {
    super(message, cause);
  }
}
