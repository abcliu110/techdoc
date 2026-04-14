-- 商户表
select * from sc_merchant sm where sm.company_id   = 159411180237043484
-- 门店表
select * from sc_store ss  where ss.company_id   = 159411180237043484

--门店表
select * from sc_store ss  where ss.shop_id  = 159426147207078756

-- 设备表
select * from pos_dev where mid = 159411180237043484 and sid = 159426147207078756

--微信小程序配置表
select * from a_wechat.wx_app_config

--发券表
select * from  gylregdb.sc_mall_coupon_order where openid = 'o2SeR5TNG1V4Jjpm_3QDbMBdxifw'


--会员卡表
select * from gylregdb.crm_card where phone = '18923865943'

  SELECT
    mid,
    sid,
    lid,
    type,
    merchant_name,
    merchant_no,
    app_id,
    api_shop_id,
    deleted,
    created_time,
    updated_time
  FROM pay_channel
  WHERE mid = 159411180237043484
    AND deleted = 0
  ORDER BY lid;
  
  
  select cc.merchant_name,c.* from pay_store_and_channel c inner join pay_channel cc on c.channel_no  = cc.lid and c.mid = 159411180237043484 and c.sid = 159411180237074902
  
-- 大类表
select * from gylregdb.sc_dish_type 

-- 食品表
select * from gylregdb.sc_dish sd


-- 角色表
select * from a_platform.sys_role



