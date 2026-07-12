package com.lowcode.plugin.service;

import com.lowcode.common.error.BizException;
import com.lowcode.common.error.ErrorCode;
import com.lowcode.metamodel.domain.def.PackageManifestDef;
import com.lowcode.metamodel.domain.service.PackageManifestValidationContext;
import com.lowcode.metamodel.domain.service.PackageManifestValidator;
import com.lowcode.metamodel.domain.service.ValidationError;
import com.lowcode.metamodel.domain.service.ValidationReport;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** M4 应用包市场安装生命周期最小服务。 */
public class PackageMarketplaceService {

  private final PackageInstallationRepository repository;
  private final PackageManifestValidator validator;
  private final PackageCapabilityContextProvider capabilityContextProvider;

  public PackageMarketplaceService() {
    this(new InMemoryPackageInstallationRepository(), new PackageManifestValidator(), tenantId -> null);
  }

  public PackageMarketplaceService(PackageCapabilityContextProvider capabilityContextProvider) {
    this(new InMemoryPackageInstallationRepository(), new PackageManifestValidator(), capabilityContextProvider);
  }

  public static PackageMarketplaceService inMemoryDemo(
      PackageCapabilityContextProvider capabilityContextProvider) {
    return new PackageMarketplaceService(
        new InMemoryPackageInstallationRepository(),
        new PackageManifestValidator(),
        capabilityContextProvider);
  }

  PackageMarketplaceService(
      PackageInstallationRepository repository,
      PackageManifestValidator validator) {
    this(repository, validator, tenantId -> null);
  }

  public PackageMarketplaceService(
      PackageInstallationRepository repository,
      PackageManifestValidator validator,
      PackageCapabilityContextProvider capabilityContextProvider) {
    this.repository = repository;
    this.validator = validator;
    this.capabilityContextProvider = capabilityContextProvider;
  }

  public PackageInstallResult install(
      String tenantId,
      String operator,
      String traceId,
      PackageManifestDef manifest,
      PackageManifestValidationContext context) {
    PackageInstallationState current =
        repository.findByTenantAndCode(tenantId, manifest.packageCode()).orElse(null);
    if (current != null && current.version().equals(manifest.version())) {
      appendAudit(
          tenantId,
          manifest.packageCode(),
          operator,
          traceId,
          "INSTALL_REPLAYED",
          "REPLAYED",
          manifest.version());
      return new PackageInstallResult(true, current, new ValidationReport(List.of()));
    }
    if (current != null) {
      appendAudit(
          tenantId,
          manifest.packageCode(),
          operator,
          traceId,
          "INSTALL_REJECTED",
          "REJECTED",
          "LC-PKG-INSTALL-001");
      return new PackageInstallResult(
          false,
          null,
          new ValidationReport(
              List.of(
                  new ValidationError(
                      "version",
                      "LC-PKG-INSTALL-001",
                      "应用包已安装，版本变更必须走升级流程"))));
    }
    ValidationReport report = validator.validate(manifest, serverContext(tenantId, context));
    if (!report.passed()) {
      appendAudit(
          tenantId,
          manifest.packageCode(),
          operator,
          traceId,
          "INSTALL_REJECTED",
          "REJECTED",
          errorCodes(report));
      return new PackageInstallResult(false, null, report);
    }
    PackageInstallationState state =
        new PackageInstallationState(
            tenantId,
            manifest.packageCode(),
            manifest.version(),
            manifest.license(),
            manifest.runtimeEnabled(),
            declaredDependencyVersions(tenantId, manifest),
            PackageInstallationStatus.ENABLED,
            operator,
            traceId,
            Instant.now().toString());
    repository.save(state);
    appendAudit(
        tenantId,
        manifest.packageCode(),
        operator,
        traceId,
        "INSTALL_SUCCEEDED",
        "SUCCEEDED",
        manifest.version());
    return new PackageInstallResult(true, state, report);
  }

