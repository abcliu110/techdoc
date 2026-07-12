package com.lowcode.app.api;

import com.lowcode.common.error.BizException;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * M1 运行态动态数据 HTTP 入口。
 *
 * <p>Controller 只做 HTTP 协议适配、受控请求头解析和异常脱敏，业务逻辑留在 runtime 模块。
 */
@RestController
public class RuntimeDataController {

  private final RuntimeHttpFacade runtimeHttpFacade;
  private final AuthenticatedRuntimeContextResolver contextResolver;
  private final ApiErrorResponseFactory errorResponseFactory;

  RuntimeDataController(
      RuntimeHttpFacade runtimeHttpFacade,
      AuthenticatedRuntimeContextResolver contextResolver,
      ApiErrorResponseFactory errorResponseFactory) {
    this.runtimeHttpFacade = runtimeHttpFacade;
    this.contextResolver = contextResolver;
    this.errorResponseFactory = errorResponseFactory;
  }

  /**
   * 新增运行态记录。
   *
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param request 当前 HTTP 请求
   * @param command 新增命令
   * @return 新增后的记录结果
   * @throws BizException 缺少受控上下文时抛出
   * @throws RuntimeApiException 运行态处理失败时抛出安全包装异常
   */
  @PostMapping("/api/data/{appCode}/{objectCode}/add")
  Object add(
      @PathVariable("appCode") String appCode,
      @PathVariable("objectCode") String objectCode,
      HttpServletRequest request,
      @RequestBody AddRecordRequest command) {
    return runtimeHttpFacade.add(context(request, appCode, objectCode), command);
  }

  /**
   * 查询运行态记录列表。
   *
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param request 当前 HTTP 请求
   * @param listRequest 列表查询参数
   * @return 脱敏后的记录列表
   * @throws BizException 缺少受控上下文时抛出
   * @throws RuntimeApiException 运行态处理失败时抛出安全包装异常
   */
  @PostMapping("/api/data/{appCode}/{objectCode}/list")
  Object list(
      @PathVariable("appCode") String appCode,
      @PathVariable("objectCode") String objectCode,
      HttpServletRequest request,
      @RequestBody ListRequest listRequest) {
    return runtimeHttpFacade.list(
        context(request, appCode, objectCode),
        listRequest);
  }

  /**
   * 读取运行态元数据。
   *
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param request 当前 HTTP 请求
   * @return 对象元数据
   * @throws BizException 缺少受控上下文时抛出
   */
  @PostMapping("/api/data/{appCode}/{objectCode}/meta")
  Object meta(
      @PathVariable("appCode") String appCode,
      @PathVariable("objectCode") String objectCode,
      HttpServletRequest request) {
    return runtimeHttpFacade.meta(context(request, appCode, objectCode));
  }

  /**
   * 查询单条运行态记录。
   *
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param request 当前 HTTP 请求
   * @param recordRequest 读取请求
   * @return 记录详情
   * @throws BizException 缺少受控上下文时抛出
   * @throws RuntimeApiException 运行态处理失败时抛出安全包装异常
   */
  @PostMapping("/api/data/{appCode}/{objectCode}/get")
  Object get(
      @PathVariable("appCode") String appCode,
      @PathVariable("objectCode") String objectCode,
      HttpServletRequest request,
      @RequestBody RecordReadRequest recordRequest) {
    return runtimeHttpFacade.get(context(request, appCode, objectCode), recordRequest);
  }

  /**
   * 更新运行态记录。
   *
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param request 当前 HTTP 请求
   * @param command 更新命令
   * @return 更新结果
   * @throws BizException 缺少受控上下文时抛出
   * @throws RuntimeApiException 运行态处理失败时抛出安全包装异常
   */
  @PostMapping("/api/data/{appCode}/{objectCode}/update")
  Object update(
      @PathVariable("appCode") String appCode,
      @PathVariable("objectCode") String objectCode,
      HttpServletRequest request,
      @RequestBody UpdateRecordRequest command) {
    return runtimeHttpFacade.update(context(request, appCode, objectCode), command);
  }

  /**
   * 删除运行态记录。
   *
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param request 当前 HTTP 请求
   * @param command 删除命令
   * @return 删除结果
   * @throws BizException 缺少受控上下文时抛出
   * @throws RuntimeApiException 运行态处理失败时抛出安全包装异常
   */
  @PostMapping("/api/data/{appCode}/{objectCode}/del")
  Object delete(
      @PathVariable("appCode") String appCode,
      @PathVariable("objectCode") String objectCode,
      HttpServletRequest request,
      @RequestBody DeleteRecordRequest command) {
    return runtimeHttpFacade.delete(context(request, appCode, objectCode), command);
  }

  /**
   * 执行状态流转。
   *
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param request 当前 HTTP 请求
   * @param command 流转命令
   * @return 流转结果
   * @throws BizException 缺少受控上下文时抛出
   * @throws RuntimeApiException 运行态处理失败时抛出安全包装异常
   */
  @PostMapping("/api/data/{appCode}/{objectCode}/transition")
  Object transition(
      @PathVariable("appCode") String appCode,
      @PathVariable("objectCode") String objectCode,
      HttpServletRequest request,
      @RequestBody TransitionRequest command) {
    return runtimeHttpFacade.transition(context(request, appCode, objectCode), command);
  }

