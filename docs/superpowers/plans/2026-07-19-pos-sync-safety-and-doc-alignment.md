# POS Sync Safety and Documentation Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent cross-tenant incremental updates, stop logging complete sync events, and align the POS mapping document with the current source and commit history.

**Architecture:** Keep the current Canal event flow and entity map. Add a small source-contract regression test, require `mid/sid/lid` before generic writes, add all three predicates to UPDATE, reduce event logging to metadata, and update only the disproven document narrative.

**Tech Stack:** Java, JUnit 5, MyBatis-Flex, Maven, SLF4J, Markdown, Git.

---

### Task 1: Establish the old-behavior baseline and RED safety contracts

**Files:**
- Existing baseline test: `D:/mywork/nms4pos/nms4cloud-pos3boot/nms4cloud-pos3boot-biz/src/test/java/com/nms4cloud/pos3boot/service/sync/FullSyncDataServiceCrmPointsRuleTest.java`
- Create: `D:/mywork/nms4pos/nms4cloud-pos3boot/nms4cloud-pos3boot-biz/src/test/java/com/nms4cloud/pos3boot/service/sync/IncrementalSyncDataServiceSafetyContractTest.java`
- Inspect: `D:/mywork/nms4pos/nms4cloud-pos3boot/nms4cloud-pos3boot-biz/src/main/java/com/nms4cloud/pos3boot/service/sync/IncrementalSyncDataService.java`

- [ ] **Step 1: Verify the target files have no pre-existing tracked diff**

Run:

```powershell
git diff -- 'nms4cloud-pos3boot/nms4cloud-pos3boot-biz/src/main/java/com/nms4cloud/pos3boot/service/sync/IncrementalSyncDataService.java' 'nms4cloud-pos5sync/nms4cloud-pos5sync-biz/src/main/java/com/nms4cloud/pos5sync/listeners/KafkaListenerForSync.java'
```

Expected: no diff before implementation.

- [ ] **Step 2: Run the existing sync baseline test**

Run from `D:/mywork/nms4pos`:

```powershell
mvn -pl nms4cloud-pos3boot/nms4cloud-pos3boot-biz -am "-Dtest=FullSyncDataServiceCrmPointsRuleTest" "-Dsurefire.failIfNoSpecifiedTests=false" test
```

Expected: PASS. If the environment fails before the test runs, diagnose the build error and record the baseline as blocked rather than claiming PASS.

- [ ] **Step 3: Add a source-contract regression test**

Create `IncrementalSyncDataServiceSafetyContractTest.java`:

```java
package com.nms4cloud.pos3boot.service.sync;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.Test;

class IncrementalSyncDataServiceSafetyContractTest {

  private static final Path SOURCE =
      Path.of(
          "src/main/java/com/nms4cloud/pos3boot/service/sync/IncrementalSyncDataService.java");

  @Test
  void should_scope_generic_update_by_mid_sid_and_lid() throws Exception {
    String source = Files.readString(SOURCE, StandardCharsets.UTF_8);
    String updateBlock =
        source.substring(source.indexOf("//  新增或修改"), source.indexOf("if (updated)"));

    assertTrue(updateBlock.contains(".eq(midColName, data.getMid())"));
    assertTrue(updateBlock.contains(".eq(sidColName, data.getSid())"));
    assertTrue(updateBlock.contains(".eq(lidColName, data.getLid())"));
  }

  @Test
  void should_reject_generic_write_when_tenant_identity_is_incomplete() throws Exception {
    String source = Files.readString(SOURCE, StandardCharsets.UTF_8);

    assertTrue(
        source.contains(
            "data.getMid() == null || data.getSid() == null || data.getLid() == null"));
  }

  @Test
  void should_not_log_complete_event_content() throws Exception {
    String source = Files.readString(SOURCE, StandardCharsets.UTF_8);

    assertFalse(source.contains("同步数据,clazz:{},type:{},data:{}"));
    assertFalse(source.contains("lid为空,更新失败,{}\", event.getContent()"));
  }
}
```

- [ ] **Step 4: Run the safety test to verify RED**

Run:

```powershell
mvn -pl nms4cloud-pos3boot/nms4cloud-pos3boot-biz -am "-Dtest=IncrementalSyncDataServiceSafetyContractTest" "-Dsurefire.failIfNoSpecifiedTests=false" test
```

Expected: FAIL because UPDATE only uses `lid`, tenant identity is not fully rejected, and full event content is logged.

### Task 2: Apply the minimum tenant-safe update and logging fix

**Files:**
- Modify: `D:/mywork/nms4pos/nms4cloud-pos3boot/nms4cloud-pos3boot-biz/src/main/java/com/nms4cloud/pos3boot/service/sync/IncrementalSyncDataService.java`

- [ ] **Step 1: Replace full event logging with safe metadata**

Replace the current ERROR payload log with:

```java
log.debug(
    "增量同步事件, tableName={}, clazz={}, type={}, lid={}, logFileName={}",
    event.getTblName(),
    clazz.getSimpleName(),
    event.getType(),
    event.getLid(),
    event.getLogFileName());
```

- [ ] **Step 2: Reject incomplete tenant identity before DELETE/UPDATE/INSERT**

Replace the `lid`-only guard with:

```java
if (data.getMid() == null || data.getSid() == null || data.getLid() == null) {
  log.error(
      "增量同步缺少租户标识, tableName={}, clazz={}, type={}, logFileName={}",
      event.getTblName(),
      clazz.getSimpleName(),
      event.getType(),
      event.getLogFileName());
  return;
}
```

