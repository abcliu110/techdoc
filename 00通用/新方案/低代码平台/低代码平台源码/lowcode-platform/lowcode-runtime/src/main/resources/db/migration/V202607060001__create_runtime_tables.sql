create table lc_rt_idempotency (
  id bigint not null comment '雪花主键',
  tenant_id bigint not null comment '租户ID',
  app_code varchar(64) not null comment '应用编码',
  object_code varchar(64) not null comment '对象编码',
  operation varchar(32) not null comment '幂等操作类型',
  idempotency_key varchar(128) not null comment '客户端幂等键',
  record_lid varchar(26) not null comment '运行时业务记录LID',
  from_state varchar(64) not null default '' comment '流转前状态，非流转操作为空串',
  to_state varchar(64) not null default '' comment '流转后状态，非流转操作为空串',
  revision bigint not null comment '首次执行后的记录版本',
  trace_id varchar(64) not null comment '首次执行追踪ID',
  create_time datetime(3) not null default current_timestamp(3) comment '创建时间',
  primary key (id),
  unique key uk_lc_rt_idempotency_scope (tenant_id, app_code, object_code, operation, idempotency_key),
  key idx_lc_rt_idempotency_record (tenant_id, app_code, object_code, record_lid)
) comment='运行时幂等结果表';

create table lc_rt_audit_log (
  id bigint not null comment '雪花主键',
  tenant_id bigint not null comment '租户ID',
  app_code varchar(64) not null comment '应用编码',
  object_code varchar(64) not null comment '对象编码',
  operation varchar(32) not null comment '审计操作类型',
  trace_id varchar(64) not null comment '追踪ID',
  meta_hash varchar(128) not null comment '请求钉住的元数据哈希',
  perm_version bigint not null comment '权限视图版本',
  create_time datetime(3) not null default current_timestamp(3) comment '创建时间',
  primary key (id),
  key idx_lc_rt_audit_log_trace (tenant_id, app_code, object_code, trace_id),
  key idx_lc_rt_audit_log_operation (tenant_id, app_code, object_code, operation)
) comment='运行时审计日志表';

create table lc_rt_outbox (
  id bigint not null comment '雪花主键',
  tenant_id bigint not null comment '租户ID',
  app_code varchar(64) not null comment '应用编码',
  object_code varchar(64) not null comment '对象编码',
  event_type varchar(64) not null comment '平台事件类型',
  record_lid varchar(26) not null comment '运行时业务记录LID',
  trace_id varchar(64) not null comment '追踪ID',
  publish_status varchar(32) not null default 'pending' comment '投递状态',
  retry_count int not null default 0 comment '重试次数',
  create_time datetime(3) not null default current_timestamp(3) comment '创建时间',
  update_time datetime(3) not null default current_timestamp(3) comment '更新时间',
  primary key (id),
  key idx_lc_rt_outbox_pending (publish_status, create_time),
  key idx_lc_rt_outbox_record (tenant_id, app_code, object_code, record_lid)
) comment='运行时事务外发事件表';

create table lc_rt_transition_log (
  id bigint not null comment '雪花主键',
  tenant_id bigint not null comment '租户ID',
  app_code varchar(64) not null comment '应用编码',
  object_code varchar(64) not null comment '对象编码',
  record_lid varchar(26) not null comment '运行时业务记录LID',
  from_state varchar(64) not null comment '流转前状态',
  to_state varchar(64) not null comment '流转后状态',
  trace_id varchar(64) not null comment '追踪ID',
  create_time datetime(3) not null default current_timestamp(3) comment '创建时间',
  primary key (id),
  key idx_lc_rt_transition_log_record (tenant_id, app_code, object_code, record_lid),
  key idx_lc_rt_transition_log_trace (tenant_id, app_code, object_code, trace_id)
) comment='运行时状态流转日志表';
