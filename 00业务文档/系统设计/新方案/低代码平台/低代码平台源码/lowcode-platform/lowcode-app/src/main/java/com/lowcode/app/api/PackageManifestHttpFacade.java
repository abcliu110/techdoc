package com.lowcode.app.api;

import com.lowcode.metamodel.domain.def.PackageManifestDef;
import com.lowcode.metamodel.domain.service.PackageManifestValidationContext;
import com.lowcode.metamodel.domain.service.PackageManifestValidator;
import com.lowcode.metamodel.domain.service.ValidationReport;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.stereotype.Component;

@Component
class PackageManifestHttpFacade {

  private final PackageManifestValidator validator = new PackageManifestValidator();

  PackagePrecheckResponse precheck(PackagePrecheckRequest request) {
    ValidationReport report = validator.validate(request.manifest(), context(request.context()));
    return new PackagePrecheckResponse(
        report.passed(),
        report.errors().stream()
            .map(error -> new PackagePrecheckError(error.path(), error.code(), error.message()))
            .toList());
  }

  private PackageManifestValidationContext context(PackagePrecheckContext context) {
    PackagePrecheckContext safe = context == null ? PackagePrecheckContext.empty() : context;
    return new PackageManifestValidationContext(
        safe.installedDependencies(),
        safe.availableObjects(),
        safe.availableExtensions(),
        safe.availableMenus(),
        safe.availableReports(),
        safe.grantedPermissions(),
        safe.platformVersion(),
        safe.apiLevel(),
        safe.allowedLicenses(),
        safe.runtimeInstallEnabled() == null || safe.runtimeInstallEnabled());
  }
}

record PackagePrecheckRequest(PackageManifestDef manifest, PackagePrecheckContext context) {}

record PackagePrecheckContext(
    Map<String, String> installedDependencies,
    Set<String> availableObjects,
    Set<String> availableExtensions,
    Set<String> availableMenus,
    Set<String> availableReports,
    Set<String> grantedPermissions,
    String platformVersion,
    String apiLevel,
    Set<String> allowedLicenses,
    Boolean runtimeInstallEnabled) {

  PackagePrecheckContext {
    installedDependencies = installedDependencies == null ? Map.of() : Map.copyOf(installedDependencies);
    availableObjects = availableObjects == null ? Set.of() : Set.copyOf(availableObjects);
    availableExtensions = availableExtensions == null ? Set.of() : Set.copyOf(availableExtensions);
    availableMenus = availableMenus == null ? Set.of() : Set.copyOf(availableMenus);
    availableReports = availableReports == null ? Set.of() : Set.copyOf(availableReports);
    grantedPermissions = grantedPermissions == null ? Set.of() : Set.copyOf(grantedPermissions);
    allowedLicenses = allowedLicenses == null ? Set.of() : Set.copyOf(allowedLicenses);
  }

  static PackagePrecheckContext empty() {
    return new PackagePrecheckContext(Map.of(), Set.of(), Set.of(), Set.of(), Set.of(), Set.of(), null, null, Set.of(), Boolean.TRUE);
  }
}

record PackagePrecheckResponse(boolean passed, List<PackagePrecheckError> errors) {}

record PackagePrecheckError(String path, String code, String message) {
}
