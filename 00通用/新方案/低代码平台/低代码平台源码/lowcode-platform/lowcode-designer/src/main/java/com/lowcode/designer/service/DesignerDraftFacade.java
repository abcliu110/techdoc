package com.lowcode.designer.service;

import com.lowcode.common.error.ErrorCode;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * 设计态草稿门面。
 *
 * <p>当前实现使用内存存储，承担对象草稿 add/update/get/list/del/validate/publish/preview 的最小闭环。
 * 数据键包含 tenantId + appCode + objectCode，避免跨租户串读。
 */
@Service
public class DesignerDraftFacade {

  private static final Set<String> ALLOWED_FIELD_TYPES = Set.of("text", "number", "select");

  private final Map<String, ObjectDraft> drafts = new LinkedHashMap<>();
  private final PublishSnapshotSink publishSnapshotSink;

  public DesignerDraftFacade() {
    this(PublishSnapshotSink.noop());
  }

  @Autowired
  public DesignerDraftFacade(PublishSnapshotSink publishSnapshotSink) {
    this.publishSnapshotSink = publishSnapshotSink;
  }

  /**
   * 新增草稿。
   *
   * @param tenantId 租户标识
   * @param command 草稿命令
   * @return 新建后的草稿
   */
  public Object add(Long tenantId, String appCode, String objectCode, String name, Long revision, List<FieldDraft> fields) {
    DraftMutationCommand command = new DraftMutationCommand(appCode, objectCode, name, revision, fields);
    ValidateResult validation = validateDraft(command);
    if (!validation.valid()) {
      throw new DesignerApiException(ErrorCode.PARAM_INVALID, "设计态草稿校验失败", validation);
    }
    ObjectDraft draft = new ObjectDraft(
        tenantId,
        command.appCode(),
        command.objectCode(),
        command.name(),
        1L,
        List.copyOf(command.fields()),
        null,
        null);
    drafts.put(key(tenantId, command.appCode(), command.objectCode()), draft);
    return draft;
  }

  /**
   * 更新草稿。
   *
   * @param tenantId 租户标识
   * @param command 更新命令
   * @return 更新后的草稿
   */
  public Object update(Long tenantId, String appCode, String objectCode, String name, Long revision, List<FieldDraft> fields) {
    DraftMutationCommand command = new DraftMutationCommand(appCode, objectCode, name, revision, fields);
    ValidateResult validation = validateDraft(command);
    if (!validation.valid()) {
      throw new DesignerApiException(ErrorCode.PARAM_INVALID, "设计态草稿校验失败", validation);
    }
    ObjectDraft current = requireDraft(tenantId, command.appCode(), command.objectCode());
    if (command.revision() == null || !Objects.equals(current.revision(), command.revision())) {
      throw new DesignerApiException(ErrorCode.META_CONFLICT, "设计态草稿版本冲突", null);
    }
    ObjectDraft updated = new ObjectDraft(
        tenantId,
        command.appCode(),
        command.objectCode(),
        command.name(),
        current.revision() + 1,
        List.copyOf(command.fields()),
        current.publishedMetaHash(),
        current.publishedSnapshot());
    drafts.put(key(tenantId, command.appCode(), command.objectCode()), updated);
    return updated;
  }

  /**
   * 获取草稿。
   *
   * @param tenantId 租户标识
   * @param command 定位命令
   * @return 当前草稿
   */
  public Object get(Long tenantId, String appCode, String objectCode) {
    return requireDraft(tenantId, appCode, objectCode);
  }

  /**
   * 列出某个应用下的对象草稿。
   *
   * @param tenantId 租户标识
   * @param command 列表命令
   * @return 草稿摘要列表
   */
  public Object list(Long tenantId, String appCode) {
    List<ObjectDraftSummary> records = drafts.values().stream()
        .filter(draft -> Objects.equals(draft.tenantId(), tenantId))
        .filter(draft -> Objects.equals(draft.appCode(), appCode))
        .map(draft -> new ObjectDraftSummary(draft.appCode(), draft.objectCode(), draft.name(), draft.revision(), draft.fields().size()))
        .toList();
    return new DraftListResult(records);
  }

  /**
   * 删除草稿。
   *
   * @param tenantId 租户标识
   * @param command 删除命令
   * @return 删除结果
   */
  public Object delete(Long tenantId, String appCode, String objectCode, Long revision) {
    ObjectDraft current = requireDraft(tenantId, appCode, objectCode);
    if (revision == null || !Objects.equals(current.revision(), revision)) {
      throw new DesignerApiException(ErrorCode.META_CONFLICT, "设计态草稿版本冲突", null);
    }
    drafts.remove(key(tenantId, appCode, objectCode));
    return new DeleteDraftResult(true);
  }

