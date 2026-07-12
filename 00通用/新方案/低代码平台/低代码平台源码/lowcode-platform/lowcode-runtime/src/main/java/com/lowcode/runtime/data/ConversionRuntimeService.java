package com.lowcode.runtime.data;

import com.lowcode.runtime.permission.AccessView;
import com.lowcode.runtime.permission.FieldAccess;
import com.lowcode.runtime.permission.Operation;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * 单据转换运行时服务。
 *
 * <p>当前实现固定复用统一写入口和幂等仓储，先锁定字段映射、权限校验、链路深度和审计语义。
 */
public class ConversionRuntimeService {

  private final DynamicObjectDefinition sourceDefinition;
  private final DynamicRecordRepository sourceRepository;
  private final DynamicObjectDefinition targetDefinition;
  private final InMemoryDynamicDataService targetService;
  private final RuntimeSideEffectRepository sideEffectRepository;

  public ConversionRuntimeService(
      DynamicObjectDefinition sourceDefinition,
      DynamicRecordRepository sourceRepository,
      DynamicObjectDefinition targetDefinition,
      InMemoryDynamicDataService targetService,
      RuntimeSideEffectRepository sideEffectRepository) {
    this.sourceDefinition = sourceDefinition;
    this.sourceRepository = sourceRepository;
    this.targetDefinition = targetDefinition;
    this.targetService = targetService;
    this.sideEffectRepository = sideEffectRepository;
  }

  public ConversionResult convert(ConversionCommand command) {
    requireTenant(command.sourceContext());
    requireTenant(command.targetContext());
    if (command.depth() > command.maxDepth()) {
      throw new RuntimeDataException(RuntimeDataErrorCode.CHAIN_DEPTH_EXCEEDED, "转换链深度超限");
    }
    RuntimeIdempotencyEntry replay = sideEffectRepository.findIdempotency(command.targetContext(), "conversion", command.idempotencyKey());
    if (replay != null) {
      return new ConversionResult(command.conversionCode(), replay.recordLid(), replay.revision(), true);
    }
    if (!command.sourceAccessView().can(Operation.READ) || !command.targetAccessView().can(Operation.CREATE)) {
      throw new RuntimeDataException(RuntimeDataErrorCode.PERMISSION_DENIED, "无权限执行单据转换");
    }
    DynamicRecord sourceRecord = sourceRepository.require(sourceDefinition, command.sourceContext(), command.sourceRecordLid());
    Map<String, Object> targetValues = new LinkedHashMap<>();
    command.fieldMapping().forEach((sourceField, targetField) -> {
      requireReadable(command.sourceAccessView(), sourceField);
      requireWritable(command.targetAccessView(), targetField);
      requireTargetField(targetField);
      targetValues.put(targetField, sourceRecord.values().get(sourceField));
    });
    AddRecordResult created = targetService.add(
        command.targetContext(),
        command.targetAccessView(),
        new AddRecordCommand(targetValues, command.targetContext().metaHash(), command.idempotencyKey()));
    sideEffectRepository.saveIdempotency(
        command.targetContext(),
        new RuntimeIdempotencyEntry("conversion", command.idempotencyKey(), created.recordLid(), null, null, created.revision()));
    sideEffectRepository.appendAudit(
        command.targetContext(),
        new AuditLog("conversion:" + command.conversionCode(), command.targetContext().traceId(), command.targetContext().metaHash(), command.targetAccessView().permVersion()));
    return new ConversionResult(command.conversionCode(), created.recordLid(), created.revision(), false);
  }

  private void requireTenant(RuntimeExecutionContext context) {
    if (context.tenantId() == null) {
      throw new RuntimeDataException(RuntimeDataErrorCode.TENANT_REQUIRED, "租户不能为空");
    }
  }

  private void requireReadable(AccessView accessView, String fieldCode) {
    if (accessView.fieldAccess(fieldCode) == FieldAccess.NONE) {
      throw new RuntimeDataException(RuntimeDataErrorCode.PERMISSION_DENIED, "来源字段无读取权限");
    }
  }

  private void requireWritable(AccessView accessView, String fieldCode) {
    if (accessView.fieldAccess(fieldCode) != FieldAccess.WRITE) {
      throw new RuntimeDataException(RuntimeDataErrorCode.PERMISSION_DENIED, "目标字段无写权限");
    }
  }

  private void requireTargetField(String fieldCode) {
    if (!targetDefinition.fields().containsKey(fieldCode)) {
      throw new RuntimeDataException(RuntimeDataErrorCode.SQL_WHITELIST_VIOLATION, "目标字段不在白名单内");
    }
  }
}

record ConversionCommand(
    String conversionCode,
    RuntimeExecutionContext sourceContext,
    AccessView sourceAccessView,
    String sourceRecordLid,
    RuntimeExecutionContext targetContext,
    AccessView targetAccessView,
    Map<String, String> fieldMapping,
    String idempotencyKey,
    int depth,
    int maxDepth) {

  ConversionCommand {
    fieldMapping = Map.copyOf(fieldMapping);
  }
}

record ConversionResult(String conversionCode, String targetRecordLid, Long targetRevision, boolean replayed) {}
