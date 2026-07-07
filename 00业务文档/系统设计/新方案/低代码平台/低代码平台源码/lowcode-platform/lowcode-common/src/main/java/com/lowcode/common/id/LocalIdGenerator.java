package com.lowcode.common.id;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicLong;

/**
 * 本地开发用 ID 生成器。
 *
 * <p>ULID 不是业务排序契约。业务排序必须使用 create_time 或领域时间字段。本实现足够支撑本地 M0 测试；
 * 生产环境 workerId 分配和时钟回拨处理必须在商业部署前单独补齐。
 */
public class LocalIdGenerator implements IdGenerator {

  private static final char[] CROCKFORD =
      "0123456789ABCDEFGHJKMNPQRSTVWXYZ".toCharArray();
  private static final SecureRandom RANDOM = new SecureRandom();

  private final long workerId;
  private final AtomicLong sequence = new AtomicLong();

  public LocalIdGenerator(long workerId) {
    if (workerId < 0 || workerId > 1023) {
      throw new IllegalArgumentException("workerId must be between 0 and 1023");
    }
    this.workerId = workerId;
  }

  @Override
  public long nextSnowflakeId() {
    // M0 采用常规位布局：41 位时间戳、10 位 worker、12 位序列。
    long timestamp = Instant.now().toEpochMilli() & ((1L << 41) - 1);
    long seq = sequence.getAndIncrement() & 0xFFFL;
    return (timestamp << 22) | (workerId << 12) | seq;
  }

  @Override
  public String nextUlid() {
    // 后续动态记录需要 ULID 形态，但 M0 不把它作为排序保证。
    byte[] bytes = new byte[16];
    long timestamp = Instant.now().toEpochMilli();
    bytes[0] = (byte) (timestamp >>> 40);
    bytes[1] = (byte) (timestamp >>> 32);
    bytes[2] = (byte) (timestamp >>> 24);
    bytes[3] = (byte) (timestamp >>> 16);
    bytes[4] = (byte) (timestamp >>> 8);
    bytes[5] = (byte) timestamp;
    byte[] random = new byte[10];
    RANDOM.nextBytes(random);
    System.arraycopy(random, 0, bytes, 6, random.length);
    return encodeBase32(bytes).toUpperCase(Locale.ROOT);
  }

  private static String encodeBase32(byte[] bytes) {
    StringBuilder output = new StringBuilder(26);
    int buffer = 0;
    int bitsLeft = 0;
    for (byte value : bytes) {
      buffer = (buffer << 8) | (value & 0xFF);
      bitsLeft += 8;
      while (bitsLeft >= 5) {
        output.append(CROCKFORD[(buffer >> (bitsLeft - 5)) & 31]);
        bitsLeft -= 5;
      }
    }
    if (bitsLeft > 0) {
      output.append(CROCKFORD[(buffer << (5 - bitsLeft)) & 31]);
    }
    while (output.length() < 26) {
      output.append('0');
    }
    return output.substring(0, 26);
  }
}
