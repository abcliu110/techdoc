package com.lowcode.runtime.data;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@EnabledIfSystemProperty(named = "lowcode.it", matches = "true")
@Testcontainers(disabledWithoutDocker = true)
class JdbcDynamicRecordRepositoryIT {

  @Container
  private static final MySQLContainer<?> MYSQL =
      new MySQLContainer<>("mysql:8.0.37")
          .withDatabaseName("lowcode")
          .withUsername("lowcode")
          .withPassword("lowcode");

  private final DynamicObjectDefinition order = DynamicObjectDefinition.builder("order", "lc_rt_order")
      .field("amount", FieldKind.CURRENCY)
      .field("remark", FieldKind.TEXT)
      .stateMachine(StateMachineDefinition.simpleApproval("draft", "approved", "approve", java.util.Set.of("manager")))
      .build();
  private final RuntimeExecutionContext tenant1 = context(1L);
  private final RuntimeExecutionContext tenant2 = context(2L);
  private JdbcDynamicRecordRepository repository;

  @BeforeEach
  void setUp() throws SQLException {
    try (Connection connection = connection()) {
      connection.createStatement().execute("drop table if exists lc_rt_order");
      connection.createStatement().execute("""
          create table lc_rt_order (
            tenant_id bigint not null,
            workspace_id bigint not null,
            lid varchar(26) not null,
            revision bigint not null,
            deleted tinyint not null default 0,
            state_code varchar(64),
            amount decimal(18,2),
            remark varchar(255),
            primary key (tenant_id, workspace_id, lid),
            key idx_lc_rt_order_list (tenant_id, workspace_id, deleted, amount, remark)
          )
          """);
    }
    repository = new JdbcDynamicRecordRepository(new MySqlJdbcExecutor());
  }

  @Test
  void shouldRunCrudAgainstRealDynamicBusinessTableWithTenantAndSoftDeleteGuards() {
    repository.insert(order, tenant1, record("01AAAAAAAAAAAAAAAAAAAAAAAA", 1L, "12.30", "alpha order", false));
    repository.insert(order, tenant1, record("01BBBBBBBBBBBBBBBBBBBBBBBB", 1L, "18.00", "beta order", false));
    repository.insert(order, tenant2, record("01CCCCCCCCCCCCCCCCCCCCCCCC", 1L, "15.00", "alpha other", false));

    List<DynamicRecord> rows = repository.list(
        order,
        tenant1,
        List.of(new Filter("amount", "gte", "10"), new Filter("amount", "lte", "20"), new Filter("remark", "contains", "order")),
        List.of(new Sort("amount", "desc")),
        1,
        20);

    assertThat(rows).extracting(DynamicRecord::lid)
        .containsExactly("01BBBBBBBBBBBBBBBBBBBBBBBB", "01AAAAAAAAAAAAAAAAAAAAAAAA");

    DynamicRecord first = repository.require(order, tenant1, "01AAAAAAAAAAAAAAAAAAAAAAAA");
    first.values().put("remark", "updated order");
    repository.update(order, tenant1, first.nextRevision());

    assertThat(repository.require(order, tenant1, first.lid()).values())
        .containsEntry("remark", "updated order");

    repository.softDelete(order, tenant1, first.lid(), 2L);
    assertThatThrownBy(() -> repository.require(order, tenant1, first.lid()))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.RECORD_NOT_FOUND);
    assertThat(repository.require(order, tenant2, "01CCCCCCCCCCCCCCCCCCCCCCCC").tenantId()).isEqualTo(2L);
  }

  @Test
  void shouldIsolateRecordsByWorkspaceInsideSameTenant() {
    RuntimeExecutionContext workspace2 = context(1L, 2L);
    repository.insert(order, tenant1, record("01AAAAAAAAAAAAAAAAAAAAAAAA", 1L, "12.30", "alpha order", false));

    assertThat(repository.list(order, workspace2, List.of(), List.of(), 1, 20)).isEmpty();
    assertThatThrownBy(() -> repository.require(order, workspace2, "01AAAAAAAAAAAAAAAAAAAAAAAA"))
        .isInstanceOf(RuntimeDataException.class)
        .extracting("errorCode")
        .isEqualTo(RuntimeDataErrorCode.RECORD_NOT_FOUND);
  }

  private static DynamicRecord record(String lid, Long revision, String amount, String remark, boolean deleted) {
    return new DynamicRecord(
        lid,
        1L,
        new java.util.HashMap<>(Map.of("amount", new BigDecimal(amount), "remark", remark)),
        "draft",
        revision,
        deleted);
  }

  private static RuntimeExecutionContext context(Long tenantId) {
    return context(tenantId, 1L);
  }

  private static RuntimeExecutionContext context(Long tenantId, Long workspaceId) {
    return new RuntimeExecutionContext(tenantId, workspaceId, "u1", java.util.Set.of("manager"), "sales", "order", "mh-1", "trace-1");
  }

  private static Connection connection() throws SQLException {
    return DriverManager.getConnection(MYSQL.getJdbcUrl(), MYSQL.getUsername(), MYSQL.getPassword());
  }

  private static final class MySqlJdbcExecutor implements RuntimeJdbcExecutor {
    @Override
    public int update(String sql, List<Object> parameters) {
      try (Connection connection = connection();
           PreparedStatement statement = connection.prepareStatement(sql)) {
        bind(statement, parameters);
        return statement.executeUpdate();
      } catch (SQLException ex) {
        throw new RuntimeException(ex);
      }
    }

    @Override
    public List<Map<String, Object>> query(String sql, List<Object> parameters) {
      try (Connection connection = connection();
           PreparedStatement statement = connection.prepareStatement(sql)) {
        bind(statement, parameters);
        try (var resultSet = statement.executeQuery()) {
          List<Map<String, Object>> rows = new java.util.ArrayList<>();
          var metadata = resultSet.getMetaData();
          while (resultSet.next()) {
            Map<String, Object> row = new java.util.LinkedHashMap<>();
            for (int i = 1; i <= metadata.getColumnCount(); i++) {
              row.put(metadata.getColumnLabel(i), resultSet.getObject(i));
            }
            rows.add(row);
          }
          return rows;
        }
      } catch (SQLException ex) {
        throw new RuntimeException(ex);
      }
    }

    private static void bind(PreparedStatement statement, List<Object> parameters) throws SQLException {
      for (int i = 0; i < parameters.size(); i++) {
        statement.setObject(i + 1, parameters.get(i));
      }
    }
  }
}
