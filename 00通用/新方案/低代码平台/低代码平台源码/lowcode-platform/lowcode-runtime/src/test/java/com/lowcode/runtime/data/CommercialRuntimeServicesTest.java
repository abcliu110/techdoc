package com.lowcode.runtime.data;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.lowcode.runtime.permission.AccessExplain;
import com.lowcode.runtime.permission.AccessView;
import com.lowcode.runtime.permission.DataScope;
import com.lowcode.runtime.permission.FieldAccess;
import com.lowcode.runtime.permission.Operation;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.junit.jupiter.api.Test;

class CommercialRuntimeServicesTest {

  @Test
  void shouldConvertSourceToTargetIdempotentlyAndWriteAuditEvent() {
    DynamicObjectDefinition sourceDefinition = DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("customer_name", FieldKind.TEXT)
        .field("amount", FieldKind.CURRENCY)
        .build();
    DynamicObjectDefinition targetDefinition = DynamicObjectDefinition.builder("delivery", "lc_rt_delivery")
        .field("receiver_name", FieldKind.TEXT)
        .field("delivery_amount", FieldKind.CURRENCY)
        .build();
    InMemoryDynamicRecordRepository sourceRepository = new InMemoryDynamicRecordRepository();
    InMemoryRuntimeSideEffectRepository sideEffects = new InMemoryRuntimeSideEffectRepository();
    InMemoryDynamicDataService sourceService = new InMemoryDynamicDataService(sourceDefinition, sourceRepository, sideEffects);
    InMemoryDynamicDataService targetService = new InMemoryDynamicDataService(targetDefinition, new InMemoryDynamicRecordRepository(), sideEffects);
    ConversionRuntimeService service = new ConversionRuntimeService(sourceDefinition, sourceRepository, targetDefinition, targetService, sideEffects);

    RuntimeExecutionContext tenant1Order = context(1L, "sales", "order", "mh-1", "trace-conv-order");
    RuntimeExecutionContext tenant1Delivery = context(1L, "sales", "delivery", "mh-1", "trace-conv-delivery");
    String sourceLid = sourceService.add(
            tenant1Order,
            writableAccess("order", "mh-1", Set.of(Operation.READ, Operation.CREATE), "customer_name", "amount"),
            new AddRecordCommand(Map.of("customer_name", "张三", "amount", "88.50"), "mh-1", "src-add"))
        .recordLid();

    ConversionResult first = service.convert(new ConversionCommand(
        "order_to_delivery",
        tenant1Order,
        readableAccess("order", "mh-1", "customer_name", "amount"),
        sourceLid,
        tenant1Delivery,
        writableAccess("delivery", "mh-1", Set.of(Operation.READ, Operation.CREATE), "receiver_name", "delivery_amount"),
        Map.of("customer_name", "receiver_name", "amount", "delivery_amount"),
        "conv-idem-1",
        1,
        3));
    ConversionResult replay = service.convert(new ConversionCommand(
        "order_to_delivery",
        tenant1Order,
        readableAccess("order", "mh-1", "customer_name", "amount"),
        sourceLid,
        tenant1Delivery,
        writableAccess("delivery", "mh-1", Set.of(Operation.READ, Operation.CREATE), "receiver_name", "delivery_amount"),
        Map.of("customer_name", "receiver_name", "amount", "delivery_amount"),
        "conv-idem-1",
        1,
        3));

    assertThat(replay.targetRecordLid()).isEqualTo(first.targetRecordLid());
    assertThat(replay.replayed()).isTrue();
    assertThat(targetService.get(
            tenant1Delivery,
            readableAccess("delivery", "mh-1", "receiver_name", "delivery_amount"),
            first.targetRecordLid(),
            Set.of("receiver_name", "delivery_amount")))
        .containsEntry("receiver_name", "张三")
        .containsEntry("delivery_amount", new BigDecimal("88.50"));
    assertThat(sideEffects.auditLogs()).extracting(AuditLog::operation)
        .contains("create", "conversion:order_to_delivery");
  }

