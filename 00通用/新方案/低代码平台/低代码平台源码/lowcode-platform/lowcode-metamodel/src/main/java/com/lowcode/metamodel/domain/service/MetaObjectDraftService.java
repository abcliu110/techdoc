package com.lowcode.metamodel.domain.service;

import com.lowcode.common.error.BizException;
import com.lowcode.common.error.ErrorCode;
import com.lowcode.metamodel.domain.def.CodeRuleDef;
import com.lowcode.metamodel.domain.def.CommercialMetadataDef;
import com.lowcode.metamodel.domain.def.ConversionDef;
import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.def.FlexFieldDef;
import com.lowcode.metamodel.domain.def.I18nResourceDef;
import com.lowcode.metamodel.domain.def.LicensePolicyDef;
import com.lowcode.metamodel.domain.def.LinkConfigDef;
import com.lowcode.metamodel.domain.def.LinkTraceDef;
import com.lowcode.metamodel.domain.def.MenuDef;
import com.lowcode.metamodel.domain.def.ObjectExtensionDef;
import com.lowcode.metamodel.domain.def.OrgRelationDef;
import com.lowcode.metamodel.domain.def.PackageManifestDef;
import com.lowcode.metamodel.domain.def.PrintTemplateDef;
import com.lowcode.metamodel.domain.def.ReportDef;
import com.lowcode.metamodel.domain.def.WriteBackDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import com.lowcode.metamodel.domain.enums.RelationTypeEnum;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * M0 设计态元对象服务。
 *
 * <p>当前实现刻意是内存仓储，用于锁定领域规则和测试契约；它不替代后续 Mapper 事务实现，也不暴露运行时 CRUD。
 */
public class MetaObjectDraftService {

  private final Map<String, MetaObjectDraft> drafts = new LinkedHashMap<>();
  private final Map<String, List<MetaRefDef>> refsBySource = new LinkedHashMap<>();

  public MetaObjectDraft saveDraft(MetaObjectDraft draft) {
    ValidationReport report = validateDraft(draft);
    if (!report.passed()) {
      throw new IllegalArgumentException(report.errors().getFirst().message());
    }
    checkRevision(draft);
    MetaObjectDraft saved = draft.withRelationsAndRevision(syncRelations(draft), nextRevision(draft));
    drafts.put(key(draft.tenantId(), draft.appId(), draft.code()), saved);
    refsBySource.put(key(draft.tenantId(), draft.appId(), draft.code()), extractRefs(saved));
    return saved;
  }

  public MetaObjectDraft get(Long tenantId, Long appId, String objectCode) {
    return drafts.get(key(tenantId, appId, objectCode));
  }

  public ValidationReport validateDraft(MetaObjectDraft draft) {
    List<ValidationError> errors = new ArrayList<>();
    validateRequired(draft, errors);
    validateDuplicateFields(draft, errors);
    validateFieldOptions(draft, errors);
    validateFetchFrom(draft, errors);
    validateStateMachine(draft, errors);
    return new ValidationReport(errors);
  }

  public ValidationReport validateApp(Long tenantId, Long appId) {
    List<ValidationError> errors = new ArrayList<>();
    drafts.values().stream()
        .filter(draft -> Objects.equals(draft.tenantId(), tenantId) && Objects.equals(draft.appId(), appId))
        .forEach(draft -> {
          validateClosedReferences(draft, errors);
          validatePublishCapabilities(draft, errors);
          validateCommercialMetadata(draft, errors);
        });
    return new ValidationReport(errors);
  }

  public List<MetaRefDef> refsFrom(Long tenantId, Long appId, String objectCode) {
    return refsBySource.getOrDefault(key(tenantId, appId, objectCode), List.of());
  }

  public List<MetaRefDef> analyzeDeleteObject(Long tenantId, Long appId, String objectCode) {
    return refsBySource.values().stream()
        .flatMap(List::stream)
        .filter(ref -> Objects.equals(ref.tenantId(), tenantId))
        .filter(ref -> Objects.equals(ref.appId(), appId))
        .filter(ref -> "OBJECT".equals(ref.targetType()))
        .filter(ref -> Objects.equals(ref.targetCode(), objectCode))
        .toList();
  }

