package com.lowcode.app.api;

import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import com.lowcode.metamodel.domain.graph.FieldNode;
import com.lowcode.metamodel.domain.graph.MetaGraph;
import com.lowcode.metamodel.domain.graph.MetaGraphProvider;
import com.lowcode.metamodel.domain.graph.ObjectNode;
import com.lowcode.runtime.api.RuntimeApiFacade;
import com.lowcode.runtime.data.DynamicObjectDefinition;
import com.lowcode.runtime.data.FieldKind;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Comparator;
import org.springframework.stereotype.Component;

/**
 * Registers runtime object definitions from published metamodel snapshots.
 */
@Component
class PublishedRuntimeObjectRegistry {

  private final RuntimeApiFacade runtimeApiFacade;
  private final MetaGraphProvider metaGraphProvider;
  private final Map<String, Boolean> registered = new ConcurrentHashMap<>();

  PublishedRuntimeObjectRegistry(RuntimeApiFacade runtimeApiFacade, MetaGraphProvider metaGraphProvider) {
    this.runtimeApiFacade = runtimeApiFacade;
    this.metaGraphProvider = metaGraphProvider;
  }

  void ensureRegistered(AuthenticatedRuntimeContext context) {
    String key = context.tenantId() + ":" + context.appCode() + ":" + context.objectCode() + ":" + context.metaHash();
    registered.computeIfAbsent(key, ignored -> {
      MetaGraph graph = metaGraphProvider.requirePublished(context.tenantId(), context.appCode(), context.metaHash());
      ObjectNode object = graph.object(context.objectCode());
      runtimeApiFacade.registerObject(context.appCode(), toRuntimeDefinition(object));
      return true;
    });
  }

  private DynamicObjectDefinition toRuntimeDefinition(ObjectNode object) {
    DynamicObjectDefinition.Builder builder = DynamicObjectDefinition.builder(object.code(), object.tableName());
    for (FieldNode field : object.fieldsByCode().values().stream().sorted(Comparator.comparing(FieldNode::code)).toList()) {
      FieldKind kind = fieldKind(field.fieldType());
      if (kind != null) {
        builder.field(field.code(), kind);
      }
    }
    return builder.build();
  }

  private FieldKind fieldKind(FieldTypeEnum fieldType) {
    return switch (fieldType) {
      case TEXT, TEXTAREA, RICHTEXT, CODE, SELECT -> FieldKind.TEXT;
      case INTEGER -> FieldKind.INTEGER;
      case DECIMAL, PERCENT -> FieldKind.DECIMAL;
      case CURRENCY -> FieldKind.CURRENCY;
      case CHECKBOX -> FieldKind.BOOLEAN;
      case MULTISELECT, ATTACHMENT -> FieldKind.JSON;
      case LINK, USER, ORG -> FieldKind.REFERENCE;
      case DATE, DATETIME, TIME -> FieldKind.TEMPORAL;
      case AUTONUMBER -> FieldKind.AUTONUMBER;
      case TABLE, MULTILINK, FORMULA -> null;
    };
  }
}