Do not log `event.getContent()` or the materialized entity.

- [ ] **Step 3: Add `mid` and `sid` to the generic UPDATE predicate**

Use:

```java
boolean updated =
    new UpdateChain<>(mapper, data)
        .eq(midColName, data.getMid())
        .eq(sidColName, data.getSid())
        .eq(lidColName, data.getLid())
        .update();
```

Do not change CLASS_MAP, custom handlers, delete behavior, cache cleanup or progress tracking.

- [ ] **Step 4: Run RED test and baseline test to verify GREEN**

Run both Maven commands from Task 1.

Expected: both tests pass.

### Task 3: Stop the current Kafka listener from printing message bodies

**Files:**
- Modify: `D:/mywork/nms4pos/nms4cloud-pos5sync/nms4cloud-pos5sync-biz/src/main/java/com/nms4cloud/pos5sync/listeners/KafkaListenerForSync.java`

- [ ] **Step 1: Replace `System.out.println` with metadata-only SLF4J logging**

Use the project's existing Lombok/SLF4J pattern:

```java
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class KafkaListenerForSync {
  @KafkaListener(topics = CanalEventService.TOPIC)
  public void consumeMessage(String message) {
    log.debug("收到同步消息, payloadLength={}", message == null ? 0 : message.length());
  }
}
```

This change intentionally does not claim that the listener persists data; it only removes payload disclosure.

- [ ] **Step 2: Verify the listener source**

Run:

```powershell
rg -n 'System\.out|Received message:|\+ message|payloadLength' 'nms4cloud-pos5sync/nms4cloud-pos5sync-biz/src/main/java/com/nms4cloud/pos5sync/listeners/KafkaListenerForSync.java'
```

Expected: only `payloadLength` matches.

- [ ] **Step 3: Compile the two affected modules**

Run:

```powershell
mvn -pl nms4cloud-pos3boot/nms4cloud-pos3boot-biz,nms4cloud-pos5sync/nms4cloud-pos5sync-biz -am "-DskipTests" compile
```

Expected: BUILD SUCCESS.

### Task 4: Align the POS sync document with current evidence

**Files:**
- Modify without overwriting user mapping additions: `D:/mywork/techdoc/crm技术文档/17-POS门店与云端表同步对应关系.md`

- [ ] **Step 1: Re-read the user's exact diff**

Preserve the added `pt_auto_order` and five `biz_pos_perm_*` mappings. Do not reformat the full table.

- [ ] **Step 2: Correct the current-chain narrative**

State these evidence-backed facts:

```text
- The former pos4cloud KafkaListenerForSync was deleted by commit 98c1a0433549d246e2873a30dc42645690713f2a on 2026-07-07.
- The current pos5sync listener only records message metadata; current source does not prove that it performs store persistence.
- The authoritative store-side lookup remains tbl_name → IncrementalSyncDataService.CLASS_MAP → entity → local table, plus custom handlers and SyncBaseDataService.classMapper registration.
```

Delete any wording that presents the removed `pos4cloud` listener or Kafka-to-Netty chain as current fact.

- [ ] **Step 3: Add evidence metadata to dynamic mappings**

Add a short source note containing:

```text
source repository: D:/mywork/nms4pos
verified commit: current HEAD plus deletion commit 98c1a0433
verified date: 2026-07-19
environment: source inspection only; production Nacos/Kafka/database not queried
```

Mark environment-dependent routes as “待环境验证” rather than current fact.

- [ ] **Step 4: Verify every changed narrative claim**

Run:

```powershell
git show --name-status --format=fuller 98c1a0433 -- '*KafkaListenerForSync.java'
rg -n 'class KafkaListenerForSync|System\.out|log\.' 'nms4cloud-pos5sync/nms4cloud-pos5sync-biz/src/main/java/com/nms4cloud/pos5sync/listeners/KafkaListenerForSync.java'
rg -n 'CLASS_MAP|HANDLER_MAP|classMapper' 'nms4cloud-pos3boot/nms4cloud-pos3boot-biz/src/main/java/com/nms4cloud/pos3boot/service/sync/IncrementalSyncDataService.java' 'nms4cloud-pos3boot/nms4cloud-pos3boot-biz/src/main/java/com/nms4cloud/pos3boot/service/sync/SyncBaseDataService.java'
```

Expected: each document statement has a matching source or commit record.

### Task 5: Final verification and handoff

**Files:** All files in this plan.

- [ ] **Step 1: Run target tests and compilation fresh**

Run the two JUnit commands and the two-module compile command again. Record exit codes and test counts.

- [ ] **Step 2: Verify Java encoding and logging privacy**

Check both modified Java files are UTF-8 without BOM. Run bounded searches confirming no full `event.getContent()` log and no message-body print remain.

- [ ] **Step 3: Review exact diffs in both repositories**

Confirm `nms4pos` contains only the two Java changes plus the new test. Confirm `techdoc` preserves the user's mapping additions and only changes the inaccurate narrative/source metadata.

- [ ] **Step 4: Respect the repository's test-submission rule**

The new Java test is required for the TDD loop, but the repository says newly added Java tests are not submitted by default. Leave implementation uncommitted and explicitly report the test file so the user can decide whether it should be committed with the fix.

- [ ] **Step 5: Report rollback and remaining risk**

Rollback is restoring the two Java files and the document hunk. Remaining risks must state that no production database, Kafka broker, Nacos route or real sync event was exercised.

