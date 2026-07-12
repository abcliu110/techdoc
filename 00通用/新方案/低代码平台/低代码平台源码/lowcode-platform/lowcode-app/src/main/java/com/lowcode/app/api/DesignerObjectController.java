package com.lowcode.app.api;

import com.lowcode.common.api.Result;
import com.lowcode.common.error.BizException;
import com.lowcode.common.error.ErrorCode;
import com.lowcode.designer.service.DesignerApiException;
import com.lowcode.designer.service.DesignerDraftFacade;
import com.lowcode.designer.service.FieldDraft;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * 设计态对象草稿 HTTP 入口。
 *
 * <p>当前只开放最小可用闭环：add/update/get/list/del/validate/publish/preview。
 * Controller 负责协议适配、traceId 透传和安全错误映射，设计态业务逻辑留在 designer 模块。
 */
@RestController
public class DesignerObjectController {

  private final DesignerDraftFacade designerDraftFacade;
  private final ApiErrorResponseFactory errorResponseFactory;
  private final AuthenticatedRuntimeContextResolver contextResolver;

  DesignerObjectController(
      DesignerDraftFacade designerDraftFacade,
      ApiErrorResponseFactory errorResponseFactory,
      AuthenticatedRuntimeContextResolver contextResolver) {
    this.designerDraftFacade = designerDraftFacade;
    this.errorResponseFactory = errorResponseFactory;
    this.contextResolver = contextResolver;
  }

  /**
   * 新增对象草稿。
   *
   * @param request 当前 HTTP 请求
   * @param body 新增命令
   * @return 统一 Result 包装的草稿
   * @throws BizException 缺少租户上下文时抛出
   */
  @PostMapping("/api/designer/object/add")
  Result<?> add(HttpServletRequest request, @RequestBody DesignerDraftMutationRequest body) {
    AuthenticatedRuntimeContext context = context(request, body.appCode(), body.objectCode());
    return Result.success(
        designerDraftFacade.add(context.tenantId(), body.appCode(), body.objectCode(), body.name(), body.revision(), toFields(body)),
        traceId(request));
  }

  /**
   * 更新对象草稿。
   *
   * @param request 当前 HTTP 请求
   * @param body 更新命令
   * @return 统一 Result 包装的草稿
   * @throws BizException 缺少租户上下文时抛出
   */
  @PostMapping("/api/designer/object/update")
  Result<?> update(HttpServletRequest request, @RequestBody DesignerDraftMutationRequest body) {
    AuthenticatedRuntimeContext context = context(request, body.appCode(), body.objectCode());
    return Result.success(
        designerDraftFacade.update(context.tenantId(), body.appCode(), body.objectCode(), body.name(), body.revision(), toFields(body)),
        traceId(request));
  }

  /**
   * 获取对象草稿。
   *
   * @param request 当前 HTTP 请求
   * @param body 查询命令
   * @return 统一 Result 包装的草稿
   * @throws BizException 缺少租户上下文时抛出
   */
  @PostMapping("/api/designer/object/get")
  Result<?> get(HttpServletRequest request, @RequestBody DesignerDraftLocateRequest body) {
    AuthenticatedRuntimeContext context = context(request, body.appCode(), body.objectCode());
    return Result.success(
        designerDraftFacade.get(context.tenantId(), body.appCode(), body.objectCode()),
        traceId(request));
  }

  /**
   * 列出对象草稿。
   *
   * @param request 当前 HTTP 请求
   * @param body 列表命令
   * @return 统一 Result 包装的草稿列表
   * @throws BizException 缺少租户上下文时抛出
   */
  @PostMapping("/api/designer/object/list")
  Result<?> list(HttpServletRequest request, @RequestBody DesignerDraftListRequest body) {
    AuthenticatedRuntimeContext context = context(request, body.appCode(), "designer_object");
    return Result.success(
        designerDraftFacade.list(context.tenantId(), body.appCode()),
        traceId(request));
  }

  /**
   * 删除对象草稿。
   *
   * @param request 当前 HTTP 请求
   * @param body 删除命令
   * @return 统一 Result 包装的删除结果
   * @throws BizException 缺少租户上下文时抛出
   */
  @PostMapping("/api/designer/object/del")
  Result<?> delete(HttpServletRequest request, @RequestBody DesignerDraftDeleteRequest body) {
    AuthenticatedRuntimeContext context = context(request, body.appCode(), body.objectCode());
    return Result.success(
        designerDraftFacade.delete(context.tenantId(), body.appCode(), body.objectCode(), body.revision()),
        traceId(request));
  }

