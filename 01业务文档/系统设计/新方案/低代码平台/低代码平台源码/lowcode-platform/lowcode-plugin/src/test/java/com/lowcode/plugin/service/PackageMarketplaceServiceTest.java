package com.lowcode.plugin.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.common.error.BizException;
import com.lowcode.metamodel.domain.def.PackageCompatibilityDef;
import com.lowcode.metamodel.domain.def.PackageDependencyDef;
import com.lowcode.metamodel.domain.def.PackageManifestDef;
import com.lowcode.metamodel.domain.service.PackageManifestValidationContext;
import com.lowcode.metamodel.domain.service.PackageManifestValidator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;

class PackageMarketplaceServiceTest {

  @Test
  void shouldInstallListDisableAndDryRunMarketplacePackage() {
    PackageMarketplaceService service = marketplaceService();
    PackageManifestValidationContext context = marketplaceContext();
    PackageManifestDef baseManifest =
        new PackageManifestDef(
            "base_pkg",
            "1.0.2",
            List.of(),
            "commercial",
            List.of("customer"),
            List.of(),
            List.of(),
            List.of(),
            List.of("customer:read"),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
            false);
    PackageManifestDef manifest =
        new PackageManifestDef(
            "customer_pkg",
            "1.0.0",
            List.of(new PackageDependencyDef("base_pkg", "1.0.0")),
            "commercial",
            List.of("customer"),
            List.of(),
            List.of(),
            List.of(),
            List.of("customer:read"),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
            true);

    assertThat(service.install("tenant-a", "package-admin", "trace-install-base", baseManifest, context).installed())
        .isTrue();

    PackageMarketplaceService.PackageInstallResult installResult =
        service.install(
            "tenant-a",
            "package-admin",
            "trace-install-1",
            manifest,
            context);

    assertThat(installResult.installed()).isTrue();
    assertThat(installResult.state()).isNotNull();
    assertThat(installResult.state().status()).isEqualTo(PackageMarketplaceService.PackageInstallationStatus.ENABLED);
    assertThat(service.listInstalled("tenant-a"))
        .extracting(PackageMarketplaceService.PackageInstallationState::packageCode)
        .containsExactly("base_pkg", "customer_pkg");

    PackageMarketplaceService.PackageInstallationState disabled =
        service.disable("tenant-a", "package-admin", "trace-disable-1", "customer_pkg");
    assertThat(disabled.status()).isEqualTo(PackageMarketplaceService.PackageInstallationStatus.DISABLED);

    PackageMarketplaceService.PackageUninstallDryRun dryRun = service.uninstallDryRun("tenant-a", "customer_pkg");
    assertThat(dryRun.allowed()).isTrue();
    assertThat(dryRun.status()).isEqualTo(PackageMarketplaceService.PackageInstallationStatus.DISABLED);
    assertThat(dryRun.blockingReasons()).isEmpty();

    PackageMarketplaceService.PackageUninstallDryRun baseDryRun = service.uninstallDryRun("tenant-a", "base_pkg");
    assertThat(baseDryRun.allowed()).isFalse();
    assertThat(baseDryRun.blockingReasons()).contains("仍被已安装应用包依赖：customer_pkg");
  }

