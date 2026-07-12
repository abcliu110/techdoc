package com.lowcode.app.api;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.lowcode.designer.service.FieldDraft;
import com.lowcode.designer.service.PublishSnapshotSink;
import com.lowcode.designer.service.PublishedSnapshotRecord;
import com.lowcode.metamodel.domain.def.AppSnapshotDef;
import com.lowcode.metamodel.domain.def.CommercialMetadataDef;
import com.lowcode.metamodel.domain.def.FieldDef;
import com.lowcode.metamodel.domain.def.FieldOptionsDef;
import com.lowcode.metamodel.domain.enums.FieldTypeEnum;
import com.lowcode.metamodel.domain.enums.ObjectTypeEnum;
import com.lowcode.metamodel.domain.service.MetaObjectDraft;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;
import org.springframework.jdbc.core.JdbcTemplate;

/**
 * Persists designer publish snapshots for runtime MetaGraph loading.
 */
class JdbcPublishSnapshotSink implements PublishSnapshotSink {

  private static final String FIND_APP_SQL =
      "select id from lc_meta_app where tenant_id = ? and code = ? and deleted = 0 and delete_token = 0";
  private static final String INSERT_APP_SQL =
      "insert into lc_meta_app (id, tenant_id, workspace_id, code, name, config, revision, deleted, delete_token, create_time, create_by, update_time, update_by) values (?, ?, null, ?, ?, '{}', 0, 0, 0, ?, 0, ?, 0)";
  private static final String DELETE_OLD_VERSION_SQL =
      "update lc_meta_version set deleted = 1, deleted_at = ?, delete_token = id, update_time = ? where tenant_id = ? and app_id = ? and version_no = ? and deleted = 0 and delete_token = 0";
  private static final String INSERT_VERSION_SQL =
      "insert into lc_meta_version (id, tenant_id, app_id, version_no, publish_status, snapshot, published_at, revision, deleted, delete_token, create_time, create_by, update_time, update_by) values (?, ?, ?, ?, 'PUBLISHED', ?, ?, 0, 0, 0, ?, 0, ?, 0)";

  private final JdbcTemplate jdbcTemplate;
  private final ObjectMapper objectMapper;
  private final AtomicLong idSequence;

  JdbcPublishSnapshotSink(JdbcTemplate jdbcTemplate) {
    this(jdbcTemplate, new ObjectMapper(), new AtomicLong(System.currentTimeMillis()));
  }

  JdbcPublishSnapshotSink(JdbcTemplate jdbcTemplate, ObjectMapper objectMapper, AtomicLong idSequence) {
    this.jdbcTemplate = jdbcTemplate;
    this.objectMapper = objectMapper;
    this.idSequence = idSequence;
  }

  @Override
  public void save(PublishedSnapshotRecord record) {
    LocalDateTime now = LocalDateTime.now();
    Long appId = findOrCreateApp(record, now);
    String snapshotJson = writeSnapshot(record);
    jdbcTemplate.update(
        DELETE_OLD_VERSION_SQL,
        now,
        now,
        record.tenantId(),
        appId,
        record.metaVersion());
    jdbcTemplate.update(
        INSERT_VERSION_SQL,
        nextId(),
        record.tenantId(),
        appId,
        record.metaVersion(),
        snapshotJson,
        now,
        now,
        now);
  }

  private Long findOrCreateApp(PublishedSnapshotRecord record, LocalDateTime now) {
    List<Map<String, Object>> rows = jdbcTemplate.queryForList(FIND_APP_SQL, record.tenantId(), record.appCode());
    if (!rows.isEmpty()) {
      return ((Number) rows.get(0).get("id")).longValue();
    }
    Long appId = nextId();
    jdbcTemplate.update(
        INSERT_APP_SQL,
        appId,
        record.tenantId(),
        record.appCode(),
        record.appCode(),
        now,
        now);
    return appId;
  }

  private String writeSnapshot(PublishedSnapshotRecord record) {
    try {
      return objectMapper.writeValueAsString(appSnapshot(record));
    } catch (JsonProcessingException ex) {
      throw new IllegalStateException("published snapshot json serialization failed", ex);
    }
  }

  private AppSnapshotDef appSnapshot(PublishedSnapshotRecord record) {
    MetaObjectDraft object = new MetaObjectDraft(
        record.tenantId(),
        0L,
        record.objectCode(),
        record.objectName(),
        ObjectTypeEnum.DOCUMENT,
        record.fields().stream().map(this::field).toList());
    return new AppSnapshotDef(
        1,
        record.tenantId(),
        record.appCode(),
        record.metaVersion(),
        List.of(object),
        List.of(),
        List.of(),
        List.of(),
        List.of(),
        CommercialMetadataDef.empty(1));
  }

  private FieldDef field(FieldDraft field) {
    FieldTypeEnum fieldType = switch (field.type()) {
      case "number" -> FieldTypeEnum.DECIMAL;
      case "select" -> FieldTypeEnum.SELECT;
      default -> FieldTypeEnum.TEXT;
    };
    return new FieldDef(field.code(), field.name(), fieldType, field.required(), defaultOptions(fieldType));
  }

  private FieldOptionsDef defaultOptions(FieldTypeEnum fieldType) {
    return switch (fieldType) {
      case DECIMAL -> FieldOptionsDef.decimal(1, 18, 4);
      case TEXT -> FieldOptionsDef.text(1, 255);
      default -> new FieldOptionsDef(1);
    };
  }

  private long nextId() {
    return idSequence.incrementAndGet();
  }
}
