# 多租户 SaaS 体系下小程序用户身份识别方案

> 文档版本：v1.0
> 创建日期：2026-09-16
> 适用系统：物业租赁管理系统
> 文档目的：解决多租户 SaaS 架构中，小程序场景下区分不同租户用户的核心问题

---

## 一、问题背景与核心矛盾

### 1.1 业务场景

在物业租赁管理系统的 SaaS 化部署中，存在两类客户：

| 客户类型 | 说明 |
|---------|------|
| 有独立小程序 | 客户拥有自己的微信小程序，`AppID` 独立 |
| 无独立小程序 | 客户使用我方提供的共用小程序，多个租户共用同一个 `AppID` |

### 1.2 核心矛盾

微信小程序提供的用户身份标识体系与业务侧租户概念之间存在天然隔离：

| 小程序能提供 | 小程序不能提供 |
|------------|-------------|
| `openid`（同 AppID 内唯一） | 业务租户语义 |
| `unionid`（需绑定公众号，有条件返回） | 微信不知道我们的租户概念 |
| `session_key` | 任何业务层信息 |

**矛盾的本质：微信只负责回答"这个用户是谁"，不负责"这个用户属于哪个租户"。**

### 1.3 两种场景的命运截然不同

| 场景 | 能否区分租户 | 原因 |
|------|------------|------|
| 客户有独立小程序 | ✅ 可以 | 不同 AppID → 不同 `openid` → 微信层天然隔离 |
| 多租户共用一个小程序 | ❌ 不行 | 同一 AppID → 同一用户 `openid` 相同 → 无法区分租户 |

这是整个问题的分叉口。有独立小程序时，方案简单清晰；共用小程序时，则需要构建额外的租户绑定层。

---

## 二、方案一：客户有独立小程序

### 2.1 原理

每个客户使用自己独立的微信小程序，拥有独立的 `AppID`。微信为不同 AppID 下的同一用户生成不同的 `openid`。因此，通过 `AppID` 即可直接关联到租户。

```
用户 A
    ├── 打开租户 A 的小程序（AppID-A）→ openid-A1 → 租户 A
    └── 打开租户 B 的小程序（AppID-B）→ openid-A2 → 租户 B

（同一个微信用户，不同 AppID，openid 不同）
```

### 2.2 数据库设计

```sql
-- 租户表扩展小程序字段
ALTER TABLE sys_tenant ADD COLUMN mini_program_type VARCHAR(10)
  DEFAULT 'none' COMMENT '小程序类型: own-独立小程序, shared-共用小程序, none-无小程序';

ALTER TABLE sys_tenant ADD COLUMN mini_program_appid VARCHAR(50)
  COMMENT '小程序 AppID（own 和 shared 类型必填）';

ALTER TABLE sys_tenant ADD COLUMN mini_program_appsecret VARCHAR(200)
  COMMENT '小程序 AppSecret（加密存储）';

ALTER TABLE sys_tenant ADD COLUMN mini_program_enabled TINYINT(1)
  DEFAULT 0 COMMENT '小程序功能是否启用';
```

### 2.3 服务端登录流程

```java
/**
 * 客户独立小程序登录
 * 微信层已通过 AppID 完成租户隔离，此处只需按 openid 查找用户
 */
public LoginResp loginByOwnMiniProgram(MiniLoginReq req) {
    // 1. 通过 AppID 确认租户身份
    Tenant tenant = tenantService.getByMiniProgramAppid(req.getAppid());
    if (tenant == null || !tenant.hasOwnMiniProgram()) {
        throw new BusinessException("非法的 AppID，租户不存在或未配置独立小程序");
    }

    // 2. 微信接口：code 换取 openid
    WeChatSession session = wxService.code2Session(req.getAppid(), req.getCode());
    String openid = session.getOpenid();

    // 3. 通过 openid + tenant_id 查找绑定用户
    UserMiniProgramBind bind = bindMapper.selectByOpenidAndTenant(openid, tenant.getId());
    if (bind == null) {
        // 未绑定 → 返回引导注册
        return LoginResp.needRegister(openid, tenant.getId());
    }

    // 4. 生成业务登录态
    return doLogin(bind.getUserId(), tenant.getId());
}
```

### 2.4 特点总结

- **优势**：微信层天然隔离，逻辑简单，无额外的租户识别开销
- **劣势**：客户需要自己注册小程序、配置域名、提交审核，维护成本转移给客户
- **适用**：有一定技术能力的物业企业客户

---

## 三、方案二：多租户共用小程序（核心难点）

这是本方案的核心部分。以下对业界常用方案逐一深入分析其原理、局限和适用条件。

### 3.0 前置约束：微信能提供什么

在共用小程序场景下，我们能拿到的身份信息只有：

```javascript
// 小程序端 wx.login() 拿到 code
wx.login({
    success: res => {
        api.login({ code: res.code })  // code 每次都变，不能用来标识用户
    }
})

// 小程序端 wx.getUserProfile() 拿到加密数据
wx.getUserProfile({
    success: res => {
        // res.encryptedData 和 res.iv 用于解密 unionid（可能为空）
        // res.rawData 包含昵称头像
    }
})
```

