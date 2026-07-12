package com.lowcode.runtime.api;

import com.lowcode.runtime.data.AddRecordCommand;
import com.lowcode.runtime.data.AddRecordResult;
import com.lowcode.runtime.data.DeleteRecordCommand;
import com.lowcode.runtime.data.DeleteRecordResult;
import com.lowcode.runtime.data.DynamicRecordRepository;
import com.lowcode.runtime.data.DynamicObjectDefinition;
import com.lowcode.runtime.data.InMemoryDynamicDataService;
import com.lowcode.runtime.data.ListRecordCommand;
import com.lowcode.runtime.data.RuntimeSideEffectRepository;
import com.lowcode.runtime.data.RuntimeExecutionContext;
import com.lowcode.runtime.data.TransitionCommand;
import com.lowcode.runtime.data.TransitionResult;
import com.lowcode.runtime.data.UpdateRecordCommand;
import com.lowcode.runtime.data.UpdateRecordResult;
import com.lowcode.runtime.permission.AccessExplain;
import com.lowcode.runtime.permission.AccessView;
import com.lowcode.runtime.permission.Operation;
import com.lowcode.runtime.permission.RuntimePermissionCenter;
import com.lowcode.runtime.permission.DefaultRuntimePermissionCenter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;

/**
 * M1 运行态 API 门面。
 *
 * <p>该门面模拟 `/api/data/{appCode}/{objectCode}` 的服务层入口，把上下文固定、权限视图、导入预览、导出裁剪和指标采集收束到一处。
 */
public class RuntimeApiFacade {

  private static final String ANY_APP = "*";

  private final Map<String, InMemoryDynamicDataService> services = new LinkedHashMap<>();
  private final Map<String, DynamicObjectDefinition> definitions = new LinkedHashMap<>();
  private final Map<String, ImportPreviewState> previews = new LinkedHashMap<>();
  private final Map<String, ImportCommitResult> importIdempotency = new LinkedHashMap<>();
  private final List<PlatformMetricEvent> metrics = new ArrayList<>();
  private final Function<DynamicObjectDefinition, DynamicRecordRepository> repositoryFactory;
  private final Function<DynamicObjectDefinition, RuntimeSideEffectRepository> sideEffectRepositoryFactory;
  private final RuntimePermissionCenter permissionCenter;

  public RuntimeApiFacade() {
    this.repositoryFactory = null;
    this.sideEffectRepositoryFactory = null;
    this.permissionCenter = new DefaultRuntimePermissionCenter();
  }

  public RuntimeApiFacade(RuntimePermissionCenter permissionCenter) {
    this.repositoryFactory = null;
    this.sideEffectRepositoryFactory = null;
    this.permissionCenter = permissionCenter == null ? new DefaultRuntimePermissionCenter() : permissionCenter;
  }

  public RuntimeApiFacade(Function<DynamicObjectDefinition, DynamicRecordRepository> repositoryFactory) {
    this.repositoryFactory = repositoryFactory;
    this.sideEffectRepositoryFactory = null;
    this.permissionCenter = new DefaultRuntimePermissionCenter();
  }

  public RuntimeApiFacade(
      Function<DynamicObjectDefinition, DynamicRecordRepository> repositoryFactory,
      Function<DynamicObjectDefinition, RuntimeSideEffectRepository> sideEffectRepositoryFactory) {
    this.repositoryFactory = repositoryFactory;
    this.sideEffectRepositoryFactory = sideEffectRepositoryFactory;
    this.permissionCenter = new DefaultRuntimePermissionCenter();
  }

  public void registerObject(DynamicObjectDefinition definition) {
    registerObject(ANY_APP, definition);
  }

  public void registerObject(String appCode, DynamicObjectDefinition definition) {
    String key = definitionKey(appCode, definition.objectCode());
    definitions.put(key, definition);
    if (repositoryFactory == null) {
      services.put(key, new InMemoryDynamicDataService(definition));
      return;
    }
    if (sideEffectRepositoryFactory == null) {
      services.put(key, new InMemoryDynamicDataService(definition, repositoryFactory.apply(definition)));
      return;
    }
    services.put(key, new InMemoryDynamicDataService(
        definition,
        repositoryFactory.apply(definition),
        sideEffectRepositoryFactory.apply(definition)));
  }

