package com.lowcode.metamodel.domain.schema;

import com.lowcode.metamodel.domain.def.CommercialMetadataDef;
import com.lowcode.metamodel.domain.def.I18nResourceDef;
import com.lowcode.metamodel.domain.def.MenuDef;
import com.lowcode.metamodel.domain.def.ObjectExtensionDef;
import com.lowcode.metamodel.domain.def.PackageManifestDef;
import com.lowcode.metamodel.domain.def.PrintTemplateDef;
import com.lowcode.metamodel.domain.def.ReportDef;
import com.lowcode.metamodel.domain.service.MetaObjectDraft;
import com.lowcode.metamodel.domain.service.ObjectExtensionMergeReport;
import com.lowcode.metamodel.domain.service.ObjectExtensionMergeService;
import com.lowcode.metamodel.domain.service.PackageManifestValidationContext;
import com.lowcode.metamodel.domain.service.PackageManifestValidator;
import com.lowcode.metamodel.domain.service.ValidationError;
import com.lowcode.metamodel.domain.service.ValidationReport;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** 商业发布门禁校验器。 */
public class CommercialPublishValidator {

  private final ObjectExtensionMergeService objectExtensionMergeService = new ObjectExtensionMergeService();
  private final PackageManifestValidator packageManifestValidator = new PackageManifestValidator();

  public CommercialPublishReport validate(List<MetaObjectDraft> objects) {
    Map<String, MetaObjectDraft> objectsByCode = new HashMap<>();
    for (MetaObjectDraft object : objects) {
      objectsByCode.put(object.code(), object);
    }
    Set<String> i18nKeys = new HashSet<>();
    Set<String> menus = new HashSet<>();
    Set<String> reports = new HashSet<>();
    Set<String> extensions = new HashSet<>();
    Set<String> permissions = new HashSet<>();
    List<ObjectExtensionMergeReport> mergeReports = new ArrayList<>();
    List<ValidationError> blockingErrors = new ArrayList<>();
    List<ValidationError> warnings = new ArrayList<>();

    for (MetaObjectDraft object : objects) {
      CommercialMetadataDef metadata = object.commercialMetadata();
      for (I18nResourceDef resource : metadata.i18nResources()) {
        i18nKeys.add(resource.resourceKey());
      }
      for (MenuDef menu : metadata.menus()) {
        menus.add(menu.menuCode());
      }
      for (ReportDef report : metadata.reports()) {
        reports.add(report.reportCode());
      }
      for (ObjectExtensionDef extension : metadata.objectExtensions()) {
        extensions.add(extension.extensionCode());
      }
      for (PackageManifestDef manifest : metadata.packageManifests()) {
        permissions.addAll(manifest.permissions());
      }
    }

    for (MetaObjectDraft object : objects) {
      CommercialMetadataDef metadata = object.commercialMetadata();
      List<ObjectExtensionDef> applicableExtensions =
          metadata.objectExtensions().stream()
              .filter(item -> objectsByCode.containsKey(item.baseObjectCode()))
              .toList();
      Map<String, List<ObjectExtensionDef>> grouped = new HashMap<>();
      for (ObjectExtensionDef extension : applicableExtensions) {
        grouped.computeIfAbsent(extension.baseObjectCode(), ignored -> new ArrayList<>()).add(extension);
      }
      for (Map.Entry<String, List<ObjectExtensionDef>> entry : grouped.entrySet()) {
        ObjectExtensionMergeReport report = objectExtensionMergeService.merge(objectsByCode.get(entry.getKey()), entry.getValue());
        mergeReports.add(report);
        blockingErrors.addAll(report.blockingErrors());
      }
      for (PackageManifestDef manifest : metadata.packageManifests()) {
        ValidationReport report =
            packageManifestValidator.validate(
                manifest,
                new PackageManifestValidationContext(
                    Map.of(),
                    objectsByCode.keySet(),
                    extensions,
                    menus,
                    reports,
                    permissions,
                    "1.0.0",
                    "stable-1"));
        blockingErrors.addAll(report.errors());
      }
      validateArtifacts(metadata, i18nKeys, permissions, blockingErrors, warnings);
    }
    return new CommercialPublishReport(mergeReports, blockingErrors, warnings);
  }

  private static void validateArtifacts(
      CommercialMetadataDef metadata,
      Set<String> i18nKeys,
      Set<String> permissions,
      List<ValidationError> blockingErrors,
      List<ValidationError> warnings) {
    for (ReportDef report : metadata.reports()) {
      validatePermissionAndI18n("reports[" + report.reportCode() + "]", report.requiredPermission(), report.titleI18nKey(), i18nKeys, permissions, blockingErrors);
      if (!report.mobileSupported()) {
        warnings.add(new ValidationError("reports[" + report.reportCode() + "]", "LC-META-PUBLISH-002", "移动端不兼容组件已进入发布报告"));
      }
    }
    for (PrintTemplateDef template : metadata.printTemplates()) {
      validatePermissionAndI18n("printTemplates[" + template.templateCode() + "]", template.requiredPermission(), template.titleI18nKey(), i18nKeys, permissions, blockingErrors);
      if (!template.mobileSupported()) {
        warnings.add(new ValidationError("printTemplates[" + template.templateCode() + "]", "LC-META-PUBLISH-002", "移动端不兼容组件已进入发布报告"));
      }
    }
    for (MenuDef menu : metadata.menus()) {
      validatePermissionAndI18n("menus[" + menu.menuCode() + "]", menu.requiredPermission(), menu.titleI18nKey(), i18nKeys, permissions, blockingErrors);
      if (!menu.mobileSupported() || "mobile".equals(menu.deviceScope())) {
        warnings.add(new ValidationError("menus[" + menu.menuCode() + "]", "LC-META-PUBLISH-003", "菜单移动端兼容性需要人工确认"));
      }
    }
  }

  private static void validatePermissionAndI18n(
      String path,
      String requiredPermission,
      String titleI18nKey,
      Set<String> i18nKeys,
      Set<String> permissions,
      List<ValidationError> blockingErrors) {
    if (requiredPermission != null && !permissions.contains(requiredPermission)) {
      blockingErrors.add(new ValidationError(path + ".requiredPermission", "LC-META-PUBLISH-001", "缺少权限声明：" + requiredPermission));
    }
    if (titleI18nKey != null && !i18nKeys.contains(titleI18nKey)) {
      blockingErrors.add(new ValidationError(path + ".titleI18nKey", "LC-META-PUBLISH-004", "缺少 i18n key：" + titleI18nKey));
    }
  }
}
