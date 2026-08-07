import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.dirname(fileURLToPath(import.meta.url));
const sourceName = process.argv[2];
const outputName = process.argv[3];

if (!sourceName || !outputName) {
  throw new Error("Usage: node build-model-ui-handbook.mjs <source.md> <output.html>");
}

const sourcePath = path.resolve(root, sourceName);
const outputPath = path.resolve(root, outputName);
const markdown = fs.readFileSync(sourcePath, "utf8").replace(/^\uFEFF/, "");

const escapeHtml = (value) => value
  .replaceAll("&", "&amp;")
  .replaceAll("<", "&lt;")
  .replaceAll(">", "&gt;")
  .replaceAll('"', "&quot;");

const escapeAttr = (value) => escapeHtml(value).replaceAll("'", "&#39;");

function slugify(value, index) {
  const ascii = value
    .toLowerCase()
    .replace(/`([^`]+)`/g, "$1")
    .replace(/[^a-z0-9\u4e00-\u9fff]+/g, "-")
    .replace(/^-+|-+$/g, "");
  return `${ascii || "section"}-${index}`;
}

function inline(text) {
  let value = escapeHtml(text);
  value = value.replace(/`([^`]+)`/g, "<code>$1</code>");
  value = value.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
  value = value.replace(/\*([^*]+)\*/g, "<em>$1</em>");
  value = value.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
  return value;
}