  private void validateRequired(MetaObjectDraft draft, List<ValidationError> errors) {
    if (draft.tenantId() == null) {
      errors.add(new ValidationError("tenantId", "LC-COMM-0401", "租户不能为空"));
    }
    if (draft.appId() == null) {
      errors.add(new ValidationError("appId", "LC-COMM-0400", "应用不能为空"));
    }
    if (isBlank(draft.code())) {
      errors.add(new ValidationError("code", "LC-META-1002", "对象编码不能为空"));
    }
  }

  private void validateDuplicateFields(MetaObjectDraft draft, List<ValidationError> errors) {
    Map<String, Integer> firstIndex = new LinkedHashMap<>();
    List<FieldDef> fields = draft.fields();
    for (int i = 0; i < fields.size(); i++) {
      String code = fields.get(i).code();
      if (firstIndex.containsKey(code)) {
        errors.add(new ValidationError("fields[" + i + "].code", "LC-META-1001", "字段编码重复：" + code));
      } else {
        firstIndex.put(code, i);
      }
    }
  }

  private void validateFieldOptions(MetaObjectDraft draft, List<ValidationError> errors) {
    List<FieldDef> fields = draft.fields();
    for (int i = 0; i < fields.size(); i++) {
      FieldDef field = fields.get(i);
      FieldOptionsDef options = field.options();
      if ((field.fieldType() == FieldTypeEnum.LINK || field.fieldType() == FieldTypeEnum.TABLE || field.fieldType() == FieldTypeEnum.MULTILINK)
          && (options == null || isBlank(options.targetObjectCode()))) {
        errors.add(new ValidationError("fields[" + i + "].options.targetObjectCode", "LC-META-1101", "引用字段必须指定目标对象"));
      }
      if (field.fieldType() == FieldTypeEnum.MULTILINK && (options == null || isBlank(options.throughObjectCode()))) {
        errors.add(new ValidationError("fields[" + i + "].options.throughObjectCode", "LC-META-1201", "多链接字段必须指定中间对象"));
      }
    }
  }

  private void validateFetchFrom(MetaObjectDraft draft, List<ValidationError> errors) {
    Map<String, FieldDef> fieldsByCode = fieldsByCode(draft);
    List<FieldDef> fields = draft.fields();
    for (int i = 0; i < fields.size(); i++) {
      FieldOptionsDef options = fields.get(i).options();
      if (options == null || isBlank(options.fetchFrom())) {
        continue;
      }
      String[] parts = options.fetchFrom().split("\\.");
      if (parts.length != 2) {
        errors.add(new ValidationError("fields[" + i + "].options.fetchFrom", "LC-META-1101", "fetch_from 必须使用 link字段.目标字段"));
        continue;
      }
      FieldDef linkField = fieldsByCode.get(parts[0]);
      if (linkField == null || linkField.fieldType() != FieldTypeEnum.LINK) {
        errors.add(new ValidationError("fields[" + i + "].options.fetchFrom", "LC-META-1101", "fetch_from 必须从 link 字段带出"));
        continue;
      }
      // fetch_from 的语义依赖目标对象字段，草稿阶段只要声明了 fetch_from 就必须能闭合到目标字段。
      FieldOptionsDef linkOptions = linkField.options();
      MetaObjectDraft target = linkOptions == null ? null : drafts.get(key(draft.tenantId(), draft.appId(), linkOptions.targetObjectCode()));
      if (target == null || !fieldsByCode(target).containsKey(parts[1])) {
        errors.add(new ValidationError("fields[" + i + "].options.fetchFrom", "LC-META-1101", "fetch_from 目标字段不存在"));
      }
    }
  }

  private void validateStateMachine(MetaObjectDraft draft, List<ValidationError> errors) {
    List<MetaStateDef> states = draft.states();
    if (states.isEmpty()) {
      return;
    }
    long initialCount = states.stream().filter(MetaStateDef::initial).count();
    if (initialCount != 1) {
      errors.add(new ValidationError("states", "LC-META-1301", "状态机必须且只能有一个初始状态"));
    }
    Set<String> stateCodes = new HashSet<>();
    for (MetaStateDef state : states) {
      stateCodes.add(state.code());
    }
    for (int i = 0; i < states.size(); i++) {
      MetaStateDef state = states.get(i);
      for (int j = 0; j < state.transitions().size(); j++) {
        MetaTransitionDef transition = state.transitions().get(j);
        if (!stateCodes.contains(transition.fromState())) {
          errors.add(new ValidationError("states[" + i + "].transitions[" + j + "].fromState", "LC-META-1301", "状态流转来源状态不存在"));
        }
        if (!stateCodes.contains(transition.toState())) {
          errors.add(new ValidationError("states[" + i + "].transitions[" + j + "].toState", "LC-META-1301", "状态流转目标状态不存在"));
        }
      }
    }
  }