服务端用 code 调用微信接口换取：

```java
WeChatSession {
    String openid;     // 一定有，同一 AppID 内唯一
    String session_key; // 用于解密 encryptedData
    String unionid;    // 不一定有！条件：
                       //   ① 小程序绑定了微信开放平台账号
                       //   ② 用户在开放平台下已关联的公众号/网站已授权
                       //   ③ 实际场景中成功率通常低于 60%
}
```

**`unionid` 的局限性**：在 toB 物业租赁场景下，用户大概率从未关注过关联的公众号，`unionid` 为空。所以**不能将 unionid 作为主要用户标识**，只能作为辅助。

### 3.1 方案 A：扫码入口植入租户信息（最优雅的方案）

#### 3.1.1 原理

在用户进入小程序之前，在物理上植入租户标识。租户的所有推广渠道（海报、名片、公众号文章）都通过带参二维码分发，用户扫码即携带租户 ID，后续全程无感知。

```
租户 A 的推广渠道
    ├── 宣传海报 → 扫码 → scene="t=abc123"
    ├── 员工名片 → 扫码 → scene="t=abc123"
    ├── 公众号推文 → 扫码 → scene="t=abc123"
    └── 官网链接 → 打开小程序 → URL 携带 tenant_id

租户 A 的员工 → 扫码进入小程序 → 小程序读取 scene → 自动记住租户
```

#### 3.1.2 微信带参二维码 API

微信小程序支持生成带参二维码，`scene` 参数最大 32 个字符：

```java
/**
 * 生成带参二维码（需要 tenant 的短码）
 * scene 最大32字符，格式: t={shortCode}
 */
public byte[] generateMiniProgramQRCode(Tenant tenant, String page, Integer width) {
    String shortCode = tenant.getShortCode(); // 例如 "abc123"

    // 调用微信接口
    String url = "https://api.weixin.qq.com/wxa/getwxacode?access_token=" + getAccessToken();
    String body = Json.stringify(ImmutableMap.of(
        "scene", "t=" + shortCode,
        "page", page,              // 例如 "pages/index/index"
        "width", width != null ? width : 430,
        "env_version", "release"   // 可选：trial-体验版、develop-开发版
    ));

    return HttpUtil.post(url, body);
}
```

#### 3.1.3 小程序端解析 scene

```javascript
// app.js
App({
    globalData: {
        tenantId: null,
        openid: null,
        userId: null,
    },

    onLaunch(options) {
        this.resolveTenantEntry(options);
    },

    onShow(options) {
        // 从后台切回来也要检查
        this.resolveTenantEntry(options);
    },

    resolveTenantEntry(options) {
        // 场景值来源优先级：扫码 > 分享链接 > 扫码启动参数
        let tenantShortCode = null;

        // 路径①：扫码进入（scene 最大 32 字符）
        if (options.scene) {
            const sceneStr = decodeURIComponent(options.scene);
            const params = this.parseSceneParams(sceneStr); // "t=abc123&s=xxx" → {t: "abc123", s: "xxx"}
            tenantShortCode = params.t;
        }

        // 路径②：页面参数进入
        if (!tenantShortCode && options.query && options.query.tenant_code) {
            tenantShortCode = options.query.tenant_code;
        }

        // 路径③：本地缓存（扫码后已存储）
        if (!tenantShortCode) {
            const cached = wx.getStorageSync('tenant_short_code');
            if (cached) tenantShortCode = cached;
        }

        if (tenantShortCode) {
            // 异步换取 tenant_id 并缓存
            this.resolveTenantId(tenantShortCode);
        }
    },

    parseSceneParams(scene) {
        const result = {};
        scene.split('&').forEach(pair => {
            const [k, v] = pair.split('=');
            if (k && v) result[k] = v;
        });
        return result;
    },

    async resolveTenantId(shortCode) {
        try {
            const res = await wx.request({
                url: `${API_BASE}/mini/resolve-tenant`,
                data: { shortCode }
            });
            if (res.data.code === 0) {
                this.globalData.tenantId = res.data.data.tenantId;
                this.globalData.tenantName = res.data.data.tenantName;
                // 持久化到本地
                wx.setStorageSync('tenant_short_code', shortCode);
                wx.setStorageSync('tenant_id', res.data.data.tenantId);
            }
        } catch (e) {
            console.error('解析租户失败', e);
        }
    }
});
```

#### 3.1.4 服务端根据 shortCode 换取 tenantId

```sql
-- 租户表新增短码字段（用于二维码 scene 参数）
ALTER TABLE sys_tenant ADD COLUMN short_code VARCHAR(20) UNIQUE;

-- 生成短码：取租户名称拼音首字母 + 4位随机数，如 "wygl_001a"
```

```java
/**
 * 根据 shortCode 解析 tenantId
 * 每次扫码/链接进入都会调用此接口，用于建立 session 中的租户上下文
 */
public TenantResolveResp resolveTenantByShortCode(String shortCode) {
    Tenant tenant = tenantMapper.selectByShortCode(shortCode);
    if (tenant == null) {
        throw new BusinessException("无效的租户码");
    }

    // 返回基本信息（不含敏感配置）
    return TenantResolveResp.builder()
        .tenantId(tenant.getId())
        .tenantName(tenant.getName())
        .tenantLogo(tenant.getLogo())
        .hasMiniProgram(tenant.hasOwnMiniProgram())
        .build();
}
```

