package com.lowcode.metamodel.domain.graph;

/**
 * Explicit demo/test-only factories for published meta version storage.
 */
public final class MetaVersionStorageFactory {

  private MetaVersionStorageFactory() {}

  public static MetaVersionRepository inMemoryRepository() {
    return new InMemoryMetaVersionRepository();
  }

  public static MetaVersionPointer inMemoryPointer() {
    return new InMemoryMetaVersionPointer();
  }
}
