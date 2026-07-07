package com.lowcode.runtime.data;

/**
 * 动态记录软删除结果。
 */
public record DeleteRecordResult(String recordLid, boolean deleted) {}
