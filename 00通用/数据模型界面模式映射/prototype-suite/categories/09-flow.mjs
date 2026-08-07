export const categoryNumber = "09";
function studio(ctx, title, ...children) { return ctx.el("div", { className: "demo col" }, ctx.el("h3", { text: title }), ...children); }
function indicator(ctx, text) { return ctx.el("div", { className: "status", text }); }
function renderWorkflowDesigner(ctx) { const flow = indicator(ctx, "开始 → 填单"); const connect = ctx.button("连接审批节点", "workflow-edge"); ctx.on(connect, "click", () => { flow.textContent = "开始 → 填单 → 审批；新增边 1"; ctx.setStatus("工作流边已创建", "edges:2"); }); ctx.stage.append(studio(ctx, "工作流", flow, connect)); return {}; }
function renderBpmnDesigner(ctx) { const token = indicator(ctx, "开始 → 排他网关"); const choose = ctx.button("选择金额≥1万分支", "bpmn-path"); ctx.on(choose, "click", () => { token.textContent = "Token 经过：开始 → 金额网关 → 经理审批"; ctx.setStatus("BPMN Token 进入经理分支", "path:manager"); }); ctx.stage.append(studio(ctx, "BPMN 网关", token, choose)); return {}; }
function renderApprovalFlow(ctx) { const flow = indicator(ctx, "申请 → 部门审批"); const branch = ctx.button("添加金额分支", "approval-branch"); ctx.on(branch, "click", () => { flow.textContent = "金额≥10,000 → 财务审批；否则 → 通过"; ctx.setStatus("审批条件分支已添加", "approval:branched"); }); ctx.stage.append(studio(ctx, "审批流", flow, branch)); return {}; }

function renderStateMachine(ctx) {
  let current = "draft"; const out = indicator(ctx, "当前状态：draft"); const transition = ctx.button("提交审核", "state-transition");
  ctx.on(transition, "click", () => { current = "review"; out.textContent = "当前状态：review；可执行 approve/reject"; ctx.setStatus("合法迁移 draft → review", `state:${current}`); }); ctx.stage.append(studio(ctx, "状态机", out, transition)); return { destroy() { current = "destroyed"; } };
}

function renderRuleDesigner(ctx) {
  const amount = ctx.el("input", { type: "number", value: 12000, "aria-label": "金额" }); const level = ctx.el("select", { "aria-label": "客户等级" }, ctx.el("option", { value: "VIP", text: "VIP" }), ctx.el("option", { value: "NORMAL", text: "普通" })); const out = indicator(ctx, "等待执行"); const run = ctx.button("执行所有条件", "rule-run");
  ctx.on(run, "click", () => { const hit = Number(amount.value) >= 10000 && level.value === "VIP"; out.textContent = `金额条件=${Number(amount.value) >= 10000}；等级条件=${level.value === "VIP"}；结果=${hit}`; ctx.setStatus(hit ? "规则命中" : "规则未命中", hit ? "rule:hit" : "rule:miss"); }); ctx.stage.append(studio(ctx, "规则输入一致性", amount, level, out, run)); return {};
}

function renderDecisionTable(ctx) {
  let vip = true; let amountHigh = false; const cellVip = ctx.button("VIP: 是", "decision-vip"); const cellAmount = ctx.button("金额≥1万: 否", "decision-amount"); const out = indicator(ctx, "等待命中策略"); const run = ctx.button("执行决策表", "decision-run");
  ctx.on(cellAmount, "click", () => { amountHigh = true; cellAmount.textContent = "金额≥1万: 是"; }); ctx.on(cellVip, "click", () => { vip = !vip; cellVip.textContent = `VIP: ${vip ? "是" : "否"}`; }); ctx.on(run, "click", () => { const action = vip && amountHigh ? "折扣 15%" : vip ? "折扣 8%" : "无折扣"; out.textContent = `输入 VIP=${vip}，高金额=${amountHigh}；命中：${action}`; ctx.setStatus(`决策结果：${action}`, `decision:${action}`); }); ctx.stage.append(studio(ctx, "决策表单元格", ctx.el("div", { className: "row" }, cellVip, cellAmount), out, run)); return {};
}

