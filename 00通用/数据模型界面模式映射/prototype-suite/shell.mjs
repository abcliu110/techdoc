import { browserDomSource, escapeHtml } from "./dom.mjs";
import { suiteCss } from "./styles.mjs";

function handbookRuntime(category, rendererRegistry) {
  const patterns = category.components;
  let currentIndex = -1;
  let mounted = null;
  let toastTimer = 0;
  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];

  function showToast(message) {
    const toast = $("#toast");
    toast.textContent = String(message);
    toast.classList.add("show");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => toast.classList.remove("show"), 1400);
  }

  function renderNav() {
    const query = $("#search").value.trim().toLowerCase();
    const items = patterns.flatMap((component, index) => {
      const haystack = [component.name, component.en, component.model, component.state].join(" ").toLowerCase();
      if (query && !haystack.includes(query)) return [];
      const item = document.createElement("button");
      item.type = "button";
      item.dataset.index = String(index);
      item.className = index === currentIndex ? "active" : "";
      item.setAttribute("aria-label", component.name);
      const number = document.createElement("span");
      number.className = "num";
      number.textContent = String(index + 1).padStart(2, "0");
      const label = document.createElement("span");
      label.textContent = component.name;
      const english = document.createElement("span");
      english.className = "en";
      english.textContent = component.en;
      label.append(english);
      item.append(number, label);
      return [item];
    });
    $("#nav").replaceChildren(...items);
  }

  function destroyMounted() {
    if (!mounted) return;
    try { mounted.result?.destroy?.(); } finally { mounted.dom.cleanup(); }
    mounted = null;
  }

  function mount(component) {
    destroyMounted();
    const stage = $("#stage");
    stage.removeAttribute("aria-disabled");
    stage.inert = false;
    stage.replaceChildren();
    const stateNode = $("#prototypeState");
    stateNode.textContent = "初始状态";
    stateNode.dataset.state = "initial";
    const dom = createDomRuntime(stage, stateNode, $("#toast"));
    const renderer = rendererRegistry[component.key];
    if (typeof renderer !== "function") throw new Error("Missing renderer: " + component.key);
    const result = renderer({ ...dom, component, showToast });
    mounted = { dom, result };
    const readinessResult = $("#readinessResult");
    readinessResult.className = "business-notice";
    readinessResult.textContent = component.contract?.business ? "预期业务影响：" + component.contract.business.effect : "";
  }

  function setStageLocked(locked) {
    const stage = $("#stage");
    if (locked) stage.setAttribute("aria-disabled", "true");
    else stage.removeAttribute("aria-disabled");
    stage.inert = locked;
    $$(`button,input,select,textarea,[tabindex]`, stage).forEach((control) => {
      if (locked) {
        control.dataset.readinessDisabled = String(Boolean(control.disabled));
        control.disabled = true;
      } else {
        control.disabled = control.dataset.readinessDisabled === "true";
        delete control.dataset.readinessDisabled;
      }
    });
    if (!locked) {
      const target = $("button:not(:disabled),input:not(:disabled),select:not(:disabled),textarea:not(:disabled),[tabindex]:not([tabindex='-1'])", stage);
      target?.focus();
    }
  }

  function updateSystemReadiness(state) {
    const root = $("#systemReadiness");
    if (root.hidden) return;
    $$(`[data-system-step]`, root).forEach((step, index) => {
      step.className = "business-timeline-item";
      if (state === "primary") step.classList.add("done");
      if (state === "exception" && index === 1) step.classList.add("error");
      if (state === "recovered" && index <= 1) step.classList.add("done");
    });
    $("#systemCompensation", root).className = state === "exception" ? "business-notice business-error" : "business-notice";
  }

  function renderTaskContext(component) {
    const root = $("#taskContext");
    const result = $("#readinessResult");
    const contract = component.contract;
    if (!contract?.business || !contract?.readiness) {
      root.hidden = true;
      result.textContent = "";
      return;
    }
    root.hidden = false;
    const business = contract.business;
    const fields = [
      ["当前角色", business.role],
      ["业务任务", business.task],
      ["业务对象", business.objects.join(" · ")],
      ["决策规则", business.rule],
    ];
    $("#taskFields").replaceChildren(...fields.map(([label, value]) => {
      const field = document.createElement("div");
      field.className = "business-field";
      const caption = document.createElement("span");
      caption.className = "business-label";
      caption.textContent = label;
      const content = document.createElement("strong");
      content.textContent = value;
      field.append(caption, content);
      return field;
    }));
    $("#taskLevel").textContent = contract.business.level + " 级交互规范";
    $("#taskException").textContent = business.exception;
    $("#taskRecovery").textContent = contract.readiness.recovery;
    $("#taskKeyboard").textContent = contract.readiness.keyboard;
    const systemRoot = $("#systemReadiness");
    const systemBusiness = business.level === "C" ? business : null;
    systemRoot.hidden = !systemBusiness;
    if (systemBusiness) {
      $("#systemResponsibilities").replaceChildren(...systemBusiness.responsibilities.map((value) => {
        const item = document.createElement("li"); item.textContent = value; return item;
      }));
      $("#systemTimeline").replaceChildren(...systemBusiness.timeline.map((value) => {
        const item = document.createElement("div"); item.className = "business-timeline-item"; item.dataset.systemStep = "";
        const copy = document.createElement("span"); copy.textContent = value; item.append(copy); return item;
      }));
      $("#systemCompensation").textContent = "补偿路径：" + systemBusiness.compensation;
      updateSystemReadiness("initial");
    }
    result.className = "business-notice";
    result.textContent = "预期业务影响：" + business.effect;
  }

  function show(index, options = {}) {
    const nextIndex = Math.max(0, Math.min(patterns.length - 1, index));
    const component = patterns[nextIndex];
    currentIndex = nextIndex;
    renderNav();
    $("#count").textContent = String(nextIndex + 1).padStart(2, "0") + " / " + patterns.length;
    $("#eyebrow").textContent = (category.number + " · " + (component.kind || component.group || "COMPONENT")).toUpperCase();
    const englishTitle = document.createElement("small");
    englishTitle.textContent = component.en;
    $("#title").replaceChildren(document.createTextNode(component.name + " "), englishTitle);
    $("#summary").textContent = component.summary;

    const factData = [
      ["统一模型", "Component = Data + State + Action"],
      ["数据模型", component.model],
      ["核心状态", component.state],
    ];
    $("#facts").replaceChildren(...factData.map(([label, value]) => {
      const fact = document.createElement("div");
      fact.className = "fact";
      const labelNode = document.createElement("div");
      labelNode.className = "label";
      labelNode.textContent = label;
      const valueNode = document.createElement("div");
      valueNode.className = "value";
      valueNode.textContent = value;
      fact.append(labelNode, valueNode);
      return fact;
    }));

    const noteData = [["适用边界", component.boundary], ["关键不变量", component.invariant]];
    $("#notes").replaceChildren(...noteData.map(([heading, copy]) => {
      const article = document.createElement("article");
      article.className = "note";
      const title = document.createElement("h2");
      title.textContent = heading;
      const text = document.createElement("p");
      text.textContent = copy;
      article.append(title, text);
      return article;
    }));
    renderTaskContext(component);
    mount(component);
    $("#main").scrollTop = 0;
    $("#side").classList.remove("open");
    if (options.updateHash !== false && location.hash.slice(1) !== component.id) location.hash = component.id;
  }

  function showFromHash() {
    const id = decodeURIComponent(location.hash.slice(1));
    const index = patterns.findIndex((component) => component.id === id);
    show(index >= 0 ? index : 0, { updateHash: false });
  }

  $("#nav").addEventListener("click", (event) => {
    const item = event.target.closest("[data-index]");
    if (item) show(Number(item.dataset.index));
  });
  $("#search").addEventListener("input", renderNav);
  $("#menu").addEventListener("click", () => $("#side").classList.toggle("open"));
  $("#prev").addEventListener("click", () => show(currentIndex - 1));
  $("#next").addEventListener("click", () => show(currentIndex + 1));
  $("#reset").addEventListener("click", () => { mount(patterns[currentIndex]); showToast("原型已重置"); });
  $("#taskContext").addEventListener("click", (event) => {
    const contract = patterns[currentIndex]?.contract;
    if (!contract) return;
    const result = $("#readinessResult");
    const stateNode = $("#prototypeState");
    if (event.target.closest("[data-readiness-start]")) {
      result.className = "business-notice business-success";
      result.textContent = "任务已载入：" + contract.business.objects.join(" · ") + "；规则：" + contract.business.rule;
      stateNode.textContent = "任务已载入 · " + contract.business.task;
      stateNode.dataset.state = "readiness:started";
    }
    if (event.target.closest("[data-readiness-exception]")) {
      setStageLocked(true);
      updateSystemReadiness("exception");
      result.className = "business-notice business-error";
      result.textContent = "非理想场景：" + contract.business.exception;
      stateNode.textContent = "异常路径 · " + contract.business.exception;
      stateNode.dataset.state = "readiness:exception";
    }
    if (event.target.closest("[data-readiness-recovery]")) {
      setStageLocked(false);
      updateSystemReadiness("recovered");
      result.className = "business-notice business-success";
      result.textContent = "已恢复：" + contract.readiness.recovery + "；" + contract.business.effect;
      stateNode.textContent = "恢复路径 · " + contract.readiness.recovery;
      stateNode.dataset.state = "readiness:recovered";
    }
  });
  ["click", "contextmenu"].forEach((type) => $("#stage").addEventListener(type, (event) => {
    if (!event.target.closest("button,input,select,textarea,[role='button'],[data-action]")) return;
    const contract = patterns[currentIndex]?.contract;
    if (!contract?.business) return;
    requestAnimationFrame(() => {
      const componentState = $("#prototypeState").dataset.state;
      updateSystemReadiness("primary");
      const result = $("#readinessResult");
      result.className = "business-notice business-success";
      result.textContent = "主路径完成：" + contract.business.effect + "；组件状态：" + componentState;
    });
  }));
  window.addEventListener("hashchange", showFromHash);
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      $("#side").classList.remove("open");
      if ($("#stage").getAttribute("aria-disabled") === "true") {
        setStageLocked(false);
        updateSystemReadiness("recovered");
        const contract = patterns[currentIndex]?.contract;
        $("#readinessResult").textContent = "已恢复：" + contract.readiness.recovery + "；" + contract.business.effect;
        $("#prototypeState").dataset.state = "readiness:recovered";
      }
    }
    const target = event.target;
    const editing = event.isComposing || target.closest?.("input,textarea,select,button,[contenteditable='true'],[contenteditable='']");
    if (editing) return;
    if (event.key === "ArrowLeft") show(currentIndex - 1);
    if (event.key === "ArrowRight") show(currentIndex + 1);
  });
  showFromHash();
}

