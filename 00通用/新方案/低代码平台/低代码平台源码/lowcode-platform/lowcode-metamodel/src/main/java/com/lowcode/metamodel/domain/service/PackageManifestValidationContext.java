package com.lowcode.metamodel.domain.service;

import java.util.Map;
import java.util.Set;

/** 应用包清单校验上下文。 */
public record PackageManifestValidationContext(
    Map<String, String> installedDependencies,
    Set<String> availableObjects,
    Set<String> availableExtensions,
    Set<String> availableMenus,
    Set<String> availableReports,
    Set<String> grantedPermissions,
    String platformVersion,
    String apiLevel,
    Set<String> allowedLicenses,
    boolean runtimeInstallEnabled) {

  public PackageManifestValidationContext {
    installedDependencies = Map.copyOf(installedDependencies);
    availableObjects = Set.copyOf(availableObjects);
    availableExtensions = Set.copyOf(availableExtensions);
    availableMenus = Set.copyOf(availableMenus);
    availableReports = Set.copyOf(availableReports);
    grantedPermissions = Set.copyOf(grantedPermissions);
    allowedLicenses = Set.copyOf(allowedLicenses);
  }

  public PackageManifestValidationContext(
      Map<String, String> installedDependencies,
      Set<String> availableObjects,
      Set<String> availableExtensions,
      Set<String> availableMenus,
      Set<String> availableReports,
      Set<String> grantedPermissions,
      String platformVersion,
      String apiLevel) {
    this(
        installedDependencies,
        availableObjects,
        availableExtensions,
        availableMenus,
        availableReports,
        grantedPermissions,
        platformVersion,
        apiLevel,
        Set.of(),
        true);
  }
}