  /**
   * 校验对象草稿。
   *
   * @param request 当前 HTTP 请求
   * @param body 查询命令
   * @return 统一 Result 包装的校验结果
   * @throws BizException 缺少租户上下文时抛出
   */
  @PostMapping("/api/designer/object/validate")
  Result<?> validate(HttpServletRequest request, @RequestBody DesignerDraftLocateRequest body) {
    AuthenticatedRuntimeContext context = context(request, body.appCode(), body.objectCode());
    return Result.success(
        designerDraftFacade.validate(context.tenantId(), body.appCode(), body.objectCode()),
        traceId(request));
  }

  /**
   * 发布对象草稿。
   *
   * @param request 当前 HTTP 请求
   * @param body 发布命令
   * @return 统一 Result 包装的发布快照
   * @throws BizException 缺少租户上下文时抛出
   */
  @PostMapping("/api/designer/object/publish")
  Result<?> publish(HttpServletRequest request, @RequestBody DesignerDraftPublishRequest body) {
    AuthenticatedRuntimeContext context = context(request, body.appCode(), body.objectCode());
    return Result.success(
        designerDraftFacade.publish(context.tenantId(), body.appCode(), body.objectCode(), body.revision()),
        traceId(request));
  }

  /**
   * 预览对象草稿。
   *
   * @param request 当前 HTTP 请求
   * @param body 查询命令
   * @return 统一 Result 包装的预览结果
   * @throws BizException 缺少租户上下文时抛出
   */
  @PostMapping("/api/designer/object/preview")
  Result<?> preview(HttpServletRequest request, @RequestBody DesignerDraftLocateRequest body) {
    AuthenticatedRuntimeContext context = context(request, body.appCode(), body.objectCode());
    return Result.success(
        designerDraftFacade.preview(context.tenantId(), body.appCode(), body.objectCode()),
        traceId(request));
  }

  @ExceptionHandler(DesignerApiException.class)
  Object handleDesignerApiException(DesignerApiException ex, HttpServletRequest request) {
    HttpStatus status = ex.errorCode() == ErrorCode.META_CONFLICT
        ? HttpStatus.CONFLICT
        : (ex.safeData() != null ? HttpStatus.UNPROCESSABLE_ENTITY : HttpStatus.BAD_REQUEST);
    return ResponseEntity.status(status).body(new Result<>(ex.errorCode().code(), ex.safeMessage(), ex.safeData(), traceId(request)));
  }

  @ExceptionHandler(BizException.class)
  Object handleBizException(BizException ex, HttpServletRequest request) {
    ApiErrorResponse response = errorResponseFactory.fromBizException(ex, request);
    return ResponseEntity.status(response.status()).body(response.body());
  }

  private List<FieldDraft> toFields(DesignerDraftMutationRequest body) {
    return body.fields() == null ? List.of() : body.fields().stream()
        .map(field -> new FieldDraft(field.code(), field.name(), field.type(), field.required()))
        .toList();
  }

  private AuthenticatedRuntimeContext context(HttpServletRequest request, String appCode, String objectCode) {
    return contextResolver.resolve(request, appCode, objectCode, metaHash(request));
  }

  private String metaHash(HttpServletRequest request) {
    String raw = request.getHeader("X-Meta-Hash");
    return raw == null || raw.isBlank() ? "mh-1" : raw.trim();
  }

  private String traceId(HttpServletRequest request) {
    String raw = request.getHeader("X-Trace-Id");
    return raw == null || raw.isBlank() ? "trace-http" : raw.trim();
  }
}

record DesignerDraftMutationRequest(String appCode, String objectCode, String name, Long revision, List<DesignerFieldRequest> fields) {}

record DesignerFieldRequest(String code, String name, String type, boolean required) {}

record DesignerDraftLocateRequest(String appCode, String objectCode) {}

record DesignerDraftListRequest(String appCode) {}

record DesignerDraftDeleteRequest(String appCode, String objectCode, Long revision) {}

record DesignerDraftPublishRequest(String appCode, String objectCode, Long revision) {}
