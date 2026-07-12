package com.lowcode.common.id;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.HashSet;
import java.util.Set;
import org.junit.jupiter.api.Test;

class LocalIdGeneratorTest {

  @Test
  void nextSnowflakeId_shouldReturnPositiveUniqueLongs() {
    LocalIdGenerator generator = new LocalIdGenerator(1L);

    long first = generator.nextSnowflakeId();
    long second = generator.nextSnowflakeId();

    assertThat(first).isPositive();
    assertThat(second).isPositive().isNotEqualTo(first);
  }

  @Test
  void nextUlid_shouldReturnTwentySixCharacterIdentifiers() {
    LocalIdGenerator generator = new LocalIdGenerator(1L);
    Set<String> ids = new HashSet<>();

    for (int i = 0; i < 100; i++) {
      ids.add(generator.nextUlid());
    }

    assertThat(ids).hasSize(100);
    assertThat(ids).allSatisfy(id -> assertThat(id).hasSize(26));
  }
}