#### 3.1.5 局限与应对

| 局限 | 影响 | 应对方案 |
|------|------|---------|
| 用户从聊天记录/发现页进入（无 scene） | 约 30% 用户无租户标识 | 兜底：本地有缓存则用缓存；无缓存则引导选择租户 |
| 短码泄漏到其他租户 | 其他租户员工拿到短码进入 | 短码仅用于入口识别，绑定时需二次核身 |
| 短码过于简单易被枚举 | 安全性问题 | 短码不包含敏感数据，配合登录态使用；定期轮换 |

---

### 3.2 方案 B：激活码体系（企业管控能力强）

#### 3.2.1 原理

租户管理员在后台预录入员工信息，为每个员工（或每个部门）生成唯一激活码。员工在小程序中输入激活码完成身份核身，系统建立 openid → user_id → tenant_id 的三元绑定。

#### 3.2.2 激活码类型与对比

| 类型 | 说明 | 管理员工作量 | 安全性 | 适用场景 |
|------|------|------------|--------|---------|
| 通用激活码 | 部门/全员共用，不限人次 | 低 | 低（易泄漏） | 初创小团队 |
| 个人专属码 | 每个员工唯一，一次性使用 | 高 | 高 | 中大型物业企业 |
| 时限激活码 | 一次性 + 有效期限制 | 中 | 高 | 流动性大的岗位 |
| 受控手机号码 | 手机号后4位 + 部门码组合 | 中 | 中 | 平衡安全与便捷 |

#### 3.2.3 数据库设计

```sql
-- 个人专属激活码（推荐）
CREATE TABLE mini_program_invite_code (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    tenant_id       BIGINT NOT NULL,
    employee_id     BIGINT,              -- 关联 sys_user 的员工ID（可选）
    employee_name   VARCHAR(50),          -- 员工姓名（便于管理员识别）
    employee_mobile VARCHAR(20),          -- 员工手机号

    invite_code     VARCHAR(20) NOT NULL UNIQUE,  -- 激活码，如 "A3F7-K9L2"
    code_type       VARCHAR(20) NOT NULL DEFAULT 'personal',  -- personal/department/general

    status          TINYINT NOT NULL DEFAULT 0,  -- 0-未使用 1-已使用 2-已过期 3-已撤销
    expire_time     DATETIME,              -- 过期时间
    used_by         BIGINT,               -- 使用者 user_id
    used_at         DATETIME,             -- 使用时间
    used_openid     VARCHAR(64),           -- 使用时的 openid（防止被冒用）

    create_by       BIGINT,
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_by       BIGINT,
    update_time     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_tenant_id (tenant_id),
    INDEX idx_mobile (employee_mobile),
    INDEX idx_code (invite_code)
) COMMENT '小程序激活码表';

-- 激活码生成规则（示例）
-- 个人码：YWGL-8位字母数字混排，如 "WYGL-A3F7K9L2"（前4位固定为租户标识）
-- 部门码：YWGL-DEPT-001
```

#### 3.2.4 激活码生成逻辑

```java
/**
 * 生成个人专属激活码
 * 规则：4位租户前缀 + 8位随机字符
 * 存储时做 hash（激活时比对原文，防止泄露表数据导致串用）
 */
public String generateInviteCode(Tenant tenant, String employeeName, String mobile) {
    // 1. 生成激活码
    String prefix = tenant.getShortCode().toUpperCase(); // 如 "WYGL"
    String randomPart = RandomStringUtils.randomAlphanumeric(8).toUpperCase();
    String inviteCode = prefix + "-" + randomPart; // 如 "WYGL-A3F7K9L2"

    // 2. 存储时对激活码做摘要（防止数据库泄漏后激活码被滥用）
    String codeHash = DigestUtils.sha256Hex(inviteCode + tenant.getSalt());

    // 3. 有效期默认30天
    LocalDateTime expireTime = LocalDateTime.now().plusDays(30);

    // 4. 写入数据库
    MiniProgramInviteCode record = MiniProgramInviteCode.builder()
        .tenantId(tenant.getId())
        .employeeName(employeeName)
        .employeeMobile(mobile)
        .inviteCode(codeHash)  // 存 hash 不存原文
        .originalCode(inviteCode)  // 管理员可见的原码（生成时一次性返回，之后不再显示）
        .codeType("personal")
        .status(0)
        .expireTime(expireTime)
        .build();
    inviteCodeMapper.insert(record);

    // 5. 返回原文（仅在生成时返回一次，之后不保存不显示）
    return inviteCode;
}
```

#### 3.2.5 激活码使用流程

