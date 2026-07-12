package com.lowcode.plugin.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.net.URI;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;

class PluginCommercialServiceTest {

  @Test
  void shouldVerifyPluginLifecycleAndBlockUnsafeConnectorUrl() {
    PluginLifecycleService pluginService = new PluginLifecycleService("trusted-public-key");
    PluginManifest manifest = new PluginManifest("crm-fields", "1.0.0", "trusted-public-key", "signature-ok");

    pluginService.install(manifest);
    pluginService.enable("crm-fields");
    pluginService.disable("crm-fields");

    assertThat(pluginService.plugin("crm-fields").status()).isEqualTo(PluginStatus.DISABLED);
    assertThatThrownBy(() -> new ConnectorUrlGuard().validate(URI.create("http://169.254.169.254/latest/meta-data")))
        .isInstanceOf(PluginSecurityException.class)
        .hasMessageContaining("禁止访问云厂商 metadata");
  }

  @Test
  void shouldUpgradeRollbackAndUninstallPluginLifecycle() {
    PluginLifecycleService pluginService = new PluginLifecycleService("trusted-public-key");
    pluginService.install(new PluginManifest("crm-fields", "1.0.0", "trusted-public-key", "signature-ok"));
    pluginService.enable("crm-fields");

    pluginService.upgrade(new PluginManifest("crm-fields", "1.1.0", "trusted-public-key", "signature-ok"));
    assertThat(pluginService.plugin("crm-fields").version()).isEqualTo("1.1.0");
    assertThat(pluginService.plugin("crm-fields").status()).isEqualTo(PluginStatus.ENABLED);

    pluginService.rollback("crm-fields");
    assertThat(pluginService.plugin("crm-fields").version()).isEqualTo("1.0.0");
    assertThat(pluginService.plugin("crm-fields").status()).isEqualTo(PluginStatus.ENABLED);

    pluginService.uninstall("crm-fields");
    assertThat(pluginService.plugin("crm-fields").status()).isEqualTo(PluginStatus.UNINSTALLED);
  }

  @Test
  void shouldProtectPackageSecretsAndLicenseQuota() {
    AppPackageSecurityScanner scanner = new AppPackageSecurityScanner();
    assertThatThrownBy(() -> scanner.scan(new AppPackageManifest(
            "pkg-1",
            Map.of("apiToken", "secret-token"),
            Map.of())))
        .isInstanceOf(PluginSecurityException.class)
        .hasMessageContaining("应用包不能包含密钥");

    LicensePolicy policy = new LicensePolicy("offline-basic", 2, LocalDate.now().plusDays(30));
    assertThat(policy.allowObjectCount(2)).isTrue();
    assertThat(policy.allowObjectCount(3)).isFalse();
  }

  @Test
  void shouldImportPackageIdempotentlyValidateNotificationAndProducePrivateDeploymentReport() {
    AppPackageImportService importService = new AppPackageImportService();
    AppPackageManifest manifest = new AppPackageManifest(
        "crm-template",
        Map.of("edition", "basic"),
        Map.of("customer", "hash-1"));

    PackageImportResult first = importService.importCommit(manifest, "idem-1");
    PackageImportResult replay = importService.importCommit(manifest, "idem-1");

    assertThat(replay.importId()).isEqualTo(first.importId());
    assertThat(replay.createdObjects()).containsExactly("customer");

    NotificationTemplateGuard guard = new NotificationTemplateGuard();
    assertThatThrownBy(() -> guard.validate("order", "金额 ${secret_amount}", Map.of("amount", true, "secret_amount", false)))
        .isInstanceOf(PluginSecurityException.class)
        .hasMessageContaining("通知模板引用无权限字段");

    PrivateDeploymentReport report = PrivateDeploymentReport.generate(true, true, true, true);
    assertThat(report.ready()).isTrue();
    assertThat(report.items()).contains("备份恢复演练已完成", "指标上报关闭验收已完成", "插件失败回滚演练已完成");
  }