function renderDecisionTree(ctx) { const tree = indicator(ctx, "根：客户等级？"); const evaluate = ctx.button("沿 VIP 分支求值", "tree-evaluate"); ctx.on(evaluate, "click", () => { tree.textContent = "VIP → 金额≥1万 → 优惠 15%"; ctx.setStatus("决策树命中优惠叶子", "leaf:discount15"); }); ctx.stage.append(studio(ctx, "决策树", tree, evaluate)); return {}; }
function renderExpressionGraph(ctx) { const graph = indicator(ctx, "amount → multiply(taxRate)"); const connect = ctx.button("连接 round 节点", "expression-edge"); ctx.on(connect, "click", () => { graph.textContent = "amount → multiply → round；结果 107.00"; ctx.setStatus("表达式图结果 107", "expression:107"); }); ctx.stage.append(studio(ctx, "表达式图", graph, connect)); return {}; }
function renderDagDesigner(ctx) { const dag = indicator(ctx, "extract → transform"); const add = ctx.button("添加 load 依赖", "dag-edge"); ctx.on(add, "click", () => { dag.textContent = "extract → transform → load；拓扑序有效"; ctx.setStatus("DAG 增至 3 个节点", "dag:3"); }); ctx.stage.append(studio(ctx, "DAG 编排", dag, add)); return {}; }
function renderPipelineDesigner(ctx) { const stages = indicator(ctx, "读取[等待] → 清洗[等待]"); const run = ctx.button("运行下一阶段", "pipeline-run"); ctx.on(run, "click", () => { stages.textContent = "读取[完成] → 清洗[运行中] → 写入[等待]"; ctx.setStatus("清洗阶段运行中", "stage:cleaning"); }); ctx.stage.append(studio(ctx, "数据流水线", stages, run)); return {}; }
function renderJobOrchestrator(ctx) { const jobs = indicator(ctx, "作业 A / B / C 未调度"); const schedule = ctx.button("按依赖调度", "job-schedule"); ctx.on(schedule, "click", () => { jobs.textContent = "A[完成] → B[运行]；C 等待 B"; ctx.setStatus("作业 B 运行中", "job:B-running"); }); ctx.stage.append(studio(ctx, "作业编排", jobs, schedule)); return {}; }
function renderDependencyGraph(ctx) { const graph = indicator(ctx, "service-api → service-core"); const analyze = ctx.button("分析 core 变更", "dependency-impact"); ctx.on(analyze, "click", () => { graph.textContent = "影响：service-api、batch-job、3 个测试"; ctx.setStatus("依赖影响范围已计算", "impact:3"); }); ctx.stage.append(studio(ctx, "依赖影响", graph, analyze)); return {}; }
function renderServiceTopology(ctx) { const topology = indicator(ctx, "gateway → order-service"); const retry = ctx.button("模拟订单服务重试", "service-retry"); ctx.on(retry, "click", () => { topology.textContent = "gateway → order-service(第 2 次成功) → inventory"; ctx.setStatus("服务第 2 次重试成功", "retry:2-success"); }); ctx.stage.append(studio(ctx, "服务拓扑", topology, retry)); return {}; }
function renderNetworkTopology(ctx) { const network = indicator(ctx, "Router A：正常；Switch B：正常"); const disconnect = ctx.button("断开 Switch B", "network-health"); ctx.on(disconnect, "click", () => { network.textContent = "Switch B：离线；受影响终端 12"; ctx.setStatus("网络拓扑降级", "network:degraded"); }); ctx.stage.append(studio(ctx, "网络拓扑", network, disconnect)); return {}; }
function renderDataLineage(ctx) { const lineage = indicator(ctx, "raw_order → dwd_order"); const expand = ctx.button("展开下游", "lineage-expand"); ctx.on(expand, "click", () => { lineage.textContent = "raw_order → dwd_order → sales_report；影响 2 层"; ctx.setStatus("血缘下游已展开", "lineage:2"); }); ctx.stage.append(studio(ctx, "数据血缘", lineage, expand)); return {}; }
function renderErDesigner(ctx) { const relation = indicator(ctx, "Customer 实体"); const connect = ctx.button("关联 Order 1:N", "er-relation"); ctx.on(connect, "click", () => { relation.textContent = "Customer 1 ─── N Order；外键 customer_id"; ctx.setStatus("ER 一对多关系已创建", "relation:1-n"); }); ctx.stage.append(studio(ctx, "ER 关系", relation, connect)); return {}; }
function renderClassDiagram(ctx) { const classes = indicator(ctx, "OrderService"); const add = ctx.button("添加依赖 OrderRepository", "class-association"); ctx.on(add, "click", () => { classes.textContent = "OrderService ──uses──> OrderRepository"; ctx.setStatus("类依赖关联已创建", "association:uses"); }); ctx.stage.append(studio(ctx, "类图", classes, add)); return {}; }
function renderSequenceDiagram(ctx) { const messages = indicator(ctx, "User → UI"); const append = ctx.button("追加 API 调用", "sequence-message"); ctx.on(append, "click", () => { messages.textContent = "1 User→UI；2 UI→API；3 API→DB"; ctx.setStatus("时序消息增至 3 条", "messages:3"); }); ctx.stage.append(studio(ctx, "时序消息", messages, append)); return {}; }
function renderUseCaseDiagram(ctx) { const usecase = indicator(ctx, "参与者：销售"); const link = ctx.button("关联“创建订单”", "usecase-link"); ctx.on(link, "click", () => { usecase.textContent = "销售 ── 创建订单；权限 order.create"; ctx.setStatus("参与者与用例已关联", "usecase:linked"); }); ctx.stage.append(studio(ctx, "用例图", usecase, link)); return {}; }
function renderActivityDiagram(ctx) { const activity = indicator(ctx, "开始 → 填写资料"); const fork = ctx.button("添加并行校验", "activity-fork"); ctx.on(fork, "click", () => { activity.textContent = "填写资料 → [身份校验 ∥ 信用校验] → 汇合"; ctx.setStatus("活动图增加并行分支", "activity:parallel"); }); ctx.stage.append(studio(ctx, "活动图", activity, fork)); return {}; }
function renderFlowchartEditor(ctx) { const chart = indicator(ctx, "开始 → 处理"); const insert = ctx.button("插入判断节点", "flowchart-decision"); ctx.on(insert, "click", () => { chart.textContent = "开始 → 是否有效？ ├是→处理 └否→结束"; ctx.setStatus("流程图判断分支已插入", "flowchart:decision"); }); ctx.stage.append(studio(ctx, "流程图", chart, insert)); return {}; }
function renderMindMap(ctx) { const map = indicator(ctx, "中心：产品规划"); const branch = ctx.button("添加“市场”分支", "mindmap-branch"); ctx.on(branch, "click", () => { map.textContent = "产品规划 ├ 功能 └ 市场（竞品/用户）"; ctx.setStatus("思维导图增至 2 个主分支", "branches:2"); }); ctx.stage.append(studio(ctx, "思维导图", map, branch)); return {}; }
function renderConceptMap(ctx) { const map = indicator(ctx, "概念：订单、客户"); const relate = ctx.button("定义“由…创建”关系", "concept-relation"); ctx.on(relate, "click", () => { map.textContent = "客户 ──创建──> 订单；关系类型=业务动作"; ctx.setStatus("概念关系类型已定义", "concept:creates"); }); ctx.stage.append(studio(ctx, "概念图", map, relate)); return {}; }
function renderNodeEditor(ctx) { const ports = indicator(ctx, "Source.out（未连接）"); const connect = ctx.button("连接 Transform.in", "node-connect"); ctx.on(connect, "click", () => { ports.textContent = "Source.out → Transform.in；类型 String 匹配"; ctx.setStatus("节点端口已连接", "ports:connected"); }); ctx.stage.append(studio(ctx, "端口节点编辑", ports, connect)); return {}; }

