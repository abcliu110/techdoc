package com.lowcode.app.api;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.hamcrest.Matchers.hasItem;

import java.nio.charset.StandardCharsets;
import java.util.HexFormat;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

@WebMvcTest(PackageMarketplaceController.class)
@Import({
    PackageMarketplaceControllerTest.PackageMarketplaceControllerTestConfig.class,
    ApiErrorResponseFactory.class
})
class PackageMarketplaceControllerTest {

  @Autowired private MockMvc mockMvc;

  @TestConfiguration
  static class PackageMarketplaceControllerTestConfig {

    @Bean
    PackageMarketplaceHttpFacade packageMarketplaceHttpFacade() {
      return new PackageMarketplaceHttpFacade();
    }

    @Bean
    AuthenticatedRuntimeContextResolver authenticatedRuntimeContextResolver() {
      return new AuthenticatedRuntimeContextResolver("test-gateway-secret");
    }
  }

  @Test
  void shouldInstallListDisableAndDryRunMarketplacePackageThroughSignedGateway() throws Exception {
    mockMvc.perform(post("/api/packages/install")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-install")
            .content("""
                {
                  "manifest": {
                    "packageCode": "customer_pkg",
                    "version": "1.0.0",
                    "license": "commercial",
                    "objects": ["customer"],
                    "permissions": ["customer:read"],
                    "compatibility": {
                      "minPlatformVersion": "1.0.0",
                      "maxTestedPlatformVersion": "1.2.x",
                      "apiLevel": "M4"
                    },
                    "runtimeEnabled": true
                  },
                  "context": {
                    "availableObjects": ["customer"],
                    "grantedPermissions": ["customer:read"],
                    "platformVersion": "1.1.0",
                    "apiLevel": "M4",
                    "allowedLicenses": ["commercial"],
                    "runtimeInstallEnabled": true
                  }
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.installed").value(true))
        .andExpect(jsonPath("$.state.packageCode").value("customer_pkg"))
        .andExpect(jsonPath("$.state.status").value("ENABLED"));

    mockMvc.perform(get("/api/packages")
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-list"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.packages[0].packageCode").value("customer_pkg"))
        .andExpect(jsonPath("$.packages[0].status").value("ENABLED"));

    mockMvc.perform(post("/api/packages/customer_pkg/disable")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-disable")
            .content("{}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.state.status").value("DISABLED"));

    mockMvc.perform(post("/api/packages/customer_pkg/enable")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-enable")
            .content("{}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.state.status").value("ENABLED"));

    mockMvc.perform(post("/api/packages/customer_pkg/disable")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-disable-again")
            .content("{}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.state.status").value("DISABLED"));

    mockMvc.perform(post("/api/packages/customer_pkg/uninstall-dry-run")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-dry-run")
            .content("{}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.allowed").value(true))
        .andExpect(jsonPath("$.status").value("DISABLED"))
        .andExpect(jsonPath("$.blockingReasons").isEmpty());

    mockMvc.perform(post("/api/packages/customer_pkg/uninstall")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-uninstall")
            .content("{}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.uninstalled").value(true))
        .andExpect(jsonPath("$.packageCode").value("customer_pkg"))
        .andExpect(jsonPath("$.blockingReasons").isEmpty());

    mockMvc.perform(get("/api/packages")
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-list-after-uninstall"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.packages").isEmpty());

    mockMvc.perform(get("/api/packages/audit")
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-audit"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.events[*].operation").value(hasItem("INSTALL_SUCCEEDED")))
        .andExpect(jsonPath("$.events[*].operation").value(hasItem("DISABLED")))
        .andExpect(jsonPath("$.events[*].operation").value(hasItem("ENABLED")))
        .andExpect(jsonPath("$.events[*].operation").value(hasItem("UNINSTALL_DRY_RUN_ALLOWED")))
        .andExpect(jsonPath("$.events[*].operation").value(hasItem("UNINSTALLED")))
        .andExpect(jsonPath("$.events[*].traceId").value(hasItem("trace-package-enable")))
        .andExpect(jsonPath("$.events[*].traceId").value(hasItem("trace-package-uninstall")))
        .andExpect(jsonPath("$.events[*].traceId").value(hasItem("trace-package-install")));
  }

  @Test
  void shouldReturnStableValidationErrorsForRejectedInstall() throws Exception {
    mockMvc.perform(post("/api/packages/install")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-install-invalid")
            .content("""
                {
                  "manifest": {
                    "packageCode": "customer_pkg",
                    "version": "2.0.0",
                    "license": "enterprise",
                    "compatibility": {
                      "minPlatformVersion": "2.0.0",
                      "maxTestedPlatformVersion": "2.1.x",
                      "apiLevel": "M5"
                    },
                    "runtimeEnabled": true
                  },
                  "context": {
                    "installedDependencies": {
                      "base_pkg": "1.0.0"
                    },
                    "platformVersion": "1.1.0",
                    "apiLevel": "M4",
                    "allowedLicenses": ["commercial"],
                    "runtimeInstallEnabled": false
                  }
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.installed").value(false))
        .andExpect(jsonPath("$.errors[0].code").exists())
        .andExpect(jsonPath("$.errors[0].path").exists());
  }

  @Test
  void shouldIgnoreClientForgedInstalledDependenciesDuringMarketplaceInstall() throws Exception {
    mockMvc.perform(post("/api/packages/install")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("3", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-forged-deps")
            .content("""
                {
                  "manifest": {
                    "packageCode": "customer_pkg",
                    "version": "1.0.0",
                    "license": "commercial",
                    "dependencies": [
                      {"packageCode": "base_pkg", "minVersion": "1.0.0"}
                    ],
                    "compatibility": {
                      "minPlatformVersion": "1.0.0",
                      "maxTestedPlatformVersion": "1.2.x",
                      "apiLevel": "M4"
                    },
                    "runtimeEnabled": false
                  },
                  "context": {
                    "installedDependencies": {
                      "base_pkg": "9.9.9"
                    },
                    "platformVersion": "1.1.0",
                    "apiLevel": "M4",
                    "allowedLicenses": ["commercial"],
                    "runtimeInstallEnabled": true
                  }
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.installed").value(false))
        .andExpect(jsonPath("$.errors[0].code").value("LC-META-PKG-001"));
  }

  @Test
  void shouldIgnoreForgedCapabilityContextDuringMarketplaceInstall() throws Exception {
    mockMvc.perform(post("/api/packages/install")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("11", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-forged-capabilities")
            .content("""
                {
                  "manifest": {
                    "packageCode": "customer_pkg",
                    "version": "1.0.0",
                    "license": "commercial",
                    "objects": ["customer"],
                    "permissions": ["customer:read"],
                    "compatibility": {
                      "minPlatformVersion": "1.0.0",
                      "maxTestedPlatformVersion": "1.2.x",
                      "apiLevel": "M4"
                    },
                    "runtimeEnabled": true
                  },
                  "context": {
                    "availableObjects": ["customer"],
                    "grantedPermissions": ["customer:read"],
                    "platformVersion": "1.1.0",
                    "apiLevel": "M4",
                    "allowedLicenses": ["commercial"],
                    "runtimeInstallEnabled": true
                  }
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.installed").value(false))
        .andExpect(jsonPath("$.errors[*].code").isNotEmpty());
  }

  @Test
  void shouldKeepExistingPackageVersionWhenDifferentVersionInstallIsSubmitted() throws Exception {
    String firstInstall = """
        {
          "manifest": {
            "packageCode": "stable_pkg",
            "version": "1.0.0",
            "license": "commercial",
            "compatibility": {
              "minPlatformVersion": "1.0.0",
              "maxTestedPlatformVersion": "1.2.x",
              "apiLevel": "M4"
            },
            "runtimeEnabled": false
          },
          "context": {
            "platformVersion": "1.1.0",
            "apiLevel": "M4",
            "allowedLicenses": ["commercial"],
            "runtimeInstallEnabled": true
          }
        }
        """;
    mockMvc.perform(post("/api/packages/install")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("8", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-stable-install-1")
            .content(firstInstall))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.installed").value(true));

    mockMvc.perform(post("/api/packages/install")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("8", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-stable-install-2")
            .content(firstInstall.replace("\"1.0.0\"", "\"2.0.0\"")))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.installed").value(false))
        .andExpect(jsonPath("$.errors[0].code").value("LC-PKG-INSTALL-001"));

    mockMvc.perform(get("/api/packages")
            .with(gatewaySignature("8", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-stable-list"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.packages[0].packageCode").value("stable_pkg"))
        .andExpect(jsonPath("$.packages[0].version").value("1.0.0"));
  }

  @Test
  void shouldUpgradeAndRollbackMarketplacePackageThroughSignedGateway() throws Exception {
    String installPayload = """
        {
          "manifest": {
            "packageCode": "customer_pkg",
            "version": "1.0.0",
            "license": "commercial",
            "objects": ["customer"],
            "permissions": ["customer:read"],
            "compatibility": {
              "minPlatformVersion": "1.0.0",
              "maxTestedPlatformVersion": "1.2.x",
              "apiLevel": "M4"
            },
            "runtimeEnabled": true
          },
          "context": {
            "availableObjects": ["customer"],
            "grantedPermissions": ["customer:read"],
            "platformVersion": "1.1.0",
            "apiLevel": "M4",
            "allowedLicenses": ["commercial"],
            "runtimeInstallEnabled": true
          }
        }
        """;

    mockMvc.perform(post("/api/packages/install")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("9", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-upgrade-install")
            .content(installPayload))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.installed").value(true));

    mockMvc.perform(post("/api/packages/customer_pkg/upgrade")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("9", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-upgrade")
            .content(installPayload.replace("\"1.0.0\"", "\"1.1.0\"")))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.state.packageCode").value("customer_pkg"))
        .andExpect(jsonPath("$.state.version").value("1.1.0"));

    mockMvc.perform(post("/api/packages/customer_pkg/rollback")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("9", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-rollback")
            .content("{}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.state.packageCode").value("customer_pkg"))
        .andExpect(jsonPath("$.state.version").value("1.0.0"));

    mockMvc.perform(get("/api/packages/audit")
            .with(gatewaySignature("9", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-upgrade-audit"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.events[*].operation").value(hasItem("UPGRADED")))
        .andExpect(jsonPath("$.events[*].operation").value(hasItem("ROLLED_BACK")))
        .andExpect(jsonPath("$.events[*].details").value(hasItem("1.0.0->1.1.0")))
        .andExpect(jsonPath("$.events[*].details").value(hasItem("1.1.0->1.0.0")));
  }

  @Test
  void shouldRejectUnsignedMarketplaceRequests() throws Exception {
    mockMvc.perform(get("/api/packages")
            .header("X-Tenant-Id", "3")
            .header("X-Workspace-Id", "70")
            .header("X-User-Lid", "package-admin"))
        .andExpect(status().isBadRequest())
        .andExpect(jsonPath("$.message").value("网关签名无效"));
  }

  private static RequestPostProcessor gatewaySignature(
      String tenantId,
      String workspaceId,
      String userLid,
      String roleCodes,
      String metaHash) {
    return request -> {
      String timestamp = String.valueOf(System.currentTimeMillis());
      request.addHeader("X-Tenant-Id", tenantId);
      request.addHeader("X-Workspace-Id", workspaceId);
      request.addHeader("X-User-Lid", userLid);
      request.addHeader("X-Role-Codes", roleCodes);
      request.addHeader("X-Meta-Hash", metaHash);
      request.addHeader("X-Gateway-Timestamp", timestamp);
      request.addHeader("X-Gateway-Signature", hmac(canonicalPayload(request, timestamp, metaHash)));
      return request;
    };
  }

  private static String canonicalPayload(
      org.springframework.mock.web.MockHttpServletRequest request,
      String timestamp,
      String metaHash) {
    return String.join("\n",
        request.getMethod(),
        request.getRequestURI(),
        timestamp,
        header(request, "X-Tenant-Id"),
        header(request, "X-Workspace-Id"),
        header(request, "X-User-Lid"),
        header(request, "X-Role-Codes"),
        metaHash);
  }

  private static String hmac(String payload) {
    try {
      Mac mac = Mac.getInstance("HmacSHA256");
      mac.init(new SecretKeySpec("test-gateway-secret".getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
      return HexFormat.of().formatHex(mac.doFinal(payload.getBytes(StandardCharsets.UTF_8)));
    } catch (Exception ex) {
      throw new IllegalStateException(ex);
    }
  }

  private static String header(org.springframework.mock.web.MockHttpServletRequest request, String name) {
    String value = request.getHeader(name);
    return value == null ? "" : value.trim();
  }
}
