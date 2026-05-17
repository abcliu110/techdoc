/*
 Navicat Premium Dump SQL

 Source Server         : 172.16.0.12
 Source Server Type    : MySQL
 Source Server Version : 80030 (8.0.30-txsql)
 Source Host           : 172.16.0.12:3306
 Source Schema         : gylregdb

 Target Server Type    : MySQL
 Target Server Version : 80030 (8.0.30-txsql)
 File Encoding         : 65001

 Date: 08/05/2026 15:29:01
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for bd_barcodes
-- ----------------------------
DROP TABLE IF EXISTS `bd_barcodes`;
CREATE TABLE `bd_barcodes`  (
  `pid` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `barcode` bigint UNSIGNED NOT NULL DEFAULT 0 COMMENT '条码',
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品名',
  `status_` int NULL DEFAULT NULL,
  `specification` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规格',
  `unit` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '单位',
  `made_in` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '产地',
  `remark` varchar(240) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注信息',
  `sort` tinyint UNSIGNED NOT NULL DEFAULT 100 COMMENT '排序',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `barcodes_barcode_index`(`barcode` ASC) USING BTREE,
  INDEX `barcodes_name_index`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1048577 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '标准商品条码表' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for bd_barcodes_ali
-- ----------------------------
DROP TABLE IF EXISTS `bd_barcodes_ali`;
CREATE TABLE `bd_barcodes_ali`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `barcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ename` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unspsc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `width` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `height` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `depth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `origincountry` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `originplace` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `assemblycountry` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `barcodetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `catena` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `isbasicunit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `packagetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `grossweight` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `netcontent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `netweight` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `keyword` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pic` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `price` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `licensenum` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `healthpermitnum` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_bd_barcodes_ali_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 461 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for bi_diancaipici
-- ----------------------------
DROP TABLE IF EXISTS `bi_diancaipici`;
CREATE TABLE `bi_diancaipici`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `xiaofeid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `orgpid` int NULL DEFAULT NULL,
  `diancairen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `begintime` datetime NULL DEFAULT NULL,
  `endtime` datetime NULL DEFAULT NULL,
  `fuwufeilv` decimal(19, 10) NULL DEFAULT NULL,
  `dazheren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dazhefangshi` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhekoulv` decimal(19, 10) NULL DEFAULT NULL,
  `memberid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `membername` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `membersex` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `huiyuancahao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `huiyuanbalance` decimal(19, 10) NULL DEFAULT NULL,
  `huiyuanintegral` decimal(19, 10) NULL DEFAULT NULL,
  `shipingfei` decimal(19, 10) NULL DEFAULT NULL,
  `fuwufei` decimal(19, 10) NULL DEFAULT NULL,
  `zhekoue` decimal(19, 10) NULL DEFAULT NULL,
  `tuicaijine` decimal(19, 10) NULL DEFAULT NULL,
  `zengsongjine` decimal(19, 10) NULL DEFAULT NULL,
  `weishu` decimal(19, 10) NULL DEFAULT NULL,
  `lingtou` decimal(19, 10) NULL DEFAULT NULL,
  `lingtouor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `yingshoujine` decimal(19, 10) NULL DEFAULT NULL,
  `tax` decimal(19, 10) NULL DEFAULT NULL,
  `shishoujine` decimal(19, 10) NULL DEFAULT NULL,
  `shoudaojine` decimal(19, 10) NULL DEFAULT NULL,
  `zhaohuijine` decimal(19, 10) NULL DEFAULT NULL,
  `fapiaojine` decimal(19, 10) NULL DEFAULT NULL,
  `maidancishu` int NULL DEFAULT NULL,
  `maidanzhuangtai` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jiezhangfangshi` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jiaobanhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `stationid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `stationname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shouyinren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `isshoudongzhekou` tinyint NULL DEFAULT NULL,
  `fapiaodanhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_Bi_DianCaiPiCi_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_Bi_DianCaiPiCi_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for bi_diancaipicifjz
-- ----------------------------
DROP TABLE IF EXISTS `bi_diancaipicifjz`;
CREATE TABLE `bi_diancaipicifjz`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `xiaofeid` bigint NULL DEFAULT NULL,
  `orgpid` int NULL DEFAULT NULL,
  `diancairen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `begintime` datetime NULL DEFAULT NULL,
  `endtime` datetime NULL DEFAULT NULL,
  `fuwufeilv` decimal(19, 10) NULL DEFAULT NULL,
  `dazheren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dazhefangshi` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhekoulv` decimal(19, 10) NULL DEFAULT NULL,
  `memberid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `membername` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `membersex` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `huiyuancahao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `huiyuanbalance` decimal(19, 10) NULL DEFAULT NULL,
  `huiyuanintegral` decimal(19, 10) NULL DEFAULT NULL,
  `shipingfei` decimal(19, 10) NULL DEFAULT NULL,
  `fuwufei` decimal(19, 10) NULL DEFAULT NULL,
  `zhekoue` decimal(19, 10) NULL DEFAULT NULL,
  `tuicaijine` decimal(19, 10) NULL DEFAULT NULL,
  `zengsongjine` decimal(19, 10) NULL DEFAULT NULL,
  `weishu` decimal(19, 10) NULL DEFAULT NULL,
  `lingtou` decimal(19, 10) NULL DEFAULT NULL,
  `lingtouor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `yingshoujine` decimal(19, 10) NULL DEFAULT NULL,
  `tax` decimal(19, 10) NULL DEFAULT NULL,
  `shishoujine` decimal(19, 10) NULL DEFAULT NULL,
  `shoudaojine` decimal(19, 10) NULL DEFAULT NULL,
  `zhaohuijine` decimal(19, 10) NULL DEFAULT NULL,
  `fapiaojine` decimal(19, 10) NULL DEFAULT NULL,
  `maidancishu` int NULL DEFAULT NULL,
  `maidanzhuangtai` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jiezhangfangshi` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jiaobanhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `stationid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `stationname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shouyinren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `isshoudongzhekou` tinyint NULL DEFAULT NULL,
  `fapiaodanhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_Bi_DianCaiPiCiFJZ_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_Bi_DianCaiPiCiFJZ_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for bi_tblinbill
-- ----------------------------
DROP TABLE IF EXISTS `bi_tblinbill`;
CREATE TABLE `bi_tblinbill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `xiaofeid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tblid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tblname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_Bi_TblInBill_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_Bi_TblInBill_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for bi_tblinbillfjz
-- ----------------------------
DROP TABLE IF EXISTS `bi_tblinbillfjz`;
CREATE TABLE `bi_tblinbillfjz`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `xiaofeid` bigint NULL DEFAULT NULL,
  `tblid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tblname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_Bi_TblInBillFJZ_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_Bi_TblInBillFJZ_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for biz_usr_merchant
-- ----------------------------
DROP TABLE IF EXISTS `biz_usr_merchant`;
CREATE TABLE `biz_usr_merchant`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `open_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'openid',
  `merchant_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户号',
  `merchant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户名称',
  `usr_id` bigint NULL DEFAULT NULL COMMENT '用户id',
  `usr_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '账户名称',
  `staff_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户工号',
  `union_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'union_id',
  `gzh_open_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '公众号的openId',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  INDEX `idx_mid_open_id`(`mid` ASC, `open_id`(191) ASC) USING BTREE,
  INDEX `idx_union_id`(`union_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3954 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户与商户关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for buweiinshifa
-- ----------------------------
DROP TABLE IF EXISTS `buweiinshifa`;
CREATE TABLE `buweiinshifa`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `shifa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `chupingbumen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_BuWeiInShiFa_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_BuWeiInShiFa_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for buweiinshifafjz
-- ----------------------------
DROP TABLE IF EXISTS `buweiinshifafjz`;
CREATE TABLE `buweiinshifafjz`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `shifa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `chupingbumen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_BuWeiInShiFaFJZ_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_BuWeiInShiFaFJZ_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for caipingxingzhuang
-- ----------------------------
DROP TABLE IF EXISTS `caipingxingzhuang`;
CREATE TABLE `caipingxingzhuang`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `caipingxingzhuangid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caipingxingzhuangname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dailei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaolei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cai` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_CaiPingXingZhuang_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for caipingzuofa
-- ----------------------------
DROP TABLE IF EXISTS `caipingzuofa`;
CREATE TABLE `caipingzuofa`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `caipingzuofaid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caipingzuofaname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `leibie` bigint NULL DEFAULT NULL,
  `caidalei` bigint NULL DEFAULT NULL,
  `cailei` bigint NULL DEFAULT NULL,
  `caip` bigint NULL DEFAULT NULL,
  `pingying` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jiage` decimal(19, 10) NULL DEFAULT NULL,
  `chengbenjiage` decimal(19, 10) NULL DEFAULT NULL,
  `shifuochenyushuliang` tinyint NULL DEFAULT NULL,
  `mulselfamount` tinyint NULL DEFAULT NULL,
  `bumen` bigint NULL DEFAULT NULL,
  `chupingbumen` bigint NULL DEFAULT NULL,
  `canyidazhe` tinyint NULL DEFAULT NULL,
  `shouqifuwuwei` tinyint NULL DEFAULT NULL,
  `beidiancishu` int NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bihua` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caipingzuofaname2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caipingzuofaname3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `isbendi` tinyint NULL DEFAULT NULL,
  `uploadtowx` tinyint NULL DEFAULT NULL,
  `notsynctodev` tinyint NULL DEFAULT NULL,
  `showorder` int NULL DEFAULT NULL,
  `Hide_in_mall` tinyint NULL DEFAULT NULL COMMENT '微餐厅隐藏',
  `buweip` bigint NULL DEFAULT NULL COMMENT '部位lid',
  `order_default` tinyint NULL DEFAULT NULL COMMENT '点单时默认做法',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_CaiPingZuoFa_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_lid`(`lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1848527 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for caishifa
-- ----------------------------
DROP TABLE IF EXISTS `caishifa`;
CREATE TABLE `caishifa`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `cai` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caishifaid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caishifaname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `miaoshu` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `miaoshutmp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shangcaishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `buwei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zuofa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `kuowei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `yaoqiu` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeicaipingid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeicaipingpid` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_CaiShiFa_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_CaiShiFa_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1879642 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for caishifafjz
-- ----------------------------
DROP TABLE IF EXISTS `caishifafjz`;
CREATE TABLE `caishifafjz`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `cai` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caishifaid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caishifaname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `miaoshu` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `miaoshutmp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shangcaishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `buwei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zuofa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `kuowei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `yaoqiu` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeicaipingid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeicaipingpid` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_CaiShiFaFJZ_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_CaiShiFaFJZ_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17681 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for config_properties
-- ----------------------------
DROP TABLE IF EXISTS `config_properties`;
CREATE TABLE `config_properties`  (
  `PID` bigint NOT NULL AUTO_INCREMENT,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `COMPANY_ID` bigint NULL DEFAULT NULL,
  `SHOP_ID` bigint NULL DEFAULT NULL,
  `ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Key1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Value1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Application` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Profiles` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Label` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  PRIMARY KEY (`PID`) USING BTREE,
  INDEX `idx_Config_Properties_COMPANY_ID_SHOP_ID_PID`(`COMPANY_ID` ASC, `SHOP_ID` ASC, `PID` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 547 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for creditaccount
-- ----------------------------
DROP TABLE IF EXISTS `creditaccount`;
CREATE TABLE `creditaccount`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `Type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `RegistTime` datetime NULL DEFAULT NULL,
  `BeginTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `Disable` tinyint NULL DEFAULT NULL,
  `CreditLimit` decimal(19, 10) NULL DEFAULT NULL,
  `CreditBalance` decimal(19, 10) NULL DEFAULT NULL,
  `ServeMoney` decimal(19, 10) NULL DEFAULT NULL,
  `ServeBalance` decimal(19, 10) NULL DEFAULT NULL,
  `ReturnedDay` int NULL DEFAULT NULL,
  `Contacts` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PingYing` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Fax` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `MemberId` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `MemberCard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ShopName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_CreditAccount_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22063 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for creditaccounttype
-- ----------------------------
DROP TABLE IF EXISTS `creditaccounttype`;
CREATE TABLE `creditaccounttype`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `ShopName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_CreditAccountType_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12737 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for creditperson
-- ----------------------------
DROP TABLE IF EXISTS `creditperson`;
CREATE TABLE `creditperson`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `Phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Account` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `BeginTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `PingYing` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ShopName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_CreditAccount_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22640 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_card
-- ----------------------------
DROP TABLE IF EXISTS `crm_card`;
CREATE TABLE `crm_card`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `join_time` datetime NULL DEFAULT NULL,
  `balance` decimal(19, 10) NULL DEFAULT NULL,
  `principal_balance` decimal(19, 10) NULL DEFAULT NULL,
  `give_balance` decimal(19, 10) NULL DEFAULT NULL,
  `points` decimal(19, 10) NULL DEFAULT NULL,
  `sum_of_save_times` int NULL DEFAULT NULL,
  `sum_of_save` decimal(19, 10) NULL DEFAULT NULL,
  `sum_of_consume` decimal(19, 10) NULL DEFAULT NULL,
  `sum_of_consume_times` int NULL DEFAULT NULL,
  `over_time` datetime NULL DEFAULT NULL,
  `last_consume_time` datetime NULL DEFAULT NULL,
  `openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `out_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `headimgurl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pwd` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type_level_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Member` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Member_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Member_id_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Agent_lmnid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `invitees_lmnid` bigint NULL DEFAULT NULL COMMENT '邀请人lid',
  `Invitees` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Salesman_lmnid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Salesman` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Unpaid_amount` decimal(19, 10) NULL DEFAULT NULL,
  `Session_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `last_card_level_time` datetime NULL DEFAULT NULL,
  `Last_charge_time` datetime NULL DEFAULT NULL COMMENT '最后一次充值时间',
  `sum_of_points` decimal(24, 6) NULL DEFAULT NULL COMMENT '累计消费积分',
  `first_gift_coupon_done` tinyint(1) NULL DEFAULT NULL COMMENT '首次充值已赠券',
  `wx_card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '微信卡券编号',
  `back_balance` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '返现余额',
  `sum_of_back` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '累计返现',
  `sum_of_back_times` int NULL DEFAULT 0 COMMENT '返现次数',
  `sum_of_save_give` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '累计充值赠送金额',
  `sum_of_consume_give` decimal(24, 6) NULL DEFAULT 0.000000 COMMENT '累计消费赠送金额',
  `dash_balance` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '霸王餐余额',
  `unpaid_at` datetime NULL DEFAULT NULL COMMENT '冻结金额时间',
  `unpaid_give_amount` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '未到账赠送金额（冻结金额）',
  `invoice_balance` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '发票余额',
  `rebate_ratio` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '返佣比例',
  `rebate_rule_lid` bigint NULL DEFAULT NULL COMMENT '返佣规则lid',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_crm_card_company_id_phone`(`company_id` ASC, `Phone`(191) ASC) USING BTREE,
  INDEX `idx_crm_card_company_id_ID`(`company_id` ASC, `id`(191) ASC) USING BTREE,
  INDEX `idx_crm_card_company_id_member_code`(`company_id` ASC, `Member_code`(191) ASC) USING BTREE,
  INDEX `idx_crmcard_cid_openid`(`company_id` ASC, `openid`(191) ASC) USING BTREE,
  INDEX `idx_crm_wx_card_id`(`company_id` ASC, `wx_card_id`(191) ASC) USING BTREE,
  INDEX `index_mid_lid`(`company_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_unionid`(`company_id` ASC, `unionid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 528808 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_card_level
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_level`;
CREATE TABLE `crm_card_level`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_code` bigint NULL DEFAULT NULL COMMENT '会员卡类型lid',
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bg_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `font_color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bg_color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `upg_by_cumulative_consumption_amount` tinyint NULL DEFAULT NULL,
  `cumulative_consumption_amount` decimal(19, 10) NULL DEFAULT NULL,
  `upg_by_cumulative_consumption_count` tinyint NULL DEFAULT NULL,
  `cumulative_consumption_count` decimal(19, 10) NULL DEFAULT NULL,
  `upg_by_cumulative_consumption_amount_and_count` tinyint NULL DEFAULT NULL,
  `upg_by_cumulative_save_amount` tinyint NULL DEFAULT NULL,
  `cumulative_save_amount` decimal(19, 10) NULL DEFAULT NULL,
  `upg_by_earn_points` tinyint NULL DEFAULT NULL,
  `earn_points` decimal(19, 10) NULL DEFAULT NULL,
  `upg_by_points_balance` tinyint NULL DEFAULT NULL,
  `earn_balance` decimal(19, 10) NULL DEFAULT NULL,
  `deg_by_expiration_date` tinyint NULL DEFAULT NULL,
  `expiration_date` decimal(19, 10) NULL DEFAULT NULL,
  `deg_by_balance` tinyint NULL DEFAULT NULL,
  `balance` decimal(19, 10) NULL DEFAULT NULL,
  `deg_by_consumption_limit` tinyint NULL DEFAULT NULL,
  `consumption_limit_day` int NULL DEFAULT NULL,
  `consumption_limit_amount` decimal(19, 10) NULL DEFAULT NULL,
  `add_point_rule_amount` decimal(19, 10) NULL DEFAULT NULL,
  `add_point_rule_point` decimal(19, 10) NULL DEFAULT NULL,
  `add_point_rule_max_point_one_time` decimal(19, 10) NULL DEFAULT NULL,
  `discount_rate` decimal(19, 10) NULL DEFAULT NULL,
  `discount_range` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_price_discount_can_use_at_the_same_time` tinyint NULL DEFAULT NULL,
  `can_credit` tinyint NULL DEFAULT NULL,
  `can_use_member_price` tinyint NULL DEFAULT NULL,
  `can_not_use_member_price_and_discount_when_balance_below` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Level_upgrade_price` decimal(19, 10) NULL DEFAULT NULL,
  `Coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Coupon_pkg_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Coupon_pkg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Discount_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Discount` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `discount_shop_id` bigint NULL DEFAULT NULL COMMENT '折扣方式店铺编号',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_card_level_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1714 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_card_level_and_cash_back
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_level_and_cash_back`;
CREATE TABLE `crm_card_level_and_cash_back`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_level_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `min_amount` decimal(19, 10) NULL DEFAULT NULL,
  `max_amount` decimal(19, 10) NULL DEFAULT NULL,
  `cash_back_type` int NULL DEFAULT NULL,
  `cash_back_amount` decimal(19, 10) NULL DEFAULT NULL,
  `cash_back_amount_rate` decimal(19, 10) NULL DEFAULT NULL,
  `cash_back_max_amount` decimal(19, 10) NULL DEFAULT NULL,
  `Valid_begin_time` datetime NULL DEFAULT NULL,
  `Valid_end_time` datetime NULL DEFAULT NULL,
  `Deferred_day_num` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_card_level_and_cash_back_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_card_level_and_more_recharge
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_level_and_more_recharge`;
CREATE TABLE `crm_card_level_and_more_recharge`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_level_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `min_amount` decimal(19, 10) NULL DEFAULT NULL,
  `max_amount` decimal(19, 10) NULL DEFAULT NULL,
  `more_recharge_rate` decimal(19, 10) NULL DEFAULT NULL,
  `give_type` int NULL DEFAULT NULL,
  `give_amount` decimal(19, 10) NULL DEFAULT NULL,
  `give_amount_rate` decimal(19, 10) NULL DEFAULT NULL,
  `give_max_amount` decimal(19, 10) NULL DEFAULT NULL,
  `Valid_begin_time` datetime NULL DEFAULT NULL,
  `Valid_end_time` datetime NULL DEFAULT NULL,
  `Enable_preset_recharge` tinyint NULL DEFAULT NULL,
  `Preset_recharge_amount` decimal(19, 10) NULL DEFAULT NULL,
  `apply_to_store` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '适用门店',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_card_level_and_more_recharge_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_card_level_and_overlord_meal
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_level_and_overlord_meal`;
CREATE TABLE `crm_card_level_and_overlord_meal`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_level_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `min_amount` decimal(19, 10) NULL DEFAULT NULL,
  `max_amount` decimal(19, 10) NULL DEFAULT NULL,
  `recharge_multiple_times` int NULL DEFAULT NULL,
  `Valid_begin_time` datetime NULL DEFAULT NULL,
  `Valid_end_time` datetime NULL DEFAULT NULL,
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `once` tinyint(1) NULL DEFAULT NULL COMMENT '仅限参与一次',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_card_level_and_overlord_meal_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_card_level_record
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_level_record`;
CREATE TABLE `crm_card_level_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_id_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_id_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_out_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `type_of_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `level_before` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `level_after` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `level_code_before` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `level_code_after` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `need_amount` decimal(19, 10) NULL DEFAULT NULL,
  `is_total` tinyint NULL DEFAULT NULL,
  `order_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_cancel` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_card_level_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_crm_card_level_record_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_card_op_record
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_op_record`;
CREATE TABLE `crm_card_op_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_out_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operation_model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Member_id_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_id_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_card_op_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_crm_card_op_record_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4486 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_card_points_record
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_points_record`;
CREATE TABLE `crm_card_points_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_out_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operation_model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `balance_before` decimal(19, 10) NULL DEFAULT NULL,
  `balance_after` decimal(19, 10) NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `save_rule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `save_rule_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Member_id_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_id_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Tran_source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Out_order_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Is_third_party` tinyint NULL DEFAULT NULL,
  `If_deal_success` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_card_points_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_crm_card_points_record_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_crm_card_points_record_COMPANY_SHOP_Order_bill_id`(`company_id` ASC, `shop_id` ASC, `order_bill_id`(191) ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_card_record
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_record`;
CREATE TABLE `crm_card_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_out_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operation_model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `balance_before` decimal(19, 10) NULL DEFAULT NULL,
  `balance_after` decimal(19, 10) NULL DEFAULT NULL,
  `principal_amount` decimal(19, 10) NULL DEFAULT NULL,
  `give_amount` decimal(19, 10) NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `save_rule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `save_rule_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pay_way` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pay_way_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `invoice_amount` decimal(19, 10) NULL DEFAULT NULL,
  `give_point` decimal(19, 10) NULL DEFAULT NULL,
  `Principal_amount_before` decimal(19, 10) NULL DEFAULT NULL,
  `Principal_amount_after` decimal(19, 10) NULL DEFAULT NULL,
  `Give_amount_before` decimal(19, 10) NULL DEFAULT NULL,
  `Give_amount_after` decimal(19, 10) NULL DEFAULT NULL,
  `Recharge_number` int NULL DEFAULT NULL,
  `Member_id_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_id_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Is_refund` tinyint NULL DEFAULT NULL,
  `Is_cancel` tinyint NULL DEFAULT NULL,
  `Out_order_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Is_third_party` tinyint NULL DEFAULT NULL,
  `If_deal_success` tinyint NULL DEFAULT NULL,
  `Give_coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Give_coupon_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Marketer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Commission_amount` decimal(15, 4) NULL DEFAULT NULL,
  `Commission_ratio` decimal(15, 4) NULL DEFAULT NULL,
  `Marketer_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `source_sid` bigint NULL DEFAULT NULL COMMENT '源门店号',
  `task_lid` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_card_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_crm_card_record_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_crm_card_record_company_id_order_bill_id`(`company_id` ASC, `order_bill_id`(191) ASC) USING BTREE,
  INDEX `idx_crm_card_record_company_id_lmnid`(`company_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 292215 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_card_type
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_type`;
CREATE TABLE `crm_card_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `kind` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bg_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `font_color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bg_color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `points_to_cash_point` decimal(19, 10) NULL DEFAULT NULL,
  `points_to_cash_money` decimal(19, 10) NULL DEFAULT NULL,
  `points_to_cash_max_rule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `points_to_cash_max` decimal(19, 10) NULL DEFAULT NULL,
  `points_to_cash_rule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `points_to_cash_min` decimal(19, 10) NULL DEFAULT NULL,
  `offline_cost` decimal(19, 10) NULL DEFAULT NULL,
  `online_cost` decimal(19, 10) NULL DEFAULT NULL,
  `deposit` decimal(19, 10) NULL DEFAULT NULL,
  `save_amount_while_apply` decimal(19, 10) NULL DEFAULT NULL,
  `deduction_rule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `enable_on_line_save` tinyint NULL DEFAULT NULL,
  `enable_on_line_deduction` tinyint NULL DEFAULT NULL,
  `use_rule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `save_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `pay_by_rate` decimal(19, 10) NULL DEFAULT NULL,
  `Default_card_type` tinyint NULL DEFAULT NULL,
  `Upg_by_cumulative_consumption_amount` tinyint NULL DEFAULT NULL,
  `Cumulative_consumption_amount` decimal(19, 10) NULL DEFAULT NULL,
  `Upg_by_cumulative_consumption_count` tinyint NULL DEFAULT NULL,
  `Cumulative_consumption_count` decimal(19, 10) NULL DEFAULT NULL,
  `Upg_by_cumulative_save_amount` tinyint NULL DEFAULT NULL,
  `Cumulative_save_amount` decimal(19, 10) NULL DEFAULT NULL,
  `Upg_by_earn_points` tinyint NULL DEFAULT NULL,
  `Earn_points` decimal(19, 10) NULL DEFAULT NULL,
  `Upg_by_points_balance` tinyint NULL DEFAULT NULL,
  `Earn_balance` decimal(19, 10) NULL DEFAULT NULL,
  `Deg_by_expiration_date` tinyint NULL DEFAULT NULL,
  `Expiration_date` decimal(19, 10) NULL DEFAULT NULL,
  `Deg_by_balance` tinyint NULL DEFAULT NULL,
  `Balance` decimal(19, 10) NULL DEFAULT NULL,
  `Deg_by_consumption_limit` tinyint NULL DEFAULT NULL,
  `Consumption_limit_day` int NULL DEFAULT NULL,
  `Consumption_limit_amount` decimal(19, 10) NULL DEFAULT NULL,
  `discount_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `discount_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `integral_plan_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `integral_plan_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `by_recharge_validity_demote` tinyint NULL DEFAULT NULL COMMENT '通过充值有效期降级',
  `recharge_validity_days` int NULL DEFAULT NULL COMMENT '充值有效期天数',
  `discount_shop_id` bigint NULL DEFAULT NULL COMMENT '折扣方式店铺编号',
  `pay_rate_for_bill` decimal(24, 6) NULL DEFAULT NULL COMMENT '每次支付本账单的比例',
  `coupon_lid` bigint NULL DEFAULT NULL COMMENT '购卡送券',
  `upgrade_h5_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '升级h5地址',
  `upgrade_qr_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '升级小程序二维码',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_card_type_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 467 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_card_type_free_rule
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_type_free_rule`;
CREATE TABLE `crm_card_type_free_rule`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规则名称',
  `card_type_code` bigint NULL DEFAULT NULL COMMENT '会员编号',
  `free_times` int NULL DEFAULT NULL COMMENT '免赠次数',
  `food_list` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品编号列表',
  `start_date` datetime NULL DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime NULL DEFAULT NULL COMMENT '结束日期',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员免赠规则' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_card_upg
-- ----------------------------
DROP TABLE IF EXISTS `crm_card_upg`;
CREATE TABLE `crm_card_upg`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户号',
  `SHOP_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店号',
  `LMNID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `status_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '记录状态',
  `card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员卡号',
  `card_code` bigint NULL DEFAULT NULL COMMENT '会员卡lmnid',
  `org_card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '原会员卡类型',
  `org_card_type_code` bigint NULL DEFAULT NULL COMMENT '原会员卡类型编号',
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员卡类型',
  `card_type_code` bigint NULL DEFAULT NULL COMMENT '会员卡类型编号',
  `create_time` datetime NULL DEFAULT NULL COMMENT '升级时间',
  `demote` tinyint NULL DEFAULT NULL COMMENT '是否降级标志 0未执行降级 1已执行降级',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_card_upg_COMPANY_SHOP_LmnID`(`COMPANY_ID` ASC, `SHOP_ID` ASC, `LMNID` ASC) USING BTREE,
  INDEX `IDX_U_crm_card_upg_COMPANY_SHOP_card_code`(`COMPANY_ID` ASC, `SHOP_ID` ASC, `card_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1023 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员升级表' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_join_activity
-- ----------------------------
DROP TABLE IF EXISTS `crm_join_activity`;
CREATE TABLE `crm_join_activity`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `begin_date` datetime NULL DEFAULT NULL,
  `end_date` datetime NULL DEFAULT NULL,
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_level_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `usage_scenarios` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `purchase_amount` decimal(19, 10) NULL DEFAULT NULL,
  `recharge_amount` decimal(19, 10) NULL DEFAULT NULL,
  `card_fee` decimal(19, 10) NULL DEFAULT NULL,
  `card_validity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `amount_of_bonus_stored_value` decimal(19, 10) NULL DEFAULT NULL,
  `delayed_days` int NULL DEFAULT NULL,
  `bonus_points` decimal(19, 10) NULL DEFAULT NULL,
  `bonus_coupons` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bonus_coupons_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_termination` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Is_all_store` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_join_activity_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_join_activity_shop
-- ----------------------------
DROP TABLE IF EXISTS `crm_join_activity_shop`;
CREATE TABLE `crm_join_activity_shop`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Plan_code` bigint NULL DEFAULT NULL,
  `Owner_shop_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_join_activity_shop_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_member
-- ----------------------------
DROP TABLE IF EXISTS `crm_member`;
CREATE TABLE `crm_member`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_details` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sex` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `birthday` datetime NULL DEFAULT NULL,
  `birthday_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `certificate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `certificate_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `postal_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `position` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `submitter` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_out_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Join_time` datetime NULL DEFAULT NULL,
  `Agent_lmnid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Invitees_lmnid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Invitees` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Salesman_lmnid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Salesman` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `give_coupon_time` datetime NULL DEFAULT NULL COMMENT '生日赠劵时间',
  `has_give_coupon` tinyint NULL DEFAULT 0 COMMENT '已生日赠劵',
  `had_modify_birthday` tinyint NULL DEFAULT 0 COMMENT '已修改过生日',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_member_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_crm_member_company_id_phone`(`company_id` ASC, `phone`(191) ASC) USING BTREE,
  INDEX `idx_crm_member_company_id_lmnid`(`company_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 604561 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_save_rule
-- ----------------------------
DROP TABLE IF EXISTS `crm_save_rule`;
CREATE TABLE `crm_save_rule`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `begin_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `save_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `save_amount` decimal(19, 10) NULL DEFAULT NULL,
  `give_amount` decimal(19, 10) NULL DEFAULT NULL,
  `give_point` decimal(19, 10) NULL DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Give_coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Give_coupon_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Give_coupon_is_map` tinyint NULL DEFAULT NULL,
  `HideInWeapp` tinyint NULL DEFAULT NULL,
  `Unpaid_amount` decimal(19, 10) NULL DEFAULT NULL,
  `give_coupon_num` int NULL DEFAULT NULL,
  `Commission_ratio` decimal(15, 4) NULL DEFAULT NULL,
  `Commission_amount` decimal(15, 4) NULL DEFAULT NULL,
  `upgrade_card_type` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `upgrade_card_type_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `first_charge_gift_coupon` tinyint(1) NULL DEFAULT NULL COMMENT '首次充值赠券',
  `apply_to_store` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '适用门店',
  `as_upgrade_cost` tinyint(1) NOT NULL DEFAULT 0 COMMENT '作为升级工本费',
  `optional` tinyint(1) NOT NULL DEFAULT 0 COMMENT '赠送可选券',
  `optional_coupons` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '可选券列表',
  `unpaid_rate` decimal(24, 6) NULL DEFAULT NULL COMMENT '当餐不可用比例',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_save_rule_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 86 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_save_rule_interval
-- ----------------------------
DROP TABLE IF EXISTS `crm_save_rule_interval`;
CREATE TABLE `crm_save_rule_interval`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `min_amount` decimal(19, 10) NULL DEFAULT NULL,
  `max_amount` decimal(19, 10) NULL DEFAULT NULL,
  `give_money_rule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `give_money` decimal(19, 10) NULL DEFAULT NULL,
  `give_point_reule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `give_point` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_save_rule_interval_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_shop_in_card_type
-- ----------------------------
DROP TABLE IF EXISTS `crm_shop_in_card_type`;
CREATE TABLE `crm_shop_in_card_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_shop_in_card_type_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for crm_team_leader
-- ----------------------------
DROP TABLE IF EXISTS `crm_team_leader`;
CREATE TABLE `crm_team_leader`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `enable` tinyint NULL DEFAULT NULL,
  `crttime` datetime NULL DEFAULT NULL,
  `audit_status` tinyint NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `commit_audit_time` datetime NULL DEFAULT NULL,
  `audit_time` datetime NULL DEFAULT NULL,
  `reviewer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Owner_shop_id` bigint NULL DEFAULT NULL,
  `Sum_amount` decimal(19, 10) NULL DEFAULT NULL,
  `Amount` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_crm_team_leader_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for cunjiubiandongjilu
-- ----------------------------
DROP TABLE IF EXISTS `cunjiubiandongjilu`;
CREATE TABLE `cunjiubiandongjilu`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cardid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goodsname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `curacount` decimal(19, 10) NULL DEFAULT NULL,
  `storetime` datetime NULL DEFAULT NULL,
  `returntime` datetime NULL DEFAULT NULL,
  `timeline` datetime NULL DEFAULT NULL,
  `qujiutaiming` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `taiming` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sendovertimemsg` tinyint NULL DEFAULT NULL,
  `cunjiuren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cunjiurenphone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qujiuren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qujiurenphone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cunjiuoperator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qujiuoperator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operatedamount` decimal(19, 10) NULL DEFAULT NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_CunJiuBianDongJiLu_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_CunJiuBianDongJiLu_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_CunJiuBianDongJiLu_COMPANY_SHOP_ID`(`company_id` ASC, `shop_id` ASC, `id`(191) ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for cunjiujilu
-- ----------------------------
DROP TABLE IF EXISTS `cunjiujilu`;
CREATE TABLE `cunjiujilu`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cardid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goodsname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `acount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `storetime` datetime NULL DEFAULT NULL,
  `returntime` datetime NULL DEFAULT NULL,
  `pwd` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `timeline` datetime NULL DEFAULT NULL,
  `taiming` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sendovertimemsg` tinyint NULL DEFAULT NULL,
  `cunjiuren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cunjiurenphone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cunjiuoperator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qujiuren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qujiurenphone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_CunJiuJiLu_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 42991 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for data_version_info
-- ----------------------------
DROP TABLE IF EXISTS `data_version_info`;
CREATE TABLE `data_version_info`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `ver_date` datetime NULL DEFAULT NULL,
  `release_time` datetime NULL DEFAULT NULL,
  `version_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cos_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_data_version_info_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for dbupglog
-- ----------------------------
DROP TABLE IF EXISTS `dbupglog`;
CREATE TABLE `dbupglog`  (
  `PID` bigint NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` bigint NOT NULL,
  `ID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `SHOP_ID` bigint NULL DEFAULT NULL,
  `LmnID` bigint NULL DEFAULT NULL,
  `Name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `YingYeRiQi` datetime NULL DEFAULT NULL,
  `Year_` int NULL DEFAULT NULL,
  `Month_` int NULL DEFAULT NULL,
  `Day_` int NULL DEFAULT NULL,
  `RunOpr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `RunTime` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `SqlText` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `RetCode` int NULL DEFAULT NULL,
  `RetMsg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`PID`) USING BTREE,
  INDEX `IDX_DBUpgLog_COMPANY_SHOP_YYRQ`(`COMPANY_ID` ASC, `SHOP_ID` ASC, `YingYeRiQi` ASC, `PID` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 541 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for fukuanqingkuang
-- ----------------------------
DROP TABLE IF EXISTS `fukuanqingkuang`;
CREATE TABLE `fukuanqingkuang`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `xiaofeid` bigint NULL DEFAULT NULL,
  `diancaipici` int NULL DEFAULT NULL,
  `fukuanqingkuangid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fukuanqingkuangname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhifujine` decimal(19, 10) NULL DEFAULT NULL,
  `huilv` decimal(19, 10) NULL DEFAULT NULL,
  `hsjine` decimal(19, 10) NULL DEFAULT NULL,
  `zhenshishouru` decimal(19, 10) NULL DEFAULT NULL,
  `exchangable` tinyint NULL DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhaohuijine` decimal(19, 10) NULL DEFAULT NULL,
  `shishoujine` decimal(19, 10) NULL DEFAULT NULL,
  `sumofintegrate` decimal(19, 10) NULL DEFAULT NULL,
  `huiyuankaid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `huiyuanname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `guazhangid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `guazhangname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qiandanren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `returnbillid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xianjinjuanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `yujiaodingjinid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shouyinyuan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `billnumber` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `availablepoint` decimal(19, 10) NULL DEFAULT NULL,
  `availablevalue` decimal(19, 10) NULL DEFAULT NULL,
  `morememberkaid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `morememberid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `moremembername` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paymoney` decimal(19, 10) NULL DEFAULT NULL,
  `norealincome` tinyint NULL DEFAULT NULL,
  `shishoulv` decimal(19, 10) NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `posserialno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paychanel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `payplatform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paystatus` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `ShopName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `TuiKuanJinE` decimal(19, 10) NULL DEFAULT NULL,
  `Is_inline` tinyint NULL DEFAULT NULL,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '店铺名称',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开台时间',
  `checkout_time` datetime NULL DEFAULT NULL COMMENT '结账时间',
  `order_sub_type` int NULL DEFAULT NULL COMMENT '账单类型;堂食、外卖、自提',
  `shift_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次',
  `area_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区域名称',
  `table_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台名称',
  `checkout_by` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标记',
  `saas_order_no` bigint NULL DEFAULT NULL COMMENT '账单流水号',
  `takeout_channel` int NULL DEFAULT NULL COMMENT '外卖渠道',
  `checkout_time_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '餐段',
  `free_service_charge` tinyint NULL DEFAULT NULL COMMENT '免服务费',
  `online` tinyint NULL DEFAULT NULL COMMENT '线上订单',
  `actual_income` decimal(19, 10) NULL DEFAULT 0.0000000000 COMMENT '实际收入',
  `virtual_income` decimal(19, 10) NULL DEFAULT 0.0000000000 COMMENT '虚拟收入',
  `group_promote_amount` decimal(24, 10) NULL DEFAULT NULL COMMENT '团购折扣',
  `member_gift_amount` decimal(24, 10) NULL DEFAULT NULL COMMENT '赠送折扣',
  `promote_detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '优惠明细',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_FuKuanQingKuang_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_FuKuanQingKuang_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_FuKuanQingKuang_COMPANY_SHOP_XFDID`(`company_id` ASC, `shop_id` ASC, `xiaofeidanid`(191) ASC) USING BTREE,
  INDEX `idx_report_date`(`yingyeriqi` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2376368 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for fukuanqingkuangfjz
-- ----------------------------
DROP TABLE IF EXISTS `fukuanqingkuangfjz`;
CREATE TABLE `fukuanqingkuangfjz`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `xiaofeid` bigint NULL DEFAULT NULL,
  `diancaipici` int NULL DEFAULT NULL,
  `fukuanqingkuangid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fukuanqingkuangname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhifujine` decimal(19, 10) NULL DEFAULT NULL,
  `huilv` decimal(19, 10) NULL DEFAULT NULL,
  `hsjine` decimal(19, 10) NULL DEFAULT NULL,
  `tuikuanjine` decimal(19, 10) NULL DEFAULT NULL,
  `zhenshishouru` decimal(19, 10) NULL DEFAULT NULL,
  `exchangable` tinyint NULL DEFAULT NULL,
  `type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhaohuijine` decimal(19, 10) NULL DEFAULT NULL,
  `shishoujine` decimal(19, 10) NULL DEFAULT NULL,
  `sumofintegrate` decimal(19, 10) NULL DEFAULT NULL,
  `huiyuankaid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `huiyuanname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `guazhangid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `guazhangname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qiandanren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `returnbillid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xianjinjuanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `yujiaodingjinid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shouyinyuan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `billnumber` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `availablepoint` decimal(19, 10) NULL DEFAULT NULL,
  `availablevalue` decimal(19, 10) NULL DEFAULT NULL,
  `morememberkaid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `morememberid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `moremembername` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paymoney` decimal(19, 10) NULL DEFAULT NULL,
  `norealincome` tinyint NULL DEFAULT NULL,
  `shishoulv` decimal(19, 10) NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `posserialno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paychanel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `payplatform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paystatus` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shopname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Is_inline` tinyint NULL DEFAULT NULL,
  `start_time` datetime NULL DEFAULT NULL COMMENT '开台时间',
  `checkout_time` datetime NULL DEFAULT NULL COMMENT '结账时间',
  `order_sub_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单子类型',
  `shift_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次名称',
  `area_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区域名称',
  `table_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台名称',
  `checkout_by` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `saas_order_no` bigint NULL DEFAULT NULL COMMENT 'SaaS订单号',
  `takeout_channel` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外卖渠道',
  `checkout_time_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '结账时段名称',
  `online` tinyint NULL DEFAULT NULL COMMENT '是否线上(0:否,1:是)',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_FuKuanQingKuangFJZ_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_FuKuanQingKuangFJZ_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12422 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for fx_devdeliveryrecord
-- ----------------------------
DROP TABLE IF EXISTS `fx_devdeliveryrecord`;
CREATE TABLE `fx_devdeliveryrecord`  (
  `PID` bigint NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` bigint NULL DEFAULT NULL,
  `ID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `SHOP_ID` bigint NULL DEFAULT NULL,
  `Name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `DateTime` datetime NULL DEFAULT NULL,
  `MachineModel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `DeliveryNum` int NULL DEFAULT NULL,
  `Amount` decimal(19, 10) NULL DEFAULT NULL,
  `Price` decimal(19, 10) NULL DEFAULT NULL,
  `DeliveryStatus` int NULL DEFAULT NULL,
  `Consignor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `DeliveryTime` datetime NULL DEFAULT NULL,
  `DeviceNo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `DaiLiShangId` int NULL DEFAULT NULL,
  PRIMARY KEY (`PID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for jiaobanxinxi
-- ----------------------------
DROP TABLE IF EXISTS `jiaobanxinxi`;
CREATE TABLE `jiaobanxinxi`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `jiaobanhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `stationname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jiaobanrenname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `alive` tinyint NULL DEFAULT NULL,
  `starttime` datetime NULL DEFAULT NULL,
  `endtime` datetime NULL DEFAULT NULL,
  `billnum` int NULL DEFAULT NULL,
  `sumofconsume` decimal(19, 10) NULL DEFAULT NULL,
  `sumofservice` decimal(19, 10) NULL DEFAULT NULL,
  `sumofdiscount` decimal(19, 10) NULL DEFAULT NULL,
  `sumofincome` decimal(19, 10) NULL DEFAULT NULL,
  `shijijine` decimal(19, 10) NULL DEFAULT NULL,
  `beiyongjin` decimal(19, 10) NULL DEFAULT NULL,
  `printcount` int NULL DEFAULT NULL,
  `upload` tinyint NULL DEFAULT NULL,
  `StationID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `JiaoBanRenID` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_JiaoBanXinXi_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_JiaoBanXinXi_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for kouwei
-- ----------------------------
DROP TABLE IF EXISTS `kouwei`;
CREATE TABLE `kouwei`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `kouweiid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `kouweiname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `leixing` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_KouWei_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for kouweileixing
-- ----------------------------
DROP TABLE IF EXISTS `kouweileixing`;
CREATE TABLE `kouweileixing`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `kouweileixingid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `kouweileixingname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dailei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaolei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cai` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_KouWeiLeiXing_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for kuoweiinshifa
-- ----------------------------
DROP TABLE IF EXISTS `kuoweiinshifa`;
CREATE TABLE `kuoweiinshifa`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `shifa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_KuoWeiInShiFa_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_KuoWeiInShiFa_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for kuoweiinshifafjz
-- ----------------------------
DROP TABLE IF EXISTS `kuoweiinshifafjz`;
CREATE TABLE `kuoweiinshifafjz`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `shifa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_KuoWeiInShiFaFJZ_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_KuoWeiInShiFaFJZ_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for mn_caiandzuofaleibie
-- ----------------------------
DROP TABLE IF EXISTS `mn_caiandzuofaleibie`;
CREATE TABLE `mn_caiandzuofaleibie`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `caip` bigint NULL DEFAULT NULL,
  `zuofaleibie` bigint NULL DEFAULT NULL,
  `amount` int NULL DEFAULT NULL,
  `maxamount` int NULL DEFAULT NULL,
  `hide` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_MN_CaiAndZuoFaLeiBie_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15488 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for pos_give_bill
-- ----------------------------
DROP TABLE IF EXISTS `pos_give_bill`;
CREATE TABLE `pos_give_bill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单号',
  `donee_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '受赠人手机',
  `donee` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '受赠人',
  `donor_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '打赏人手机',
  `donor` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '打赏人',
  `amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '打赏金额',
  `done` tinyint(1) NULL DEFAULT NULL COMMENT '支付成功',
  `payment_state` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付状态',
  `payment_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付单号',
  `payment_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `payment_qr_code` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付码',
  `merchant_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付商户号',
  `terminal_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '终端号',
  `terminal_trace` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付秘钥',
  `closed` tinyint(1) NULL DEFAULT NULL COMMENT '已经转结',
  `closed_time` datetime NULL DEFAULT NULL COMMENT '转结时间',
  `closed_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转结人',
  `report_date` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `depart` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `table_area` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `sid_id`(`sid` ASC, `id` ASC) USING BTREE,
  INDEX `done`(`done` ASC) USING BTREE,
  INDEX `closed`(`closed` ASC) USING BTREE,
  INDEX `created_time`(`created_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '打赏记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for prn_parasinstyle
-- ----------------------------
DROP TABLE IF EXISTS `prn_parasinstyle`;
CREATE TABLE `prn_parasinstyle`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_Prn_ParasInStyle_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for prn_printjob
-- ----------------------------
DROP TABLE IF EXISTS `prn_printjob`;
CREATE TABLE `prn_printjob`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `styletype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `createtime` datetime NULL DEFAULT NULL,
  `printtime` datetime NULL DEFAULT NULL,
  `delayprinttime` datetime NULL DEFAULT NULL,
  `prnqueuename` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `printcount` int NULL DEFAULT NULL,
  `paras` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xfdid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xfdname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `oldxfdname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inited` tinyint NULL DEFAULT NULL,
  `curprinterpid` int NULL DEFAULT NULL,
  `printed` tinyint NULL DEFAULT NULL,
  `xfcpname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bumen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `iscpbml` tinyint NULL DEFAULT NULL,
  `reprintcount` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_Prn_PrintJob_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for prn_printjobitem
-- ----------------------------
DROP TABLE IF EXISTS `prn_printjobitem`;
CREATE TABLE `prn_printjobitem`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `job` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contenttype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `printcontent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `width` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `align` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fontname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fontcolor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fontsize` int NULL DEFAULT NULL,
  `comfontsize` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bold` tinyint NULL DEFAULT NULL,
  `italic` tinyint NULL DEFAULT NULL,
  `underline` tinyint NULL DEFAULT NULL,
  `strikethrough` tinyint NULL DEFAULT NULL,
  `rowspace` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `condition_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_Prn_PrintJobItem_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for prn_printstyle
-- ----------------------------
DROP TABLE IF EXISTS `prn_printstyle`;
CREATE TABLE `prn_printstyle`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sourcestring` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `prnnum` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_Prn_PrintStyle_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for prn_stylecontent
-- ----------------------------
DROP TABLE IF EXISTS `prn_stylecontent`;
CREATE TABLE `prn_stylecontent`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `style_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contenttype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `printcontent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `width` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `align` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fontname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fontcolor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fontsize` int NULL DEFAULT NULL,
  `comfontsize` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bold` tinyint NULL DEFAULT NULL,
  `italic` tinyint NULL DEFAULT NULL,
  `underline` tinyint NULL DEFAULT NULL,
  `strikethrough` tinyint NULL DEFAULT NULL,
  `rowspace` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `condition_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_Prn_StyleContent_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for quanjucanshu
-- ----------------------------
DROP TABLE IF EXISTS `quanjucanshu`;
CREATE TABLE `quanjucanshu`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `strval` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strval2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strval3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intval` int NULL DEFAULT NULL,
  `boolval` tinyint NULL DEFAULT NULL,
  `doubleval` decimal(19, 10) NULL DEFAULT NULL,
  `dateval` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_quanjucanshu_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for qywx_auth_info
-- ----------------------------
DROP TABLE IF EXISTS `qywx_auth_info`;
CREATE TABLE `qywx_auth_info`  (
  `PID` bigint NOT NULL COMMENT '物理主键',
  `TENANT_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '租户号',
  `REVISION` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'REVISION',
  `CREATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'CREATED_BY',
  `CREATED_TIME` datetime NULL DEFAULT NULL COMMENT 'CREATED_TIME',
  `UPDATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'UPDATED_BY',
  `UPDATED_TIME` datetime NULL DEFAULT NULL COMMENT 'UPDATED_TIME',
  `SUITE_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '第三方应用的SuiteId',
  `AUTH_CODE` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '授权的auth_code,最长为512字节。用于获取企业的永久授权码。5分钟内有效',
  `AUTH_CORPID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '授权方的corpid',
  PRIMARY KEY (`PID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '企业微信授权信息' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for qywx_contact
-- ----------------------------
DROP TABLE IF EXISTS `qywx_contact`;
CREATE TABLE `qywx_contact`  (
  `PID` bigint NOT NULL COMMENT '物理主键',
  `TENANT_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '租户号',
  `REVISION` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'REVISION',
  `CREATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'CREATED_BY',
  `CREATED_TIME` datetime NULL DEFAULT NULL COMMENT 'CREATED_TIME',
  `UPDATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'UPDATED_BY',
  `UPDATED_TIME` datetime NULL DEFAULT NULL COMMENT 'UPDATED_TIME',
  `SUITE_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '第三方应用的SuiteId',
  `AUTH_CORPID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '授权方的corpid',
  `USER_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '成员UserID',
  `NAME` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '成员名称',
  `DEPARTMENT` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新后成员所在部门列表',
  `MOBILE` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号码，仅通讯录管理应用可获取',
  `POSITION` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '职位信息。长度为0~64个字节，仅通讯录管理应用可获取',
  `GENDER` int NULL DEFAULT NULL COMMENT '性别。1表示男性，2表示女性',
  `EMAIL` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '邮箱，仅通讯录管理应用可获取',
  `STATUS` int NULL DEFAULT NULL COMMENT '激活状态：1=激活或关注， 2=禁用， 4=未激活 已激活代表已激活企业微信或已关注微工作台（原企业号）。未激活代表既未激活企业微信又未关注微工作台（原企业号）',
  `AVATAR` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '头像url。注：如果要获取小图将url最后的”/0”改成”/100”即可，仅通讯录管理应用可获取',
  `ENGLISH_NAME` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '英文名',
  `ISLEADER` int NULL DEFAULT NULL COMMENT '上级字段，标识是否为上级。0表示普通成员，1表示上级。仅通讯录管理应用可获取',
  `TELEPHONE` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '座机，仅通讯录管理应用可获取',
  `EXT_ATTR` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '扩展属性，仅通讯录管理应用可获取',
  `ORDER_` int NULL DEFAULT NULL COMMENT '部门内的排序值，默认为0。',
  `BIZ_MAIL` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '企业邮箱，代开发自建应用不返回；第三方仅通讯录应用可获取；对于非第三方创建的成员，第三方通讯录应用也不可获取；上游企业不可获取下游企业成员该字段',
  `IS_LEADER_IN_DEPT` int NULL DEFAULT NULL COMMENT '表示在所在的部门内是否为部门负责人，数量与department一致；第三方通讯录应用或者授权了“组织架构信息-应用可获取企业的部门组织架构信息-部门负责人”权限的第三方应用可获取；对于非第三方创建的成员，第三方通讯录应用不可获取；上游企业不可获取下游企业成员该字段',
  `DIRECT_LEADER` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '直属上级UserID，',
  `THUMB_AVATAR` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '头像缩略图url。',
  `ALIAS` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '别名；',
  `QR_CODE` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '员工个人二维码',
  `EXTERNAL_PROFILE` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '成员对外属性',
  `EXTERNAL_POSITION` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '对外职务',
  `ADDRESS` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '地址。',
  `OPEN_USERID` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '全局唯一。对于同一个服务商，不同应用获取到企业内同一个成员的open_userid是相同的，最多64个字节。仅第三方应用可获取',
  `MAIN_DEPARTMENT` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '主部门，仅当应用对主部门有查看权限时返回。',
  PRIMARY KEY (`PID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '企业微信通信录' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for qywx_external_contact
-- ----------------------------
DROP TABLE IF EXISTS `qywx_external_contact`;
CREATE TABLE `qywx_external_contact`  (
  `PID` bigint NOT NULL COMMENT '物理主键',
  `TENANT_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '租户号',
  `REVISION` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'REVISION',
  `CREATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'CREATED_BY',
  `CREATED_TIME` datetime NULL DEFAULT NULL COMMENT 'CREATED_TIME',
  `UPDATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'UPDATED_BY',
  `UPDATED_TIME` datetime NULL DEFAULT NULL COMMENT 'UPDATED_TIME',
  `SUITE_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '第三方应用的SuiteId',
  `AUTH_CORPID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '授权方的corpid',
  `EXTERNAL_USERID` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外部联系人的userid',
  `NAME` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外部联系人的名称',
  `AVATAR` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '外部联系人头像',
  `TYPE_` int NULL DEFAULT NULL COMMENT '外部联系人的类型，1表示该外部联系人是微信用户，2表示该外部联系人是企业微信用户',
  `GENDER` int NULL DEFAULT NULL COMMENT '外部联系人性别 0-未知 1-男性 2-女性。第三方不可获取，上游企业不可获取下游企业客户该字段，返回值为0，表示未定义',
  `MINI_APPID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '小程序appid',
  `MINI_OPENID` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '小程序上的openid',
  `APPID` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '公众号appid',
  `OPENID` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '公众号的appid',
  `POSITION` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外部联系人的职位，如果外部企业或用户选择隐藏职位，则不返回，仅当联系人类型是企业微信用户时有此字段',
  `CORP_NAME` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外部联系人所在企业的简称，仅当联系人类型是企业微信用户时有此字段',
  `CORP_FULL_NAME` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外部联系人所在企业的主体名称，仅当联系人类型是企业微信用户时有此字段。仅企业自建应用可获取；第三方应用、代开发应用、上下游应用不可获取，返回内容为企业名称，即corp_name。',
  PRIMARY KEY (`PID`) USING BTREE,
  INDEX `IDX_ON_AUTH_CORPID`(`AUTH_CORPID` ASC) USING BTREE,
  INDEX `IDX_ON_MINI_OPENID`(`MINI_OPENID` ASC) USING BTREE,
  INDEX `IDX_ON_OPENID`(`OPENID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '企业微信外部联系人(客户)' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for returnbill
-- ----------------------------
DROP TABLE IF EXISTS `returnbill`;
CREATE TABLE `returnbill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `FuKuanQingKuangName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ZhiFuJinE` decimal(19, 10) NULL DEFAULT NULL,
  `HuiLv` decimal(19, 10) NULL DEFAULT NULL,
  `HSJinE` decimal(19, 10) NULL DEFAULT NULL,
  `Exchangable` tinyint NULL DEFAULT NULL,
  `Type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ZhaoHuiJinE` decimal(19, 10) NULL DEFAULT NULL,
  `ShiShouJinE` decimal(19, 10) NULL DEFAULT NULL,
  `GuaZhangID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `GuaZhangName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `HuiKuanRen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ShouYinYuan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ReturnTime` datetime NULL DEFAULT NULL,
  `JiaoBanHao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `StationID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `StationName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ShopName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ReturnBillID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `YingYeRiQi` datetime NULL DEFAULT NULL,
  `YEAR` int NULL DEFAULT NULL,
  `MONTH` int NULL DEFAULT NULL,
  `DAY` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_ReturnBill_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`company_id` ASC, `YingYeRiQi` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 87200 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for returnbillfukuan
-- ----------------------------
DROP TABLE IF EXISTS `returnbillfukuan`;
CREATE TABLE `returnbillfukuan`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `ReturnBillID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `FuKuanQingKuangID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `FuKuanQingKuangName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ZhiFuJinE` decimal(19, 10) NULL DEFAULT NULL,
  `HuiLv` decimal(19, 10) NULL DEFAULT NULL,
  `HSJinE` decimal(19, 10) NULL DEFAULT NULL,
  `Exchangable` tinyint NULL DEFAULT NULL,
  `Type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ZhaoHuiJinE` decimal(19, 10) NULL DEFAULT NULL,
  `ShiShouJinE` decimal(19, 10) NULL DEFAULT NULL,
  `HuiYuanKaID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `HuiYuanName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ShouYinYuan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ShopName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `YingYeRiQi` datetime NULL DEFAULT NULL,
  `YEAR` int NULL DEFAULT NULL,
  `MONTH` int NULL DEFAULT NULL,
  `DAY` int NULL DEFAULT NULL,
  `GivingAmount` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_ReturnBillFuKuan_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`company_id` ASC, `YingYeRiQi` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 94490 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for returnbillxiaofei
-- ----------------------------
DROP TABLE IF EXISTS `returnbillxiaofei`;
CREATE TABLE `returnbillxiaofei`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `ReturnBillID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `XiaoFeiDanID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `HuiKuanJinE` decimal(19, 10) NULL DEFAULT NULL,
  `ShopName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `YingYeRiQi` datetime NULL DEFAULT NULL,
  `YEAR` int NULL DEFAULT NULL,
  `MONTH` int NULL DEFAULT NULL,
  `DAY` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_ReturnBillXiaoFei_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_report_date`(`company_id` ASC, `YingYeRiQi` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 200688 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_advertising_scheme
-- ----------------------------
DROP TABLE IF EXISTS `sc_advertising_scheme`;
CREATE TABLE `sc_advertising_scheme`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `begin_date_time` datetime NULL DEFAULT NULL,
  `end_date_time` datetime NULL DEFAULT NULL,
  `priority` int NULL DEFAULT NULL,
  `maker` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `make_time` datetime NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `carousel_time` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `For_all` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_advertising_scheme_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_advertising_scheme_and_shop
-- ----------------------------
DROP TABLE IF EXISTS `sc_advertising_scheme_and_shop`;
CREATE TABLE `sc_advertising_scheme_and_shop`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `scheme` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `scheme_code` bigint NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_advertising_scheme_and_shop_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_advertising_scheme_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_advertising_scheme_item`;
CREATE TABLE `sc_advertising_scheme_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `scheme` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jump_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Scheme_code` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Jump_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Position` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_advertising_scheme_item_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 69 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_appid_to_secret
-- ----------------------------
DROP TABLE IF EXISTS `sc_appid_to_secret`;
CREATE TABLE `sc_appid_to_secret`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_appid_to_secret_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 30 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_bar_scale
-- ----------------------------
DROP TABLE IF EXISTS `sc_bar_scale`;
CREATE TABLE `sc_bar_scale`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `port` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_bar_scale_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_bar_scale_and_dish
-- ----------------------------
DROP TABLE IF EXISTS `sc_bar_scale_and_dish`;
CREATE TABLE `sc_bar_scale_and_dish`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `bar_scale` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bar_scale_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_bar_scale_and_dish_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_bill_in_mall
-- ----------------------------
DROP TABLE IF EXISTS `sc_bill_in_mall`;
CREATE TABLE `sc_bill_in_mall`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `fans` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `addr_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `detail_addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_person` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `make_time` datetime NULL DEFAULT NULL,
  `send_time` datetime NULL DEFAULT NULL,
  `packaging_fee` decimal(19, 10) NULL DEFAULT NULL,
  `amount_before_discount` decimal(19, 10) NULL DEFAULT NULL,
  `amount_received` decimal(19, 10) NULL DEFAULT NULL,
  `delivery_fee` decimal(19, 10) NULL DEFAULT NULL,
  `comments` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `delivery_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `free_delivery_fee` tinyint NULL DEFAULT NULL,
  `courier_company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bill_in_courier_company` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bill_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Fans_unionid` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Delivery_time` datetime NULL DEFAULT NULL,
  `Marketing` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Marketing_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_bill_in_mall_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_bill_in_mall_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_book_hours
-- ----------------------------
DROP TABLE IF EXISTS `sc_book_hours`;
CREATE TABLE `sc_book_hours`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `begin_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_book_hours_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_brand
-- ----------------------------
DROP TABLE IF EXISTS `sc_brand`;
CREATE TABLE `sc_brand`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `business_model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `logo` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT 'logo',
  `disable` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `pos_bg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '收银系统背景图片',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_brand_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 115 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_buffet
-- ----------------------------
DROP TABLE IF EXISTS `sc_buffet`;
CREATE TABLE `sc_buffet`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `Price` decimal(19, 9) NULL DEFAULT NULL COMMENT '价格',
  `MaxPrice` decimal(19, 9) NULL DEFAULT NULL COMMENT '价格上限',
  `CanYiDaZhe` tinyint NULL DEFAULT NULL COMMENT '参与打折',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_buffet_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1930 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_business_hours
-- ----------------------------
DROP TABLE IF EXISTS `sc_business_hours`;
CREATE TABLE `sc_business_hours`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `begin_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Disable_wct` tinyint NULL DEFAULT NULL,
  `book_period` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '预订时段',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_business_hours_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 290 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_cash_box
-- ----------------------------
DROP TABLE IF EXISTS `sc_cash_box`;
CREATE TABLE `sc_cash_box`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `pos_dev` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pos_dev_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `command` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `port` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_cash_box_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_cause_of_damage
-- ----------------------------
DROP TABLE IF EXISTS `sc_cause_of_damage`;
CREATE TABLE `sc_cause_of_damage`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_cause_of_damage_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_client
-- ----------------------------
DROP TABLE IF EXISTS `sc_client`;
CREATE TABLE `sc_client`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `client_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `client_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `principal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `enable_on_line_mall` tinyint NULL DEFAULT NULL,
  `qualification_photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `quarantine_report_photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tax_rate` decimal(19, 10) NULL DEFAULT NULL,
  `tax_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bank` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_of_bank` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `billing_period_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `expiry_day_of_qualification` datetime NULL DEFAULT NULL,
  `commit_audit_time` datetime NULL DEFAULT NULL,
  `audit_time` datetime NULL DEFAULT NULL,
  `reviewer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `audit_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_client_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_client_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_client_type`;
CREATE TABLE `sc_client_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_client_type_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_company_dishs
-- ----------------------------
DROP TABLE IF EXISTS `sc_company_dishs`;
CREATE TABLE `sc_company_dishs`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `brand_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `modified_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `modified_time` datetime NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `releaseed` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Enable_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_company_dishs_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_company_dishs_publish_job
-- ----------------------------
DROP TABLE IF EXISTS `sc_company_dishs_publish_job`;
CREATE TABLE `sc_company_dishs_publish_job`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `company_dishs_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `company_dishs_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `publish_opr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `publish_time` datetime NULL DEFAULT NULL,
  `enable_time` datetime NULL DEFAULT NULL,
  `publish_status` int NULL DEFAULT NULL,
  `release_rule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cancel_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Cancel_people` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Cancel_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_company_dishs_publish_job_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_company_pay_way
-- ----------------------------
DROP TABLE IF EXISTS `sc_company_pay_way`;
CREATE TABLE `sc_company_pay_way`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `brand_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `modified_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `modified_time` datetime NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_company_pay_way_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_company_pay_way_publish_job
-- ----------------------------
DROP TABLE IF EXISTS `sc_company_pay_way_publish_job`;
CREATE TABLE `sc_company_pay_way_publish_job`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `publish_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `publish_context` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `company_pay_way` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `company_pay_way_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `company_pay_way_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `publish_version` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `publish_opr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `publish_time` datetime NULL DEFAULT NULL,
  `last_update_time` datetime NULL DEFAULT NULL,
  `publish_status` int NULL DEFAULT NULL,
  `release_rule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_company_pay_way_publish_job_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_config_of_shop
-- ----------------------------
DROP TABLE IF EXISTS `sc_config_of_shop`;
CREATE TABLE `sc_config_of_shop`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `str_val` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '字符串值',
  `int_val` int NULL DEFAULT NULL,
  `boolean_val` tinyint NULL DEFAULT NULL,
  `double_val` decimal(19, 10) NULL DEFAULT NULL,
  `date_val` datetime NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_config_of_shop_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_sid_name`(`company_id` ASC, `shop_id` ASC, `name`(191) ASC) USING BTREE,
  INDEX `idx_mid_name`(`company_id` ASC, `shop_id` ASC, `name`(191) ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5380 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_consumption_coupon_limit
-- ----------------------------
DROP TABLE IF EXISTS `sc_consumption_coupon_limit`;
CREATE TABLE `sc_consumption_coupon_limit`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间段',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间段',
  `week_type` int NULL DEFAULT NULL COMMENT '周类型',
  `rule_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '活动名称',
  `rule_code` bigint NOT NULL COMMENT '活动规则',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_consumption_coupon_limit_COMPANY_LmnID`(`company_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sc_consumption_limit_COMPANY_rule_code`(`company_id` ASC, `rule_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 107 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '赠劵活动限制设置' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_consumption_coupon_record
-- ----------------------------
DROP TABLE IF EXISTS `sc_consumption_coupon_record`;
CREATE TABLE `sc_consumption_coupon_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `order_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_amount` decimal(19, 10) NULL DEFAULT NULL,
  `full_amount` decimal(19, 10) NULL DEFAULT NULL,
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_head_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `gift_rule_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `gift_rule_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `gift_quantity` int NULL DEFAULT NULL,
  `coupon_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `YingYeRiQi` datetime NULL DEFAULT NULL,
  `YEAR` int NULL DEFAULT NULL,
  `MONTH` int NULL DEFAULT NULL,
  `DAY` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_consumption_coupon_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 228 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_consumption_coupon_rule
-- ----------------------------
DROP TABLE IF EXISTS `sc_consumption_coupon_rule`;
CREATE TABLE `sc_consumption_coupon_rule`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `gift_quantity` int NULL DEFAULT NULL,
  `full_amount` decimal(19, 10) NULL DEFAULT NULL,
  `term_of_validity_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `effective_days` int NULL DEFAULT NULL,
  `effective_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `effective_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `rule_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_level_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `start_effective_time` datetime NULL DEFAULT NULL,
  `end_effective_time` datetime NULL DEFAULT NULL,
  `gift_max_quantity` int NOT NULL COMMENT '单次最多赠券数量',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_consumption_coupon_rule_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_coupon
-- ----------------------------
DROP TABLE IF EXISTS `sc_coupon`;
CREATE TABLE `sc_coupon`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `start_date` datetime NULL DEFAULT NULL,
  `end_date` datetime NULL DEFAULT NULL,
  `deductible_amount` decimal(19, 10) NULL DEFAULT NULL,
  `type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `total_number` int NULL DEFAULT NULL,
  `used_number` int NULL DEFAULT NULL,
  `write_off_number` int NULL DEFAULT NULL,
  `deadline` int NULL DEFAULT NULL,
  `limited_purchase_per_person_per_day` int NULL DEFAULT NULL,
  `limited_purchase_per_person_all` int NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `Use_explain` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Use_limit` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `limit_use_day` int NULL DEFAULT NULL,
  `limit_use_num` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_coupon_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_coupon_map
-- ----------------------------
DROP TABLE IF EXISTS `sc_coupon_map`;
CREATE TABLE `sc_coupon_map`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `main_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `deputy_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `main` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `deputy` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `number` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_coupon_map_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_coupon_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_coupon_order`;
CREATE TABLE `sc_coupon_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `pkg_coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pkg_coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `deadline` datetime NULL DEFAULT NULL,
  `get_date` datetime NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `avatarurl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `write_off_staff` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `write_off_time` datetime NULL DEFAULT NULL,
  `coupon_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_coupon_order_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_coupon_proportion_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_coupon_proportion_item`;
CREATE TABLE `sc_coupon_proportion_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `min_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '最低消费金额',
  `max_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '最高消费金额',
  `proportion_min` decimal(19, 10) NULL DEFAULT NULL COMMENT '最低赠送比例',
  `proportion_max` decimal(19, 10) NULL DEFAULT NULL COMMENT '最高赠送比例',
  `coupon_code` bigint NOT NULL COMMENT '优惠券/红包编号',
  `coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '优惠券/红包名称',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_coupon_proportion_item_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sc_coupon_proportion_item_COMPANY_SHOP_coupon_coe`(`company_id` ASC, `shop_id` ASC, `coupon_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 55 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '红包/劵按单金额比例范围' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_customer_display
-- ----------------------------
DROP TABLE IF EXISTS `sc_customer_display`;
CREATE TABLE `sc_customer_display`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `pos_dev` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pos_dev_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `port` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Baud_rate` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_customer_display_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_daily_goods_in_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `sc_daily_goods_in_warehouse`;
CREATE TABLE `sc_daily_goods_in_warehouse`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_code` bigint NULL DEFAULT NULL,
  `super_dish_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `super_dish_type_code` bigint NULL DEFAULT NULL,
  `dish_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_type_code` bigint NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop_id` bigint NULL DEFAULT NULL,
  `warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `warehouse_code` bigint NULL DEFAULT NULL,
  `price` decimal(19, 10) NULL DEFAULT NULL,
  `volume` decimal(19, 10) NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_daily_goods_in_warehouse_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_daily_goods_in_warehouse_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_delivery_center
-- ----------------------------
DROP TABLE IF EXISTS `sc_delivery_center`;
CREATE TABLE `sc_delivery_center`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_delivery_center_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_department
-- ----------------------------
DROP TABLE IF EXISTS `sc_department`;
CREATE TABLE `sc_department`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `brand_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `produce` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `produce_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_department_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 60 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_department_kpi_day
-- ----------------------------
DROP TABLE IF EXISTS `sc_department_kpi_day`;
CREATE TABLE `sc_department_kpi_day`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `merchant_code` bigint NULL DEFAULT NULL,
  `merchant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `store_code` bigint NULL DEFAULT NULL,
  `store_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `department_code` bigint NULL DEFAULT NULL,
  `department_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `target_amount` decimal(19, 10) NULL DEFAULT NULL,
  `completed_amount` decimal(19, 10) NULL DEFAULT NULL,
  `completion_rate` decimal(19, 10) NULL DEFAULT NULL,
  `department_cost` decimal(19, 10) NULL DEFAULT NULL,
  `gross_profit_rate` decimal(19, 10) NULL DEFAULT NULL,
  `gross_profit_amount` decimal(19, 10) NULL DEFAULT NULL,
  `up_to_standard` tinyint NULL DEFAULT NULL,
  `material_cost` decimal(19, 10) NULL DEFAULT NULL,
  `labor_cost` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_department_kpi_day_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_department_kpi_day_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish`;
CREATE TABLE `sc_dish`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `brand_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `dish_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_type_code` bigint NULL DEFAULT NULL COMMENT '分类lid',
  `alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `hot_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `mode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `department_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `show_in_pad` tinyint NULL DEFAULT NULL,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `image_2d` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `image_3d` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `income` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `income_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `signboard` tinyint NULL DEFAULT NULL,
  `newed` tinyint NULL DEFAULT NULL,
  `recommend` tinyint NULL DEFAULT NULL,
  `can_be_decimal` decimal(19, 10) NULL DEFAULT NULL,
  `support_mode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `min_amount_for_sale` decimal(19, 10) NULL DEFAULT NULL,
  `packing_fee` decimal(19, 10) NULL DEFAULT NULL,
  `need_confirm_amount` tinyint NULL DEFAULT NULL,
  `auto_order` tinyint NULL DEFAULT NULL,
  `can_sale_alone` tinyint NULL DEFAULT NULL,
  `tax_rate` decimal(19, 10) NULL DEFAULT NULL,
  `sales_commission` decimal(19, 10) NULL DEFAULT NULL,
  `order_tips` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `markdown_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '简介',
  `item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `abbreviation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `can_modify_price` tinyint NULL DEFAULT NULL,
  `can_discount` tinyint NULL DEFAULT NULL,
  `can_give` tinyint NULL DEFAULT NULL,
  `stock` decimal(19, 10) NULL DEFAULT NULL,
  `can_manage_lib` tinyint NULL DEFAULT NULL,
  `origin_place` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `can_promotion` tinyint NULL DEFAULT NULL,
  `joint_franchise_rate` decimal(19, 10) NULL DEFAULT NULL,
  `term_of_validity` int NULL DEFAULT NULL,
  `valuation_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `warning_days` int NULL DEFAULT NULL,
  `can_integrate` tinyint NULL DEFAULT NULL,
  `integral` int NULL DEFAULT NULL,
  `rate_of_margin` decimal(19, 10) NULL DEFAULT NULL,
  `royalty_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `royalty_count` decimal(19, 10) NULL DEFAULT NULL,
  `dish_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_nissin` tinyint NULL DEFAULT NULL,
  `is_fresh` tinyint NULL DEFAULT NULL,
  `is_manage_number` tinyint NULL DEFAULT NULL,
  `input_tax` decimal(19, 10) NULL DEFAULT NULL,
  `inventory_ceiling` decimal(19, 10) NULL DEFAULT NULL,
  `inventory_lower` decimal(19, 10) NULL DEFAULT NULL,
  `produce_date` datetime NULL DEFAULT NULL,
  `output_tax` decimal(19, 10) NULL DEFAULT NULL,
  `set_more_code1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `set_more_code2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `set_more_code3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `set_more_code4` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `set_more_code5` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `price` decimal(19, 10) NULL DEFAULT NULL,
  `Factory_brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Factory_brand_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Auxiliary_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Unit_conversion` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Standard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Hide_in_dine` tinyint NULL DEFAULT NULL,
  `Hide_in_takeaway` tinyint NULL DEFAULT NULL,
  `Image_second` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Image_third` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Image_fourth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Image_fifth` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Dish_video` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `No_sync_to_store` tinyint NULL DEFAULT NULL,
  `Detail_image` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Shipping_addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Shipping_addr_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Security_services` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Showorder` int NULL DEFAULT NULL,
  `Limit_number` decimal(19, 10) NULL DEFAULT NULL,
  `Min_practice` int NULL DEFAULT NULL,
  `Max_practice` int NULL DEFAULT NULL,
  `Must_order_food` tinyint NULL DEFAULT NULL,
  `Must_Num_With_Same_People` tinyint NULL DEFAULT NULL,
  `Recommend_food` tinyint NULL DEFAULT NULL,
  `Not_inherit_subclass` tinyint NULL DEFAULT NULL,
  `Not_inherit_supperclass` tinyint NULL DEFAULT NULL,
  `Not_multiple_choice` tinyint NULL DEFAULT NULL,
  `Not_inherit_common` tinyint NULL DEFAULT NULL,
  `Not_show_practice` tinyint NULL DEFAULT NULL,
  `Need_split_order` tinyint NULL DEFAULT NULL,
  `Can_mod_name` tinyint NULL DEFAULT NULL,
  `only_show` tinyint NULL DEFAULT NULL,
  `qr_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '点餐码',
  `by_quantity_order` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '按数量出单',
  `time_price` tinyint NULL DEFAULT NULL COMMENT '时价菜',
  `order_in_mall` tinyint NULL DEFAULT NULL COMMENT '微餐厅排序值',
  `online_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '线上分类名称',
  `online_type_code` bigint NULL DEFAULT NULL COMMENT '线上分类编号',
  `recommend_order_idx` int NULL DEFAULT NULL COMMENT '推荐菜品顺序',
  `share_commission` decimal(24, 6) NULL DEFAULT NULL,
  `had_cook` tinyint(1) NULL DEFAULT NULL,
  `non_saleable_time` tinyint(1) NULL DEFAULT NULL,
  `enable_give_balance` tinyint(1) NULL DEFAULT NULL,
  `sale_commission` decimal(24, 6) NULL DEFAULT NULL COMMENT '销售提成',
  `assist_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '辅助编码',
  `hide_in_pickup` tinyint(1) NOT NULL DEFAULT 0 COMMENT '在自提中隐藏',
  `enable` tinyint(1) NOT NULL DEFAULT 1 COMMENT '禁用/启用',
  `shelve` tinyint(1) NOT NULL DEFAULT 1 COMMENT '上下架',
  `bar_code` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '条码',
  `small_pictures` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '小图片列表',
  `big_pictures` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '大图片列表',
  `kilo_rate` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '千克比率',
  `dept_commission` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '部门提成',
  `market_commission` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '营销提成',
  `market_percentage` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '营销提成百分比',
  `draw_commission` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '现抽',
  `sales_percentage` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '销售提成百分比',
  `side_up_rate` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '配菜上限百分比',
  `side_down_rate` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '配菜下限百分比',
  `gift_minute` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '赠送计时（分）',
  `lowest` tinyint(1) NOT NULL DEFAULT 0 COMMENT '参与最低消费',
  `no_billing` tinyint(1) NOT NULL DEFAULT 0 COMMENT '单位不参与计费',
  `discount_all` tinyint(1) NOT NULL DEFAULT 1 COMMENT '参与所有折扣方式',
  `deposited` tinyint(1) NOT NULL DEFAULT 0 COMMENT '作为押金退款',
  `performed` tinyint(1) NOT NULL DEFAULT 1 COMMENT '计算业绩',
  `settle_coupon` tinyint(1) NOT NULL DEFAULT 0 COMMENT '使用优惠券结算',
  `ext_names` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '美团、饿了么、抖音名称',
  `specials` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '第X杯特价',
  `side` tinyint(1) NOT NULL DEFAULT 0 COMMENT '可作为配菜',
  `auto_out` tinyint(1) NOT NULL DEFAULT 0 COMMENT '自动出库',
  `primary_` tinyint(1) NOT NULL DEFAULT 0 COMMENT '任点主菜',
  `by_other_sure` tinyint(1) NOT NULL DEFAULT 0 COMMENT '数量由其他确定',
  `prohibit_qty` tinyint(1) NOT NULL DEFAULT 0 COMMENT '禁止修改数量',
  `sold_stock` tinyint(1) NOT NULL DEFAULT 0 COMMENT '作为库存沽清',
  `relate_people` tinyint(1) NOT NULL DEFAULT 0 COMMENT '跟人数有关',
  `order_merge` tinyint(1) NOT NULL DEFAULT 0 COMMENT '点单时合并',
  `expiry_day` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '保质期（天）',
  `delay_minute` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '延迟打印分钟数',
  `order_limit_number` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '单内限点',
  `warn_number` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '预警数量',
  `spec` tinyint(1) NOT NULL DEFAULT 0 COMMENT '特价商品',
  `crown` tinyint(1) NOT NULL DEFAULT 0 COMMENT '销冠',
  `hide_in_electric` tinyint(1) NOT NULL DEFAULT 0 COMMENT '在电子菜谱隐藏',
  `hide_in_waiter` tinyint(1) NOT NULL DEFAULT 0 COMMENT '在服务员小程序隐藏',
  `read_electric` tinyint(1) NOT NULL DEFAULT 0 COMMENT '从电子秤中读取',
  `pop_side` tinyint(1) NOT NULL DEFAULT 0 COMMENT '点菜时自动弹出配菜',
  `pop_unit` tinyint(1) NOT NULL DEFAULT 0 COMMENT '点菜弹出多单位选择框',
  `take_service_fee` tinyint(1) NOT NULL DEFAULT 0 COMMENT '需要收取服务费',
  `pop_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT '点菜弹出数量确认框',
  `pop_cook` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT '点菜时默认显示本类做法',
  `pinyin` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '拼音',
  `markdown_detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '菜品简介(富文本)',
  `min_cook_number` int NULL DEFAULT NULL COMMENT '必须做法数量',
  `max_cook_number` int NULL DEFAULT NULL COMMENT '最多可选做法数量',
  `upload` tinyint NULL DEFAULT NULL COMMENT '是否上传',
  `floor_split_order` tinyint NULL DEFAULT NULL COMMENT '楼面也出分单',
  `hide_in_self_order` tinyint NULL DEFAULT 0 COMMENT '在自助点餐中隐藏',
  `fixed_cook` tinyint NULL DEFAULT NULL COMMENT '做法不随菜谱变更',
  `dish_label` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '菜品标签',
  `approval_lids` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '当前审批的lids',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_lid`(`company_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 39538339 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_and_printer
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_and_printer`;
CREATE TABLE `sc_dish_and_printer`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `printer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `superior` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `reserve` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `reserve_str` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Printer_code` bigint NULL DEFAULT NULL,
  `Superior_code` bigint NULL DEFAULT NULL,
  `Dish_type_code` bigint NULL DEFAULT NULL,
  `Dish_code` bigint NULL DEFAULT NULL,
  `Pos` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Pos_code` bigint NULL DEFAULT NULL,
  `Purpose` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_and_printer_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_and_supplier
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_and_supplier`;
CREATE TABLE `sc_dish_and_supplier`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_code` bigint NULL DEFAULT NULL,
  `supplier` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `supplier_code` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_and_supplier_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_backup
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_backup`;
CREATE TABLE `sc_dish_backup`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `store` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `store_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `backup_time` datetime NULL DEFAULT NULL,
  `restore_type` int NULL DEFAULT NULL,
  `restore_time` datetime NULL DEFAULT NULL,
  `restore_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_backup_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_bom
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_bom`;
CREATE TABLE `sc_dish_bom`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `batch_output` decimal(19, 10) NULL DEFAULT NULL,
  `batch_cost` decimal(19, 10) NULL DEFAULT NULL,
  `single_cost` decimal(19, 10) NULL DEFAULT NULL,
  `single_price` decimal(19, 10) NULL DEFAULT NULL,
  `single_gross_profit` decimal(19, 10) NULL DEFAULT NULL,
  `Dish_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_bom_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_bom_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_bom_item`;
CREATE TABLE `sc_dish_bom_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `bom` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `batch_consumption` decimal(19, 10) NULL DEFAULT NULL,
  `single_consumption` decimal(19, 10) NULL DEFAULT NULL,
  `cost_price` decimal(19, 10) NULL DEFAULT NULL,
  `batch_price` decimal(19, 10) NULL DEFAULT NULL,
  `Bom_code` bigint NULL DEFAULT NULL,
  `Dish_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_bom_item_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_brand_in_marketing_plan
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_brand_in_marketing_plan`;
CREATE TABLE `sc_dish_brand_in_marketing_plan`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `brand_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plan_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `discount_rate` decimal(19, 10) NULL DEFAULT NULL,
  `Full_money` decimal(19, 10) NULL DEFAULT NULL,
  `Give_money` decimal(19, 10) NULL DEFAULT NULL,
  `Minus_money` decimal(19, 10) NULL DEFAULT NULL,
  `Increase_money` decimal(19, 10) NULL DEFAULT NULL,
  `Give_dish` decimal(19, 10) NULL DEFAULT NULL,
  `Give_gift_dish` decimal(19, 10) NULL DEFAULT NULL,
  `Give_gift_Coupon` decimal(19, 10) NULL DEFAULT NULL,
  `Give_gift_piece` decimal(19, 10) NULL DEFAULT NULL,
  `Discount_quantity` decimal(19, 10) NULL DEFAULT NULL,
  `Full_piece` int NULL DEFAULT NULL,
  `Buy_price` decimal(19, 10) NULL DEFAULT NULL,
  `Buy_imit` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_brand_in_marketing_plan_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_buffet
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_buffet`;
CREATE TABLE `sc_dish_buffet`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `Buffet` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '自助餐',
  `buffet_code` bigint NULL DEFAULT NULL COMMENT '自助餐lid',
  `Dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜品',
  `dish_code` bigint NULL DEFAULT NULL COMMENT '菜品lid',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_buffet_COMPANY_SHOP_bffet_dish`(`company_id` ASC, `shop_id` ASC, `buffet_code` ASC, `dish_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 221424 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_for_type_in_mall
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_for_type_in_mall`;
CREATE TABLE `sc_dish_for_type_in_mall`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Type_code` bigint NULL DEFAULT NULL,
  `Dish_code` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_for_type_in_mall_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_group_buy
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_group_buy`;
CREATE TABLE `sc_dish_group_buy`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `maker` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `make_time` datetime NULL DEFAULT NULL,
  `summary` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_review` tinyint NULL DEFAULT NULL,
  `reviewer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `review_time` datetime NULL DEFAULT NULL,
  `begin_date` datetime NULL DEFAULT NULL,
  `end_date` datetime NULL DEFAULT NULL,
  `begin_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `is_terminator` tinyint NULL DEFAULT NULL,
  `terminator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `terminat_time` datetime NULL DEFAULT NULL,
  `pay_way` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pay_way_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shipping_method` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_freight` tinyint NULL DEFAULT NULL,
  `is_coupon` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Group_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_group_buy_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_in_marketing_plan
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_in_marketing_plan`;
CREATE TABLE `sc_dish_in_marketing_plan`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plan_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `discount_rate` decimal(19, 10) NULL DEFAULT NULL,
  `Full_money` decimal(19, 10) NULL DEFAULT NULL,
  `Minus_money` decimal(19, 10) NULL DEFAULT NULL,
  `Give_money` decimal(19, 10) NULL DEFAULT NULL,
  `Increase_money` decimal(19, 10) NULL DEFAULT NULL,
  `Give_dish` decimal(19, 10) NULL DEFAULT NULL,
  `Give_gift_dish` decimal(19, 10) NULL DEFAULT NULL,
  `Give_gift_Coupon` decimal(19, 10) NULL DEFAULT NULL,
  `Give_gift_piece` decimal(19, 10) NULL DEFAULT NULL,
  `Discount_quantity` decimal(19, 10) NULL DEFAULT NULL,
  `Full_piece` int NULL DEFAULT NULL,
  `Special_price` decimal(19, 10) NULL DEFAULT NULL,
  `Buy_imit` int NULL DEFAULT NULL,
  `Buy_price` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Unit_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Sale_price` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_in_marketing_plan_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_in_time_limit_promotion
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_in_time_limit_promotion`;
CREATE TABLE `sc_dish_in_time_limit_promotion`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plan_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `group_price` decimal(19, 10) NULL DEFAULT NULL,
  `group_inventory` decimal(19, 10) NULL DEFAULT NULL,
  `restricted_quantity` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_in_time_limit_promotion_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_limit_stock
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_limit_stock`;
CREATE TABLE `sc_dish_limit_stock`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `stock` decimal(19, 10) NULL DEFAULT NULL,
  `Dish_code` bigint NULL DEFAULT NULL,
  `Plan_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_limit_stock_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_limit_stock_plan
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_limit_stock_plan`;
CREATE TABLE `sc_dish_limit_stock_plan`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `for_all` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_limit_stock_plan_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_map
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_map`;
CREATE TABLE `sc_dish_map`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `main_dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `main_dish_code` bigint NULL DEFAULT NULL COMMENT '主菜lid',
  `sub_dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sub_dish_code` bigint NULL DEFAULT NULL COMMENT '子菜lid',
  `sub_dish_number` decimal(19, 10) NULL DEFAULT NULL,
  `sub_dish_scate` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Unit_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Amount` int NULL DEFAULT NULL,
  `Max_amount` int NULL DEFAULT NULL,
  `Price` decimal(19, 10) NULL DEFAULT NULL,
  `Map_type` int NULL DEFAULT NULL,
  `Main_type` int NULL DEFAULT NULL,
  `idx` int NULL DEFAULT NULL COMMENT '排序值',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_map_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_sid_main_dish_code`(`company_id` ASC, `shop_id` ASC, `main_dish_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6256056 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_plan_and_shop_in_mall
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_plan_and_shop_in_mall`;
CREATE TABLE `sc_dish_plan_and_shop_in_mall`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Plan_code` bigint NULL DEFAULT NULL,
  `Owner_shop_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_plan_and_shop_in_mall_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_plan_in_mall
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_plan_in_mall`;
CREATE TABLE `sc_dish_plan_in_mall`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `for_all` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_plan_in_mall_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_qc_in_marketing_plan
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_qc_in_marketing_plan`;
CREATE TABLE `sc_dish_qc_in_marketing_plan`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plan_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `full_money` decimal(19, 10) NULL DEFAULT NULL,
  `minus_money` decimal(19, 10) NULL DEFAULT NULL,
  `give_money` decimal(19, 10) NULL DEFAULT NULL,
  `increase_money` decimal(19, 10) NULL DEFAULT NULL,
  `give_dish` decimal(19, 10) NULL DEFAULT NULL,
  `give_gift_dish` decimal(19, 10) NULL DEFAULT NULL,
  `give_gift_coupon` decimal(19, 10) NULL DEFAULT NULL,
  `give_gift_piece` decimal(19, 10) NULL DEFAULT NULL,
  `discount_quantity` decimal(19, 10) NULL DEFAULT NULL,
  `full_piece` int NULL DEFAULT NULL,
  `buy_price` decimal(19, 10) NULL DEFAULT NULL,
  `buy_imit` int NULL DEFAULT NULL,
  `discount_rate` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_qc_in_marketing_plan_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_stock_and_shop
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_stock_and_shop`;
CREATE TABLE `sc_dish_stock_and_shop`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Plan_code` bigint NULL DEFAULT NULL,
  `Owner_shop_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_stock_and_shop_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_type`;
CREATE TABLE `sc_dish_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `brand_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `department_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `income` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `income_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `superior` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `superior_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tax_rate` decimal(19, 10) NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `order_idx` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Not_inherit_supperclass` tinyint NULL DEFAULT NULL,
  `Not_multiple_choice` tinyint NULL DEFAULT NULL,
  `Not_inherit_common` tinyint NULL DEFAULT NULL,
  `Not_show_practice` tinyint NULL DEFAULT NULL,
  `Hide_in_mall` tinyint NULL DEFAULT NULL COMMENT '微餐厅隐藏',
  `order_in_mall` tinyint NULL DEFAULT NULL COMMENT '微餐厅排序值',
  `support_mode` int NULL DEFAULT NULL COMMENT '分类模式',
  `alias` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '别名',
  `upload` tinyint NULL DEFAULT NULL COMMENT '是否上传',
  `images` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '图片',
  `fixed_cook` tinyint NULL DEFAULT NULL COMMENT '做法不随菜谱变更',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_type_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3223711 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_type_and_shop_in_mall
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_type_and_shop_in_mall`;
CREATE TABLE `sc_dish_type_and_shop_in_mall`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Type_code` bigint NULL DEFAULT NULL,
  `Owner_shop_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_type_and_shop_in_mall_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_type_in_mall
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_type_in_mall`;
CREATE TABLE `sc_dish_type_in_mall`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `superior` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `superior_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `order_idx` int NULL DEFAULT NULL,
  `show_in_home` tinyint NULL DEFAULT NULL,
  `img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_type_in_mall_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_type_in_marketing_plan
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_type_in_marketing_plan`;
CREATE TABLE `sc_dish_type_in_marketing_plan`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `dish_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plan_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `discount_rate` decimal(19, 10) NULL DEFAULT NULL,
  `Full_money` decimal(19, 10) NULL DEFAULT NULL,
  `Minus_money` decimal(19, 10) NULL DEFAULT NULL,
  `Give_money` decimal(19, 10) NULL DEFAULT NULL,
  `Increase_money` decimal(19, 10) NULL DEFAULT NULL,
  `Give_dish` decimal(19, 10) NULL DEFAULT NULL,
  `Give_gift_dish` decimal(19, 10) NULL DEFAULT NULL,
  `Give_gift_Coupon` decimal(19, 10) NULL DEFAULT NULL,
  `Give_gift_piece` decimal(19, 10) NULL DEFAULT NULL,
  `Discount_quantity` decimal(19, 10) NULL DEFAULT NULL,
  `Full_piece` int NULL DEFAULT NULL,
  `Buy_price` decimal(19, 10) NULL DEFAULT NULL,
  `Buy_imit` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_type_in_marketing_plan_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_dish_unit
-- ----------------------------
DROP TABLE IF EXISTS `sc_dish_unit`;
CREATE TABLE `sc_dish_unit`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_code` bigint NOT NULL COMMENT '菜品lid',
  `common_price` decimal(19, 10) NULL DEFAULT NULL,
  `crm_price` decimal(19, 10) NULL DEFAULT NULL,
  `org_price` decimal(19, 10) NULL DEFAULT NULL,
  `estimate_cost` decimal(19, 10) NULL DEFAULT NULL,
  `take_away_price` decimal(19, 10) NULL DEFAULT NULL,
  `online_dine_price` decimal(19, 10) NULL DEFAULT NULL,
  `online_take_away_price` decimal(19, 10) NULL DEFAULT NULL,
  `online_mention_price` decimal(19, 10) NULL DEFAULT NULL,
  `special_price1` decimal(19, 10) NULL DEFAULT NULL,
  `special_price2` decimal(19, 10) NULL DEFAULT NULL,
  `special_price3` decimal(19, 10) NULL DEFAULT NULL,
  `special_price4` decimal(19, 10) NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cost` decimal(19, 10) NULL DEFAULT NULL,
  `lowest_price` decimal(19, 10) NULL DEFAULT NULL,
  `distribution_price` decimal(19, 10) NULL DEFAULT NULL,
  `crm_price1` decimal(19, 10) NULL DEFAULT NULL,
  `crm_price2` decimal(19, 10) NULL DEFAULT NULL,
  `crm_price3` decimal(19, 10) NULL DEFAULT NULL,
  `crm_price4` decimal(19, 10) NULL DEFAULT NULL,
  `crm_price5` decimal(19, 10) NULL DEFAULT NULL,
  `Rate_of_def` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Exchange_points` int NULL DEFAULT NULL,
  `kilo_rate` decimal(24, 6) NULL DEFAULT NULL COMMENT '千克比率',
  `no_billing` tinyint(1) NOT NULL DEFAULT 0 COMMENT '单位不参与计费',
  `can_integrate` tinyint(1) NOT NULL DEFAULT 0 COMMENT '参与积分',
  `market_commission` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '营销提成',
  `market_percentage` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '营销提成百分比',
  `dept_commission` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '部门提成',
  `sales_commission` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '销售提成',
  `sales_percentage` decimal(24, 6) NOT NULL DEFAULT 0.000000 COMMENT '销售提成百分比',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_dish_unit_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_sid_dish_lid`(`company_id` ASC, `shop_id` ASC, `dish_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 43257403 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_distribution_plan_in_mall
-- ----------------------------
DROP TABLE IF EXISTS `sc_distribution_plan_in_mall`;
CREATE TABLE `sc_distribution_plan_in_mall`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `begin_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `plan_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fixed_cost` decimal(19, 10) NULL DEFAULT NULL,
  `distance1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `amount1` decimal(19, 10) NULL DEFAULT NULL,
  `cost1` decimal(19, 10) NULL DEFAULT NULL,
  `distance2` decimal(19, 10) NULL DEFAULT NULL,
  `amount2` decimal(19, 10) NULL DEFAULT NULL,
  `cost2` decimal(19, 10) NULL DEFAULT NULL,
  `distance3` decimal(19, 10) NULL DEFAULT NULL,
  `amount3` decimal(19, 10) NULL DEFAULT NULL,
  `cost3` decimal(19, 10) NULL DEFAULT NULL,
  `distribution_mode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `default_mode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Is_all_store` tinyint NULL DEFAULT NULL,
  `Disable` tinyint NULL DEFAULT NULL,
  `Full_amount` decimal(19, 10) NULL DEFAULT NULL,
  `Max_distance_range` decimal(19, 10) NULL DEFAULT NULL,
  `Base_distance` decimal(19, 10) NULL DEFAULT NULL,
  `Base_cost` decimal(19, 10) NULL DEFAULT NULL,
  `Add_distance` decimal(19, 10) NULL DEFAULT NULL,
  `Add_cost` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_distribution_plan_in_mall_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_envelope_proportion
-- ----------------------------
DROP TABLE IF EXISTS `sc_envelope_proportion`;
CREATE TABLE `sc_envelope_proportion`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `min_range` decimal(19, 10) NULL DEFAULT NULL COMMENT '最小范围',
  `max_range` decimal(19, 10) NULL DEFAULT NULL COMMENT '最大范围',
  `proportion` int NULL DEFAULT NULL COMMENT '比例',
  `envelope_code` bigint NOT NULL COMMENT '红包编号',
  `envelope` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '红包名称',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_envelope_proportion_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sc_envelope_proportion_COMPANY_SHOP_coupon_coe`(`company_id` ASC, `shop_id` ASC, `envelope_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '红包面值比例' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_factory_brand
-- ----------------------------
DROP TABLE IF EXISTS `sc_factory_brand`;
CREATE TABLE `sc_factory_brand`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_factory_brand_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_fans_addr
-- ----------------------------
DROP TABLE IF EXISTS `sc_fans_addr`;
CREATE TABLE `sc_fans_addr`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `fans` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `longitude` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `latitude` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `landmark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `detail_addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_person` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `label` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `default_addr` tinyint NULL DEFAULT NULL,
  `Fans_unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Fans_member_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Fans_openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Province_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `City` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `City_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `District` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `District_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_fans_addr_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_fans_hot_search
-- ----------------------------
DROP TABLE IF EXISTS `sc_fans_hot_search`;
CREATE TABLE `sc_fans_hot_search`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Search_times` int NULL DEFAULT NULL,
  `Search_str` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_fans_hot_search_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_fans_search_history
-- ----------------------------
DROP TABLE IF EXISTS `sc_fans_search_history`;
CREATE TABLE `sc_fans_search_history`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_fans_search_history_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_goods
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods`;
CREATE TABLE `sc_goods`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `goods_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `hot_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `standard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `domestic` tinyint NULL DEFAULT NULL,
  `nation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nation_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `modified_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `modified_time` datetime NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `minimum_order` decimal(19, 10) NULL DEFAULT NULL,
  `minimum_order_once` decimal(19, 10) NULL DEFAULT NULL,
  `must_order` tinyint NULL DEFAULT NULL,
  `minimum_order_unit_multiples` decimal(19, 10) NULL DEFAULT NULL,
  `maxmun_safety` decimal(19, 10) NULL DEFAULT NULL,
  `minimun_safety` decimal(19, 10) NULL DEFAULT NULL,
  `reminder_days_in_advance` int NULL DEFAULT NULL,
  `attrition_rate` decimal(19, 10) NULL DEFAULT NULL,
  `enable_shelf_life` tinyint NULL DEFAULT NULL,
  `shelf_life` int NULL DEFAULT NULL,
  `in_shelf_life` int NULL DEFAULT NULL,
  `out_shelf_life` int NULL DEFAULT NULL,
  `tax_rate` decimal(19, 10) NULL DEFAULT NULL,
  `consume_while_buy` tinyint NULL DEFAULT NULL,
  `enable_batch` tinyint NULL DEFAULT NULL,
  `enable_sn` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `reference_price` decimal(19, 10) NULL DEFAULT NULL COMMENT '参考进价',
  `in_transit_quantity` decimal(19, 10) NULL DEFAULT NULL COMMENT '在途数量',
  `last_transit_time` datetime NULL DEFAULT NULL COMMENT '最后在途时间',
  `last_receipt_time` datetime NULL DEFAULT NULL COMMENT '最后入库时间',
  `img_url` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品图片',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_goods_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_goods_in_department
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods_in_department`;
CREATE TABLE `sc_goods_in_department`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `price` decimal(19, 10) NULL DEFAULT NULL,
  `volume` decimal(19, 10) NULL DEFAULT NULL,
  `bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Goods_code` bigint NULL DEFAULT NULL,
  `Department_code` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_goods_in_department_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_goods_in_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods_in_warehouse`;
CREATE TABLE `sc_goods_in_warehouse`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `price` decimal(19, 10) NULL DEFAULT NULL,
  `volume` decimal(19, 10) NULL DEFAULT NULL,
  `bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Goods_code` bigint NULL DEFAULT NULL,
  `Warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Warehouse_code` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop_id` bigint NULL DEFAULT NULL,
  `Super_dish_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Super_dish_type_code` bigint NULL DEFAULT NULL,
  `Dish_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Dish_type_code` bigint NULL DEFAULT NULL,
  `Inventory_time` datetime NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_goods_in_warehouse_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_goods_in_warhouse
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods_in_warhouse`;
CREATE TABLE `sc_goods_in_warhouse`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `price` decimal(19, 10) NULL DEFAULT NULL,
  `volume` decimal(19, 10) NULL DEFAULT NULL,
  `bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_goods_in_warhouse_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_goods_route_rule
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods_route_rule`;
CREATE TABLE `sc_goods_route_rule`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_goods_route_rule_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_goods_sales_delivery_record
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods_sales_delivery_record`;
CREATE TABLE `sc_goods_sales_delivery_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `volume` decimal(19, 10) NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `reduce_status` int NULL DEFAULT NULL,
  `deal_time` datetime NULL DEFAULT NULL,
  `request_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `begin_volume` decimal(19, 10) NULL DEFAULT NULL,
  `end_volume` decimal(19, 10) NULL DEFAULT NULL,
  `warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Owner_shop_id` bigint NULL DEFAULT NULL,
  `Goods_code` bigint NULL DEFAULT NULL,
  `Warehouse_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_goods_sales_delivery_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_goods_sales_delivery_record_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_goods_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods_type`;
CREATE TABLE `sc_goods_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `superior` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `superior_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_goods_type_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_goods_unit
-- ----------------------------
DROP TABLE IF EXISTS `sc_goods_unit`;
CREATE TABLE `sc_goods_unit`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `conversion_rate` decimal(19, 10) NULL DEFAULT NULL,
  `for_standard` tinyint NULL DEFAULT NULL,
  `for_order` tinyint NULL DEFAULT NULL,
  `for_cost` tinyint NULL DEFAULT NULL,
  `for_stock` tinyint NULL DEFAULT NULL,
  `for_assist` tinyint NULL DEFAULT NULL,
  `barcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `used_stock` tinyint NULL DEFAULT NULL COMMENT '是否已产生库存',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_goods_unit_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_hot_key
-- ----------------------------
DROP TABLE IF EXISTS `sc_hot_key`;
CREATE TABLE `sc_hot_key`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `func` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `key_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_hot_key_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_income
-- ----------------------------
DROP TABLE IF EXISTS `sc_income`;
CREATE TABLE `sc_income`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `editor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `edit_time` datetime NULL DEFAULT NULL,
  `source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `income_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `income_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_income_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_income_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_income_type`;
CREATE TABLE `sc_income_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_income_type_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_inst
-- ----------------------------
DROP TABLE IF EXISTS `sc_inst`;
CREATE TABLE `sc_inst`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `principal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `industry` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `industry_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `PCNum` int NULL DEFAULT NULL,
  `PC_LSNum` int NULL DEFAULT NULL,
  `PC_FTNum` int NULL DEFAULT NULL,
  `PC_ZYNum` int NULL DEFAULT NULL,
  `PC_YWNum` int NULL DEFAULT NULL,
  `PC_HYLSNum` int NULL DEFAULT NULL,
  `PC_LSPSNum` int NULL DEFAULT NULL,
  `PC_LSBBNum` int NULL DEFAULT NULL,
  `DCBNum` int NULL DEFAULT NULL,
  `AZPBNum` int NULL DEFAULT NULL,
  `AZSJNum` int NULL DEFAULT NULL,
  `IpadNum` int NULL DEFAULT NULL,
  `ZZDCNum` int NULL DEFAULT NULL,
  `Balance` decimal(19, 10) NULL DEFAULT NULL,
  `Gift_balance` decimal(19, 10) NULL DEFAULT NULL,
  `Powerbank_balance` decimal(19, 10) NULL DEFAULT NULL,
  `Share_balance` decimal(19, 10) NULL DEFAULT NULL,
  `Principal_balance` decimal(19, 10) NULL DEFAULT NULL,
  `Wechat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Inst_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Technical_director_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Technical_director_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Technical_director_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Technical_director_wechat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Business_director_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Business_director_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Business_director_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Business_director_wechat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Tax_identification_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Company_account_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Account_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Bank_of_deposit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Remark` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Product_price_set` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Product_price_set_code` bigint NULL DEFAULT NULL,
  `Sync_from_old` tinyint NULL DEFAULT NULL,
  `Pid_from_old` bigint NULL DEFAULT NULL,
  `Annual` tinyint NULL DEFAULT NULL,
  `Over_time` datetime NULL DEFAULT NULL,
  `JLWeappNum` int NULL DEFAULT NULL,
  `JBWeappNum` int NULL DEFAULT NULL,
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_inst_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 641 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_inst_adm
-- ----------------------------
DROP TABLE IF EXISTS `sc_inst_adm`;
CREATE TABLE `sc_inst_adm`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pwd` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Headimgurl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Type_` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `First_recharge_commission` decimal(19, 10) NULL DEFAULT NULL,
  `Other_recharge_commission` decimal(19, 10) NULL DEFAULT NULL,
  `User_status` tinyint NULL DEFAULT NULL,
  `Remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Create_time` datetime NULL DEFAULT NULL,
  `Login_num` int NULL DEFAULT NULL,
  `Last_login_time` datetime NULL DEFAULT NULL,
  `Last_login_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Sync_from_old` tinyint NULL DEFAULT NULL,
  `Pid_from_old` bigint NULL DEFAULT NULL,
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_inst_adm_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 843 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_inst_and_product
-- ----------------------------
DROP TABLE IF EXISTS `sc_inst_and_product`;
CREATE TABLE `sc_inst_and_product`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `Inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Inst_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `product_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_inst_and_product_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 392 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_inst_finance_bill
-- ----------------------------
DROP TABLE IF EXISTS `sc_inst_finance_bill`;
CREATE TABLE `sc_inst_finance_bill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `crttime` datetime NULL DEFAULT NULL,
  `jinbanren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `balance_before` decimal(19, 10) NULL DEFAULT NULL,
  `balance` decimal(19, 10) NULL DEFAULT NULL,
  `balance_after` decimal(19, 10) NULL DEFAULT NULL,
  `principal_before` decimal(19, 10) NULL DEFAULT NULL,
  `principal` decimal(19, 10) NULL DEFAULT NULL,
  `principal_after` decimal(19, 10) NULL DEFAULT NULL,
  `gift_balance_before` decimal(19, 10) NULL DEFAULT NULL,
  `gift_balance` decimal(19, 10) NULL DEFAULT NULL,
  `gift_balance_after` decimal(19, 10) NULL DEFAULT NULL,
  `powerbank_balance_before` decimal(19, 10) NULL DEFAULT NULL,
  `powerbank_balance` decimal(19, 10) NULL DEFAULT NULL,
  `powerbank_balance_after` decimal(19, 10) NULL DEFAULT NULL,
  `share_balance_before` decimal(19, 10) NULL DEFAULT NULL,
  `share_balance` decimal(19, 10) NULL DEFAULT NULL,
  `share_balance_after` decimal(19, 10) NULL DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `refflag` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `otherbillid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Recharge_set_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Recharge_set_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Recharge_set_amount` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_inst_finance_bill_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_inst_finance_bill_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_inst_op_log
-- ----------------------------
DROP TABLE IF EXISTS `sc_inst_op_log`;
CREATE TABLE `sc_inst_op_log`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `crt_time` datetime NULL DEFAULT NULL,
  `inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_inst_op_log_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_inst_recharge_set
-- ----------------------------
DROP TABLE IF EXISTS `sc_inst_recharge_set`;
CREATE TABLE `sc_inst_recharge_set`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `gift_amount` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_inst_recharge_set_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_integral_goods
-- ----------------------------
DROP TABLE IF EXISTS `sc_integral_goods`;
CREATE TABLE `sc_integral_goods`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `goods_integral` decimal(19, 10) NULL DEFAULT NULL,
  `goods_type` int NULL DEFAULT NULL,
  `goods_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_info_msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_info_img_one` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_info_img_two` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `need_postage` tinyint NULL DEFAULT NULL,
  `crt_time` datetime NULL DEFAULT NULL,
  `disable_time` datetime NULL DEFAULT NULL,
  `stock_nums` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_integral_goods_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_integral_goods_plan
-- ----------------------------
DROP TABLE IF EXISTS `sc_integral_goods_plan`;
CREATE TABLE `sc_integral_goods_plan`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `maker` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `make_time` datetime NULL DEFAULT NULL,
  `for_all` tinyint NULL DEFAULT NULL,
  `Integral_rate` decimal(19, 10) NULL DEFAULT NULL,
  `Integral_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_integral_goods_plan_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_integral_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_integral_order`;
CREATE TABLE `sc_integral_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `total_integral` decimal(19, 10) NULL DEFAULT NULL,
  `total_goods_num` int NULL DEFAULT NULL,
  `courie_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `return_courie_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `crt_time` datetime NULL DEFAULT NULL,
  `need_postage` tinyint NULL DEFAULT NULL,
  `operation_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Return_integral` decimal(19, 10) NULL DEFAULT NULL,
  `Return_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_integral_order_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_integral_order_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_integral_order_info
-- ----------------------------
DROP TABLE IF EXISTS `sc_integral_order_info`;
CREATE TABLE `sc_integral_order_info`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `integral_order_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_num` int NULL DEFAULT NULL,
  `goods_integral` decimal(19, 10) NULL DEFAULT NULL,
  `goods_type` int NULL DEFAULT NULL,
  `goods_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_info_img_one` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_info_img_two` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `need_postage` tinyint NULL DEFAULT NULL,
  `Goods_total_integral` decimal(19, 10) NULL DEFAULT NULL,
  `Return_integral` decimal(19, 10) NULL DEFAULT NULL,
  `Return_num` int NULL DEFAULT NULL,
  `Returning_num` int NULL DEFAULT NULL,
  `Has_return` tinyint NULL DEFAULT NULL,
  `Return_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Order_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_integral_order_info_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_integral_order_info_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_integral_plan_and_goods
-- ----------------------------
DROP TABLE IF EXISTS `sc_integral_plan_and_goods`;
CREATE TABLE `sc_integral_plan_and_goods`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `integral_plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `integral_plan_code` bigint NULL DEFAULT NULL,
  `integral_goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `integral_goods_code` bigint NULL DEFAULT NULL,
  `Integral_rate` decimal(19, 10) NULL DEFAULT NULL,
  `Can_integral` tinyint NULL DEFAULT NULL,
  `Unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_integral_plan_and_goods_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_integral_plan_and_store
-- ----------------------------
DROP TABLE IF EXISTS `sc_integral_plan_and_store`;
CREATE TABLE `sc_integral_plan_and_store`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `integral_plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `integral_plan_code` bigint NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_integral_plan_and_store_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_invitation_reward
-- ----------------------------
DROP TABLE IF EXISTS `sc_invitation_reward`;
CREATE TABLE `sc_invitation_reward`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `use_begin_time` datetime NULL DEFAULT NULL,
  `use_end_time` datetime NULL DEFAULT NULL,
  `maker` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `make_time` datetime NULL DEFAULT NULL,
  `coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nums` decimal(19, 10) NULL DEFAULT NULL,
  `instructions` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `recharge_cash_back` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_invitation_reward_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_item_for_bill_in_mall
-- ----------------------------
DROP TABLE IF EXISTS `sc_item_for_bill_in_mall`;
CREATE TABLE `sc_item_for_bill_in_mall`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `volume` decimal(19, 10) NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `org_price` decimal(19, 10) NULL DEFAULT NULL,
  `price` decimal(19, 10) NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `discount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `amount_of_discount` decimal(19, 10) NULL DEFAULT NULL,
  `Bill_code` bigint NULL DEFAULT NULL,
  `Dish_code` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_item_for_bill_in_mall_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_item_for_bill_in_mall_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_join_us
-- ----------------------------
DROP TABLE IF EXISTS `sc_join_us`;
CREATE TABLE `sc_join_us`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `jointype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `partner_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `partner_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_join_us_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_large_turntable
-- ----------------------------
DROP TABLE IF EXISTS `sc_large_turntable`;
CREATE TABLE `sc_large_turntable`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '大转盘名称',
  `lmnid` bigint NOT NULL,
  `status_` int NULL DEFAULT NULL,
  `ENABLE` tinyint NULL DEFAULT NULL COMMENT '状态',
  `activity_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '活动类型：大奖盘，刮刮乐等',
  `begin_date` datetime NULL DEFAULT NULL COMMENT '开始日期',
  `end_date` datetime NULL DEFAULT NULL COMMENT '结束日期',
  `limit_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '限制类型：会员，粉丝',
  `partake_mode` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '参与方式：免费参与，积分兑换，充值赠送，消费赠送',
  `use_period` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '限制使用周期：每天，每周，每月',
  `use_times` int NULL DEFAULT NULL COMMENT '限制周期内最多使用的次数',
  `points_exchange` decimal(19, 10) NULL DEFAULT NULL COMMENT '兑换抽奖所需积分',
  `points_exchange_times` int NULL DEFAULT NULL COMMENT '积分兑换抽奖对应的抽奖次数',
  `charge_gift_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '充值满赠门槛金额',
  `charge_gift_times` int NULL DEFAULT NULL COMMENT '充值满赠赠送的抽奖次数',
  `charge_gift_max_times` int NULL DEFAULT NULL COMMENT '充值最多可赠送次数',
  `consume_gift_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '消费满赠门槛金额',
  `consume_gift_times` int NULL DEFAULT NULL COMMENT '消费满赠赠送的抽奖次数',
  `consume_gift_max_times` int NULL DEFAULT NULL COMMENT '消费最多可赠送次数',
  `prize_remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '奖项说明',
  `activity_remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '活动说明',
  `fail_tips` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '抽奖失败提示',
  `msg_img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '消息封面图片',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `updated_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_large_turntable_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '大转盘活动' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_large_turntable_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_large_turntable_item`;
CREATE TABLE `sc_large_turntable_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '奖项名称',
  `status_` int NULL DEFAULT NULL,
  `large_turntable` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '活动名称',
  `large_turntable_code` bigint NULL DEFAULT NULL COMMENT '活动lmnid',
  `probability` decimal(19, 10) NULL DEFAULT NULL COMMENT '抽奖概率',
  `limit_number` int NULL DEFAULT NULL COMMENT '限制数量',
  `drawn_out_number` int NULL DEFAULT NULL COMMENT '已抽出数量',
  `gift_coupon` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '奖劵名称',
  `gift_coupon_code` bigint NULL DEFAULT NULL COMMENT '劵lmnid',
  `gift_points` decimal(19, 10) NULL DEFAULT NULL COMMENT '奖励积分',
  `img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '奖品地址',
  `img_thumbnail_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '奖品缩略图地址',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_large_turntable_item_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sc_large_turntable_item_company_large_turntable_code`(`company_id` ASC, `shop_id` ASC, `large_turntable_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 179 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '活动奖项明细' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_large_turntable_record
-- ----------------------------
DROP TABLE IF EXISTS `sc_large_turntable_record`;
CREATE TABLE `sc_large_turntable_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `large_turntable` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '大转盘活动名称',
  `large_turntable_code` bigint NULL DEFAULT NULL COMMENT '大转盘活动lmnid',
  `member_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员名称',
  `member_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员电话',
  `card_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员卡号',
  `open_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'openid',
  `large_turntable_item` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '奖项名称',
  `large_turntable_item_code` bigint NULL DEFAULT NULL COMMENT '奖项lmnid',
  `gift_coupon` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '奖劵名称',
  `gift_coupon_code` bigint NULL DEFAULT NULL COMMENT '劵lmnid',
  `gift_points` decimal(19, 10) NULL DEFAULT NULL COMMENT '奖励积分',
  `amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '满赠金额',
  `paid_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '充值/赠送/购买金额',
  `img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '奖品地址',
  `img_thumbnail_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '奖品缩略图地址',
  `raffle_result` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '抽奖结果：中奖，未中奖',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `partake_channel` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '参与渠道：充值，消费，积分兑换,小程序抽奖,其他',
  `remarks` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注，说明',
  `last_times` int NULL DEFAULT NULL COMMENT '上一次抽奖次数',
  `this_times` int NULL DEFAULT NULL COMMENT '本次增加/扣减抽奖次数',
  `surplus_times` int NULL DEFAULT NULL COMMENT '剩余抽奖次数',
  `yingYeRiQi` datetime NULL DEFAULT NULL,
  `YEAR` int NULL DEFAULT NULL,
  `MONTH` int NULL DEFAULT NULL,
  `DAY` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_large_turntable_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sc_large_turntable_record_record_COMPANY_card_id`(`company_id` ASC, `card_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 63 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '转盘抽奖/增加记录' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_auto_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_auto_order`;
CREATE TABLE `sc_mall_auto_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `tbl_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tbl_type_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_num` decimal(19, 10) NULL DEFAULT NULL,
  `dish_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `start_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `end_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `By_quantity` tinyint NULL DEFAULT NULL,
  `By_person` tinyint NULL DEFAULT NULL,
  `auto_order_type` int NULL DEFAULT 1 COMMENT '自动点菜类型',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_auto_order_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_sid_type_lid`(`company_id` ASC, `shop_id` ASC, `tbl_type_code`(191) ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 298762 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_cash_back_food
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_cash_back_food`;
CREATE TABLE `sc_mall_cash_back_food`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `Dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品名称',
  `Dish_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品编号',
  `Dish_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品小类',
  `Dish_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品小类编号',
  `Cash_back` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '返现活动名称',
  `Cash_back_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '返现活动编号',
  `Unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_cash_back_food_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sc_mall_cash_back_food_COMPANY_SHOP_Dish_code`(`company_id` ASC, `shop_id` ASC, `Dish_code`(191) ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1155 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '不参与消费返现的菜品' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_consume_coupon_food
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_consume_coupon_food`;
CREATE TABLE `sc_mall_consume_coupon_food`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `Dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Dish_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Dish_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Dish_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_consume_coupon_food_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 686 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_coupon
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_coupon`;
CREATE TABLE `sc_mall_coupon`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `coupon_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `face_value` decimal(19, 10) NULL DEFAULT NULL,
  `full_money` decimal(19, 10) NULL DEFAULT NULL,
  `limit_number` decimal(19, 10) NULL DEFAULT NULL,
  `receiving_limit_number` decimal(19, 10) NULL DEFAULT NULL,
  `begin_reception_time` datetime NULL DEFAULT NULL,
  `end_reception_time` datetime NULL DEFAULT NULL,
  `instructions` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `use_restriction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fixed_days` decimal(19, 10) NULL DEFAULT NULL,
  `fixed_begin_date` datetime NULL DEFAULT NULL,
  `fixed_end_date` datetime NULL DEFAULT NULL,
  `fixed_begin_time` datetime NULL DEFAULT NULL,
  `fixed_end_time` datetime NULL DEFAULT NULL,
  `moday` tinyint NULL DEFAULT NULL,
  `tuesday` tinyint NULL DEFAULT NULL,
  `wednesday` tinyint NULL DEFAULT NULL,
  `thursday` tinyint NULL DEFAULT NULL,
  `friday` tinyint NULL DEFAULT NULL,
  `saturday` tinyint NULL DEFAULT NULL,
  `sunday` tinyint NULL DEFAULT NULL,
  `Dish_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Dish_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Begin_use_time` datetime NULL DEFAULT NULL,
  `End_use_time` datetime NULL DEFAULT NULL,
  `Maker` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Make_time` datetime NULL DEFAULT NULL,
  `Update_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `update_Time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `Is_all_store` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Is_review` tinyint NULL DEFAULT NULL,
  `Reviewer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Review_time` datetime NULL DEFAULT NULL,
  `Is_terminator` tinyint NULL DEFAULT NULL,
  `Terminator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Terminat_time` datetime NULL DEFAULT NULL,
  `Received_number` decimal(19, 10) NULL DEFAULT NULL,
  `Is_pkg` tinyint NULL DEFAULT NULL,
  `Img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Is_ad` tinyint NULL DEFAULT NULL,
  `enable_direct_take` tinyint NULL DEFAULT NULL,
  `limit_use_day` int NULL DEFAULT NULL,
  `limit_use_num` int NULL DEFAULT NULL,
  `Is_enable_purchase` tinyint NULL DEFAULT NULL,
  `Purchase_price` decimal(19, 10) NULL DEFAULT NULL,
  `Original_price` decimal(19, 10) NULL DEFAULT NULL,
  `Purchase_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Purchase_limit_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Start_purchase_time` datetime NULL DEFAULT NULL,
  `End_purchase_time` datetime NULL DEFAULT NULL,
  `Max_purchase_num` int NULL DEFAULT NULL,
  `Every_day_max_purchase_num` int NULL DEFAULT NULL,
  `Coupon_qr_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Desc_img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Sold_growth_value` int NULL DEFAULT NULL,
  `Sold_base_value` int NULL DEFAULT NULL,
  `Popularity_growth_value` int NULL DEFAULT NULL,
  `Popularity_base_value` int NULL DEFAULT NULL,
  `Desc_img_url4` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Desc_img_url3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Desc_img_url2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Desc_img_url1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Desc_img_url0` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Desc_font_size` int NULL DEFAULT NULL,
  `Pay_account_storce` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Coupon_weapp_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Start_time_slot` datetime NULL DEFAULT NULL,
  `End_time_slot` datetime NULL DEFAULT NULL,
  `can_make_appointment` tinyint NULL DEFAULT NULL,
  `Coupon_mode` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模式，CP:劵，RE:红包',
  `face_value_method` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '面值金额方式，GDF:固定面值，RDF:随机面值,GDP:固定比例，RDP:范围比例',
  `face_value_min` decimal(19, 10) NULL DEFAULT NULL COMMENT '随机面值时，最低面值',
  `face_value_max` decimal(19, 10) NULL DEFAULT NULL COMMENT '随机面值时，最大面值',
  `can_transferable` tinyint NULL DEFAULT NULL COMMENT '可转赠',
  `face_value_mantissa_method` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '取整方式',
  `by_proportion_take_value` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '通过概率获取随机面值',
  `begin_valid_days` decimal(19, 10) NULL DEFAULT NULL COMMENT '自领取日起开始生效的天数',
  `eve_full_money` decimal(19, 10) NULL DEFAULT NULL COMMENT '每满xxx金额就使用',
  `eve_full_max_times` int NULL DEFAULT NULL COMMENT '每满xxx金额最多可使用xxx张',
  `dish_shop_id` bigint NULL DEFAULT NULL COMMENT '实物券菜品所属店铺编号',
  `base_map_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '优惠券底图地址',
  `dish_unit` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商品单位',
  `every_day_limit_number` int NULL DEFAULT NULL COMMENT '每天限领数量',
  `start_valid_time` datetime NULL DEFAULT NULL COMMENT '优惠券开始生效日期',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_coupon_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_lid`(`company_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 55 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_coupon_festival
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_coupon_festival`;
CREATE TABLE `sc_mall_coupon_festival`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `coupon_code` bigint NULL DEFAULT NULL COMMENT '优惠券编号',
  `coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '优惠券',
  `festival_code` bigint NULL DEFAULT NULL COMMENT '节假日编号',
  `festival` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '节假日',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_coupon_festival_COMPANY_LmnID`(`company_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '节假日与优惠券关联' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_coupon_hours
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_coupon_hours`;
CREATE TABLE `sc_mall_coupon_hours`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `hours_begin_time` datetime NULL DEFAULT NULL,
  `hours_end_time` datetime NULL DEFAULT NULL,
  `Coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_coupon_hours_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_coupon_map
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_coupon_map`;
CREATE TABLE `sc_mall_coupon_map`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `main_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `deputy_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `main` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `deputy` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `number` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_coupon_map_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_coupon_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_coupon_order`;
CREATE TABLE `sc_mall_coupon_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `pkg_coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pkg_coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `deadline` datetime NULL DEFAULT NULL,
  `get_date` datetime NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `avatarurl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `write_off_staff` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `write_off_time` datetime NULL DEFAULT NULL,
  `coupon_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_id_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `used_time` datetime NULL DEFAULT NULL,
  `Abandon_time` datetime NULL DEFAULT NULL,
  `Abandon_staff` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Get_channel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `can_make_appointment` tinyint NULL DEFAULT NULL,
  `time_of_appointment` datetime NULL DEFAULT NULL,
  `Store_of_appointment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Store_code_of_appointment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Used_Shop_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Used_Shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon_mode` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '模式，CP:劵，RE:红包',
  `face_value_method` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '面值金额方式，GDF:固定面值，RDF:随机面值,GDP:固定比例，RDP:范围比例',
  `face_value_min` decimal(19, 10) NULL DEFAULT NULL COMMENT '随机面值时，最低面值',
  `face_value_max` decimal(19, 10) NULL DEFAULT NULL COMMENT '随机面值时，最大面值',
  `face_value` decimal(19, 10) NULL DEFAULT NULL COMMENT '红包或者劵的面值（随机面值或按比例时使用）',
  `bill_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '消费单金额',
  `proportion_min` decimal(19, 10) NULL DEFAULT NULL COMMENT '范围比例时，最低比例',
  `proportion_max` decimal(19, 10) NULL DEFAULT NULL COMMENT '范围比例时，最高比例',
  `can_transferable` tinyint NULL DEFAULT NULL COMMENT '可转赠',
  `valid_date` datetime NULL DEFAULT NULL COMMENT '领取的优惠券开始使用日期',
  `start_valid_time` datetime NULL DEFAULT NULL COMMENT '优惠券开始生效日期',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_coupon_order_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sc_mall_coupon_order_COMPANY_LmnID`(`company_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_coupon_order_cid_unionid`(`company_id` ASC, `unionid`(191) ASC) USING BTREE,
  INDEX `idx_mid_sid_order_id`(`company_id` ASC, `shop_id` ASC, `order_bill_id`(191) ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1146 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_coupon_purchase
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_coupon_purchase`;
CREATE TABLE `sc_mall_coupon_purchase`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `purchase_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `purchase_limit_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `original_price` decimal(19, 10) NULL DEFAULT NULL,
  `coupon_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `purchase_num` int NULL DEFAULT NULL,
  `purchase_price` decimal(19, 10) NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Deal_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Tran_order_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_coupon_purchase_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 668 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_discount
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_discount`;
CREATE TABLE `sc_mall_discount`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `discount_rate` decimal(19, 10) NULL DEFAULT NULL,
  `custom_discount` tinyint NULL DEFAULT NULL,
  `ENABLE` tinyint NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `card_type_lids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '会员卡类型lids',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_discount_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 921 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_discount_dish
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_discount_dish`;
CREATE TABLE `sc_mall_discount_dish`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `dish_code` bigint NULL DEFAULT NULL COMMENT '菜品lid',
  `dish_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `discount_code` bigint NULL DEFAULT NULL COMMENT '折扣lid',
  `dish_unit` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '单位名称',
  `discount_rate` decimal(10, 4) NULL DEFAULT NULL COMMENT '菜品折扣率：0.0000-1.0000，如 0.85 表示 85 折',
  `use_custom_rate` tinyint NULL DEFAULT 0 COMMENT '是否使用自定义折扣率：0-否 (使用默认),1-是',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_discount_dish_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 207374 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_discount_tbl_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_discount_tbl_type`;
CREATE TABLE `sc_mall_discount_tbl_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `tbl_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tbl_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `discount_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_discount_tbl_type_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_exchange_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_exchange_order`;
CREATE TABLE `sc_mall_exchange_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `order_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `point_exchange_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `point_exchange_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `point_exchange_value` decimal(19, 10) NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `order_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cancel_time` datetime NULL DEFAULT NULL,
  `cancel_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_exchange_order_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 149 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_festival
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_festival`;
CREATE TABLE `sc_mall_festival`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime NULL DEFAULT NULL COMMENT '结束时间',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_festival_COMPANY_LmnID`(`company_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '节假日定义' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_gift_coupon_food
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_gift_coupon_food`;
CREATE TABLE `sc_mall_gift_coupon_food`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `Dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Dish_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Dish_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Dish_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_gift_coupon_food_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 133 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_gift_dish_reason
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_gift_dish_reason`;
CREATE TABLE `sc_mall_gift_dish_reason`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_gift_dish_reason_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 38 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_member_goods
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_member_goods`;
CREATE TABLE `sc_mall_member_goods`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `order_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `self_start_lifting_time` datetime NULL DEFAULT NULL,
  `self_end_lifting_time` datetime NULL DEFAULT NULL,
  `confirm_Self_lifting_time` datetime NULL DEFAULT NULL,
  `confirm_Self_lifting` tinyint NULL DEFAULT NULL,
  `Confirm_Self_lifting_num` decimal(19, 10) NULL DEFAULT NULL,
  `Has_Self_lifting` tinyint NULL DEFAULT NULL,
  `Has_Self_lifting_time` datetime NULL DEFAULT NULL,
  `Cancel_Self_lifting_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Cancel_Self_lifting_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_member_goods_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_point_exchange
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_point_exchange`;
CREATE TABLE `sc_mall_point_exchange`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `effective_start_time` datetime NULL DEFAULT NULL,
  `effective_end_time` datetime NULL DEFAULT NULL,
  `point_exchange_value` decimal(19, 10) NULL DEFAULT NULL,
  `coupon_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `original_price` decimal(19, 10) NULL DEFAULT NULL,
  `sort_number` int NULL DEFAULT NULL,
  `exchange_num` int NULL DEFAULT NULL,
  `sold_growth_value` int NULL DEFAULT NULL,
  `sold_base_value` int NULL DEFAULT NULL,
  `popularity_growth_value` int NULL DEFAULT NULL,
  `popularity_base_value` int NULL DEFAULT NULL,
  `limit_exchange_times` int NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `exchange_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Exchange_weapp_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_point_exchange_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_purchase_order
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_purchase_order`;
CREATE TABLE `sc_mall_purchase_order`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `order_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `purchase_rule_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `purchase_rule_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `purchase_price` decimal(19, 10) NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `order_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `refund_time` datetime NULL DEFAULT NULL,
  `refund_user` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Store_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Store_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Self_start_lifting_time` datetime NULL DEFAULT NULL,
  `Self_end_lifting_time` datetime NULL DEFAULT NULL,
  `Confirm_Self_lifting_time` datetime NULL DEFAULT NULL,
  `Confirm_Self_lifting` tinyint NULL DEFAULT NULL,
  `Tran_order_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `purchase_num` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Purchase_total_price` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_purchase_order_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 43 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_purchase_rule
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_purchase_rule`;
CREATE TABLE `sc_mall_purchase_rule`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `effective_start_time` datetime NULL DEFAULT NULL,
  `effective_end_time` datetime NULL DEFAULT NULL,
  `purchase_price` decimal(19, 10) NULL DEFAULT NULL,
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `original_price` decimal(19, 10) NULL DEFAULT NULL,
  `sort_number` int NULL DEFAULT NULL,
  `purchase_num` int NULL DEFAULT NULL,
  `limit_purchase_times` int NULL DEFAULT NULL,
  `sold_growth_value` int NULL DEFAULT NULL,
  `sold_base_value` int NULL DEFAULT NULL,
  `popularity_growth_value` int NULL DEFAULT NULL,
  `popularity_base_value` int NULL DEFAULT NULL,
  `purchase_weapp_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `store_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `store_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `purchase_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  `Pay_account_store` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_purchase_rule_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_recommend
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_recommend`;
CREATE TABLE `sc_mall_recommend`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `mall_plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `mall_dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_idx` int NULL DEFAULT NULL,
  `crttime` datetime NULL DEFAULT NULL,
  `Mall_dish_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_recommend_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_red_envelope
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_red_envelope`;
CREATE TABLE `sc_mall_red_envelope`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `begin_date` datetime NULL DEFAULT NULL COMMENT '生效时间',
  `end_date` datetime NULL DEFAULT NULL COMMENT '失效时间',
  `pay_type` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付类型,ALL:全部,WXZF:微信支付,HYK:会员卡',
  `full_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '满弹金额',
  `envelope_code` bigint NOT NULL COMMENT '红包编号',
  `envelope` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '红包名称',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `updated_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_red_envelope_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sc_mall_red_envelope_COMPANY_SHOP_coupon_coe`(`company_id` ASC, `shop_id` ASC, `envelope_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '红包活动' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mall_retreat_dish_reason
-- ----------------------------
DROP TABLE IF EXISTS `sc_mall_retreat_dish_reason`;
CREATE TABLE `sc_mall_retreat_dish_reason`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mall_retreat_dish_reason_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 44 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_marketing_plan
-- ----------------------------
DROP TABLE IF EXISTS `sc_marketing_plan`;
CREATE TABLE `sc_marketing_plan`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `maker` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `make_time` datetime NULL DEFAULT NULL,
  `summary` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `reviewer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `review_time` datetime NULL DEFAULT NULL,
  `begin_date` datetime NULL DEFAULT NULL,
  `end_date` datetime NULL DEFAULT NULL,
  `begin_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `terminator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `terminat_time` datetime NULL DEFAULT NULL,
  `moday` tinyint NULL DEFAULT NULL,
  `tuesday` tinyint NULL DEFAULT NULL,
  `wednesday` tinyint NULL DEFAULT NULL,
  `thursday` tinyint NULL DEFAULT NULL,
  `friday` tinyint NULL DEFAULT NULL,
  `saturday` tinyint NULL DEFAULT NULL,
  `sunday` tinyint NULL DEFAULT NULL,
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `score` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `additional_information1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `additional_information2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish_can_discount` tinyint NULL DEFAULT NULL,
  `discount_rate` decimal(19, 10) NULL DEFAULT NULL,
  `Is_review` tinyint NULL DEFAULT NULL,
  `Is_terminator` tinyint NULL DEFAULT NULL,
  `Full_money` decimal(19, 10) NULL DEFAULT NULL,
  `Minus_money` decimal(19, 10) NULL DEFAULT NULL,
  `Give_money` decimal(19, 10) NULL DEFAULT NULL,
  `Increase_money` decimal(19, 10) NULL DEFAULT NULL,
  `Give_dish` decimal(19, 10) NULL DEFAULT NULL,
  `Give_gift_dish` decimal(19, 10) NULL DEFAULT NULL,
  `Give_gift_Coupon` decimal(19, 10) NULL DEFAULT NULL,
  `Give_gift_piece` decimal(19, 10) NULL DEFAULT NULL,
  `Discount_quantity` decimal(19, 10) NULL DEFAULT NULL,
  `Full_piece` int NULL DEFAULT NULL,
  `Special_price` decimal(19, 10) NULL DEFAULT NULL,
  `Buy_imit` int NULL DEFAULT NULL,
  `Buy_price` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `By_multiple` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_marketing_plan_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_member_gift_record
-- ----------------------------
DROP TABLE IF EXISTS `sc_member_gift_record`;
CREATE TABLE `sc_member_gift_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `new_gift` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '新人礼包名称',
  `new_gift_code` bigint NULL DEFAULT NULL COMMENT '新人礼包shop_id',
  `member_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员名称',
  `member_phone` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员手机号',
  `card_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员卡号',
  `open_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'openid',
  `create_time` datetime NULL DEFAULT NULL COMMENT '领取时间',
  `gift_coupon` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '赠劵名称',
  `gift_coupon_code` bigint NULL DEFAULT NULL COMMENT '劵lmnid',
  `yingYeRiQi` datetime NULL DEFAULT NULL,
  `YEAR` int NULL DEFAULT NULL,
  `MONTH` int NULL DEFAULT NULL,
  `DAY` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_member_gift_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sc_member_gift_record_COMPANY_SHOP_card_id`(`company_id` ASC, `shop_id` ASC, `card_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1107 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '新人礼包领取记录' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_member_red_envelope_record
-- ----------------------------
DROP TABLE IF EXISTS `sc_member_red_envelope_record`;
CREATE TABLE `sc_member_red_envelope_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `coupon_code` bigint NOT NULL COMMENT '红包编号',
  `coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '红包名称',
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员名称',
  `card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员卡lmnid',
  `open_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'openid',
  `member_phone` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员电话',
  `red_envelope` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '活动名称',
  `red_envelope_code` bigint NULL DEFAULT NULL COMMENT '活动名称ID',
  `bill_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '消费金额',
  `pay_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付方式',
  `envelope_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '红包的类型，比例，现金，实物',
  `face_value_method` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '面值金额方式，GDF:固定面值，RDF:随机面值,GDP:固定比例，RDP:范围比例',
  `face_value_min` decimal(19, 10) NULL DEFAULT NULL COMMENT '随机面值时，最低面值',
  `face_value_max` decimal(19, 10) NULL DEFAULT NULL COMMENT '随机面值时，最大面值',
  `face_value` decimal(19, 10) NULL DEFAULT NULL COMMENT '红包的最终面值',
  `proportion_min` decimal(19, 10) NULL DEFAULT NULL COMMENT '范围比例时，最低比例',
  `proportion_max` decimal(19, 10) NULL DEFAULT NULL COMMENT '范围比例时，最高比例',
  `min_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '最低消费金额',
  `max_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '最高消费金额',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `owner_shop` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '领取门店',
  `owner_shop_id` bigint NULL DEFAULT NULL COMMENT '领取门店编号',
  `yingYeRiQi` datetime NULL DEFAULT NULL,
  `YEAR` int NULL DEFAULT NULL,
  `MONTH` int NULL DEFAULT NULL,
  `DAY` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_member_red_envelope_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sc_member_red_envelope_record_COMPANY_SHOP_envelope_code`(`company_id` ASC, `shop_id` ASC, `red_envelope_code` ASC) USING BTREE,
  INDEX `IDX_U_sc_member_red_envelope_record_COMPANY_SHOP_coupon_code`(`company_id` ASC, `shop_id` ASC, `coupon_code` ASC) USING BTREE,
  INDEX `IDX_U_sc_member_red_envelope_record_COMPANY_envelope_code_id`(`company_id` ASC, `red_envelope_code` ASC, `id`(191) ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7328 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员红包领取记录' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_member_transferable_record
-- ----------------------------
DROP TABLE IF EXISTS `sc_member_transferable_record`;
CREATE TABLE `sc_member_transferable_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `coupon_order_code` bigint NOT NULL COMMENT '优惠券/红包订单编号',
  `coupon_code` bigint NULL DEFAULT NULL COMMENT '优惠券/红包编号',
  `coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '优惠券/红包名称',
  `dish_code` bigint NULL DEFAULT NULL COMMENT '优惠券/红包编号',
  `dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '优惠券/红包名称',
  `coupon_mode` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '劵模式',
  `coupon_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '劵类型',
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转赠人会员名称',
  `card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转赠人会员卡lmnid',
  `open_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转赠人openid',
  `member_phone` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '转赠人会员电话',
  `receive_member_phone` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '领取人会员电话',
  `receive_member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '领取人会员名称',
  `receive_card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '领取人会员卡lmnid',
  `receive_open_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '领取人openid',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `yingYeRiQi` datetime NULL DEFAULT NULL,
  `YEAR` int NULL DEFAULT NULL,
  `MONTH` int NULL DEFAULT NULL,
  `DAY` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_member_transferable_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sc_member_transferable_record_COMPANY_SHOP_card_id`(`company_id` ASC, `card_id`(191) ASC) USING BTREE,
  INDEX `IDX_U_sc_member_transferable_record_COMPANY_SHOP_member_phone`(`company_id` ASC, `member_phone` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员优惠券/红包转赠记录' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_member_turntable_times
-- ----------------------------
DROP TABLE IF EXISTS `sc_member_turntable_times`;
CREATE TABLE `sc_member_turntable_times`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `member_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员名称',
  `card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员卡lmnid',
  `open_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'openid',
  `member_phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会员电话',
  `times` int NULL DEFAULT NULL COMMENT '总抽奖次数',
  `surplus_times` int NULL DEFAULT NULL COMMENT '剩余抽奖次数',
  `charge_gift_max_times` int NULL DEFAULT NULL COMMENT '充值赠送最大次数',
  `charge_gift_sum_times` int NULL DEFAULT NULL COMMENT '充值累加次数',
  `consume_gift_max_times` int NULL DEFAULT NULL COMMENT '消费赠送最大次数',
  `consume_gift_sum_times` int NULL DEFAULT NULL COMMENT '消费累加次数',
  `large_turntable` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '活动名称',
  `large_turntable_code` bigint NULL DEFAULT NULL COMMENT '活动lmnid',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `partake_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '参与类型：每天，每周，每月，不限制',
  `yingYeRiQi` datetime NULL DEFAULT NULL,
  `YEAR` int NULL DEFAULT NULL,
  `MONTH` int NULL DEFAULT NULL,
  `DAY` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_member_turntable_times_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sc_member_turntable_times_COMPANY_card_id`(`company_id` ASC, `card_id`(191) ASC) USING BTREE,
  INDEX `IDX_U_sc_member_turntable_times_COMPANY_phone`(`company_id` ASC, `member_phone` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 129 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '会员抽奖次数剩余表' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_merchant
-- ----------------------------
DROP TABLE IF EXISTS `sc_merchant`;
CREATE TABLE `sc_merchant`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operation_model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `principal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `industry` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `industry_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `recommend_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Can_view` tinyint NULL DEFAULT NULL,
  `SYSType` int NULL DEFAULT NULL,
  `Over_time` datetime NULL DEFAULT NULL,
  `Renew_amount` decimal(19, 10) NULL DEFAULT NULL,
  `Inst_adm` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Inst_adm_code` bigint NULL DEFAULT NULL,
  `Inst_adm_tech` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Inst_adm_tech_code` bigint NULL DEFAULT NULL,
  `Sync_from_old` tinyint NULL DEFAULT NULL,
  `Trial_days` int NULL DEFAULT NULL,
  `ExamineTime` datetime NULL DEFAULT NULL,
  `Total_recharge_amount` decimal(19, 10) NULL DEFAULT NULL,
  `IsExameined` tinyint NULL DEFAULT NULL,
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT 0 COMMENT '是否删除',
  `longitude` decimal(24, 6) NULL DEFAULT NULL COMMENT '经度',
  `latitude` decimal(24, 6) NULL DEFAULT NULL COMMENT '纬度',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_merchant_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22699 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_merchant_op_log
-- ----------------------------
DROP TABLE IF EXISTS `sc_merchant_op_log`;
CREATE TABLE `sc_merchant_op_log`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `crt_time` datetime NULL DEFAULT NULL,
  `merchant` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `merchant_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_merchant_op_log_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_merchant_renew_bill
-- ----------------------------
DROP TABLE IF EXISTS `sc_merchant_renew_bill`;
CREATE TABLE `sc_merchant_renew_bill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `merchant` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `merchant_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `platamount` decimal(19, 10) NULL DEFAULT NULL,
  `agentamount` decimal(19, 10) NULL DEFAULT NULL,
  `crttime` datetime NULL DEFAULT NULL,
  `operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `isplayed` tinyint NULL DEFAULT NULL,
  `iscancel` tinyint NULL DEFAULT NULL,
  `isreturn` tinyint NULL DEFAULT NULL,
  `out_trade_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qr_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `authcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bzid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Store` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Store_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_merchant_renew_bill_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_merchant_renew_bill_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mod_time_of_tbl
-- ----------------------------
DROP TABLE IF EXISTS `sc_mod_time_of_tbl`;
CREATE TABLE `sc_mod_time_of_tbl`  (
  `PID` bigint NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` bigint NOT NULL,
  `ID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `SHOP_ID` bigint NULL DEFAULT NULL,
  `LmnID` bigint NOT NULL,
  `Name` bigint NULL DEFAULT NULL,
  `Status_` int NULL DEFAULT NULL,
  `Tbl_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Mod_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Mod_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Mod_lmnid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`PID`) USING BTREE,
  UNIQUE INDEX `IDX_sc_mod_time_of_tbl_COMPANY_LmnID`(`COMPANY_ID` ASC, `LmnID` ASC) USING BTREE,
  INDEX `IDX_sc_mod_time_of_tbl_COMPANY_SHOP_LMN`(`COMPANY_ID` ASC, `SHOP_ID` ASC, `LmnID` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_mqtt_msg
-- ----------------------------
DROP TABLE IF EXISTS `sc_mqtt_msg`;
CREATE TABLE `sc_mqtt_msg`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `msg` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `rsp_topic` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `msg_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `request_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `crt_time` datetime NULL DEFAULT NULL,
  `Msg_new` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_mqtt_msg_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_mqtt_msg_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE,
  INDEX `sc_mqtt_msg_lmnid_IDX`(`lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_new_gift
-- ----------------------------
DROP TABLE IF EXISTS `sc_new_gift`;
CREATE TABLE `sc_new_gift`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `use_begin_time` datetime NULL DEFAULT NULL,
  `use_end_time` datetime NULL DEFAULT NULL,
  `maker` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `make_time` datetime NULL DEFAULT NULL,
  `coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nums` decimal(19, 10) NULL DEFAULT NULL,
  `instructions` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `img_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '消息图片',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_new_gift_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_new_gift_store
-- ----------------------------
DROP TABLE IF EXISTS `sc_new_gift_store`;
CREATE TABLE `sc_new_gift_store`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `new_gift` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '新人礼包名称',
  `new_gift_code` bigint NULL DEFAULT NULL COMMENT '新人礼包shop_id',
  `store_id` bigint NULL DEFAULT NULL COMMENT '门店lmnid',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_sc_new_gift_store_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 101 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '新人礼包适用门店' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_online_pay_bill_oprlog
-- ----------------------------
DROP TABLE IF EXISTS `sc_online_pay_bill_oprlog`;
CREATE TABLE `sc_online_pay_bill_oprlog`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `createtime` datetime NULL DEFAULT NULL,
  `ordercontent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paycontent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `payamt` decimal(19, 10) NULL DEFAULT NULL,
  `refundamt` decimal(19, 10) NULL DEFAULT NULL,
  `refund` tinyint NULL DEFAULT NULL,
  `refundor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `refundtime` datetime NULL DEFAULT NULL,
  `paytype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_online_pay_bill_oprlog_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_online_pay_bill_oprlog_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_online_pay_record
-- ----------------------------
DROP TABLE IF EXISTS `sc_online_pay_record`;
CREATE TABLE `sc_online_pay_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `playamount` decimal(19, 10) NULL DEFAULT NULL,
  `createtime` datetime NULL DEFAULT NULL,
  `outtimeminute` int NULL DEFAULT NULL,
  `operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `isplayed` tinyint NULL DEFAULT NULL,
  `iscancel` tinyint NULL DEFAULT NULL,
  `isreturn` tinyint NULL DEFAULT NULL,
  `resultxml` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `big_pic_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pic_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `small_pic_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `out_trade_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qr_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `billstatus` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paytype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dvpid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `isprinted` tinyint NULL DEFAULT NULL,
  `wspidforlmd` bigint NULL DEFAULT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dealstatus` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `refnum` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `authcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bogusaccountnum` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `emvdate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plnameoncard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `appname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cardbin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `extdata` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bzid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Refundamt` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_online_pay_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_online_pay_record_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_order_evaluation
-- ----------------------------
DROP TABLE IF EXISTS `sc_order_evaluation`;
CREATE TABLE `sc_order_evaluation`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `is_hide` tinyint NULL DEFAULT NULL,
  `comments_on_stars` int NULL DEFAULT NULL,
  `comments_msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comments_img_one` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comments_img_two` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comments_img_three` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comments_video` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_anonymous` tinyint NULL DEFAULT NULL,
  `like_times` int NULL DEFAULT NULL,
  `express_packaging` int NULL DEFAULT NULL,
  `delivery_speed` int NULL DEFAULT NULL,
  `delivery_service` int NULL DEFAULT NULL,
  `goods_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_info_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nick_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `crt_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_order_evaluation_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_pay_bill
-- ----------------------------
DROP TABLE IF EXISTS `sc_pay_bill`;
CREATE TABLE `sc_pay_bill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `paychanel_order_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `payplatform_order_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `terminal_trace` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `out_trade_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `merchant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `merchant_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pay_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `terminal_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `total_fee` decimal(19, 10) NULL DEFAULT NULL,
  `open_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `result_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `return_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `return_msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `trade_state` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bill_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst_adm_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst_adm` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `recharge_set_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `recharge_set` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `principal` decimal(19, 10) NULL DEFAULT NULL,
  `gift_amount` decimal(19, 10) NULL DEFAULT NULL,
  `renew_merchant_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `renew_merchant` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `crt_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_pay_bill_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_pay_bill_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_pay_way
-- ----------------------------
DROP TABLE IF EXISTS `sc_pay_way`;
CREATE TABLE `sc_pay_way`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `pay_way_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pay_way_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `src` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `actual_income` tinyint NULL DEFAULT NULL,
  `can_integral` tinyint NULL DEFAULT NULL,
  `can_invoicing` tinyint NULL DEFAULT NULL,
  `physical_certificate` tinyint NULL DEFAULT NULL,
  `show_in_pos` tinyint NULL DEFAULT NULL,
  `show_in_crm` tinyint NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `modified_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `modified_time` datetime NULL DEFAULT NULL,
  `show_order` int NULL DEFAULT NULL,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Exchangable` tinyint NULL DEFAULT NULL,
  `cash_box` tinyint(1) NULL DEFAULT 0 COMMENT '弹出钱箱',
  `voice_broadcast` tinyint(1) NULL DEFAULT NULL COMMENT '语音播报',
  `actual_income_rate` decimal(24, 6) NULL DEFAULT NULL COMMENT '实收率',
  `profit_department` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '利润所属部门',
  `actual_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '实收金额',
  `face_value` decimal(19, 10) NULL DEFAULT NULL COMMENT '实收金额',
  `points_rate` decimal(19, 10) NULL DEFAULT NULL COMMENT '积分抵现率',
  `show_in_phone` tinyint(1) NULL DEFAULT NULL COMMENT '在phone显示',
  `show_order_in_phone` int NULL DEFAULT NULL COMMENT 'phone显示顺序',
  `points_bill_rate` decimal(24, 10) NULL DEFAULT NULL COMMENT '积分最多抵扣账单的比率',
  `fraction_digit` int NULL DEFAULT NULL COMMENT '自动抹零小数位数',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_pay_way_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5480 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_pay_way_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_pay_way_type`;
CREATE TABLE `sc_pay_way_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `can_add` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_pay_way_type_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_payway_for_bill_in_mall
-- ----------------------------
DROP TABLE IF EXISTS `sc_payway_for_bill_in_mall`;
CREATE TABLE `sc_payway_for_bill_in_mall`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `fukuanqingkuangid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fukuanqingkuangname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhifujine` decimal(19, 10) NULL DEFAULT NULL,
  `huilv` decimal(19, 10) NULL DEFAULT NULL,
  `hsjine` decimal(19, 10) NULL DEFAULT NULL,
  `zhenshishouru` decimal(19, 10) NULL DEFAULT NULL,
  `exchangable` tinyint NULL DEFAULT NULL,
  `type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhaohuijine` decimal(19, 10) NULL DEFAULT NULL,
  `shishoujine` decimal(19, 10) NULL DEFAULT NULL,
  `sumofintegrate` decimal(19, 10) NULL DEFAULT NULL,
  `huiyuankaid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `huiyuanname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `guazhangid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `guazhangname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qiandanren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `returnbillid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xianjinjuanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `yujiaodingjinid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shouyinyuan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `billnumber` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `availablepoint` decimal(19, 10) NULL DEFAULT NULL,
  `availablevalue` decimal(19, 10) NULL DEFAULT NULL,
  `morememberkaid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `morememberid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `moremembername` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paymoney` decimal(19, 10) NULL DEFAULT NULL,
  `norealincome` tinyint NULL DEFAULT NULL,
  `shishoulv` decimal(19, 10) NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `posserialno` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paychanel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `payplatform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paystatus` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Bill_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_payway_for_bill_in_mall_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_payway_for_bill_in_mall_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_pc_scale
-- ----------------------------
DROP TABLE IF EXISTS `sc_pc_scale`;
CREATE TABLE `sc_pc_scale`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `pos_dev` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pos_dev_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `auto_read` tinyint NULL DEFAULT NULL,
  `auto_comfirm` tinyint NULL DEFAULT NULL,
  `read_time_gap` int NULL DEFAULT NULL,
  `tolerance_scope` int NULL DEFAULT NULL,
  `read_times_before_comfirm` int NULL DEFAULT NULL,
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `port` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `data_bit` int NULL DEFAULT NULL,
  `baud_rate` int NULL DEFAULT NULL,
  `stop_bit` int NULL DEFAULT NULL,
  `check_digit` int NULL DEFAULT NULL,
  `buffer` int NULL DEFAULT NULL,
  `Continuous_weighing` tinyint NULL DEFAULT NULL,
  `Tips_comfirm` tinyint NULL DEFAULT NULL,
  `With_cash_box` tinyint NULL DEFAULT NULL,
  `With_printer` tinyint NULL DEFAULT NULL,
  `Model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_pc_scale_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_permission
-- ----------------------------
DROP TABLE IF EXISTS `sc_permission`;
CREATE TABLE `sc_permission`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `show_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `modified_time` datetime NULL DEFAULT NULL,
  `permission_status` int NULL DEFAULT NULL,
  `showed` tinyint NULL DEFAULT NULL,
  `permission_type_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `permission_type_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_permission_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3637 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_permission_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_permission_type`;
CREATE TABLE `sc_permission_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `show_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `super_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `showed` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_permission_type_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 140 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_plan_shop_in_mall
-- ----------------------------
DROP TABLE IF EXISTS `sc_plan_shop_in_mall`;
CREATE TABLE `sc_plan_shop_in_mall`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `distribution_plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Distribution_plan_code` bigint NULL DEFAULT NULL,
  `Owner_shop_id` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_plan_shop_in_mall_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_plan_time_in_mall
-- ----------------------------
DROP TABLE IF EXISTS `sc_plan_time_in_mall`;
CREATE TABLE `sc_plan_time_in_mall`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `distribution_plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `begin_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Distribution_plan_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_plan_time_in_mall_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_platform_member
-- ----------------------------
DROP TABLE IF EXISTS `sc_platform_member`;
CREATE TABLE `sc_platform_member`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `gzh_openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nick_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `avatarurl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bak1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bak2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_platform_member_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_pos_dev
-- ----------------------------
DROP TABLE IF EXISTS `sc_pos_dev`;
CREATE TABLE `sc_pos_dev`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `shop_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `name_of_computer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pwd_for_login` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `secret_key_for_communicate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `code_for_unlock` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `last_online_time` datetime NULL DEFAULT NULL,
  `online` tinyint NULL DEFAULT NULL,
  `last_time_of_dish_upg` datetime NULL DEFAULT NULL,
  `type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ver_of_interface` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ver_of_pos` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Descname_of_computer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_pos_dev_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 140 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_pos_dev_and_queue
-- ----------------------------
DROP TABLE IF EXISTS `sc_pos_dev_and_queue`;
CREATE TABLE `sc_pos_dev_and_queue`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `pos_dev` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pos_dev_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `queue_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_pos_dev_and_queue_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_powerbank_box_id
-- ----------------------------
DROP TABLE IF EXISTS `sc_powerbank_box_id`;
CREATE TABLE `sc_powerbank_box_id`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `crt_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_powerbank_box_id_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_powerbank_id
-- ----------------------------
DROP TABLE IF EXISTS `sc_powerbank_id`;
CREATE TABLE `sc_powerbank_id`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `crt_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_powerbank_id_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8635 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_printer
-- ----------------------------
DROP TABLE IF EXISTS `sc_printer`;
CREATE TABLE `sc_printer`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `pos_dev` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pos_dev_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `port` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `with_cash_box` tinyint NULL DEFAULT NULL,
  `Paper_width` decimal(19, 10) NULL DEFAULT NULL,
  `Paper_high` decimal(19, 10) NULL DEFAULT NULL,
  `Top_margin` decimal(19, 10) NULL DEFAULT NULL,
  `Bottom_margin` decimal(19, 10) NULL DEFAULT NULL,
  `Left_margin` decimal(19, 10) NULL DEFAULT NULL,
  `Right_margin` decimal(19, 10) NULL DEFAULT NULL,
  `Baud_rate` int NULL DEFAULT NULL,
  `Data_bits` int NULL DEFAULT NULL,
  `Stop_bits` int NULL DEFAULT NULL,
  `Blank_line_num` int NULL DEFAULT NULL,
  `Flow_control` int NULL DEFAULT NULL,
  `Beep` tinyint NULL DEFAULT NULL,
  `Can_prn_label` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `PrinterPurpose` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_printer_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_printer_and_queue
-- ----------------------------
DROP TABLE IF EXISTS `sc_printer_and_queue`;
CREATE TABLE `sc_printer_and_queue`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `printer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `printer_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `queue_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `stand_by` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_printer_and_queue_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_printer_queue
-- ----------------------------
DROP TABLE IF EXISTS `sc_printer_queue`;
CREATE TABLE `sc_printer_queue`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `pos_dev` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pos_dev_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_printer_queue_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_prn_label_setting
-- ----------------------------
DROP TABLE IF EXISTS `sc_prn_label_setting`;
CREATE TABLE `sc_prn_label_setting`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `label_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `paper_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `num_of_line` int NULL DEFAULT NULL,
  `row_space` decimal(19, 10) NULL DEFAULT NULL,
  `col_space` decimal(19, 10) NULL DEFAULT NULL,
  `width` decimal(19, 10) NULL DEFAULT NULL,
  `height` decimal(19, 10) NULL DEFAULT NULL,
  `width_of_line` decimal(19, 10) NULL DEFAULT NULL,
  `height_of_line` decimal(19, 10) NULL DEFAULT NULL,
  `top_margin` decimal(19, 10) NULL DEFAULT NULL,
  `left_margin` decimal(19, 10) NULL DEFAULT NULL,
  `width_of_barcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `prn_border` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Typeface` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Typeface_size` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_prn_label_setting_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_prn_label_setting_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_prn_label_setting_item`;
CREATE TABLE `sc_prn_label_setting_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `setting` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `settint_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `item_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `content_1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `align_1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `width_1` int NULL DEFAULT NULL,
  `content_2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `align_2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `width_2` int NULL DEFAULT NULL,
  `content_3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `align_3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `width_3` int NULL DEFAULT NULL,
  `content_4` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `align_4` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `width_4` int NULL DEFAULT NULL,
  `content_5` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `align_5` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `width_5` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Item_typeface` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Item_typeface_size` int NULL DEFAULT NULL,
  `Content_type_1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Content_type_2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Content_type_3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Content_type_4` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Content_type_5` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_prn_label_setting_item_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_product_price
-- ----------------------------
DROP TABLE IF EXISTS `sc_product_price`;
CREATE TABLE `sc_product_price`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `product` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `price` decimal(19, 10) NULL DEFAULT NULL,
  `Duration` decimal(19, 10) NULL DEFAULT NULL,
  `Owner_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Owner_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Init_price` decimal(19, 10) NULL DEFAULT NULL,
  `Renew_cost_price` decimal(19, 10) NULL DEFAULT NULL,
  `Shop_pay_price` decimal(19, 10) NULL DEFAULT NULL,
  `Show_order` int NULL DEFAULT NULL,
  `Product_price_set` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Product_price_set_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_product_price_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_product_price_set
-- ----------------------------
DROP TABLE IF EXISTS `sc_product_price_set`;
CREATE TABLE `sc_product_price_set`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `show_order` int NULL DEFAULT NULL,
  `def` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_product_price_set_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_qr_bind
-- ----------------------------
DROP TABLE IF EXISTS `sc_qr_bind`;
CREATE TABLE `sc_qr_bind`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `qrcodekey` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qrcodevalue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `crttime` datetime NULL DEFAULT NULL,
  `bindshopname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bindzuotai` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bindusertaiid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bindtime` datetime NULL DEFAULT NULL,
  `dantype` int NULL DEFAULT NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `BusinessType` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `AppType` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `XcxQrCodeUrl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `GzhQrCodeUrl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sun_code_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '小程序太阳码',
  `h5_code_url` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'h5二维码',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_qr_bind_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_key`(`company_id` ASC, `qrcodekey`(191) ASC) USING BTREE,
  INDEX `idx_mid_value`(`company_id` ASC, `qrcodevalue`(191) ASC) USING BTREE,
  INDEX `idx_mid_sid_bid`(`company_id` ASC, `shop_id` ASC, `bindusertaiid`(191) ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17685 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_qr_code
-- ----------------------------
DROP TABLE IF EXISTS `sc_qr_code`;
CREATE TABLE `sc_qr_code`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `qrcodetype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qrcodekey` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `crttime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_qr_code_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 116252 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_recommend_dish_in_mall
-- ----------------------------
DROP TABLE IF EXISTS `sc_recommend_dish_in_mall`;
CREATE TABLE `sc_recommend_dish_in_mall`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dish` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Type_code` bigint NULL DEFAULT NULL,
  `Dish_code` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_recommend_dish_in_mall_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_reg_dog
-- ----------------------------
DROP TABLE IF EXISTS `sc_reg_dog`;
CREATE TABLE `sc_reg_dog`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ver` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `maketime` datetime NULL DEFAULT NULL,
  `firsttimewriteshopinfo` datetime NULL DEFAULT NULL,
  `overtime` datetime NULL DEFAULT NULL,
  `zhucejilu` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pcnum` int NULL DEFAULT NULL,
  `dcbnum` int NULL DEFAULT NULL,
  `azpbnum` int NULL DEFAULT NULL,
  `azsjnum` int NULL DEFAULT NULL,
  `ipadnum` int NULL DEFAULT NULL,
  `zzdcnum` int NULL DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `district` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shopname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shopaddr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shopphone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pc_hylsnum` int NULL DEFAULT NULL,
  `pc_lspsnum` int NULL DEFAULT NULL,
  `pc_lsbbnum` int NULL DEFAULT NULL,
  `pwd` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `needsync` tinyint NULL DEFAULT NULL,
  `needsyncforce` tinyint NULL DEFAULT NULL,
  `notneedflag` tinyint NULL DEFAULT NULL,
  `Renew_amount` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_reg_dog_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `sc_reg_dog_id_IDX`(`id` ASC) USING BTREE,
  INDEX `sc_reg_dog_name_IDX`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23064 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_reg_dog_delivery_record
-- ----------------------------
DROP TABLE IF EXISTS `sc_reg_dog_delivery_record`;
CREATE TABLE `sc_reg_dog_delivery_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `crttime` datetime NULL DEFAULT NULL,
  `jinbanren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `refflag` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_reg_dog_delivery_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_reg_dog_delivery_record_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_reg_dog_delivery_record_item`;
CREATE TABLE `sc_reg_dog_delivery_record_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `record_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ver` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `maketime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_reg_dog_delivery_record_item_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_reg_dog_recharge_record
-- ----------------------------
DROP TABLE IF EXISTS `sc_reg_dog_recharge_record`;
CREATE TABLE `sc_reg_dog_recharge_record`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `crttime` datetime NULL DEFAULT NULL,
  `jinbanren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `inst_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jine` decimal(19, 10) NULL DEFAULT NULL,
  `pcnum` int NULL DEFAULT NULL,
  `pcnumq` int NULL DEFAULT NULL,
  `pcnumh` int NULL DEFAULT NULL,
  `pc_lsnum` int NULL DEFAULT NULL,
  `pc_lsnumq` int NULL DEFAULT NULL,
  `pc_lsnumh` int NULL DEFAULT NULL,
  `pc_ftnum` int NULL DEFAULT NULL,
  `pc_ftnumq` int NULL DEFAULT NULL,
  `pc_ftnumh` int NULL DEFAULT NULL,
  `pc_zynum` int NULL DEFAULT NULL,
  `pc_zynumq` int NULL DEFAULT NULL,
  `pc_zynumh` int NULL DEFAULT NULL,
  `pc_ywnum` int NULL DEFAULT NULL,
  `pc_ywnumq` int NULL DEFAULT NULL,
  `pc_ywnumh` int NULL DEFAULT NULL,
  `dcbnum` int NULL DEFAULT NULL,
  `dcbnumq` int NULL DEFAULT NULL,
  `dcbnumh` int NULL DEFAULT NULL,
  `azpbnum` int NULL DEFAULT NULL,
  `azpbnumq` int NULL DEFAULT NULL,
  `azpbnumh` int NULL DEFAULT NULL,
  `azsjnum` int NULL DEFAULT NULL,
  `azsjnumq` int NULL DEFAULT NULL,
  `azsjnumh` int NULL DEFAULT NULL,
  `ipadnum` int NULL DEFAULT NULL,
  `ipadnumq` int NULL DEFAULT NULL,
  `ipadnumh` int NULL DEFAULT NULL,
  `zzdcnum` int NULL DEFAULT NULL,
  `zzdcnumq` int NULL DEFAULT NULL,
  `zzdcnumh` int NULL DEFAULT NULL,
  `pc_hylsnum` int NULL DEFAULT NULL,
  `pc_hylsnumq` int NULL DEFAULT NULL,
  `pc_hylsnumh` int NULL DEFAULT NULL,
  `pc_lspsnum` int NULL DEFAULT NULL,
  `pc_lspsnumq` int NULL DEFAULT NULL,
  `pc_lspsnumh` int NULL DEFAULT NULL,
  `pc_lsbbnum` int NULL DEFAULT NULL,
  `pc_lsbbnumq` int NULL DEFAULT NULL,
  `pc_lsbbnumh` int NULL DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `refflag` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `yijinhuikuang` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_reg_dog_recharge_record_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_reg_dog_recharge_record_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_return_reason
-- ----------------------------
DROP TABLE IF EXISTS `sc_return_reason`;
CREATE TABLE `sc_return_reason`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_return_reason_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `sc_role_permission`;
CREATE TABLE `sc_role_permission`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `permission_lmnid` bigint NULL DEFAULT NULL,
  `role_lmnid` bigint NULL DEFAULT NULL,
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `modified_time` datetime NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Permission_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_role_permission_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5085 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_roles
-- ----------------------------
DROP TABLE IF EXISTS `sc_roles`;
CREATE TABLE `sc_roles`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `create_opr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `modified_time` datetime NULL DEFAULT NULL,
  `modified_opr` datetime NULL DEFAULT NULL,
  `role_status` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Clerk_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Parent_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Staff_number_prefix` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Pos_give_pwd` tinyint NULL DEFAULT NULL,
  `Clerk_sort` int NULL DEFAULT NULL,
  `Charge_limit` decimal(19, 10) NULL DEFAULT NULL,
  `Parent_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Role_charge_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Role_charge_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_roles_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 159 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_scale_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_scale_type`;
CREATE TABLE `sc_scale_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `scale_brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `scale_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_scale_type_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_scale_type_para
-- ----------------------------
DROP TABLE IF EXISTS `sc_scale_type_para`;
CREATE TABLE `sc_scale_type_para`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `scale_type_lmnid` bigint NULL DEFAULT NULL,
  `scale_type_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `scale_lmnid` bigint NULL DEFAULT NULL,
  `strval` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strval2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `strval3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `intval` int NULL DEFAULT NULL,
  `boolval` tinyint NULL DEFAULT NULL,
  `doubleval` decimal(19, 10) NULL DEFAULT NULL,
  `dateval` datetime NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_scale_type_para_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_secondary_screen_img
-- ----------------------------
DROP TABLE IF EXISTS `sc_secondary_screen_img`;
CREATE TABLE `sc_secondary_screen_img`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `idx` int NULL DEFAULT NULL,
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_secondary_screen_img_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_secondary_screen_video
-- ----------------------------
DROP TABLE IF EXISTS `sc_secondary_screen_video`;
CREATE TABLE `sc_secondary_screen_video`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `idx` int NULL DEFAULT NULL,
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_secondary_screen_video_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_shipping_addr
-- ----------------------------
DROP TABLE IF EXISTS `sc_shipping_addr`;
CREATE TABLE `sc_shipping_addr`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `fans` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `longitude` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `latitude` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `landmark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `district` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `district_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `detail_addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_person` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `label` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `default_addr` tinyint NULL DEFAULT NULL,
  `Fans_member_id` bigint NULL DEFAULT NULL,
  `Fans_unionid` bigint NULL DEFAULT NULL,
  `Fans_openid` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_shipping_addr_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_shop_in_company_dishs
-- ----------------------------
DROP TABLE IF EXISTS `sc_shop_in_company_dishs`;
CREATE TABLE `sc_shop_in_company_dishs`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `release_status` int NULL DEFAULT NULL,
  `release_rule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `company_dishs` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `company_dishs_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `releaseed` tinyint NULL DEFAULT NULL,
  `release_time` datetime NULL DEFAULT NULL,
  `enable_time` datetime NULL DEFAULT NULL,
  `publish_job` bigint NULL DEFAULT NULL,
  `cancel_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_shop_in_company_dishs_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_shop_in_company_pay_way
-- ----------------------------
DROP TABLE IF EXISTS `sc_shop_in_company_pay_way`;
CREATE TABLE `sc_shop_in_company_pay_way`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `release_status` int NULL DEFAULT NULL,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `release_rule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `company_pay_way` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `company_pay_way_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `company_pay_way_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `releaseed` tinyint NULL DEFAULT NULL,
  `release_time` datetime NULL DEFAULT NULL,
  `enable_time` datetime NULL DEFAULT NULL,
  `publish_job` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_shop_in_company_pay_way_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_shop_in_marketing_plan
-- ----------------------------
DROP TABLE IF EXISTS `sc_shop_in_marketing_plan`;
CREATE TABLE `sc_shop_in_marketing_plan`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `store` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `store_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `plan_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_shop_in_marketing_plan_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_st_account_period
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_account_period`;
CREATE TABLE `sc_st_account_period`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `begin_date` datetime NULL DEFAULT NULL,
  `end_date` datetime NULL DEFAULT NULL,
  `post_date` datetime NULL DEFAULT NULL,
  `posted` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_account_period_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_st_bill
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_bill`;
CREATE TABLE `sc_st_bill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `out_department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comments` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `maker` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `client` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `supplier` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `manager` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `make_time` datetime NULL DEFAULT NULL,
  `post_time` datetime NULL DEFAULT NULL,
  `poster` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `posted` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `post_id` bigint NULL DEFAULT NULL,
  `last_mode_time` datetime NULL DEFAULT NULL,
  `total_amount` decimal(19, 10) NULL DEFAULT NULL,
  `total_volume` decimal(19, 10) NULL DEFAULT NULL,
  `ref_flag` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `out_warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `org_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shipper` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `consignee` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `in_out_flag_of_warehouse` int NULL DEFAULT NULL,
  `in_out_flag_of_department` int NULL DEFAULT NULL,
  `aotu_maked` tinyint NULL DEFAULT NULL,
  `check_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `book_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `account_period` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `delivery_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xfd_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `printed_count` int NULL DEFAULT NULL,
  `settlement_person` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `settlement_time` datetime NULL DEFAULT NULL,
  `have_settlement_amount` decimal(19, 10) NULL DEFAULT NULL,
  `Department_code` bigint NULL DEFAULT NULL,
  `Out_department_code` bigint NULL DEFAULT NULL,
  `Maker_code` bigint NULL DEFAULT NULL,
  `Client_code` bigint NULL DEFAULT NULL,
  `Supplier_code` bigint NULL DEFAULT NULL,
  `Manager_code` bigint NULL DEFAULT NULL,
  `Poster_code` bigint NULL DEFAULT NULL,
  `Warehouse_code` bigint NULL DEFAULT NULL,
  `Out_warehouse_code` bigint NULL DEFAULT NULL,
  `Account_period_code` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `In_department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `In_department_code` bigint NULL DEFAULT NULL,
  `In_warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `In_warehouse_code` bigint NULL DEFAULT NULL,
  `manual_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手工单号',
  `keeper` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '库管员',
  `applicant` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '申请人',
  `purchase_order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '采购订单号',
  `organization` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '录入机构',
  `organization_code` bigint NULL DEFAULT NULL COMMENT '录入机构编号',
  `arrival_time` datetime NULL DEFAULT NULL COMMENT '到货日期',
  `applicant_code` bigint NULL DEFAULT NULL COMMENT '申请人编号',
  `keeper_code` bigint NULL DEFAULT NULL COMMENT '库管员编号',
  `updater_code` bigint NULL DEFAULT NULL COMMENT '修改人编号',
  `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '修改人编号',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改人编号',
  `in_bill_code` bigint NULL DEFAULT NULL COMMENT '入库仓库单据编号',
  `out_bill_code` bigint NULL DEFAULT NULL COMMENT '出库仓库单据编号',
  `org_bill_code` bigint NULL DEFAULT NULL COMMENT '原仓库单据编号',
  `order_src` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '业务单来源',
  `relate_bill_code` bigint NULL DEFAULT NULL COMMENT '关联单据编号',
  `purchaser_merchant_id` bigint NULL DEFAULT NULL COMMENT '采购商商户号',
  `shipment_bill_code` bigint NULL DEFAULT NULL COMMENT '关联的发货单编号',
  `receipt_bill_code` bigint NULL DEFAULT NULL COMMENT '关联的收货单编号',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_bill_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_st_bill_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_st_bill_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_bill_item`;
CREATE TABLE `sc_st_bill_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `big_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `small_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `standard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `volume` decimal(19, 10) NULL DEFAULT NULL,
  `def_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `actual_volume` decimal(19, 10) NULL DEFAULT NULL,
  `total_volume` decimal(19, 10) NULL DEFAULT NULL,
  `price` decimal(19, 10) NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `base_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `volume_of_base_unit` decimal(19, 10) NULL DEFAULT NULL,
  `price_of_base_unit` decimal(19, 10) NULL DEFAULT NULL,
  `comments` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `barcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `old_price` decimal(19, 10) NULL DEFAULT NULL,
  `new_price` decimal(19, 10) NULL DEFAULT NULL,
  `warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `beginning_volume_of_warhouse` decimal(19, 10) NULL DEFAULT NULL,
  `beginning_amount_of_warhouse` decimal(19, 10) NULL DEFAULT NULL,
  `int_volume_of_warhouse` decimal(19, 10) NULL DEFAULT NULL,
  `in_amount_of_warhouse` decimal(19, 10) NULL DEFAULT NULL,
  `out_volume_of_warhouse` decimal(19, 10) NULL DEFAULT NULL,
  `out_amount_of_warhouse` decimal(19, 10) NULL DEFAULT NULL,
  `ending_volume_of_warhouse` decimal(19, 10) NULL DEFAULT NULL,
  `ending_amount_of_warhouse` decimal(19, 10) NULL DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `beginning_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `beginning_amount_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `int_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `in_amount_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `out_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `out_amount_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `ending_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `ending_amount_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `Bill_type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Make_time` datetime NULL DEFAULT NULL,
  `Post_time` datetime NULL DEFAULT NULL,
  `Beginning_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `Beginning_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `In_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `In_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `Out_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `Out_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `Ending_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `Ending_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `In_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `St_bill_code` bigint NULL DEFAULT NULL,
  `Big_type_code` bigint NULL DEFAULT NULL,
  `Small_type_code` bigint NULL DEFAULT NULL,
  `Goods_code` bigint NULL DEFAULT NULL,
  `Warehouse_code` bigint NULL DEFAULT NULL,
  `Department_code` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Is_reduce` int NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_bill_item_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_st_bill_item_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_st_check_bill
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_check_bill`;
CREATE TABLE `sc_st_check_bill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `begin_date` datetime NULL DEFAULT NULL,
  `end_date` datetime NULL DEFAULT NULL,
  `manager` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `maker` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `account_period` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `check_for_beginning` tinyint NULL DEFAULT NULL,
  `check_for_month_end` tinyint NULL DEFAULT NULL,
  `finished` tinyint NULL DEFAULT NULL,
  `Warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Manager_code` bigint NULL DEFAULT NULL,
  `Maker_code` bigint NULL DEFAULT NULL,
  `Warehouse_code` bigint NULL DEFAULT NULL,
  `Department_code` bigint NULL DEFAULT NULL,
  `Account_period_code` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_check_bill_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_st_check_bill_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_st_check_bill_item
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_check_bill_item`;
CREATE TABLE `sc_st_check_bill_item`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `big_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `small_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `standard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `volume` decimal(19, 10) NULL DEFAULT NULL,
  `price` decimal(19, 10) NULL DEFAULT NULL,
  `real_volume` decimal(19, 10) NULL DEFAULT NULL,
  `real_amount` decimal(19, 10) NULL DEFAULT NULL,
  `org_volume` decimal(19, 10) NULL DEFAULT NULL,
  `org_amount` decimal(19, 10) NULL DEFAULT NULL,
  `volmun_of_rofitand_loss` decimal(19, 10) NULL DEFAULT NULL,
  `amount_of_rofitand_loss` decimal(19, 10) NULL DEFAULT NULL,
  `Real_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Check_bill_id` bigint NULL DEFAULT NULL,
  `Big_type_code` bigint NULL DEFAULT NULL,
  `Small_type_code` bigint NULL DEFAULT NULL,
  `Goods_code` bigint NULL DEFAULT NULL,
  `Amount` decimal(19, 10) NULL DEFAULT NULL,
  `Org_price` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_check_bill_item_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_st_check_bill_item_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_st_convert_bill
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_convert_bill`;
CREATE TABLE `sc_st_convert_bill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `comments` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `maker` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `manager` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `make_time` datetime NULL DEFAULT NULL,
  `post_time` datetime NULL DEFAULT NULL,
  `poster` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `posted` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `post_id` int NULL DEFAULT NULL,
  `last_mode_time` datetime NULL DEFAULT NULL,
  `total_amount` decimal(19, 10) NULL DEFAULT NULL,
  `total_volume` decimal(19, 10) NULL DEFAULT NULL,
  `ref_flag` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `org_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `aotu_maked` tinyint NULL DEFAULT NULL,
  `check_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `book_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `account_period` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `delivery_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xfd_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `printed_count` int NULL DEFAULT NULL,
  `Department_code` bigint NULL DEFAULT NULL,
  `Maker_code` bigint NULL DEFAULT NULL,
  `Manager_code` bigint NULL DEFAULT NULL,
  `Poster_code` bigint NULL DEFAULT NULL,
  `Warehouse_code` bigint NULL DEFAULT NULL,
  `Account_period_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_convert_bill_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_st_convert_bill_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_st_convert_bill_item_in
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_convert_bill_item_in`;
CREATE TABLE `sc_st_convert_bill_item_in`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `make_time` datetime NULL DEFAULT NULL,
  `post_time` datetime NULL DEFAULT NULL,
  `big_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `small_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `standard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `volume` decimal(19, 10) NULL DEFAULT NULL,
  `def_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `actual_volume` decimal(19, 10) NULL DEFAULT NULL,
  `total_volume` decimal(19, 10) NULL DEFAULT NULL,
  `price` decimal(19, 10) NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `base_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `volume_of_base_unit` decimal(19, 10) NULL DEFAULT NULL,
  `price_of_base_unit` decimal(19, 10) NULL DEFAULT NULL,
  `barcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `old_price` decimal(19, 10) NULL DEFAULT NULL,
  `new_price` decimal(19, 10) NULL DEFAULT NULL,
  `warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `beginning_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `beginning_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `in_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `in_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `out_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `out_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `ending_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `ending_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `beginning_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `beginning_amount_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `in_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `in_amount_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `out_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `out_amount_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `ending_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `ending_amount_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `comments` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `St_bill_code` bigint NULL DEFAULT NULL,
  `Big_type_code` bigint NULL DEFAULT NULL,
  `Small_type_code` bigint NULL DEFAULT NULL,
  `Goods_code` bigint NULL DEFAULT NULL,
  `Warehouse_code` bigint NULL DEFAULT NULL,
  `Department_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_convert_bill_item_in_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_st_convert_bill_item_in_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_st_convert_bill_item_out
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_convert_bill_item_out`;
CREATE TABLE `sc_st_convert_bill_item_out`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `make_time` datetime NULL DEFAULT NULL,
  `post_time` datetime NULL DEFAULT NULL,
  `big_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `small_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `standard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `volume` decimal(19, 10) NULL DEFAULT NULL,
  `def_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `actual_volume` decimal(19, 10) NULL DEFAULT NULL,
  `total_volume` decimal(19, 10) NULL DEFAULT NULL,
  `price` decimal(19, 10) NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `base_unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `volume_of_base_unit` decimal(19, 10) NULL DEFAULT NULL,
  `price_of_base_unit` decimal(19, 10) NULL DEFAULT NULL,
  `barcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `old_price` decimal(19, 10) NULL DEFAULT NULL,
  `new_price` decimal(19, 10) NULL DEFAULT NULL,
  `warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `beginning_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `beginning_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `in_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `in_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `out_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `out_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `ending_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `ending_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `beginning_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `beginning_amount_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `in_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `in_amount_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `out_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `out_amount_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `ending_volume_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `ending_amount_of_department` decimal(19, 10) NULL DEFAULT NULL,
  `comments` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `St_bill_code` bigint NULL DEFAULT NULL,
  `Big_type_code` bigint NULL DEFAULT NULL,
  `Small_type_code` bigint NULL DEFAULT NULL,
  `Goods_code` bigint NULL DEFAULT NULL,
  `Warehouse_code` bigint NULL DEFAULT NULL,
  `Department_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_convert_bill_item_out_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_st_convert_bill_item_out_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_st_goods_day_book
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_goods_day_book`;
CREATE TABLE `sc_st_goods_day_book`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` bigint NULL DEFAULT NULL COMMENT '原始单据编号',
  `lmnid` bigint NOT NULL COMMENT 'lmn内部编号',
  `yingyeriqi` datetime NULL DEFAULT NULL COMMENT '营业日期',
  `year` int NULL DEFAULT NULL COMMENT '年',
  `month` int NULL DEFAULT NULL COMMENT '月',
  `day` int NULL DEFAULT NULL COMMENT '日',
  `bill_type_` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '票据类型',
  `st_bill_code` bigint NULL DEFAULT NULL COMMENT '仓库单据编号',
  `make_time` datetime NULL DEFAULT NULL COMMENT '开票时间',
  `post_time` datetime NULL DEFAULT NULL COMMENT '过帐日期',
  `type_code` bigint NULL DEFAULT NULL COMMENT '物品类别编号',
  `goods_code` bigint NULL DEFAULT NULL COMMENT '物品编号',
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品名称',
  `standard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规格',
  `actual_volume` decimal(19, 10) NULL DEFAULT NULL COMMENT '到货数量（用于采购订货）',
  `unit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '单位',
  `volume` decimal(19, 10) NULL DEFAULT NULL COMMENT '数量',
  `price` decimal(19, 10) NULL DEFAULT NULL COMMENT '单价',
  `amount` decimal(24, 6) NULL DEFAULT NULL COMMENT '金额',
  `old_price` decimal(19, 10) NULL DEFAULT NULL COMMENT '原库存价',
  `new_price` decimal(19, 10) NULL DEFAULT NULL COMMENT '新库存价',
  `warehouse_code` bigint NULL DEFAULT NULL COMMENT '仓库编号',
  `beginning_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库期初数量',
  `beginning_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库期初金额',
  `in_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库收入数量',
  `in_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库收入金额',
  `out_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库发出数量',
  `out_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库发出金额',
  `ending_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库结存数量',
  `ending_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库结存金额',
  `comments` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `client_code` bigint NULL DEFAULT NULL COMMENT '客户编号',
  `supplier_code` bigint NULL DEFAULT NULL COMMENT '供应商编号',
  `status_` int NULL DEFAULT NULL,
  `st_bill_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '仓库单据id',
  `base_unit` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '基本单位',
  `volume_of_base_unit` decimal(19, 10) NULL DEFAULT NULL COMMENT '基本数量',
  `price_of_base_unit` decimal(19, 10) NULL DEFAULT NULL COMMENT '基本单价',
  `bill_date` datetime NULL DEFAULT NULL COMMENT '开票日期',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_goods_day_book_COMPANY_LmnID`(`company_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_st_goods_day_book_COMPANY_YYRQ`(`company_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8528 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_st_goods_summary
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_goods_summary`;
CREATE TABLE `sc_st_goods_summary`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL COMMENT 'lmn内部编号',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '仓库业务单中的商品明细名称',
  `status_` int NULL DEFAULT NULL COMMENT '记录状态',
  `period_id` bigint NULL DEFAULT NULL COMMENT '会计周期',
  `period` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '会计名称',
  `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品类型名称',
  `type_id` bigint NULL DEFAULT NULL COMMENT '类型编号',
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品名称',
  `goods_id` bigint NULL DEFAULT NULL COMMENT '物品编号',
  `item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品货号',
  `standard` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '规格',
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '单位',
  `volume` decimal(19, 10) NULL DEFAULT NULL COMMENT '数量',
  `price` decimal(19, 10) NULL DEFAULT NULL COMMENT '单价',
  `amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '金额',
  `barcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '条码',
  `warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '仓库',
  `warehouse_id` bigint NULL DEFAULT NULL COMMENT '仓库编号',
  `beginning_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库期初数量',
  `beginning_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库期初金额',
  `in_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库收入数量',
  `in_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库收入金额',
  `out_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库发出数量',
  `out_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库发出金额',
  `ending_volume_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库结存数量',
  `ending_amount_of_warehouse` decimal(19, 10) NULL DEFAULT NULL COMMENT '仓库结存金额',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_goods_summary_COMPANY_LmnID`(`company_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_st_goods_summary_COMPANY_period_id`(`company_id` ASC, `period_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8525 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sc_st_item_change
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_item_change`;
CREATE TABLE `sc_st_item_change`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `xiafeicaipingid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shopname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiafeicaipingname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaoleiid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaolei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `daleiid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dalei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `danwei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jibendanwei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `danweibilv` decimal(19, 10) NULL DEFAULT NULL,
  `jiage` decimal(19, 10) NULL DEFAULT NULL,
  `diancaishijian` datetime NULL DEFAULT NULL,
  `subed` tinyint NULL DEFAULT NULL,
  `caipingtype` int NULL DEFAULT NULL,
  `item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `autosale` tinyint NULL DEFAULT NULL,
  `st_bill_code` bigint NULL DEFAULT NULL,
  `upload` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Xfcp_lmnid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Upload_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_item_change_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_st_item_change_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_st_item_change_fjz
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_item_change_fjz`;
CREATE TABLE `sc_st_item_change_fjz`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `xiafeicaipingid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shopname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiafeicaipingname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaoleiid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaolei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `daleiid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dalei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `danwei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jibendanwei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `danweibilv` decimal(19, 10) NULL DEFAULT NULL,
  `jiage` decimal(19, 10) NULL DEFAULT NULL,
  `diancaishijian` datetime NULL DEFAULT NULL,
  `baoshunshuliang` decimal(19, 10) NULL DEFAULT NULL,
  `subed` tinyint NULL DEFAULT NULL,
  `caipingtype` int NULL DEFAULT NULL,
  `item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `autosale` tinyint NULL DEFAULT NULL,
  `st_bill_code` bigint NULL DEFAULT NULL,
  `upload` tinyint NULL DEFAULT NULL,
  `dealed` tinyint NULL DEFAULT NULL,
  `deal_time` datetime NULL DEFAULT NULL,
  `deal_opr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `deal_opr_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Xfcp_lmnid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_item_change_fjz_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_st_item_change_fjz_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_st_unit
-- ----------------------------
DROP TABLE IF EXISTS `sc_st_unit`;
CREATE TABLE `sc_st_unit`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_st_unit_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 127 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_store
-- ----------------------------
DROP TABLE IF EXISTS `sc_store`;
CREATE TABLE `sc_store`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `brand_code` bigint NULL DEFAULT NULL COMMENT '品牌lid',
  `grp` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `grp_code` bigint NULL DEFAULT NULL COMMENT '旧版的所属分组编号',
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operation_model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `business_model` int NULL DEFAULT NULL COMMENT '运营模式',
  `business_begin_time` datetime NULL DEFAULT NULL,
  `business_end_time` datetime NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `principal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `addr_map` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `longitude` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `latitude` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `placard` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '店铺公告',
  `business_manager` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `business_license_img` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `business_license_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `legal_representative` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `business_license_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `place_of_business` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `registered_capital` decimal(19, 10) NULL DEFAULT NULL,
  `registered_date` datetime NULL DEFAULT NULL,
  `registration_authority` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `operating_period` datetime NULL DEFAULT NULL,
  `approval_date` datetime NULL DEFAULT NULL,
  `business_scope` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `license` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `boss_certificate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `licensed_documents` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `food_safety_quantitative_classification` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sys_init_pwd` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Detailed_scope` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Score` decimal(19, 10) NULL DEFAULT NULL,
  `Enable_mall` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Mall_begin_time` datetime NULL DEFAULT NULL,
  `Mall_end_time` datetime NULL DEFAULT NULL,
  `Mall_status` tinyint NULL DEFAULT NULL,
  `SYSType` int NULL DEFAULT NULL,
  `Over_time` datetime NULL DEFAULT NULL,
  `Over_year` int NULL DEFAULT NULL,
  `Over_month` int NULL DEFAULT NULL,
  `Over_day` int NULL DEFAULT NULL,
  `Renew_amount` decimal(19, 10) NULL DEFAULT NULL,
  `Book_status` tinyint NULL DEFAULT NULL,
  `Crt_time` datetime NULL DEFAULT NULL,
  `Creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Inst_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Inst_adm` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Inst_adm_code` bigint NULL DEFAULT NULL,
  `Inst_adm_tech` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Inst_adm_tech_code` bigint NULL DEFAULT NULL,
  `Sync_from_old` tinyint NULL DEFAULT NULL,
  `Over_time_in_plat` datetime NULL DEFAULT NULL,
  `Over_year_in_plat` int NULL DEFAULT NULL,
  `Over_month_in_plat` int NULL DEFAULT NULL,
  `Over_day_in_plat` int NULL DEFAULT NULL,
  `can_dao_store_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '餐道店铺id',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  `organization_type` int NULL DEFAULT 1 COMMENT '组织类型',
  `rdc_lid` bigint NULL DEFAULT NULL COMMENT '配送中心lid',
  `rdc_examine` tinyint(1) NULL DEFAULT NULL COMMENT '配送中心审核订单',
  `to_examine_submit` tinyint(1) NULL DEFAULT NULL COMMENT '门店审核订货单时同时提交',
  `check_in_multi_spec` tinyint(1) NULL DEFAULT NULL COMMENT '门店多规格盘点',
  `self_built_goods` tinyint(1) NULL DEFAULT NULL COMMENT '门店自建物品',
  `show_stock_check_in` tinyint(1) NULL DEFAULT NULL COMMENT '盘点显示账面库存',
  `receiver` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人',
  `receiver_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货人联系方式',
  `receiver_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收货地址',
  `number_of_item` int NULL DEFAULT NULL,
  `number_of_supplier` int NULL DEFAULT NULL,
  `number_of_delivery` int NULL DEFAULT NULL,
  `number_of_supplier_price` int NULL DEFAULT NULL,
  `number_of_delivery_price` int NULL DEFAULT NULL,
  `show_in_order` tinyint(1) NOT NULL DEFAULT 1 COMMENT '可用于扫码点餐',
  `maolink_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '数字价签key',
  `maolink_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '数字价签秘钥',
  `latest_online_time` datetime NULL DEFAULT NULL,
  `server_ip` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '服务器ip',
  `server_ver` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '服务器版本',
  `server_ver_at` datetime NULL DEFAULT NULL COMMENT '服务器编译时间',
  `server_dev_id` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '服务器设备号',
  `server_dev_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '服务器设备名',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_store_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_id`(`id` ASC) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE,
  INDEX `sc_store_shop_id_IDX`(`shop_id` ASC) USING BTREE,
  INDEX `sc_store_latest_online_time_IDX`(`latest_online_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23055 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_store_and_product
-- ----------------------------
DROP TABLE IF EXISTS `sc_store_and_product`;
CREATE TABLE `sc_store_and_product`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `merchant_code` bigint NULL DEFAULT NULL,
  `merchant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `store_code` bigint NULL DEFAULT NULL,
  `store_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sc_inst_code` bigint NULL DEFAULT NULL,
  `sc_inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `crt_time` datetime NULL DEFAULT NULL,
  `last_update_time` datetime NULL DEFAULT NULL,
  `last_update_opr` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sys_type` int NULL DEFAULT NULL,
  `product_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `product_out_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `product_inner_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `product_amount` decimal(19, 10) NULL DEFAULT NULL,
  `cost_amt` decimal(19, 10) NULL DEFAULT NULL,
  `pay_amt` decimal(19, 10) NULL DEFAULT NULL,
  `over_time` datetime NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `Sync_from_old` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_store_and_product_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_id_type`(`company_id` ASC, `id` ASC, `product_type` ASC) USING BTREE,
  INDEX `sc_store_and_product_id_IDX`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 23781 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_store_and_product_flow
-- ----------------------------
DROP TABLE IF EXISTS `sc_store_and_product_flow`;
CREATE TABLE `sc_store_and_product_flow`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `payer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `merchant_code` bigint NULL DEFAULT NULL,
  `merchant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `store_code` bigint NULL DEFAULT NULL,
  `store_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sc_inst_code` bigint NULL DEFAULT NULL,
  `sc_inst` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `crt_time` datetime NULL DEFAULT NULL,
  `last_update_time` datetime NULL DEFAULT NULL,
  `last_update_opr` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sys_type` int NULL DEFAULT NULL,
  `product_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `product_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `product_amount_before` decimal(19, 10) NULL DEFAULT NULL,
  `product_amount` decimal(19, 10) NULL DEFAULT NULL,
  `product_amount_after` decimal(19, 10) NULL DEFAULT NULL,
  `cost_` decimal(19, 10) NULL DEFAULT NULL,
  `pay_price` decimal(19, 10) NULL DEFAULT NULL,
  `pay_amt` decimal(19, 10) NULL DEFAULT NULL,
  `pay_bill_id` bigint NULL DEFAULT NULL,
  `sc_inst_finance_bill_id` bigint NULL DEFAULT NULL,
  `over_time` int NULL DEFAULT NULL,
  `over_time_before` datetime NULL DEFAULT NULL,
  `over_time_after` datetime NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `state_` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Inst_amount_before` decimal(19, 10) NULL DEFAULT NULL,
  `Inst_amount_after` decimal(19, 10) NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_store_and_product_flow_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17005 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_store_grp
-- ----------------------------
DROP TABLE IF EXISTS `sc_store_grp`;
CREATE TABLE `sc_store_grp`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_store_grp_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_store_in_group_buy
-- ----------------------------
DROP TABLE IF EXISTS `sc_store_in_group_buy`;
CREATE TABLE `sc_store_in_group_buy`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `store` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `store_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `group_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `group_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_store_in_group_buy_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_store_in_mall_coupon
-- ----------------------------
DROP TABLE IF EXISTS `sc_store_in_mall_coupon`;
CREATE TABLE `sc_store_in_mall_coupon`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `store` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `store_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `coupon_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `tbl_type_code` bigint NULL DEFAULT NULL COMMENT '桌台类型编号',
  `tbl_type_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台类型名称',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_store_in_mall_coupon_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_store_in_time_limit_promotion
-- ----------------------------
DROP TABLE IF EXISTS `sc_store_in_time_limit_promotion`;
CREATE TABLE `sc_store_in_time_limit_promotion`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `store` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `store_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `promotion_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `promotion_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_store_in_time_limit_promotion_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_store_wx_info
-- ----------------------------
DROP TABLE IF EXISTS `sc_store_wx_info`;
CREATE TABLE `sc_store_wx_info`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `authorizer_appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `authorizer_refresh_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `app_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `func_info` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qrcode_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nick_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `service_type_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `verify_type_info` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `principal_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bridge_model` int NULL DEFAULT NULL COMMENT '对接模式',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_store_wx_info_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1073 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_supplier
-- ----------------------------
DROP TABLE IF EXISTS `sc_supplier`;
CREATE TABLE `sc_supplier`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `supplier_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `supplier_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `principal` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `creator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `county_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `enable_on_line_mall` tinyint NULL DEFAULT NULL,
  `qualification_photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `quarantine_report_photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tax_rate` decimal(19, 10) NULL DEFAULT NULL,
  `tax_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bank` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_of_bank` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `billing_period_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `expiry_day_of_qualification` datetime NULL DEFAULT NULL,
  `Remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Commit_audit_time` datetime NULL DEFAULT NULL,
  `Audit_time` datetime NULL DEFAULT NULL,
  `Reviewer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Audit_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `supplier_merchant_id` bigint NULL DEFAULT NULL COMMENT '货商商户编号',
  `supplier_shop_id` bigint NULL DEFAULT NULL COMMENT '货商店铺编号',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_supplier_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_supplier_goods
-- ----------------------------
DROP TABLE IF EXISTS `sc_supplier_goods`;
CREATE TABLE `sc_supplier_goods`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '商户号',
  `SHOP_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '门店号',
  `LMNID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `status_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '记录状态',
  `supplier` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '供应商',
  `supplier_code` bigint NULL DEFAULT NULL COMMENT '供应商编号',
  `goods` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '物品',
  `goods_code` bigint NULL DEFAULT NULL COMMENT '物品编号',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_supplier_goods_COMPANY_SHOP_LmnID`(`COMPANY_ID` ASC, `SHOP_ID` ASC, `LMNID` ASC) USING BTREE,
  INDEX `IDX_U_sc_supplier_goods_COMPANY_SHOP_supplier_code_goods_code`(`COMPANY_ID` ASC, `SHOP_ID` ASC, `supplier_code` ASC, `goods_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7258 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '供应商物品关联' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_supplier_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_supplier_type`;
CREATE TABLE `sc_supplier_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `disable` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_supplier_type_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_task
-- ----------------------------
DROP TABLE IF EXISTS `sc_task`;
CREATE TABLE `sc_task`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `planned_time` datetime NULL DEFAULT NULL,
  `queue_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_task_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 137 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_tbl
-- ----------------------------
DROP TABLE IF EXISTS `sc_tbl`;
CREATE TABLE `sc_tbl`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `area` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `orderable` tinyint NULL DEFAULT NULL,
  `hide` tinyint NULL DEFAULT NULL,
  `qrcode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Area_code` bigint NULL DEFAULT NULL,
  `Type_code` bigint NULL DEFAULT NULL,
  `Show_order` int NULL DEFAULT NULL,
  `h5_code_url` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'h5二维码',
  `min_dining_capacity` int NULL DEFAULT NULL COMMENT '就餐最小人数',
  `max_dining_capacity` int NULL DEFAULT NULL COMMENT '就餐最大人数',
  `near_window` tinyint(1) NULL DEFAULT NULL COMMENT '是否靠窗',
  `deposit` decimal(24, 6) NULL DEFAULT NULL COMMENT '订金',
  `standard_table_num` int NULL DEFAULT NULL COMMENT '标准摆台桌数',
  `staff` bigint NULL DEFAULT NULL COMMENT '专属服务',
  `app` tinyint(1) NULL DEFAULT NULL COMMENT '营销app',
  `online` tinyint(1) NULL DEFAULT NULL COMMENT '网络预订',
  `tbl_position` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌位',
  `facility` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '房间设施',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '餐位说明',
  `tbl_photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台图片',
  `slide_photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '轮播图',
  `vr_photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'vr图',
  `capacity` int NULL DEFAULT NULL COMMENT '容纳人数',
  `price` decimal(24, 6) NULL DEFAULT NULL COMMENT '建议标准(元/桌)',
  `max_table_num` int NULL DEFAULT NULL COMMENT '最大桌数',
  `attribute_remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '桌台属性',
  `tbl_photo_list` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '桌台图片列表',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_tbl_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_sid_id`(`company_id` ASC, `shop_id` ASC, `id`(191) ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15612570 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_tbl_area
-- ----------------------------
DROP TABLE IF EXISTS `sc_tbl_area`;
CREATE TABLE `sc_tbl_area`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `order_idx` int NULL DEFAULT NULL,
  `Show_order` int NULL DEFAULT NULL,
  `floor_height` decimal(10, 2) NULL DEFAULT NULL COMMENT '层高(m)',
  `tbl_photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台图片',
  `max_table_num` int NULL DEFAULT NULL COMMENT '最大桌数',
  `area_size` decimal(10, 2) NULL DEFAULT NULL COMMENT '面积(㎡)',
  `attribute_remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '台桌属性',
  `area_desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '台区描述',
  `tbl_photo_list` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '桌台图片列表',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_tbl_area_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 650040 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_tbl_type
-- ----------------------------
DROP TABLE IF EXISTS `sc_tbl_type`;
CREATE TABLE `sc_tbl_type`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `service_rate` decimal(19, 10) NULL DEFAULT NULL,
  `minimum_consumption` decimal(19, 10) NULL DEFAULT NULL,
  `allowepeople` int NULL DEFAULT NULL,
  `Book_amount` decimal(19, 10) NULL DEFAULT NULL,
  `Mon_minimum_consumption` decimal(19, 10) NULL DEFAULT NULL,
  `Tues_minimum_consumption` decimal(19, 10) NULL DEFAULT NULL,
  `Wed_minimum_consumption` decimal(19, 10) NULL DEFAULT NULL,
  `Thur_minimum_consumption` decimal(19, 10) NULL DEFAULT NULL,
  `Fri_minimum_consumption` decimal(19, 10) NULL DEFAULT NULL,
  `Sat_minimum_consumption` decimal(19, 10) NULL DEFAULT NULL,
  `Sun_minimum_consumption` decimal(19, 10) NULL DEFAULT NULL,
  `Discount_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Discount_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tbl_mode` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '收费模式',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_tbl_type_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 594900 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_team_leader_bill
-- ----------------------------
DROP TABLE IF EXISTS `sc_team_leader_bill`;
CREATE TABLE `sc_team_leader_bill`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `type_` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `order_bill_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `member_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `leader` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `leader_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `rate` decimal(19, 10) NULL DEFAULT NULL,
  `order_amount` decimal(19, 10) NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `crttime` datetime NULL DEFAULT NULL,
  `is_cancel` tinyint NULL DEFAULT NULL,
  `shopname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_team_leader_bill_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_team_leader_bill_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_time_limit_promotion
-- ----------------------------
DROP TABLE IF EXISTS `sc_time_limit_promotion`;
CREATE TABLE `sc_time_limit_promotion`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `maker` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `make_time` datetime NULL DEFAULT NULL,
  `summary` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_review` tinyint NULL DEFAULT NULL,
  `reviewer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `review_time` datetime NULL DEFAULT NULL,
  `begin_date` datetime NULL DEFAULT NULL,
  `end_date` datetime NULL DEFAULT NULL,
  `begin_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `is_terminator` tinyint NULL DEFAULT NULL,
  `terminator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `terminat_time` datetime NULL DEFAULT NULL,
  `repeat_cycle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `moday` tinyint NULL DEFAULT NULL,
  `tuesday` tinyint NULL DEFAULT NULL,
  `wednesday` tinyint NULL DEFAULT NULL,
  `thursday` tinyint NULL DEFAULT NULL,
  `friday` tinyint NULL DEFAULT NULL,
  `saturday` tinyint NULL DEFAULT NULL,
  `sunday` tinyint NULL DEFAULT NULL,
  `repeat_day_for_month` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `For_all` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_time_limit_promotion_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_user_department
-- ----------------------------
DROP TABLE IF EXISTS `sc_user_department`;
CREATE TABLE `sc_user_department`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `user_lmnid` bigint NULL DEFAULT NULL,
  `shop_lmnid` bigint NULL DEFAULT NULL,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `department_code` bigint NULL DEFAULT NULL,
  `department_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_user_department_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 90 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_user_permission
-- ----------------------------
DROP TABLE IF EXISTS `sc_user_permission`;
CREATE TABLE `sc_user_permission`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `permission_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '权限名称',
  `permission_lmnid` bigint NULL DEFAULT NULL COMMENT '权限LmnID',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户名称/角色名称',
  `user_lmnid` bigint NULL DEFAULT NULL COMMENT '用户lmnid/角色lmnid',
  `permission_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '权限类型：Return 退菜权限，Order 点单权限，ItemDiscount 单品打折权限，Gift 赠品权限，CheckOut 结账权限，WholeDiscount 整单打折权限，AdjustChange 调整零头权限',
  `user_type` tinyint NULL DEFAULT NULL COMMENT '0代表角色，1代表用户',
  `amount` decimal(19, 9) NULL DEFAULT NULL COMMENT '数量',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_user_permission_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_companyid_shopid_permission_user`(`company_id` ASC, `shop_id` ASC, `permission_lmnid` ASC, `user_lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4709 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sc_user_role`;
CREATE TABLE `sc_user_role`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `user_lmnid` bigint NULL DEFAULT NULL,
  `role_lmnid` bigint NULL DEFAULT NULL,
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `modified_time` datetime NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_user_role_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3757 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_user_store
-- ----------------------------
DROP TABLE IF EXISTS `sc_user_store`;
CREATE TABLE `sc_user_store`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `user_lmnid` bigint NULL DEFAULT NULL,
  `store_lmnid` bigint NULL DEFAULT NULL,
  `store_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_user_store_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12597 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_usr
-- ----------------------------
DROP TABLE IF EXISTS `sc_usr`;
CREATE TABLE `sc_usr`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `salt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `modified_time` datetime NULL DEFAULT NULL,
  `user_status` int NULL DEFAULT NULL,
  `pwd` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `wechat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qq` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_opr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `modified_opr` datetime NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `avatarurl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Pb_cat_unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Pb_cat_openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Pb_dailishangid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Roles` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Roles_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `For_some_shop` tinyint NULL DEFAULT NULL,
  `Min_discount` decimal(19, 10) NULL DEFAULT NULL,
  `Max_discount` decimal(19, 10) NULL DEFAULT NULL,
  `Min_mod_price` decimal(19, 10) NULL DEFAULT NULL,
  `Max_mod_price` decimal(19, 10) NULL DEFAULT NULL,
  `Write_off_bag` tinyint NULL DEFAULT NULL,
  `Leave_office` tinyint NULL DEFAULT NULL,
  `Entry_time` datetime NULL DEFAULT NULL,
  `Staff_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Charge_limit` decimal(19, 10) NULL DEFAULT NULL,
  `By_permission_ratio` decimal(19, 10) NULL DEFAULT NULL,
  `Available_quota` decimal(19, 10) NULL DEFAULT NULL,
  `Used_quota` decimal(19, 10) NULL DEFAULT NULL,
  `Giving_goods_quota` decimal(19, 10) NULL DEFAULT NULL,
  `Giving_goods_amount` decimal(19, 10) NULL DEFAULT NULL,
  `Usr_show` tinyint NULL DEFAULT NULL,
  `Sex` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Pos_give_pwd` tinyint NULL DEFAULT NULL,
  `Usr_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT 0 COMMENT '是否删除',
  `data_scope` int NULL DEFAULT NULL COMMENT '数据权限',
  `warehouse_lids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '部门/仓库lids',
  PRIMARY KEY (`pid`, `company_id`, `lmnid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_usr_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_mid_id`(`company_id` ASC, `id`(191) ASC) USING BTREE,
  INDEX `sc_usr_lmnid_IDX`(`lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1703 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_usr_grp
-- ----------------------------
DROP TABLE IF EXISTS `sc_usr_grp`;
CREATE TABLE `sc_usr_grp`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `link_user_num` int NULL DEFAULT NULL,
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `create_opr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `modified_time` datetime NULL DEFAULT NULL,
  `modified_opr` datetime NULL DEFAULT NULL,
  `grp_status` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_usr_grp_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_usr_grp_user
-- ----------------------------
DROP TABLE IF EXISTS `sc_usr_grp_user`;
CREATE TABLE `sc_usr_grp_user`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `user_lmnid` bigint NULL DEFAULT NULL,
  `usr_grp_lmnid` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_usr_grp_user_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_usr_permission
-- ----------------------------
DROP TABLE IF EXISTS `sc_usr_permission`;
CREATE TABLE `sc_usr_permission`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `permission_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `permission_lmnid` bigint NULL DEFAULT NULL,
  `usr_lmnid` bigint NULL DEFAULT NULL,
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `modified_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_usr_permission_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_usr_tbl
-- ----------------------------
DROP TABLE IF EXISTS `sc_usr_tbl`;
CREATE TABLE `sc_usr_tbl`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `usr_lmnid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tbl_lmnid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tbl_area_lmnid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_usr_tbl_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_verify_code
-- ----------------------------
DROP TABLE IF EXISTS `sc_verify_code`;
CREATE TABLE `sc_verify_code`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `create_time` datetime NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `store` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `store_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `verify_num` int NULL DEFAULT NULL,
  `application` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_verify_code_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_sc_verify_code_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_warehouse
-- ----------------------------
DROP TABLE IF EXISTS `sc_warehouse`;
CREATE TABLE `sc_warehouse`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `type_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `delivery_center` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `delivery_center_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `number_of_item` int NULL DEFAULT NULL,
  `number_of_supplier` int NULL DEFAULT NULL,
  `number_of_route_rule` int NULL DEFAULT NULL,
  `number_of_supply_contract` int NULL DEFAULT NULL,
  `number_of_delivery_contract` int NULL DEFAULT NULL,
  `inited` tinyint NULL DEFAULT NULL,
  `last_inventory_time` datetime NULL DEFAULT NULL,
  `last_order_time` datetime NULL DEFAULT NULL,
  `time_of_last_bill` datetime NULL DEFAULT NULL,
  `time_of_last_auto_out` datetime NULL DEFAULT NULL,
  `Phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Telephone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Warehouse_describe` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Crt_time` datetime NULL DEFAULT NULL,
  `Address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Checking` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Owner_shop` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Owner_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Reduce_level` int NULL DEFAULT NULL,
  `Init_time` datetime NULL DEFAULT NULL,
  `for_default` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_warehouse_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 38 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_weapp_code_ver
-- ----------------------------
DROP TABLE IF EXISTS `sc_weapp_code_ver`;
CREATE TABLE `sc_weapp_code_ver`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `commit_audit_time` datetime NULL DEFAULT NULL,
  `operator` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `template_ver` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `template_desc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `template_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `template_create_time` datetime NULL DEFAULT NULL,
  `submit_audit_time` datetime NULL DEFAULT NULL,
  `auditid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `audit_status` int NULL DEFAULT NULL,
  `audit_reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `audit_reject_screenshot` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `released` tinyint NULL DEFAULT NULL,
  `release_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_weapp_code_ver_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_wegzh_auto_reply
-- ----------------------------
DROP TABLE IF EXISTS `sc_wegzh_auto_reply`;
CREATE TABLE `sc_wegzh_auto_reply`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `key_word` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `enable_status` tinyint NULL DEFAULT NULL,
  `reply_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `msg_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pic_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `msg_content` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `msg_jump_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `third_party_addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `third_party_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_wegzh_auto_reply_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_wegzh_menu
-- ----------------------------
DROP TABLE IF EXISTS `sc_wegzh_menu`;
CREATE TABLE `sc_wegzh_menu`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `menu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `menu_content` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `creater` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `create_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `editor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `modify_time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_wegzh_menu_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_wx_msg_template
-- ----------------------------
DROP TABLE IF EXISTS `sc_wx_msg_template`;
CREATE TABLE `sc_wx_msg_template`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `template_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `template_id_short` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `template_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `app_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_wx_msg_template_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_wx_zfb_fans
-- ----------------------------
DROP TABLE IF EXISTS `sc_wx_zfb_fans`;
CREATE TABLE `sc_wx_zfb_fans`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `country` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `gender` int NULL DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `avatarurl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `unionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nickname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `language` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_wx_zfb_fans_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 932 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_xcx_qualification
-- ----------------------------
DROP TABLE IF EXISTS `sc_xcx_qualification`;
CREATE TABLE `sc_xcx_qualification`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `appid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_shop_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `doorhead_business__license` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dbl_media_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qualification_photo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qp_media_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cash_register_scene` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `crs_media_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `food_business_license` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fbl_media_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `express_business_license` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `exbl_media_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `increment_telecom_business_license` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `itbl_media_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `enterprise_business_license` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ebl_media_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `merchant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `business_license` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bl_media_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `business_license_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `qualification_start_date` datetime NULL DEFAULT NULL,
  `expiry_day_of_qualification` datetime NULL DEFAULT NULL,
  `commit_audit_time` datetime NULL DEFAULT NULL,
  `media_last_submit_time` datetime NULL DEFAULT NULL,
  `Shop_logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_xcx_qualification_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sc_xfd_and_distribution
-- ----------------------------
DROP TABLE IF EXISTS `sc_xfd_and_distribution`;
CREATE TABLE `sc_xfd_and_distribution`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `distribution_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fans_openid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fans_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `amount` decimal(19, 10) NULL DEFAULT NULL,
  `crt_time` datetime NULL DEFAULT NULL,
  `detail_addr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `district` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `district_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_person` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `XiaofeidanID` bigint NULL DEFAULT NULL,
  `Distribution_code` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sc_xfd_and_distribution_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sms_msg_content
-- ----------------------------
DROP TABLE IF EXISTS `sms_msg_content`;
CREATE TABLE `sms_msg_content`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `msg_style` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '样式类型',
  `msg_style_code` bigint NULL DEFAULT NULL COMMENT '样式类型编号',
  `content_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '样式内容类型',
  `print_content` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '样式内容',
  `condition_` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '条件',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sms_msg_content_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_U_sms_msg_content_COMPANY_SHOP_style_code`(`company_id` ASC, `shop_id` ASC, `msg_style_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 237 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '短信打印样式内容' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sms_msg_style
-- ----------------------------
DROP TABLE IF EXISTS `sms_msg_style`;
CREATE TABLE `sms_msg_style`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `type_` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '样式类型',
  `source_string` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '源sql',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `created_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `updated_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_sms_msg_style_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 88 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '短信打印样式' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for suite_receive_log
-- ----------------------------
DROP TABLE IF EXISTS `suite_receive_log`;
CREATE TABLE `suite_receive_log`  (
  `PID` bigint NOT NULL COMMENT '物理主键',
  `TENANT_ID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '租户号',
  `REVISION` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'REVISION',
  `CREATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'CREATED_BY',
  `CREATED_TIME` datetime NULL DEFAULT NULL COMMENT 'CREATED_TIME',
  `UPDATED_BY` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'UPDATED_BY',
  `UPDATED_TIME` datetime NULL DEFAULT NULL COMMENT 'UPDATED_TIME',
  `REQUEST_BODY` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '企业微信推送过来的完整内容',
  `ENCRYPT_BODY` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '解密后的数据',
  `SUITEID` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '第三方应用的SuiteId',
  `INFOTYPE` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '回调类型',
  PRIMARY KEY (`PID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '第三方回调记录' ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sys_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '权限标识',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父菜单ID',
  `order_num` int NULL DEFAULT NULL COMMENT '显示顺序',
  `is_dir` tinyint(1) NULL DEFAULT NULL COMMENT '目录',
  `invisible` tinyint(1) NULL DEFAULT NULL COMMENT '隐藏',
  `def` tinyint(1) NULL DEFAULT NULL COMMENT '默认',
  `status` bigint NULL DEFAULT NULL COMMENT '菜单状态;（0正常 1停用）',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  UNIQUE INDEX `uk_id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '角色编号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '角色名称',
  `role_sort` int NULL DEFAULT NULL COMMENT '显示顺序',
  `status` bigint NULL DEFAULT NULL COMMENT '角色状态;（0正常 1停用）',
  `def` tinyint(1) NULL DEFAULT NULL COMMENT '默认',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '删除标志;（0代表存在 2代表删除）',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  UNIQUE INDEX `uk_id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_rold_id`(`role_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户账号',
  `name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '姓名',
  `nick_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户昵称',
  `email` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户邮箱',
  `phone_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号码',
  `sex` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户性别',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像地址',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '密码',
  `def` tinyint(1) NULL DEFAULT NULL COMMENT '默认用户',
  `disabled` tinyint(1) NULL DEFAULT NULL COMMENT '禁用',
  `login_ip` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `created_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建者',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新者',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '删除标志;（0代表存在 1代表删除）',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  UNIQUE INDEX `uk_id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`pid`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户和角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wx_sc_user
-- ----------------------------
DROP TABLE IF EXISTS `wx_sc_user`;
CREATE TABLE `wx_sc_user`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `wx_id` bigint NULL DEFAULT NULL COMMENT 'wx_user表lid',
  `sc_id` bigint NULL DEFAULT NULL COMMENT 'sc_usr表lid',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  INDEX `idx_wx_id`(`wx_id` ASC) USING BTREE,
  INDEX `idx_sc_id`(`sc_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1808 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '微信用户和系统用户的对应关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for wx_user
-- ----------------------------
DROP TABLE IF EXISTS `wx_user`;
CREATE TABLE `wx_user`  (
  `pid` bigint NOT NULL AUTO_INCREMENT COMMENT '物理编号',
  `mid` bigint NULL DEFAULT NULL COMMENT '租户号',
  `sid` bigint NULL DEFAULT NULL COMMENT '门店号',
  `lid` bigint NOT NULL COMMENT '逻辑编号',
  `appid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'appid',
  `openid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'openid',
  `nick_name` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '昵称',
  `gender` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '性别',
  `language` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '语言',
  `city` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '城市',
  `province` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '省份',
  `country` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '国家',
  `avatar_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像',
  `phone_number` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `pure_phone_number` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '手机号',
  `country_code` varchar(90) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '国家码',
  `revision` int NULL DEFAULT NULL COMMENT '乐观锁',
  `created_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '创建人',
  `created_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_by` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '更新人',
  `updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `deleted` bigint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`pid`, `lid`) USING BTREE,
  UNIQUE INDEX `uk_lid`(`lid` ASC) USING BTREE,
  UNIQUE INDEX `uk_openid`(`openid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1066 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '微信用户' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for xiaofeicaiping
-- ----------------------------
DROP TABLE IF EXISTS `xiaofeicaiping`;
CREATE TABLE `xiaofeicaiping`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `xiaofeid` bigint NULL DEFAULT NULL,
  `diancaipici` bigint NULL DEFAULT NULL,
  `xiafeicaipingid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiafeicaipingname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `diancaicanduanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `diancaicanduanname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaoleiid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaolei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `daleiid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dalei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zuofa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jifenduihuan` tinyint NULL DEFAULT NULL,
  `zengsong` tinyint NULL DEFAULT NULL,
  `zengsongren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zengsongyuanyin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `diancaishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `shangcaishijian` datetime NULL DEFAULT NULL,
  `yilingqushuliang` decimal(19, 10) NULL DEFAULT NULL,
  `yishangcaishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `tuicaishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `tuicaishijian` datetime NULL DEFAULT NULL,
  `tuicairen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `tuicaijine` decimal(19, 10) NULL DEFAULT NULL,
  `xiaohaojifen` decimal(19, 10) NULL DEFAULT NULL,
  `zengsongjine` decimal(19, 10) NULL DEFAULT NULL,
  `shipinfei` decimal(19, 10) NULL DEFAULT NULL,
  `jiagongfei` decimal(19, 10) NULL DEFAULT NULL,
  `shipinfuwufei` decimal(19, 10) NULL DEFAULT NULL,
  `jiagongfuwufei` decimal(19, 10) NULL DEFAULT NULL,
  `shipinzhekuoe` decimal(19, 10) NULL DEFAULT NULL,
  `jiagongzhekuoe` decimal(19, 10) NULL DEFAULT NULL,
  `yuancailiaodangechengben` decimal(19, 10) NULL DEFAULT NULL,
  `yuancailiaozongchengben` decimal(19, 10) NULL DEFAULT NULL,
  `jiagongchengben` decimal(19, 10) NULL DEFAULT NULL,
  `danwei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nobillingunit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nobillingamount` decimal(19, 10) NULL DEFAULT NULL,
  `jibendanwei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `danweibilv` decimal(19, 10) NULL DEFAULT NULL,
  `jiage` decimal(19, 10) NULL DEFAULT NULL,
  `yuanshijiage` decimal(19, 10) NULL DEFAULT NULL,
  `shifa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `diancairen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dangeticheng` decimal(19, 10) NULL DEFAULT NULL,
  `zongticheng` decimal(19, 10) NULL DEFAULT NULL,
  `tuicaiyuanyin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sfquerenshuliang` tinyint NULL DEFAULT NULL,
  `shuliangquerenyuan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `diancaishijian` datetime NULL DEFAULT NULL,
  `xiadanshijian` datetime NULL DEFAULT NULL,
  `overtime` int NULL DEFAULT NULL,
  `cuicairenshijian` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caipinginzhuotai` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `precaipinginzhuotai` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhuantaishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `bumen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `chupingbumen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `chupingbumenorg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pricemoder` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pricemodtime` datetime NULL DEFAULT NULL,
  `shougonggaijia` tinyint NULL DEFAULT NULL,
  `renamedtime` datetime NULL DEFAULT NULL,
  `namemoder` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `renamed` tinyint NULL DEFAULT NULL,
  `chushi` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `maincai` bigint NULL DEFAULT NULL,
  `fenchengqianjiage` decimal(19, 10) NULL DEFAULT NULL,
  `idxinbill` int NULL DEFAULT NULL,
  `peicaimaincai` int NULL DEFAULT NULL,
  `zhekoulv` decimal(19, 10) NULL DEFAULT NULL,
  `dazheren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dazhebyman` tinyint NULL DEFAULT NULL,
  `mensetdiscount` tinyint NULL DEFAULT NULL,
  `canyizuidixiaofei` tinyint NULL DEFAULT NULL,
  `paid` tinyint NULL DEFAULT NULL,
  `rendian` tinyint NULL DEFAULT NULL,
  `orgpid` int NULL DEFAULT NULL,
  `xishu` int NULL DEFAULT NULL,
  `isjiuxi` tinyint NULL DEFAULT NULL,
  `autosubwarehouse` int NULL DEFAULT NULL,
  `autosubbumem` int NULL DEFAULT NULL,
  `subbumen` tinyint NULL DEFAULT NULL,
  `autosale` tinyint NULL DEFAULT NULL,
  `subed` tinyint NULL DEFAULT NULL,
  `prnidx` int NULL DEFAULT NULL,
  `prnsum` int NULL DEFAULT NULL,
  `fuzhutaihao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fuzhutaiming` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `songdanidx` bigint NULL DEFAULT NULL,
  `tichengren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tichengpercent` decimal(19, 10) NULL DEFAULT NULL,
  `istichengper` tinyint NULL DEFAULT NULL,
  `yufu` tinyint NULL DEFAULT NULL,
  `orderbypad` tinyint NULL DEFAULT NULL,
  `strzf1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `chengbengjia` decimal(19, 10) NULL DEFAULT NULL,
  `istejiacai` tinyint NULL DEFAULT NULL,
  `orderwsid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `orderwsname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `yichulibanjia` tinyint NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caipingtype` int NULL DEFAULT NULL,
  `saletaxlv` int NULL DEFAULT NULL,
  `saletaxjine` decimal(19, 10) NULL DEFAULT NULL,
  `additionalcost` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `ShopName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Factory_brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Factory_brand_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `MemberID` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `MemberLmnID` bigint NULL DEFAULT NULL,
  `MemberName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `MemberSex` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type_code` bigint NULL DEFAULT NULL,
  `Card_type_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type_level_code` bigint NULL DEFAULT NULL,
  `CardLmnID` bigint NULL DEFAULT NULL,
  `HuiYuanCaHao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Marketing_plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Is_inline` tinyint NULL DEFAULT NULL,
  `Upload_time` datetime NULL DEFAULT NULL,
  `Is_offline` tinyint NULL DEFAULT NULL,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '店铺名称',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开台时间',
  `checkout_time` datetime NULL DEFAULT NULL COMMENT '结账时间',
  `order_sub_type` int NULL DEFAULT NULL COMMENT '账单类型;堂食、外卖、自提',
  `shift_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次',
  `area_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区域名称',
  `table_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台名称',
  `checkout_by` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标记',
  `saas_order_no` bigint NULL DEFAULT NULL COMMENT '账单流水号',
  `takeout_channel` int NULL DEFAULT NULL COMMENT '外卖渠道',
  `checkout_time_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '餐段',
  `free_service_charge` tinyint NULL DEFAULT NULL COMMENT '免服务费',
  `online` tinyint NULL DEFAULT NULL COMMENT '线上订单',
  `promotion_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '优惠金额',
  `total_ordered_qty` decimal(18, 4) NULL DEFAULT NULL COMMENT '毛销售数量/总下单数量',
  `returned_qty` decimal(18, 4) NULL DEFAULT NULL COMMENT '退菜数量（负数）',
  `free_qty` decimal(18, 4) NULL DEFAULT NULL COMMENT '赠送数量（负数）',
  `gross_sales_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '毛销售额',
  `net_sales_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '净销售额',
  `returned_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '退菜金额（负数）',
  `free_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '赠送金额（负数）',
  `food_service_charge_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '食品服务费',
  `food_discount_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '食品折扣额（负数）',
  `food_processing_fee_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '加工费',
  `processing_service_charge_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '加工服务费',
  `processing_fee_discount_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '加工费折扣额（负数）',
  `receivable_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '应收金额',
  `price_diff_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '价差金额',
  `platform_discount_amt` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '平台优惠金额',
  `net_sales_qty` decimal(18, 4) NULL DEFAULT 0.0000 COMMENT '净售数量（计算字段）',
  `group_promote_amount` decimal(24, 10) NULL DEFAULT NULL COMMENT '团购折扣',
  `member_gift_amount` decimal(24, 10) NULL DEFAULT NULL COMMENT '赠送折扣',
  `promote_detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '优惠明细',
  `fraction` decimal(19, 10) NULL DEFAULT NULL COMMENT '零头',
  `mantissa` decimal(19, 10) NULL DEFAULT NULL COMMENT '尾数',
  `dish_category_type` tinyint NULL DEFAULT NULL COMMENT '菜品类型：1-套餐 2-套餐子菜 3-单品',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_XiaoFeiCaiPing_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_XiaoFeiCaiPing_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_XiaoFeiCaiPing_COMPANY_SHOP_XFDID`(`company_id` ASC, `shop_id` ASC, `xiaofeidanid`(191) ASC) USING BTREE,
  INDEX `idx_report_date`(`yingyeriqi` ASC) USING BTREE,
  INDEX `idx_mid_name`(`company_id` ASC, `xiafeicaipingname` ASC) USING BTREE,
  INDEX `idx_xfcp_company_shop_name_date`(`company_id` ASC, `shop_id` ASC, `xiafeicaipingname` ASC, `yingyeriqi` ASC) USING BTREE,
  INDEX `idx_mid_id`(`company_id` ASC, `xiafeicaipingid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12047611 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for xiaofeicaipingfjz
-- ----------------------------
DROP TABLE IF EXISTS `xiaofeicaipingfjz`;
CREATE TABLE `xiaofeicaipingfjz`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `xiaofeid` bigint NULL DEFAULT NULL,
  `diancaipici` bigint NULL DEFAULT NULL,
  `xiafeicaipingid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shopname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiafeicaipingname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `diancaicanduanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `diancaicanduanname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaoleiid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaolei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `daleiid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dalei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zuofa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jifenduihuan` tinyint NULL DEFAULT NULL,
  `zengsong` tinyint NULL DEFAULT NULL,
  `zengsongren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zengsongyuanyin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `diancaishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `shangcaishijian` datetime NULL DEFAULT NULL,
  `yilingqushuliang` decimal(19, 10) NULL DEFAULT NULL,
  `yishangcaishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `tuicaishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `tuicaishijian` datetime NULL DEFAULT NULL,
  `tuicairen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `tuicaijine` decimal(19, 10) NULL DEFAULT NULL,
  `xiaohaojifen` decimal(19, 10) NULL DEFAULT NULL,
  `zengsongjine` decimal(19, 10) NULL DEFAULT NULL,
  `shipinfei` decimal(19, 10) NULL DEFAULT NULL,
  `jiagongfei` decimal(19, 10) NULL DEFAULT NULL,
  `shipinfuwufei` decimal(19, 10) NULL DEFAULT NULL,
  `jiagongfuwufei` decimal(19, 10) NULL DEFAULT NULL,
  `shipinzhekuoe` decimal(19, 10) NULL DEFAULT NULL,
  `jiagongzhekuoe` decimal(19, 10) NULL DEFAULT NULL,
  `yuancailiaodangechengben` decimal(19, 10) NULL DEFAULT NULL,
  `yuancailiaozongchengben` decimal(19, 10) NULL DEFAULT NULL,
  `jiagongchengben` decimal(19, 10) NULL DEFAULT NULL,
  `danwei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nobillingunit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nobillingamount` decimal(19, 10) NULL DEFAULT NULL,
  `jibendanwei` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `danweibilv` decimal(19, 10) NULL DEFAULT NULL,
  `jiage` decimal(19, 10) NULL DEFAULT NULL,
  `yuanshijiage` decimal(19, 10) NULL DEFAULT NULL,
  `shifa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `diancairen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dangeticheng` decimal(19, 10) NULL DEFAULT NULL,
  `zongticheng` decimal(19, 10) NULL DEFAULT NULL,
  `tuicaiyuanyin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sfquerenshuliang` tinyint NULL DEFAULT NULL,
  `shuliangquerenyuan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `diancaishijian` datetime NULL DEFAULT NULL,
  `xiadanshijian` datetime NULL DEFAULT NULL,
  `overtime` int NULL DEFAULT NULL,
  `cuicairenshijian` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caipinginzhuotai` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `precaipinginzhuotai` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhuantaishuliang` decimal(19, 10) NULL DEFAULT NULL,
  `bumen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `chupingbumen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `chupingbumenorg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pricemoder` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pricemodtime` datetime NULL DEFAULT NULL,
  `shougonggaijia` tinyint NULL DEFAULT NULL,
  `renamedtime` datetime NULL DEFAULT NULL,
  `namemoder` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `renamed` tinyint NULL DEFAULT NULL,
  `chushi` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `maincai` bigint NULL DEFAULT NULL,
  `fenchengqianjiage` decimal(19, 10) NULL DEFAULT NULL,
  `idxinbill` int NULL DEFAULT NULL,
  `peicaimaincai` int NULL DEFAULT NULL,
  `zhekoulv` decimal(19, 10) NULL DEFAULT NULL,
  `dazheren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dazhebyman` tinyint NULL DEFAULT NULL,
  `mensetdiscount` tinyint NULL DEFAULT NULL,
  `canyizuidixiaofei` tinyint NULL DEFAULT NULL,
  `paid` tinyint NULL DEFAULT NULL,
  `rendian` tinyint NULL DEFAULT NULL,
  `orgpid` bigint NULL DEFAULT NULL,
  `xishu` int NULL DEFAULT NULL,
  `isjiuxi` tinyint NULL DEFAULT NULL,
  `autosubwarehouse` int NULL DEFAULT NULL,
  `autosubbumem` int NULL DEFAULT NULL,
  `subbumen` tinyint NULL DEFAULT NULL,
  `autosale` tinyint NULL DEFAULT NULL,
  `subed` tinyint NULL DEFAULT NULL,
  `prnidx` int NULL DEFAULT NULL,
  `prnsum` int NULL DEFAULT NULL,
  `fuzhutaihao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fuzhutaiming` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `songdanidx` bigint NULL DEFAULT NULL,
  `tichengren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tichengpercent` decimal(19, 10) NULL DEFAULT NULL,
  `istichengper` tinyint NULL DEFAULT NULL,
  `yufu` tinyint NULL DEFAULT NULL,
  `orderbypad` tinyint NULL DEFAULT NULL,
  `strzf1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `chengbengjia` decimal(19, 10) NULL DEFAULT NULL,
  `istejiacai` tinyint NULL DEFAULT NULL,
  `orderwsid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `orderwsname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `yichulibanjia` tinyint NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caipingtype` int NULL DEFAULT NULL,
  `saletaxlv` int NULL DEFAULT NULL,
  `saletaxjine` decimal(19, 10) NULL DEFAULT NULL,
  `factory_brand` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `factory_brand_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `memberid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `memberlmnid` bigint NULL DEFAULT NULL,
  `membername` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `membersex` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_code` bigint NULL DEFAULT NULL,
  `card_type_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_level_code` bigint NULL DEFAULT NULL,
  `cardlmnid` bigint NULL DEFAULT NULL,
  `huiyuancahao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `marketing_plan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `item_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `additionalcost` decimal(19, 10) NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Is_inline` tinyint NULL DEFAULT NULL,
  `Upload_time` datetime NULL DEFAULT NULL,
  `Is_offline` tinyint NULL DEFAULT NULL,
  `start_time` datetime NULL DEFAULT NULL COMMENT '开台时间',
  `checkout_time` datetime NULL DEFAULT NULL COMMENT '结账时间',
  `order_sub_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单子类型',
  `shift_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次名称',
  `area_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区域名称',
  `table_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台名称',
  `checkout_by` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `saas_order_no` bigint NULL DEFAULT NULL COMMENT 'SaaS订单号',
  `takeout_channel` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外卖渠道',
  `checkout_time_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '结账时段名称',
  `online` tinyint NULL DEFAULT NULL COMMENT '是否线上(0:否,1:是)',
  `free_service_charge` tinyint NULL DEFAULT NULL COMMENT '是否免服务费(0:否,1:是)',
  `promotion_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '促销优惠金额',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_XiaoFeiCaiPingFJZ_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_XiaoFeiCaiPingFJZ_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 95210 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for xiaofeidan
-- ----------------------------
DROP TABLE IF EXISTS `xiaofeidan`;
CREATE TABLE `xiaofeidan`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `taihao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `taiming` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `taiquhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `taiquming` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `canduan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `canduanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `renshu` int NULL DEFAULT NULL,
  `yanchidanhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `kaitaishijian` datetime NULL DEFAULT NULL,
  `firstjiezhangshijian` datetime NULL DEFAULT NULL,
  `jiezhangshijian` datetime NULL DEFAULT NULL,
  `booktime` datetime NULL DEFAULT NULL,
  `kaitairen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `maidanren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `maidanshijian` datetime NULL DEFAULT NULL,
  `ShouYinRen` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `yewuyuan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `rendiancha` decimal(19, 10) NULL DEFAULT NULL,
  `tuicaijine` decimal(19, 10) NULL DEFAULT NULL,
  `zengsongjine` decimal(19, 10) NULL DEFAULT NULL,
  `fuwufeilv` decimal(19, 10) NULL DEFAULT NULL,
  `dazheren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dazhefangshi` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhekoulv` decimal(19, 10) NULL DEFAULT NULL,
  `membertypeid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `membertypename` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `memberid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `membername` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `membersex` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `huiyuancahao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `huiyuanbalance` decimal(19, 10) NULL DEFAULT NULL,
  `huiyuanintegral` decimal(19, 10) NULL DEFAULT NULL,
  `mianfuwufei` tinyint NULL DEFAULT NULL,
  `miandiaofuwufei` decimal(19, 10) NULL DEFAULT NULL,
  `shipingfei` decimal(19, 10) NULL DEFAULT NULL,
  `fuwufei` decimal(19, 10) NULL DEFAULT NULL,
  `zhekoue` decimal(19, 10) NULL DEFAULT NULL,
  `weishu` decimal(19, 10) NULL DEFAULT NULL,
  `lingtou` decimal(19, 10) NULL DEFAULT NULL,
  `lingtouor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fanjiezhangren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fanjiezhangshijian` datetime NULL DEFAULT NULL,
  `zuidixiaofei` decimal(19, 10) NULL DEFAULT NULL,
  `zuidixiaofeicha` decimal(19, 10) NULL DEFAULT NULL,
  `quxiaozdxf` tinyint NULL DEFAULT NULL,
  `quxiaozdxfor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `taxrate` decimal(19, 10) NULL DEFAULT NULL,
  `tax` decimal(19, 10) NULL DEFAULT NULL,
  `statetaxrate` decimal(19, 10) NULL DEFAULT NULL,
  `statetax` decimal(19, 10) NULL DEFAULT NULL,
  `yingshoujine` decimal(19, 10) NULL DEFAULT NULL,
  `shishoujine` decimal(19, 10) NULL DEFAULT NULL,
  `shoudaojine` decimal(19, 10) NULL DEFAULT NULL,
  `zhaohuijine` decimal(19, 10) NULL DEFAULT NULL,
  `fapiaojine` decimal(19, 10) NULL DEFAULT NULL,
  `maidancishu` int NULL DEFAULT NULL,
  `maidanzhuangtai` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tbl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cai` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `pretable` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fukuanqingkuang` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lastcaozuoren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lastaction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `printcount` int NULL DEFAULT NULL,
  `jiaobanhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `firststationid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `stationid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `stationname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `kaitaistationid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `kaitaistationname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jiezhangfangshi` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `booktype` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bookbilltype` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xinkaitai` tinyint NULL DEFAULT NULL,
  `isorder` tinyint NULL DEFAULT NULL,
  `beizhu` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `orderbillid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `alltblname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xishu` int NULL DEFAULT NULL,
  `isjiuxi` tinyint NULL DEFAULT NULL,
  `danxijine` decimal(19, 10) NULL DEFAULT NULL,
  `jiuxijine` decimal(19, 10) NULL DEFAULT NULL,
  `jiuxidingjin` decimal(19, 10) NULL DEFAULT NULL,
  `bulu` tinyint NULL DEFAULT NULL,
  `diancaipici` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shopname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `songcanaddr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `songcanjifen` decimal(19, 10) NULL DEFAULT NULL,
  `songcanphone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `songcanren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `diancanrenunionid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dingcanren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `songcanshijian` datetime NULL DEFAULT NULL,
  `youhuihuodongid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `youhuihuodongname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `youhuijine` decimal(19, 10) NULL DEFAULT NULL,
  `qtmodel` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shangzhongshijian` datetime NULL DEFAULT NULL,
  `luozhongshijian` datetime NULL DEFAULT NULL,
  `jishijine` decimal(19, 10) NULL DEFAULT NULL,
  `isshoudongzhekou` tinyint NULL DEFAULT NULL,
  `songcantuicai` tinyint NULL DEFAULT NULL,
  `kaitaiyushouyajin` decimal(19, 10) NULL DEFAULT NULL,
  `buffetid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `buffetname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `buffetdazhe` tinyint NULL DEFAULT NULL,
  `buffetamount` decimal(19, 10) NULL DEFAULT NULL,
  `buffetprice` decimal(19, 10) NULL DEFAULT NULL,
  `buffetmoney` decimal(19, 10) NULL DEFAULT NULL,
  `jifenjishu` decimal(19, 10) NULL DEFAULT NULL,
  `jifene` decimal(19, 10) NULL DEFAULT NULL,
  `alpay_out_trade_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `alpay_finish` tinyint NULL DEFAULT NULL,
  `billprntype` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jishizhekoue` decimal(19, 10) NULL DEFAULT NULL,
  `youhuijuanchae` decimal(19, 10) NULL DEFAULT NULL,
  `fapiaodanhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bucanyudazhejine` decimal(19, 10) NULL DEFAULT NULL,
  `msgdealstate` int NULL DEFAULT NULL,
  `dealstate` int NULL DEFAULT NULL,
  `wmptbillid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `manjianjine` decimal(19, 10) NULL DEFAULT NULL,
  `dantype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tips` decimal(19, 10) NULL DEFAULT NULL,
  `xjtips` decimal(19, 10) NULL DEFAULT NULL,
  `xyktips` decimal(19, 10) NULL DEFAULT NULL,
  `wmptdaynum` int NULL DEFAULT NULL,
  `additionalcost` decimal(19, 10) NULL DEFAULT NULL,
  `notax` tinyint NULL DEFAULT NULL,
  `additionalchargecp` decimal(19, 10) NULL DEFAULT NULL,
  `payxfdtype` int NULL DEFAULT NULL,
  `danmode` int NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Sum_of_cost` decimal(20, 10) NULL DEFAULT NULL,
  `UploadToSaaS` tinyint NULL DEFAULT NULL,
  `MemberLmnID` bigint NULL DEFAULT NULL,
  `Card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type_code` bigint NULL DEFAULT NULL,
  `Card_type_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `Card_type_level_code` bigint NULL DEFAULT NULL,
  `CardLmnID` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '优惠券json列表',
  `Sum_of_org_price` decimal(19, 10) NULL DEFAULT NULL,
  `Is_inline` tinyint NULL DEFAULT NULL,
  `PickUpCode` int NULL DEFAULT NULL,
  `Viewmode` int NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL,
  `takeout_channel` int NULL DEFAULT NULL COMMENT '外卖渠道',
  `takeout_channel_order_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外卖渠道单号',
  `takeout_order_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '订单总金额',
  `commission_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '佣金金额',
  `business_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '商家应收金额',
  `favourable_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '优惠总金额（商家承担+平台承担+商家替用户承担的配送费用）',
  `business_favourable_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '商家承担金额',
  `platform_favourable_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '平台承担金额',
  `businesses_deliveryroute_fees` decimal(19, 10) NULL DEFAULT NULL COMMENT '商家替用户承担的配送费用',
  `delivery_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '配送费',
  `box_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '打包盒金额',
  `takeout_pay_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '支付金额',
  `price_diff_amt` decimal(19, 10) NULL DEFAULT NULL COMMENT '价差金额',
  `gross_sales_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '毛销售额',
  `net_sales_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '净销售额',
  `returned_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '退菜金额',
  `free_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '赠送金额',
  `food_service_charge_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '食品服务费',
  `food_discount_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '食品折扣额',
  `food_processing_fee_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '加工费',
  `processing_service_charge_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '加工服务费',
  `processing_fee_discount_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '加工费折扣额',
  `receivable_amt` decimal(18, 4) NULL DEFAULT NULL COMMENT '应收金额(菜品)',
  `promotion_amount` decimal(18, 2) NULL DEFAULT 0.00,
  `group_promote_amount` decimal(24, 10) NULL DEFAULT NULL COMMENT '团购折扣',
  `member_gift_amount` decimal(24, 10) NULL DEFAULT NULL COMMENT '赠送折扣',
  `promote_detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '优惠明细',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_XiaoFeiDan_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_XiaoFeiDan_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_cid_sid_ycdh`(`company_id` ASC, `shop_id` ASC, `yanchidanhao`(191) ASC) USING BTREE,
  INDEX `IDX_XiaoFeiDan_COMPANY_SHOP_XFDID`(`company_id` ASC, `shop_id` ASC, `xiaofeidanid`(191) ASC) USING BTREE,
  INDEX `idx_report_date`(`yingyeriqi` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2241712 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for xiaofeidanfjz
-- ----------------------------
DROP TABLE IF EXISTS `xiaofeidanfjz`;
CREATE TABLE `xiaofeidanfjz`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `sum_of_cost` decimal(19, 10) NULL DEFAULT NULL,
  `sum_of_org_price` decimal(19, 10) NULL DEFAULT NULL,
  `xiaofeidanid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `taihao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `taiming` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `taiquhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `taiquming` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `canduan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `canduanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `renshu` int NULL DEFAULT NULL,
  `yanchidanhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `kaitaishijian` datetime NULL DEFAULT NULL,
  `firstjiezhangshijian` datetime NULL DEFAULT NULL,
  `jiezhangshijian` datetime NULL DEFAULT NULL,
  `booktime` datetime NULL DEFAULT NULL,
  `kaitairen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `maidanren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `maidanshijian` datetime NULL DEFAULT NULL,
  `ShouYinRen` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `yewuyuan` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `rendiancha` decimal(19, 10) NULL DEFAULT NULL,
  `tuicaijine` decimal(19, 10) NULL DEFAULT NULL,
  `zengsongjine` decimal(19, 10) NULL DEFAULT NULL,
  `fuwufeilv` decimal(19, 10) NULL DEFAULT NULL,
  `dazheren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dazhefangshi` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhekoulv` decimal(19, 10) NULL DEFAULT NULL,
  `membertypeid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `membertypename` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `memberid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `memberlmnid` bigint NULL DEFAULT NULL,
  `membername` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `membersex` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_code` bigint NULL DEFAULT NULL,
  `card_type_level` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `card_type_level_code` bigint NULL DEFAULT NULL,
  `cardlmnid` bigint NULL DEFAULT NULL,
  `huiyuancahao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `huiyuanbalance` decimal(19, 10) NULL DEFAULT NULL,
  `huiyuanintegral` decimal(19, 10) NULL DEFAULT NULL,
  `mianfuwufei` tinyint NULL DEFAULT NULL,
  `miandiaofuwufei` decimal(19, 10) NULL DEFAULT NULL,
  `shipingfei` decimal(19, 10) NULL DEFAULT NULL,
  `fuwufei` decimal(19, 10) NULL DEFAULT NULL,
  `zhekoue` decimal(19, 10) NULL DEFAULT NULL,
  `weishu` decimal(19, 10) NULL DEFAULT NULL,
  `lingtou` decimal(19, 10) NULL DEFAULT NULL,
  `lingtouor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fanjiezhangren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fanjiezhangshijian` datetime NULL DEFAULT NULL,
  `zuidixiaofei` decimal(19, 10) NULL DEFAULT NULL,
  `zuidixiaofeicha` decimal(19, 10) NULL DEFAULT NULL,
  `quxiaozdxf` tinyint NULL DEFAULT NULL,
  `quxiaozdxfor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `taxrate` decimal(19, 10) NULL DEFAULT NULL,
  `tax` decimal(19, 10) NULL DEFAULT NULL,
  `statetaxrate` decimal(19, 10) NULL DEFAULT NULL,
  `statetax` decimal(19, 10) NULL DEFAULT NULL,
  `yingshoujine` decimal(19, 10) NULL DEFAULT NULL,
  `shishoujine` decimal(19, 10) NULL DEFAULT NULL,
  `shoudaojine` decimal(19, 10) NULL DEFAULT NULL,
  `zhaohuijine` decimal(19, 10) NULL DEFAULT NULL,
  `fapiaojine` decimal(19, 10) NULL DEFAULT NULL,
  `maidancishu` int NULL DEFAULT NULL,
  `maidanzhuangtai` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tbl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cai` bigint NULL DEFAULT NULL,
  `pretable` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `fukuanqingkuang` bigint NULL DEFAULT NULL,
  `lastcaozuoren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lastaction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `printcount` int NULL DEFAULT NULL,
  `jiaobanhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `firststationid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `stationid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `stationname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `kaitaistationid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `kaitaistationname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jiezhangfangshi` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `booktype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bookbilltype` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xinkaitai` tinyint NULL DEFAULT NULL,
  `isorder` tinyint NULL DEFAULT NULL,
  `beizhu` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `orderbillid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `alltblname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xishu` int NULL DEFAULT NULL,
  `isjiuxi` tinyint NULL DEFAULT NULL,
  `danxijine` decimal(19, 10) NULL DEFAULT NULL,
  `jiuxijine` decimal(19, 10) NULL DEFAULT NULL,
  `jiuxidingjin` decimal(19, 10) NULL DEFAULT NULL,
  `bulu` tinyint NULL DEFAULT NULL,
  `diancaipici` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shopname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `songcanaddr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `songcanjifen` decimal(19, 10) NULL DEFAULT NULL,
  `songcanphone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `songcanren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `diancanrenunionid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `dingcanren` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `songcanshijian` datetime NULL DEFAULT NULL,
  `youhuihuodongid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `youhuihuodongname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `youhuijine` decimal(19, 10) NULL DEFAULT NULL,
  `qtmodel` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `shangzhongshijian` datetime NULL DEFAULT NULL,
  `luozhongshijian` datetime NULL DEFAULT NULL,
  `jishijine` decimal(19, 10) NULL DEFAULT NULL,
  `isshoudongzhekou` tinyint NULL DEFAULT NULL,
  `songcantuicai` tinyint NULL DEFAULT NULL,
  `kaitaiyushouyajin` decimal(19, 10) NULL DEFAULT NULL,
  `buffetid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `buffetname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `buffetdazhe` tinyint NULL DEFAULT NULL,
  `buffetamount` decimal(19, 10) NULL DEFAULT NULL,
  `buffetprice` decimal(19, 10) NULL DEFAULT NULL,
  `buffetmoney` decimal(19, 10) NULL DEFAULT NULL,
  `jifenjishu` decimal(19, 10) NULL DEFAULT NULL,
  `jifene` decimal(19, 10) NULL DEFAULT NULL,
  `alpay_out_trade_no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `alpay_finish` tinyint NULL DEFAULT NULL,
  `billprntype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jishizhekoue` decimal(19, 10) NULL DEFAULT NULL,
  `youhuijuanchae` decimal(19, 10) NULL DEFAULT NULL,
  `fapiaodanhao` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bucanyudazhejine` decimal(19, 10) NULL DEFAULT NULL,
  `msgdealstate` int NULL DEFAULT NULL,
  `dealstate` int NULL DEFAULT NULL,
  `wmptbillid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `manjianjine` decimal(19, 10) NULL DEFAULT NULL,
  `dantype` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tips` decimal(19, 10) NULL DEFAULT NULL,
  `xjtips` decimal(19, 10) NULL DEFAULT NULL,
  `xyktips` decimal(19, 10) NULL DEFAULT NULL,
  `wmptdaynum` int NULL DEFAULT NULL,
  `additionalcost` decimal(19, 10) NULL DEFAULT NULL,
  `notax` tinyint NULL DEFAULT NULL,
  `additionalchargecp` decimal(19, 10) NULL DEFAULT NULL,
  `payxfdtype` int NULL DEFAULT NULL,
  `danmode` int NULL DEFAULT NULL,
  `uploadtosaas` tinyint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `Is_inline` tinyint NULL DEFAULT NULL,
  `PickUpCode` int NULL DEFAULT NULL,
  `Viewmode` int NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL,
  `takeout_channel` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外卖渠道(如:美团、饿了么等)',
  `takeout_channel_order_number` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外卖渠道订单号',
  `takeout_order_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '外卖订单总金额',
  `commission_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '佣金金额',
  `business_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '商家实收金额',
  `favourable_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '优惠总金额',
  `business_favourable_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '商家优惠金额',
  `platform_favourable_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '平台优惠金额',
  `businesses_deliveryroute_fees` decimal(19, 10) NULL DEFAULT NULL COMMENT '商家配送费',
  `delivery_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '配送费金额',
  `box_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '餐盒费',
  `takeout_pay_amount` decimal(19, 10) NULL DEFAULT NULL COMMENT '外卖实付金额',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_XiaoFeiDanFJZ_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_XiaoFeiDanFJZ_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13412 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for yaoqiuinshifa
-- ----------------------------
DROP TABLE IF EXISTS `yaoqiuinshifa`;
CREATE TABLE `yaoqiuinshifa`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `shifa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeicaipingid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeicaipingpid` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_YaoQiuInShiFa_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_YaoQiuInShiFa_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for yaoqiuinshifafjz
-- ----------------------------
DROP TABLE IF EXISTS `yaoqiuinshifafjz`;
CREATE TABLE `yaoqiuinshifafjz`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `shifa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeicaipingid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeicaipingpid` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_YaoQiuInShiFaFJZ_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_YaoQiuInShiFaFJZ_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for zuofainshifa
-- ----------------------------
DROP TABLE IF EXISTS `zuofainshifa`;
CREATE TABLE `zuofainshifa`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `shifa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caipingzuofapid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caipingzuofaid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jiage` decimal(19, 10) NULL DEFAULT NULL,
  `chengbendanjia` decimal(19, 10) NULL DEFAULT NULL,
  `selfamount` decimal(19, 10) NULL DEFAULT NULL,
  `yaochengyushuliang` tinyint NULL DEFAULT NULL,
  `shufuwufei` tinyint NULL DEFAULT NULL,
  `canyidazhe` tinyint NULL DEFAULT NULL,
  `ishandwrited` tinyint NULL DEFAULT NULL,
  `writer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bumen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jiagongfei` decimal(19, 10) NULL DEFAULT NULL,
  `chengbenzongjia` decimal(19, 10) NULL DEFAULT NULL,
  `fuwufei` decimal(19, 10) NULL DEFAULT NULL,
  `biaoqian` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `biaoqianpid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `biaoqianid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhekoue` decimal(19, 10) NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `chupingbumen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `isyaoqiu` tinyint NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeicaipingid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeicaipingpid` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `shop_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '店铺名称',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开台时间',
  `checkout_time` datetime NULL DEFAULT NULL COMMENT '结账时间',
  `order_sub_type` int NULL DEFAULT NULL COMMENT '账单类型;堂食、外卖、自提',
  `shift_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次',
  `area_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区域名称',
  `table_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台名称',
  `checkout_by` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '标记',
  `saas_order_no` bigint NULL DEFAULT NULL COMMENT '账单流水号',
  `takeout_channel` int NULL DEFAULT NULL COMMENT '外卖渠道',
  `checkout_time_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '餐段',
  `free_service_charge` tinyint NULL DEFAULT NULL COMMENT '免服务费',
  `online` tinyint NULL DEFAULT NULL COMMENT '线上订单',
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '部门',
  `send_number` decimal(19, 10) NULL DEFAULT NULL COMMENT '赠送数量',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_ZuoFaInShiFa_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_ZuoFaInShiFa_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE,
  INDEX `idx_report_date`(`yingyeriqi` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2530636 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for zuofainshifafjz
-- ----------------------------
DROP TABLE IF EXISTS `zuofainshifafjz`;
CREATE TABLE `zuofainshifafjz`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `yingyeriqi` datetime NULL DEFAULT NULL,
  `year` int NULL DEFAULT NULL,
  `month` int NULL DEFAULT NULL,
  `day` int NULL DEFAULT NULL,
  `shifa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caipingzuofapid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caipingzuofaid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jiage` decimal(19, 10) NULL DEFAULT NULL,
  `chengbendanjia` decimal(19, 10) NULL DEFAULT NULL,
  `selfamount` decimal(19, 10) NULL DEFAULT NULL,
  `yaochengyushuliang` tinyint NULL DEFAULT NULL,
  `shufuwufei` tinyint NULL DEFAULT NULL,
  `canyidazhe` tinyint NULL DEFAULT NULL,
  `ishandwrited` tinyint NULL DEFAULT NULL,
  `writer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bumen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `jiagongfei` decimal(19, 10) NULL DEFAULT NULL,
  `chengbenzongjia` decimal(19, 10) NULL DEFAULT NULL,
  `fuwufei` decimal(19, 10) NULL DEFAULT NULL,
  `biaoqian` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `biaoqianpid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `biaoqianid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zhekoue` decimal(19, 10) NULL DEFAULT NULL,
  `unit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `chupingbumen` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `isyaoqiu` tinyint NULL DEFAULT NULL,
  `xiaofeidanid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeicaipingid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `xiaofeicaipingpid` bigint NULL DEFAULT NULL,
  `PIDTmp` bigint NULL DEFAULT NULL,
  `start_time` datetime NULL DEFAULT NULL COMMENT '开台时间',
  `checkout_time` datetime NULL DEFAULT NULL COMMENT '结账时间',
  `order_sub_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '订单子类型',
  `shift_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '班次名称',
  `area_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '区域名称',
  `table_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '桌台名称',
  `checkout_by` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `saas_order_no` bigint NULL DEFAULT NULL COMMENT 'SaaS订单号',
  `takeout_channel` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '外卖渠道',
  `checkout_time_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '结账时段名称',
  `online` tinyint NULL DEFAULT NULL COMMENT '是否线上(0:否,1:是)',
  `department` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '部门',
  `send_number` decimal(19, 10) NULL DEFAULT NULL COMMENT '配送数量',
  `shop_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `free_service_charge` tinyint NULL DEFAULT NULL,
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_ZuoFaInShiFaFJZ_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE,
  INDEX `IDX_ZuoFaInShiFaFJZ_COMPANY_SHOP_YYRQ`(`company_id` ASC, `shop_id` ASC, `yingyeriqi` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17550 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for zuofaleibie
-- ----------------------------
DROP TABLE IF EXISTS `zuofaleibie`;
CREATE TABLE `zuofaleibie`  (
  `pid` bigint NOT NULL AUTO_INCREMENT,
  `company_id` bigint NOT NULL,
  `shop_id` bigint NULL DEFAULT NULL,
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `lmnid` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status_` int NULL DEFAULT NULL,
  `bukeduoxuan` tinyint NULL DEFAULT NULL,
  `isbendi` tinyint NULL DEFAULT NULL,
  `showinyaoqiu` tinyint NULL DEFAULT NULL,
  `ZuoFa` bigint NULL DEFAULT NULL,
  `CaiAndZuoFaLeiBie` bigint NULL DEFAULT NULL,
  `dish_lids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '菜品lids',
  `small_type_lids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '菜品小类lids',
  `super_type_lids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '菜品大类lids',
  `min_cook_number` int NULL DEFAULT NULL COMMENT '必须做法数量',
  `max_cook_number` int NULL DEFAULT NULL COMMENT '最多可选做法数量',
  `fixed_cook` tinyint NULL DEFAULT NULL COMMENT '做法不随菜谱变更',
  PRIMARY KEY (`pid`) USING BTREE,
  UNIQUE INDEX `IDX_U_ZuoFaLeiBie_COMPANY_SHOP_LmnID`(`company_id` ASC, `shop_id` ASC, `lmnid` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 295460 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = COMPRESSED;

SET FOREIGN_KEY_CHECKS = 1;