```java
/**
 * 小程序端激活码激活
 */
public LoginResp activateByInviteCode(String inviteCode, String openid) {
    // 1. hash 后查询（数据库存的是 hash）
    String codeHash = DigestUtils.sha256Hex(inviteCode + tenantContext.getSalt());
    MiniProgramInviteCode code = inviteCodeMapper.selectByCodeHash(codeHash);

    // 2. 验证合法性
    if (code == null) {
        throw new BusinessException("激活码无效");
    }
    if (code.isExpired()) {
        throw new BusinessException("激活码已过期");
    }
    if (code.isUsed()) {
        throw new BusinessException("激活码已被使用");
    }
    if (!Objects.equals(code.getUsedOpenid(), openid) && code.getUsedOpenid() != null) {
        throw new BusinessException("激活码已被其他账号使用");
    }

    // 3. 更新激活码状态
    code.setStatus(1);
    code.setUsedAt(LocalDateTime.now());
    code.setUsedOpenid(openid);
    inviteCodeMapper.updateById(code);

    // 4. 建立 openid → user_id → tenant_id 绑定
    //    如果员工已在系统中（通过手机号关联），直接绑定现有账号
    //    如果是新用户，创建新账号
    User user = userService.getByMobile(code.getEmployeeMobile());
    if (user == null) {
        user = userService.createUserFromMiniProgram(openid, code.getTenantId(), code.getEmployeeMobile());
    }

    // 5. 建立绑定关系
    bindMapper.insertOrUpdate(UserMiniProgramBind.builder()
        .openid(openid)
        .userId(user.getId())
        .tenantId(code.getTenantId())
        .entrySource("invite_code")
        .isVerified(1)
        .verifyMethod("invite_code")
        .build());

    // 6. 写死租户关系（一人一租户场景）
    //    或写入 user_tenant_relation（一人多租户场景）
    userTenantRelationMapper.insert(UserTenantRelation.builder()
        .userId(user.getId())
        .tenantId(code.getTenantId())
        .role("member")
        .isPrimary(1)
        .bindTime(LocalDateTime.now())
        .build());

    // 7. 返回登录态
    return doLogin(user.getId(), code.getTenantId());
}
```

#### 3.2.6 局限与应对

| 局限 | 影响 | 应对方案 |
|------|------|---------|
| 管理员需要预录入员工 | 有配置工作量 | 提供 Excel 批量导入功能 |
| 员工离职后需回收激活码 | 运营成本 | 激活码撤销功能 + 离职账号自动禁用 |
| 激活码被截图外泄 | 非目标租户人员进入 | 配合手机号后4位验证（激活时输入手机号后4位） |

---

### 3.3 方案 C：手机号 + 租户核身（自助式，适合客户）

#### 3.3.1 适用场景

适用于非企业员工的外部人员（业主、租客、访客）。这类人员没有管理员分配的激活码，通过手机号自主申请加入租户。

#### 3.3.2 核心流程

```
用户输入手机号 → 系统发送验证码 → 用户输入验证码 → 系统判断该手机号属于哪个租户 → 绑定
```

**问题：手机号如何关联租户？** 有以下几种方式：

| 方式 | 说明 | 实现难度 |
|------|------|---------|
| 手机号精确匹配 | 管理员先录入员工手机号，绑定到租户 | 简单，但需提前录入 |
| 房号匹配 | 业主/租客的手机号与房产信息关联，自动识别租户 | 需物业系统有房号数据 |
| 验证码中转 | 用户填手机号 + 期望加入的租户 → 系统向管理员发审核请求 → 管理员审核通过后发验证码 | 复杂但安全 |
| 管理员扫码确认 | 用户填手机号 → 管理员小程序扫码确认身份 | 体验好但需管理员在线 |

#### 3.3.3 方案 C-1：管理员预录入手机号（推荐 for 员工）

```java
/**
 * 员工手机号注册/激活流程
 * 前提：管理员已在后台录入员工的手机号和身份信息
 */
public void sendVerificationCode(String mobile, Long tenantId) {
    // 1. 验证该手机号是否在当前租户的员工列表中
    Employee employee = employeeMapper.selectByMobileAndTenant(mobile, tenantId);
    if (employee == null) {
        throw new BusinessException("该手机号未在租户员工列表中登记，请联系管理员");
    }

    // 2. 生成6位数字验证码（5分钟有效）
    String code = String.format("%06d", new Random().nextInt(999999));
    redisTemplate.opsForValue().set(
        "mp:verify:" + mobile + ":" + tenantId,
        code,
        5, TimeUnit.MINUTES
    );

    // 3. 发送短信
    smsService.send(mobile, "您的验证码是：" + code + "，5分钟内有效。");
}
```

#### 3.3.4 方案 C-2：物业房号自动匹配（推荐 for 业主/租客）

物业租赁系统的独特优势：**天然有房号-手机号关系**。

```java
/**
 * 通过房产自动识别租户
 * 适用于业主和租客：他们的手机号早已在物业系统中与具体房间关联
 */
public LoginResp loginByRoomBinding(String openid, String phone) {
    // 1. 通过手机号查找关联的房产记录
    List<Room> rooms = roomMapper.selectByOwnerMobile(phone);

    if (rooms.isEmpty()) {
        // 该手机号在系统中无房产记录 → 走通用注册流程
        return handleUnboundUser(openid, phone);
    }

    if (rooms.size() == 1) {
        // 只有一个房产 → 自动识别租户
        Room room = rooms.get(0);
        return bindAndLogin(openid, phone, room.getTenantId());
    }

    // 有多个房产（同一手机号在多个租户下有房）→ 让用户选择租户
    List<Long> candidateTenantIds = rooms.stream()
        .map(Room::getTenantId)
        .distinct()
        .collect(Collectors.toList());
    return LoginResp.needSelectTenant(openid, phone, candidateTenantIds);
}
```