  @Test
  void shouldRejectInstallWhenDependencyLicenseOrRuntimeConstraintsFail() {
    PackageMarketplaceService service = marketplaceService();
    PackageManifestDef baseManifest =
        new PackageManifestDef(
            "base_pkg",
            "1.0.0",
            List.of(),
            "commercial",
            List.of(),
            List.of(),
            List.of(),
            List.of(),
            List.of(),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
            false);
    PackageManifestValidationContext baseContext =
        new PackageManifestValidationContext(
            Map.of(),
            Set.of(),
            Set.of(),
            Set.of(),
            Set.of(),
            Set.of(),
            "1.1.0",
            "M4",
            Set.of("commercial"),
            true);
    assertThat(service.install("tenant-a", "package-admin", "trace-install-base", baseManifest, baseContext).installed())
        .isTrue();

    PackageManifestDef manifest =
        new PackageManifestDef(
            "customer_pkg",
            "2.0.0",
            List.of(new PackageDependencyDef("base_pkg", "2.0.0")),
            "enterprise",
            List.of(),
            List.of(),
            List.of(),
            List.of(),
            List.of(),
            new PackageCompatibilityDef("2.0.0", "2.1.x", "M5"),
            true);

    PackageMarketplaceService.PackageInstallResult installResult =
        service.install(
            "tenant-a",
            "package-admin",
            "trace-install-2",
            manifest,
            new PackageManifestValidationContext(
                Map.of("base_pkg", "1.0.0"),
                Set.of(),
                Set.of(),
                Set.of(),
                Set.of(),
                Set.of(),
                "1.1.0",
                "M4",
                Set.of("commercial"),
                false));

    assertThat(installResult.installed()).isFalse();
    assertThat(installResult.state()).isNull();
    assertThat(installResult.report().errors())
        .extracting(error -> error.code())
        .contains(
            "LC-META-PKG-012",
            "LC-META-PKG-013",
            "LC-META-PKG-014",
            "LC-META-PKG-015");
    assertThat(service.listInstalled("tenant-a"))
        .extracting(PackageMarketplaceService.PackageInstallationState::packageCode)
        .containsExactly("base_pkg");
    assertThat(service.auditEvents("tenant-a"))
        .extracting(PackageMarketplaceService.PackageAuditEvent::operation)
        .contains("INSTALL_REJECTED");
    assertThat(service.auditEvents("tenant-a"))
        .filteredOn(event -> event.operation().equals("INSTALL_REJECTED"))
        .singleElement()
        .satisfies(event -> {
          assertThat(event.packageCode()).isEqualTo("customer_pkg");
          assertThat(event.operator()).isEqualTo("package-admin");
          assertThat(event.traceId()).isEqualTo("trace-install-2");
          assertThat(event.result()).isEqualTo("REJECTED");
          assertThat(event.details()).contains("LC-META-PKG-012");
        });
  }

  @Test
  void shouldFailClosedWhenTrustedCapabilityContextIsMissing() {
    PackageMarketplaceService service = new PackageMarketplaceService();

    PackageMarketplaceService.PackageInstallResult installResult =
        service.install(
            "tenant-a",
            "package-admin",
            "trace-missing-context",
            marketplaceManifest("customer_pkg", "1.0.0"),
            null);

    assertThat(installResult.installed()).isFalse();
    assertThat(installResult.report().errors())
        .extracting(error -> error.code())
        .contains(
            "LC-META-PKG-007",
            "LC-META-PKG-011",
            "LC-META-PKG-015");
  }

  @Test
  void shouldRejectUpgradeWhenTrustedCapabilityContextIsMissing() {
    PackageMarketplaceService.InMemoryPackageInstallationRepository repository =
        new PackageMarketplaceService.InMemoryPackageInstallationRepository();
    repository.save(
        new PackageMarketplaceService.PackageInstallationState(
            "tenant-a",
            "customer_pkg",
            "1.0.0",
            "commercial",
            true,
            Map.of(),
            PackageMarketplaceService.PackageInstallationStatus.ENABLED,
            "seed-user",
            "seed-trace",
            "2026-07-07T00:00:00Z"));
    PackageMarketplaceService service =
        new PackageMarketplaceService(repository, new PackageManifestValidator());

    assertThatThrownBy(() ->
        service.upgrade(
            "tenant-a",
            "package-admin",
            "trace-upgrade-missing-context",
            marketplaceManifest("customer_pkg", "1.1.0"),
            null))
        .isInstanceOf(BizException.class)
        .hasMessageContaining("应用包升级校验失败");
  }

  @Test
  void shouldDeriveInstalledDependenciesFromServerStateAndAvoidSilentOverwrite() {
    PackageMarketplaceService service = marketplaceService();
    PackageManifestDef baseManifest =
        new PackageManifestDef(
            "base_pkg",
            "1.0.2",
            List.of(),
            "commercial",
            List.of("customer"),
            List.of(),
            List.of(),
            List.of(),
            List.of("customer:read"),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
            false);
    PackageManifestValidationContext context = marketplaceContext();

    assertThat(service.install("tenant-a", "package-admin", "trace-base", baseManifest, context).installed())
        .isTrue();

    PackageManifestDef dependentManifest =
        new PackageManifestDef(
            "customer_pkg",
            "1.0.0",
            List.of(new PackageDependencyDef("base_pkg", "1.0.0")),
            "commercial",
            List.of("customer"),
            List.of(),
            List.of(),
            List.of(),
            List.of("customer:read"),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
            true);

    assertThat(service.install("tenant-a", "package-admin", "trace-dependent", dependentManifest, context).installed())
        .isTrue();

    PackageMarketplaceService.PackageInstallResult replay =
        service.install("tenant-a", "package-admin", "trace-replay", dependentManifest, context);
    assertThat(replay.installed()).isTrue();
    assertThat(replay.state().version()).isEqualTo("1.0.0");

    PackageManifestDef overwriteAttempt =
        new PackageManifestDef(
            "customer_pkg",
            "2.0.0",
            List.of(new PackageDependencyDef("base_pkg", "1.0.0")),
            "commercial",
            List.of("customer"),
            List.of(),
            List.of(),
            List.of(),
            List.of("customer:read"),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
            true);

    PackageMarketplaceService.PackageInstallResult overwriteResult =
        service.install("tenant-a", "package-admin", "trace-overwrite", overwriteAttempt, context);

    assertThat(overwriteResult.installed()).isFalse();
    assertThat(overwriteResult.report().errors())
        .extracting(error -> error.code())
        .contains("LC-PKG-INSTALL-001");
    assertThat(service.listInstalled("tenant-a"))
        .filteredOn(state -> state.packageCode().equals("customer_pkg"))
        .singleElement()
        .extracting(PackageMarketplaceService.PackageInstallationState::version)
        .isEqualTo("1.0.0");
  }

