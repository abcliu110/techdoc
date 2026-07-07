package com.lowcode.metamodel.dao.mapper;

import static org.assertj.core.api.Assertions.assertThat;

import com.lowcode.metamodel.dao.entity.AppEntity;
import com.lowcode.metamodel.dao.entity.DdlLogEntity;
import com.lowcode.metamodel.dao.entity.MetaDatasourceEntity;
import com.lowcode.metamodel.dao.entity.MetaObjectEntity;
import com.lowcode.metamodel.dao.entity.MetaPageEntity;
import com.lowcode.metamodel.dao.entity.MetaPluginEntity;
import com.lowcode.metamodel.dao.entity.MetaPublishTaskEntity;
import com.lowcode.metamodel.dao.entity.MetaRefEntity;
import com.lowcode.metamodel.dao.entity.MetaRoleEntity;
import com.lowcode.metamodel.dao.entity.MetaVersionEntity;
import com.lowcode.metamodel.dao.entity.PhysicalSchemaEntity;
import com.lowcode.metamodel.dao.entity.TenantEntity;
import com.lowcode.metamodel.dao.entity.WorkspaceEntity;
import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.util.Optional;
import java.util.Set;
import org.junit.jupiter.api.Test;

class MetaMapperContractTest {

  @Test
  void mappers_shouldCoverEveryStaticTableEntity() {
    assertThat(mapperTypes())
        .containsExactlyInAnyOrder(
            TenantMapper.class,
            WorkspaceMapper.class,
            AppMapper.class,
            MetaObjectMapper.class,
            MetaPageMapper.class,
            MetaRoleMapper.class,
            MetaDatasourceMapper.class,
            MetaVersionMapper.class,
            MetaPluginMapper.class,
            MetaRefMapper.class,
            PhysicalSchemaMapper.class,
            DdlLogMapper.class,
            MetaPublishTaskMapper.class);
  }

  @Test
  void mappers_shouldOnlyExposeSingleTableCrudContract() throws NoSuchMethodException {
    assertThat(MetaCrudMapper.class.getMethod("insert", Object.class).getReturnType())
        .isEqualTo(int.class);
    assertThat(MetaCrudMapper.class.getMethod("updateByIdAndRevision", Object.class).getReturnType())
        .isEqualTo(int.class);
    assertThat(MetaCrudMapper.class.getMethod("findById", Long.class, Long.class).getReturnType())
        .isEqualTo(Optional.class);
    assertThat(
            MetaCrudMapper.class
                .getMethod("softDeleteByIdAndRevision", Long.class, Long.class, Long.class, Long.class)
                .getReturnType())
        .isEqualTo(int.class);

    for (Class<?> mapper : mapperTypes()) {
      assertThat(mapper.getInterfaces()).contains(MetaCrudMapper.class);
      assertThat(entityType(mapper)).as(mapper.getSimpleName() + " entity binding").isNotNull();
    }
  }

  @Test
  void genericEntityType_shouldMatchMapperName() {
    assertEntityType(TenantMapper.class, TenantEntity.class);
    assertEntityType(WorkspaceMapper.class, WorkspaceEntity.class);
    assertEntityType(AppMapper.class, AppEntity.class);
    assertEntityType(MetaObjectMapper.class, MetaObjectEntity.class);
    assertEntityType(MetaPageMapper.class, MetaPageEntity.class);
    assertEntityType(MetaRoleMapper.class, MetaRoleEntity.class);
    assertEntityType(MetaDatasourceMapper.class, MetaDatasourceEntity.class);
    assertEntityType(MetaVersionMapper.class, MetaVersionEntity.class);
    assertEntityType(MetaPluginMapper.class, MetaPluginEntity.class);
    assertEntityType(MetaRefMapper.class, MetaRefEntity.class);
    assertEntityType(PhysicalSchemaMapper.class, PhysicalSchemaEntity.class);
    assertEntityType(DdlLogMapper.class, DdlLogEntity.class);
    assertEntityType(MetaPublishTaskMapper.class, MetaPublishTaskEntity.class);
  }

  private static Set<Class<?>> mapperTypes() {
    return Set.of(
        TenantMapper.class,
        WorkspaceMapper.class,
        AppMapper.class,
        MetaObjectMapper.class,
        MetaPageMapper.class,
        MetaRoleMapper.class,
        MetaDatasourceMapper.class,
        MetaVersionMapper.class,
        MetaPluginMapper.class,
        MetaRefMapper.class,
        PhysicalSchemaMapper.class,
        DdlLogMapper.class,
        MetaPublishTaskMapper.class);
  }

  private static void assertEntityType(Class<?> mapper, Class<?> expectedEntityType) {
    assertThat(entityType(mapper)).as(mapper.getSimpleName()).isEqualTo(expectedEntityType);
  }

  private static Class<?> entityType(Class<?> mapper) {
    for (var type : mapper.getGenericInterfaces()) {
      if (type instanceof ParameterizedType parameterizedType
          && parameterizedType.getRawType().equals(MetaCrudMapper.class)) {
        return (Class<?>) parameterizedType.getActualTypeArguments()[0];
      }
    }
    throw new AssertionError("Missing MetaCrudMapper generic type: " + mapper.getName());
  }
}