#### 3.3.5 方案 C-3：双向确认模式（最安全）

管理员添加员工时，需要员工本人在小程序端确认。

```
管理员后台 → 输入员工手机号 → 发送邀请
    ↓
员工收到短信"您被邀请加入XX物业，是否同意？"
    ↓
员工打开小程序 → 输入手机号 → 系统识别为待确认邀请
    ↓
员工点击"确认加入" → 绑定 openid + user_id + tenant_id
```

```sql
CREATE TABLE mini_program_invitation (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    tenant_id       BIGINT NOT NULL,
    employee_mobile VARCHAR(20) NOT NULL,
    invite_token    VARCHAR(64) NOT NULL UNIQUE,  -- 一次性 token
    status          TINYINT DEFAULT 0,  -- 0-待确认 1-已接受 2-已拒绝 3-已过期
    expire_time     DATETIME,
    accepted_at     DATETIME,
    accepted_openid VARCHAR(64),

    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_mobile (employee_mobile),
    INDEX idx_token (invite_token)
) COMMENT '小程序邀请确认表';
```

---

### 3.4 方案 D：unionid 关联（仅作辅助）

#### 3.4.1 原理

微信 `unionid` 在以下条件同时满足时返回：
- 小程序绑定了微信开放平台（公众平台账号）
- 用户在开放平台下已关联的公众号有过授权

```java
/**
 * 通过 unionid 登录（仅作为辅助路径）
 * unionid 在同一开放平台下唯一，可跨小程序/公众号/网站识别同一用户
 */
public LoginResp loginByUnionid(String encryptedData, String iv, String sessionKey) {
    // 1. 解密获取 unionid
    WxUserInfo wxUserInfo = WxCryptUtil.decrypt(encryptedData, iv, sessionKey);
    String unionid = wxUserInfo.getUnionId();
    String nickname = wxUserInfo.getNickName();

    if (unionid == null) {
        // unionid 为空 → 降级到其他方案
        throw new BusinessException("无法获取微信 UnionID，请使用其他方式登录");
    }

    // 2. 通过 unionid 查找绑定用户
    UserMiniProgramBind bind = bindMapper.selectByUnionid(unionid);
    if (bind != null) {
        return doLogin(bind.getUserId(), bind.getTenantId());
    }

    // 3. unionid 命中但无租户绑定 → 提示用户选择租户
    return LoginResp.needSelectTenantByUnionid(unionid);
}
```

#### 3.4.2 unionid 的局限

| 限制 | 说明 | 实际影响 |
|------|------|---------|
| 需开放平台认证 | 需企业主体，每年 300 元认证费 | 成本投入 |
| 用户需在关联公众号授权 | toB 场景员工不一定关注过公众号 | 成功率不稳定 |
| 小程序未强制获取手机号 | 隐私政策收紧后用户可拒绝 | 数据不全 |

**结论：unionid 方案只能作为辅助路径（已有账号的快速登录），不能作为主要身份标识。**

---

## 四、混合策略：分阶段识别方案

### 4.1 设计思路

将用户进入小程序到完成租户绑定的过程分为多个阶段，每阶段有对应的识别/绑定策略，覆盖率逐级提升。

```
┌─────────────────────────────────────────────────────────┐
│  阶段一：入口识别（覆盖 60%~70% 用户）                      │
│  ├── 扫码进入 → scene 携带 tenant_short_code              │
│  ├── 分享链接 → URL 参数携带 tenant_code                   │
│  └── 公众号菜单 → 网页授权后打开小程序带参数                  │
│       ↓ 命中 → 直接建立上下文 ↓                             │
│                                                         │
│  阶段二：缓存识别（覆盖 20%~25% 用户）                      │
│  ├── 用户曾扫码进入过 → 本地存储了 tenant_id                 │
│  └── 再次进入 → 直接用缓存的租户上下文                       │
│       ↓ 命中 → 直接建立上下文 ↓                             │
│                                                         │
│  阶段三：绑定识别（覆盖 5%~10% 用户）                       │
│  ├── 查 openid → 已有绑定记录 → 直接登录                     │
│  └── openid 无绑定 → 引导激活/注册流程                       │
│       ↓ 命中 → 完成绑定 ↓                                  │
│                                                         │
│  阶段四：兜底（覆盖 1%~5% 边缘用户）                        │
│  └── 所有方式都失败 → 进入租户选择页（手机号后4位匹配）        │
└─────────────────────────────────────────────────────────┘
```

### 4.2 完整登录流程图