  /**
   * 执行业务动作。
   *
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param request 当前 HTTP 请求
   * @param command 动作命令
   * @return 动作执行结果
   * @throws BizException 缺少受控上下文时抛出
   * @throws RuntimeApiException 运行态处理失败时抛出安全包装异常
   */
  @PostMapping("/api/data/{appCode}/{objectCode}/action")
  Object action(
      @PathVariable("appCode") String appCode,
      @PathVariable("objectCode") String objectCode,
      HttpServletRequest request,
      @RequestBody TransitionRequest command) {
    return runtimeHttpFacade.transition(context(request, appCode, objectCode), command);
  }

  /**
   * 查询建议项。
   *
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param request 当前 HTTP 请求
   * @param suggestRequest 建议查询参数
   * @return 匹配到的候选项
   * @throws BizException 缺少受控上下文时抛出
   * @throws RuntimeApiException 运行态处理失败时抛出安全包装异常
   */
  @PostMapping("/api/data/{appCode}/{objectCode}/suggest")
  Object suggest(
      @PathVariable("appCode") String appCode,
      @PathVariable("objectCode") String objectCode,
      HttpServletRequest request,
      @RequestBody SuggestRequest suggestRequest) {
    return runtimeHttpFacade.suggest(context(request, appCode, objectCode), suggestRequest);
  }

  /**
   * 导出运行态数据。
   *
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param request 当前 HTTP 请求
   * @param exportRequest 导出字段请求
   * @return 导出结果
   * @throws BizException 缺少受控上下文时抛出
   * @throws RuntimeApiException 运行态处理失败时抛出安全包装异常
   */
  @PostMapping("/api/data/{appCode}/{objectCode}/export")
  Object export(
      @PathVariable("appCode") String appCode,
      @PathVariable("objectCode") String objectCode,
      HttpServletRequest request,
      @RequestBody ExportRequest exportRequest) {
    return runtimeHttpFacade.export(context(request, appCode, objectCode), exportRequest);
  }

  /**
   * 导入预览。
   *
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param request 当前 HTTP 请求
   * @param importPreviewRequest 预览请求
   * @return 导入预览结果
   * @throws BizException 缺少受控上下文时抛出
   * @throws RuntimeApiException 运行态处理失败时抛出安全包装异常
   */
  @PostMapping("/api/data/{appCode}/{objectCode}/importPreview")
  Object importPreview(
      @PathVariable("appCode") String appCode,
      @PathVariable("objectCode") String objectCode,
      HttpServletRequest request,
      @RequestBody ImportPreviewRequest importPreviewRequest) {
    return runtimeHttpFacade.importPreview(context(request, appCode, objectCode), importPreviewRequest);
  }

  /**
   * 导入提交。
   *
   * @param appCode 应用编码
   * @param objectCode 对象编码
   * @param request 当前 HTTP 请求
   * @param importCommitRequest 提交请求
   * @return 导入提交结果
   * @throws BizException 缺少受控上下文时抛出
   * @throws RuntimeApiException 运行态处理失败时抛出安全包装异常
   */
  @PostMapping("/api/data/{appCode}/{objectCode}/importCommit")
  Object importCommit(
      @PathVariable("appCode") String appCode,
      @PathVariable("objectCode") String objectCode,
      HttpServletRequest request,
      @RequestBody ImportCommitRequest importCommitRequest) {
    return runtimeHttpFacade.importCommit(context(request, appCode, objectCode), importCommitRequest);
  }

  /**
   * 解释权限判定结果。
   *
   * @param request 当前 HTTP 请求
   * @param permissionExplainRequest 权限解释请求
   * @return 权限解释结果
   * @throws BizException 缺少受控上下文时抛出
   */
  @PostMapping("/api/permission/explain")
  PermissionExplainResponse explain(
      HttpServletRequest request,
      @RequestBody PermissionExplainRequest permissionExplainRequest) {
    return runtimeHttpFacade.explain(context(request, permissionExplainRequest.appCode(), permissionExplainRequest.objectCode()), permissionExplainRequest);
  }

  @ExceptionHandler(BizException.class)
  Object handleBizException(BizException ex, HttpServletRequest request) {
    ApiErrorResponse response = errorResponseFactory.fromBizException(ex, request);
    return ResponseEntity.status(response.status()).body(response.body());
  }

  @ExceptionHandler(RuntimeException.class)
  Object handleUnexpectedRuntimeException(RuntimeException ex, HttpServletRequest request) {
    ApiErrorResponse response = errorResponseFactory.fromRuntimeException(ex, request);
    return ResponseEntity.status(response.status()).body(response.body());
  }

  private AuthenticatedRuntimeContext context(HttpServletRequest request, String appCode, String objectCode) {
    String metaHash = request.getHeader("X-Meta-Hash") == null ? "mh-1" : request.getHeader("X-Meta-Hash");
    return contextResolver.resolve(request, appCode, objectCode, metaHash);
  }
}

record ListRequest(Set<String> fields, List<Map<String, Object>> filters, List<Map<String, Object>> sorts, int pageNo, int pageSize) {}

record RecordReadRequest(String recordLid, Set<String> fields) {}

record SuggestRequest(String keyword, Set<String> fields, int limit) {}

record PermissionExplainRequest(String appCode, String objectCode, String operation) {}
