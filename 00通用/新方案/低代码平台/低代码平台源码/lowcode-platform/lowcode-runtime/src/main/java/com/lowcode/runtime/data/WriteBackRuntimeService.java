package com.lowcode.runtime.data;

import com.lowcode.runtime.permission.AccessView;
import com.lowcode.runtime.permission.FieldAccess;
import com.lowcode.runtime.permission.Operation;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 反写运行时服务。
 *
 * <p>首版支持聚合反写、事件去重和死信/修复状态模型，不引入额外依赖。
 */
public class WriteBackRuntimeService {

  private final DynamicObjectDefinition sourceDefinition;
  private final DynamicRecordRepository sourceRepository;
  private final DynamicObjectDefinition targetDefinition;
  private final InMemoryDynamicDataService targetService;
  private final Map<String, WriteBackResult> eventResults = new LinkedHashMap<>();
  private final Map<String, WriteBackDeadLetter> deadLetters = new LinkedHashMap<>();

  public WriteBackRuntimeService(
      DynamicObjectDefinition sourceDefinition,
      DynamicRecordRepository sourceRepository,
      DynamicObjectDefinition targetDefinition,
      InMemoryDynamicDataService targetService) {
    this.sourceDefinition = sourceDefinition;
    this.sourceRepository = sourceRepository;
    this.targetDefinition = targetDefinition;
    this.targetService = targetService;
  }

  public WriteBackResult writeBack(WriteBackCommand command) {
    WriteBackResult replay = eventResults.get(command.eventId());
    if (replay != null) {
      return replay.replayed() ? replay : new WriteBackResult(replay.writeBackCode(), replay.targetRecordLid(), replay.targetRevision(), replay.state(), true);
    }
    try {
      BigDecimal total = BigDecimal.ZERO;
      for (String sourceRecordLid : command.sourceRecordLids()) {
        DynamicRecord sourceRecord = sourceRepository.require(sourceDefinition, command.sourceContext(), sourceRecordLid);
        Object value = sourceRecord.values().get(command.sourceFieldCode());
        total = total.add(value instanceof BigDecimal decimal ? decimal : new BigDecimal(String.valueOf(value)));
      }
      if (!command.targetAccessView().can(Operation.UPDATE)
          || command.targetAccessView().fieldAccess(command.targetFieldCode()) != FieldAccess.WRITE) {
        throw new RuntimeDataException(RuntimeDataErrorCode.PERMISSION_DENIED, "反写目标字段无权限");
      }
      UpdateRecordResult updated = targetService.update(
          command.targetContext(),
          command.targetAccessView(),
          new UpdateRecordCommand(command.targetRecordLid(), command.targetRevision(), Map.of(command.targetFieldCode(), total), command.targetContext().metaHash()));
      WriteBackState state = deadLetters.containsKey(command.eventId()) ? WriteBackState.REPAIRED : WriteBackState.SUCCESS;
      WriteBackResult result = new WriteBackResult(command.writeBackCode(), updated.recordLid(), updated.revision(), state, false);
      eventResults.put(command.eventId(), result);
      if (deadLetters.containsKey(command.eventId())) {
        deadLetters.put(command.eventId(), new WriteBackDeadLetter(command.eventId(), command.writeBackCode(), WriteBackState.REPAIRED, "已修复"));
      }
      return result;
    } catch (RuntimeDataException ex) {
      WriteBackResult failed = new WriteBackResult(command.writeBackCode(), command.targetRecordLid(), command.targetRevision(), WriteBackState.DEAD_LETTER, false);
      eventResults.put(command.eventId(), failed);
      deadLetters.put(command.eventId(), new WriteBackDeadLetter(command.eventId(), command.writeBackCode(), WriteBackState.DEAD_LETTER, ex.getMessage()));
      return failed;
    }
  }

  public void markRepairPending(String eventId) {
    WriteBackDeadLetter current = deadLetters.get(eventId);
    if (current != null) {
      deadLetters.put(eventId, new WriteBackDeadLetter(current.eventId(), current.writeBackCode(), WriteBackState.REPAIR_PENDING, current.reason()));
      eventResults.remove(eventId);
    }
  }

  public WriteBackResult retryDeadLetter(WriteBackCommand command) {
    return writeBack(command);
  }

  public List<WriteBackDeadLetter> deadLetters() {
    return new ArrayList<>(deadLetters.values());
  }
}

record WriteBackCommand(
    String writeBackCode,
    RuntimeExecutionContext sourceContext,
    AccessView sourceAccessView,
    List<String> sourceRecordLids,
    String sourceFieldCode,
    RuntimeExecutionContext targetContext,
    AccessView targetAccessView,
    String targetRecordLid,
    Long targetRevision,
    String targetFieldCode,
    String eventId) {

  WriteBackCommand {
    sourceRecordLids = List.copyOf(sourceRecordLids);
  }
}

record WriteBackResult(
    String writeBackCode,
    String targetRecordLid,
    Long targetRevision,
    WriteBackState state,
    boolean replayed) {}

record WriteBackDeadLetter(String eventId, String writeBackCode, WriteBackState state, String reason) {}

enum WriteBackState {
  SUCCESS,
  DEAD_LETTER,
  REPAIR_PENDING,
  REPAIRED
}
