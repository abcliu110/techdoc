package com.lowcode.metamodel.domain.graph;

/**
 * MetaGraph 版本源降级后的写入保护异常。
 */
public class MetaGraphReadOnlyException extends RuntimeException {

  public MetaGraphReadOnlyException(String message) {
    super(message);
  }
}
