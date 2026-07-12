package com.lowcode.designer.service;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Test;

class DesignerDraftFacadePublishSinkTest {

  @Test
  void publish_shouldPersistPublishedSnapshotThroughSink() {
    RecordingPublishSnapshotSink sink = new RecordingPublishSnapshotSink();
    DesignerDraftFacade facade = new DesignerDraftFacade(sink);
    facade.add(3L, "sales", "invoice", "Invoice", null, List.of(new FieldDraft("name", "Name", "text", true)));

    facade.publish(3L, "sales", "invoice", 1L);

    assertThat(sink.snapshots).hasSize(1);
    PublishedSnapshotRecord record = sink.snapshots.get(0);
    assertThat(record.tenantId()).isEqualTo(3L);
    assertThat(record.appCode()).isEqualTo("sales");
    assertThat(record.objectCode()).isEqualTo("invoice");
    assertThat(record.objectName()).isEqualTo("Invoice");
    assertThat(record.fields()).extracting(FieldDraft::code).containsExactly("name");
    assertThat(record.metaVersion()).isEqualTo("sales:invoice:1");
  }

  private static final class RecordingPublishSnapshotSink implements PublishSnapshotSink {
    private final List<PublishedSnapshotRecord> snapshots = new ArrayList<>();

    @Override
    public void save(PublishedSnapshotRecord record) {
      snapshots.add(record);
    }
  }
}
