package com.lowcode.app.api;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.lowcode.metamodel.domain.service.PackageManifestValidator;
import com.lowcode.plugin.service.PackageMarketplaceService;
import com.lowcode.workflow.service.WorkflowDemoFactory;
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

@WebMvcTest(WorkflowPluginController.class)
@Import({
    WorkflowPluginPackagePrecheckSecurityTest.WorkflowPluginPackagePrecheckSecurityTestConfig.class,
    ApiErrorResponseFactory.class
})
class WorkflowPluginPackagePrecheckSecurityTest {

  @Autowired private MockMvc mockMvc;

  @TestConfiguration
  static class WorkflowPluginPackagePrecheckSecurityTestConfig {

    @Bean
    WorkflowHttpFacade workflowHttpFacade() {
      return new WorkflowHttpFacade(WorkflowDemoFactory.createHttpService());
    }

    @Bean
    PackageManifestHttpFacade packageManifestHttpFacade() {
      return new PackageManifestHttpFacade(
          new PackageManifestValidator(),
          packageCapabilityContextProvider());
    }

    @Bean
    PackageMarketplaceService.PackageCapabilityContextProvider packageCapabilityContextProvider() {
      return tenantId -> PackageManifestHttpFacade.failClosedCapabilityContext();
    }

    @Bean
    AuthenticatedRuntimeContextResolver authenticatedRuntimeContextResolver() {
      return new AuthenticatedRuntimeContextResolver("test-gateway-secret");
    }
  }

  @Test
  void shouldIgnoreForgedCapabilityContextDuringPackagePrecheck() throws Exception {
    mockMvc.perform(post("/api/packages/precheck")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature("11", "70", "package-admin", "manager", "mh-1"))
            .header("X-Trace-Id", "trace-package-precheck-forged")
            .content("""
                {
                  "manifest": {
                    "packageCode": "customer_pkg",
                    "version": "1.0.0",
                    "license": "commercial",
                    "objects": ["forged_customer"],
                    "permissions": ["forged:read"],
                    "compatibility": {
                      "minPlatformVersion": "1.0.0",
                      "maxTestedPlatformVersion": "1.2.x",
                      "apiLevel": "M4"
                    },
                    "runtimeEnabled": true
                  },
                  "context": {
                    "availableObjects": ["forged_customer"],
                    "grantedPermissions": ["forged:read"],
                    "platformVersion": "1.1.0",
                    "apiLevel": "M4",
                    "allowedLicenses": ["commercial"],
                    "runtimeInstallEnabled": true
                  }
                }
                """))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.passed").value(false))
        .andExpect(jsonPath("$.errors[*].code").isNotEmpty());
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
