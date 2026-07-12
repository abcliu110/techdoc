package com.lowcode.metamodel.dao.entity;

import static org.assertj.core.api.Assertions.assertThat;

import java.lang.reflect.Field;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;

class MetaEntityContractTest {

  private static final String ENTITY_PACKAGE = "com.lowcode.metamodel.dao.entity.";

  @Test
  void entities_shouldCoverOnlyT002StaticMetadataTables() {
    assertThat(loadEntities())
        .containsExactlyInAnyOrder(
            TenantEntity.class,
            WorkspaceEntity.class,
            AppEntity.class,
            MetaObjectEntity.class,
            MetaPageEntity.class,
            MetaRoleEntity.class,
            MetaDatasourceEntity.class,
            MetaVersionEntity.class,
            MetaPluginEntity.class,
            MetaRefEntity.class,
            PhysicalSchemaEntity.class,
            DdlLogEntity.class,
            MetaPublishTaskEntity.class);
  }

  @Test
  void baseEntity_shouldCarryStandardColumnsUsedByEveryMetaTable() throws NoSuchFieldException {
    assertField(BaseMetaEntity.class, "id", Long.class);
    assertField(BaseMetaEntity.class, "tenantId", Long.class);
    assertField(BaseMetaEntity.class, "revision", Long.class);
    assertField(BaseMetaEntity.class, "deleted", Boolean.class);
    assertField(BaseMetaEntity.class, "deletedAt", LocalDateTime.class);
    assertField(BaseMetaEntity.class, "deleteToken", Long.class);
    assertField(BaseMetaEntity.class, "createTime", LocalDateTime.class);
    assertField(BaseMetaEntity.class, "createBy", Long.class);
    assertField(BaseMetaEntity.class, "updateTime", LocalDateTime.class);
    assertField(BaseMetaEntity.class, "updateBy", Long.class);
  }

  @Test
  void jsonAggregateColumns_shouldRemainStringUntilServiceLayerCodecExists() throws Exception {
    Map<Class<?>, Set<String>> jsonFields =
        Map.ofEntries(
            Map.entry(TenantEntity.class, Set.of("config")),
            Map.entry(WorkspaceEntity.class, Set.of("config")),
            Map.entry(AppEntity.class, Set.of("config")),
            Map.entry(
                MetaObjectEntity.class,
                Set.of("fields", "relations", "states", "actions", "rules", "options")),
            Map.entry(MetaPageEntity.class, Set.of("views")),
            Map.entry(MetaRoleEntity.class, Set.of("permissions")),
            Map.entry(MetaDatasourceEntity.class, Set.of("config")),
            Map.entry(MetaVersionEntity.class, Set.of("snapshot")),
            Map.entry(MetaPluginEntity.class, Set.of("config")),
            Map.entry(MetaRefEntity.class, Set.of("detail")),
            Map.entry(PhysicalSchemaEntity.class, Set.of("schemaJson")),
            Map.entry(MetaPublishTaskEntity.class, Set.of("planJson", "errorDetail")));

    for (Map.Entry<Class<?>, Set<String>> entry : jsonFields.entrySet()) {
      for (String fieldName : entry.getValue()) {
        assertField(entry.getKey(), fieldName, String.class);
      }
    }
  }

  @Test
  void appOwnedEntities_shouldExposeAppIdForTenantScopedQueries() throws Exception {
    for (Class<?> entity :
        Set.of(
            MetaObjectEntity.class,
            MetaPageEntity.class,
            MetaRoleEntity.class,
            MetaDatasourceEntity.class,
            MetaVersionEntity.class,
            MetaPluginEntity.class,
            MetaRefEntity.class,
            PhysicalSchemaEntity.class,
            DdlLogEntity.class,
            MetaPublishTaskEntity.class)) {
      assertField(entity, "appId", Long.class);
    }
  }

  private static Set<Class<?>> loadEntities() {
    return Set.of(
        load("TenantEntity"),
        load("WorkspaceEntity"),
        load("AppEntity"),
        load("MetaObjectEntity"),
        load("MetaPageEntity"),
        load("MetaRoleEntity"),
        load("MetaDatasourceEntity"),
        load("MetaVersionEntity"),
        load("MetaPluginEntity"),
        load("MetaRefEntity"),
        load("PhysicalSchemaEntity"),
        load("DdlLogEntity"),
        load("MetaPublishTaskEntity"));
  }

  private static Class<?> load(String simpleName) {
    try {
      return Class.forName(ENTITY_PACKAGE + simpleName);
    } catch (ClassNotFoundException ex) {
      throw new AssertionError("Missing T-002 entity: " + simpleName, ex);
    }
  }

  private static void assertField(Class<?> type, String fieldName, Class<?> fieldType)
      throws NoSuchFieldException {
    Field field = type.getDeclaredField(fieldName);
    assertThat(field.getType()).as(type.getSimpleName() + "." + fieldName).isEqualTo(fieldType);
  }
}