  @Test
  void shouldUpgradeAndRollbackInstalledPackageWithVersionAudit() {
    PackageMarketplaceService service = marketplaceService();
    PackageManifestValidationContext context = marketplaceContext();
    PackageManifestDef manifest =
        new PackageManifestDef(
            "customer_pkg",
            "1.0.0",
            List.of(),
            "commercial",
            List.of("customer"),
            List.of(),
            List.of(),
            List.of(),
            List.of("customer:read"),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
            true);
    PackageManifestDef upgradedManifest =
        new PackageManifestDef(
            "customer_pkg",
            "1.1.0",
            List.of(),
            "commercial",
            List.of("customer"),
            List.of(),
            List.of(),
            List.of(),
            List.of("customer:read"),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
            true);

    assertThat(service.install("tenant-a", "package-admin", "trace-install", manifest, context).installed())
        .isTrue();
    PackageMarketplaceService.PackageInstallationState upgraded =
        service.upgrade("tenant-a", "package-admin", "trace-upgrade", upgradedManifest, context);
    PackageMarketplaceService.PackageInstallationState rolledBack =
        service.rollback("tenant-a", "package-admin", "trace-rollback", "customer_pkg");

    assertThat(upgraded.version()).isEqualTo("1.1.0");
    assertThat(rolledBack.version()).isEqualTo("1.0.0");
    assertThat(service.auditEvents("tenant-a"))
        .extracting(PackageMarketplaceService.PackageAuditEvent::operation)
        .containsExactly("INSTALL_SUCCEEDED", "UPGRADED", "ROLLED_BACK");
    assertThat(service.auditEvents("tenant-a"))
        .filteredOn(event -> event.operation().equals("UPGRADED"))
        .singleElement()
        .satisfies(event -> {
          assertThat(event.traceId()).isEqualTo("trace-upgrade");
          assertThat(event.details()).isEqualTo("1.0.0->1.1.0");
        });
    assertThat(service.auditEvents("tenant-a"))
        .filteredOn(event -> event.operation().equals("ROLLED_BACK"))
        .singleElement()
        .satisfies(event -> {
          assertThat(event.traceId()).isEqualTo("trace-rollback");
          assertThat(event.details()).isEqualTo("1.1.0->1.0.0");
        });
  }

  @Test
  void shouldRollbackUpgradeStackOneVersionAtATimeAfterMultipleUpgrades() {
    PackageMarketplaceService service = marketplaceService();
    PackageManifestValidationContext context = marketplaceContext();

    assertThat(service.install(
            "tenant-a",
            "package-admin",
            "trace-install",
            marketplaceManifest("customer_pkg", "1.0.0"),
            context)
        .installed())
        .isTrue();
    service.upgrade(
        "tenant-a",
        "package-admin",
        "trace-upgrade-1",
        marketplaceManifest("customer_pkg", "1.1.0"),
        context);
    service.upgrade(
        "tenant-a",
        "package-admin",
        "trace-upgrade-2",
        marketplaceManifest("customer_pkg", "1.2.0"),
        context);

    PackageMarketplaceService.PackageInstallationState firstRollback =
        service.rollback("tenant-a", "package-admin", "trace-rollback-1", "customer_pkg");
    PackageMarketplaceService.PackageInstallationState secondRollback =
        service.rollback("tenant-a", "package-admin", "trace-rollback-2", "customer_pkg");

    assertThat(firstRollback.version()).isEqualTo("1.1.0");
    assertThat(secondRollback.version()).isEqualTo("1.0.0");
    assertThat(firstRollback.status()).isEqualTo(PackageMarketplaceService.PackageInstallationStatus.ENABLED);
    assertThat(secondRollback.status()).isEqualTo(PackageMarketplaceService.PackageInstallationStatus.ENABLED);
    assertThat(service.auditEvents("tenant-a"))
        .extracting(PackageMarketplaceService.PackageAuditEvent::operation)
        .containsExactly(
            "INSTALL_SUCCEEDED",
            "UPGRADED",
            "UPGRADED",
            "ROLLED_BACK",
            "ROLLED_BACK");
    assertThat(service.auditEvents("tenant-a"))
        .extracting(PackageMarketplaceService.PackageAuditEvent::details)
        .contains(
            "1.0.0->1.1.0",
            "1.1.0->1.2.0",
            "1.2.0->1.1.0",
            "1.1.0->1.0.0");
  }

