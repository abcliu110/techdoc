package com.lowcode.metamodel.domain.service;

import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.ObjectExtensionDef;
import java.util.List;

/** 对象扩展层合并报告。 */
public record ObjectExtensionMergeReport(
    String baseObjectCode,
    List<ObjectExtensionDef> appliedExtensions,
    List<FieldDef> mergedFields,
    List<ValidationError> blockingErrors) {

  public ObjectExtensionMergeReport {
    appliedExtensions = List.copyOf(appliedExtensions);
    mergedFields = List.copyOf(mergedFields);
    blockingErrors = List.copyOf(blockingErrors);
  }

  public boolean blocked() {
    return !blockingErrors.isEmpty();
  }
}
