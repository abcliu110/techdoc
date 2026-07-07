package com.lowcode.designer.service;

/**
 * Published designer snapshot with tenant and app scope.
 */
public record PublishedSnapshotRecord(
    Long tenantId,
    String appCode,
    String objectCode,
    String objectName,
    java.util.List<FieldDraft> fields,
    PublishedSnapshot snapshot) {

  public String metaVersion() {
    return snapshot.metaVersion();
  }

  public Object snapshotPayload() {
    return snapshot;
  }
}
