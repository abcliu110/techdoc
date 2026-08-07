# 作用域与授权分析

## 1. 租户隔离模型

### 1.1 隔离层级

```
商户 (mid)
    │
    └──▶ 门店 (sid)
            │
            └──▶ 用户 (uid)
                    │
                    └──▶ 角色 (role)
                            │
                            └──▶ 权限 (permission)
```

### 1.2 标识体系

| 标识 | 名称 | 用途 | 范围 |
|------|------|------|------|
| mid | 商户ID | 租户隔离 | 全局唯一 |
| sid | 门店ID | 门店隔离 | 商户内唯一 |
| uid | 用户ID | 用户标识 | 门店内唯一 |
| lid | 逻辑主键 | 记录唯一 | 全局唯一 |

## 2. 权限模型

### 2.1 角色定义

| 角色 | 权限范围 | 说明 |
|------|----------|------|
| 收银员 | 点餐、结账、打印 | 日常收银操作 |
| 店长 | 收银 + 反结账、挂账、报表 | 门店管理 |
| 管理员 | 所有权限 | 系统管理 |

### 2.2 权限矩阵

| 功能 | 收银员 | 店长 | 管理员 |
|------|--------|------|--------|
| 开台 | ✅ | ✅ | ✅ |
| 点餐 | ✅ | ✅ | ✅ |
| 结账 | ✅ | ✅ | ✅ |
| 反结账 | ❌ | ✅ | ✅ |
| 挂账 | ❌ | ✅ | ✅ |
| 赊账还款 | ❌ | ✅ | ✅ |
| 日结 | ❌ | ✅ | ✅ |
| 菜品管理 | ❌ | ✅ | ✅ |
| 桌台管理 | ❌ | ✅ | ✅ |
| 系统配置 | ❌ | ❌ | ✅ |

### 2.3 授权边界

**数据范围约束**：
```
用户可访问数据 = WHERE mid = 用户.mid AND sid IN (用户可访问的门店列表)
```

**操作权限约束**：
```
操作可执行 = 用户.role IN (操作要求的角色列表)
```

## 3. API 授权

### 3.1 接口认证

| 认证方式 | 适用场景 | 说明 |
|----------|----------|------|
| Token | POS 终端 | 设备绑定认证 |
| Cookie | Web 前端 | Session 认证 |
| API Key | 外部系统 | 美团/饿了么 |

### 3.2 接口鉴权

```java
// 鉴权流程
public boolean authorize(String token, String apiPath) {
    // 1. 解析 Token 获取用户信息
    UserInfo user = parseToken(token);

    // 2. 检查用户角色
    if (!hasPermission(user.role, apiPath)) {
        return false;
    }

    // 3. 检查门店权限
    if (!hasStoreAccess(user.sid, apiPath)) {
        return false;
    }

    return true;
}
```

## 4. 数据访问控制

### 4.1 查询约束

**强制约束**：所有数据查询必须包含租户条件

```sql
-- ✅ 正确
SELECT * FROM dwd_bill WHERE mid = ? AND sid = ?;

-- ❌ 错误（缺少 mid/sid）
SELECT * FROM dwd_bill;
```

### 4.2 写入约束

**强制约束**：写入时必须携带租户标识

```java
public void save(DwdBill bill) {
    // 1. 强制校验 mid, sid
    if (bill.getMid() == null || bill.getSid() == null) {
        throw new IllegalArgumentException("mid/sid 不能为空");
    }

    // 2. 校验用户权限
    if (!hasStoreAccess(bill.getMid(), bill.getSid(), user)) {
        throw new UnauthorizedException();
    }

    // 3. 执行写入
    billMapper.insert(bill);
}
```

### 4.3 跨租户访问

**禁止场景**：
- 直接跨 mid 查询
- 直接跨 sid 查询
- 越权访问其他门店数据

**允许场景**：
- 商户管理员查询旗下所有门店
- 平台管理员查询所有商户

## 5. 敏感操作授权

### 5.1 高风险操作

| 操作 | 需要的权限 | 日志要求 |
|------|------------|----------|
| 反结账 | 店长及以上 | 必须记录操作人和原因 |
| 赊账 | 店长及以上 | 必须记录赊账人和还款计划 |
| 日结 | 店长及以上 | 必须记录操作人 |
| 账单作废 | 店长及以上 | 必须记录作废原因 |
| 数据删除 | 管理员 | 必须二次确认 |

### 5.2 操作日志

```sql
-- 操作日志表结构
CREATE TABLE sys_oper_log (
    id BIGINT PRIMARY KEY,
    oper_type VARCHAR(50),      -- 操作类型
    oper_content JSON,          -- 操作内容
    mid BIGINT,                 -- 商户ID
    sid BIGINT,                 -- 门店ID
    user_id BIGINT,             -- 操作人
    user_name VARCHAR(100),     -- 操作人姓名
    ip_address VARCHAR(50),     -- IP 地址
    created_time DATETIME
);
```

## 6. 外部系统授权

### 6.1 美团/饿了么授权

| 系统 | 认证方式 | 授权范围 |
|------|----------|----------|
| 美团开放平台 | AppKey + AppSecret | 授权门店的订单 |
| 饿了么开放平台 | Token | 授权门店的订单 |

### 6.2 支付渠道授权

| 渠道 | 认证方式 | 授权范围 |
|------|----------|----------|
| 微信支付 | 商户号 + API密钥 | 商户的所有门店 |
| 支付宝 | 应用ID + 私钥 | 商户的所有门店 |

## 7. 作用域边界验证

### 7.1 常见越权场景

| 场景 | 检测方式 | 预防措施 |
|------|----------|----------|
| 跨门店访问账单 | 检查 sid 是否匹配 | 中间件强制校验 |
| 跨商户访问数据 | 检查 mid 是否匹配 | 中间件强制校验 |
| 未授权操作 | 检查用户角色 | 权限注解校验 |
| 越权删除 | 检查数据归属 | Service 层校验 |

### 7.2 边界验证 SQL

```sql
-- 检测跨租户数据访问（异常）
SELECT * FROM dwd_bill
WHERE mid = 1001
  AND sid NOT IN (SELECT sid FROM user_store WHERE user_id = :current_user_id);

-- 检测异常数据归属
SELECT * FROM dwd_bill
WHERE mid != :user_mid;
```

## 8. 证据索引

| 分析项 | 证据来源 | 证据类型 |
|--------|----------|----------|
| 租户隔离 | 代码中的 mid/sid 查询 | SRC |
| 权限模型 | 角色相关代码 | SRC |
| 授权边界 | Controller 注解 | SRC |

