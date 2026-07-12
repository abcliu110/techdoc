package com.lowcode.app.api;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
class PackageMarketplaceController {

  private final PackageMarketplaceHttpFacade packageMarketplaceHttpFacade;
  private final AuthenticatedRuntimeContextResolver contextResolver;
  private final ApiErrorResponseFactory errorResponseFactory;

  PackageMarketplaceController(
      PackageMarketplaceHttpFacade packageMarketplaceHttpFacade,
      AuthenticatedRuntimeContextResolver contextResolver,
      ApiErrorResponseFactory errorResponseFactory) {
    this.packageMarketplaceHttpFacade = packageMarketplaceHttpFacade;
    this.contextResolver = contextResolver;
    this.errorResponseFactory = errorResponseFactory;
  }

  @PostMapping("/api/packages/install")
  Object install(
      HttpServletRequest httpRequest,
      @RequestBody PackageInstallRequest request) {
    return packageMarketplaceHttpFacade.install(context(httpRequest, "package", "install"), request);
  }

  @GetMapping("/api/packages")
  Object list(HttpServletRequest httpRequest) {
    return packageMarketplaceHttpFacade.list(context(httpRequest, "package", "list"));
  }

  @GetMapping("/api/packages/audit")
  Object audit(HttpServletRequest httpRequest) {
    return packageMarketplaceHttpFacade.audit(context(httpRequest, "package", "audit"));
  }

  @PostMapping("/api/packages/{packageCode}/disable")
  Object disable(
      @PathVariable("packageCode") String packageCode,
      HttpServletRequest httpRequest,
      @RequestBody(required = false) Object ignored) {
    return packageMarketplaceHttpFacade.disable(context(httpRequest, "package", packageCode), packageCode);
  }

  @PostMapping("/api/packages/{packageCode}/enable")
  Object enable(
      @PathVariable("packageCode") String packageCode,
      HttpServletRequest httpRequest,
      @RequestBody(required = false) Object ignored) {
    return packageMarketplaceHttpFacade.enable(context(httpRequest, "package", packageCode), packageCode);
  }

  @PostMapping("/api/packages/{packageCode}/upgrade")
  Object upgrade(
      @PathVariable("packageCode") String packageCode,
      HttpServletRequest httpRequest,
      @RequestBody PackageInstallRequest request) {
    return packageMarketplaceHttpFacade.upgrade(context(httpRequest, "package", packageCode), packageCode, request);
  }

  @PostMapping("/api/packages/{packageCode}/rollback")
  Object rollback(
      @PathVariable("packageCode") String packageCode,
      HttpServletRequest httpRequest,
      @RequestBody(required = false) Object ignored) {
    return packageMarketplaceHttpFacade.rollback(context(httpRequest, "package", packageCode), packageCode);
  }

  @PostMapping("/api/packages/{packageCode}/uninstall-dry-run")
  Object uninstallDryRun(
      @PathVariable("packageCode") String packageCode,
      HttpServletRequest httpRequest,
      @RequestBody(required = false) Object ignored) {
    return packageMarketplaceHttpFacade.uninstallDryRun(context(httpRequest, "package", packageCode), packageCode);
  }

  @PostMapping("/api/packages/{packageCode}/uninstall")
  Object uninstall(
      @PathVariable("packageCode") String packageCode,
      HttpServletRequest httpRequest,
      @RequestBody(required = false) Object ignored) {
    return packageMarketplaceHttpFacade.uninstall(context(httpRequest, "package", packageCode), packageCode);
  }

  @ExceptionHandler(com.lowcode.common.error.BizException.class)
  Object handleBizException(com.lowcode.common.error.BizException ex, HttpServletRequest request) {
    ApiErrorResponse response = errorResponseFactory.fromBizException(ex, request);
    return ResponseEntity.status(response.status()).body(response.body());
  }

  @ExceptionHandler(RuntimeException.class)
  Object handleRuntimeException(RuntimeException ex, HttpServletRequest request) {
    ApiErrorResponse response = errorResponseFactory.fromRuntimeException(ex, request);
    return ResponseEntity.status(response.status()).body(response.body());
  }

  private AuthenticatedRuntimeContext context(HttpServletRequest request, String appCode, String objectCode) {
    String metaHash = request.getHeader("X-Meta-Hash") == null ? "mh-1" : request.getHeader("X-Meta-Hash");
    return contextResolver.resolve(request, appCode, objectCode, metaHash);
  }
}