function renderInfiniteCanvas(ctx) {
  let zoom = 1; let x = 0; const canvas = ctx.el("div", { className: "canvas", text: "视口 x=0, zoom=1.0" }); const move = ctx.button("向右平移并放大", "canvas-transform");
  ctx.on(move, "click", () => { x += 160; zoom = 1.25; canvas.textContent = `视口 x=${x}, zoom=${zoom.toFixed(2)}；节点坐标保持世界空间`; ctx.setStatus("无限画布视口已变换", `viewport:${x}@${zoom}`); }); ctx.stage.append(studio(ctx, "无限画布", canvas, move)); return {};
}

export const renderers09 = Object.freeze({
  "09:workflow-designer": renderWorkflowDesigner, "09:bpmn-designer": renderBpmnDesigner, "09:approval-flow": renderApprovalFlow,
  "09:state-machine": renderStateMachine, "09:rule-designer": renderRuleDesigner, "09:decision-table": renderDecisionTable,
  "09:decision-tree": renderDecisionTree, "09:expression-graph": renderExpressionGraph, "09:dag-designer": renderDagDesigner,
  "09:pipeline-designer": renderPipelineDesigner, "09:job-orchestrator": renderJobOrchestrator, "09:dependency-graph": renderDependencyGraph,
  "09:service-topology": renderServiceTopology, "09:network-topology": renderNetworkTopology, "09:data-lineage": renderDataLineage,
  "09:er-designer": renderErDesigner, "09:class-diagram": renderClassDiagram, "09:sequence-diagram": renderSequenceDiagram,
  "09:use-case-diagram": renderUseCaseDiagram, "09:activity-diagram": renderActivityDiagram, "09:flowchart-editor": renderFlowchartEditor,
  "09:mind-map": renderMindMap, "09:concept-map": renderConceptMap, "09:node-editor": renderNodeEditor,
  "09:infinite-canvas": renderInfiniteCanvas,
});
export const renderers = renderers09;
