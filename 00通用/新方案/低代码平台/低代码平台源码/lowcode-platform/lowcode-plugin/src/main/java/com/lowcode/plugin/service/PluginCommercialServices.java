package com.lowcode.plugin.service;

import java.net.InetAddress;
import java.net.URI;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

/**
 * M4/M5 插件、应用包和 License 商用生命周期最小内核。
 */
class PluginLifecycleService {

  private final String trustedPublicKey;
  private final String platformStage;
  private final Map<String, Map<String, PluginRuntime>> pluginsByTenant = new LinkedHashMap<>();
  private final Map<String, List<PluginAuditRecord>> auditLogs = new LinkedHashMap<>();

  PluginLifecycleService(String trustedPublicKey) {
    this(trustedPublicKey, "M3");
  }

  PluginLifecycleService(String trustedPublicKey, String platformStage) {
    this.trustedPublicKey = trustedPublicKey;
    this.platformStage = platformStage;
  }

  void install(PluginManifest manifest) {
    verifyManifest(manifest, null);
    Map<String, PluginRuntime> tenantPlugins = tenantPlugins("global");
    tenantPlugins.put(manifest.code(), PluginRuntime.from("global", manifest, PluginStatus.INSTALLED, null));
  }

  void install(String tenantId, String operator, String traceId, PluginManifest manifest) {
    verifyManifest(manifest, tenantId);
    Map<String, PluginRuntime> tenantPlugins = tenantPlugins(tenantId);
    PluginRuntime runtime = PluginRuntime.from(tenantId, manifest, PluginStatus.INSTALLED, null);
    tenantPlugins.put(manifest.code(), runtime);
    appendAudit(tenantId, new PluginAuditRecord(manifest.code(), null, manifest.version(), operator, traceId, "install", "SUCCESS"));
  }

  void enable(String code) {
    Map<String, PluginRuntime> tenantPlugins = tenantPlugins("global");
    tenantPlugins.put(code, plugin(code).withStatus(PluginStatus.ENABLED));
  }

  void enable(String tenantId, String operator, String traceId, String code) {
    PluginRuntime runtime = plugin(tenantId, code);
    tenantPlugins(tenantId).put(code, runtime.withStatus(PluginStatus.ENABLED));
    appendAudit(tenantId, new PluginAuditRecord(code, runtime.version(), runtime.version(), operator, traceId, "enable", "SUCCESS"));
  }

  void disable(String code) {
    Map<String, PluginRuntime> tenantPlugins = tenantPlugins("global");
    tenantPlugins.put(code, plugin(code).withStatus(PluginStatus.DISABLED));
  }

  void disable(String tenantId, String operator, String traceId, String code) {
    PluginRuntime runtime = plugin(tenantId, code);
    tenantPlugins(tenantId).put(code, runtime.withStatus(PluginStatus.DISABLED));
    appendAudit(tenantId, new PluginAuditRecord(code, runtime.version(), runtime.version(), operator, traceId, "disable", "SUCCESS"));
  }

  void upgrade(PluginManifest manifest) {
    verifyManifest(manifest, null);
    PluginRuntime runtime = plugin(manifest.code());
    tenantPlugins("global").put(manifest.code(), runtime.upgradeTo(manifest));
  }

  void upgrade(String tenantId, String operator, String traceId, PluginManifest manifest, String currentPlatformVersion) {
    PluginRuntime runtime = plugin(tenantId, manifest.code());
    try {
      verifyManifest(manifest, tenantId);
      verifyCompatibility(manifest.compatibility(), currentPlatformVersion);
      PluginRuntime upgraded = runtime.upgradeTo(manifest);
      tenantPlugins(tenantId).put(manifest.code(), upgraded);
      appendAudit(tenantId, new PluginAuditRecord(manifest.code(), runtime.version(), manifest.version(), operator, traceId, "upgrade", "SUCCESS"));
    } catch (RuntimeException ex) {
      appendAudit(tenantId, new PluginAuditRecord(manifest.code(), runtime.version(), manifest.version(), operator, traceId, "upgrade_failed", "FAILED"));
      tenantPlugins(tenantId).put(manifest.code(), runtime.rollbackUpgradeFailure());
      appendAudit(tenantId, new PluginAuditRecord(manifest.code(), manifest.version(), runtime.version(), operator, traceId, "rollback", "SUCCESS"));
      throw ex;
    }
  }

