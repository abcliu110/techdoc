package com.lowcode.metamodel.domain.upgrade;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.metamodel.domain.def.VersionedJson;
import java.util.List;
import org.junit.jupiter.api.Test;

class JsonUpgraderRegistryStrictModeTest {

  @Test
  void validateChain_shouldPassWhenEveryVersionStepExists() {
    JsonUpgraderRegistry registry =
        new JsonUpgraderRegistry(List.of(new SampleUpgrader(1, 2), new SampleUpgrader(2, 3)));

    registry.validateChain(SampleDef.class, 1, 3);

    assertThat(registry.upgrade(new SampleDef(1), 3).schemaVersion()).isEqualTo(3);
  }

  @Test
  void validateChain_shouldFailWhenStepIsMissing() {
    JsonUpgraderRegistry registry = new JsonUpgraderRegistry(List.of(new SampleUpgrader(1, 2)));

    assertThatThrownBy(() -> registry.validateChain(SampleDef.class, 1, 3))
        .isInstanceOf(JsonUpgradeException.class)
        .hasMessageContaining("missing upgrader");
  }

  @Test
  void upgrade_shouldRejectFutureVersion() {
    JsonUpgraderRegistry registry = new JsonUpgraderRegistry(List.of(new SampleUpgrader(1, 2)));

    assertThatThrownBy(() -> registry.upgrade(new SampleDef(5), 2))
        .isInstanceOf(JsonUpgradeException.class)
        .hasMessageContaining("future version");
  }

  record SampleDef(int schemaVersion) implements VersionedJson {}

  record SampleUpgrader(int fromVersion, int toVersion)
      implements JsonUpgrader<SampleDef> {

    @Override
    public Class<SampleDef> targetType() {
      return SampleDef.class;
    }

    @Override
    public SampleDef upgrade(SampleDef oldValue) {
      return new SampleDef(toVersion);
    }
  }
}