  private PackageManifestValidationContext serverContext(
      String tenantId,
      PackageManifestValidationContext ignoredRequestedContext) {
    PackageManifestValidationContext resolvedContext = capabilityContextProvider.resolve(tenantId);
    if (resolvedContext == null) {
      resolvedContext = failClosedCapabilityContext();
    }
    return new PackageManifestValidationContext(
        installedVersions(tenantId),
        resolvedContext.availableObjects(),
        resolvedContext.availableExtensions(),
        resolvedContext.availableMenus(),
        resolvedContext.availableReports(),
        resolvedContext.grantedPermissions(),
        resolvedContext.platformVersion(),
        resolvedContext.apiLevel(),
        resolvedContext.allowedLicenses(),
        resolvedContext.runtimeInstallEnabled());
  }

  private PackageManifestValidationContext failClosedCapabilityContext() {
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

  private Map<String, String> installedVersions(String tenantId) {
    Map<String, String> versions = new LinkedHashMap<>();
    for (PackageInstallationState state : repository.listByTenant(tenantId)) {
      versions.put(state.packageCode(), state.version());
    }
    return versions;
  }

  private Map<String, String> declaredDependencyVersions(String tenantId, PackageManifestDef manifest) {
    Map<String, String> installed = installedVersions(tenantId);
    Map<String, String> dependencies = new LinkedHashMap<>();
    manifest.dependencies().forEach(dependency -> {
      String installedVersion = installed.get(dependency.packageCode());
      if (installedVersion != null) {
        dependencies.put(dependency.packageCode(), installedVersion);
      }
    });
    return dependencies;
  }

  public List<PackageInstallationState> listInstalled(String tenantId) {
    return repository.listByTenant(tenantId);
  }

  public PackageInstallationState upgrade(
      String tenantId,
      String operator,
      String traceId,
      PackageManifestDef manifest,
      PackageManifestValidationContext context) {
    PackageInstallationState current = requireState(tenantId, manifest.packageCode());
    ValidationReport report = validator.validate(manifest, serverContext(tenantId, context));
    if (!report.passed()) {
      appendAudit(
          tenantId,
          manifest.packageCode(),
          operator,
          traceId,
          "UPGRADE_REJECTED",
          "REJECTED",
          errorCodes(report));
      throw new BizException(ErrorCode.PARAM_INVALID, "应用包升级校验失败：" + errorCodes(report));
    }
    if (current.version().equals(manifest.version())) {
      appendAudit(
          tenantId,
          manifest.packageCode(),
          operator,
          traceId,
          "UPGRADE_REPLAYED",
          "REPLAYED",
          manifest.version());
      return current.withOperation(operator, traceId);
    }
    PackageInstallationState updated =
        new PackageInstallationState(
            tenantId,
            manifest.packageCode(),
            manifest.version(),
            manifest.license(),
            manifest.runtimeEnabled(),
            declaredDependencyVersions(tenantId, manifest),
            current.status(),
            operator,
            traceId,
            current.installedAt());
    repository.saveRollbackState(current);
    repository.save(updated);
    appendAudit(
        tenantId,
        manifest.packageCode(),
        operator,
        traceId,
        "UPGRADED",
        "SUCCEEDED",
        current.version() + "->" + manifest.version());
    return updated;
  }

  public PackageInstallationState rollback(
      String tenantId,
      String operator,
      String traceId,
      String packageCode) {
    PackageInstallationState current = requireState(tenantId, packageCode);
    PackageInstallationState previous =
        repository.popRollbackState(tenantId, packageCode)
            .orElseThrow(() -> new BizException(ErrorCode.PARAM_INVALID, "应用包没有可回滚版本"));
    PackageInstallationState rolledBack = previous.withOperation(operator, traceId);
    repository.save(rolledBack);
    appendAudit(
        tenantId,
        packageCode,
        operator,
        traceId,
        "ROLLED_BACK",
        "SUCCEEDED",
        current.version() + "->" + rolledBack.version());
    return rolledBack;
  }

  public PackageInstallationState disable(
      String tenantId,
      String operator,
      String traceId,
      String packageCode) {
    PackageInstallationState current = requireState(tenantId, packageCode);
    PackageInstallationState updated =
        current.withStatus(PackageInstallationStatus.DISABLED)
            .withOperation(operator, traceId);
    repository.save(updated);
    appendAudit(
        tenantId,
        packageCode,
        operator,
        traceId,
        "DISABLED",
        "SUCCEEDED",
        current.status().name() + "->" + updated.status().name());
    return updated;
  }

  public PackageInstallationState enable(
      String tenantId,
      String operator,
      String traceId,
      String packageCode) {
    PackageInstallationState current = requireState(tenantId, packageCode);
    PackageInstallationState updated =
        current.withStatus(PackageInstallationStatus.ENABLED)
            .withOperation(operator, traceId);
    repository.save(updated);
    appendAudit(
        tenantId,
        packageCode,
        operator,
        traceId,
        "ENABLED",
        "SUCCEEDED",
        current.status().name() + "->" + updated.status().name());
    return updated;
  }

  public PackageUninstallDryRun uninstallDryRun(String tenantId, String packageCode) {
    return uninstallDryRun(tenantId, "system", "trace-uninstall-dry-run", packageCode);
  }

  public PackageUninstallDryRun uninstallDryRun(
      String tenantId,
      String operator,
      String traceId,
      String packageCode) {
    PackageUninstallCheck check = checkUninstall(tenantId, packageCode);
    appendAudit(
        tenantId,
        packageCode,
        operator,
        traceId,
        check.blockingReasons().isEmpty() ? "UNINSTALL_DRY_RUN_ALLOWED" : "UNINSTALL_DRY_RUN_BLOCKED",
        check.blockingReasons().isEmpty() ? "ALLOWED" : "BLOCKED",
        String.join("|", check.blockingReasons()));
    return new PackageUninstallDryRun(
        check.blockingReasons().isEmpty(),
        check.state().packageCode(),
        check.state().status(),
        check.blockingReasons());
  }

  public PackageUninstallResult uninstall(
      String tenantId,
      String operator,
      String traceId,
      String packageCode) {
    PackageUninstallCheck check = checkUninstall(tenantId, packageCode);
    if (!check.blockingReasons().isEmpty()) {
      appendAudit(
          tenantId,
          packageCode,
          operator,
          traceId,
          "UNINSTALL_BLOCKED",
          "BLOCKED",
          String.join("|", check.blockingReasons()));
      return new PackageUninstallResult(false, packageCode, check.state().status(), check.blockingReasons());
    }
    repository.delete(tenantId, packageCode);
    appendAudit(
        tenantId,
        packageCode,
        operator,
        traceId,
        "UNINSTALLED",
        "SUCCEEDED",
        "metadata-preserved");
    return new PackageUninstallResult(true, packageCode, check.state().status(), List.of());
  }

  private PackageUninstallCheck checkUninstall(String tenantId, String packageCode) {
    PackageInstallationState current = requireState(tenantId, packageCode);
    List<String> blockingReasons = new ArrayList<>();
    if (current.status() == PackageInstallationStatus.ENABLED) {
      blockingReasons.add("应用包仍处于启用状态，请先禁用");
    }
    Set<String> dependents = dependentPackages(tenantId, packageCode);
    if (!dependents.isEmpty()) {
      blockingReasons.add("仍被已安装应用包依赖：" + String.join(",", dependents));
    }
    return new PackageUninstallCheck(current, List.copyOf(blockingReasons));
  }

  private PackageInstallationState requireState(String tenantId, String packageCode) {
    return repository.findByTenantAndCode(tenantId, packageCode)
        .orElseThrow(() -> new BizException(ErrorCode.PARAM_INVALID, "应用包不存在"));
  }

  private Set<String> dependentPackages(String tenantId, String packageCode) {
    Set<String> dependents = new LinkedHashSet<>();
    for (PackageInstallationState state : repository.listByTenant(tenantId)) {
      if (state.dependencyVersions().containsKey(packageCode)) {
        dependents.add(state.packageCode());
      }
    }
    return dependents;
  }

  public List<PackageAuditEvent> auditEvents(String tenantId) {
    return repository.auditEvents(tenantId);
  }

  private void appendAudit(
      String tenantId,
      String packageCode,
      String operator,
      String traceId,
      String operation,
      String result,
      String details) {
    repository.appendAudit(
        new PackageAuditEvent(
            tenantId,
            packageCode,
            operator,
            traceId,
            operation,
            result,
            details == null ? "" : details,
            Instant.now().toString()));
  }

  private String errorCodes(ValidationReport report) {
    return report.errors().stream()
        .map(ValidationError::code)
        .distinct()
        .reduce((left, right) -> left + "," + right)
        .orElse("");
  }

  interface PackageInstallationRepository {

    void save(PackageInstallationState state);

    java.util.Optional<PackageInstallationState> findByTenantAndCode(String tenantId, String packageCode);

    void saveRollbackState(PackageInstallationState state);

    java.util.Optional<PackageInstallationState> popRollbackState(String tenantId, String packageCode);

    void clearRollbackState(String tenantId, String packageCode);

    void delete(String tenantId, String packageCode);

    List<PackageInstallationState> listByTenant(String tenantId);

    void appendAudit(PackageAuditEvent event);

    List<PackageAuditEvent> auditEvents(String tenantId);

    PackageRepositorySnapshot exportTenantSnapshot(String tenantId);

    void importTenantSnapshot(PackageRepositorySnapshot snapshot);
  }

  static final class InMemoryPackageInstallationRepository implements PackageInstallationRepository {

    private final Map<String, Map<String, PackageInstallationState>> statesByTenant = new LinkedHashMap<>();
    private final Map<String, Map<String, List<PackageInstallationState>>> rollbackStatesByTenant = new LinkedHashMap<>();
    private final Map<String, List<PackageAuditEvent>> auditEventsByTenant = new LinkedHashMap<>();

    @Override
    public void save(PackageInstallationState state) {
      statesByTenant
          .computeIfAbsent(state.tenantId(), ignored -> new LinkedHashMap<>())
          .put(state.packageCode(), state);
    }

    @Override
    public java.util.Optional<PackageInstallationState> findByTenantAndCode(String tenantId, String packageCode) {
      return java.util.Optional.ofNullable(
          statesByTenant.getOrDefault(tenantId, Map.of()).get(packageCode));
    }

    @Override
    public void saveRollbackState(PackageInstallationState state) {
      rollbackStatesByTenant
          .computeIfAbsent(state.tenantId(), ignored -> new LinkedHashMap<>())
          .computeIfAbsent(state.packageCode(), ignored -> new ArrayList<>())
          .add(state);
    }

    @Override
    public java.util.Optional<PackageInstallationState> popRollbackState(String tenantId, String packageCode) {
      List<PackageInstallationState> states =
          rollbackStatesByTenant.getOrDefault(tenantId, Map.of()).get(packageCode);
      if (states == null || states.isEmpty()) {
        return java.util.Optional.empty();
      }
      return java.util.Optional.of(states.removeLast());
    }

    @Override
    public void clearRollbackState(String tenantId, String packageCode) {
      Map<String, List<PackageInstallationState>> states = rollbackStatesByTenant.get(tenantId);
      if (states != null) {
        states.remove(packageCode);
      }
    }

    @Override
    public void delete(String tenantId, String packageCode) {
      Map<String, PackageInstallationState> states = statesByTenant.get(tenantId);
      if (states != null) {
        states.remove(packageCode);
      }
      clearRollbackState(tenantId, packageCode);
    }

    @Override
    public List<PackageInstallationState> listByTenant(String tenantId) {
      return List.copyOf(statesByTenant.getOrDefault(tenantId, Map.of()).values());
    }

    @Override
    public void appendAudit(PackageAuditEvent event) {
      auditEventsByTenant
          .computeIfAbsent(event.tenantId(), ignored -> new ArrayList<>())
          .add(event);
    }

    @Override
    public List<PackageAuditEvent> auditEvents(String tenantId) {
      return List.copyOf(auditEventsByTenant.getOrDefault(tenantId, List.of()));
    }

    @Override
    public PackageRepositorySnapshot exportTenantSnapshot(String tenantId) {
      Map<String, PackageInstallationState> installedStates =
          new LinkedHashMap<>(statesByTenant.getOrDefault(tenantId, Map.of()));
      Map<String, List<PackageInstallationState>> rollbackStates = new LinkedHashMap<>();
      rollbackStatesByTenant.getOrDefault(tenantId, Map.of())
          .forEach((packageCode, states) -> rollbackStates.put(packageCode, List.copyOf(states)));
      List<PackageAuditEvent> auditEvents = List.copyOf(auditEventsByTenant.getOrDefault(tenantId, List.of()));
      return new PackageRepositorySnapshot(tenantId, installedStates, rollbackStates, auditEvents);
    }

    @Override
    public void importTenantSnapshot(PackageRepositorySnapshot snapshot) {
      statesByTenant.put(snapshot.tenantId(), new LinkedHashMap<>(snapshot.installedStates()));
      Map<String, List<PackageInstallationState>> rollbackStates = new LinkedHashMap<>();
      snapshot.rollbackStates().forEach((packageCode, states) -> rollbackStates.put(packageCode, new ArrayList<>(states)));
      rollbackStatesByTenant.put(snapshot.tenantId(), rollbackStates);
      auditEventsByTenant.put(snapshot.tenantId(), new ArrayList<>(snapshot.auditEvents()));
    }
  }

  public enum PackageInstallationStatus {
    ENABLED,
    DISABLED
  }

  public record PackageInstallationState(
      String tenantId,
      String packageCode,
      String version,
      String license,
      boolean runtimeEnabled,
      Map<String, String> dependencyVersions,
      PackageInstallationStatus status,
      String lastOperator,
      String lastTraceId,
      String installedAt) {

    public PackageInstallationState {
      dependencyVersions = Map.copyOf(dependencyVersions);
    }

    PackageInstallationState withStatus(PackageInstallationStatus targetStatus) {
      return new PackageInstallationState(
          tenantId,
          packageCode,
          version,
          license,
          runtimeEnabled,
          dependencyVersions,
          targetStatus,
          lastOperator,
          lastTraceId,
          installedAt);
    }

    PackageInstallationState withOperation(String operator, String traceId) {
      return new PackageInstallationState(
          tenantId,
          packageCode,
          version,
          license,
          runtimeEnabled,
          dependencyVersions,
          status,
          operator,
          traceId,
          installedAt);
    }
  }

  public record PackageInstallResult(
      boolean installed,
      PackageInstallationState state,
      ValidationReport report) {
  }

  public record PackageRepositorySnapshot(
      String tenantId,
      Map<String, PackageInstallationState> installedStates,
      Map<String, List<PackageInstallationState>> rollbackStates,
      List<PackageAuditEvent> auditEvents) {

    public PackageRepositorySnapshot {
      installedStates = Map.copyOf(installedStates);
      Map<String, List<PackageInstallationState>> copiedRollbackStates = new LinkedHashMap<>();
      rollbackStates.forEach((packageCode, states) -> copiedRollbackStates.put(packageCode, List.copyOf(states)));
      rollbackStates = Map.copyOf(copiedRollbackStates);
      auditEvents = List.copyOf(auditEvents);
    }
  }

  public record PackageUninstallDryRun(
      boolean allowed,
      String packageCode,
      PackageInstallationStatus status,
      List<String> blockingReasons) {
  }

  public record PackageUninstallResult(
      boolean uninstalled,
      String packageCode,
      PackageInstallationStatus previousStatus,
      List<String> blockingReasons) {
  }

  private record PackageUninstallCheck(
      PackageInstallationState state,
      List<String> blockingReasons) {
  }

  public record PackageAuditEvent(
      String tenantId,
      String packageCode,
      String operator,
      String traceId,
      String operation,
      String result,
      String details,
      String occurredAt) {
  }

  @FunctionalInterface
  public interface PackageCapabilityContextProvider {

    PackageManifestValidationContext resolve(String tenantId);
  }
}
