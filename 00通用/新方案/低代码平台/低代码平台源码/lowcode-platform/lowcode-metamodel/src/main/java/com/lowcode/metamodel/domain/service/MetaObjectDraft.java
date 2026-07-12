package com.lowcode.metamodel.domain.service;

import com.lowcode.metamodel.domain.def.CommercialMetadataDef;
import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.enums.ObjectTypeEnum;
import java.util.List;

/**
 * 设计态元对象草稿。
 *
 * <p>它是 T-003 的领域模型，不是数据库 Entity，也不是运行态业务数据。M0 先用它承载对象、字段和自动关系，
 * 后续真实持久化时再由 Mapper/事务层接入。
 */
public record MetaObjectDraft(
    Long tenantId,
    Long appId,
    String code,
    String name,
    ObjectTypeEnum objectType,
    List<FieldDef> fields,
    List<MetaRelationDef> relations,
    List<MetaStateDef> states,
    CommercialMetadataDef commercialMetadata,
    long revision,
    Long expectedRevision) {

  public MetaObjectDraft {
    fields = fields == null ? List.of() : List.copyOf(fields);
    relations = relations == null ? List.of() : List.copyOf(relations);
    states = states == null ? List.of() : List.copyOf(states);
    commercialMetadata = commercialMetadata == null ? CommercialMetadataDef.empty(1) : commercialMetadata;
  }

  public MetaObjectDraft(
      Long tenantId,
      Long appId,
      String code,
      String name,
      ObjectTypeEnum objectType,
      List<FieldDef> fields) {
    this(tenantId, appId, code, name, objectType, fields, List.of(), List.of(), CommercialMetadataDef.empty(1), 0L, null);
  }

  public MetaObjectDraft withRelationsAndRevision(List<MetaRelationDef> newRelations, long newRevision) {
    return new MetaObjectDraft(tenantId, appId, code, name, objectType, fields, newRelations, states, commercialMetadata, newRevision, null);
  }

  public MetaObjectDraft withExpectedRevision(long newExpectedRevision) {
    return new MetaObjectDraft(tenantId, appId, code, name, objectType, fields, relations, states, commercialMetadata, revision, newExpectedRevision);
  }

  public MetaObjectDraft withFields(List<FieldDef> newFields) {
    return new MetaObjectDraft(tenantId, appId, code, name, objectType, newFields, relations, states, commercialMetadata, revision, expectedRevision);
  }

  public MetaObjectDraft withStates(List<MetaStateDef> newStates) {
    return new MetaObjectDraft(tenantId, appId, code, name, objectType, fields, relations, newStates, commercialMetadata, revision, expectedRevision);
  }

  public MetaObjectDraft withCommercialMetadata(CommercialMetadataDef newCommercialMetadata) {
    return new MetaObjectDraft(tenantId, appId, code, name, objectType, fields, relations, states, newCommercialMetadata, revision, expectedRevision);
  }
}
