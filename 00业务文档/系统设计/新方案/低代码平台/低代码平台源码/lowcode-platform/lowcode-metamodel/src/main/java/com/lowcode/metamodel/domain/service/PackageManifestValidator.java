package com.lowcode.metamodel.domain.service;

import com.lowcode.metamodel.domain.def.PackageDependencyDef;
import com.lowcode.metamodel.domain.def.PackageManifestDef;
import java.util.ArrayList;
import java.util.List;

/** 应用包 manifest 校验器。 */
public class PackageManifestValidator {

  public ValidationReport validate(PackageManifestDef manifest, PackageManifestValidationContext context) {
    List<ValidationError> errors = new ArrayList<>();
    if (isBlank(manifest.packageCode())) {
      errors.add(new ValidationError("packageCode", "LC-META-PKG-002", "packageCode 不能为空"));
    }
    if (isBlank(manifest.version())) {
      errors.add(new ValidationError("version", "LC-META-PKG-003", "version 不能为空"));
    }
    if (isBlank(manifest.license())) {
      errors.add(new ValidationError("license", "LC-META-PKG-004", "license 不能为空"));
    }
    if (manifest.compatibility() == null
        || isBlank(manifest.compatibility().minPlatformVersion())
        || isBlank(manifest.compatibility().maxTestedPlatformVersion())
        || isBlank(manifest.compatibility().apiLevel())) {
      errors.add(new ValidationError("compatibility", "LC-META-PKG-006", "compatibility 声明不完整"));
    }
    for (PackageDependencyDef dependency : manifest.dependencies()) {
      String installedVersion = context.installedDependencies().get(dependency.packageCode());
      if (installedVersion == null) {
        errors.add(
            new ValidationError(
                "dependencies[" + dependency.packageCode() + "]",
                "LC-META-PKG-001",
                "缺少依赖包：" + dependency.packageCode()));
      } else if (compareVersion(installedVersion, dependency.minVersion()) < 0) {
        errors.add(
            new ValidationError(
                "dependencies[" + dependency.packageCode() + "]",
                "LC-META-PKG-012",
                "依赖版本不满足：" + dependency.packageCode()));
      }
    }
    validateMembership(manifest.objects(), context.availableObjects(), "objects", "LC-META-PKG-007", errors);
    validateMembership(manifest.extensions(), context.availableExtensions(), "extensions", "LC-META-PKG-008", errors);
    validateMembership(manifest.menus(), context.availableMenus(), "menus", "LC-META-PKG-009", errors);
    validateMembership(manifest.reports(), context.availableReports(), "reports", "LC-META-PKG-010", errors);
    for (String permission : manifest.permissions()) {
      if (!context.grantedPermissions().contains(permission)) {
        errors.add(new ValidationError("permissions[" + permission + "]", "LC-META-PKG-011", "缺少权限声明：" + permission));
      }
    }
    if (manifest.compatibility() != null && !isBlank(context.platformVersion())) {
      if (compareVersion(context.platformVersion(), manifest.compatibility().minPlatformVersion()) < 0
          || compareVersion(context.platformVersion(), normalizeMaxVersion(manifest.compatibility().maxTestedPlatformVersion())) > 0) {
        errors.add(new ValidationError("compatibility.platformVersion", "LC-META-PKG-013", "平台版本不兼容"));
      }
      if (!isBlank(context.apiLevel())
          && !manifest.compatibility().apiLevel().equalsIgnoreCase(context.apiLevel())) {
        errors.add(new ValidationError("compatibility.apiLevel", "LC-META-PKG-014", "API 级别不兼容"));
      }
    }
    if (!context.allowedLicenses().isEmpty() && !context.allowedLicenses().contains(manifest.license())) {
      errors.add(new ValidationError("license", "LC-META-PKG-015", "License 不允许安装"));
    }
    if (manifest.runtimeEnabled() && !context.runtimeInstallEnabled()) {
      errors.add(new ValidationError("runtimeEnabled", "LC-META-PKG-015", "当前环境未开启运行态安装"));
    }
    return new ValidationReport(errors);
  }

  private static void validateMembership(
      List<String> values, java.util.Set<String> available, String path, String code, List<ValidationError> errors) {
    for (String value : values) {
      if (!available.contains(value)) {
        errors.add(new ValidationError(path + "[" + value + "]", code, "引用不存在：" + value));
      }
    }
  }

  private static boolean isBlank(String value) {
    return value == null || value.isBlank();
  }

  private static String normalizeMaxVersion(String version) {
    if (version != null && version.endsWith(".x")) {
      return version.substring(0, version.length() - 2) + ".999";
    }
    return version;
  }

  private static int compareVersion(String left, String right) {
    String[] leftParts = left.split("\\.");
    String[] rightParts = right.split("\\.");
    int max = Math.max(leftParts.length, rightParts.length);
    for (int i = 0; i < max; i++) {
      int leftValue = i < leftParts.length ? Integer.parseInt(leftParts[i]) : 0;
      int rightValue = i < rightParts.length ? Integer.parseInt(rightParts[i]) : 0;
      if (leftValue != rightValue) {
        return Integer.compare(leftValue, rightValue);
      }
    }
    return 0;
  }
}
