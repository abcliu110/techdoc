import pathlib, sys
out = pathlib.Path("06-\u5e94\u7528\u58f3\u9ad8\u4fdd\u771f\u539f\u578b-\u4e03\u79cd\u6a21\u5f0f.html")

# ── HEAD ──────────────────────────────────────────────────────────────
HEAD = """<!doctype html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>企业应用壳 · 七种模式高保真原型</title>
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{--ink:#172332;--muted:#6d7885;--line:#dbe1e7;--paper:#f0f2f5;--navy:#102337;--cyan:#28b4aa;--amber:#e7a43a;--red:#cd5c54;--green:#2b9b70;--blue:#4074c8;--shadow:0 20px 48px rgba(23,35,50,.14)}
body{background:var(--paper);color:var(--ink);font-family:"Segoe UI","Microsoft YaHei",system-ui,sans-serif;font-size:13px}
button{font:inherit;cursor:pointer;border:none;background:none}
.page{max-width:1560px;margin:0 auto;padding:28px 24px 80px}
.eyebrow{font-size:10px;font-weight:800;letter-spacing:1.8px;text-transform:uppercase;color:var(--cyan);margin-bottom:8px}
h1{font-size:28px;font-weight:900;letter-spacing:-.5px;line-height:1.2;margin-bottom:8px}
.mast p{color:var(--muted);font-size:13px;line-height:1.7;max-width:820px;margin-bottom:20px}
.switcher{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:14px}
.sw{border:1.5px solid var(--line);background:#fff;color:var(--muted);padding:10px 18px;border-radius:6px;font-size:12px;font-weight:700;transition:.15s}
.sw:hover{border-color:#a8b8c6;color:var(--ink)}
.sw.on{background:var(--navy);border-color:var(--navy);color:#fff}
.sw small{display:block;font-weight:400;font-size:10px;margin-top:2px;opacity:.75}
.dcard{background:#fff;border:1px solid var(--line);padding:16px 20px;margin-bottom:14px;display:flex;justify-content:space-between;gap:20px;align-items:flex-start}
.dcard h2{font-size:15px;font-weight:800;margin-bottom:5px}
.dcard p{font-size:12px;color:var(--muted);line-height:1.65;max-width:680px}
.chips{display:flex;flex-wrap:wrap;gap:5px;min-width:180px}
.chip{font-size:10px;font-weight:700;padding:3px 8px;background:#edf4f4;color:#236e6a;border-radius:3px}
.chip.o{background:#fff4df;color:#98631a}.chip.b{background:#edf2fb;color:#345d9f}
.chip.p{background:#f3f0ff;color:#5b21b6}.chip.r{background:#fcede9;color:#a44840}
.box{background:#fff;border:1px solid #cfd7df;box-shadow:var(--shadow);overflow:hidden}
/* Shell 1 styles */
#s1-layout{display:grid;grid-template-columns:60px 210px 1fr;min-height:680px}
#s1-rail{background:#0f1f2e;display:flex;flex-direction:column;align-items:center;padding:14px 0;gap:8px}
#s1-brand{width:34px;height:34px;background:#28b4aa;color:#0f1f2e;display:grid;place-items:center;font-weight:900;font-size:15px;border-radius:7px;margin-bottom:18px}
#s1-side{background:#f1f4f6;border-right:1px solid var(--line);padding:18px 12px;overflow-y:auto}
#s1-main{background:#fbfcfc;display:flex;flex-direction:column;min-width:0}
#s1-topbar{height:54px;border-bottom:1px solid var(--line);display:flex;align-items:center;gap:14px;padding:0 20px;flex-shrink:0}
#s1-content{padding:14px 20px 20px;overflow-y:auto;flex:1}
.kpis{display:grid;grid-template-columns:repeat(4,1fr);gap:9px;margin-bottom:14px}
.kpi{background:#fff;border:1px solid var(--line);padding:12px 14px}
.kpi small{display:block;color:var(--muted);font-size:10px}
.kpi b{display:block;font-size:20px;font-weight:800;margin-top:5px}
.delta{font-size:10px;color:var(--green);margin-top:3px}
.delta.w{color:var(--amber)}
.mgrid{display:grid;grid-template-columns:1.35fr .65fr;gap:11px}
.pnl{background:#fff;border:1px solid var(--line)}
.ph{display:flex;justify-content:space-between;align-items:center;padding:11px 14px;border-bottom:1px solid var(--line);font-size:11px}
.ph b{font-weight:700}
.ph span{color:var(--muted);font-size:10px}
.tbl{width:100%;border-collapse:collapse;font-size:11px}
.tbl th{background:#f7f8f9;color:#7e8994;font-size:10px;font-weight:700;text-align:left;padding:8px 11px}
.tbl td{padding:10px 11px;border-top:1px solid #eef1f3;white-space:nowrap}
.tbl tr{cursor:pointer}
.tbl tr:hover td,.tbl tr.sel td{background:#f0f7f6}
.stag{display:inline-block;padding:2px 6px;border-radius:3px;font-size:9px;font-weight:800}
.stag.g{background:#e5f5ed;color:#287b5d}
.stag.y{background:#fff2d9;color:#96641d}
.stag.r{background:#fce8e4;color:#a64c43}
.stag.b{background:#e8f0fb;color:#2d4f9a}
.qrow{display:grid;grid-template-columns:1fr auto;gap:8px;padding:10px 0;border-bottom:1px solid #edf0f2}
.qrow:last-child{border-bottom:none}
.qrow b{display:block;font-size:11px}
.qrow small{display:block;color:var(--muted);font-size:10px;margin-top:3px}
.qbar{height:4px;background:#e9eef0;margin-top:6px;border-radius:2px}
.qbar i{display:block;height:100%;border-radius:2px;background:var(--cyan)}
/* Drawer */
.drw{position:absolute;top:0;right:0;bottom:0;width:390px;background:#fff;border-left:1px solid var(--line);box-shadow:-10px 0 30px rgba(16,35,55,.15);transform:translateX(100%);transition:.25s;z-index:10;padding:22px;overflow-y:auto}
.drw.open{transform:none}
.tl{border-left:2px solid #dce8e7;padding-left:14px;margin-top:10px}
.tl-e{position:relative;margin:12px 0}
.tl-e::before{content:"";position:absolute;left:-20px;top:4px;width:7px;height:7px;background:var(--cyan);border-radius:50%}
.tl-e b{font-size:11px}
.tl-e small{display:block;color:var(--muted);font-size:10px;margin-top:2px}
/* Shell 2 (Linear) */
#s2{display:flex;flex-direction:column;height:680px;background:#fff}
#s2-topbar{height:50px;border-bottom:1px solid #e5e7eb;display:flex;align-items:center;gap:10px;padding:0 16px;flex-shrink:0}
#s2-body{display:flex;flex:1;overflow:hidden}
#s2-sidebar{width:220px;background:#fff;border-right:1px solid #f3f4f6;flex-shrink:0;overflow-y:auto}
#s2-main{flex:1;display:flex;flex-direction:column;background:#f9fafb;min-width:0;overflow:hidden}
#s2-viewhd{background:#fff;border-bottom:1px solid #e5e7eb;padding:10px 18px;display:flex;align-items:center;gap:12px;flex-shrink:0}
#s2-filters{display:flex;gap:6px;align-items:center;padding:8px 18px;background:#fff;border-bottom:1px solid #f3f4f6;flex-shrink:0}
#s2-kanban{display:flex;gap:12px;padding:14px;overflow-x:auto;flex:1;align-items:flex-start}
.s2-si{display:flex;align-items:center;gap:7px;padding:5px 7px;border-radius:5px;color:#374151;cursor:pointer;font-size:12px}
.s2-si:hover,.s2-si.on{background:#f3f0ff;color:#5b21b6}
.s2-si .cnt{margin-left:auto;font-size:10px;color:#9ca3af;background:#f3f4f6;padding:1px 5px;border-radius:8px}
.s2-si.on .cnt{background:#ede9fe;color:#7c3aed}
.k-col{width:230px;flex-shrink:0}
.k-hd{display:flex;align-items:center;gap:6px;margin-bottom:10px;font-size:11px;font-weight:700;padding:0 2px}
.k-card{background:#fff;border:1px solid #e5e7eb;border-radius:6px;padding:10px;margin-bottom:7px;cursor:pointer}
.k-card:hover{box-shadow:0 2px 8px rgba(0,0,0,.08)}
.k-card.sel{border-color:#6366f1;box-shadow:0 0 0 3px rgba(99,102,241,.12)}
.k-ct{font-size:11px;font-weight:600;color:#111827;margin-bottom:6px}
.k-ft{display:flex;align-items:center;gap:4px}
.itag{padding:2px 6px;border-radius:8px;font-size:10px;font-weight:700}
.itag.bug{background:#fee2e2;color:#dc2626}
.itag.feat{background:#dbeafe;color:#1d4ed8}
.itag.imp{background:#d1fae5;color:#065f46}
/* Shell 3 (Airtable) */
#s3{display:flex;flex-direction:column;height:680px;background:#fff}
#s3-topbar{height:48px;border-bottom:1px solid #e5e7eb;display:flex;align-items:center;padding:0 16px;gap:12px;flex-shrink:0}
#s3-body{display:flex;flex:1;overflow:hidden}
#s3-sidebar{width:180px;background:#fafafa;border-right:1px solid #e5e7eb;padding:10px 8px;flex-shrink:0;overflow-y:auto;font-size:12px}
#s3-main{flex:1;display:flex;flex-direction:column;min-width:0}
#s3-ttabs{display:flex;border-bottom:1px solid #e5e7eb;overflow-x:auto;flex-shrink:0;background:#fff}
#s3-viewbar{display:flex;gap:6px;padding:7px 12px;border-bottom:1px solid #f3f4f6;background:#fafafa;flex-shrink:0}
#s3-grid-wrap{display:flex;flex:1;overflow:hidden}
#s3-grid{flex:1;overflow:auto}
.s3-tt{padding:9px 14px;font-size:12px;font-weight:600;color:#6b7280;border-bottom:2px solid transparent;cursor:pointer;white-space:nowrap}
.s3-tt.on{color:#111827;border-color:#111827;font-weight:700}
.s3-vb{padding:5px 10px;border:1px solid #e5e7eb;border-radius:4px;font-size:11px;font-weight:600;cursor:pointer;background:#fff;color:#374151}
.s3-vb.on{background:#111827;color:#fff;border-color:#111827}
.g-hdr{display:flex;background:#fafafa;border-bottom:1px solid #e5e7eb;position:sticky;top:0;z-index:2}
.g-hc{padding:7px 10px;font-size:11px;font-weight:700;color:#374151;border-right:1px solid #e5e7eb;white-space:nowrap;flex-shrink:0}
.g-row{display:flex;border-bottom:1px solid #f3f4f6;cursor:pointer}
.g-row:hover{background:#f9fafb}
.g-row.on{background:#eff6ff}
.g-c{padding:8px 10px;font-size:11px;color:#374151;border-right:1px solid #f3f4f6;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;flex-shrink:0;display:flex;align-items:center}
.rec-pnl{width:340px;border-left:1px solid #e5e7eb;padding:18px;overflow-y:auto;flex-shrink:0;background:#fff}
/* Shell 4 (Notion) */
#s4{display:flex;flex-direction:column;height:680px;background:#fff}
#s4-topbar{height:46px;border-bottom:1px solid #e5e7eb;display:flex;align-items:center;padding:0 14px;gap:10px;flex-shrink:0;background:#fff}
#s4-body{display:flex;flex:1;overflow:hidden}
#s4-sidebar{width:220px;background:#fafafa;border-right:1px solid #e5e7eb;overflow-y:auto;padding:10px 6px;flex-shrink:0;font-size:12px}
#s4-canvas{flex:1;overflow-y:auto;background:#fff;padding:0 40px 40px}
.s4-pi{display:flex;align-items:center;gap:5px;padding:4px 7px;border-radius:4px;cursor:pointer;color:#374151}
.s4-pi:hover,.s4-pi.on{background:#eff6ff;color:#1e40af}
.s4-pg{font-size:10px;font-weight:700;color:#9ca3af;letter-spacing:.5px;padding:8px 6px 3px;text-transform:uppercase}
/* Shell 5 (VS Code) */
#s5{display:flex;flex-direction:column;height:680px;background:#1e1e1e;color:#d4d4d4}
#s5-titlebar{height:30px;background:#323233;display:flex;align-items:center;padding:0 14px;gap:8px;flex-shrink:0;font-size:11px;color:#cccccc}
#s5-body{display:flex;flex:1;overflow:hidden}
#s5-actbar{width:46px;background:#333333;display:flex;flex-direction:column;align-items:center;padding:6px 0;gap:2px;flex-shrink:0}
#s5-sidebar{width:210px;background:#252526;border-right:1px solid #1e1e1e;flex-shrink:0;overflow-y:auto}
#s5-editor-wrap{flex:1;display:flex;flex-direction:column;min-width:0}
#s5-tabs{height:34px;background:#2d2d2d;display:flex;align-items:flex-end;border-bottom:1px solid #1e1e1e;flex-shrink:0;overflow-x:auto}
#s5-breadcrumb{height:22px;background:#1e1e1e;border-bottom:1px solid #252526;display:flex;align-items:center;padding:0 14px;font-size:11px;color:#858585;flex-shrink:0}
#s5-code{flex:1;overflow-y:auto;padding:12px 0;font-family:Consolas,monospace;font-size:12px;line-height:1.8;background:#1e1e1e}
#s5-panel{height:140px;background:#1e1e1e;border-top:1px solid #252526;flex-shrink:0;display:flex;flex-direction:column}
#s5-panel-tabs{height:28px;background:#2d2d2d;display:flex;align-items:center;padding:0 14px;gap:12px;flex-shrink:0}
#s5-terminal{flex:1;overflow-y:auto;padding:8px 14px;font-family:Consolas,monospace;font-size:11px;line-height:1.6;background:#1e1e1e}
#s5-status{height:22px;background:#0078d4;display:flex;align-items:center;padding:0 12px;font-size:11px;color:#fff;flex-shrink:0;gap:14px}
/* Shell 6 (Ant Design Pro) */
#s6{display:flex;flex-direction:column;height:680px;background:#f0f2f5}
#s6-topbar{height:50px;background:#001529;display:flex;align-items:center;padding:0 20px;gap:16px;flex-shrink:0}
#s6-body{display:flex;flex:1;overflow:hidden}
#s6-menu{width:200px;background:#001529;overflow-y:auto;flex-shrink:0;padding:8px 0}
#s6-content{flex:1;overflow-y:auto;padding:16px}
.ant-card{background:#fff;border-radius:4px;box-shadow:0 1px 3px rgba(0,0,0,.06);margin-bottom:16px}
.ant-card-hd{padding:14px 18px;border-bottom:1px solid #f0f0f0;display:flex;align-items:center;justify-content:space-between}
.ant-card-body{padding:16px 18px}
.ant-kpi{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:16px}
.ant-kpi-item{background:#fff;border-radius:4px;padding:16px;box-shadow:0 1px 3px rgba(0,0,0,.06)}
.ant-tbl{width:100%;border-collapse:collapse;font-size:12px}
.ant-tbl th{padding:10px 14px;text-align:left;font-weight:600;color:#595959;border-bottom:1px solid #f0f0f0;background:#fafafa;white-space:nowrap}
.ant-tbl td{padding:10px 14px;border-bottom:1px solid #f5f5f5}
.ant-tbl tr{cursor:pointer}
.ant-tbl tr:hover td{background:#e6f7ff}
.ant-menu-item{padding:10px 20px;color:rgba(255,255,255,.45);cursor:pointer;display:flex;align-items:center;gap:8px;font-size:12px}
.ant-menu-item.on{background:#1890ff;color:#fff}
/* Shell 7 (Retool) */
#s7{display:flex;flex-direction:column;height:680px;background:#1a1f2e;color:#d4d4d4}
#s7-topbar{height:46px;background:#1e2330;border-bottom:1px solid #161b27;display:flex;align-items:center;padding:0 14px;gap:10px;flex-shrink:0}
#s7-body{display:flex;flex:1;overflow:hidden}
#s7-explorer{width:220px;background:#1e2330;border-right:1px solid #161b27;flex-shrink:0;overflow-y:auto}
#s7-canvas{flex:1;display:flex;flex-direction:column;background:#292f3d;min-width:0;overflow:hidden}
#s7-canvas-hd{height:32px;background:#242937;border-bottom:1px solid #1a1f2e;display:flex;align-items:center;padding:0 12px;font-size:11px;color:#6b7280;flex-shrink:0}
#s7-canvas-body{flex:1;overflow:auto;padding:16px;background-image:radial-gradient(circle,#374151 1px,transparent 1px);background-size:20px 20px}
#s7-props{width:240px;background:#1e2330;border-left:1px solid #161b27;flex-shrink:0;overflow-y:auto}
.s7-etab{flex:1;padding:7px;font-size:10px;font-weight:700;cursor:pointer;border:none;text-align:center}
.s7-etab.on{color:#60a5fa;background:rgba(59,130,246,.1);border-bottom:2px solid #3b82f6}
.s7-etab.off{color:#6b7280;background:transparent;border-bottom:2px solid transparent}
</style>
</head>
<body>
<div class="page">
<div class="mast">
  <div class="eyebrow">Enterprise App Shell · High-fidelity prototypes · 2026.07</div>
  <h1>企业应用壳 · 七种模式高保真原型</h1>
  <p>基于 Salesforce、SAP Fiori、Linear、Notion、VS Code、Airtable、Retool 等 14 款产品深度分析，七种壳均含真实业务数据与可交互演示。</p>
</div>
<div class="switcher">
  <button class="sw on" data-s="1">企业业务壳<small>Salesforce / SAP / CRM</small></button>
  <button class="sw" data-s="2">任务协作壳<small>Linear / Jira / Plane</small></button>
  <button class="sw" data-s="3">数据应用壳<small>Airtable / Teable / NocoDB</small></button>
  <button class="sw" data-s="4">知识空间壳<small>Notion / Outline / AFFiNE</small></button>
  <button class="sw" data-s="5">开发者工具壳<small>VS Code / GitHub</small></button>
  <button class="sw" data-s="6">后台管理壳<small>Ant Design Pro / 金蝶</small></button>
  <button class="sw" data-s="7">低代码设计壳<small>Retool / Appsmith</small></button>
</div>
<div class="dcard">
  <div><h2 id="dtitle">企业业务壳 · App → Object → Record</h2>
  <p id="dtext">以业务对象（客户、订单、合同、工单）为核心，顶栏切换应用，左侧按业务域分模块，列表+详情抽屉保持同屏上下文。代表：Salesforce Lightning、SAP Fiori、ServiceNow。</p></div>
  <div class="chips" id="dchips">
    <span class="chip">App Launcher</span><span class="chip o">业务对象导航</span><span class="chip b">列表+详情抽屉</span><span class="chip p">角色首页</span><span class="chip r">RBAC 权限菜单</span>
  </div>
</div>
"""