  void rollback(String code) {
    PluginRuntime runtime = plugin(code);
    if (runtime.previousVersion() == null) {
      throw new PluginSecurityException("插件没有可回滚版本");
    }
    tenantPlugins("global").put(code, runtime.rollbackVersion());
  }

  void uninstall(String code) {
    PluginRuntime runtime = plugin(code);
    tenantPlugins("global").put(code, runtime.withStatus(PluginStatus.UNINSTALLED));
  }

  void uninstall(String tenantId, String operator, String traceId, String code, boolean preserveData) {
    PluginRuntime runtime = plugin(tenantId, code);
    if (!preserveData && runtime.manifest().hasBusinessData()) {
      throw new PluginSecurityException("卸载预检失败");
    }
    tenantPlugins(tenantId).put(code, runtime.uninstallPreservingData());
    appendAudit(tenantId, new PluginAuditRecord(code, runtime.version(), runtime.version(), operator, traceId, "uninstall", "SUCCESS"));
  }

  void applyLicensePolicy(String tenantId, String operator, String traceId, String code, boolean active) {
    PluginRuntime runtime = plugin(tenantId, code);
    if (active) {
      return;
    }
    PluginRuntime degraded = runtime.withStatus(PluginStatus.DEGRADED)
        .withLicenseDegraded(true)
        .withDataRetentionMode("retain_" + runtime.manifest().licensePlan().degradeMode());
    tenantPlugins(tenantId).put(code, degraded);
    appendAudit(tenantId, new PluginAuditRecord(code, runtime.version(), runtime.version(), operator, traceId, "license_degrade", "SUCCESS"));
  }

  PluginRuntime plugin(String code) {
    PluginRuntime runtime = tenantPlugins("global").get(code);
    if (runtime == null) {
      throw new PluginSecurityException("插件不存在");
    }
    return runtime;
  }

  PluginRuntime plugin(String tenantId, String code) {
    PluginRuntime runtime = tenantPlugins(tenantId).get(code);
    if (runtime == null) {
      throw new PluginSecurityException("插件不存在");
    }
    return runtime;
  }

  List<PluginAuditRecord> auditLog(String tenantId) {
    return List.copyOf(auditLogs.getOrDefault(tenantId, List.of()));
  }

  private Map<String, PluginRuntime> tenantPlugins(String tenantId) {
    return pluginsByTenant.computeIfAbsent(tenantId, ignored -> new LinkedHashMap<>());
  }

  private void verifyManifest(PluginManifest manifest, String tenantId) {
    if (!trustedPublicKey.equals(manifest.publicKey()) || !"signature-ok".equals(manifest.signature())) {
      throw new PluginSecurityException("插件签名不合法");
    }
    if (!manifest.signaturePlaceholderPresent()) {
      throw new PluginSecurityException("插件签名占位缺失");
    }
    if (isLegacyStage() && manifest.backendCodeIncluded()) {
      throw new PluginSecurityException("M0/M1 默认拒绝后端代码");
    }
    if (!manifest.extensionNamespace().contains(".")) {
      throw new PluginSecurityException("扩展点命名空间不合法");
    }
    if (tenantId != null && !manifest.extensionNamespace().startsWith(namespacePrefix(tenantId))) {
      throw new PluginSecurityException("扩展点命名空间不合法");
    }
    if (tenantId != null) {
      for (PluginDependency dependency : manifest.dependencies()) {
        PluginRuntime dependencyRuntime = tenantPlugins(tenantId).get(dependency.pluginCode());
        if (dependencyRuntime == null || !dependencyRuntime.version().equals(dependency.requiredVersion())) {
          throw new PluginSecurityException("缺失依赖");
        }
      }
    }
  }