  @Test
  void shouldRejectConversionWithoutTargetFieldWritePermissionAndWhenChainDepthExceeded() {
    DynamicObjectDefinition sourceDefinition = DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("amount", FieldKind.CURRENCY)
        .build();
    DynamicObjectDefinition targetDefinition = DynamicObjectDefinition.builder("invoice", "lc_rt_invoice")
        .field("total_amount", FieldKind.CURRENCY)
        .build();
    InMemoryDynamicRecordRepository sourceRepository = new InMemoryDynamicRecordRepository();
    InMemoryRuntimeSideEffectRepository sideEffects = new InMemoryRuntimeSideEffectRepository();
    InMemoryDynamicDataService sourceService = new InMemoryDynamicDataService(sourceDefinition, sourceRepository, sideEffects);
    InMemoryDynamicDataService targetService = new InMemoryDynamicDataService(targetDefinition, new InMemoryDynamicRecordRepository(), sideEffects);
    ConversionRuntimeService service = new ConversionRuntimeService(sourceDefinition, sourceRepository, targetDefinition, targetService, sideEffects);

    RuntimeExecutionContext sourceContext = context(1L, "sales", "order", "mh-2", "trace-conv-source");
    RuntimeExecutionContext targetContext = context(1L, "sales", "invoice", "mh-2", "trace-conv-target");
    String sourceLid = sourceService.add(
            sourceContext,
            writableAccess("order", "mh-2", Set.of(Operation.READ, Operation.CREATE), "amount"),
            new AddRecordCommand(Map.of("amount", "30"), "mh-2", "src-add-2"))
        .recordLid();

    assertThatThrownBy(() -> service.convert(new ConversionCommand(
            "order_to_invoice",
            sourceContext,
            readableAccess("order", "mh-2", "amount"),
            sourceLid,
            targetContext,
            access("invoice", "mh-2", Set.of(Operation.READ, Operation.CREATE), Map.of("total_amount", FieldAccess.NONE)),
            Map.of("amount", "total_amount"),
            "conv-denied",
            1,
            3)))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.PERMISSION_DENIED);