html = [HEAD]
print("HEAD written,", len(HEAD), "chars")

# ── SHELL 1: 企业业务壳 ─────────────────────────────────────────────
S1 = """<div class="box" id="sp1" style="position:relative">
<div id="s1-layout">
  <div id="s1-rail">
    <div id="s1-brand">N</div>
    <button style="width:38px;height:38px;border-radius:6px;background:#1e3a50;color:#fff;font-size:17px;display:grid;place-items:center">⌂</button>
    <button style="width:38px;height:38px;border-radius:6px;color:#7d96a8;font-size:17px;display:grid;place-items:center">◈</button>
    <button style="width:38px;height:38px;border-radius:6px;color:#7d96a8;font-size:17px;display:grid;place-items:center">✓</button>
    <button style="width:38px;height:38px;border-radius:6px;color:#7d96a8;font-size:17px;display:grid;place-items:center">▥</button>
    <button style="width:38px;height:38px;border-radius:6px;color:#7d96a8;font-size:17px;display:grid;place-items:center">⚙</button>
  </div>
  <div id="s1-side">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px"><b style="font-size:14px">经营中枢</b><span style="color:var(--muted)">＋</span></div>
    <div style="border:1px solid #cad4dc;background:#fff;padding:9px;border-radius:4px;font-size:11px;margin-bottom:14px"><b style="display:block;font-size:12px;margin-bottom:2px">Northstar 集团</b><span style="color:var(--muted)">华东运营中心　⌄</span></div>
    <div style="font-size:9px;font-weight:800;letter-spacing:1px;color:#8996a2;margin:14px 0 5px;text-transform:uppercase">经营导航</div>
    <div style="padding:8px 9px;border-radius:4px;background:#d9ebe9;color:#1a6b67;font-weight:700;font-size:12px;display:flex;justify-content:space-between;align-items:center">总览工作台<span style="font-size:10px">⌂</span></div>
    <div style="padding:8px 9px;border-radius:4px;color:#3a4a56;font-size:12px;display:flex;justify-content:space-between;align-items:center;cursor:pointer">销售与客户<span style="font-size:10px;color:#8b979f">24</span></div>
    <div style="padding:8px 9px;border-radius:4px;color:#3a4a56;font-size:12px;display:flex;justify-content:space-between;align-items:center;cursor:pointer">采购与库存<span style="font-size:10px;color:#8b979f">8</span></div>
    <div style="padding:8px 9px;border-radius:4px;color:#3a4a56;font-size:12px;display:flex;justify-content:space-between;align-items:center;cursor:pointer">财务与结算<span style="font-size:10px;color:#8b979f">3</span></div>
    <div style="padding:8px 9px;border-radius:4px;color:#3a4a56;font-size:12px;display:flex;justify-content:space-between;align-items:center;cursor:pointer">合同管理<span style="font-size:10px;color:#8b979f">›</span></div>
    <div style="font-size:9px;font-weight:800;letter-spacing:1px;color:#8996a2;margin:14px 0 5px;text-transform:uppercase">我的工作</div>
    <div style="padding:8px 9px;border-radius:4px;color:#3a4a56;font-size:12px;display:flex;justify-content:space-between;align-items:center;cursor:pointer">待我审批<span style="font-size:10px;color:#cd5c54;font-weight:700">12</span></div>
    <div style="padding:8px 9px;border-radius:4px;color:#3a4a56;font-size:12px;display:flex;justify-content:space-between;align-items:center;cursor:pointer">最近访问<span style="font-size:10px;color:#8b979f">7</span></div>
  </div>
  <div id="s1-main">
    <div id="s1-topbar">
      <div style="font-size:12px;font-weight:700">Northstar ERP <span style="color:var(--muted);font-weight:400">/ 经营中枢</span></div>
      <input style="margin-left:auto;border:1px solid #d4dce2;background:#fff;color:#8a949e;border-radius:4px;width:200px;padding:7px 10px;font-size:11px;outline:none" placeholder="⌕  搜索客户、单据…" readonly>
      <span style="font-size:16px;color:#71808d;cursor:pointer">🔔</span>
      <div style="width:26px;height:26px;background:#e6b96c;color:#5b3b0a;border-radius:50%;display:grid;place-items:center;font-size:10px;font-weight:900">林</div>
    </div>
    <div id="s1-content">
      <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:10px">
        <div><div style="font-size:22px;font-weight:800">经营总览</div><div style="font-size:11px;color:var(--muted);margin-top:2px">2026年7月20日 · 华东运营中心</div></div>
        <div style="display:flex;gap:6px">
          <button style="border:1px solid #ccd5dd;background:#fff;color:#43515d;padding:7px 10px;border-radius:4px;font-size:11px">导出视图</button>
          <button style="background:var(--navy);border:none;color:#fff;padding:7px 11px;border-radius:4px;font-size:11px">＋ 新建单据</button>
        </div>
      </div>
      <div style="display:flex;gap:16px;border-bottom:1px solid var(--line);margin-bottom:14px">
        <button style="border:none;background:none;color:var(--navy);font-weight:700;padding:7px 0;font-size:11px;border-bottom:2.5px solid var(--cyan)">我的总览</button>
        <button style="border:none;background:none;color:#89939c;padding:7px 0;font-size:11px;border-bottom:2.5px solid transparent">销售漏斗</button>
        <button style="border:none;background:none;color:#89939c;padding:7px 0;font-size:11px;border-bottom:2.5px solid transparent">库存健康</button>
        <button style="border:none;background:none;color:#89939c;padding:7px 0;font-size:11px;border-bottom:2.5px solid transparent">现金流</button>
      </div>
      <div class="kpis">
        <div class="kpi"><small>本月含税收入</small><b>¥ 2,846,200</b><div class="delta">↗ 12.8% 对比上月</div></div>
        <div class="kpi"><small>待处理业务</small><b>36</b><div class="delta w">12 项今日到期</div></div>
        <div class="kpi"><small>库存周转天数</small><b>18.4 天</b><div class="delta">↘ 2.1 天改善</div></div>
        <div class="kpi"><small>应收账款余额</small><b>¥ 694,800</b><div class="delta w">3 笔超过账期</div></div>
      </div>
      <div class="mgrid">
        <div class="pnl">
          <div class="ph"><b>跨域业务队列</b><span>已保存视图　⌄</span></div>
          <div style="display:flex;gap:6px;padding:8px 11px;border-bottom:1px solid #edf0f2">
            <button style="border:1px solid #a8b8c4;background:#f5f8fa;padding:5px 8px;color:var(--navy);font-size:10px;border-radius:3px;font-weight:600">全部业务</button>
            <button style="border:1px solid #d9e0e5;background:#fff;padding:5px 8px;color:#687581;font-size:10px;border-radius:3px">待审批　12</button>
            <button style="border:1px solid #d9e0e5;background:#fff;padding:5px 8px;color:#687581;font-size:10px;border-radius:3px">高风险　4</button>
            <button style="border:1px solid #d9e0e5;background:#fff;padding:5px 8px;color:#687581;font-size:10px;border-radius:3px">我的负责</button>
          </div>
          <table class="tbl">
            <thead><tr><th>业务对象</th><th>类型</th><th>所属组织</th><th>负责人</th><th>状态</th><th>更新</th></tr></thead>
            <tbody>
              <tr class="sel" data-id="d1"><td style="font-weight:700">SO-20260720-018　上海星河科技</td><td>销售订单</td><td>华东</td><td>林晓</td><td><span class="stag y">待财务复核</span></td><td>09:36</td></tr>
              <tr data-id="d2"><td style="font-weight:700">PO-20260720-006　苏州云杉供应链</td><td>采购订单</td><td>华东</td><td>陈默</td><td><span class="stag g">采购确认</span></td><td>09:12</td></tr>
              <tr data-id="d3"><td style="font-weight:700">AR-20260719-031　深圳蓝海零售</td><td>应收核销</td><td>华南</td><td>周宁</td><td><span class="stag r">超过账期</span></td><td>昨天</td></tr>
              <tr data-id="d4"><td style="font-weight:700">WF-20260719-122　费用报销申请</td><td>审批流</td><td>集团总部</td><td>王璐</td><td><span class="stag y">待部门主管</span></td><td>昨天</td></tr>
              <tr data-id="d5"><td style="font-weight:700">CT-20260718-009　北京华润集团</td><td>合同审批</td><td>华北</td><td>赵磊</td><td><span class="stag b">法务审核中</span></td><td>昨天</td></tr>
            </tbody>
          </table>
        </div>
        <div>
          <div class="pnl" style="margin-bottom:11px">
            <div class="ph"><b>今日待办</b><span>全部 →</span></div>
            <div style="padding:0 14px 6px">
              <div class="qrow"><div><b>销售订单待财务复核</b><small>3 笔·影响发货</small><div class="qbar"><i style="width:72%"></i></div></div><span style="font-size:10px;color:#9a6a22">今天</span></div>
              <div class="qrow"><div><b>采购价格审批</b><small>8 笔·采购中心</small><div class="qbar"><i style="width:48%"></i></div></div><span style="font-size:10px;color:#9a6a22">2小时</span></div>
              <div class="qrow"><div><b>应收账款超期</b><small>3 笔·需跟进</small><div class="qbar"><i style="width:31%;background:var(--red)"></i></div></div><span style="font-size:10px;color:var(--red)">逾期</span></div>
            </div>
          </div>
          <div style="background:var(--navy);color:#d9e5ed;padding:13px 14px"><b style="display:block;color:#fff;font-size:11px;margin-bottom:5px">经营提示</b><p style="font-size:10px;line-height:1.6;color:#b4c6d3">华南事业部有3笔应收超过30天账期；SO-20260720-018信用额度已使用82%，建议暂缓发货。</p></div>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="drw" id="s1drw">
  <button onclick="document.getElementById('s1drw').classList.remove('open')" style="float:right;font-size:22px;color:var(--muted);cursor:pointer">×</button>
  <div style="font-size:10px;font-weight:800;letter-spacing:1.5px;color:var(--cyan);text-transform:uppercase;margin-top:22px">Record Detail</div>
  <h3 id="drw-id" style="font-size:22px;font-weight:800;margin:6px 0 4px">SO-20260720-018</h3>
  <p id="drw-desc" style="font-size:12px;color:var(--muted);line-height:1.6;margin-bottom:16px">上海星河科技 · 销售订单 · 当前节点：财务复核</p>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:7px;margin-bottom:14px">
    <div style="background:#f5f7f8;padding:10px;border-radius:3px"><small style="display:block;color:var(--muted);font-size:10px">订单金额</small><b style="display:block;font-size:12px;font-weight:700;margin-top:3px">¥ 186,400</b></div>
    <div style="background:#f5f7f8;padding:10px;border-radius:3px"><small style="display:block;color:var(--muted);font-size:10px">信用额度使用</small><b style="display:block;font-size:12px;font-weight:700;margin-top:3px">82%</b></div>
    <div style="background:#f5f7f8;padding:10px;border-radius:3px"><small style="display:block;color:var(--muted);font-size:10px">业务组织</small><b style="display:block;font-size:12px;font-weight:700;margin-top:3px">华东运营中心</b></div>
    <div style="background:#f5f7f8;padding:10px;border-radius:3px"><small style="display:block;color:var(--muted);font-size:10px">负责人</small><b style="display:block;font-size:12px;font-weight:700;margin-top:3px">林晓</b></div>
  </div>
  <div style="display:flex;gap:6px;margin-bottom:16px">
    <button style="background:var(--navy);border:none;color:#fff;padding:7px 10px;border-radius:4px;font-size:11px">打开完整单据</button>
    <button style="border:1px solid #ccd5dd;background:#fff;color:#43515d;padding:7px 10px;border-radius:4px;font-size:11px">转交</button>
  </div>
  <div style="font-size:12px;font-weight:700;margin-bottom:8px">状态时间线</div>
  <div class="tl">
    <div class="tl-e"><b>提交销售订单</b><small>林晓　今天 09:12</small></div>
    <div class="tl-e"><b>销售主管已审核</b><small>王璐　今天 09:28</small></div>
    <div class="tl-e"><b>等待财务复核</b><small>当前节点</small></div>
  </div>
</div>
</div>"""
html.append(S1)