function parseMarkdown(source) {
  const lines = source.replace(/\r\n/g, "\n").split("\n");
  const headings = [];
  const html = [];
  let paragraph = [];
  let listType = null;
  let listItems = [];
  let quote = [];
  let code = null;
  let table = [];
  let headingIndex = 0;

  function flushParagraph() {
    if (!paragraph.length) return;
    html.push(`<p>${inline(paragraph.join(" "))}</p>`);
    paragraph = [];
  }

  function flushList() {
    if (!listItems.length) return;
    html.push(`<${listType}>${listItems.map((item) => `<li>${inline(item)}</li>`).join("")}</${listType}>`);
    listItems = [];
    listType = null;
  }

  function flushQuote() {
    if (!quote.length) return;
    html.push(`<blockquote>${quote.map((item) => `<p>${inline(item)}</p>`).join("")}</blockquote>`);
    quote = [];
  }

  function splitTableRow(line) {
    return line.trim().replace(/^\||\|$/g, "").split("|").map((cell) => cell.trim());
  }

  function flushTable() {
    if (!table.length) return;
    const rows = table.map(splitTableRow);
    const header = rows[0] || [];
    const body = rows.slice(2);
    html.push(`<div class="table-scroll"><table><thead><tr>${header.map((cell) => `<th>${inline(cell)}</th>`).join("")}</tr></thead><tbody>${body.map((row) => `<tr>${row.map((cell) => `<td>${inline(cell)}</td>`).join("")}</tr>`).join("")}</tbody></table></div>`);
    table = [];
  }

  function flushAll() {
    flushParagraph();
    flushList();
    flushQuote();
    flushTable();
  }

  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];

    if (code) {
      if (/^```/.test(line)) {
        html.push(`<pre data-language="${escapeAttr(code.language)}"><code>${escapeHtml(code.lines.join("\n"))}</code></pre>`);
        code = null;
      } else {
        code.lines.push(line);
      }
      continue;
    }

    const fence = line.match(/^```\s*(.*)$/);
    if (fence) {
      flushAll();
      code = { language: fence[1].trim() || "text", lines: [] };
      continue;
    }

    if (/^\|.*\|\s*$/.test(line)) {
      flushParagraph();
      flushList();
      flushQuote();
      table.push(line);
      continue;
    }
    flushTable();

    const heading = line.match(/^(#{1,3})\s+(.+)$/);
    if (heading) {
      flushAll();
      const level = heading[1].length;
      const text = heading[2].trim();
      const id = slugify(text, headingIndex += 1);
      headings.push({ level, text, id });
      const className = level === 2 ? "part-title" : level === 3 ? "chapter-title" : "document-title";
      html.push(`<h${level} id="${id}" class="${className}">${inline(text)}<a class="heading-anchor" href="#${id}" aria-label="链接到本节">#</a></h${level}>`);
      continue;
    }

    if (/^---\s*$/.test(line)) {
      flushAll();
      html.push("<hr>");
      continue;
    }

    const quoteMatch = line.match(/^>\s?(.*)$/);
    if (quoteMatch) {
      flushParagraph();
      flushList();
      quote.push(quoteMatch[1]);
      continue;
    }
    flushQuote();

    const unordered = line.match(/^[-*]\s+(.+)$/);
    const ordered = line.match(/^\d+\.\s+(.+)$/);
    if (unordered || ordered) {
      flushParagraph();
      const nextType = ordered ? "ol" : "ul";
      if (listType && listType !== nextType) flushList();
      listType = nextType;
      listItems.push((unordered || ordered)[1]);
      continue;
    }
    flushList();

    if (!line.trim()) {
      flushParagraph();
      continue;
    }

    paragraph.push(line.trim());
  }

  flushAll();
  if (code) html.push(`<pre data-language="${escapeAttr(code.language)}"><code>${escapeHtml(code.lines.join("\n"))}</code></pre>`);
  return { html: html.join("\n"), headings };
}

const parsed = parseMarkdown(markdown);
const parts = parsed.headings.filter((heading) => heading.level === 2);
const chapters = parsed.headings.filter((heading) => heading.level === 3 && /^\d+\./.test(heading.text));

const prototypeCatalog = [
  { id: "five-views", chapter: "开篇：", title: "原型 01 · 一张订单，五种任务视图", label: "改变任务，观察同一事实怎样重新组织", kind: "fiveViews" },
  { id: "mapping-function", chapter: "15.", title: "原型 02 · 映射函数实验室", label: "改变角色、状态与终端，观察 F(D,C) 的输出", kind: "mappingFunction" },
  { id: "read-write", chapter: "6.", title: "原型 03 · 读取有损，写入有意图", label: "对比 ViewModel 与 Command，理解为什么不能镜像写回", kind: "readWrite" },
  { id: "permission-intersection", chapter: "31.", title: "原型 04 · 动作可用性交集", label: "动作 = 状态允许 ∩ 角色允许 ∩ 数据范围 ∩ 风险约束", kind: "permission" },
  { id: "rule-conflict", chapter: "21.", title: "原型 05 · 规则冲突解释器", label: "调换规则优先级，观察结论与解释链怎样变化", kind: "rules" },
  { id: "dependency-graph", chapter: "22.", title: "原型 06 · 字段影响图", label: "点击字段，追踪它对页面、命令、报表与缓存的传播", kind: "dependency" },
  { id: "null-semantics", chapter: "23.", title: "原型 07 · 空值语义解码器", label: "同一个 null，在不同语义下必须生成不同界面", kind: "nulls" },
  { id: "navigation-projection", chapter: "34.", title: "原型 08 · 导航是任务投影", label: "切换任务与角色，观察入口、层级和当前位置如何变化", kind: "navigation" },
  { id: "schema-compiler", chapter: "40.", title: "原型 09 · Schema 编译流水线", label: "逐步执行编译阶段，观察元数据怎样变成可执行页面", kind: "compiler" },
  { id: "version-migration", chapter: "45.", title: "原型 10 · 版本迁移与回滚", label: "模拟破坏性变更，选择兼容、迁移、灰度与回滚策略", kind: "migration" },
  { id: "test-matrix", chapter: "49.", title: "原型 11 · 映射测试矩阵", label: "组合角色、状态、终端与数据条件，找出未覆盖的解释路径", kind: "testing" },
  { id: "ai-dynamic-ui", chapter: "84.", title: "原型 12 · AI 动态 UI 安全边界", label: "允许 AI 选择表达，不允许它改写真值、权限与命令", kind: "ai" }
];

function prototypeShell(item) {
  return `<section class="prototype" id="prototype-${item.id}" data-prototype="${item.kind}">
    <header class="prototype-head">
      <div><span class="prototype-kicker">INTERACTIVE MODEL</span><h4>${item.title}</h4><p>${item.label}</p></div>
      <button class="icon-button prototype-reset" type="button" title="重置原型" aria-label="重置原型"><span aria-hidden="true">↻</span></button>
    </header>
    <div class="prototype-body" data-prototype-stage></div>
    <footer class="prototype-foot"><strong data-prototype-insight>等待交互</strong><span data-prototype-state>初始状态</span></footer>
  </section>`;
}

let articleHtml = parsed.html;
for (const item of prototypeCatalog) {
  const target = parsed.headings.find((heading) => heading.level === 3 && heading.text.startsWith(item.chapter));
  if (!target) throw new Error(`Prototype target not found: ${item.chapter}`);
  const marker = `<h3 id="${target.id}"`;
  articleHtml = articleHtml.replace(marker, `${prototypeShell(item)}\n${marker}`);
}

const title = parsed.headings.find((heading) => heading.level === 1)?.text || "数据模型与界面模式映射大型手册";
const toc = parts.map((part, partIndex) => {
  const children = parsed.headings.filter((heading) => heading.level === 3 && parsed.headings.indexOf(heading) > parsed.headings.indexOf(part) && (!parts[partIndex + 1] || parsed.headings.indexOf(heading) < parsed.headings.indexOf(parts[partIndex + 1])));
  return `<section class="toc-part"><a class="toc-part-link" href="#${part.id}"><span>${String(partIndex + 1).padStart(2, "0")}</span>${inline(part.text.replace(/^第.+?篇[　\s]*/, ""))}</a><div class="toc-chapters">${children.map((heading) => `<a href="#${heading.id}" data-search-text="${escapeAttr(heading.text)}">${inline(heading.text)}</a>`).join("")}</div></section>`;
}).join("");

const css = String.raw`
:root{color-scheme:light;--ink:#202732;--muted:#667180;--paper:#fff;--canvas:#edf1f4;--nav:#1c2732;--nav-2:#24313e;--line:#c8d0d8;--line-strong:#9ba8b5;--accent:#e2aa26;--accent-2:#16796f;--blue:#346d9b;--red:#a94949;--code:#19232d;--shadow:0 18px 44px rgba(24,35,46,.12);--top:58px;--side:316px;--rail:54px;font-family:"Microsoft YaHei UI","Noto Sans SC",sans-serif;font-size:16px;line-height:1.78}*{box-sizing:border-box}html{scroll-behavior:smooth;scroll-padding-top:80px}body{margin:0;background:var(--canvas);color:var(--ink);letter-spacing:0}button,input,select,textarea{font:inherit;letter-spacing:0}button{cursor:pointer}a{color:inherit}.app{min-height:100vh}.topbar{position:fixed;z-index:50;inset:0 0 auto 0;height:var(--top);display:flex;align-items:center;gap:12px;padding:0 18px;color:#fff;background:#19232d;border-bottom:3px solid var(--accent)}.brand-mark{width:7px;height:28px;background:var(--accent)}.brand{font:700 15px/1.2 Bahnschrift,"Microsoft YaHei UI"}.brand small{display:block;margin-top:3px;color:#aab6c2;font-size:10px;font-weight:500}.top-actions{margin-left:auto;display:flex;align-items:center;gap:8px}.search-box{position:relative;width:min(360px,34vw)}.search-box input{width:100%;height:34px;padding:6px 72px 6px 34px;border:1px solid #485867;border-radius:4px;color:#fff;background:#111a23;outline:0}.search-box input:focus{border-color:var(--accent)}.search-box svg{position:absolute;left:10px;top:8px;width:17px;height:17px;color:#91a0af}.search-count{position:absolute;right:8px;top:7px;color:#8f9dac;font:11px/20px Consolas}.icon-button{display:inline-grid;place-items:center;width:34px;height:34px;border:1px solid var(--line-strong);border-radius:4px;color:var(--ink);background:#fff}.topbar .icon-button{border-color:#4c5a68;color:#fff;background:transparent}.icon-button:hover{border-color:var(--accent);color:#7c5700}.topbar .icon-button:hover{color:var(--accent)}.reading-meter{width:110px;height:4px;background:#41505e;overflow:hidden}.reading-meter i{display:block;width:0;height:100%;background:var(--accent);transition:width .12s linear}.shell{display:grid;grid-template-columns:var(--side) minmax(0,1fr) var(--rail);padding-top:var(--top);min-height:100vh}.sidebar{position:fixed;z-index:40;left:0;top:var(--top);bottom:0;width:var(--side);display:grid;grid-template-rows:auto minmax(0,1fr) auto;color:#c9d2dc;background:var(--nav);border-right:1px solid #344251}.side-head{padding:16px 16px 12px;border-bottom:1px solid #374553}.side-overline{color:#7f90a2;font:700 10px/1.3 Consolas}.side-title{margin:5px 0 0;color:#fff;font-size:14px}.toc{overflow:auto;padding:8px}.toc-part{border-bottom:1px solid #303e4c}.toc-part-link{display:grid;grid-template-columns:31px 1fr;gap:3px;padding:10px 9px;text-decoration:none;color:#f1f4f7;font-size:12px;font-weight:700}.toc-part-link span{color:var(--accent);font:11px Consolas}.toc-chapters{display:grid;padding:0 0 8px 31px}.toc-chapters a{position:relative;padding:5px 9px;border-left:2px solid transparent;text-decoration:none;color:#9eacba;font-size:11px;line-height:1.45}.toc-chapters a:hover,.toc-chapters a.active{color:#fff;background:#2a3947;border-left-color:var(--accent)}.toc-chapters a.search-hidden,.toc-part.search-hidden{display:none}.side-foot{padding:11px 16px;border-top:1px solid #374553;color:#8796a5;font-size:10px}.main{grid-column:2;min-width:0;padding:44px 28px 100px}.article{width:min(980px,100%);margin:0 auto;background:var(--paper);border:1px solid var(--line);box-shadow:var(--shadow);padding:60px clamp(28px,6vw,78px) 90px}.document-title{margin:0 0 12px;font:800 clamp(30px,4vw,48px)/1.22 Bahnschrift,"Microsoft YaHei UI";color:#17212b}.part-title{margin:90px -20px 34px;padding:28px 20px 21px;border-top:5px solid var(--accent);border-bottom:1px solid var(--line);background:#f2f5f7;font:800 clamp(24px,3vw,34px)/1.32 Bahnschrift,"Microsoft YaHei UI"}.chapter-title{margin:58px 0 20px;padding-top:6px;font:800 22px/1.45 Bahnschrift,"Microsoft YaHei UI";color:#17212b}.heading-anchor{margin-left:8px;text-decoration:none;color:transparent;font-weight:400}.document-title:hover .heading-anchor,.part-title:hover .heading-anchor,.chapter-title:hover .heading-anchor{color:#a6b0ba}p{margin:13px 0}strong{color:#111a22}blockquote{margin:22px 0;padding:17px 20px;border-left:5px solid var(--accent);background:#fff9e8;color:#3f4852;font-size:16px}blockquote p{margin:0 0 6px}blockquote p:last-child{margin-bottom:0}hr{height:1px;border:0;background:var(--line);margin:38px 0}ul,ol{padding-left:24px}li{margin:6px 0}code{padding:1px 5px;border:1px solid #d8dee4;border-radius:3px;background:#f2f5f7;font:13px/1.5 Consolas,"Microsoft YaHei UI"}pre{position:relative;margin:20px 0;padding:20px;overflow:auto;border-left:5px solid var(--accent-2);background:var(--code);color:#d9e2eb;line-height:1.62}pre::before{content:attr(data-language);position:absolute;right:10px;top:7px;color:#6f8294;font:10px Consolas}pre code{padding:0;border:0;background:transparent;color:inherit;font-size:13px}.table-scroll{margin:22px 0;overflow:auto;border:1px solid var(--line)}table{width:100%;border-collapse:collapse;background:#fff;font-size:13px}th,td{padding:10px 12px;border-right:1px solid var(--line);border-bottom:1px solid var(--line);text-align:left;vertical-align:top}th:last-child,td:last-child{border-right:0}tr:last-child td{border-bottom:0}th{position:sticky;top:0;color:#fff;background:#283746;white-space:nowrap}tbody tr:nth-child(even){background:#f7f9fa}tbody tr:hover{background:#fff6d8}.utility-rail{position:fixed;z-index:30;right:0;top:var(--top);bottom:0;width:var(--rail);display:flex;flex-direction:column;align-items:center;gap:9px;padding-top:16px;background:#dfe5ea;border-left:1px solid var(--line)}.utility-rail .icon-button{background:#f8fafb}.rail-label{writing-mode:vertical-rl;color:#778492;font:10px Consolas;margin-top:4px}.back-top{margin-top:auto;margin-bottom:16px}.mobile-menu{display:none}.search-panel{position:fixed;z-index:60;right:65px;top:52px;width:min(560px,calc(100vw - 30px));max-height:62vh;display:none;overflow:auto;border:1px solid var(--line-strong);background:#fff;box-shadow:var(--shadow)}.search-panel.open{display:block}.search-result{display:block;padding:11px 14px;border-bottom:1px solid var(--line);text-decoration:none}.search-result:hover{background:#fff5d5}.search-result small{display:block;color:var(--muted)}.search-empty{padding:24px;color:var(--muted)}mark{padding:0 2px;background:#ffe18a}.prototype{margin:34px 0 42px;border:1px solid #aeb9c4;background:#fff;box-shadow:0 16px 34px rgba(25,38,51,.13)}.prototype-head{min-height:76px;display:flex;align-items:center;gap:16px;padding:13px 15px 13px 18px;border-bottom:1px solid var(--line);background:#f6f8fa}.prototype-head>div{min-width:0}.prototype-kicker{color:#8a6100;font:700 10px Consolas}.prototype h4{margin:2px 0 1px;font-size:15px}.prototype-head p{margin:0;color:var(--muted);font-size:11px}.prototype-reset{flex:0 0 auto;margin-left:auto}.prototype-body{min-height:340px;padding:18px;overflow:auto;background:#e8edf1;background-image:linear-gradient(#dce3e8 1px,transparent 1px),linear-gradient(90deg,#dce3e8 1px,transparent 1px);background-size:20px 20px}.prototype-foot{min-height:45px;display:flex;align-items:center;gap:12px;padding:8px 14px;border-top:1px solid var(--line);background:#f8fafb;font-size:11px}.prototype-foot strong{color:#165f58}.prototype-foot span{margin-left:auto;color:var(--muted);font-family:Consolas}.demo-toolbar{display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:12px}.demo-toolbar label{display:flex;align-items:center;gap:6px;color:#4d5966;font-size:11px}.demo-toolbar select,.demo-toolbar input[type="text"],.demo-toolbar input[type="number"]{height:33px;padding:5px 8px;border:1px solid #aeb9c5;background:#fff}.demo-button{min-height:33px;padding:5px 10px;border:1px solid #9facb8;background:#fff;color:#27333f}.demo-button:hover,.demo-button.active{border-color:#a97b09;background:var(--accent);color:#1d2731;font-weight:700}.demo-button.danger{border-color:#bc7777;color:#842c2c}.segmented{display:inline-flex;border:1px solid #aab6c1}.segmented .demo-button{border:0;border-right:1px solid #aab6c1}.segmented .demo-button:last-child{border-right:0}.demo-panel{border:1px solid #9eacb9;background:#fff}.demo-panel-head{display:flex;align-items:center;justify-content:space-between;gap:10px;padding:9px 12px;color:#fff;background:#293745;font-size:12px}.demo-panel-body{padding:14px}.demo-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}.demo-grid.three{grid-template-columns:repeat(3,minmax(0,1fr))}.metric{padding:11px;border-left:4px solid var(--accent);background:#fff}.metric small{display:block;color:var(--muted);font-size:10px}.metric strong{display:block;font:800 18px Bahnschrift}.badge{display:inline-block;padding:2px 7px;border:1px solid #b9a45b;background:#fff4c9;color:#725000;font-size:10px}.badge.green{border-color:#86b5a8;background:#e5f3ee;color:#14685f}.badge.red{border-color:#c99494;background:#f8e6e6;color:#8b3232}.formula-strip{display:flex;align-items:center;gap:8px;flex-wrap:wrap;padding:13px;border:1px solid #a9b6c2;background:#17222d;color:#e8eef4;font:13px Consolas}.formula-strip .token{padding:5px 7px;border:1px solid #455564;background:#23313e}.formula-strip .context{border-color:#a87e18;color:#ffdc7e}.order-table{width:100%;border-collapse:collapse}.order-table th{position:static}.order-card{display:grid;grid-template-columns:1fr auto;gap:8px;padding:13px;border:1px solid var(--line);background:#fff}.order-card p{grid-column:1/-1;margin:0;color:var(--muted);font-size:11px}.timeline{display:grid;gap:0}.timeline-item{position:relative;margin-left:8px;padding:0 0 17px 22px;border-left:2px solid #a6b2bd}.timeline-item::before{content:"";position:absolute;left:-7px;top:4px;width:11px;height:11px;background:var(--accent);border:2px solid #fff}.field{display:grid;gap:4px}.field label{color:var(--muted);font-size:10px}.field input,.field select,.field textarea{width:100%;padding:8px;border:1px solid #a9b6c2;background:#fff}.field input:disabled{background:#e9edf1;color:#7a8692}.command-box{padding:12px;border:1px dashed #7f8f9e;background:#f7f9fb;font:12px Consolas;white-space:pre-wrap}.set-diagram{display:grid;grid-template-columns:repeat(4,1fr);gap:7px}.set-box{min-height:105px;padding:9px;border:1px solid #a6b3bf;background:#fff}.set-box.active{border:3px solid var(--accent-2);background:#e9f5f1}.set-box h5{margin:0 0 6px;font-size:11px}.set-box span{display:block;color:var(--muted);font-size:10px}.rule-list{display:grid;gap:7px}.rule-row{display:grid;grid-template-columns:30px minmax(0,1fr) auto;align-items:center;gap:8px;padding:9px;border:1px solid #b2bdc8;background:#fff}.rule-order{display:grid;place-items:center;width:26px;height:26px;background:#293745;color:#fff;font:11px Consolas}.rule-row select{max-width:150px;padding:5px}.graph{position:relative;min-width:700px;height:310px;background:#f8fafb}.graph svg{position:absolute;inset:0;width:100%;height:100%;pointer-events:none}.graph line{stroke:#8b99a7;stroke-width:2}.graph line.active{stroke:var(--accent-2);stroke-width:4}.graph-node{position:absolute;width:130px;min-height:52px;padding:8px;border:1px solid #93a2b1;background:#fff;box-shadow:0 5px 13px rgba(24,35,46,.1);font-size:11px;text-align:left}.graph-node.active{border:3px solid var(--accent);background:#fff7d9;font-weight:700}.null-cards{display:grid;grid-template-columns:repeat(4,1fr);gap:9px}.null-card{padding:12px;border:1px solid #a9b6c2;background:#fff}.null-card.active{border-top:5px solid var(--accent)}.null-card h5{margin:0 0 5px}.null-card p{min-height:56px;margin:0;color:var(--muted);font-size:10px}.nav-demo{min-width:650px;display:grid;grid-template-columns:165px 1fr;min-height:290px;border:1px solid #8f9eac;background:#fff}.nav-demo aside{padding:10px;color:#d5dee7;background:#263442}.nav-demo aside button{width:100%;padding:8px;border:0;border-left:3px solid transparent;color:inherit;background:transparent;text-align:left;font-size:11px}.nav-demo aside button.active{border-left-color:var(--accent);background:#344657;color:#fff}.nav-content{padding:15px}.crumb{color:var(--muted);font-size:10px}.pipeline{min-width:700px;display:grid;grid-template-columns:repeat(6,1fr);gap:8px}.pipe-stage{position:relative;min-height:120px;padding:10px;border:1px solid #9eacb8;background:#fff;font-size:10px}.pipe-stage::after{content:"→";position:absolute;right:-13px;top:43px;z-index:2;font-size:20px}.pipe-stage:last-child::after{display:none}.pipe-stage.active{border:4px solid var(--accent-2);background:#e8f4f0}.version-track{display:grid;grid-template-columns:repeat(4,1fr);gap:8px}.version-node{min-height:110px;padding:10px;border:1px solid #a6b3bf;background:#fff}.version-node.active{border-top:5px solid var(--accent)}.test-matrix{border-collapse:collapse}.test-matrix th{position:static}.test-matrix td{text-align:center}.coverage-hit{background:#dcefe8;color:#12665d;font-weight:700}.coverage-gap{background:#f8dddd;color:#8c2e2e;font-weight:700}.ai-boundary{display:grid;grid-template-columns:1fr 1fr;gap:10px}.ai-zone{padding:14px;border:1px solid #a5b2bf;background:#fff}.ai-zone.safe{border-top:5px solid var(--accent-2)}.ai-zone.locked{border-top:5px solid var(--red)}.ai-option{display:flex;align-items:center;gap:7px;margin:7px 0;font-size:11px}.explanation{margin-top:10px;padding:10px;border-left:4px solid var(--blue);background:#e8f0f7;color:#314b61;font-size:11px}.toast{position:fixed;z-index:100;right:70px;bottom:20px;max-width:360px;padding:11px 14px;color:#fff;background:#1e2a35;border-left:5px solid var(--accent);box-shadow:var(--shadow);transform:translateY(18px);opacity:0;pointer-events:none;transition:.2s}.toast.show{transform:translateY(0);opacity:1}.focus-mode .sidebar,.focus-mode .utility-rail{display:none}.focus-mode .shell{grid-template-columns:1fr}.focus-mode .main{grid-column:1;padding-inline:22px}.focus-mode .article{width:min(900px,100%)}.focus-mode .topbar .search-box{display:none}@media(max-width:1050px){:root{--side:280px}.shell{grid-template-columns:var(--side) minmax(0,1fr)}.utility-rail{display:none}.main{padding-right:20px}.demo-grid.three{grid-template-columns:1fr 1fr}.null-cards{grid-template-columns:1fr 1fr}}@media(max-width:760px){:root{--top:54px}.topbar{height:var(--top);padding:0 10px}.brand small,.reading-meter{display:none}.brand{max-width:42vw;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.mobile-menu{display:inline-grid}.search-box{width:min(43vw,250px)}.search-box input{padding-right:8px}.search-count{display:none}.shell{display:block;padding-top:var(--top)}.sidebar{top:var(--top);width:min(88vw,320px);transform:translateX(-102%);transition:transform .22s;box-shadow:none}.sidebar.open{transform:translateX(0);box-shadow:18px 0 40px rgba(0,0,0,.3)}.main{padding:18px 8px 70px}.article{padding:32px 18px 60px}.part-title{margin-left:-9px;margin-right:-9px;padding-left:12px;padding-right:12px}.chapter-title{font-size:20px}.prototype{margin-left:-10px;margin-right:-10px}.prototype-head{align-items:flex-start}.prototype-body{padding:10px;min-height:320px}.prototype-foot{align-items:flex-start;flex-direction:column}.prototype-foot span{margin-left:0}.demo-grid,.demo-grid.three,.set-diagram,.version-track,.ai-boundary{grid-template-columns:1fr}.null-cards{grid-template-columns:1fr 1fr}.search-panel{right:8px;top:50px}.toast{right:10px;left:10px}.focus-mode .main{padding-inline:8px}}@media print{.topbar,.sidebar,.utility-rail,.prototype,.search-panel,.toast{display:none!important}.shell{display:block;padding:0}.main{padding:0}.article{width:auto;border:0;box-shadow:none;padding:0}.part-title{break-before:page;background:#fff}.chapter-title{break-after:avoid}pre,.table-scroll{break-inside:avoid}}@media(prefers-reduced-motion:reduce){*{scroll-behavior:auto!important;transition:none!important}}
`;

function browserRuntime() {
(() => {
  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];
  const escapeText = (value) => String(value).replace(/[&<>"']/g, (char) => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[char]));
  const order = { id: "SO-2026-0714", customer: "远航科技", amount: 128800, status: "待审批", owner: "林经理", items: 4, risk: "中", paid: true };
  let toastTimer;
  function toast(message) { const node = $("#toast"); node.textContent = message; node.classList.add("show"); clearTimeout(toastTimer); toastTimer = setTimeout(() => node.classList.remove("show"), 1800); }
  function setFoot(root, insight, state) { $("[data-prototype-insight]", root).textContent = insight; $("[data-prototype-state]", root).textContent = state; }
  function money(value) { return `¥${Number(value).toLocaleString("zh-CN", { minimumFractionDigits: 2 })}`; }

  const renderers = {
    fiveViews(root) {
      const stage = $("[data-prototype-stage]", root);
      const views = {
        list: { label: "列表", task: "找", html: `<div class="demo-panel"><div class="demo-panel-head"><span>订单列表</span><span>共 1 条</span></div><table class="order-table"><tr><th>订单号</th><th>客户</th><th>金额</th><th>状态</th></tr><tr><td>${order.id}</td><td>${order.customer}</td><td>${money(order.amount)}</td><td><span class="badge">${order.status}</span></td></tr></table></div>` },
        detail: { label: "详情", task: "看懂", html: `<div class="demo-grid"><div class="demo-panel"><div class="demo-panel-head"><span>${order.id}</span><span class="badge">${order.status}</span></div><div class="demo-panel-body"><h5>客户</h5><strong>${order.customer}</strong><p>负责人：${order.owner}</p><p>商品明细：${order.items} 项</p></div></div><div class="timeline"><div class="timeline-item"><b>订单创建</b><small>事实形成</small></div><div class="timeline-item"><b>支付完成</b><small>金额已确认</small></div><div class="timeline-item"><b>等待审批</b><small>当前任务</small></div></div></div>` },
        edit: { label: "编辑", task: "修改", html: `<div class="demo-panel"><div class="demo-panel-head"><span>编辑订单草稿</span><span>W ≠ D</span></div><div class="demo-panel-body demo-grid"><div class="field"><label>客户</label><input value="${order.customer}"></div><div class="field"><label>业务状态</label><input value="${order.status}" disabled></div><div class="field"><label>金额</label><input type="number" value="${order.amount}"></div><div class="field"><label>备注</label><input value="等待业务确认"></div></div></div>` },
        approve: { label: "审批", task: "决策", html: `<div class="demo-grid"><div class="metric"><small>申请金额</small><strong>${money(order.amount)}</strong></div><div class="metric"><small>风险等级</small><strong>${order.risk}</strong></div></div><div class="explanation">证据：客户 ${order.customer} · 已支付 · ${order.items} 项明细。审批动作受当前状态、角色权限和风险阈值共同约束。</div><div class="demo-toolbar" style="margin-top:12px"><button class="demo-button active" data-action="approve">通过</button><button class="demo-button danger" data-action="reject">驳回</button></div>` },
        report: { label: "报表", task: "分析", html: `<div class="demo-grid three"><div class="metric"><small>订单数</small><strong>1</strong></div><div class="metric"><small>销售额</small><strong>${money(order.amount)}</strong></div><div class="metric"><small>待审批占比</small><strong>100%</strong></div></div><div style="height:150px;display:flex;align-items:flex-end;gap:18px;padding:20px 35px 0;background:#fff;border:1px solid #a7b3bf"><div style="height:55%;flex:1;background:#346d9b"></div><div style="height:82%;flex:1;background:#16796f"></div><div style="height:100%;flex:1;background:#e2aa26"></div><div style="height:42%;flex:1;background:#a94949"></div></div>` }
      };
      stage.innerHTML = `<div class="demo-toolbar"><div class="segmented">${Object.entries(views).map(([key, view]) => `<button class="demo-button" data-view="${key}">${view.label}</button>`).join("")}</div></div><div data-view-stage></div>`;
      const show = (key) => { const view = views[key]; $$('[data-view]', stage).forEach((button) => button.classList.toggle("active", button.dataset.view === key)); $("[data-view-stage]", stage).innerHTML = view.html; setFoot(root, `同一事实被组织成“${view.task}”的任务界面`, `${view.label}UI = f(${order.id})`); };
      stage.addEventListener("click", (event) => { const button = event.target.closest("[data-view]"); if (button) show(button.dataset.view); const action = event.target.closest("[data-action]")?.dataset.action; if (action) toast(action === "approve" ? "已形成 ApproveOrder 命令" : "已形成 RejectOrder 命令"); });
      show("list");
    },
    mappingFunction(root) {
      const stage = $("[data-prototype-stage]", root);
      stage.innerHTML = `<div class="demo-toolbar"><label>角色<select data-input="role"><option>客户</option><option>客服</option><option>仓库</option><option>财务</option><option>管理者</option></select></label><label>状态<select data-input="status"><option>待审批</option><option>待发货</option><option>已完成</option><option>已取消</option></select></label><label>终端<select data-input="device"><option>桌面端</option><option>移动端</option></select></label></div><div class="formula-strip"><span>U = F(</span><span class="token">D: ${order.id}</span><span>,</span><span class="token context" data-context></span><span>)</span><span>→</span><span class="token" data-output></span></div><div class="demo-panel" style="margin-top:12px"><div class="demo-panel-head"><span data-title></span><span data-density></span></div><div class="demo-panel-body" data-fields></div></div>`;
      const map = { 客户:["商品摘要","金额","物流进度","退款入口"], 客服:["客户资料","订单时间线","异常记录","补救动作"], 仓库:["SKU","数量","库位","发货动作"], 财务:["实付金额","支付渠道","退款","对账状态"], 管理者:["销售额","转化率","异常率","趋势"] };
      const update = () => { const role = $('[data-input="role"]',stage).value; const status = $('[data-input="status"]',stage).value; const device = $('[data-input="device"]',stage).value; const fields = map[role]; $('[data-context]',stage).textContent = `C: ${role} · ${status} · ${device}`; $('[data-output]',stage).textContent = `${role}${device === "移动端" ? "任务流" : "工作台"}`; $('[data-title]',stage).textContent = `${role} · ${status}`; $('[data-density]',stage).textContent = device === "移动端" ? "单列 / 低密度" : "双列 / 高密度"; $('[data-fields]',stage).innerHTML = `<div class="demo-grid ${device === "桌面端" ? "" : "mobile-output"}">${fields.map((field,index) => `<div class="metric"><small>投影字段 ${index+1}</small><strong>${field}</strong></div>`).join("")}</div>`; setFoot(root,"数据不变，任务上下文改变了选择、布局与动作",`F(D, ${role}, ${status}, ${device})`); };
      stage.addEventListener("change", update); update();
    },
    readWrite(root) {
      const stage = $("[data-prototype-stage]", root);
      stage.innerHTML = `<div class="demo-grid"><div class="demo-panel"><div class="demo-panel-head"><span>读取模型 · ViewModel</span><span>允许有损</span></div><div class="demo-panel-body"><div class="field"><label>客户名称（由 customerId 查找）</label><input value="${order.customer}"></div><div class="field"><label>格式化金额（由 amount 派生）</label><input value="${money(order.amount)}"></div><div class="field"><label>状态说明（由 status 解释）</label><input value="正在等待有权限的负责人审批"></div></div></div><div class="demo-panel"><div class="demo-panel-head"><span>写入模型 · Command</span><span>表达意图</span></div><div class="demo-panel-body"><div class="field"><label>新金额</label><input data-amount type="number" value="${order.amount}"></div><div class="field"><label>变更原因</label><input data-reason value="客户补充采购项"></div><button class="demo-button active" data-submit>生成命令</button><div class="command-box" data-command style="margin-top:10px">尚未生成</div></div></div></div>`;
      $('[data-submit]',stage).addEventListener("click",()=>{const amount=$('[data-amount]',stage).value;const reason=$('[data-reason]',stage).value.trim();if(!reason){toast("写入必须说明业务意图");setFoot(root,"读取值无法直接安全地镜像写回","缺少变更原因");return}$('[data-command]',stage).textContent=`ChangeOrderAmount {\n  orderId: "${order.id}",\n  expectedVersion: 7,\n  newAmount: ${amount},\n  reason: "${reason}"\n}`;setFoot(root,"写入携带身份、版本、目标值与原因","Command 已形成");});
      setFoot(root,"左侧为解释后的读取投影，右侧为受约束的业务意图","ViewModel ≠ Command");
    },
    permission(root) {
      const stage=$("[data-prototype-stage]",root);const groups={"状态允许":["查看","编辑","通过","驳回"],"角色允许":["查看","通过","驳回"],"数据范围":["查看","通过"],"风险约束":["查看","通过"]};
      stage.innerHTML=`<div class="demo-toolbar"><label>订单状态<select data-status><option>待审批</option><option>已完成</option><option>已取消</option></select></label><label>角色<select data-role><option>审批人</option><option>客服</option><option>访客</option></select></label><label>金额阈值<input data-limit type="number" value="200000"></label></div><div class="set-diagram" data-sets></div><div class="explanation" data-result></div>`;
      const update=()=>{const status=$('[data-status]',stage).value,role=$('[data-role]',stage).value,limit=Number($('[data-limit]',stage).value);groups["状态允许"]=status==="待审批"?["查看","编辑","通过","驳回"]:["查看"];groups["角色允许"]=role==="审批人"?["查看","通过","驳回"]:role==="客服"?["查看","编辑"]:["查看"];groups["风险约束"]=order.amount<=limit?["查看","通过"]:["查看"];const result=Object.values(groups).reduce((a,b)=>a.filter(x=>b.includes(x)));$('[data-sets]',stage).innerHTML=Object.entries(groups).map(([name,items])=>`<div class="set-box ${items.includes("通过")?"active":""}"><h5>${name}</h5>${items.map(x=>`<span>${x}</span>`).join("")}</div>`).join("");$('[data-result]',stage).innerHTML=`最终可用动作：<strong>${result.join("、")||"无"}</strong>。任何一个集合拒绝，动作就不能出现。`;setFoot(root,"UI 动作不是按钮配置，而是多项业务约束的交集",`Actions = { ${result.join(", ")} }`)};stage.addEventListener("change",update);stage.addEventListener("input",update);update();
    },
    rules(root) {
      const stage=$("[data-prototype-stage]",root);const rules=[{name:"字段级显式配置",result:"TextArea",weight:100},{name:"页面角色规则",result:"只读文本",weight:80},{name:"语义类型默认",result:"MoneyInput",weight:60},{name:"数据类型兜底",result:"NumberInput",weight:20}];
      stage.innerHTML=`<div class="demo-grid"><div><div class="rule-list" data-rules></div></div><div class="demo-panel"><div class="demo-panel-head"><span>解析结果</span><span data-winner></span></div><div class="demo-panel-body"><div class="metric"><small>最终组件</small><strong data-component></strong></div><div class="explanation" data-chain></div></div></div></div>`;
      const update=()=>{rules.sort((a,b)=>b.weight-a.weight);$('[data-rules]',stage).innerHTML=rules.map((rule,index)=>`<div class="rule-row"><span class="rule-order">${index+1}</span><div><b>${rule.name}</b><small style="display:block;color:#667180">命中 → ${rule.result}</small></div><select data-rule="${escapeText(rule.name)}">${[100,80,60,20].map(v=>`<option ${v===rule.weight?"selected":""}>${v}</option>`).join("")}</select></div>`).join("");const winner=rules[0];$('[data-winner]',stage).textContent=`权重 ${winner.weight}`;$('[data-component]',stage).textContent=winner.result;$('[data-chain]',stage).innerHTML=`解释链：${rules.map((r,i)=>`${i?" → ":""}${r.name}(${r.weight})`).join("")}。<br>首个最高优先级规则胜出，但冲突仍被保留用于诊断。`;setFoot(root,"优先级解决冲突，但可解释性负责让冲突可诊断",`${winner.name} → ${winner.result}`)};stage.addEventListener("change",e=>{if(e.target.dataset.rule){const rule=rules.find(r=>r.name===e.target.dataset.rule);rule.weight=Number(e.target.value);update()}});update();
    },
    dependency(root) {
      const stage=$("[data-prototype-stage]",root);const nodes=[{id:"amount",label:"amount 金额",x:20,y:125,targets:["formatted","approval","report","cache"]},{id:"status",label:"status 状态",x:20,y:35,targets:["badge","actions","nav"]},{id:"formatted",label:"格式化金额",x:230,y:175},{id:"approval",label:"审批阈值",x:230,y:105},{id:"report",label:"销售额指标",x:450,y:175},{id:"cache",label:"查询计划缓存",x:450,y:245},{id:"badge",label:"状态 Badge",x:230,y:5},{id:"actions",label:"可用动作",x:230,y:65},{id:"nav",label:"任务入口",x:450,y:35}];const edges=[["status","badge"],["status","actions"],["status","nav"],["amount","formatted"],["amount","approval"],["amount","report"],["amount","cache"],["approval","actions"]];
      stage.innerHTML=`<div class="graph"><svg viewBox="0 0 700 310" preserveAspectRatio="none">${edges.map(([a,b])=>{const s=nodes.find(n=>n.id===a),t=nodes.find(n=>n.id===b);return`<line data-from="${a}" data-to="${b}" x1="${s.x+65}" y1="${s.y+26}" x2="${t.x+65}" y2="${t.y+26}"/>`}).join("")}</svg>${nodes.map(n=>`<button class="graph-node" data-node="${n.id}" style="left:${n.x}px;top:${n.y}px">${n.label}</button>`).join("")}</div>`;
      stage.addEventListener("click",e=>{const button=e.target.closest("[data-node]");if(!button)return;const id=button.dataset.node;const start=nodes.find(n=>n.id===id);const affected=new Set([id]);let changed=true;while(changed){changed=false;edges.forEach(([a,b])=>{if(affected.has(a)&&!affected.has(b)){affected.add(b);changed=true}})};$$('[data-node]',stage).forEach(n=>n.classList.toggle("active",affected.has(n.dataset.node)));$$('line',stage).forEach(l=>l.classList.toggle("active",affected.has(l.dataset.from)&&affected.has(l.dataset.to)));setFoot(root,`${start.label} 变化会影响 ${affected.size-1} 个下游节点`,`影响集 = { ${[...affected].join(", ")} }`)});$('[data-node="amount"]',stage).click();
    },
    nulls(root) {
      const stage=$("[data-prototype-stage]",root);const meanings=[{id:"unknown",title:"未知",copy:"事实尚未获得",ui:"显示“待补充”，允许稍后填写"},{id:"not-applicable",title:"不适用",copy:"该字段对当前对象无意义",ui:"隐藏输入，保留“不适用”说明"},{id:"not-authorized",title:"无权查看",copy:"事实存在，但当前主体不可见",ui:"显示脱敏或权限占位，不暴露存在性"},{id:"not-yet",title:"尚未发生",copy:"流程还没到该阶段",ui:"显示时间线未来节点，不允许输入"}];
      stage.innerHTML=`<div class="demo-toolbar"><span class="badge">数据库值：null</span></div><div class="null-cards">${meanings.map(m=>`<button class="null-card" data-null="${m.id}"><h5>${m.title}</h5><p>${m.copy}</p></button>`).join("")}</div><div class="demo-panel" style="margin-top:12px"><div class="demo-panel-head"><span>界面解释</span><span data-null-title></span></div><div class="demo-panel-body" data-null-ui></div></div>`;const show=id=>{const m=meanings.find(x=>x.id===id);$$('[data-null]',stage).forEach(x=>x.classList.toggle("active",x.dataset.null===id));$('[data-null-title]',stage).textContent=m.title;$('[data-null-ui]',stage).innerHTML=`<div class="explanation">${m.ui}</div>`;setFoot(root,"存储值相同，语义不同，界面行为就不能相同",`null ≠ ${m.title}`)};stage.addEventListener("click",e=>{const b=e.target.closest("[data-null]");if(b)show(b.dataset.null)});show("unknown");
    },
    navigation(root) {
      const stage=$("[data-prototype-stage]",root);stage.innerHTML=`<div class="demo-toolbar"><label>任务<select data-task><option>处理异常订单</option><option>完成发货</option><option>查看经营趋势</option></select></label><label>角色<select data-nav-role><option>客服</option><option>仓库</option><option>管理者</option></select></label></div><div class="nav-demo"><aside data-nav-items></aside><div class="nav-content"><div class="crumb" data-crumb></div><h4 data-nav-title></h4><p data-nav-copy></p><div class="demo-grid" data-nav-widgets></div></div></div>`;const configs={"处理异常订单":{items:["待办","异常订单","客户档案","补救记录"],title:"异常订单处理",copy:"导航突出任务队列和上下文恢复。",widgets:["异常原因","客户影响","可用补救动作"]},"完成发货":{items:["拣货任务","待发货","库存位置","物流交接"],title:"发货工作台",copy:"导航压缩探索层级，突出连续操作。",widgets:["SKU 与数量","库位","交接状态"]},"查看经营趋势":{items:["经营总览","销售分析","异常率","指标口径"],title:"经营分析",copy:"导航围绕指标维度与下钻路径组织。",widgets:["销售额","转化率","异常率"]}};const update=()=>{const task=$('[data-task]',stage).value,role=$('[data-nav-role]',stage).value,c=configs[task];$('[data-nav-items]',stage).innerHTML=c.items.map((x,i)=>`<button class="${i===0?"active":""}">${x}</button>`).join("");$('[data-crumb]',stage).textContent=`${role}工作区 / ${c.items[0]} / ${c.title}`;$('[data-nav-title]',stage).textContent=c.title;$('[data-nav-copy]',stage).textContent=c.copy;$('[data-nav-widgets]',stage).innerHTML=c.widgets.map(x=>`<div class="metric"><small>任务信息</small><strong>${x}</strong></div>`).join("");setFoot(root,"导航把信息空间投影成当前角色最短的任务路径",`${role} → ${task}`)};stage.addEventListener("change",update);update();
    },
    compiler(root) {
      const stage=$("[data-prototype-stage]",root);const steps=["读取 Schema","规范化","合并权限","生成查询计划","解析组件","绑定命令"];let current=0;stage.innerHTML=`<div class="demo-toolbar"><button class="demo-button active" data-next>执行下一阶段</button><button class="demo-button" data-all>全部编译</button></div><div class="pipeline">${steps.map((x,i)=>`<div class="pipe-stage" data-step="${i}"><b>${i+1}. ${x}</b><p data-step-copy>等待执行</p></div>`).join("")}</div><div class="explanation" data-compile-result>输入：Order Data Schema + View Schema + Permission Schema + Action Schema</div>`;const copies=["解析订单、字段、关系与语义类型","补齐默认值并验证引用","裁剪记录、字段和动作范围","选择字段、关联、聚合与分页","把语义映射为 Table / Badge / Money","连接 ApproveOrder 与审计上下文"];const update=()=>{$$('[data-step]',stage).forEach((node,i)=>{node.classList.toggle("active",i<current);$('p',node).textContent=i<current?copies[i]:"等待执行"});$('[data-compile-result]',stage).textContent=current===steps.length?"输出：可执行审批页计划。运行时仍要重新验证数据范围与动作权限。":`当前完成 ${current} / ${steps.length} 阶段`;setFoot(root,current===steps.length?"Schema 已成为受约束、可解释的执行计划":"编译将不同元数据分阶段消歧",`pipeline ${current}/${steps.length}`)};$('[data-next]',stage).addEventListener("click",()=>{current=Math.min(steps.length,current+1);update()});$('[data-all]',stage).addEventListener("click",()=>{current=steps.length;update()});update();
    },
    migration(root) {
      const stage=$("[data-prototype-stage]",root);stage.innerHTML=`<div class="demo-toolbar"><label>变更类型<select data-change><option value="rename">字段重命名：amount → totalAmount</option><option value="remove">删除字段：legacyCode</option><option value="semantic">语义变化：status 枚举重构</option></select></label><button class="demo-button active" data-evaluate>评估变更</button></div><div class="version-track" data-track></div><div class="explanation" data-plan></div>`;const plans={rename:{risk:"中",nodes:["v7 旧 Schema","兼容别名层","v8 双读验证","v8 正式切换"],plan:"先保留 amount 别名，发布双读版本；监控旧客户端后再移除。"},remove:{risk:"高",nodes:["依赖扫描","弃用公告","灰度拒绝写入","延迟删除"],plan:"删除是单向门。先证明没有读取、写入、报表和导出依赖，再进入延迟删除。"},semantic:{risk:"高",nodes:["冻结旧口径","定义映射表","回放历史数据","双口径对账"],plan:"枚举名称相似不代表语义相同。需要显式迁移函数和可回滚快照。"}};const update=()=>{const p=plans[$('[data-change]',stage).value];$('[data-track]',stage).innerHTML=p.nodes.map((x,i)=>`<div class="version-node ${i===0?"active":""}"><span class="badge ${p.risk==="高"?"red":""}">风险 ${p.risk}</span><h5>${i+1}. ${x}</h5></div>`).join("");$('[data-plan]',stage).innerHTML=`<strong>策略：</strong>${p.plan}<br><strong>回滚点：</strong>保持旧 Schema 和转换器，直到双读结果一致。`;setFoot(root,"版本治理的目标不是让新版本能跑，而是让旧事实和旧客户端仍可解释",`risk=${p.risk}`)};$('[data-evaluate]',stage).addEventListener("click",update);stage.addEventListener("change",update);update();
    },
    testing(root) {
      const stage=$("[data-prototype-stage]",root);const roles=["客户","审批人","访客"],statuses=["草稿","待审批","已完成"],devices=["桌面","移动"];let covered=new Set(["客户|草稿|桌面","客户|待审批|移动","审批人|待审批|桌面","访客|已完成|移动"]);stage.innerHTML=`<div class="demo-toolbar"><button class="demo-button active" data-add-test>补齐一个缺口</button><span class="badge" data-coverage></span></div><div class="table-scroll"><table class="test-matrix"><thead><tr><th>角色 / 状态</th>${statuses.map(s=>`<th>${s} · 桌面</th><th>${s} · 移动</th>`).join("")}</tr></thead><tbody data-test-body></tbody></table></div>`;const all=roles.flatMap(r=>statuses.flatMap(s=>devices.map(d=>`${r}|${s}|${d}`)));const update=()=>{$('[data-test-body]',stage).innerHTML=roles.map(r=>`<tr><th>${r}</th>${statuses.flatMap(s=>devices.map(d=>{const k=`${r}|${s}|${d}`,hit=covered.has(k);return`<td class="${hit?"coverage-hit":"coverage-gap"}" data-case="${k}">${hit?"已测":"缺口"}</td>`})).join("")}</tr>`).join("");const pct=Math.round(covered.size/all.length*100);$('[data-coverage]',stage).textContent=`组合覆盖 ${covered.size}/${all.length} · ${pct}%`;setFoot(root,"Schema 可解析只是起点，真正的测试对象是上下文组合后的解释结果",`coverage=${pct}%`)};$('[data-add-test]',stage).addEventListener("click",()=>{const gap=all.find(x=>!covered.has(x));if(gap){covered.add(gap);toast(`已覆盖 ${gap}`);update()}});update();
    },
    ai(root) {
      const stage=$("[data-prototype-stage]",root);stage.innerHTML=`<div class="demo-toolbar"><label>任务<select data-ai-task><option>快速找异常订单</option><option>解释单笔订单</option><option>分析趋势</option></select></label><button class="demo-button active" data-generate>让 AI 生成视图计划</button></div><div class="ai-boundary"><div class="ai-zone safe"><h5>AI 可决定 · 表达层</h5><label class="ai-option"><input type="checkbox" checked> 字段排序</label><label class="ai-option"><input type="checkbox" checked> 表格 / 卡片 / 图表</label><label class="ai-option"><input type="checkbox" checked> 信息密度与摘要</label><label class="ai-option"><input type="checkbox" checked> 辅助解释文本</label></div><div class="ai-zone locked"><h5>AI 不可改 · 真值与约束</h5><label class="ai-option"><input type="checkbox" checked disabled> 数据范围权限</label><label class="ai-option"><input type="checkbox" checked disabled> 字段语义与指标口径</label><label class="ai-option"><input type="checkbox" checked disabled> 状态机合法转移</label><label class="ai-option"><input type="checkbox" checked disabled> 命令校验与审计</label></div></div><div class="explanation" data-ai-result>尚未生成。</div>`;const plans={"快速找异常订单":"使用高密度表格；置顶异常原因、金额和负责人；隐藏非任务字段；动作仍由权限引擎返回。","解释单笔订单":"使用摘要卡 + 时间线；显示事实来源和更新时间；不推测缺失事实。","分析趋势":"使用聚合图表 + 指标口径；允许下钻到授权范围内的事实记录。"};$('[data-generate]',stage).addEventListener("click",()=>{const task=$('[data-ai-task]',stage).value;$('[data-ai-result]',stage).innerHTML=`<strong>生成计划：</strong>${plans[task]}<br><strong>约束证明：</strong>AI 输出只包含 ViewPlan；QueryScope、Command 与 StateMachine 由确定性运行时提供。`;setFoot(root,"AI 可以生成表达方案，但不能成为权限、真值和业务合法性的来源",`AI → ViewPlan(${task})`)});setFoot(root,"安全边界先于动态能力","AI controls presentation only");
    }
  };

  function initializePrototype(root) { const kind=root.dataset.prototype; const renderer=renderers[kind]; if(!renderer)return; const reset=()=>{const stage=$("[data-prototype-stage]",root);stage.replaceWith(stage.cloneNode(false));renderer(root)};$('.prototype-reset',root).addEventListener("click",()=>{reset();toast("原型已重置")});renderer(root); }
  $$('.prototype').forEach(initializePrototype);

  const searchInput=$("#searchInput"),searchPanel=$("#searchPanel"),searchCount=$("#searchCount");
  const searchable=$$('.article h2,.article h3,.article p,.article li,.article blockquote,.article td');
  function runSearch(){const query=searchInput.value.trim().toLowerCase();if(!query){searchPanel.classList.remove("open");searchCount.textContent="";return}const hits=searchable.filter(n=>n.textContent.toLowerCase().includes(query)).slice(0,30);searchCount.textContent=`${hits.length} 条`;searchPanel.innerHTML=hits.length?hits.map(n=>{const heading=n.matches('h2,h3')?n:n.closest('section')?.querySelector('h3')||[...n.parentElement.querySelectorAll('h2,h3')].at(-1);const id=heading?.id||n.closest('[id]')?.id||'';const text=n.textContent.trim().replace(/\s+/g,' ').slice(0,100);return`<a class="search-result" href="#${id}"><b>${escapeText(heading?.textContent.replace('#','').trim()||'正文')}</b><small>${escapeText(text)}</small></a>`}).join(''):'<div class="search-empty">没有找到匹配内容</div>';searchPanel.classList.add('open')}
  searchInput.addEventListener('input',runSearch);searchInput.addEventListener('keydown',e=>{if(e.key==='Escape'){searchInput.value='';runSearch()}if(e.key==='Enter'){searchPanel.querySelector('a')?.click()}});searchPanel.addEventListener('click',()=>{searchPanel.classList.remove('open')});document.addEventListener('click',e=>{if(!e.target.closest('.search-box')&&!e.target.closest('.search-panel'))searchPanel.classList.remove('open')});

  const sidebar=$("#sidebar");$("#mobileMenu").addEventListener('click',()=>sidebar.classList.toggle('open'));$$('.toc a').forEach(a=>a.addEventListener('click',()=>sidebar.classList.remove('open')));
  $("#focusButton").addEventListener('click',()=>{document.body.classList.toggle('focus-mode');toast(document.body.classList.contains('focus-mode')?'已进入专注阅读':'已恢复完整导航')});
  $("#printButton").addEventListener('click',()=>window.print());$("#backTop").addEventListener('click',()=>window.scrollTo({top:0,behavior:'smooth'}));
  document.addEventListener('keydown',e=>{if((e.ctrlKey||e.metaKey)&&e.key.toLowerCase()==='k'){e.preventDefault();searchInput.focus()}if(e.key==='Escape')sidebar.classList.remove('open')});

  const observer=new IntersectionObserver(entries=>{entries.forEach(entry=>{if(entry.isIntersecting){const id=entry.target.id;$$('.toc a').forEach(a=>a.classList.toggle('active',a.getAttribute('href')===`#${id}`));history.replaceState(null,'',`#${id}`)}})},{rootMargin:'-15% 0px -75% 0px',threshold:0});$$('.article h2,.article h3').forEach(h=>observer.observe(h));
  function progress(){const max=document.documentElement.scrollHeight-innerHeight;const pct=max>0?Math.min(100,scrollY/max*100):0;$("#readingBar").style.width=`${pct}%`;$("#readingPercent").textContent=`${Math.round(pct)}%`}
  addEventListener('scroll',progress,{passive:true});addEventListener('resize',progress);progress();
})();
}

let js = browserRuntime.toString();
js = js.slice(js.indexOf("{") + 1, js.lastIndexOf("}"));

const documentHtml = `<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="description" content="数据模型与界面模式映射大型交互手册：从业务事实、任务视图到低代码运行时与工程治理。">
  <title>${escapeHtml(title)}</title>
  <style>${css}</style>
</head>
<body>
<div class="app">
  <header class="topbar">
    <button class="icon-button mobile-menu" id="mobileMenu" type="button" title="打开目录" aria-label="打开目录">☰</button>
    <span class="brand-mark" aria-hidden="true"></span>
    <div class="brand">数据模型 × 界面模式<small>大型交互手册 · 10 篇 / ${chapters.length} 章 / ${prototypeCatalog.length} 组原型</small></div>
    <div class="top-actions">
      <div class="search-box">
        <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="7" fill="none" stroke="currentColor" stroke-width="2"></circle><path d="m16.5 16.5 4 4" fill="none" stroke="currentColor" stroke-width="2"></path></svg>
        <input id="searchInput" type="search" placeholder="搜索 84 章正文" aria-label="搜索手册">
        <span class="search-count" id="searchCount"></span>
      </div>
      <div class="reading-meter" aria-label="阅读进度"><i id="readingBar"></i></div>
      <span id="readingPercent" style="font:11px Consolas;color:#aeb9c4">0%</span>
    </div>
  </header>
  <div class="search-panel" id="searchPanel" role="region" aria-live="polite"></div>
  <div class="shell">
    <aside class="sidebar" id="sidebar">
      <div class="side-head"><div class="side-overline">CONTENTS / HANDBOOK</div><h2 class="side-title">十篇知识地图</h2></div>
      <nav class="toc" aria-label="章节目录">${toc}</nav>
      <div class="side-foot">全文来自对应 Markdown 定稿。交互原型用于解释概念，不替代正文。</div>
    </aside>
    <main class="main">
      <article class="article">${articleHtml}</article>
    </main>
    <aside class="utility-rail" aria-label="阅读工具">
      <button class="icon-button" id="focusButton" type="button" title="专注阅读" aria-label="专注阅读">◫</button>
      <button class="icon-button" id="printButton" type="button" title="打印或导出 PDF" aria-label="打印或导出 PDF">↧</button>
      <span class="rail-label">READING TOOLS</span>
      <button class="icon-button back-top" id="backTop" type="button" title="回到顶部" aria-label="回到顶部">↑</button>
    </aside>
  </div>
</div>
<div class="toast" id="toast" role="status"></div>
<script>${js}</script>
</body>
</html>`;

fs.writeFileSync(outputPath, documentHtml, "utf8");
console.log(JSON.stringify({ outputPath, bytes: Buffer.byteLength(documentHtml), parts: parts.length, chapters: chapters.length, prototypes: prototypeCatalog.length }, null, 2));