export function buildHandbookHtml(category, rendererSource, registryName) {
  const safeRendererSource = rendererSource
    .replace(/^export\s+default\s+[^;]+;?\s*$/gm, "")
    .replace(/^export\s+/gm, "");
  const title = category.name + "复杂组件交互原型手册";
  const runtime = browserDomSource + "\n(" + handbookRuntime.toString() + ")(" + JSON.stringify(category) + ", " + registryName + ");";
  return `<!doctype html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="icon" href="data:,"><title>${escapeHtml(title)}</title><style>${suiteCss}</style></head><body><div class="app"><header><button class="menu" id="menu" type="button" aria-label="打开目录">目录</button><span class="mark"></span><div class="brand">数据模型 × 界面模式 <small>${escapeHtml(category.name)}原型手册</small></div><div class="count" id="count"></div></header><div class="shell"><aside id="side"><div class="side-head"><div class="side-label">${escapeHtml(category.number)} · ${escapeHtml(category.en)}</div><input id="search" class="search" type="search" aria-label="搜索组件" placeholder="搜索组件名称或模型"></div><nav id="nav" class="nav" aria-label="组件目录"></nav><div class="side-foot">方向键切换 · Esc 收起目录</div></aside><main id="main" tabindex="-1"><div class="inner"><div class="hero"><div><div class="eyebrow" id="eyebrow"></div><h1 id="title"></h1><p class="summary" id="summary"></p></div><div class="pager"><button class="btn" id="prev" type="button">上一项</button><button class="btn" id="next" type="button">下一项</button></div></div><div class="facts" id="facts"></div><section class="proto"><div class="proto-head"><strong>关键交互原型</strong><span class="hint">本组件拥有独立结构、动作和状态。</span><div class="actions"><button class="btn" id="reset" type="button">重置原型</button></div></div><section class="business-task" id="taskContext" hidden><div class="business-task-head"><div><h3>生产级任务场景</h3><p>先载入任务上下文，再完成组件主动作；异常与恢复路径用于评审边界。</p></div><span class="business-badge" id="taskLevel"></span></div><div class="business-grid" id="taskFields"></div><div class="business-notice business-warning"><strong>非理想场景</strong><span id="taskException"></span></div><div class="business-actions"><button class="btn primary" type="button" data-readiness-start>载入任务上下文</button><button class="btn danger" type="button" data-readiness-exception>注入非理想场景</button><button class="btn business-recovery" type="button" data-readiness-recovery>执行恢复动作</button></div><div class="business-grid"><div class="business-field"><span class="business-label">恢复方式</span><strong id="taskRecovery"></strong></div><div class="business-field"><span class="business-label">键盘路径</span><strong id="taskKeyboard"></strong></div></div><section class="business-system" id="systemReadiness" hidden><div><strong>职责边界</strong><ul id="systemResponsibilities"></ul><strong>跨模块时间线</strong><div class="business-timeline" id="systemTimeline"></div></div><div class="business-notice" id="systemCompensation"></div></section><div class="business-notice" id="readinessResult" role="status" aria-live="polite"></div></section><div class="stage-wrap"><div class="stage" id="stage"></div></div><div class="prototype-state" id="prototypeState" data-state="initial" aria-live="polite">初始状态</div></section><div class="notes" id="notes"></div></div></main></div></div><div class="toast" id="toast" role="status" aria-live="polite"></div><script>${safeRendererSource}\n${runtime}</script></body></html>`;
}

