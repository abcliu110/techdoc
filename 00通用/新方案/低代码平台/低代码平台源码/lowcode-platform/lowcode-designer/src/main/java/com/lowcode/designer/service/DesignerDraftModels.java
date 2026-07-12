package com.lowcode.designer.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 设计态草稿与发布快照模型。
 *
 * <p>模型保持最小可用：对象草稿、字段定义、校验结果、默认页面 schema 与发布快照。
 */
public final class DesignerDraftModels {

  private DesignerDraftModels() {}

  public static String buildMetaHash(ObjectDraft draft) {
    String seed = draft.appCode() + "|" + draft.objectCode() + "|" + draft.name() + "|" + draft.revision()
        + "|" + draft.fields().stream()
            .map(field -> field.code() + ":" + field.name() + ":" + field.type() + ":" + field.required())
            .reduce((left, right) -> left + "|" + right)
            .orElse("");
    try {
      return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(seed.getBytes(StandardCharsets.UTF_8)));
    } catch (NoSuchAlgorithmException ex) {
      throw new IllegalStateException("JDK 缺少 SHA-256 算法", ex);
    }
  }

  public static DefaultPages buildDefaultPages(ObjectDraft draft) {
    List<String> fieldCodes = draft.fields().stream().map(FieldDraft::code).toList();
    return new DefaultPages(
        new PageSchema("list", Map.of("columns", fieldCodes)),
        new PageSchema("form", Map.of("fields", fieldCodes)),
        new PageSchema("detail", Map.of("sections", fieldCodes)));
  }
}

record ObjectDraft(
    Long tenantId,
    String appCode,
    String objectCode,
    String name,
    long revision,
    List<FieldDraft> fields,
    String publishedMetaHash,
    PublishedSnapshot publishedSnapshot) {}

record ValidateResult(boolean valid, List<FieldValidationError> errors) {}

record FieldValidationError(String field, String message) {}

record DraftListResult(List<ObjectDraftSummary> records) {}

record ObjectDraftSummary(String appCode, String objectCode, String name, long revision, int fieldCount) {}

record PublishResult(PublishedSnapshot snapshot) {}

record PublishedSnapshot(
    PublishedObject object,
    List<PublishedField> fields,
    DefaultPages defaultPages,
    String metaVersion,
    String metaHash) {}

record PublishedObject(String code, String name) {}

record PublishedField(String code, String name, String type, boolean required) {}

record DefaultPages(PageSchema list, PageSchema form, PageSchema detail) {}

record PageSchema(String type, Map<String, Object> schema) {}

record DeleteDraftResult(boolean deleted) {}

record PreviewResult(
    PublishedObject object,
    List<PublishedField> fields,
    DefaultPages defaultPages,
    String metaVersion,
    String metaHash) {}

record DraftMutationCommand(String appCode, String objectCode, String name, Long revision, List<FieldDraft> fields) {}

record DraftLocateCommand(String appCode, String objectCode) {}

record DraftListCommand(String appCode) {}

record DraftDeleteCommand(String appCode, String objectCode, Long revision) {}

record DraftPublishCommand(String appCode, String objectCode, Long revision) {}