  private void verifyCompatibility(CompatibilityRange compatibility, String currentPlatformVersion) {
    if (!compatibility.includes(currentPlatformVersion)) {
      throw new PluginSecurityException("平台版本不兼容");
    }
  }

  private boolean isLegacyStage() {
    return "M0".equalsIgnoreCase(platformStage) || "M1".equalsIgnoreCase(platformStage);
  }

  private String namespacePrefix(String tenantId) {
    String compact = tenantId.replace("-", "");
    if (compact.isEmpty()) {
      return tenantId;
    }
    return Character.toLowerCase(compact.charAt(0)) + compact.substring(1);
  }

  private void appendAudit(String tenantId, PluginAuditRecord record) {
    auditLogs.computeIfAbsent(tenantId, ignored -> new ArrayList<>()).add(record);
  }
}

record PluginManifest(
    String code,
    String version,
    String publicKey,
    String signature,
    boolean signaturePlaceholderPresent,
    String extensionNamespace,
    boolean backendCodeIncluded,
    boolean hasBusinessData,
    Map<String, String> config,
    List<PluginDependency> dependencies,
    CompatibilityRange compatibility,
    LicensePlan licensePlan,
    boolean uninstallPreservesData) {

  PluginManifest {
    config = Map.copyOf(config);
    dependencies = List.copyOf(dependencies);
  }

  PluginManifest(String code, String version, String publicKey, String signature) {
    this(
        code,
        version,
        publicKey,
        signature,
        true,
        "global." + code,
        false,
        false,
        Map.of(),
        List.of(),
        new CompatibilityRange("0.0.0", "9999.x"),
        new LicensePlan("community", "retain_read_only", true),
        true);
  }
}

record PluginDependency(String pluginCode, String requiredVersion) {}

record CompatibilityRange(String minPlatformVersion, String maxTestedPlatformVersion) {

  boolean includes(String platformVersion) {
    return compare(platformVersion, minPlatformVersion) >= 0
        && compare(platformVersion, normalizedMaxVersion()) <= 0;
  }

  private String normalizedMaxVersion() {
    if (maxTestedPlatformVersion.endsWith(".x")) {
      return maxTestedPlatformVersion.substring(0, maxTestedPlatformVersion.length() - 2) + ".999";
    }
    return maxTestedPlatformVersion;
  }