  public AddRecordResult add(RuntimeRequestContext requestContext, AddRecordCommand command) {
    try {
      AddRecordResult result = service(requestContext).add(toExecutionContext(requestContext), accessView(requestContext), command);
      metrics.add(PlatformMetricEvent.safe("record.created", requestContext.tenantId(), requestContext.appCode(), requestContext.objectCode(), requestContext.traceId()));
      return result;
    } catch (RuntimeException ex) {
      throw new RuntimeApiException(ex.getMessage(), ex);
    }
  }

  public List<Map<String, Object>> list(RuntimeRequestContext requestContext, ListRecordCommand command) {
    try {
      return service(requestContext).list(toExecutionContext(requestContext), accessView(requestContext), command);
    } catch (RuntimeException ex) {
      throw new RuntimeApiException(ex.getMessage(), ex);
    }
  }

  public RuntimeObjectMeta meta(RuntimeRequestContext requestContext) {
    try {
      accessView(requestContext);
      DynamicObjectDefinition definition = definition(requestContext);
      return new RuntimeObjectMeta(
          requestContext.appCode(),
          requestContext.objectCode(),
          requestContext.metaHash(),
          List.copyOf(definition.fields().keySet()));
    } catch (RuntimeException ex) {
      throw new RuntimeApiException(ex.getMessage(), ex);
    }
  }

  public Map<String, Object> get(RuntimeRequestContext requestContext, String recordLid, Set<String> fields) {
    try {
      return service(requestContext).get(toExecutionContext(requestContext), accessView(requestContext), recordLid, fields);
    } catch (RuntimeException ex) {
      throw new RuntimeApiException(ex.getMessage(), ex);
    }
  }

  public UpdateRecordResult update(RuntimeRequestContext requestContext, UpdateRecordCommand command) {
    try {
      return service(requestContext).update(toExecutionContext(requestContext), accessView(requestContext), command);
    } catch (RuntimeException ex) {
      throw new RuntimeApiException(ex.getMessage(), ex);
    }
  }

  public DeleteRecordResult delete(RuntimeRequestContext requestContext, DeleteRecordCommand command) {
    try {
      DeleteRecordResult result = service(requestContext).delete(toExecutionContext(requestContext), accessView(requestContext), command);
      metrics.add(PlatformMetricEvent.safe("record.deleted", requestContext.tenantId(), requestContext.appCode(), requestContext.objectCode(), requestContext.traceId()));
      return result;
    } catch (RuntimeException ex) {
      throw new RuntimeApiException(ex.getMessage(), ex);
    }
  }

  public TransitionResult transition(RuntimeRequestContext requestContext, TransitionCommand command) {
    try {
      TransitionResult result = service(requestContext).transition(toExecutionContext(requestContext), accessView(requestContext), command);
      metrics.add(PlatformMetricEvent.safe("state.transitioned", requestContext.tenantId(), requestContext.appCode(), requestContext.objectCode(), requestContext.traceId()));
      return result;
    } catch (RuntimeException ex) {
      throw new RuntimeApiException(ex.getMessage(), ex);
    }
  }

  public List<Map<String, Object>> export(RuntimeRequestContext requestContext, Set<String> fields) {
    return list(requestContext, new ListRecordCommand(fields, List.of(), List.of(), 1, 200));
  }

  public List<Map<String, Object>> suggest(RuntimeRequestContext requestContext, String keyword, Set<String> fields, int limit) {
    Set<String> requested = fields == null || fields.isEmpty() ? definition(requestContext).fields().keySet() : fields;
    String safeKeyword = keyword == null ? "" : keyword;
    int safeLimit = Math.max(1, Math.min(limit, 20));
    return list(requestContext, new ListRecordCommand(requested, List.of(), List.of(), 1, safeLimit)).stream()
        .filter(row -> row.values().stream().anyMatch(value -> value != null && String.valueOf(value).contains(safeKeyword)))
        .limit(safeLimit)
        .toList();
  }

  public AccessExplain explain(RuntimeRequestContext requestContext, Operation operation) {
    try {
      AccessView accessView = accessView(requestContext);
      boolean allowed = accessView.can(operation);
      return new AccessExplain(allowed, allowed ? accessView.explain().reasons() : List.of("运行态默认权限拒绝"));
    } catch (RuntimeException ex) {
      throw new RuntimeApiException(ex.getMessage(), ex);
    }
  }

