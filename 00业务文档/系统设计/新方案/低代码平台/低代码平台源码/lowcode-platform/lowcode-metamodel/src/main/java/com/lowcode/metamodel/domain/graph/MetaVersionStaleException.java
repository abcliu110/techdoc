package com.lowcode.metamodel.domain.graph;

/**
 * 请求携带的 metaHash 与当前请求上下文不一致。
 */
public class MetaVersionStaleException extends RuntimeException {

  public MetaVersionStaleException(String message) {
    super(message);
  }
}
