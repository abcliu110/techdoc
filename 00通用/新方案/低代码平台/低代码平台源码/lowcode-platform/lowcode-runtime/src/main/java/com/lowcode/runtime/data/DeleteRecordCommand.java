package com.lowcode.runtime.data;

/**
 * 动态记录软删除命令。
 */
public record DeleteRecordCommand(String recordLid, Long revision, String requestMetaHash) {}