  @Test
  void shouldRestoreInstalledStateRollbackStackAndAuditTrailFromRepositorySnapshot() {
    PackageMarketplaceService.InMemoryPackageInstallationRepository repository =
        new PackageMarketplaceService.InMemoryPackageInstallationRepository();
    PackageMarketplaceService service =
        new PackageMarketplaceService(
            repository,
            new PackageManifestValidator(),
            tenantId -> marketplaceContext());
    PackageManifestValidationContext context = marketplaceContext();

    assertThat(service.install(
            "tenant-a",
            "package-admin",
            "trace-install",
            marketplaceManifest("customer_pkg", "1.0.0"),
            context)
        .installed())
        .isTrue();
    service.upgrade(
        "tenant-a",
        "package-admin",
        "trace-upgrade",
        marketplaceManifest("customer_pkg", "1.1.0"),
        context);
    service.disable("tenant-a", "package-admin", "trace-disable", "customer_pkg");

    PackageMarketplaceService.PackageRepositorySnapshot snapshot =
        repository.exportTenantSnapshot("tenant-a");

    PackageMarketplaceService.InMemoryPackageInstallationRepository restoredRepository =
        new PackageMarketplaceService.InMemoryPackageInstallationRepository();
    restoredRepository.importTenantSnapshot(snapshot);
    PackageMarketplaceService restoredService =
        new PackageMarketplaceService(restoredRepository, new PackageManifestValidator());

    assertThat(restoredService.listInstalled("tenant-a"))
        .singleElement()
        .satisfies(state -> {
          assertThat(state.packageCode()).isEqualTo("customer_pkg");
          assertThat(state.version()).isEqualTo("1.1.0");
          assertThat(state.status()).isEqualTo(PackageMarketplaceService.PackageInstallationStatus.DISABLED);
        });
    assertThat(restoredService.auditEvents("tenant-a"))
        .extracting(PackageMarketplaceService.PackageAuditEvent::operation)
        .containsExactly("INSTALL_SUCCEEDED", "UPGRADED", "DISABLED");

    PackageMarketplaceService.PackageInstallationState rolledBack =
        restoredService.rollback("tenant-a", "package-admin", "trace-rollback", "customer_pkg");

    assertThat(rolledBack.version()).isEqualTo("1.0.0");
    assertThat(rolledBack.status()).isEqualTo(PackageMarketplaceService.PackageInstallationStatus.ENABLED);
    assertThat(restoredService.auditEvents("tenant-a"))
        .extracting(PackageMarketplaceService.PackageAuditEvent::operation)
        .containsExactly("INSTALL_SUCCEEDED", "UPGRADED", "DISABLED", "ROLLED_BACK");
  }

  @Test
  void shouldOnlyBlockUninstallWhenPackageIsDeclaredDependency() {
    PackageMarketplaceService service = marketplaceService();
    PackageManifestValidationContext context = marketplaceContext();
    PackageManifestDef baseManifest =
        new PackageManifestDef(
            "base_pkg",
            "1.0.2",
            List.of(),
            "commercial",
            List.of("customer"),
            List.of(),
            List.of(),
            List.of(),
            List.of("customer:read"),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
            false);
    PackageManifestDef unrelatedManifest =
        new PackageManifestDef(
            "unrelated_pkg",
            "1.0.0",
            List.of(),
            "commercial",
            List.of("customer"),
            List.of(),
            List.of(),
            List.of(),
            List.of("customer:read"),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
            false);

    assertThat(service.install("tenant-a", "package-admin", "trace-base", baseManifest, context).installed())
        .isTrue();
    assertThat(service.install("tenant-a", "package-admin", "trace-unrelated", unrelatedManifest, context).installed())
        .isTrue();
    service.disable("tenant-a", "package-admin", "trace-disable-base", "base_pkg");

    PackageMarketplaceService.PackageUninstallDryRun dryRun = service.uninstallDryRun("tenant-a", "base_pkg");

    assertThat(dryRun.allowed()).isTrue();
    assertThat(dryRun.blockingReasons()).isEmpty();
  }

