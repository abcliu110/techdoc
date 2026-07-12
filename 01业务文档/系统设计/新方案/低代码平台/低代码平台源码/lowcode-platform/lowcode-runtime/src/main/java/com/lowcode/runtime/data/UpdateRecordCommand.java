package com.lowcode.runtime.data;

import java.util.Map;

/**
 * 动态更新命令。
 */
public record UpdateRecordCommand(
    String recordLid,
    Long revision,
    Map<String, Object> values,
    String requestMetaHash,
    String idempotencyKey) {

  public UpdateRecordCommand(String recordLid, Long revision, Map<String, Object> values, String requestMetaHash) {
    this(recordLid, revision, values, requestMetaHash, null);
  }
}