  @Test
  void shouldEnforceConnectorLimitsNotificationDeadLetterWebhookSignatureAndApiTokenScope() {
    ConnectorPolicyGuard connector = new ConnectorPolicyGuard(1000, 1024, 10);
    assertThatThrownBy(() -> connector.validate(new ConnectorInvocation("https://example.com/orders", 1500, 512, 1)))
        .isInstanceOf(PluginSecurityException.class)
        .hasMessageContaining("Connector 超时超过上限");
    assertThatThrownBy(() -> connector.validate(new ConnectorInvocation("https://example.com/orders", 100, 2048, 1)))
        .isInstanceOf(PluginSecurityException.class)
        .hasMessageContaining("Connector 响应大小超过上限");

    NotificationDeliveryService notification = new NotificationDeliveryService(2);
    notification.send("tenant-1:order-1:approve", false);
    notification.send("tenant-1:order-1:approve", false);
    notification.send("tenant-1:order-1:approve", false);
    notification.send("tenant-1:order-1:approve", true);

    assertThat(notification.deadLetters()).containsExactly("tenant-1:order-1:approve");
    assertThat(notification.sentKeys()).isEmpty();

    WebhookDeliveryService webhook = new WebhookDeliveryService("secret");
    assertThatThrownBy(() -> webhook.deliver(new WebhookRequest("event-1", "payload", "bad-signature")))
        .isInstanceOf(PluginSecurityException.class)
        .hasMessageContaining("Webhook 签名不合法");
    webhook.deliver(new WebhookRequest("event-1", "payload", "sig-secret-payload"));
    webhook.deliver(new WebhookRequest("event-1", "payload", "sig-secret-payload"));
    assertThat(webhook.deliveredEventIds()).containsExactly("event-1");

    ApiTokenScopeGuard tokenScope = new ApiTokenScopeGuard();
    assertThat(tokenScope.effectiveScopes(
        java.util.Set.of("record:read", "record:update"),
        java.util.Set.of("record:read", "record:delete"))).containsExactly("record:read");
  }

  @Test
  void shouldAuditLifecycleResolveDependenciesAndKeepTenantIsolation() {
    PluginLifecycleService pluginService = new PluginLifecycleService("trusted-public-key", "M1");
    PluginManifest dependency = new PluginManifest(
        "tenant-a-crm-base",
        "1.0.0",
        "trusted-public-key",
        "signature-ok",
        true,
        "tenanta.crm.base",
        false,
        false,
        Map.of("apiToken", "tenant-a-token"),
        List.of(),
        new CompatibilityRange("1.0.0", "1.2.x"),
        new LicensePlan("pro", "read_only", true),
        true);
    PluginManifest extension = new PluginManifest(
        "tenant-a-crm-ext",
        "1.1.0",
        "trusted-public-key",
        "signature-ok",
        true,
        "tenanta.crm.ext",
        false,
        false,
        Map.of("password", "tenant-a-password"),
        List.of(new PluginDependency("tenant-a-crm-base", "1.0.0")),
        new CompatibilityRange("1.0.0", "1.2.x"),
        new LicensePlan("enterprise", "read_only", true),
        true);

    pluginService.install("tenant-a", "admin-a", "trace-1", dependency);
    pluginService.install("tenant-a", "admin-a", "trace-2", extension);
    pluginService.enable("tenant-a", "admin-a", "trace-3", "tenant-a-crm-ext");
    pluginService.disable("tenant-a", "admin-a", "trace-4", "tenant-a-crm-ext");

    assertThat(pluginService.plugin("tenant-a", "tenant-a-crm-ext").status()).isEqualTo(PluginStatus.DISABLED);
    assertThat(pluginService.plugin("tenant-a", "tenant-a-crm-ext").sanitizedConfig())
        .containsEntry("password", "******");
    assertThat(pluginService.auditLog("tenant-a"))
        .extracting(PluginAuditRecord::action)
        .containsExactly("install", "install", "enable", "disable");
    assertThatThrownBy(() -> pluginService.plugin("tenant-b", "tenant-a-crm-ext"))
        .isInstanceOf(PluginSecurityException.class)
        .hasMessageContaining("插件不存在");
  }

