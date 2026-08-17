CREATE TABLE bi.export_record
(
    `version` UUID DEFAULT generateUUIDv4() COMMENT '物理主键',
    `mid` Int64 COMMENT '集团编号',
    `sid` Int64 COMMENT '门店编号',
    `lid` Int64 COMMENT '逻辑编号',
    `created_time` DateTime DEFAULT now() COMMENT '创建时间',
    `updated_time` DateTime DEFAULT now() COMMENT '更新时间',
    `report_date` DateTime COMMENT '营业日期',
    `done_time` DateTime COMMENT '导出完成时间',
    `state` Int8 COMMENT '状态',
    `path` String COMMENT 'oss存放路径',
    `description` String COMMENT '描述',
    `biz_clazz` String COMMENT '业务类名',
    `request` String COMMENT '请求参数',
    `created_by` String COMMENT '创建人',
    `updated_by` String COMMENT '更新人'
)
ENGINE = ReplacingMergeTree(created_time)
PARTITION BY toYYYYMM(report_date)
PRIMARY KEY (mid, lid)
ORDER BY (mid, lid)
SETTINGS index_granularity = 8192
COMMENT '报表导出记录'
;
INSERT INTO table (`version`, `mid`, `sid`, `lid`, `created_time`, `updated_time`, `report_date`, `done_time`, `state`, `path`, `description`, `biz_clazz`, `request`, `created_by`, `updated_by`) VALUES ('f148c2cd-d5ad-4b2b-be1c-03a1e7a2ca7a', 1940284000182472704, 0, 2084823192516956162, '2026-08-05 02:06:11', '2026-08-05 10:05:57', '2026-08-05 08:00:00', '2026-08-05 10:06:11', 2, 'https://jj-test-1421742343.cos.ap-guangzhou.myqcloud.com/report/1940284000182472704/营业汇总表_1785895557894.xlsx', '导出成功', 'com.nms4cloud.bi.app.controller.jd.BusinessSummaryForJd', '', '', ''), ('f34ed1b1-b472-43e6-a991-bd5f5db00c66', 1940284000182472704, 0, 2084847743446032386, '2026-08-05 03:43:32', '2026-08-05 11:43:31', '2026-08-05 08:00:00', '2026-08-05 11:43:32', 2, 'https://jj-test-1421742343.cos.ap-guangzhou.myqcloud.com/report/1940284000182472704/营业汇总表_1785901411289.xlsx', '导出成功', 'com.nms4cloud.bi.app.controller.jd.BusinessSummaryForJd', '', '', ''), ('d730e3f9-672a-47f8-8c06-736e3cdbad4f', 1940284000182472704, 0, 2084849684163076097, '2026-08-05 03:51:15', '2026-08-05 11:51:14', '2026-08-05 08:00:00', '2026-08-05 11:51:15', 2, 'https://jj-test-1421742343.cos.ap-guangzhou.myqcloud.com/report/1940284000182472704/营业汇总表_1785901873995.xlsx', '导出成功', 'com.nms4cloud.bi.app.controller.jd.BusinessSummaryForJd', '', '', ''), ('46a2ce75-fa53-4cf7-a828-dd4b9d27867f', 1940284000182472704, 0, 2084852583151972354, '2026-08-05 04:02:46', '2026-08-05 12:02:45', '2026-08-05 08:00:00', '2026-08-05 12:02:46', 2, 'https://jj-test-1421742343.cos.ap-guangzhou.myqcloud.com/report/1940284000182472704/营业汇总表_1785902565167.xlsx', '导出成功', 'com.nms4cloud.bi.app.controller.jd.BusinessSummaryForJd', '', '', ''), ('7307523d-07a4-44ff-a642-346d847d0643', 1940284000182472704, 0, 2084886002262220802, '2026-08-05 06:15:46', '2026-08-05 14:15:33', '2026-08-05 08:00:00', '2026-08-05 14:15:46', 2, 'https://jj-test-1421742343.cos.ap-guangzhou.myqcloud.com/report/1940284000182472704/营业汇总表_1785910532902.xlsx', '导出成功', 'com.nms4cloud.bi.app.controller.jd.BusinessSummaryForJd', '', '', ''), ('f211ed8a-564c-4991-b640-01350fa82b6e', 1940284000182472704, 0, 2084889341624459265, '2026-08-05 06:28:49', '2026-08-05 14:28:49', '2026-08-05 08:00:00', '2026-08-05 14:28:49', 2, 'https://jj-test-1421742343.cos.ap-guangzhou.myqcloud.com/report/1940284000182472704/营业汇总表_1785911329071.xlsx', '导出成功', 'com.nms4cloud.bi.app.controller.jd.BusinessSummaryForJd', '', '', ''), ('3d659c83-65ff-4dbf-bbce-e853f0c8bc02', 1940284000182472704, 0, 2084924238205300737, '2026-08-05 08:47:30', '2026-08-05 16:47:29', '2026-08-05 08:00:00', '2026-08-05 16:47:30', 2, 'https://jj-test-1421742343.cos.ap-guangzhou.myqcloud.com/report/1940284000182472704/营业汇总表_1785919649060.xlsx', '导出成功', 'com.nms4cloud.bi.app.controller.jd.BusinessSummaryForJd', '', '', ''), ('c5594ba6-0d77-464a-92a4-267e0399057c', 1940284000182472704, 0, 2084932338396180481, '2026-08-05 09:19:40', '2026-08-05 17:19:40', '2026-08-05 08:00:00', '2026-08-05 17:19:40', 2, 'https://jj-test-1421742343.cos.ap-guangzhou.myqcloud.com/report/1940284000182472704/营业汇总表_1785921580300.xlsx', '导出成功', 'com.nms4cloud.bi.app.controller.jd.BusinessSummaryForJd', '', '', ''), ('6e23bf07-d745-4d6c-8593-6e369daaf256', 1940284000182472704, 0, 2084932517924974594, '2026-08-05 09:20:23', '2026-08-05 17:20:23', '2026-08-05 08:00:00', '2026-08-05 17:20:23', 2, 'https://jj-test-1421742343.cos.ap-guangzhou.myqcloud.com/report/1940284000182472704/收银明细表_1785921623103.xlsx', '导出成功', 'com.nms4cloud.bi.app.controller.jd.CashierDetailForJd', '', '', '');