# ── SHELL 2: 任务协作壳 ──────────────────────────────────────────────
S2 = """<div class="box" id="sp2">
<div id="s2">
  <div id="s2-topbar">
    <div style="font-weight:800;font-size:13px">⚡ TechVision</div>
    <div style="width:1px;height:18px;background:#e5e7eb"></div>
    <span style="font-size:12px;color:#6b7280">产品研发工作区</span>
    <div style="margin-left:auto;border:1px solid #e5e7eb;background:#f9fafb;border-radius:5px;padding:5px 12px;font-size:11px;color:#9ca3af;display:flex;align-items:center;gap:8px"><kbd style="background:#fff;border:1px solid #e5e7eb;border-radius:3px;padding:1px 5px;font-size:10px;color:#374151">⌘K</kbd> 命令面板</div>
    <div style="width:26px;height:26px;background:#6366f1;color:#fff;border-radius:50%;display:grid;place-items:center;font-size:10px;font-weight:900">张</div>
  </div>
  <div id="s2-body">
    <div id="s2-sidebar">
      <div style="display:flex;align-items:center;gap:8px;padding:12px 14px;border-bottom:1px solid #f3f4f6">
        <div style="width:24px;height:24px;background:#6366f1;border-radius:5px;display:grid;place-items:center;color:#fff;font-size:11px;font-weight:900">T</div>
        <span style="font-size:12px;font-weight:700">TechVision</span>
        <span style="margin-left:auto;color:#9ca3af;font-size:12px">⌄</span>
      </div>
      <div style="padding:0 8px">
        <div style="font-size:10px;font-weight:700;color:#9ca3af;letter-spacing:.5px;padding:10px 6px 4px;text-transform:uppercase">工作区</div>
        <div class="s2-si"><span style="font-size:13px">📥</span>收件箱<span class="cnt">3</span></div>
        <div class="s2-si on"><span style="font-size:13px">⚡</span>我的任务<span class="cnt" style="background:#ede9fe;color:#7c3aed">12</span></div>
        <div class="s2-si"><span style="font-size:13px">🗺</span>全局路线图</div>
        <div style="font-size:10px;font-weight:700;color:#9ca3af;letter-spacing:.5px;padding:10px 6px 4px;text-transform:uppercase">团队</div>
        <div style="display:flex;align-items:center;gap:6px;padding:7px 6px 3px;color:#6b7280;font-size:11px;font-weight:700"><span style="width:8px;height:8px;border-radius:50%;background:#10b981;display:inline-block"></span>产品团队</div>
        <div class="s2-si" style="padding-left:18px"><span style="font-size:13px">📋</span>Issues<span class="cnt">47</span></div>
        <div class="s2-si on" style="padding-left:18px"><span style="font-size:13px">🔄</span>Sprint 24<span class="cnt" style="background:#d1fae5;color:#065f46">8</span></div>
        <div class="s2-si" style="padding-left:18px"><span style="font-size:13px">📁</span>项目</div>
        <div style="display:flex;align-items:center;gap:6px;padding:7px 6px 3px;color:#6b7280;font-size:11px;font-weight:700"><span style="width:8px;height:8px;border-radius:50%;background:#f59e0b;display:inline-block"></span>基础设施</div>
        <div class="s2-si" style="padding-left:18px"><span style="font-size:13px">📋</span>Issues<span class="cnt">23</span></div>
      </div>
    </div>
    <div id="s2-main">
      <div id="s2-viewhd">
        <div style="font-size:14px;font-weight:800">Sprint 24 · 进行中</div>
        <div style="display:flex;gap:0;margin-left:16px;border:1px solid #e5e7eb;border-radius:5px;overflow:hidden">
          <div style="padding:5px 10px;font-size:11px;font-weight:600;color:#6b7280;background:#fff;border-right:1px solid #e5e7eb;cursor:pointer">列表</div>
          <div style="padding:5px 10px;font-size:11px;font-weight:600;background:#6366f1;color:#fff;cursor:pointer">看板</div>
          <div style="padding:5px 10px;font-size:11px;font-weight:600;color:#6b7280;background:#fff;cursor:pointer">时间线</div>
        </div>
        <div style="margin-left:auto;display:flex;gap:6px">
          <button style="border:1px solid #e5e7eb;background:#fff;border-radius:4px;padding:5px 10px;font-size:11px;color:#6b7280">分组 ▾</button>
          <button style="background:#6366f1;color:#fff;border:none;border-radius:4px;padding:5px 10px;font-size:11px">＋ 新建 Issue</button>
        </div>
      </div>
      <div id="s2-filters">
        <span style="font-size:11px;color:#9ca3af;margin-right:4px">筛选：</span>
        <button style="border:1px solid #c4b5fd;background:#ede9fe;border-radius:4px;padding:4px 8px;font-size:10px;font-weight:600;color:#5b21b6">状态：进行中</button>
        <button style="border:1px solid #e5e7eb;background:#fff;border-radius:4px;padding:4px 8px;font-size:10px;font-weight:600;color:#6b7280">优先级：高</button>
        <button style="border:1px solid #e5e7eb;background:#fff;border-radius:4px;padding:4px 8px;font-size:10px;font-weight:600;color:#6b7280">＋ 添加筛选</button>
      </div>
      <div id="s2-kanban">
        <div class="k-col">
          <div class="k-hd"><div style="width:8px;height:8px;border-radius:50%;border:2px solid #d1d5db"></div><span style="color:#6b7280">待开始</span><span style="background:#f3f4f6;padding:1px 6px;border-radius:8px;font-size:10px;color:#9ca3af">4</span></div>
          <div class="k-card"><div class="k-ct">优化登录页面加载性能</div><div class="k-ft"><span class="itag imp">改进</span><span style="margin-left:auto;font-size:10px;color:#9ca3af">TV-156</span></div></div>
          <div class="k-card"><div class="k-ct">重构用户权限模块</div><div class="k-ft"><span class="itag bug">缺陷</span><span style="margin-left:auto;font-size:10px;color:#9ca3af">TV-157</span></div></div>
        </div>
        <div class="k-col">
          <div class="k-hd"><div style="width:8px;height:8px;border-radius:50%;border:2px solid #6366f1;background:#ede9fe"></div><span style="color:#6366f1">进行中</span><span style="background:#ede9fe;color:#6366f1;padding:1px 6px;border-radius:8px;font-size:10px">5</span></div>
          <div class="k-card sel"><div class="k-ct" style="font-weight:700">应用壳向导生成器 · 步骤1</div><div class="k-ft"><span class="itag feat">功能</span><div style="width:16px;height:16px;background:#e6b96c;border-radius:50%;display:grid;place-items:center;font-size:8px;font-weight:900;color:#5b3b0a;margin-left:auto">张</div><span style="font-size:10px;color:#9ca3af">TV-149</span></div></div>
          <div class="k-card"><div class="k-ct">数据表格虚拟滚动优化</div><div class="k-ft"><span class="itag imp">改进</span><span style="margin-left:auto;font-size:10px;color:#9ca3af">TV-152</span></div></div>
          <div class="k-card"><div class="k-ct">移动端导航重构</div><div class="k-ft"><span class="itag bug">缺陷</span><span style="margin-left:auto;font-size:10px;color:#9ca3af">TV-153</span></div></div>
        </div>
        <div class="k-col">
          <div class="k-hd"><div style="width:8px;height:8px;border-radius:50%;background:#fcd34d"></div><span style="color:#f59e0b">评审中</span><span style="background:#fef3c7;color:#92400e;padding:1px 6px;border-radius:8px;font-size:10px">2</span></div>
          <div class="k-card"><div class="k-ct">API 接口文档生成工具</div><div class="k-ft"><span class="itag feat">功能</span><span style="margin-left:auto;font-size:10px;color:#9ca3af">TV-145</span></div></div>
        </div>
        <div class="k-col">
          <div class="k-hd"><div style="width:8px;height:8px;border-radius:50%;background:#10b981"></div><span style="color:#10b981">已完成</span><span style="background:#d1fae5;color:#065f46;padding:1px 6px;border-radius:8px;font-size:10px">6</span></div>
          <div class="k-card" style="opacity:.7"><div class="k-ct" style="text-decoration:line-through;color:#9ca3af">权限中间件升级</div><div class="k-ft"><span class="itag" style="background:#f3f4f6;color:#9ca3af">改进</span><span style="margin-left:auto;font-size:10px;color:#9ca3af">TV-140</span></div></div>
          <div class="k-card" style="opacity:.7"><div class="k-ct" style="text-decoration:line-through;color:#9ca3af">JWT 刷新逻辑修复</div><div class="k-ft"><span class="itag" style="background:#f3f4f6;color:#9ca3af">缺陷</span><span style="margin-left:auto;font-size:10px;color:#9ca3af">TV-138</span></div></div>
        </div>
      </div>
    </div>
  </div>
</div>
</div>"""
html.append(S2)