  private void validateClosedReferences(MetaObjectDraft draft, List<ValidationError> errors) {
    List<FieldDef> fields = draft.fields();
    for (int i = 0; i < fields.size(); i++) {
      FieldDef field = fields.get(i);
      FieldOptionsDef options = field.options();
      if (options == null || isBlank(options.targetObjectCode())) {
        continue;
      }
      if (!objectExists(draft.tenantId(), draft.appId(), options.targetObjectCode())) {
        errors.add(
            new ValidationError(
                "objects[" + draft.code() + "].fields[" + i + "].options.targetObjectCode",
                "LC-META-1101",
                "目标对象不存在：" + options.targetObjectCode()));
      }
    }
  }

  private void validatePublishCapabilities(MetaObjectDraft draft, List<ValidationError> errors) {
    List<FieldDef> fields = draft.fields();
    for (int i = 0; i < fields.size(); i++) {
      FieldDef field = fields.get(i);
      if (field.fieldType() == FieldTypeEnum.MULTILINK) {
        errors.add(
            new ValidationError(
                "objects[" + draft.code() + "].fields[" + i + "].fieldType",
                "LC-META-3001",
                "M0 不执行 multilink through 表发布"));
      }
    }
  }

  private void validateCommercialMetadata(MetaObjectDraft draft, List<ValidationError> errors) {
    CommercialMetadataDef metadata = draft.commercialMetadata();
    for (ObjectExtensionDef item : metadata.objectExtensions()) {
      if (!isBlank(item.baseObjectCode()) && !objectExists(draft.tenantId(), draft.appId(), item.baseObjectCode())) {
        errors.add(new ValidationError("objects[" + draft.code() + "].commercial.objectExtensions[" + item.extensionCode() + "].baseObjectCode", "LC-META-1101", "扩展基准对象不存在"));
      }
    }
  }

  private List<MetaRelationDef> syncRelations(MetaObjectDraft draft) {
    List<MetaRelationDef> relations = new ArrayList<>();
    for (FieldDef field : draft.fields()) {
      FieldOptionsDef options = field.options();
      if (field.fieldType() == FieldTypeEnum.LINK) {
        relations.add(new MetaRelationDef(draft.code(), field.code(), options.targetObjectCode(), RelationTypeEnum.MANY_TO_ONE));
      } else if (field.fieldType() == FieldTypeEnum.TABLE) {
        relations.add(new MetaRelationDef(draft.code(), field.code(), options.targetObjectCode(), RelationTypeEnum.ONE_TO_MANY));
      } else if (field.fieldType() == FieldTypeEnum.MULTILINK) {
        relations.add(new MetaRelationDef(draft.code(), field.code(), options.targetObjectCode(), RelationTypeEnum.MANY_TO_MANY));
      }
    }
    return relations;
  }

  private void checkRevision(MetaObjectDraft draft) {
    if (draft.expectedRevision() == null) {
      return;
    }
    MetaObjectDraft current = drafts.get(key(draft.tenantId(), draft.appId(), draft.code()));
    long currentRevision = current == null ? 0L : current.revision();
    if (currentRevision != draft.expectedRevision()) {
      throw new BizException(ErrorCode.META_CONFLICT, "元数据版本冲突");
    }
  }

  private List<MetaRefDef> extractRefs(MetaObjectDraft draft) {
    List<MetaRefDef> refs = new ArrayList<>();
    List<FieldDef> fields = draft.fields();
    for (int i = 0; i < fields.size(); i++) {
      FieldDef field = fields.get(i);
      FieldOptionsDef options = field.options();
      if ((field.fieldType() == FieldTypeEnum.LINK || field.fieldType() == FieldTypeEnum.TABLE || field.fieldType() == FieldTypeEnum.MULTILINK)
          && options != null
          && !isBlank(options.targetObjectCode())) {
        refs.add(
            new MetaRefDef(
                draft.tenantId(),
                draft.appId(),
                "OBJECT",
                draft.code(),
                "fields[" + i + "].options.targetObjectCode",
                "FIELD_LINK_OBJECT",
                "OBJECT",
                options.targetObjectCode()));
      }
    }
    extractCommercialRefs(draft, refs);
    return refs;
  }

