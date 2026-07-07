package com.lowcode.app.api;

import com.lowcode.metamodel.domain.def.PackageManifestDef;
import com.lowcode.metamodel.domain.service.PackageManifestValidationContext;
import com.lowcode.plugin.service.PackageMarketplaceService;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
class PackageMarketplaceHttpFacade {

  private final PackageMarketplaceService service = new PackageMarketplaceService();

  PackageInstallResponse install(
      AuthenticatedRuntimeContext runtimeContext,
      PackageInstallRequest request) {
    PackageMarketplaceService.PackageInstallResult result =
        service.install(
            String.valueOf(runtimeContext.tenantId()),
            runtimeContext.userLid(),
            runtimeContext.traceId(),
            request.manifest(),
            context(request.context()));
    return new PackageInstallResponse(
        result.installed(),
        result.state() == null ? null : state(result.state()),
        result.report().errors().stream()
            .map(error -> new PackagePrecheckError(error.path(), error.code(), error.message()))
            .toList());
  }

  PackageListResponse list(AuthenticatedRuntimeContext runtimeContext) {
    return new PackageListResponse(
        service.listInstalled(String.valueOf(runtimeContext.tenantId())).stream()
            .map(this::state)
            .toList());
  }

  PackageStateEnvelope disable(
      AuthenticatedRuntimeContext runtimeContext,
      String packageCode) {
    return new PackageStateEnvelope(
        state(
            service.disable(
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
            service.enable(
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
        service.upgrade(
            String.valueOf(runtimeContext.tenantId()),
            runtimeContext.userLid(),
            runtimeContext.traceId(),
            request.manifest(),
            context(request.context()));
    return new PackageStateEnvelope(state(state));
  }

  PackageStateEnvelope rollback(
      AuthenticatedRuntimeContext runtimeContext,
      String packageCode) {
    return new PackageStateEnvelope(
        state(
            service.rollback(
                String.valueOf(runtimeContext.tenantId()),
                runtimeContext.userLid(),
                runtimeContext.traceId(),
                packageCode)));
  }

  PackageDryRunResponse uninstallDryRun(
      AuthenticatedRuntimeContext runtimeContext,
      String packageCode) {
    PackageMarketplaceService.PackageUninstallDryRun dryRun =
        service.uninstallDryRun(
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
        service.uninstall(
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
        service.auditEvents(String.valueOf(runtimeContext.tenantId())).stream()
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
