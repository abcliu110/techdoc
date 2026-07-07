package com.lowcode.metamodel.domain.enums;

/**
 * 数据库和 API 稳定枚举 code 的公共契约。
 *
 * <p>枚举禁止持久化 Java ordinal。ordinal 只是位置实现细节，一旦枚举常量重排或插入，就会变成数据损坏。
 */
public interface CodeEnum {

  String code();
}
