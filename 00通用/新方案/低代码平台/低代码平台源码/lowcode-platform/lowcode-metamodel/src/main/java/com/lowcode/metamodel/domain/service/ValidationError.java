package com.lowcode.metamodel.domain.service;

/**
 * 元模型结构校验错误。
 *
 * <p>`path` 必须能定位到对象或字段，避免调用方只能看到笼统失败原因。
 */
public record ValidationError(String path, String code, String message) {}