# ── SHELL 3: 数据应用壳 ──────────────────────────────────────────────
S3 = """<div class="box" id="sp3">
<div id="s3">
  <div id="s3-topbar">
    <div style="font-weight:800;font-size:13px;display:flex;align-items:center;gap:6px"><div style="width:22px;height:22px;background:#10b981;border-radius:4px;display:grid;place-items:center;color:#fff;font-size:11px">📊</div>产品数据中心</div>
    <span style="color:#9ca3af;font-size:11px">· Base · 共 6 个数据表</span>
    <div style="margin-left:auto;display:flex;gap:8px;align-items:center">
      <button style="border:1px solid #e5e7eb;background:#fff;border-radius:4px;padding:5px 10px;font-size:11px;color:#374151">⚙ 字段管理</button>
      <button style="background:#000;color:#fff;border:none;border-radius:4px;padding:5px 10px;font-size:11px">＋ 添加记录</button>
      <div style="width:24px;height:24px;background:#6366f1;border-radius:50%;display:grid;place-items:center;color:#fff;font-size:10px;font-weight:900">刘</div>
    </div>
  </div>
  <div id="s3-body">
    <div id="s3-sidebar">
      <div style="font-size:10px;font-weight:700;color:#9ca3af;letter-spacing:.5px;padding:6px 4px 4px;text-transform:uppercase">数据表</div>
      <div style="display:flex;align-items:center;gap:6px;padding:5px 7px;border-radius:4px;background:#e5e7eb;font-weight:600">
        <div style="width:16px;height:16px;background:#dbeafe;color:#1d4ed8;border-radius:3px;display:grid;place-items:center;font-size:9px;font-weight:900">T</div>需求清单
      </div>
      <div style="display:flex;align-items:center;gap:6px;padding:5px 7px;border-radius:4px;cursor:pointer;color:#374151">
        <div style="width:16px;height:16px;background:#d1fae5;color:#065f46;border-radius:3px;display:grid;place-items:center;font-size:9px;font-weight:900">T</div>缺陷跟踪
      </div>
      <div style="display:flex;align-items:center;gap:6px;padding:5px 7px;border-radius:4px;cursor:pointer;color:#374151">
        <div style="width:16px;height:16px;background:#fce7f3;color:#9d174d;border-radius:3px;display:grid;place-items:center;font-size:9px;font-weight:900">T</div>客户反馈
      </div>
      <div style="display:flex;align-items:center;gap:6px;padding:5px 7px;border-radius:4px;cursor:pointer;color:#374151">
        <div style="width:16px;height:16px;background:#fef3c7;color:#92400e;border-radius:3px;display:grid;place-items:center;font-size:9px;font-weight:900">T</div>发布计划
      </div>
      <div style="height:1px;background:#e5e7eb;margin:8px 0"></div>
      <div style="font-size:10px;font-weight:700;color:#9ca3af;letter-spacing:.5px;padding:6px 4px 4px;text-transform:uppercase">视图</div>
      <div style="display:flex;align-items:center;gap:6px;padding:5px 7px;border-radius:4px;background:#e5e7eb;font-weight:600;font-size:11px">☰ 表格视图</div>
      <div style="display:flex;align-items:center;gap:6px;padding:5px 7px;border-radius:4px;cursor:pointer;font-size:11px;color:#374151">⊞ 看板视图</div>
      <div style="display:flex;align-items:center;gap:6px;padding:5px 7px;border-radius:4px;cursor:pointer;font-size:11px;color:#374151">📅 日历视图</div>
      <div style="display:flex;align-items:center;gap:6px;padding:5px 7px;border-radius:4px;cursor:pointer;font-size:11px;color:#374151">📊 甘特图</div>
    </div>
    <div id="s3-main">
      <div id="s3-ttabs">
        <div class="s3-tt on">📋 需求清单</div>
        <div class="s3-tt">🐛 缺陷跟踪</div>
        <div class="s3-tt">💬 客户反馈</div>
        <div class="s3-tt">🚀 发布计划</div>
        <button style="padding:9px 12px;font-size:16px;color:#9ca3af;border:none;background:none;cursor:pointer">＋</button>
      </div>
      <div id="s3-viewbar">
        <div class="s3-vb on">☰ 表格</div>
        <div class="s3-vb">⊞ 看板</div>
        <div class="s3-vb">📅 日历</div>
        <div style="width:1px;height:18px;background:#e5e7eb;margin:0 4px"></div>
        <div class="s3-vb">⚙ 筛选</div>
        <div class="s3-vb">↕ 排序</div>
        <div class="s3-vb" style="margin-left:auto">⌕ 搜索</div>
      </div>
      <div id="s3-grid-wrap">
        <div id="s3-grid">
          <div class="g-hdr">
            <div class="g-hc" style="width:50px;background:#f3f4f6">#</div>
            <div class="g-hc" style="width:200px">📝 需求名称</div>
            <div class="g-hc" style="width:120px">状态</div>
            <div class="g-hc" style="width:120px">优先级</div>
            <div class="g-hc" style="width:100px">负责人</div>
            <div class="g-hc" style="width:100px">目标版本</div>
            <div class="g-hc" style="width:90px">截止日期</div>
          </div>
          <div class="g-row on" onclick="document.getElementById('s3rpnl').style.display='block'">
            <div class="g-c" style="width:50px;color:#9ca3af">1</div>
            <div class="g-c" style="width:200px;font-weight:600;color:#111827">应用壳向导生成器</div>
            <div class="g-c" style="width:120px"><span style="background:#dbeafe;color:#1d4ed8;padding:2px 7px;border-radius:10px;font-size:10px;font-weight:700">进行中</span></div>
            <div class="g-c" style="width:120px;color:#dc2626">🔴 紧急</div>
            <div class="g-c" style="width:100px">张明</div>
            <div class="g-c" style="width:100px">v2.1.0</div>
            <div class="g-c" style="width:90px;color:#dc2626">7月22日</div>
          </div>
          <div class="g-row">
            <div class="g-c" style="width:50px;color:#9ca3af">2</div>
            <div class="g-c" style="width:200px;font-weight:600">数据表格虚拟滚动</div>
            <div class="g-c" style="width:120px"><span style="background:#fef3c7;color:#92400e;padding:2px 7px;border-radius:10px;font-size:10px;font-weight:700">评审中</span></div>
            <div class="g-c" style="width:120px;color:#f59e0b">🟡 高</div>
            <div class="g-c" style="width:100px">李雪</div>
            <div class="g-c" style="width:100px">v2.1.0</div>
            <div class="g-c" style="width:90px">7月25日</div>
          </div>
          <div class="g-row">
            <div class="g-c" style="width:50px;color:#9ca3af">3</div>
            <div class="g-c" style="width:200px;font-weight:600">移动端导航重构</div>
            <div class="g-c" style="width:120px"><span style="background:#f3f4f6;color:#6b7280;padding:2px 7px;border-radius:10px;font-size:10px;font-weight:700">待开始</span></div>
            <div class="g-c" style="width:120px;color:#f59e0b">🟡 高</div>
            <div class="g-c" style="width:100px">王磊</div>
            <div class="g-c" style="width:100px">v2.2.0</div>
            <div class="g-c" style="width:90px">8月5日</div>
          </div>
          <div class="g-row">
            <div class="g-c" style="width:50px;color:#9ca3af">4</div>
            <div class="g-c" style="width:200px;font-weight:600">多租户权限隔离</div>
            <div class="g-c" style="width:120px"><span style="background:#d1fae5;color:#065f46;padding:2px 7px;border-radius:10px;font-size:10px;font-weight:700">已完成</span></div>
            <div class="g-c" style="width:120px;color:#dc2626">🔴 紧急</div>
            <div class="g-c" style="width:100px">陈静</div>
            <div class="g-c" style="width:100px">v2.0.5</div>
            <div class="g-c" style="width:90px;text-decoration:line-through;color:#9ca3af">7月15日</div>
          </div>
          <div class="g-row">
            <div class="g-c" style="width:50px;color:#9ca3af">5</div>
            <div class="g-c" style="width:200px;font-weight:600">命令面板 Cmd+K</div>
            <div class="g-c" style="width:120px"><span style="background:#dbeafe;color:#1d4ed8;padding:2px 7px;border-radius:10px;font-size:10px;font-weight:700">进行中</span></div>
            <div class="g-c" style="width:120px;color:#3b82f6">🔵 中</div>
            <div class="g-c" style="width:100px">张明</div>
            <div class="g-c" style="width:100px">v2.1.0</div>
            <div class="g-c" style="width:90px">7月28日</div>
          </div>
          <div style="display:flex;align-items:center;gap:6px;padding:8px 10px;font-size:11px;color:#9ca3af;cursor:pointer;border-top:1px solid #f3f4f6">＋ 添加记录</div>
        </div>
        <div id="s3rpnl" class="rec-pnl" style="display:none">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px">
            <span style="font-size:11px;font-weight:700;color:#9ca3af">记录详情</span>
            <button onclick="document.getElementById('s3rpnl').style.display='none'" style="background:none;border:none;font-size:20px;color:#9ca3af;cursor:pointer">×</button>
          </div>
          <div style="font-size:16px;font-weight:800;margin-bottom:12px">应用壳向导生成器</div>
          <div style="display:grid;grid-template-columns:80px 1fr;gap:6px;font-size:11px">
            <span style="color:#9ca3af;font-weight:600">状态</span><span><span style="background:#dbeafe;color:#1d4ed8;padding:1px 6px;border-radius:8px;font-size:10px;font-weight:700">进行中</span></span>
            <span style="color:#9ca3af;font-weight:600">优先级</span><span style="color:#dc2626">🔴 紧急</span>
            <span style="color:#9ca3af;font-weight:600">负责人</span><span>张明</span>
            <span style="color:#9ca3af;font-weight:600">目标版本</span><span>v2.1.0</span>
            <span style="color:#9ca3af;font-weight:600">截止日期</span><span style="color:#dc2626">7月22日</span>
          </div>
          <div style="margin-top:14px;border-top:1px solid #f3f4f6;padding-top:12px;font-size:11px;color:#6b7280;line-height:1.7">用户通过4步向导选择壳类型、导航模式、功能模块和技术栈，实时预览并生成可下载的应用壳 HTML 原型。</div>
        </div>
      </div>
    </div>
  </div>
</div>
</div>"""
html.append(S3)