  @Test
  void shouldUninstallDisabledPackageAndKeepAuditTrail() {
    PackageMarketplaceService service = marketplaceService();
    PackageManifestValidationContext context = marketplaceContext();
    PackageManifestDef manifest =
        new PackageManifestDef(
            "customer_pkg",
            "1.0.0",
            List.of(),
            "commercial",
            List.of("customer"),
            List.of(),
            List.of(),
            List.of(),
            List.of("customer:read"),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
            true);

    service.install("tenant-a", "package-admin", "trace-install", manifest, context);
    PackageMarketplaceService.PackageUninstallResult blocked =
        service.uninstall("tenant-a", "package-admin", "trace-uninstall-blocked", "customer_pkg");
    service.disable("tenant-a", "package-admin", "trace-disable", "customer_pkg");
    PackageMarketplaceService.PackageUninstallResult uninstalled =
        service.uninstall("tenant-a", "package-admin", "trace-uninstall", "customer_pkg");

    assertThat(blocked.uninstalled()).isFalse();
    assertThat(blocked.blockingReasons()).contains("应用包仍处于启用状态，请先禁用");
    assertThat(uninstalled.uninstalled()).isTrue();
    assertThat(uninstalled.blockingReasons()).isEmpty();
    assertThat(service.listInstalled("tenant-a")).isEmpty();
    assertThat(service.auditEvents("tenant-a"))
        .extracting(PackageMarketplaceService.PackageAuditEvent::operation)
        .containsExactly("INSTALL_SUCCEEDED", "UNINSTALL_BLOCKED", "DISABLED", "UNINSTALLED");
  }

  @Test
  void shouldRecordLifecycleAuditEventsForInstallEnableDisableAndUninstallDryRun() {
    PackageMarketplaceService service = marketplaceService();
    PackageManifestValidationContext context = marketplaceContext();
    PackageManifestDef manifest =
        new PackageManifestDef(
            "customer_pkg",
            "1.0.0",
            List.of(),
            "commercial",
            List.of("customer"),
            List.of(),
            List.of(),
            List.of(),
            List.of("customer:read"),
            new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
            true);

    service.install("tenant-a", "package-admin", "trace-install", manifest, context);
    service.disable("tenant-a", "package-admin", "trace-disable", "customer_pkg");
    PackageMarketplaceService.PackageInstallationState enabled =
        service.enable("tenant-a", "package-admin", "trace-enable", "customer_pkg");
    service.uninstallDryRun("tenant-a", "package-admin", "trace-dry-run", "customer_pkg");

    assertThat(enabled.status()).isEqualTo(PackageMarketplaceService.PackageInstallationStatus.ENABLED);
    assertThat(service.auditEvents("tenant-a"))
        .extracting(PackageMarketplaceService.PackageAuditEvent::operation)
        .containsExactly("INSTALL_SUCCEEDED", "DISABLED", "ENABLED", "UNINSTALL_DRY_RUN_BLOCKED");
    assertThat(service.auditEvents("tenant-a"))
        .allSatisfy(event -> {
          assertThat(event.tenantId()).isEqualTo("tenant-a");
          assertThat(event.packageCode()).isEqualTo("customer_pkg");
          assertThat(event.operator()).isEqualTo("package-admin");
          assertThat(event.traceId()).startsWith("trace-");
        });
  }

  private static PackageManifestValidationContext marketplaceContext() {
    return new PackageManifestValidationContext(
        Map.of(),
        Set.of("customer"),
        Set.of(),
        Set.of(),
        Set.of(),
        Set.of("customer:read"),
        "1.2.0",
        "M4",
        Set.of("commercial"),
        true);
  }

  private static PackageMarketplaceService marketplaceService() {
    return new PackageMarketplaceService(
        new PackageMarketplaceService.InMemoryPackageInstallationRepository(),
        new PackageManifestValidator(),
        tenantId -> marketplaceContext());
  }

  private static PackageManifestDef marketplaceManifest(String packageCode, String version) {
    return new PackageManifestDef(
        packageCode,
        version,
        List.of(),
        "commercial",
        List.of("customer"),
        List.of(),
        List.of(),
        List.of(),
        List.of("customer:read"),
        new PackageCompatibilityDef("1.0.0", "1.2.x", "M4"),
        true);
  }
}
