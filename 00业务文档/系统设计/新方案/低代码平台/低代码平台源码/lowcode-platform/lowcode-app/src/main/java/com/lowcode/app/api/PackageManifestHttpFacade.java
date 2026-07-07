package com.lowcode.app.api;

import com.lowcode.metamodel.domain.def.PackageManifestDef;
import com.lowcode.metamodel.domain.service.PackageManifestValidationContext;
import com.lowcode.metamodel.domain.service.PackageManifestValidator;
import com.lowcode.metamodel.domain.service.ValidationReport;
import com.lowcode.plugin.service.PackageMarketplaceService;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class PackageManifestHttpFacade {

  private final PackageManifestValidator validator;
  private final PackageMarketplaceService.PackageCapabilityContextProvider capabilityContextProvider;

  @Autowired
  public PackageManifestHttpFacade(
      PackageMarketplaceService.PackageCapabilityContextProvider capabilityContextProvider) {
    this(new PackageManifestValidator(), capabilityContextProvider);
  }

  PackageManifestHttpFacade(
      PackageManifestValidator validator,
      PackageMarketplaceService.PackageCapabilityContextProvider capabilityContextProvider) {
    this.validator = validator;
    this.capabilityContextProvider = capabilityContextProvider;
  }

  PackagePrecheckResponse precheck(
      AuthenticatedRuntimeContext runtimeContext,
      PackagePrecheckRequest request) {
    PackagePrecheckRequest safeRequest = request == null ? PackagePrecheckRequest.empty() : request;
    ValidationReport report = validator.validate(
        safeRequest.safeManifest(),
        trustedContext(runtimeContext, safeRequest.safeContext()));
    return new PackagePrecheckResponse(
        report.passed(),
        report.errors().stream()
            .map(error -> new PackagePrecheckError(error.path(), error.code(), error.message()))
            .toList());
  }

  protected PackageManifestValidationContext trustedContext(
      AuthenticatedRuntimeContext runtimeContext) {
    return trustedContext(runtimeContext, PackagePrecheckContext.empty());
  }

  private PackageManifestValidationContext trustedContext(
      AuthenticatedRuntimeContext runtimeContext,
      PackagePrecheckContext requestContext) {
    PackageManifestValidationContext resolved =
        capabilityContextProvider.resolve(String.valueOf(runtimeContext.tenantId()));
    if (resolved == null) {
      resolved = failClosedCapabilityContext();
    }
    return new PackageManifestValidationContext(
        requestContext.installedDependencies(),
        resolved.availableObjects(),
        resolved.availableExtensions(),
        resolved.availableMenus(),
        resolved.availableReports(),
        resolved.grantedPermissions(),
        resolved.platformVersion(),
        resolved.apiLevel(),
        resolved.allowedLicenses(),
        resolved.runtimeInstallEnabled());
  }

  static PackageManifestValidationContext failClosedCapabilityContext() {
    return new PackageManifestValidationContext(
        Map.of(),
        Set.of(),
        Set.of(),
        Set.of(),
        Set.of(),
        Set.of(),
        null,
        null,
        Set.of(),
        false);
  }
}

record PackagePrecheckRequest(PackageManifestDef manifest, PackagePrecheckContext context) {

  static PackagePrecheckRequest empty() {
    return new PackagePrecheckRequest(new PackageManifestDef(null, null, false), PackagePrecheckContext.empty());
  }

  PackageManifestDef safeManifest() {
    return manifest == null ? new PackageManifestDef(null, null, false) : manifest;
  }

  PackagePrecheckContext safeContext() {
    return context == null ? PackagePrecheckContext.empty() : context;
  }
}

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