# ── SHELL 4: 知识空间壳 ──────────────────────────────────────────────
S4 = """<div class="box" id="sp4">
<div id="s4">
  <div id="s4-topbar">
    <span style="font-size:17px">📚</span>
    <span style="font-weight:800;font-size:13px">KnowledgeBase</span>
    <span style="color:#e5e7eb">|</span>
    <span style="font-size:11px;color:#9ca3af">工程团队工作区</span>
    <div style="margin-left:auto;display:flex;gap:8px;align-items:center">
      <button style="border:1px solid #e5e7eb;border-radius:5px;padding:5px 12px;font-size:11px;color:#374151;background:#f9fafb">⌕ 搜索 ⌘P</button>
      <div style="width:24px;height:24px;background:#f59e0b;border-radius:50%;display:grid;place-items:center;color:#fff;font-size:10px;font-weight:900">陈</div>
    </div>
  </div>
  <div id="s4-body">
    <div id="s4-sidebar">
      <div class="s4-pg">工作空间</div>
      <div class="s4-pi">🏠 首页</div>
      <div class="s4-pi">📥 收件箱</div>
      <div style="height:1px;background:#e5e7eb;margin:6px 0"></div>
      <div class="s4-pi" style="font-weight:700;color:#111827"><span style="color:#9ca3af;font-size:10px">▼</span>📦 产品设计</div>
      <div style="padding-left:16px">
        <div class="s4-pi"><span style="color:#9ca3af;font-size:10px">▶</span>应用壳设计规范</div>
        <div class="s4-pi on"><span style="color:#9ca3af;font-size:10px">▼</span>导航模式研究</div>
        <div style="padding-left:16px">
          <div class="s4-pi"><span style="font-size:10px;color:transparent">▶</span>五种核心模式</div>
          <div style="padding:3px 7px;background:#dbeafe;color:#1e40af;font-weight:600;border-radius:4px;cursor:pointer;font-size:12px">● 壳类型矩阵（当前）</div>
          <div class="s4-pi"><span style="font-size:10px;color:transparent">▶</span>产品对比矩阵</div>
        </div>
        <div class="s4-pi"><span style="color:#9ca3af;font-size:10px">▶</span>组件设计系统</div>
      </div>
      <div class="s4-pi" style="font-weight:700;color:#111827;margin-top:4px"><span style="color:#9ca3af;font-size:10px">▶</span>⚙️ 工程实践</div>
      <div class="s4-pi" style="font-weight:700;color:#111827"><span style="color:#9ca3af;font-size:10px">▶</span>🗄️ 数据模型</div>
      <div class="s4-pi" style="font-weight:700;color:#111827"><span style="color:#9ca3af;font-size:10px">▶</span>📋 项目文档</div>
      <div style="height:1px;background:#e5e7eb;margin:6px 0"></div>
      <div class="s4-pi" style="color:#9ca3af">＋ 新建页面</div>
    </div>
    <div id="s4-canvas">
      <div style="padding:12px 40px 0;display:flex;align-items:center;gap:6px;font-size:11px;color:#9ca3af">
        <span>产品设计</span><span>/</span><span>导航模式研究</span><span>/</span><span style="color:#374151;font-weight:600">壳类型矩阵</span>
      </div>
      <div style="max-width:700px;margin:0 auto;padding:18px 40px 40px">
        <div style="font-size:28px;font-weight:900;color:#111827;margin-bottom:5px">应用壳类型矩阵</div>
        <div style="display:flex;align-items:center;gap:10px;margin-bottom:18px;font-size:11px;color:#9ca3af">
          <div style="width:20px;height:20px;background:#6366f1;border-radius:50%;display:grid;place-items:center;color:#fff;font-size:9px;font-weight:900">张</div>
          <span>张明 · 今天 09:30</span><span>·</span><span>👁 12 次查看</span>
        </div>
        <p style="font-size:13px;color:#374151;line-height:1.8;margin-bottom:18px">本页面汇总从 14 款产品分析提炼的 <strong>7 种应用壳类型</strong>，每种壳有明确的导航模型和适用场景，用于向导生成器的设计决策。</p>
        <div style="border:1px solid #e5e7eb;border-radius:6px;overflow:hidden;margin-bottom:18px">
          <div style="background:#fafafa;padding:8px 14px;border-bottom:1px solid #e5e7eb;display:flex;align-items:center;gap:8px">
            <span style="font-size:11px;font-weight:700;color:#374151">🗄️ 壳类型数据库</span>
            <div style="display:flex;gap:4px;margin-left:auto">
              <button style="background:#111827;border:none;border-radius:3px;padding:2px 8px;font-size:10px;color:#fff">表格</button>
              <button style="background:none;border:1px solid #e5e7eb;border-radius:3px;padding:2px 8px;font-size:10px;color:#6b7280">看板</button>
            </div>
          </div>
          <table style="width:100%;border-collapse:collapse;font-size:11px">
            <thead><tr style="background:#fafafa">
              <th style="padding:8px 12px;text-align:left;font-weight:700;color:#374151;border-bottom:1px solid #e5e7eb">壳类型</th>
              <th style="padding:8px 12px;text-align:left;font-weight:700;color:#374151;border-bottom:1px solid #e5e7eb">导航模型</th>
              <th style="padding:8px 12px;text-align:left;font-weight:700;color:#374151;border-bottom:1px solid #e5e7eb">代表产品</th>
              <th style="padding:8px 12px;text-align:left;font-weight:700;color:#374151;border-bottom:1px solid #e5e7eb">详情展开</th>
            </tr></thead>
            <tbody>
              <tr style="border-bottom:1px solid #f3f4f6"><td style="padding:7px 12px;font-weight:600">🏢 企业业务壳</td><td style="padding:7px 12px;color:#6b7280">App→Object→Record</td><td style="padding:7px 12px;color:#6b7280">Salesforce, SAP</td><td style="padding:7px 12px"><span style="background:#dbeafe;color:#1d4ed8;padding:1px 6px;border-radius:8px;font-size:10px;font-weight:700">侧边抽屉</span></td></tr>
              <tr style="border-bottom:1px solid #f3f4f6"><td style="padding:7px 12px;font-weight:600">✅ 任务协作壳</td><td style="padding:7px 12px;color:#6b7280">Team→View→Issue</td><td style="padding:7px 12px;color:#6b7280">Linear, Jira</td><td style="padding:7px 12px"><span style="background:#ede9fe;color:#5b21b6;padding:1px 6px;border-radius:8px;font-size:10px;font-weight:700">Split面板</span></td></tr>
              <tr style="border-bottom:1px solid #f3f4f6;background:#eff6ff"><td style="padding:7px 12px;font-weight:700;color:#1e40af">📝 知识空间壳</td><td style="padding:7px 12px;color:#6b7280">Workspace→Hub→Page</td><td style="padding:7px 12px;color:#6b7280">Notion, Outline</td><td style="padding:7px 12px"><span style="background:#dbeafe;color:#1d4ed8;padding:1px 6px;border-radius:8px;font-size:10px;font-weight:700">原地画布</span></td></tr>
              <tr style="border-bottom:1px solid #f3f4f6"><td style="padding:7px 12px;font-weight:600">⌨️ 开发者工具壳</td><td style="padding:7px 12px;color:#6b7280">ActivityBar→Sidebar→Editor</td><td style="padding:7px 12px;color:#6b7280">VS Code, GitHub</td><td style="padding:7px 12px"><span style="background:#f3f4f6;color:#374151;padding:1px 6px;border-radius:8px;font-size:10px;font-weight:700">Editor Tab</span></td></tr>
            </tbody>
          </table>
        </div>
        <h2 style="font-size:17px;font-weight:800;margin:0 0 8px;color:#111827">Hub-and-Spoke 架构原则</h2>
        <p style="font-size:13px;color:#374151;line-height:1.8;margin-bottom:12px">Notion 官方建议：根层级保持 <strong>5~8 个 Hub</strong>，每个 Hub 代表一个稳定业务域。任意内容页面三次点击内可达（Hub → Section → 内容页）。</p>
        <div style="background:#fffbeb;border-left:3px solid #f59e0b;padding:12px 16px;border-radius:0 4px 4px 0;font-size:12px;color:#92400e;line-height:1.6">
          ⚠️ 根层级超过 10 个页面后侧边栏变成"壁纸"，用户只记住自己常用的3个页面。建议在 IA 超过 3 层深度之前先建立显式归档策略。
        </div>
      </div>
    </div>
  </div>
</div>
</div>"""
html.append(S4)