  public ImportPreview importPreview(RuntimeRequestContext requestContext, List<Map<String, Object>> rows) {
    try {
      accessView(requestContext);
      String taskId = requestContext.traceId() + "-import";
      List<String> errors = new ArrayList<>();
      DynamicObjectDefinition definition = definition(requestContext);
      for (int i = 0; i < rows.size(); i++) {
        for (String field : rows.get(i).keySet()) {
          if (!definition.fields().containsKey(field)) {
            errors.add("第 " + (i + 1) + " 行字段 " + field + " 不存在");
          }
        }
      }
      ImportPreview preview = new ImportPreview(taskId, rows, errors);
      previews.put(taskId, new ImportPreviewState(
          requestContext.tenantId(),
          requestContext.workspaceId(),
          requestContext.appCode(),
          requestContext.objectCode(),
          preview));
      return preview;
    } catch (RuntimeException ex) {
      throw new RuntimeApiException(ex.getMessage(), ex);
    }
  }

  public ImportCommitResult importCommit(RuntimeRequestContext requestContext, String taskId, String idempotencyKey) {
    try {
      accessView(requestContext);
      String key = requestContext.tenantId()
          + ":"
          + requestContext.workspaceId()
          + ":"
          + requestContext.appCode()
          + ":"
          + requestContext.objectCode()
          + ":"
          + taskId
          + ":"
          + idempotencyKey;
      ImportCommitResult replay = importIdempotency.get(key);
      if (replay != null) {
        return replay;
      }
      ImportPreviewState state = previews.get(taskId);
      if (state == null || !state.matches(requestContext) || !state.preview().errors().isEmpty()) {
        throw new RuntimeApiException("导入预览不存在或存在错误");
      }
      int created = 0;
      for (Map<String, Object> row : state.preview().rows()) {
        add(requestContext, new AddRecordCommand(row, requestContext.metaHash(), idempotencyKey + "-" + created));
        created++;
      }
      ImportCommitResult result = new ImportCommitResult(taskId, created);
      importIdempotency.put(key, result);
      return result;
    } catch (RuntimeException ex) {
      throw new RuntimeApiException(ex.getMessage(), ex);
    }
  }

  public List<PlatformMetricEvent> metrics() {
    return List.copyOf(metrics);
  }

  private InMemoryDynamicDataService service(RuntimeRequestContext requestContext) {
    InMemoryDynamicDataService service = services.get(definitionKey(requestContext));
    if (service == null) {
      service = services.get(definitionKey(ANY_APP, requestContext.objectCode()));
    }
    if (service == null) {
      throw new RuntimeApiException("对象不存在");
    }
    return service;
  }

  private DynamicObjectDefinition definition(RuntimeRequestContext requestContext) {
    DynamicObjectDefinition definition = definitions.get(definitionKey(requestContext));
    if (definition == null) {
      definition = definitions.get(definitionKey(ANY_APP, requestContext.objectCode()));
    }
    if (definition == null) {
      throw new RuntimeApiException("OBJECT_NOT_FOUND", "对象不存在");
    }
    return definition;
  }

  private String definitionKey(RuntimeRequestContext requestContext) {
    return definitionKey(requestContext.appCode(), requestContext.objectCode());
  }

  private String definitionKey(String appCode, String objectCode) {
    return appCode + ":" + objectCode;
  }

  private RuntimeExecutionContext toExecutionContext(RuntimeRequestContext requestContext) {
    return new RuntimeExecutionContext(
        requestContext.tenantId(),
        requestContext.workspaceId(),
        requestContext.userLid(),
        requestContext.roleCodes(),
        requestContext.appCode(),
        requestContext.objectCode(),
        requestContext.metaHash(),
        requestContext.traceId());
  }

  private record ImportPreviewState(
      Long tenantId,
      Long workspaceId,
      String appCode,
      String objectCode,
      ImportPreview preview) {

    boolean matches(RuntimeRequestContext requestContext) {
      return java.util.Objects.equals(tenantId, requestContext.tenantId())
          && java.util.Objects.equals(workspaceId, requestContext.workspaceId())
          && java.util.Objects.equals(appCode, requestContext.appCode())
          && java.util.Objects.equals(objectCode, requestContext.objectCode());
    }
  }

  private AccessView accessView(RuntimeRequestContext requestContext) {
    return permissionCenter.authorize(requestContext, definition(requestContext));
  }
}