  /**
   * 校验草稿。
   *
   * @param tenantId 租户标识
   * @param command 定位命令
   * @return 校验结果
   */
  public Object validate(Long tenantId, String appCode, String objectCode) {
    ObjectDraft draft = requireDraft(tenantId, appCode, objectCode);
    return validateDraft(new DraftMutationCommand(draft.appCode(), draft.objectCode(), draft.name(), draft.revision(), draft.fields()));
  }

  /**
   * 发布草稿。
   *
   * @param tenantId 租户标识
   * @param command 发布命令
   * @return 发布快照
   */
  public Object publish(Long tenantId, String appCode, String objectCode, Long revision) {
    ObjectDraft current = requireDraft(tenantId, appCode, objectCode);
    if (revision == null || !Objects.equals(current.revision(), revision)) {
      throw new DesignerApiException(ErrorCode.META_CONFLICT, "设计态草稿版本冲突", null);
    }
    ValidateResult validation = (ValidateResult) validate(tenantId, appCode, objectCode);
    if (!validation.valid()) {
      throw new DesignerApiException(ErrorCode.PARAM_INVALID, "设计态草稿校验失败", validation);
    }
    PublishedSnapshot snapshot = buildSnapshot(current);
    ObjectDraft published = new ObjectDraft(
        current.tenantId(),
        current.appCode(),
        current.objectCode(),
        current.name(),
        current.revision(),
        current.fields(),
        snapshot.metaHash(),
        snapshot);
    drafts.put(key(tenantId, appCode, objectCode), published);
    publishSnapshotSink.save(new PublishedSnapshotRecord(
        tenantId,
        appCode,
        objectCode,
        current.name(),
        current.fields(),
        snapshot));
    return new PublishResult(snapshot);
  }

  /**
   * 预览草稿。
   *
   * @param tenantId 租户标识
   * @param command 定位命令
   * @return 预览结果
   */
  public Object preview(Long tenantId, String appCode, String objectCode) {
    ObjectDraft current = requireDraft(tenantId, appCode, objectCode);
    PublishedSnapshot snapshot = current.publishedSnapshot() == null ? buildSnapshot(current) : current.publishedSnapshot();
    return new PreviewResult(snapshot.object(), snapshot.fields(), snapshot.defaultPages(), snapshot.metaVersion(), snapshot.metaHash());
  }

  private ObjectDraft requireDraft(Long tenantId, String appCode, String objectCode) {
    ObjectDraft draft = drafts.get(key(tenantId, appCode, objectCode));
    if (draft == null) {
      throw new DesignerApiException(ErrorCode.PARAM_INVALID, "设计态草稿不存在", null);
    }
    return draft;
  }

  private ValidateResult validateDraft(DraftMutationCommand command) {
    List<FieldValidationError> errors = new ArrayList<>();
    if (command.objectCode() == null || command.objectCode().isBlank()) {
      errors.add(new FieldValidationError("objectCode", "对象编码不能为空"));
    }
    if (command.name() == null || command.name().isBlank()) {
      errors.add(new FieldValidationError("name", "对象名称不能为空"));
    }
    Set<String> seenCodes = new LinkedHashSet<>();
    List<FieldDraft> fields = command.fields() == null ? List.of() : command.fields();
    for (int index = 0; index < fields.size(); index++) {
      FieldDraft field = fields.get(index);
      String code = field.code() == null ? "" : field.code().trim();
      if (!seenCodes.add(code)) {
        errors.add(new FieldValidationError("fields[" + index + "].code", "字段编码重复"));
      }
      if (!ALLOWED_FIELD_TYPES.contains(field.type())) {
        errors.add(new FieldValidationError("fields[" + index + "].type", "未知字段类型"));
      }
    }
    return new ValidateResult(errors.isEmpty(), List.copyOf(errors));
  }

  private PublishedSnapshot buildSnapshot(ObjectDraft draft) {
    List<PublishedField> fields = draft.fields().stream()
        .map(field -> new PublishedField(field.code(), field.name(), field.type(), field.required()))
        .toList();
    String metaHash = DesignerDraftModels.buildMetaHash(draft);
    return new PublishedSnapshot(
        new PublishedObject(draft.objectCode(), draft.name()),
        fields,
        DesignerDraftModels.buildDefaultPages(draft),
        draft.appCode() + ":" + draft.objectCode() + ":" + draft.revision(),
        metaHash);
  }

  private String key(Long tenantId, String appCode, String objectCode) {
    return tenantId + ":" + appCode + ":" + objectCode;
  }
}