export function buildIndexHtml(categories) {
  const cards = categories.map((category) => `<a class="card" href="${encodeURI(category.file)}"><span>${category.number}</span><h2>${escapeHtml(category.name)}</h2><p>${escapeHtml(category.en)}</p><b>${category.count} 个独立交互原型</b></a>`).join("");
  return `<!doctype html><html lang="zh-CN"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="icon" href="data:,"><title>复杂 UI 组件交互原型手册总索引</title><style>body{margin:0;padding:40px;background:#edf1f5;color:#202936;font:14px/1.6 "Microsoft YaHei UI",sans-serif}main{max-width:1180px;margin:auto}h1{font-size:34px}.grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px}.card{display:block;min-height:180px;padding:22px;border:1px solid #bcc7d1;border-top:5px solid #e4a91a;background:#fff;color:inherit;text-decoration:none}.card:hover{transform:translateY(-2px);box-shadow:0 12px 28px #1d29351c}.card span{font:12px Consolas;color:#8b6200}.card h2{margin:12px 0 4px}.card p{color:#667487}.card b{display:block;margin-top:24px}@media(max-width:800px){body{padding:20px}.grid{grid-template-columns:1fr}}</style></head><body><main><h1>复杂 UI 组件交互原型手册</h1><p>13 个类别 · 309 个逐项手写的独立交互原型</p><div class="grid">${cards}</div></main></body></html>`;
}
