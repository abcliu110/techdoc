package com.lowcode.metamodel.domain.schema;

import com.lowcode.metamodel.domain.service.ObjectExtensionMergeReport;
import com.lowcode.metamodel.domain.service.ValidationError;
import java.util.List;

/** 商业发布语义报告。 */
public record CommercialPublishReport(
    List<ObjectExtensionMergeReport> extensionMergeReports,
    List<ValidationError> blockingErrors,
    List<ValidationError> warnings) {

  public CommercialPublishReport {
    extensionMergeReports = List.copyOf(extensionMergeReports);
    blockingErrors = List.copyOf(blockingErrors);
    warnings = List.copyOf(warnings);
  }

  public boolean blocked() {
    return !blockingErrors.isEmpty();
  }
}
