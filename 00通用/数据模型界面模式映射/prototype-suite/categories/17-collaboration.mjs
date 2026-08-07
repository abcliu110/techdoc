function mount(ctx, html) {
  ctx.stage.innerHTML = `<div class="prototype-demo">${html}<output class="prototype-state" data-demo-state aria-live="polite"></output></div>`;
  const q = (selector) => ctx.stage.querySelector(selector);
  const qa = (selector) => [...ctx.stage.querySelectorAll(selector)];
  const state = (value) => { q("[data-demo-state]").textContent = String(value); q("[data-demo-state]").dataset.state = String(value); ctx.setStatus(value, value); };
  const on = (selector, type, listener) => ctx.on(q(selector), type, listener);
  return { q, qa, state, on };
}

function appendTextMessage(container, author, value) {
  const article = document.createElement("article");
  const strong = document.createElement("strong");
  strong.textContent = author;
  const text = document.createElement("p");
  text.textContent = value;
  article.append(strong, text);
  container.append(article);
}

export function renderInstantChat(ctx) {
  const ui = mount(ctx, `<div data-messages><article><strong>林晓</strong><p>合同已发给客户。</p></article></div><label>消息 <input data-input aria-label="消息" value="<img src=x onerror=alert(1)>"></label><button data-action>安全发送</button>`);
  ui.on("[data-action]", "click", () => { const value = ui.q("[data-input]").value; appendTextMessage(ui.q("[data-messages]"), "我", value); ui.state(`chat:sent;messages:2;text-length:${value.length}`); });
  ui.state("chat:connected;messages:1");
}

export function renderConversationList(ctx) {
  const ui = mount(ctx, `<ul><li><button data-conversation="sales">销售协作组 <b data-badge>3</b></button></li><li><button data-conversation="finance">财务对账</button></li></ul><article data-active>未选择会话</article><button data-action>打开销售协作组</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-active]").textContent = "销售协作组 · 最近消息：报价已确认"; ui.q("[data-badge]").textContent = "0"; ui.state("conversation:sales;unread:0"); });
  ui.state("conversation:none;unread:3");
}

export function renderComments(ctx) {
  const ui = mount(ctx, `<article data-comment><p>订单折扣需要复核。</p><span data-status>未解决</span></article><button data-action>标记评论已解决</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-status]").textContent = "已解决 · 由我处理"; ui.q("[data-comment]").style.opacity = ".65"; ui.state("comment:resolved;open:0"); });
  ui.state("comment:open;open:1");
}

export function renderThreadedReplies(ctx) {
  const ui = mount(ctx, `<article><p>主评论：是否使用新版合同？</p><div data-replies><p>回复 1：法务已审核。</p><p>回复 2：客户已同意。</p></div></article><button data-action aria-expanded="true">折叠 2 条回复</button>`);
  let open = true;
  ui.on("[data-action]", "click", () => { open = !open; ui.q("[data-replies]").hidden = !open; ui.q("[data-action]").setAttribute("aria-expanded", String(open)); ui.q("[data-action]").textContent = open ? "折叠 2 条回复" : "展开 2 条回复"; ui.state(`thread:replies:${open ? "expanded" : "collapsed"};count:2`); });
  ui.state("thread:replies:expanded;count:2");
}

export function renderDocumentAnnotation(ctx) {
  const ui = mount(ctx, `<p>合同付款周期为 <mark data-anchor>30 天</mark>。</p><aside data-note hidden>批注：应改为 45 天 · 锚点 range-18-22</aside><button data-action>为选中文本添加批注</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-note]").hidden = false; ui.q("[data-anchor]").style.background = "#ffd166"; ui.state("annotation:range-18-22;comments:1"); });
  ui.state("annotation:none;comments:0");
}

export function renderImageAnnotation(ctx) {
  const ui = mount(ctx, `<div data-image style="position:relative;width:320px;height:150px;background:#dbe7ef"><span>仓库平面图</span></div><button data-action>在坐标 68%,42% 添加标记</button>`);
  ui.on("[data-action]", "click", () => { const marker = document.createElement("button"); marker.textContent = "1"; marker.setAttribute("aria-label", "图片批注 1"); Object.assign(marker.style, { position: "absolute", left: "68%", top: "42%" }); ui.q("[data-image]").append(marker); ui.state("image-annotation:x:68;y:42;count:1"); });
  ui.state("image-annotation:count:0");
}

export function renderMentionPicker(ctx) {
  const ui = mount(ctx, `<label>评论 <input data-input aria-label="评论" value="请 @陈敏 审核"></label><div data-candidates>候选：陈敏（财务总监）、陈明（会计）</div><button data-action>选择陈敏并生成提及</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-input]").value = "请 @陈敏 审核"; ui.q("[data-candidates]").textContent = "已提及：陈敏（user-102）"; ui.state("mention:user-102;notified:true"); });
  ui.state("mention:query:陈敏;candidates:2");
}