```
用户打开小程序
      │
      ▼
┌─────────────┐     有     ┌──────────────────┐
│  是否有     │──────────→│  进入主页         │
│  有效登录态  │            │  带上 tenant_id  │
└──────┬──────┘            └──────────────────┘
       │ 无
       ▼
┌─────────────────────────┐
│  wx.login() 获取 code   │
│  wx.getUserProfile()    │
│  获取 encryptedData/iv  │
└──────────┬──────────────┘
           │
           ▼
┌─────────────────────────┐
│  调用 /mini/login 接口   │
│  提交: code + 加密数据   │
└──────────┬──────────────┘
           │
     ┌─────┴─────┐
     │  解析场景  │
     │ options   │
     │ .scene    │
     └─────┬─────┘
           │
     ┌─────┴─────┐
     │ scene 有  │
     │ tenant    │
     │ shortCode?│
     └─────┬─────┘
       Yes │    No
      ┌────┴────┐
      ▼        ▼
┌──────────┐  ┌──────────────────┐
│ 换取      │  │ 查 openid 绑定表 │
│ tenantId  │  └────────┬─────────┘
└────┬─────┘           │
     │          ┌──────┴──────┐
     └────┬─────┤   有绑定?   │
          │     └──────┬──────┘
          │      Yes  │  No
          │      ┌────┴────┐
          │      ▼         ▼
          │  ┌────────┐  ┌────────────────┐
          │  │ 登录   │  │ 引导激活流程   │
          │  │ 成功  │  │（激活码/手机号）│
          │  └────────┘  └───────┬────────┘
          │                      │
          └──────┬──────────────┘
                 ▼
         ┌──────────────────┐
         │  生成 JWT Token  │
         │  返回用户信息     │
         │  返回租户上下文   │
         └──────────────────┘
```

---

## 五、核心数据模型

### 5.1 用户-小程序绑定表（最核心的一张表）

这张表是所有登录路径的终点，是整个识别体系的中枢。

```sql
CREATE TABLE user_mini_program_bind (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT,
    openid              VARCHAR(64) NOT NULL COMMENT '微信 openid',
    unionid             VARCHAR(64) COMMENT '微信 unionid（可能为空）',
    appid               VARCHAR(50) NOT NULL COMMENT '小程序 AppID',

    user_id             BIGINT COMMENT '绑定的系统用户ID',
    tenant_id           BIGINT COMMENT '当前活跃租户ID',

    -- 渠道信息
    entry_source        VARCHAR(20) COMMENT '入口来源: qr_code/scan/invite_code/phone/wechat_official/h5/search',

    -- 核身信息
    is_verified         TINYINT(1) DEFAULT 0 COMMENT '是否已核身验证',
    verify_method       VARCHAR(20) COMMENT '核身方式: invite_code/phone/admin/wechat_official/qr_scan',

    -- 身份来源
    bind_source         VARCHAR(20) DEFAULT 'activate' COMMENT '绑定来源: activate-激活绑定/admin-管理员添加/import-批量导入',

    -- 时间戳
    first_bind_time     DATETIME COMMENT '首次绑定时间',
    last_login_time     DATETIME COMMENT '最后登录时间',
    update_time         DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_openid_appid (openid, appid),
    INDEX idx_user_id (user_id),
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_unionid (unionid)
) COMMENT '用户-小程序绑定表';
```

### 5.2 用户-租户关系表（一人多租户支持）

```sql
CREATE TABLE user_tenant_relation (
    id                  BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id             BIGINT NOT NULL,
    tenant_id           BIGINT NOT NULL,

    -- 角色与权限
    role                VARCHAR(20) DEFAULT 'member' COMMENT '角色: admin/manager/member/owner/tenant',
    role_type           VARCHAR(20) COMMENT '角色细分: property_admin/property_staff/owner/tenant_guest',

    -- 租户身份
    is_primary          TINYINT(1) DEFAULT 0 COMMENT '是否为主租户（切换租户时的默认）',
    status              TINYINT(1) DEFAULT 1 COMMENT '状态: 1-正常 0-禁用',

    -- 来源信息
    source              VARCHAR(20) COMMENT '加入来源: invite_code/phone_binding/admin_add/self_register/room_binding',

    -- 时间戳
    bind_time           DATETIME,
    expire_time         DATETIME COMMENT '有效期（临时账号）',
    unbind_time         DATETIME COMMENT '解绑时间',

    create_by           BIGINT,
    create_time         DATETIME DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uk_user_tenant (user_id, tenant_id),
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_role (role)
) COMMENT '用户-租户关系表（支持一人多租户）';
```

### 5.3 租户短码表

```sql
CREATE TABLE tenant_short_code (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT,
    tenant_id       BIGINT NOT NULL UNIQUE,
    short_code      VARCHAR(20) NOT NULL UNIQUE COMMENT '小程序入口短码',
    code_type       VARCHAR(10) DEFAULT 'qr' COMMENT '码类型: qr-二维码/link-链接',
    is_active       TINYINT(1) DEFAULT 1,
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_short_code (short_code)
) COMMENT '租户小程序入口短码表';
```

### 5.4 ER 关系图