  @Test
  void shouldBlockUnsafeManifestDependencyAndBackendEntry() {
    PluginLifecycleService pluginService = new PluginLifecycleService("trusted-public-key", "M1");

    assertThatThrownBy(() -> pluginService.install("tenant-a", "admin", "trace-1", new PluginManifest(
            "unsafe-backend",
            "1.0.0",
            "trusted-public-key",
            "signature-ok",
            true,
            "tenantA.unsafe.backend",
            true,
            false,
            Map.of(),
            List.of(),
            new CompatibilityRange("1.0.0", "1.2.x"),
            new LicensePlan("pro", "read_only", true),
            true)))
        .isInstanceOf(PluginSecurityException.class)
        .hasMessageContaining("M0/M1 默认拒绝后端代码");

    assertThatThrownBy(() -> pluginService.install("tenant-a", "admin", "trace-2", new PluginManifest(
            "bad-namespace",
            "1.0.0",
            "trusted-public-key",
            "signature-ok",
            true,
            "globalAction",
            false,
            false,
            Map.of(),
            List.of(),
            new CompatibilityRange("1.0.0", "1.2.x"),
            new LicensePlan("pro", "read_only", true),
            true)))
        .isInstanceOf(PluginSecurityException.class)
        .hasMessageContaining("扩展点命名空间不合法");

    assertThatThrownBy(() -> pluginService.install("tenant-a", "admin", "trace-3", new PluginManifest(
            "missing-dependency",
            "1.0.0",
            "trusted-public-key",
            "signature-ok",
            true,
            "tenanta.crm.missing",
            false,
            false,
            Map.of(),
            List.of(new PluginDependency("not-installed", "1.0.0")),
            new CompatibilityRange("1.0.0", "1.2.x"),
            new LicensePlan("pro", "read_only", true),
            true)))
        .isInstanceOf(PluginSecurityException.class)
        .hasMessageContaining("缺失依赖");
  }

  @Test
  void shouldRollbackFailedUpgradeAndKeepPreviousVersionEnabled() {
    PluginLifecycleService pluginService = new PluginLifecycleService("trusted-public-key", "M1");
    PluginManifest installed = new PluginManifest(
        "crm-plus",
        "1.0.0",
        "trusted-public-key",
        "signature-ok",
        true,
        "tenanta.crm.plus",
        false,
        false,
        Map.of(),
        List.of(),
        new CompatibilityRange("1.0.0", "1.2.x"),
        new LicensePlan("enterprise", "read_only", true),
        true);
    pluginService.install("tenant-a", "admin", "trace-1", installed);
    pluginService.enable("tenant-a", "admin", "trace-2", "crm-plus");

    PluginManifest incompatible = new PluginManifest(
        "crm-plus",
        "2.0.0",
        "trusted-public-key",
        "signature-ok",
        true,
        "tenanta.crm.plus",
        false,
        false,
        Map.of(),
        List.of(),
        new CompatibilityRange("2.0.0", "2.0.x"),
        new LicensePlan("enterprise", "read_only", true),
        true);

    assertThatThrownBy(() -> pluginService.upgrade("tenant-a", "admin", "trace-3", incompatible, "1.1.0"))
        .isInstanceOf(PluginSecurityException.class)
        .hasMessageContaining("平台版本不兼容");

    assertThat(pluginService.plugin("tenant-a", "crm-plus").version()).isEqualTo("1.0.0");
    assertThat(pluginService.plugin("tenant-a", "crm-plus").status()).isEqualTo(PluginStatus.ENABLED);
    assertThat(pluginService.auditLog("tenant-a"))
        .extracting(PluginAuditRecord::action)
        .contains("upgrade_failed", "rollback");
  }

  @Test
  void shouldApplyLicenseDegradeAndBlockUnsafeUninstall() {
    PluginLifecycleService pluginService = new PluginLifecycleService("trusted-public-key", "M1");
    PluginManifest manifest = new PluginManifest(
        "crm-license",
        "1.0.0",
        "trusted-public-key",
        "signature-ok",
        true,
        "tenanta.crm.license",
        false,
        true,
        Map.of("secretKey", "tenant-a-secret"),
        List.of(),
        new CompatibilityRange("1.0.0", "1.2.x"),
        new LicensePlan("enterprise", "read_only", true),
        true);

    pluginService.install("tenant-a", "admin", "trace-1", manifest);
    pluginService.enable("tenant-a", "admin", "trace-2", "crm-license");
    pluginService.applyLicensePolicy("tenant-a", "admin", "trace-3", "crm-license", false);

    assertThat(pluginService.plugin("tenant-a", "crm-license").status()).isEqualTo(PluginStatus.DEGRADED);
    assertThat(pluginService.plugin("tenant-a", "crm-license").dataRetentionMode()).isEqualTo("retain_read_only");

    assertThatThrownBy(() -> pluginService.uninstall("tenant-a", "admin", "trace-4", "crm-license", false))
        .isInstanceOf(PluginSecurityException.class)
        .hasMessageContaining("卸载预检失败");

    pluginService.uninstall("tenant-a", "admin", "trace-5", "crm-license", true);
    assertThat(pluginService.plugin("tenant-a", "crm-license").status()).isEqualTo(PluginStatus.UNINSTALLED);
    assertThat(pluginService.plugin("tenant-a", "crm-license").dataRetentionMode()).isEqualTo("retain_read_only");
  }
}