export function renderMessageCenter(ctx) {
  const ui = mount(ctx, `<div data-tabs><button>全部 5</button><button>待办 2</button></div><article data-message>合同审批待处理</article><button data-action>处理并归档当前消息</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-message]").textContent = "合同审批已处理 · 已归档"; ui.state("message-center:archived:1;pending:1;all:5"); });
  ui.state("message-center:pending:2;all:5");
}

export function renderNotificationCenter(ctx) {
  const ui = mount(ctx, `<label>过滤 <select data-filter aria-label="通知过滤"><option value="all">全部</option><option value="unread">未读</option></select></label><ul data-list><li data-unread>库存低于阈值</li><li>日报已生成</li></ul><button data-action>只看未读并标记已读</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-filter]").value = "unread"; ui.q("[data-list]").innerHTML = "<li>库存低于阈值 · 已读</li>"; ui.state("notifications:filter:unread;visible:1;unread:0"); });
  ui.state("notifications:filter:all;visible:2;unread:1");
}

export function renderOnlinePresence(ctx) {
  const ui = mount(ctx, `<ul><li data-user="lin">林晓 · 在线</li><li data-user="chen">陈敏 · 离线</li></ul><button data-action>接收陈敏上线事件</button>`);
  ui.on("[data-action]", "click", () => { ui.q('[data-user="chen"]').textContent = "陈敏 · 在线 · 正在查看本页"; ui.state("presence:online:2;viewers:2"); });
  ui.state("presence:online:1;viewers:1");
}

export function renderCollaborativeCursor(ctx) {
  const ui = mount(ctx, `<div data-canvas style="height:140px;position:relative;border:1px solid #aaa"><span data-cursor style="position:absolute;left:20px;top:20px">陈敏 ▸</span></div><button data-action>同步陈敏光标位置</button>`);
  ui.on("[data-action]", "click", () => { Object.assign(ui.q("[data-cursor]").style, { left: "180px", top: "80px" }); ui.state("cursor:user-102;x:180;y:80;revision:8"); });
  ui.state("cursor:user-102;x:20;y:20;revision:7");
}

export function renderCollaborativeEditing(ctx) {
  const ui = mount(ctx, `<textarea data-doc aria-label="协作文档">第一版合同条款</textarea><div data-users>林晓正在编辑</div><button data-action>合并陈敏的远程编辑</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-doc]").value = "第二版合同条款（陈敏补充付款周期）"; ui.q("[data-users]").textContent = "林晓、陈敏已同步到版本 12"; ui.state("collab-doc:revision:12;editors:2;merged:true"); });
  ui.state("collab-doc:revision:11;editors:1");
}

export function renderConflictResolver(ctx) {
  const ui = mount(ctx, `<div style="display:grid;grid-template-columns:1fr 1fr;gap:8px"><article>我的版本：30 天付款</article><article>远程版本：45 天付款</article></div><div data-result>存在冲突</div><button data-action>选择远程版本并合并</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-result]").textContent = "已合并：45 天付款；生成版本 13"; ui.state("conflict:resolved;choice:remote;revision:13"); });
  ui.state("conflict:unresolved;versions:local,remote");
}

export function renderActivityTimeline(ctx) {
  const ui = mount(ctx, `<label>事件类型 <select data-filter aria-label="活动类型"><option value="all">全部</option><option value="status">状态变更</option></select></label><ol data-events><li>09:20 创建订单</li><li>10:00 状态变更：待审→通过</li><li>10:12 添加评论</li></ol><button data-action>只看状态变更</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-filter]").value = "status"; ui.q("[data-events]").innerHTML = "<li>10:00 状态变更：待审→通过</li>"; ui.state("timeline:filter:status;events:1"); });
  ui.state("timeline:filter:all;events:3");
}

export function renderOperationLog(ctx) {
  const ui = mount(ctx, `<table><tbody><tr><td>10:32</td><td>更新订单</td><td><button data-detail>详情</button></td></tr></tbody></table><pre data-json hidden></pre><button data-action>展开操作详情</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-json]").hidden = false; ui.q("[data-json]").textContent = JSON.stringify({ field: "amount", before: 1200, after: 1500 }, null, 2); ui.state("operation-log:event:update-order;detail:expanded"); });
  ui.state("operation-log:detail:collapsed");
}