    assertThatThrownBy(() -> service.convert(new ConversionCommand(
            "order_to_invoice",
            sourceContext,
            readableAccess("order", "mh-2", "amount"),
            sourceLid,
            targetContext,
            writableAccess("invoice", "mh-2", Set.of(Operation.READ, Operation.CREATE), "total_amount"),
            Map.of("amount", "total_amount"),
            "conv-depth",
            4,
            3)))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.CHAIN_DEPTH_EXCEEDED);
  }

  @Test
  void shouldAggregateWriteBackIdempotentlyAndMoveFailureIntoDeadLetterThenRepair() {
    DynamicObjectDefinition sourceDefinition = DynamicObjectDefinition.builder("receipt", "lc_rt_receipt")
        .field("paid_amount", FieldKind.CURRENCY)
        .build();
    DynamicObjectDefinition targetDefinition = DynamicObjectDefinition.builder("statement", "lc_rt_statement")
        .field("received_amount", FieldKind.CURRENCY)
        .build();
    InMemoryDynamicRecordRepository sourceRepository = new InMemoryDynamicRecordRepository();
    InMemoryDynamicRecordRepository targetRepository = new InMemoryDynamicRecordRepository();
    InMemoryRuntimeSideEffectRepository sideEffects = new InMemoryRuntimeSideEffectRepository();
    InMemoryDynamicDataService sourceService = new InMemoryDynamicDataService(sourceDefinition, sourceRepository, sideEffects);
    InMemoryDynamicDataService targetService = new InMemoryDynamicDataService(targetDefinition, targetRepository, sideEffects);
    WriteBackRuntimeService service = new WriteBackRuntimeService(sourceDefinition, sourceRepository, targetDefinition, targetService);

    RuntimeExecutionContext sourceContext = context(1L, "finance", "receipt", "mh-3", "trace-wb-source");
    RuntimeExecutionContext targetContext = context(1L, "finance", "statement", "mh-3", "trace-wb-target");
    String receiptA = sourceService.add(
            sourceContext,
            writableAccess("receipt", "mh-3", Set.of(Operation.READ, Operation.CREATE), "paid_amount"),
            new AddRecordCommand(Map.of("paid_amount", "10"), "mh-3", "receipt-a"))
        .recordLid();
    String receiptB = sourceService.add(
            sourceContext,
            writableAccess("receipt", "mh-3", Set.of(Operation.READ, Operation.CREATE), "paid_amount"),
            new AddRecordCommand(Map.of("paid_amount", "15"), "mh-3", "receipt-b"))
        .recordLid();
    AddRecordResult statement = targetService.add(
        targetContext,
        writableAccess("statement", "mh-3", Set.of(Operation.READ, Operation.CREATE, Operation.UPDATE), "received_amount"),
        new AddRecordCommand(Map.of("received_amount", "0"), "mh-3", "statement-add"));

    WriteBackResult success = service.writeBack(new WriteBackCommand(
        "receipt_to_statement",
        sourceContext,
        readableAccess("receipt", "mh-3", "paid_amount"),
        List.of(receiptA, receiptB),
        "paid_amount",
        targetContext,
        writableAccess("statement", "mh-3", Set.of(Operation.READ, Operation.UPDATE), "received_amount"),
        statement.recordLid(),
        statement.revision(),
        "received_amount",
        "wb-event-1"));
    WriteBackResult replay = service.writeBack(new WriteBackCommand(
        "receipt_to_statement",
        sourceContext,
        readableAccess("receipt", "mh-3", "paid_amount"),
        List.of(receiptA, receiptB),
        "paid_amount",
        targetContext,
        writableAccess("statement", "mh-3", Set.of(Operation.READ, Operation.UPDATE), "received_amount"),
        statement.recordLid(),
        statement.revision(),
        "received_amount",
        "wb-event-1"));

    assertThat(success.state()).isEqualTo(WriteBackState.SUCCESS);
    assertThat(replay.replayed()).isTrue();
    assertThat(targetService.get(
            targetContext,
            readableAccess("statement", "mh-3", "received_amount"),
            statement.recordLid(),
            Set.of("received_amount")))
        .containsEntry("received_amount", new BigDecimal("25"));

    WriteBackResult failed = service.writeBack(new WriteBackCommand(
        "receipt_to_statement",
        sourceContext,
        readableAccess("receipt", "mh-3", "paid_amount"),
        List.of(receiptA),
        "paid_amount",
        targetContext,
        access("statement", "mh-3", Set.of(Operation.READ, Operation.UPDATE), Map.of("received_amount", FieldAccess.NONE)),
        statement.recordLid(),
        2L,
        "received_amount",
        "wb-event-2"));

    assertThat(failed.state()).isEqualTo(WriteBackState.DEAD_LETTER);
    assertThat(service.deadLetters()).singleElement().satisfies(deadLetter -> {
      assertThat(deadLetter.eventId()).isEqualTo("wb-event-2");
      assertThat(deadLetter.state()).isEqualTo(WriteBackState.DEAD_LETTER);
    });

    service.markRepairPending("wb-event-2");
    WriteBackResult repaired = service.retryDeadLetter(new WriteBackCommand(
        "receipt_to_statement",
        sourceContext,
        readableAccess("receipt", "mh-3", "paid_amount"),
        List.of(receiptA),
        "paid_amount",
        targetContext,
        writableAccess("statement", "mh-3", Set.of(Operation.READ, Operation.UPDATE), "received_amount"),
        statement.recordLid(),
        2L,
        "received_amount",
        "wb-event-2"));

    assertThat(repaired.state()).isEqualTo(WriteBackState.REPAIRED);
    assertThat(service.deadLetters()).singleElement().extracting(WriteBackDeadLetter::state).isEqualTo(WriteBackState.REPAIRED);
  }

  @Test
  void shouldTraceUpAndDownWithoutLeakingUnauthorizedTargets() {
    DynamicObjectDefinition sourceDefinition = DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("title", FieldKind.TEXT)
        .build();
    DynamicObjectDefinition targetDefinition = DynamicObjectDefinition.builder("invoice", "lc_rt_invoice")
        .field("title", FieldKind.TEXT)
        .build();
    InMemoryRuntimeSideEffectRepository sideEffects = new InMemoryRuntimeSideEffectRepository();
    InMemoryDynamicDataService sourceService = new InMemoryDynamicDataService(sourceDefinition, new InMemoryDynamicRecordRepository(), sideEffects);
    InMemoryDynamicDataService targetService = new InMemoryDynamicDataService(targetDefinition, new InMemoryDynamicRecordRepository(), sideEffects);
    LinkTraceRuntimeService service = new LinkTraceRuntimeService();

    RuntimeExecutionContext orderContext = context(1L, "sales", "order", "mh-4", "trace-link-order");
    RuntimeExecutionContext invoiceContext = context(1L, "sales", "invoice", "mh-4", "trace-link-invoice");
    RuntimeExecutionContext otherTenantInvoiceContext = context(2L, "sales", "invoice", "mh-4", "trace-link-other");
    String orderLid = sourceService.add(
            orderContext,
            writableAccess("order", "mh-4", Set.of(Operation.READ, Operation.CREATE), "title"),
            new AddRecordCommand(Map.of("title", "订单A"), "mh-4", "order-add"))
        .recordLid();
    String visibleInvoice = targetService.add(
            invoiceContext,
            writableAccess("invoice", "mh-4", Set.of(Operation.READ, Operation.CREATE), "title"),
            new AddRecordCommand(Map.of("title", "发票A"), "mh-4", "invoice-visible"))
        .recordLid();
    String hiddenInvoice = targetService.add(
            otherTenantInvoiceContext,
            writableAccess("invoice", "mh-4", Set.of(Operation.READ, Operation.CREATE), "title"),
            new AddRecordCommand(Map.of("title", "发票B"), "mh-4", "invoice-hidden"))
        .recordLid();

    service.register("order_invoice", orderContext.tenantId(), "order", orderLid, invoiceContext.tenantId(), "invoice", visibleInvoice);
    service.register("order_invoice", orderContext.tenantId(), "order", orderLid, otherTenantInvoiceContext.tenantId(), "invoice", hiddenInvoice);

    List<LinkTraceNode> down = service.traceDown(
        "order_invoice",
        sourceService,
        orderContext,
        readableAccess("order", "mh-4", "title"),
        orderLid,
        targetService,
        invoiceContext,
        readableAccess("invoice", "mh-4", "title"),
        "title");
    List<LinkTraceNode> hidden = service.traceDown(
        "order_invoice",
        sourceService,
        orderContext,
        readableAccess("order", "mh-4", "title"),
        orderLid,
        targetService,
        invoiceContext,
        access("invoice", "mh-4", Set.of(), Map.of("title", FieldAccess.NONE)),
        "title");
    List<LinkTraceNode> up = service.traceUp(
        "order_invoice",
        targetService,
        invoiceContext,
        readableAccess("invoice", "mh-4", "title"),
        visibleInvoice,
        sourceService,
        orderContext,
        readableAccess("order", "mh-4", "title"),
        "title");

    assertThat(down).singleElement().satisfies(node -> {
      assertThat(node.recordLid()).isEqualTo(visibleInvoice);
      assertThat(node.title()).isEqualTo("发票A");
    });
    assertThat(hidden).isEmpty();
    assertThat(up).singleElement().extracting(LinkTraceNode::recordLid).isEqualTo(orderLid);
  }

  @Test
  void shouldBuildPermissionCroppedReportAggregateAndEscapeCsvFormula() {
    DynamicObjectDefinition orderDefinition = DynamicObjectDefinition.builder("order", "lc_rt_order")
        .field("title", FieldKind.TEXT)
        .field("amount", FieldKind.CURRENCY)
        .field("secret_amount", FieldKind.CURRENCY)
        .build();
    InMemoryDynamicDataService service = new InMemoryDynamicDataService(orderDefinition);
    ReportRuntimeService reportService = new ReportRuntimeService();
    RuntimeExecutionContext context = context(1L, "sales", "order", "mh-5", "trace-report");
    AccessView setupAccess = writableAccess("order", "mh-5", Set.of(Operation.READ, Operation.CREATE, Operation.EXPORT), "title", "amount", "secret_amount");

    service.add(context, setupAccess, new AddRecordCommand(Map.of("title", "=2+3", "amount", "10", "secret_amount", "88"), "mh-5", "report-1"));
    service.add(context, setupAccess, new AddRecordCommand(Map.of("title", "@cmd", "amount", "5", "secret_amount", "99"), "mh-5", "report-2"));

    ReportAggregateResult aggregate = reportService.aggregate(
        service,
        context,
        access("order", "mh-5", Set.of(Operation.READ), Map.of("title", FieldAccess.WRITE, "amount", FieldAccess.WRITE, "secret_amount", FieldAccess.NONE)),
        new ListRecordCommand(Set.of("title", "amount", "secret_amount"), List.of(), List.of(Sort.asc("title")), 1, 20),
        Set.of("amount", "secret_amount"));
    ReportDataset dataset = reportService.export(
        service,
        context,
        access("order", "mh-5", Set.of(Operation.READ, Operation.EXPORT), Map.of("title", FieldAccess.WRITE, "amount", FieldAccess.WRITE, "secret_amount", FieldAccess.NONE)),
        new ListRecordCommand(Set.of("title", "amount", "secret_amount"), List.of(), List.of(Sort.asc("title")), 1, 20));

    assertThat(aggregate.rowCount()).isEqualTo(2);
    assertThat(aggregate.sums()).containsEntry("amount", new BigDecimal("15"));
    assertThat(aggregate.sums()).doesNotContainKey("secret_amount");
    assertThat(dataset.rows()).extracting(row -> row.get("title"))
        .containsExactly("'=2+3", "'@cmd");
    assertThat(dataset.rows()).allSatisfy(row -> assertThat(row).doesNotContainKey("secret_amount"));

    assertThatThrownBy(() -> reportService.export(
            service,
            context,
            access("order", "mh-5", Set.of(Operation.READ), Map.of("title", FieldAccess.WRITE, "amount", FieldAccess.WRITE)),
            new ListRecordCommand(Set.of("title", "amount"), List.of(), List.of(), 1, 20)))
        .isInstanceOf(RuntimeDataException.class)
        .satisfies(ex -> {
          RuntimeDataException runtimeEx = (RuntimeDataException) ex;
          assertThat(runtimeEx.getErrorCode()).isEqualTo(RuntimeDataErrorCode.PERMISSION_DENIED);
          assertThat(runtimeEx.getMessage()).doesNotContain("lc_rt_order").doesNotContain("java.");
        });
  }

  private static RuntimeExecutionContext context(Long tenantId, String appCode, String objectCode, String metaHash, String traceId) {
    return new RuntimeExecutionContext(tenantId, 1L, "user-1", Set.of("manager"), appCode, objectCode, metaHash, traceId);
  }

  private static AccessView readableAccess(String objectCode, String metaHash, String... readableFields) {
    java.util.LinkedHashMap<String, FieldAccess> fieldView = new java.util.LinkedHashMap<>();
    for (String field : readableFields) {
      fieldView.put(field, FieldAccess.WRITE);
    }
    return access(objectCode, metaHash, Set.of(Operation.READ), fieldView);
  }

  private static AccessView writableAccess(String objectCode, String metaHash, Set<Operation> operations, String... fields) {
    java.util.LinkedHashMap<String, FieldAccess> fieldView = new java.util.LinkedHashMap<>();
    for (String field : fields) {
      fieldView.put(field, FieldAccess.WRITE);
    }
    return access(objectCode, metaHash, operations, fieldView);
  }

  private static AccessView access(String objectCode, String metaHash, Set<Operation> operations, Map<String, FieldAccess> fieldView) {
    return new AccessView(
        objectCode,
        operations,
        fieldView,
        DataScope.self(),
        Set.of("approve"),
        metaHash,
        1L,
        AccessExplain.allow("test"));
  }
}