  private void extractCommercialRefs(MetaObjectDraft draft, List<MetaRefDef> refs) {
    CommercialMetadataDef metadata = draft.commercialMetadata();
    for (ObjectExtensionDef item : metadata.objectExtensions()) {
      addObjectRef(draft, refs, "commercial.objectExtensions[" + item.extensionCode() + "].baseObjectCode", "OBJECT_EXTENSION_BASE", item.baseObjectCode());
    }
    for (ConversionDef item : metadata.conversions()) {
      addObjectRef(draft, refs, "commercial.conversions[" + item.conversionCode() + "].sourceObjectCode", "DOCUMENT_CONVERSION_OBJECT", item.sourceObjectCode());
      addObjectRef(draft, refs, "commercial.conversions[" + item.conversionCode() + "].targetObjectCode", "DOCUMENT_CONVERSION_OBJECT", item.targetObjectCode());
    }
    for (WriteBackDef item : metadata.writeBacks()) {
      addObjectRef(draft, refs, "commercial.writeBacks[" + item.writeBackCode() + "].sourceObjectCode", "WRITEBACK_OBJECT", item.sourceObjectCode());
      addObjectRef(draft, refs, "commercial.writeBacks[" + item.writeBackCode() + "].targetObjectCode", "WRITEBACK_OBJECT", item.targetObjectCode());
    }
    for (LinkConfigDef item : metadata.linkConfigs()) {
      addObjectRef(draft, refs, "commercial.linkConfigs[" + item.linkCode() + "].sourceObjectCode", "LINK_TRACE_OBJECT", item.sourceObjectCode());
      addObjectRef(draft, refs, "commercial.linkConfigs[" + item.linkCode() + "].targetObjectCode", "LINK_TRACE_OBJECT", item.targetObjectCode());
    }
    for (LinkTraceDef item : metadata.linkTraces()) {
      addObjectRef(draft, refs, "commercial.linkTraces[" + item.traceCode() + "].sourceObjectCode", "LINK_TRACE_OBJECT", item.sourceObjectCode());
      addObjectRef(draft, refs, "commercial.linkTraces[" + item.traceCode() + "].targetObjectCode", "LINK_TRACE_OBJECT", item.targetObjectCode());
    }
    for (FlexFieldDef item : metadata.flexFields()) {
      addObjectRef(draft, refs, "commercial.flexFields[" + item.flexCode() + "].applyToObject", "FLEX_FIELD_OBJECT", item.applyToObject());
    }
    for (OrgRelationDef item : metadata.orgRelations()) {
      addObjectRef(draft, refs, "commercial.orgRelations[" + item.relationCode() + "].sourceObjectCode", "ORG_RELATION_OBJECT", item.sourceObjectCode());
    }
    for (CodeRuleDef item : metadata.codeRules()) {
      addObjectRef(draft, refs, "commercial.codeRules[" + item.ruleCode() + "].objectCode", "CODE_RULE_OBJECT", item.objectCode());
    }
    for (PrintTemplateDef item : metadata.printTemplates()) {
      addObjectRef(draft, refs, "commercial.printTemplates[" + item.templateCode() + "].objectCode", "PRINT_TEMPLATE_OBJECT", item.objectCode());
    }
  }

  private void addObjectRef(MetaObjectDraft draft, List<MetaRefDef> refs, String path, String refType, String targetCode) {
    if (isBlank(targetCode)) {
      return;
    }
    refs.add(new MetaRefDef(draft.tenantId(), draft.appId(), "OBJECT", draft.code(), path, refType, "OBJECT", targetCode));
  }

  private boolean objectExists(Long tenantId, Long appId, String objectCode) {
    return drafts.containsKey(key(tenantId, appId, objectCode));
  }

  private static Map<String, FieldDef> fieldsByCode(MetaObjectDraft draft) {
    Map<String, FieldDef> result = new LinkedHashMap<>();
    for (FieldDef field : draft.fields()) {
      result.put(field.code(), field);
    }
    return result;
  }

  private long nextRevision(MetaObjectDraft draft) {
    MetaObjectDraft current = drafts.get(key(draft.tenantId(), draft.appId(), draft.code()));
    return current == null ? 1L : current.revision() + 1L;
  }

  private static String key(Long tenantId, Long appId, String objectCode) {
    return tenantId + ":" + appId + ":" + objectCode;
  }

  private static boolean isBlank(String value) {
    return value == null || value.isBlank();
  }
}
