package com.lowcode.common.id;

/** 内部雪花 ID 与外部 ULID 字符串的生成边界。 */
public interface IdGenerator {

  long nextSnowflakeId();

  String nextUlid();
}
