package com.lowcode.runtime.data;

import com.lowcode.runtime.permission.AccessView;
import com.lowcode.runtime.permission.FieldAccess;
import com.lowcode.runtime.permission.Operation;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * 引用追踪运行时服务。
 *
 * <p>上查和下查都必须按当前权限裁剪，未授权目标统一表现为空结果，不泄露存在性。
 */
public class LinkTraceRuntimeService {

  private final Map<String, List<LinkEdge>> edgesByTraceCode = new LinkedHashMap<>();

  public void register(
      String traceCode,
      Long sourceTenantId,
      String sourceObjectCode,
      String sourceRecordLid,
      Long targetTenantId,
      String targetObjectCode,
      String targetRecordLid) {
    edgesByTraceCode.computeIfAbsent(traceCode, ignored -> new ArrayList<>())
        .add(new LinkEdge(sourceTenantId, sourceObjectCode, sourceRecordLid, targetTenantId, targetObjectCode, targetRecordLid));
  }

  public List<LinkTraceNode> traceDown(
      String traceCode,
      InMemoryDynamicDataService sourceService,
      RuntimeExecutionContext sourceContext,
      AccessView sourceAccessView,
      String sourceRecordLid,
      InMemoryDynamicDataService targetService,
      RuntimeExecutionContext targetContext,
      AccessView targetAccessView,
      String titleFieldCode) {
    requireReadable(sourceAccessView);
    return edgesByTraceCode.getOrDefault(traceCode, List.of()).stream()
        .filter(edge -> Objects.equals(edge.sourceTenantId(), sourceContext.tenantId()))
        .filter(edge -> Objects.equals(edge.sourceObjectCode(), sourceContext.objectCode()))
        .filter(edge -> Objects.equals(edge.sourceRecordLid(), sourceRecordLid))
        .map(edge -> toNode(targetService, targetContext, targetAccessView, edge.targetTenantId(), edge.targetRecordLid(), titleFieldCode))
        .filter(Objects::nonNull)
        .toList();
  }

  public List<LinkTraceNode> traceUp(
      String traceCode,
      InMemoryDynamicDataService targetService,
      RuntimeExecutionContext targetContext,
      AccessView targetAccessView,
      String targetRecordLid,
      InMemoryDynamicDataService sourceService,
      RuntimeExecutionContext sourceContext,
      AccessView sourceAccessView,
      String titleFieldCode) {
    requireReadable(targetAccessView);
    return edgesByTraceCode.getOrDefault(traceCode, List.of()).stream()
        .filter(edge -> Objects.equals(edge.targetTenantId(), targetContext.tenantId()))
        .filter(edge -> Objects.equals(edge.targetObjectCode(), targetContext.objectCode()))
        .filter(edge -> Objects.equals(edge.targetRecordLid(), targetRecordLid))
        .map(edge -> toNode(sourceService, sourceContext, sourceAccessView, edge.sourceTenantId(), edge.sourceRecordLid(), titleFieldCode))
        .filter(Objects::nonNull)
        .toList();
  }

  private LinkTraceNode toNode(
      InMemoryDynamicDataService service,
      RuntimeExecutionContext context,
      AccessView accessView,
      Long requiredTenantId,
      String recordLid,
      String titleFieldCode) {
    if (!Objects.equals(context.tenantId(), requiredTenantId)) {
      return null;
    }
    if (!accessView.can(Operation.READ) || accessView.fieldAccess(titleFieldCode) == FieldAccess.NONE) {
      return null;
    }
    try {
      Map<String, Object> row = service.get(context, accessView, recordLid, java.util.Set.of(titleFieldCode));
      return new LinkTraceNode(recordLid, String.valueOf(row.getOrDefault(titleFieldCode, "")));
    } catch (RuntimeDataException ex) {
      return null;
    }
  }

  private void requireReadable(AccessView accessView) {
    if (!accessView.can(Operation.READ)) {
      throw new RuntimeDataException(RuntimeDataErrorCode.PERMISSION_DENIED, "无读取权限");
    }
  }
}

record LinkTraceNode(String recordLid, String title) {}

record LinkEdge(
    Long sourceTenantId,
    String sourceObjectCode,
    String sourceRecordLid,
    Long targetTenantId,
    String targetObjectCode,
    String targetRecordLid) {}