# ── SHELL 5: 开发者工具壳 ─────────────────────────────────────────────
S5 = """<div class="box" id="sp5">
<div id="s5">
  <div id="s5-titlebar">
    <div style="display:flex;gap:5px;margin-right:12px">
      <div style="width:11px;height:11px;border-radius:50%;background:#ff5f57"></div>
      <div style="width:11px;height:11px;border-radius:50%;background:#febc2e"></div>
      <div style="width:11px;height:11px;border-radius:50%;background:#28c840"></div>
    </div>
    <span style="color:#858585">app-shell-wizard — Visual Studio Code</span>
    <div style="margin-left:auto;display:flex;gap:14px;font-size:11px;color:#858585">
      <span style="cursor:pointer">文件</span><span style="cursor:pointer">编辑</span><span style="cursor:pointer">视图</span><span style="cursor:pointer">终端</span><span style="cursor:pointer">帮助</span>
    </div>
  </div>
  <div id="s5-body">
    <div id="s5-actbar">
      <div style="width:34px;height:34px;border-radius:4px;background:#0078d4;display:grid;place-items:center;font-size:16px;margin-bottom:6px;cursor:pointer">🗂</div>
      <div style="width:34px;height:34px;border-radius:4px;background:rgba(255,255,255,.08);display:grid;place-items:center;font-size:16px;cursor:pointer;color:#cccccc">🔍</div>
      <div style="width:34px;height:34px;border-radius:4px;display:grid;place-items:center;font-size:16px;cursor:pointer;color:#858585">⎇</div>
      <div style="width:34px;height:34px;border-radius:4px;display:grid;place-items:center;font-size:16px;cursor:pointer;color:#858585">🐛</div>
      <div style="width:34px;height:34px;border-radius:4px;display:grid;place-items:center;font-size:16px;cursor:pointer;color:#858585">🧩</div>
      <div style="margin-top:auto;width:34px;height:34px;border-radius:50%;background:#6366f1;display:grid;place-items:center;color:#fff;font-size:11px;font-weight:900;cursor:pointer">张</div>
    </div>
    <div id="s5-sidebar">
      <div style="padding:8px 12px;font-size:10px;font-weight:700;color:#bbbbbb;text-transform:uppercase;letter-spacing:.5px;display:flex;justify-content:space-between">
        <span>资源管理器</span><span style="cursor:pointer;color:#858585">⋯</span>
      </div>
      <div style="padding:3px 8px 3px 12px;color:#cccccc;cursor:pointer;font-size:12px;background:rgba(255,255,255,.05);display:flex;align-items:center;gap:4px">
        <span style="font-size:10px;color:#858585">▼</span> APP-SHELL-WIZARD
      </div>
      <div style="padding-left:20px">
        <div style="display:flex;align-items:center;gap:4px;padding:3px 8px;color:#858585;cursor:pointer;font-size:11px"><span style="font-size:10px">▼</span> src</div>
        <div style="padding-left:16px">
          <div style="display:flex;align-items:center;gap:4px;padding:3px 8px;color:#858585;cursor:pointer;font-size:11px"><span style="font-size:10px">▼</span> components</div>
          <div style="padding-left:16px">
            <div style="padding:3px 8px;color:#9cdcfe;cursor:pointer;font-size:11px;background:rgba(255,255,255,.06)">ShellWizard.tsx</div>
            <div style="padding:3px 8px;color:#9cdcfe;cursor:pointer;font-size:11px">ShellPreview.tsx</div>
            <div style="padding:3px 8px;color:#9cdcfe;cursor:pointer;font-size:11px">NavConfigurator.tsx</div>
          </div>
          <div style="display:flex;align-items:center;gap:4px;padding:3px 8px;color:#858585;cursor:pointer;font-size:11px"><span style="font-size:10px">▶</span> shells</div>
          <div style="display:flex;align-items:center;gap:4px;padding:3px 8px;color:#858585;cursor:pointer;font-size:11px"><span style="font-size:10px">▶</span> hooks</div>
        </div>
        <div style="padding:3px 8px;color:#4ec9b0;cursor:pointer;font-size:11px">package.json</div>
        <div style="padding:3px 8px;color:#f8f8f2;cursor:pointer;font-size:11px">README.md</div>
        <div style="padding:3px 8px;color:#858585;cursor:pointer;font-size:11px">tsconfig.json</div>
      </div>
    </div>
    <div id="s5-editor-wrap">
      <div id="s5-tabs">
        <div style="display:flex;align-items:center;gap:6px;padding:0 14px;height:34px;background:#1e1e1e;border-top:1px solid #0078d4;border-right:1px solid #252526;font-size:11px;color:#cccccc;white-space:nowrap;cursor:pointer">
          <span style="color:#9cdcfe">⬡</span> ShellWizard.tsx <span style="color:#858585;font-size:10px">✕</span>
        </div>
        <div style="display:flex;align-items:center;gap:6px;padding:0 14px;height:34px;background:#2d2d2d;border-right:1px solid #252526;font-size:11px;color:#858585;white-space:nowrap;cursor:pointer">
          <span>⬡</span> shellSchema.ts <span style="font-size:10px">✕</span>
        </div>
      </div>
      <div id="s5-breadcrumb">src &gt; components &gt; <span style="color:#cccccc">ShellWizard.tsx</span> &gt; ShellWizard</div>
      <div id="s5-code">
        <div style="display:flex">
          <div style="width:46px;text-align:right;padding-right:14px;color:#858585;font-size:11px;flex-shrink:0;user-select:none;line-height:1.8">
            1<br>2<br>3<br>4<br>5<br>6<br>7<br>8<br>9<br>10<br>11<br>12<br>13<br>14<br>15<br>16<br>17<br>18<br>19<br>20
          </div>
          <div style="flex:1;padding-right:20px;font-size:12px;line-height:1.8">
            <span style="color:#6a9955">// 应用壳向导 - 步骤1：选择壳类型</span><br>
            <span style="color:#569cd6">import</span> <span style="color:#9cdcfe">React</span>, { <span style="color:#9cdcfe">useState</span> } <span style="color:#569cd6">from</span> <span style="color:#ce9178">'react'</span>;<br>
            <span style="color:#569cd6">import</span> { <span style="color:#9cdcfe">ShellType</span>, <span style="color:#9cdcfe">SHELL_CONFIGS</span> } <span style="color:#569cd6">from</span> <span style="color:#ce9178">'../shells/schema'</span>;<br>
            <br>
            <span style="color:#569cd6">interface</span> <span style="color:#4ec9b0">Step1Props</span> {<br>
            &nbsp;&nbsp;<span style="color:#9cdcfe">selected</span><span>:</span> <span style="color:#4ec9b0">ShellType</span> | <span style="color:#569cd6">null</span>;<br>
            &nbsp;&nbsp;<span style="color:#9cdcfe">onSelect</span><span>:</span> (<span style="color:#9cdcfe">t</span>: <span style="color:#4ec9b0">ShellType</span>) <span style="color:#569cd6">=&gt;</span> <span style="color:#569cd6">void</span>;<br>
            }<br>
            <br>
            <span style="color:#569cd6">export</span> <span style="color:#569cd6">const</span> <span style="background:rgba(0,120,212,.2);padding:0 2px"><span style="color:#dcdcaa">ShellWizard</span></span> = ({ <span style="color:#9cdcfe">selected</span>, <span style="color:#9cdcfe">onSelect</span> }: <span style="color:#4ec9b0">Step1Props</span>) <span style="color:#569cd6">=&gt;</span> {<br>
            &nbsp;&nbsp;<span style="color:#569cd6">return</span> (<br>
            &nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#808080">&lt;</span><span style="color:#4ec9b0">div</span> <span style="color:#9cdcfe">className</span>=<span style="color:#ce9178">"shell-type-grid"</span><span style="color:#808080">&gt;</span><br>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<span style="color:#9cdcfe">SHELL_CONFIGS</span>.<span style="color:#dcdcaa">map</span>((<span style="color:#9cdcfe">cfg</span>) <span style="color:#569cd6">=&gt;</span> (<br>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#808080">&lt;</span><span style="color:#4ec9b0">ShellTypeCard</span><br>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#9cdcfe">key</span>={<span style="color:#9cdcfe">cfg</span>.<span style="color:#9cdcfe">id</span>}<br>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#9cdcfe">config</span>={<span style="color:#9cdcfe">cfg</span>}<br>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#9cdcfe">isSelected</span>={<span style="color:#9cdcfe">selected</span> === <span style="color:#9cdcfe">cfg</span>.<span style="color:#9cdcfe">id</span>}<br>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#9cdcfe">onSelect</span>={() <span style="color:#569cd6">=&gt;</span> <span style="color:#dcdcaa">onSelect</span>(<span style="color:#9cdcfe">cfg</span>.<span style="color:#9cdcfe">id</span>)}<br>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#808080">/&gt;</span><br>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;))}<br>
            &nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#808080">&lt;/</span><span style="color:#4ec9b0">div</span><span style="color:#808080">&gt;</span>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div id="s5-panel">
    <div id="s5-panel-tabs">
      <span style="font-size:11px;color:#cccccc;border-bottom:1px solid #0078d4;padding:0 2px;cursor:pointer">终端</span>
      <span style="font-size:11px;color:#858585;cursor:pointer">问题</span>
      <span style="font-size:11px;color:#858585;cursor:pointer">输出</span>
      <div style="margin-left:auto;display:flex;gap:8px"><span style="font-size:14px;color:#858585;cursor:pointer">＋</span><span style="font-size:14px;color:#858585;cursor:pointer">×</span></div>
    </div>
    <div id="s5-terminal">
      <div><span style="color:#4ec9b0">张明@DESKTOP</span> <span style="color:#858585">MINGW64</span> <span style="color:#569cd6">~/app-shell-wizard</span></div>
      <div><span style="color:#4ec9b0">$</span> npm run dev</div>
      <div style="color:#858585">&gt; app-shell-wizard@0.1.0 dev &gt; vite --port 3000</div>
      <div><span style="color:#4ec9b0">✓</span> VITE v5.4.1 ready in <span style="color:#dcdcaa">312</span>ms</div>
      <div>&nbsp;&nbsp;<span style="color:#858585">➜</span> Local: <span style="color:#569cd6">http://localhost:3000/</span></div>
      <div>&nbsp;&nbsp;<span style="color:#858585">➜</span> Network: <span style="color:#569cd6">http://192.168.1.42:3000/</span></div>
    </div>
  </div>
  <div id="s5-status">
    <span>⎇ main</span><span>✓ 0 errors</span><span>⚠ 2 warnings</span>
    <span style="margin-left:auto">TypeScript React</span><span>UTF-8</span><span>Ln 10, Col 32</span>
  </div>
</div>
</div>"""
html.append(S5)

