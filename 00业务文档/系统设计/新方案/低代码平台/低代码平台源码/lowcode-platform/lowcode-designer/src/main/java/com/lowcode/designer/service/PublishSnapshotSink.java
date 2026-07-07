package com.lowcode.designer.service;

/**
 * Published snapshot persistence extension.
 */
public interface PublishSnapshotSink {

  void save(PublishedSnapshotRecord record);

  static PublishSnapshotSink noop() {
    return ignored -> {
    };
  }
}
