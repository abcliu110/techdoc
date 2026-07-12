package com.lowcode.metamodel.domain.service;

import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.ObjectExtensionDef;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** 按固定扩展层优先级合并对象扩展。 */
public class ObjectExtensionMergeService {

  private static final Map<String, Integer> SOURCE_PRIORITY =
      Map.of(
          "system", 0,
          "industry_template", 1,
          "app_template", 2,
          "customer", 3,
          "plugin", 4);

  private static final Set<String> SYSTEM_FIELD_CODES =
      Set.of("id", "lid", "tenant_id", "revision", "deleted", "delete_token", "create_time", "update_time", "create_by", "update_by", "publish_status", "state_code");

  public ObjectExtensionMergeReport merge(MetaObjectDraft baseObject, List<ObjectExtensionDef> extensions) {
    List<ObjectExtensionDef> sorted =
        extensions.stream()
            .filter(item -> baseObject.code().equals(item.baseObjectCode()))
            .sorted(Comparator.comparingInt(item -> SOURCE_PRIORITY.getOrDefault(item.sourceKind(), Integer.MAX_VALUE)))
            .toList();
    Map<String, FieldDef> merged = new LinkedHashMap<>();
    for (FieldDef field : baseObject.fields()) {
      merged.put(field.code(), field);
    }
    Map<String, String> fieldOwner = new LinkedHashMap<>();
    List<ValidationError> errors = new ArrayList<>();
    List<ObjectExtensionDef> applied = new ArrayList<>();

    for (ObjectExtensionDef extension : sorted) {
      applied.add(extension);
      for (FieldDef field : extension.fields()) {
        if (SYSTEM_FIELD_CODES.contains(field.code())) {
          errors.add(
              new ValidationError(
                  "objectExtensions[" + extension.extensionCode() + "].fields[" + field.code() + "]",
                  "LC-META-EXT-001",
                  "禁止覆盖系统字段或标准字段：" + field.code()));
          continue;
        }
        String existingOwner = fieldOwner.get(field.code());
        if (existingOwner != null) {
          errors.add(
              new ValidationError(
                  "objectExtensions[" + extension.extensionCode() + "].fields[" + field.code() + "]",
                  "LC-META-EXT-002",
                  "扩展字段冲突：" + existingOwner + " 与 " + extension.extensionCode()));
          continue;
        }
        if (merged.containsKey(field.code())) {
          errors.add(
              new ValidationError(
                  "objectExtensions[" + extension.extensionCode() + "].fields[" + field.code() + "]",
                  "LC-META-EXT-001",
                  "禁止覆盖系统字段或标准字段：" + field.code()));
          continue;
        }
        fieldOwner.put(field.code(), extension.extensionCode());
        merged.put(field.code(), field);
      }
    }
    return new ObjectExtensionMergeReport(baseObject.code(), applied, List.copyOf(merged.values()), errors);
  }
}
