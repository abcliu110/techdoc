package com.lowcode.metamodel.domain.schema;

/**
 * DDL 执行日志视图。
 *
 * <p>M0 内存执行器使用这个结构模拟 `lc_rt_ddl_log` 的关键字段，真实落库由后续发布服务接入。
 */
public record DdlExecutionLog(int stepNo, DdlType ddlType, String status, String errorCode, String errorMessage) {}