```
┌──────────────────┐       ┌────────────────────┐
│   sys_tenant     │       │ user_tenant_relation│
│──────────────────│       │────────────────────│
│ id (PK)          │◄──────│ user_id             │
│ name             │       │ tenant_id (FK)──────┤
│ short_code       │       │ role                │
│ mini_program_type│       │ is_primary          │
│ mini_program_appid│      │ bind_time           │
└────────┬─────────┘       └─────────┬───────────┘
         │                              │
         │         ┌────────────────────┘
         │         │
         ▼         ▼
┌──────────────────────┐        ┌──────────────────┐
│ user_mini_program_bind│───────│    sys_user      │
│──────────────────────│        │──────────────────│
│ openid                │        │ id (PK)          │
│ unionid               │        │ user_type        │
│ appid                 │        │ mobile           │
│ user_id ──────────────┘        │ nickname         │
│ tenant_id              │        │ status           │
│ entry_source           │        └──────────────────┘
│ is_verified            │
│ verify_method          │
│ first_bind_time        │
└────────────────────────┘
```

---

## 六、服务端接口设计

### 6.1 登录接口（统一入口）

```
POST /api/infra/mini-program/login
Content-Type: application/json

请求体：
{
    "code": "061Xfxxxxxx",           // wx.login 获取的 code
    "encryptedData": "xxxx",         // wx.getUserProfile 获取的加密数据
    "iv": "xxxx",                    // 解密向量
    "scene": "t=abc123",             // 可选：场景值
    "shareTicket": "xxxx"            // 可选：群分享 ticket
}

响应（成功）：
{
    "code": 0,
    "data": {
        "token": "eyJhbGciOiJIUzI1NiIs...",
        "userInfo": {
            "id": 1001,
            "nickname": "张三",
            "avatar": "https://...",
            "mobile": "138****1234"
        },
        "tenantInfo": {
            "id": 10,
            "name": "XX物业管理处",
            "logo": "https://..."
        },
        "needBind": false,
        "bindStatus": {
            "isVerified": true,
            "verifyMethod": "invite_code",
            "roles": ["property_staff"]
        }
    }
}

响应（需激活）：
{
    "code": 0,
    "data": {
        "needBind": true,
        "bindOptions": {
            "supportInviteCode": true,
            "supportPhone": true,
            "tenantCandidates": [],   // 如果通过手机号识别到候选租户
            "entryTenant": {          // 如果从 scene 识别到了租户
                "id": 10,
                "name": "XX物业管理处"
            }
        }
    }
}
```

### 6.2 激活码激活接口

```
POST /api/infra/mini-program/activate/invite-code
{
    "code": "061Xfxxxxxx",        // 登录 code
    "inviteCode": "WYGL-A3F7K9L2", // 激活码
    "mobileLast4": "1234"         // 可选：手机号后4位（增强校验）
}

响应：
{
    "code": 0,
    "data": {
        "token": "...",
        "tenantInfo": {
            "id": 10,
            "name": "XX物业管理处"
        }
    }
}
```

### 6.3 短码解析接口

```
GET /api/infra/mini-program/resolve-tenant?shortCode=abc123

响应：
{
    "code": 0,
    "data": {
        "tenantId": 10,
        "tenantName": "XX物业管理处",
        "tenantLogo": "https://...",
        "hasMiniProgram": false
    }
}
```

---

## 七、安全设计

### 7.1 激活码安全

| 风险 | 应对措施 |
|------|---------|
| 激活码枚举爆破 | 5分钟内连续5次错误锁定 + 图形验证码 |
| 激活码截图外泄 | 配合手机号后4位校验；激活码30天过期自动失效 |
| 离职员工仍能登录 | 管理员可撤销激活码；员工离职时同步禁用账号 |
| openid 被滥用 | 激活码使用时记录 openid，同一码不可被不同 openid 使用 |

### 7.2 Token 安全

| 风险 | 应对措施 |
|------|---------|
| Token 泄漏 | JWT 中嵌入 tenant_id，校验时验签 + 验 tenant 匹配 |
| Token 跨租户使用 | 请求时校验 token.tenant_id == 请求目标 tenant_id |
| 小程序 Secret 泄漏 | AppSecret 仅服务端使用，不存在于小程序前端代码中 |

### 7.3 数据隔离

| 层级 | 措施 |
|------|------|
| 接口层 | 所有接口必须带 tenant_id 或从 token 中解析 |
| Service 层 | 强制 TenantContextHolder，设置当前租户线程变量 |
| DAO 层 | MyBatis 插件自动注入 tenant_id 条件，禁止跨租户查询 |
| 数据库层 | 核心表设置 tenant_id 为必填字段，无 tenant_id 的操作抛出异常 |

```java
// TenantContextHolder 确保每个请求在明确的租户上下文中运行
public class TenantContextHolder {
    private static final ThreadLocal<Long> TENANT_ID = new ThreadLocal<>();

    public static void setTenantId(Long tenantId) {
        TENANT_ID.set(tenantId);
    }

    public static Long getTenantId() {
        return TENANT_ID.get();
    }

    public static void clear() {
        TENANT_ID.remove();
    }
}

// 登录时从 token 中恢复租户上下文
@Aspect
@Component
public class TenantContextAspect {
    @Around("@annotation(requiresTenant)")
    public Object setTenantContext(ProceedingJoinPoint pjp, RequiresTenant requiresTenant) throws Throwable {
        Long tenantId = getTenantIdFromToken();
        if (tenantId == null) {
            throw new BusinessException("无法获取租户上下文，请重新登录");
        }
        TenantContextHolder.setTenantId(tenantId);
        try {
            return pjp.proceed();
        } finally {
            TenantContextHolder.clear();
        }
    }
}
```

