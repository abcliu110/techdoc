package com.lowcode.app.api;

import com.lowcode.common.error.BizException;
import com.lowcode.common.error.ErrorCode;
import jakarta.servlet.http.HttpServletRequest;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Clock;
import java.util.Arrays;
import java.util.HexFormat;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.stream.Collectors;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * 从受控请求头解析运行态请求上下文。
 *
 * <p>安全边界：当前阶段不接入 Spring Security，但也不能继续信任控制器里的硬编码身份。
 * 这里只接受网关或上游已经注入的受控头；缺少租户、工作区或用户时立即失败，避免降级成默认管理员。
 */
@Component
public class AuthenticatedRuntimeContextResolver {

  private static final String HMAC_ALGORITHM = "HmacSHA256";
  private static final long DEFAULT_ALLOWED_SKEW_MILLIS = 300_000L;

  private final String sharedSecret;
  private final Clock clock;
  private final long allowedSkewMillis;

  @Autowired
  public AuthenticatedRuntimeContextResolver(
      @Value("${lowcode.gateway.shared-secret:}") String sharedSecret) {
    this(sharedSecret, Clock.systemUTC(), DEFAULT_ALLOWED_SKEW_MILLIS);
  }

  public AuthenticatedRuntimeContextResolver(
      String sharedSecret,
      Clock clock,
      long allowedSkewMillis) {
    this.sharedSecret = sharedSecret == null ? "" : sharedSecret.trim();
    this.clock = clock;
    this.allowedSkewMillis = allowedSkewMillis;
  }

  /**
   * 解析当前请求的运行态上下文。
   *
   * @param request 当前 HTTP 请求
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param metaHash 请求使用的元数据哈希
   * @return 经过最小校验后的运行态上下文
   */
  public AuthenticatedRuntimeContext resolve(
      HttpServletRequest request,
      String appCode,
      String objectCode,
      String metaHash) {
    requireTrustedGateway(request, metaHash);
    Long tenantId = requiredLongHeader(request, "X-Tenant-Id", ErrorCode.TENANT_REQUIRED, "租户不能为空");
    Long workspaceId = requiredLongHeader(request, "X-Workspace-Id", ErrorCode.PARAM_INVALID, "工作区不能为空");
    String userLid = requiredTextHeader(request, "X-User-Lid", "用户不能为空");
    String traceId = blankToDefault(request.getHeader("X-Trace-Id"), "trace-http");
    Set<String> roleCodes = parseRoleCodes(request.getHeader("X-Role-Codes"));
    return new AuthenticatedRuntimeContext(
        tenantId,
        workspaceId,
        userLid,
        roleCodes,
        appCode,
        objectCode,
        metaHash,
        traceId);
  }

  private void requireTrustedGateway(HttpServletRequest request, String metaHash) {
    if (sharedSecret.isBlank()) {
      throw new BizException(ErrorCode.PARAM_INVALID, "网关签名无效");
    }
    long timestamp = gatewayTimestamp(request);
    if (Math.abs(clock.millis() - timestamp) > allowedSkewMillis) {
      throw new BizException(ErrorCode.PARAM_INVALID, "网关签名无效");
    }
    String signature = request.getHeader("X-Gateway-Signature");
    String expected = hmac(canonicalPayload(request, String.valueOf(timestamp), metaHash));
    if (signature == null || !MessageDigest.isEqual(
        expected.getBytes(StandardCharsets.UTF_8),
        signature.trim().getBytes(StandardCharsets.UTF_8))) {
      throw new BizException(ErrorCode.PARAM_INVALID, "网关签名无效");
    }
  }

  private long gatewayTimestamp(HttpServletRequest request) {
    String raw = request.getHeader("X-Gateway-Timestamp");
    if (raw == null || raw.isBlank()) {
      throw new BizException(ErrorCode.PARAM_INVALID, "网关签名无效");
    }
    try {
      return Long.parseLong(raw.trim());
    } catch (NumberFormatException ex) {
      throw new BizException(ErrorCode.PARAM_INVALID, "网关签名无效");
    }
  }

  private String canonicalPayload(HttpServletRequest request, String timestamp, String metaHash) {
    return String.join("\n",
        request.getMethod(),
        request.getRequestURI(),
        timestamp,
        header(request, "X-Tenant-Id"),
        header(request, "X-Workspace-Id"),
        header(request, "X-User-Lid"),
        header(request, "X-Role-Codes"),
        metaHash == null ? "" : metaHash.trim());
  }

  private String hmac(String payload) {
    try {
      Mac mac = Mac.getInstance(HMAC_ALGORITHM);
      mac.init(new SecretKeySpec(sharedSecret.getBytes(StandardCharsets.UTF_8), HMAC_ALGORITHM));
      return HexFormat.of().formatHex(mac.doFinal(payload.getBytes(StandardCharsets.UTF_8)));
    } catch (Exception ex) {
      throw new BizException(ErrorCode.PARAM_INVALID, "网关签名无效");
    }
  }

  private String header(HttpServletRequest request, String name) {
    String value = request.getHeader(name);
    return value == null ? "" : value.trim();
  }

  private Long requiredLongHeader(
      HttpServletRequest request,
      String headerName,
      ErrorCode errorCode,
      String message) {
    String raw = request.getHeader(headerName);
    if (raw == null || raw.isBlank()) {
      throw new BizException(errorCode, message);
    }
    try {
      return Long.valueOf(raw.trim());
    } catch (NumberFormatException ex) {
      throw new BizException(ErrorCode.PARAM_INVALID, message);
    }
  }

  private String requiredTextHeader(
      HttpServletRequest request,
      String headerName,
      String message) {
    String value = request.getHeader(headerName);
    if (value == null || value.isBlank()) {
      throw new BizException(ErrorCode.PARAM_INVALID, message);
    }
    return value.trim();
  }

  private String blankToDefault(String value, String defaultValue) {
    return value == null || value.isBlank() ? defaultValue : value.trim();
  }

  private Set<String> parseRoleCodes(String headerValue) {
    if (headerValue == null || headerValue.isBlank()) {
      return Set.of();
    }
    return Arrays.stream(headerValue.split(","))
        .map(String::trim)
        .filter(token -> !token.isEmpty())
        .collect(Collectors.toCollection(LinkedHashSet::new));
  }
}
