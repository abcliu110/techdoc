package com.lowcode.metamodel.domain.graph;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lowcode.metamodel.domain.def.AppSnapshotDef;
import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import com.lowcode.metamodel.domain.enums.RelationTypeEnum;
import com.lowcode.metamodel.domain.service.MetaObjectDraft;
import com.lowcode.metamodel.domain.service.MetaRelationDef;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * MetaGraph 构建器。
 *
 * <p>M0 只消费当前版本快照 DTO；未来版本必须先走 JsonUpgrader，不能在这里猜测兼容。
 */
public class MetaGraphBuilder {

  private final ObjectMapper objectMapper = new ObjectMapper();

  public MetaGraph build(AppSnapshotDef snapshot) {
    if (snapshot.schemaVersion() > 1) {
      throw new MetaGraphLoadException("快照版本不兼容：" + snapshot.schemaVersion());
    }
    Map<String, ObjectNode> objects = new LinkedHashMap<>();
    Map<String, List<RefEdge>> refsBySource = new LinkedHashMap<>();
    Map<String, List<RefEdge>> refsByTarget = new LinkedHashMap<>();
    for (Object object : snapshot.objects()) {
      MetaObjectDraft draft = toDraft(object);
      ObjectNode objectNode = objectNode(snapshot.appCode(), draft);
      objects.put(draft.code(), objectNode);
      for (MetaRelationDef relation : draft.relations()) {
        addRef(refsBySource, refsByTarget, new RefEdge(draft.code(), relation.sourceFieldCode(), "RELATION_OBJECT", "OBJECT", relation.targetObjectCode()));
      }
      for (FieldDef field : draft.fields()) {
        if (field.options() != null && !isBlank(field.options().targetObjectCode())) {
          addRef(refsBySource, refsByTarget, new RefEdge(draft.code(), field.code(), "FIELD_LINK_OBJECT", "OBJECT", field.options().targetObjectCode()));
        }
      }
    }
    return new MetaGraph(snapshot.tenantId(), snapshot.appCode(), snapshot.versionNo(), objects, refsBySource, refsByTarget);
  }

  private MetaObjectDraft toDraft(Object object) {
    if (object instanceof MetaObjectDraft draft) {
      return draft;
    }
    try {
      return objectMapper.convertValue(object, MetaObjectDraft.class);
    } catch (IllegalArgumentException ex) {
      throw new MetaGraphLoadException("快照对象结构不兼容：" + object.getClass().getName(), ex);
    }
  }

  private ObjectNode objectNode(String appCode, MetaObjectDraft draft) {
    Map<String, FieldNode> fields = new LinkedHashMap<>();
    for (FieldDef field : draft.fields()) {
      fields.put(field.code(), new FieldNode(field.code(), field.name(), field.fieldType(), columnName(field), field.required(), field.options()));
    }
    Map<String, RelationNode> relations = new LinkedHashMap<>();
    for (MetaRelationDef relation : draft.relations()) {
      relations.put(
          relation.sourceFieldCode(),
          new RelationNode(relation.sourceObjectCode(), relation.sourceFieldCode(), relation.targetObjectCode(), relation.relationType()));
    }
    for (FieldDef field : draft.fields()) {
      if (field.fieldType() == FieldTypeEnum.LINK && field.options() != null && !isBlank(field.options().targetObjectCode())) {
        relations.putIfAbsent(
            field.code(),
            new RelationNode(draft.code(), field.code(), field.options().targetObjectCode(), RelationTypeEnum.MANY_TO_ONE));
      }
    }
    return new ObjectNode(draft.code(), draft.name(), tableName(appCode, draft.code()), fields, relations);
  }

  private static String columnName(FieldDef field) {
    return field.fieldType() == FieldTypeEnum.LINK ? field.code() + "_lid" : field.code();
  }

  private static String tableName(String appCode, String objectCode) {
    return "lc_" + appCode + "_" + objectCode;
  }

  private static void addRef(Map<String, List<RefEdge>> bySource, Map<String, List<RefEdge>> byTarget, RefEdge edge) {
    bySource.computeIfAbsent(edge.sourceCode(), ignored -> new ArrayList<>()).add(edge);
    byTarget.computeIfAbsent(edge.targetCode(), ignored -> new ArrayList<>()).add(edge);
  }

  private static boolean isBlank(String value) {
    return value == null || value.isBlank();
  }
}