---

## 八、方案对比与选型建议

| 维度 | 扫码入口 | 激活码 | 手机号核身 | unionid |
|------|---------|--------|-----------|---------|
| **覆盖场景** | 80% 扫码用户 | 企业员工 | 业主/租客 | 已有账号用户 |
| **用户感知** | 无感知（最优） | 一次性激活 | 首次验证 | 无感知 |
| **配置成本** | 低（后台一键生成） | 高（需录入员工） | 中（需关联房号） | 高（需开放平台） |
| **安全性** | 中（短码暴露，但绑定需二次核身） | 高（个人码+时效） | 中 | 高 |
| **一人多租户** | 自动识别多个租户 | 需分配多租户码 | 自动识别多个租户 | 自动关联 |
| **员工离职后** | 自动失效（撤销绑定） | 撤销激活码 | 删除手机号绑定 | 解除 unionid 关联 |

### 8.1 按客户类型选型

| 客户类型 | 推荐方案 | 原因 |
|---------|---------|------|
| 有独立小程序的大型物业 | 方案一（AppID 隔离） | 最简单，微信层隔离 |
| 中型物业（10~200人） | 激活码体系 + 扫码入口 | 企业可控，激活码可追溯 |
| 小型物业/个人房东 | 扫码入口 + 手机号核身 | 低配置成本，用户自助 |
| 业主/租客端 | 房号自动匹配 + 手机号验证 | 天然有房产数据，无需配置 |

### 8.2 实施优先级

**第一期（MVP）**：扫码入口 + 激活码（覆盖 80% 场景）
**第二期**：手机号核身 + 房号自动匹配（覆盖业主/租客）
**第三期**：管理员后台 + Excel 批量导入 + 离职账号管理
**第四期**：unionid 关联 + 跨渠道用户合并

---

## 九、文档变更记录

| 版本 | 日期 | 修改内容 | 修改人 |
|------|------|---------|--------|
| v1.0 | 2026-09-16 | 初始版本，完成核心方案设计 | - |

---

## 十、附录

### 附录 A：微信小程序登录时序图

```
┌────────┐    ┌────────────┐   ┌────────────┐   ┌──────────┐
│  用户   │    │  小程序端   │   │  服务端     │   │  微信服务器 │
└───┬────┘    └─────┬──────┘   └──────┬─────┘   └────┬─────┘
    │               │                  │              │
    │ 1.点击登录     │                  │              │
    │───────────────→│                  │              │
    │               │ 2.wx.login()     │              │
    │               │ 获取 code         │              │
    │               │──────────────────│              │
    │               │                  │ 3.code       │
    │               │                  │─────────────→│
    │               │                  │←─────────────│
    │               │  4.openid+session │  session_key │
    │               │←─────────────────│              │
    │               │                  │              │
    │               │ 5.wx.getUserProfile()            │
    │               │ 获取 encryptedData               │
    │               │──────────────────│              │
    │               │ 6.encryptedData+ │              │
    │               │    iv+code        │              │
    │               │───────────────→│              │
    │               │                  │ 7.用session_key解密              │
    │               │                  │ 8.查绑定表      │
    │               │                  │ 9.建立/验证绑定 │
    │               │ 10.JWT Token     │              │
    │               │←───────────────│              │
    │ 11.登录成功    │                  │              │
    │←───────────────│                  │              │
    │               │                  │              │
```

### 附录 B：若依框架扩展点

若依框架（RuoYi-Vue-Pro）已有租户模块（`system` 模块），小程序绑定功能建议放在 `infra`（基础设施）模块，新增文件：

```
ruoyi-modules/
├── ruoyi-system/
│   └── src/main/java/com/ruoyi/system/
│       ├── domain/vo/
│       │   └── MiniProgramLoginReq.java
│       ├── mapper/
│       │   ├── UserMiniProgramBindMapper.java
│       │   └── UserTenantRelationMapper.java
│       └── service/
│           ├── IMiniProgramLoginService.java
│           ├── IInviteCodeService.java
│           └── IUserTenantRelationService.java
│
├── ruoyi-infra/
│   └── src/main/java/com/ruoyi/infra/
│       ├── controller/mini/MiniProgramController.java
│       ├── service/impl/MiniProgramLoginServiceImpl.java
│       └── service/impl/InviteCodeServiceImpl.java
│
└── ruoyi-common/
    └── common/core/
        ├── context/TenantContextHolder.java
        └── security/TenantTokenFilter.java
```

### 附录 C：相关配置项

```yaml
# application.yml
ruoyi:
  mini-program:
    # 共用小程序配置（多个租户共用）
    shared-appid: wx1234567890abcdef
    shared-appsecret: ${WX_SHARED_APPSECRET}

    # 激活码配置
    invite-code:
      expire-days: 30
      max-retry: 5
      lock-minutes: 10

    # 验证码配置
    sms:
      expire-minutes: 5
      max-send-per-day: 10
```
