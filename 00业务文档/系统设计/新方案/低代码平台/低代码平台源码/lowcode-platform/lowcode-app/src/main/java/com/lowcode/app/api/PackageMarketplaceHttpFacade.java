package com.lowcode.app.api;

import com.lowcode.common.error.BizException;
import com.lowcode.common.error.ErrorCode;
import com.lowcode.metamodel.domain.def.PackageManifestDef;
import com.lowcode.metamodel.domain.service.PackageManifestValidationContext;
import com.lowcode.plugin.service.PackageMarketplaceService;
import java.util.List;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
class PackageMarketplaceHttpFacade {

  private final PackageMarketplaceService service;
  private final PackageMarketplaceService.PackageCapabilityContextProvider capabilityContextProvider;

  @Autowired
  PackageMarketplaceHttpFacade(
      Optional<PackageMarketplaceService> service,
      PackageMarketplaceService.PackageCapabilityContextProvider capabilityContextProvider) {
    this.service = service.orElse(null);
    this.capabilityContextProvider = capabilityContextProvider;
  }

  PackageMarketplaceHttpFacade(
      PackageMarketplaceService service,
      PackageMarketplaceService.PackageCapabilityContextProvider capabilityContextProvider) {
    this.service = service;
    this.capabilityContextProvider = capabilityContextProvider;
  }

  PackageInstallResponse install(
      AuthenticatedRuntimeContext runtimeContext,
      PackageInstallRequest request) {
    PackageMarketplaceService.PackageInstallResult result =
        requirePackageMarketplaceService().install(
            String.valueOf(runtimeContext.tenantId()),
            runtimeContext.userLid(),
            runtimeContext.traceId(),
            request.manifest(),
            trustedContext(runtimeContext));
    return new PackageInstallResponse(
        result.installed(),
        result.state() == null ? null : state(result.state()),
        result.report().errors().stream()
            .map(error -> new PackagePrecheckError(error.path(), error.code(), error.message()))
            .toList());
  }

  PackageListResponse list(AuthenticatedRuntimeContext runtimeContext) {
    return new PackageListResponse(
        requirePackageMarketplaceService().listInstalled(String.valueOf(runtimeContext.tenantId())).stream()
            .map(this::state)
            .toList());
  }

  PackageStateEnvelope disable(
      AuthenticatedRuntimeContext runtimeContext,
      String packageCode) {
    return new PackageStateEnvelope(
        state(
            requirePackageMarketplaceService().disable(
                String.valueOf(runtimeContext.tenantId()),
                runtimeContext.userLid(),
                runtimeContext.traceId(),
                packageCode)));
  }

  PackageStateEnvelope enable(
      AuthenticatedRuntimeContext runtimeContext,
      String packageCode) {
    return new PackageStateEnvelope(
        state(
            requirePackageMarketplaceService().enable(
                String.valueOf(runtimeContext.tenantId()),
                runtimeContext.userLid(),
                runtimeContext.traceId(),
                packageCode)));
  }

  PackageStateEnvelope upgrade(
      AuthenticatedRuntimeContext runtimeContext,
      String packageCode,
      PackageInstallRequest request) {
    PackageMarketplaceService.PackageInstallationState state =
        requirePackageMarketplaceService().upgrade(
            String.valueOf(runtimeContext.tenantId()),
            runtimeContext.userLid(),
            runtimeContext.traceId(),
            request.manifest(),
            trustedContext(runtimeContext));
    return new PackageStateEnvelope(state(state));
  }

  PackageStateEnvelope rollback(
      AuthenticatedRuntimeContext runtimeContext,
      String packageCode) {
    return new PackageStateEnvelope(
        state(
            requirePackageMarketplaceService().rollback(
                String.valueOf(runtimeContext.tenantId()),
                runtimeContext.userLid(),
                runtimeContext.traceId(),
                packageCode)));
  }

  PackageDryRunResponse uninstallDryRun(
      AuthenticatedRuntimeContext runtimeContext,
      String packageCode) {
    PackageMarketplaceService.PackageUninstallDryRun dryRun =
        requirePackageMarketplaceService().uninstallDryRun(
            String.valueOf(runtimeContext.tenantId()),
            runtimeContext.userLid(),
            runtimeContext.traceId(),
            packageCode);
    return new PackageDryRunResponse(
        dryRun.allowed(),
        dryRun.packageCode(),
        dryRun.status().name(),
        dryRun.blockingReasons());
  }

  PackageUninstallResponse uninstall(
      AuthenticatedRuntimeContext runtimeContext,
      String packageCode) {
    PackageMarketplaceService.PackageUninstallResult result =
        requirePackageMarketplaceService().uninstall(
            String.valueOf(runtimeContext.tenantId()),
            runtimeContext.userLid(),
            runtimeContext.traceId(),
            packageCode);
    return new PackageUninstallResponse(
        result.uninstalled(),
        result.packageCode(),
        result.previousStatus().name(),
        result.blockingReasons());
  }

  PackageAuditResponse audit(AuthenticatedRuntimeContext runtimeContext) {
    return new PackageAuditResponse(
        requirePackageMarketplaceService().auditEvents(String.valueOf(runtimeContext.tenantId())).stream()
            .map(event -> new PackageAuditEventResponse(
                event.packageCode(),
                event.operator(),
                event.traceId(),
                event.operation(),
                event.result(),
                event.details(),
                event.occurredAt()))
            .toList());
  }

  protected PackageManifestValidationContext trustedContext(
      AuthenticatedRuntimeContext runtimeContext) {
    PackageManifestValidationContext resolved =
        capabilityContextProvider.resolve(String.valueOf(runtimeContext.tenantId()));
    if (resolved == null) {
      resolved = PackageManifestHttpFacade.failClosedCapabilityContext();
    }
    return new PackageManifestValidationContext(
        java.util.Map.of(),
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

  private PackageStateResponse state(PackageMarketplaceService.PackageInstallationState state) {
    return new PackageStateResponse(
        state.packageCode(),
        state.version(),
        state.license(),
        state.runtimeEnabled(),
        state.status().name(),
        state.lastOperator(),
        state.lastTraceId(),
        state.installedAt());
  }

  private PackageMarketplaceService requirePackageMarketplaceService() {
    if (service == null) {
      throw new BizException(ErrorCode.FEATURE_DISABLED, "包市场服务未启用");
    }
    return service;
  }
}

record PackageInstallRequest(PackageManifestDef manifest, PackagePrecheckContext context) {}

record PackageInstallResponse(
    boolean installed,
    PackageStateResponse state,
    List<PackagePrecheckError> errors) {
}

record PackageListResponse(List<PackageStateResponse> packages) {}

record PackageStateEnvelope(PackageStateResponse state) {}

record PackageDryRunResponse(
    boolean allowed,
    String packageCode,
    String status,
    List<String> blockingReasons) {
}

record PackageUninstallResponse(
    boolean uninstalled,
    String packageCode,
    String previousStatus,
    List<String> blockingReasons) {
}

record PackageAuditResponse(List<PackageAuditEventResponse> events) {}

record PackageAuditEventResponse(
    String packageCode,
    String operator,
    String traceId,
    String operation,
    String result,
    String details,
    String occurredAt) {}

record PackageStateResponse(
    String packageCode,
    String version,
    String license,
    boolean runtimeEnabled,
    String status,
    String lastOperator,
    String lastTraceId,
    String installedAt) {
}