# ── SHELL 6: 后台管理壳 ──────────────────────────────────────────────
S6 = """<div class="box" id="sp6">
<div id="s6">
  <div id="s6-topbar">
    <div style="display:flex;align-items:center;gap:10px">
      <div style="width:28px;height:28px;background:#1890ff;border-radius:4px;display:grid;place-items:center;color:#fff;font-size:14px;font-weight:900">N</div>
      <span style="font-weight:800;font-size:14px;color:#fff">NMS Cloud</span>
    </div>
    <div style="height:20px;width:1px;background:rgba(255,255,255,.2)"></div>
    <div style="display:flex;gap:2px">
      <div style="padding:6px 14px;color:rgba(255,255,255,.85);font-size:12px;cursor:pointer;border-radius:3px;background:rgba(255,255,255,.1)">控制台</div>
      <div style="padding:6px 14px;color:rgba(255,255,255,.45);font-size:12px;cursor:pointer;border-radius:3px">商品管理</div>
      <div style="padding:6px 14px;color:rgba(255,255,255,.45);font-size:12px;cursor:pointer;border-radius:3px">订单管理</div>
      <div style="padding:6px 14px;color:rgba(255,255,255,.45);font-size:12px;cursor:pointer;border-radius:3px">营销活动</div>
      <div style="padding:6px 14px;color:rgba(255,255,255,.45);font-size:12px;cursor:pointer;border-radius:3px">报表分析</div>
    </div>
    <div style="margin-left:auto;display:flex;align-items:center;gap:14px;color:rgba(255,255,255,.7);font-size:16px">
      <span style="cursor:pointer">🔍</span>
      <span style="cursor:pointer">🔔</span>
      <div style="display:flex;align-items:center;gap:6px;cursor:pointer">
        <div style="width:26px;height:26px;background:#1890ff;border:2px solid rgba(255,255,255,.4);border-radius:50%;display:grid;place-items:center;color:#fff;font-size:11px;font-weight:900">林</div>
        <span style="font-size:12px;color:rgba(255,255,255,.85)">林晓 ⌄</span>
      </div>
    </div>
  </div>
  <div id="s6-body">
    <div id="s6-menu">
      <div style="padding:10px 16px 4px;font-size:10px;font-weight:700;color:rgba(255,255,255,.35);letter-spacing:.5px;text-transform:uppercase">经营概览</div>
      <div class="ant-menu-item on"><span>📊</span>工作台</div>
      <div class="ant-menu-item"><span>📈</span>数据概览</div>
      <div style="padding:10px 16px 4px;font-size:10px;font-weight:700;color:rgba(255,255,255,.35);letter-spacing:.5px;text-transform:uppercase;margin-top:8px">商户管理</div>
      <div class="ant-menu-item" style="justify-content:space-between"><div style="display:flex;align-items:center;gap:8px"><span>🏪</span>商户列表</div><span style="background:rgba(255,255,255,.15);border-radius:10px;padding:1px 6px;font-size:10px">128</span></div>
      <div class="ant-menu-item"><span>👥</span>员工管理</div>
      <div style="padding:10px 16px 4px;font-size:10px;font-weight:700;color:rgba(255,255,255,.35);letter-spacing:.5px;text-transform:uppercase;margin-top:8px">系统设置</div>
      <div class="ant-menu-item"><span>⚙️</span>权限管理</div>
      <div class="ant-menu-item"><span>📝</span>操作日志</div>
    </div>
    <div id="s6-content">
      <div style="display:flex;align-items:center;gap:6px;font-size:12px;color:#8c8c8c;margin-bottom:14px">
        <span style="color:#1890ff;cursor:pointer">首页</span><span>/</span><span style="color:#595959">工作台</span>
      </div>
      <div class="ant-kpi">
        <div class="ant-kpi-item"><div style="font-size:11px;color:#8c8c8c;margin-bottom:5px">本月营业额</div><div style="font-size:22px;font-weight:700;color:#262626">¥ 284.6万</div><div style="font-size:11px;color:#52c41a;margin-top:3px">↑ 12.8% 较上月</div></div>
        <div class="ant-kpi-item"><div style="font-size:11px;color:#8c8c8c;margin-bottom:5px">活跃商户数</div><div style="font-size:22px;font-weight:700;color:#262626">1,284</div><div style="font-size:11px;color:#52c41a;margin-top:3px">↑ 36 本月新增</div></div>
        <div class="ant-kpi-item"><div style="font-size:11px;color:#8c8c8c;margin-bottom:5px">订单总数</div><div style="font-size:22px;font-weight:700;color:#262626">18,472</div><div style="font-size:11px;color:#faad14;margin-top:3px">↓ 3.2% 较上月</div></div>
        <div class="ant-kpi-item"><div style="font-size:11px;color:#8c8c8c;margin-bottom:5px">待处理工单</div><div style="font-size:22px;font-weight:700;color:#ff4d4f">36</div><div style="font-size:11px;color:#ff4d4f;margin-top:3px">12 项今日到期</div></div>
      </div>
      <div class="ant-card">
        <div class="ant-card-hd">
          <span style="font-size:14px;font-weight:700;color:#262626">最新商户列表</span>
          <div style="display:flex;gap:8px">
            <button style="border:1px solid #d9d9d9;background:#fff;border-radius:4px;padding:5px 12px;font-size:12px;color:#595959;cursor:pointer">导出</button>
            <button style="background:#1890ff;border:none;border-radius:4px;padding:5px 12px;font-size:12px;color:#fff;cursor:pointer">＋ 新增商户</button>
          </div>
        </div>
        <div style="padding:10px 14px;border-bottom:1px solid #f5f5f5;display:flex;gap:10px;align-items:center">
          <input style="border:1px solid #d9d9d9;border-radius:4px;padding:5px 10px;font-size:12px;width:180px;outline:none" placeholder="🔍 搜索商户名称/ID" readonly>
          <select style="border:1px solid #d9d9d9;border-radius:4px;padding:5px 10px;font-size:12px;color:#595959;background:#fff;outline:none"><option>全部状态</option></select>
          <select style="border:1px solid #d9d9d9;border-radius:4px;padding:5px 10px;font-size:12px;color:#595959;background:#fff;outline:none"><option>全部类型</option></select>
        </div>
        <table class="ant-tbl">
          <thead><tr>
            <th>商户名称</th><th>类型</th><th>本月流水</th><th>状态</th><th>创建时间</th><th>操作</th>
          </tr></thead>
          <tbody>
            <tr><td style="font-weight:600">上海星河科技有限公司</td><td style="color:#8c8c8c">零售餐饮</td><td style="font-weight:600">¥ 48,620</td><td><span style="background:#f6ffed;color:#52c41a;border:1px solid #b7eb8f;padding:1px 7px;border-radius:10px;font-size:10px;font-weight:700">正常</span></td><td style="color:#8c8c8c">2024-03-15</td><td><span style="color:#1890ff;cursor:pointer">查看</span> · <span style="color:#1890ff;cursor:pointer">编辑</span></td></tr>
            <tr style="background:#e6f7ff"><td style="font-weight:600;color:#1890ff">苏州云杉连锁餐饮</td><td style="color:#8c8c8c">连锁餐饮</td><td style="font-weight:600">¥ 124,380</td><td><span style="background:#f6ffed;color:#52c41a;border:1px solid #b7eb8f;padding:1px 7px;border-radius:10px;font-size:10px;font-weight:700">正常</span></td><td style="color:#8c8c8c">2023-11-08</td><td><span style="color:#1890ff;cursor:pointer">查看</span> · <span style="color:#1890ff;cursor:pointer">编辑</span></td></tr>
            <tr><td style="font-weight:600">深圳蓝海零售集团</td><td style="color:#8c8c8c">商超零售</td><td style="font-weight:600">¥ 89,140</td><td><span style="background:#fff7e6;color:#faad14;border:1px solid #ffd591;padding:1px 7px;border-radius:10px;font-size:10px;font-weight:700">审核中</span></td><td style="color:#8c8c8c">2024-07-01</td><td><span style="color:#1890ff;cursor:pointer">查看</span> · <span style="color:#faad14;cursor:pointer">审核</span></td></tr>
            <tr><td style="font-weight:600">北京华润酒店管理</td><td style="color:#8c8c8c">酒店餐饮</td><td style="font-weight:600">¥ 36,800</td><td><span style="background:#fff1f0;color:#ff4d4f;border:1px solid #ffa39e;padding:1px 7px;border-radius:10px;font-size:10px;font-weight:700">已停用</span></td><td style="color:#8c8c8c">2023-06-20</td><td><span style="color:#1890ff;cursor:pointer">查看</span> · <span style="color:#52c41a;cursor:pointer">启用</span></td></tr>
          </tbody>
        </table>
        <div style="padding:12px 18px;border-top:1px solid #f0f0f0;display:flex;align-items:center;justify-content:space-between">
          <span style="font-size:12px;color:#8c8c8c">共 128 条记录</span>
          <div style="display:flex;gap:4px;font-size:12px;align-items:center">
            <span style="padding:4px 8px;background:#1890ff;color:#fff;border-radius:3px;cursor:pointer">1</span>
            <span style="padding:4px 8px;color:#595959;cursor:pointer;border:1px solid #d9d9d9;border-radius:3px">2</span>
            <span style="padding:4px 8px;color:#595959;cursor:pointer;border:1px solid #d9d9d9;border-radius:3px">3</span>
            <span style="color:#8c8c8c;padding:4px 8px;cursor:pointer">»</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
</div>"""
html.append(S6)