export function renderAuditTrail(ctx) {
  const ui = mount(ctx, `<ol><li data-event="1">创建 · hash a1</li><li data-event="2">审批 · hash b2</li><li data-event="3">发布 · hash c3</li></ol><div data-proof>未校验</div><button data-action>校验审计链</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-proof]").textContent = "3/3 事件哈希连续，签名有效"; ui.state("audit-chain:valid;events:3;broken:0"); });
  ui.state("audit-chain:unchecked;events:3");
}

export function renderTicketConversation(ctx) {
  const ui = mount(ctx, `<article>客户：设备无法启动</article><label>回复 <input data-reply aria-label="工单回复" value="已安排工程师远程诊断"></label><div data-status>处理中</div><button data-action>回复并转为待客户确认</button>`);
  ui.on("[data-action]", "click", () => { appendTextMessage(ui.q(".prototype-demo"), "客服", ui.q("[data-reply]").value); ui.q("[data-status]").textContent = "待客户确认"; ui.state("ticket:status:waiting-customer;messages:2"); });
  ui.state("ticket:status:processing;messages:1");
}

export function renderMessageTemplate(ctx) {
  const ui = mount(ctx, `<label>模板 <textarea data-template aria-label="消息模板">{{customer}}，您的订单 {{order}} 已发货。</textarea></label><div data-preview>未预览</div><button data-action>用安全变量预览</button>`);
  ui.on("[data-action]", "click", () => { const text = ui.q("[data-template]").value.replaceAll("{{customer}}", "星河科技").replaceAll("{{order}}", "SO-001"); ui.q("[data-preview]").textContent = text; ui.state("template:rendered;variables:2;html:false"); });
  ui.state("template:draft;variables:2");
}

export function renderSubscriptionConfig(ctx) {
  const ui = mount(ctx, `<label><input data-email type="checkbox" aria-label="邮件订阅" checked> 邮件</label><label><input data-app type="checkbox" aria-label="站内订阅"> 站内</label><label>事件 <select data-event aria-label="订阅事件"><option>库存预警</option></select></label><button data-action>启用站内渠道</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-app]").checked = true; ui.state("subscription:event:stock-alert;channels:email,in-app"); });
  ui.state("subscription:event:stock-alert;channels:email");
}

export function renderOfflineReconnect(ctx) {
  const ui = mount(ctx, `<div data-network>网络离线</div><ol data-queue><li>待发送：确认收货</li><li>待发送：补充备注</li></ol><button data-action>恢复网络并重放队列</button>`);
  ui.on("[data-action]", "click", () => { ui.q("[data-network]").textContent = "已重连 · 游标 2026-07-14T09:50"; ui.q("[data-queue]").innerHTML = "<li>2 条离线消息发送成功</li>"; ui.state("network:online;replayed:2;pending:0"); });
  ui.state("network:offline;pending:2");
}

export const collaborationRenderers = Object.freeze({
  "17:instant-chat": renderInstantChat,
  "17:conversation-list": renderConversationList,
  "17:comments": renderComments,
  "17:threaded-replies": renderThreadedReplies,
  "17:document-annotation": renderDocumentAnnotation,
  "17:image-annotation": renderImageAnnotation,
  "17:mention-picker": renderMentionPicker,
  "17:message-center": renderMessageCenter,
  "17:notification-center": renderNotificationCenter,
  "17:online-presence": renderOnlinePresence,
  "17:collaborative-cursor": renderCollaborativeCursor,
  "17:collaborative-editing": renderCollaborativeEditing,
  "17:conflict-resolver": renderConflictResolver,
  "17:activity-timeline": renderActivityTimeline,
  "17:operation-log": renderOperationLog,
  "17:audit-trail": renderAuditTrail,
  "17:ticket-conversation": renderTicketConversation,
  "17:message-template": renderMessageTemplate,
  "17:subscription-config": renderSubscriptionConfig,
  "17:offline-reconnect": renderOfflineReconnect,
});
export const renderers17 = collaborationRenderers;
export const renderers = renderers17;
