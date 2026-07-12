package com.lowcode.metamodel.domain.graph;

/**
 * 指定应用版本快照不存在。
 */
public class MetaGraphNotFoundException extends RuntimeException {

  public MetaGraphNotFoundException(String message) {
    super(message);
  }
}
