CREATE TABLE reportcenter.dws_crm_income_of_store
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '集团编号',
    `sid` Int64 COMMENT '门店编号',
    `shop_name` String COMMENT '门店名称',
    `year_` Int32 COMMENT '年',
    `month_` Int8 COMMENT '月',
    `day_` Int8 COMMENT '日',
    `season` Int8 COMMENT '季度',
    `consume_times` Decimal(18, 4) COMMENT '消费笔数',
    `consume_principal` Decimal(18, 4) COMMENT '消费本金',
    `consume_present` Decimal(18, 4) COMMENT '消费赠送',
    `charge_times` Decimal(18, 4) COMMENT '储值笔数',
    `charge_principal` Decimal(18, 4) COMMENT '储值本金',
    `charge_present` Decimal(18, 4) COMMENT '储值赠送',
    `principal` Decimal(18, 4) COMMENT '本金收支',
    `present` Decimal(18, 4) COMMENT '赠送收支',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `report_date` DateTime COMMENT '营业日期'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, sid, year_, month_, day_)
ORDER BY (mid, sid, year_, month_, day_)
SETTINGS index_granularity = 8192
COMMENT '会员连锁门店收支报表'
;
