alter table lc_rt_idempotency
  drop index uk_lc_rt_idempotency_scope;

alter table lc_rt_idempotency
  add column workspace_id bigint null comment '工作区ID' after tenant_id;

update lc_rt_idempotency set workspace_id = 0 where workspace_id is null;

alter table lc_rt_idempotency
  modify column workspace_id bigint not null comment '工作区ID';

alter table lc_rt_idempotency
  add unique key uk_lc_rt_idempotency_scope (tenant_id, workspace_id, app_code, object_code, operation, idempotency_key);
