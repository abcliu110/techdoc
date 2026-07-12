package com.lowcode.designer.service;

/**
 * 设计态字段草稿定义。
 *
 * <p>当前只保留最小快照所需信息：字段编码、名称、类型和是否必填。
 */
public record FieldDraft(String code, String name, String type, boolean required) {}