  private int compare(String left, String right) {
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

record LicensePlan(String edition, String degradeMode, boolean auditReadable) {}

record PluginRuntime(
    String tenantId,
    String code,
    String version,
    String previousVersion,
    PluginStatus status,
    Map<String, String> sanitizedConfig,
    PluginManifest manifest,
    boolean licenseDegraded,
    String dataRetentionMode) {

  static PluginRuntime from(String tenantId, PluginManifest manifest, PluginStatus status, String previousVersion) {
    return new PluginRuntime(
        tenantId,
        manifest.code(),
        manifest.version(),
        previousVersion,
        status,
        sanitizeConfig(manifest.config()),
        manifest,
        false,
        manifest.uninstallPreservesData() ? manifest.licensePlan().degradeMode() : "delete_after_manual_approval");
  }

  PluginRuntime withStatus(PluginStatus targetStatus) {
    return new PluginRuntime(tenantId, code, version, previousVersion, targetStatus, sanitizedConfig, manifest, licenseDegraded, dataRetentionMode);
  }

  PluginRuntime upgradeTo(PluginManifest nextManifest) {
    return new PluginRuntime(
        tenantId,
        code,
        nextManifest.version(),
        version,
        status,
        sanitizeConfig(nextManifest.config()),
        nextManifest,
        licenseDegraded,
        dataRetentionMode);
  }

  PluginRuntime rollbackVersion() {
    return new PluginRuntime(tenantId, code, previousVersion, null, status, sanitizedConfig, manifest, licenseDegraded, dataRetentionMode);
  }

  PluginRuntime rollbackUpgradeFailure() {
    return new PluginRuntime(tenantId, code, version, previousVersion, status, sanitizedConfig, manifest, licenseDegraded, dataRetentionMode);
  }

  PluginRuntime withLicenseDegraded(boolean degraded) {
    return new PluginRuntime(tenantId, code, version, previousVersion, status, sanitizedConfig, manifest, degraded, dataRetentionMode);
  }

  PluginRuntime withDataRetentionMode(String retentionMode) {
    return new PluginRuntime(tenantId, code, version, previousVersion, status, sanitizedConfig, manifest, licenseDegraded, retentionMode);
  }

  PluginRuntime uninstallPreservingData() {
    return new PluginRuntime(tenantId, code, version, previousVersion, PluginStatus.UNINSTALLED, sanitizedConfig, manifest, licenseDegraded, dataRetentionMode);
  }

  private static Map<String, String> sanitizeConfig(Map<String, String> config) {
    Map<String, String> sanitized = new LinkedHashMap<>();
    for (Map.Entry<String, String> entry : config.entrySet()) {
      String key = entry.getKey().toLowerCase();
      sanitized.put(entry.getKey(), key.contains("secret") || key.contains("token") || key.contains("password") ? "******" : entry.getValue());
    }
    return Map.copyOf(sanitized);
  }
}

enum PluginStatus {
  INSTALLED,
  ENABLED,
  DISABLED,
  DEGRADED,
  UNINSTALLED
}

record PluginAuditRecord(
    String pluginCode,
    String sourceVersion,
    String targetVersion,
    String operator,
    String traceId,
    String action,
    String result) {}

class ConnectorUrlGuard {

  void validate(URI uri) {
    String host = uri.getHost();
    if (host == null) {
      throw new PluginSecurityException("Connector URL 缺少 host");
    }
    if ("localhost".equalsIgnoreCase(host) || host.startsWith("127.") || host.startsWith("10.") || host.startsWith("192.168.")) {
      throw new PluginSecurityException("禁止访问本机或内网地址");
    }
    if ("169.254.169.254".equals(host)) {
      throw new PluginSecurityException("禁止访问云厂商 metadata");
    }
    try {
      InetAddress address = InetAddress.getByName(host);
      if (address.isAnyLocalAddress() || address.isLoopbackAddress() || address.isSiteLocalAddress() || address.isLinkLocalAddress()) {
        throw new PluginSecurityException("禁止访问本机或内网地址");
      }
    } catch (java.net.UnknownHostException ex) {
      throw new PluginSecurityException("Connector URL 无法解析");
    }
  }
}

class AppPackageSecurityScanner {

  void scan(AppPackageManifest manifest) {
    for (String key : manifest.config().keySet()) {
      String normalized = key.toLowerCase();
      if (normalized.contains("secret") || normalized.contains("token") || normalized.contains("password")) {
        throw new PluginSecurityException("应用包不能包含密钥");
      }
    }
  }
}

record AppPackageManifest(String packageCode, Map<String, String> config, Map<String, String> objects) {}

record LicensePolicy(String edition, int objectQuota, LocalDate expireDate) {

  boolean allowObjectCount(int count) {
    return !LocalDate.now().isAfter(expireDate) && count <= objectQuota;
  }
}

class PluginSecurityException extends RuntimeException {

  PluginSecurityException(String message) {
    super(message);
  }
}

class AppPackageImportService {

  private final Map<String, PackageImportResult> idempotency = new LinkedHashMap<>();

  PackageImportResult importCommit(AppPackageManifest manifest, String idempotencyKey) {
    PackageImportResult replay = idempotency.get(idempotencyKey);
    if (replay != null) {
      return replay;
    }
    new AppPackageSecurityScanner().scan(manifest);
    PackageImportResult result = new PackageImportResult(
        "import-" + UUID.randomUUID(),
        List.copyOf(manifest.objects().keySet()));
    idempotency.put(idempotencyKey, result);
    return result;
  }
}

record PackageImportResult(String importId, List<String> createdObjects) {}

class NotificationTemplateGuard {

  void validate(String objectCode, String template, Map<String, Boolean> readableFields) {
    for (Map.Entry<String, Boolean> entry : readableFields.entrySet()) {
      if (template.contains("${" + entry.getKey() + "}") && !entry.getValue()) {
        throw new PluginSecurityException("通知模板引用无权限字段：" + objectCode + "." + entry.getKey());
      }
    }
  }
}

record PrivateDeploymentReport(boolean ready, List<String> items) {

  static PrivateDeploymentReport generate(
      boolean backupRestorePassed,
      boolean metricDisabledPassed,
      boolean tenantCleanupPassed,
      boolean pluginRollbackPassed) {
    List<String> items = new ArrayList<>();
    if (backupRestorePassed) {
      items.add("备份恢复演练已完成");
    }
    if (metricDisabledPassed) {
      items.add("指标上报关闭验收已完成");
    }
    if (tenantCleanupPassed) {
      items.add("租户注销与数据清理演练已完成");
    }
    if (pluginRollbackPassed) {
      items.add("插件失败回滚演练已完成");
    }
    return new PrivateDeploymentReport(
        backupRestorePassed && metricDisabledPassed && tenantCleanupPassed && pluginRollbackPassed,
        List.copyOf(items));
  }
}

record ConnectorInvocation(String url, int timeoutMs, int responseBytes, int permitsPerMinute) {}

class ConnectorPolicyGuard {

  private final int maxTimeoutMs;
  private final int maxResponseBytes;
  private final int maxPermitsPerMinute;

  ConnectorPolicyGuard(int maxTimeoutMs, int maxResponseBytes, int maxPermitsPerMinute) {
    this.maxTimeoutMs = maxTimeoutMs;
    this.maxResponseBytes = maxResponseBytes;
    this.maxPermitsPerMinute = maxPermitsPerMinute;
  }

  void validate(ConnectorInvocation invocation) {
    new ConnectorUrlGuard().validate(URI.create(invocation.url()));
    if (invocation.timeoutMs() > maxTimeoutMs) {
      throw new PluginSecurityException("Connector 超时超过上限");
    }
    if (invocation.responseBytes() > maxResponseBytes) {
      throw new PluginSecurityException("Connector 响应大小超过上限");
    }
    if (invocation.permitsPerMinute() > maxPermitsPerMinute) {
      throw new PluginSecurityException("Connector 限流超过上限");
    }
  }
}

class NotificationDeliveryService {

  private final int maxRetry;
  private final Map<String, Integer> attempts = new LinkedHashMap<>();
  private final List<String> deadLetters = new ArrayList<>();
  private final List<String> sentKeys = new ArrayList<>();

  NotificationDeliveryService(int maxRetry) {
    this.maxRetry = maxRetry;
  }

  void send(String businessKey, boolean success) {
    if (deadLetters.contains(businessKey) || sentKeys.contains(businessKey)) {
      return;
    }
    if (success) {
      sentKeys.add(businessKey);
      return;
    }
    int nextAttempt = attempts.getOrDefault(businessKey, 0) + 1;
    attempts.put(businessKey, nextAttempt);
    if (nextAttempt > maxRetry) {
      deadLetters.add(businessKey);
    }
  }

  List<String> deadLetters() {
    return List.copyOf(deadLetters);
  }

  List<String> sentKeys() {
    return List.copyOf(sentKeys);
  }
}

record WebhookRequest(String eventId, String payload, String signature) {}

class WebhookDeliveryService {

  private final String secret;
  private final Set<String> deliveredEventIds = new LinkedHashSet<>();

  WebhookDeliveryService(String secret) {
    this.secret = secret;
  }

  void deliver(WebhookRequest request) {
    if (!("sig-" + secret + "-" + request.payload()).equals(request.signature())) {
      throw new PluginSecurityException("Webhook 签名不合法");
    }
    deliveredEventIds.add(request.eventId());
  }

  List<String> deliveredEventIds() {
    return List.copyOf(deliveredEventIds);
  }
}

class ApiTokenScopeGuard {

  Set<String> effectiveScopes(Set<String> principalScopes, Set<String> tokenScopes) {
    java.util.LinkedHashSet<String> effective = new java.util.LinkedHashSet<>(tokenScopes);
    effective.retainAll(principalScopes);
    return Set.copyOf(effective);
  }
}
