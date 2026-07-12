package com.lowcode.app;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.nio.charset.StandardCharsets;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

@SpringBootTest(properties = {
    "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration",
    "lowcode.gateway.shared-secret=test-gateway-secret",
    "lowcode.app.runtime.demo-enabled=true"
})
@AutoConfigureMockMvc
class RuntimeDemoWithJdbcApplicationTest {

  @Autowired private ApplicationContext applicationContext;
  @Autowired private MockMvc mockMvc;

  @TestConfiguration
  static class JdbcTestConfig {

    @Bean
    JdbcTemplate jdbcTemplate() {
      return new RecordingJdbcTemplate();
    }
  }

  @Test
  void shouldKeepRuntimeDemoIndependentFromPublishedRegistryWhenJdbcTemplateExists() throws Exception {
    assertThat(applicationContext.containsBean("publishedRuntimeObjectRegistry")).isFalse();

    mockMvc.perform(post("/api/data/sales/order/meta")
            .contentType(MediaType.APPLICATION_JSON)
            .with(gatewaySignature())
            .header("X-Trace-Id", "trace-runtime-demo-jdbc-meta")
            .content("{}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.objectCode").value("order"))
        .andExpect(jsonPath("$.fields[0]").value("amount"));
  }

  private static final class RecordingJdbcTemplate extends JdbcTemplate {
    @Override
    public List<Map<String, Object>> queryForList(String sql, Object... args) {
      return List.of();
    }

    @Override
    public void afterPropertiesSet() {
      // Test fixture: no real DataSource is needed for configuration wiring assertions.
    }

    @Override
    public int update(String sql, Object... args) {
      return 1;
    }
  }

  private static RequestPostProcessor gatewaySignature() {
    return request -> {
      String timestamp = String.valueOf(System.currentTimeMillis());
      request.addHeader("X-Tenant-Id", "9");
      request.addHeader("X-Workspace-Id", "70");
      request.addHeader("X-User-Lid", "manager-1");
      request.addHeader("X-Role-Codes", "manager");
      request.addHeader("X-Meta-Hash", "mh-1");
      request.addHeader("X-Gateway-Timestamp", timestamp);
      request.addHeader("X-Gateway-Signature", hmac(canonicalPayload(request, timestamp)));
      return request;
    };
  }

  private static String canonicalPayload(MockHttpServletRequest request, String timestamp) {
    return String.join("\n",
        request.getMethod(),
        request.getRequestURI(),
        timestamp,
        header(request, "X-Tenant-Id"),
        header(request, "X-Workspace-Id"),
        header(request, "X-User-Lid"),
        header(request, "X-Role-Codes"),
        header(request, "X-Meta-Hash"));
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

  private static String header(MockHttpServletRequest request, String name) {
    String value = request.getHeader(name);
    return value == null ? "" : value.trim();
  }
}
