export function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

export function createDomRuntime(stage, statusNode, toastNode) {
  let active = true;
  const cleanups = [];
  const timers = new Set();
  const token = { get active() { return active; } };

  function append(parent, child) {
    if (child === null || child === undefined || child === false) return;
    if (Array.isArray(child)) {
      child.forEach((item) => append(parent, item));
      return;
    }
    parent.append(child instanceof Node ? child : document.createTextNode(String(child)));
  }

  function el(tag, attributes = {}, ...children) {
    const node = document.createElement(tag);
    for (const [name, value] of Object.entries(attributes || {})) {
      if (value === null || value === undefined || value === false) continue;
      if (/^on/i.test(name)) throw new Error("Inline event attributes are forbidden");
      if (name === "className") node.className = value;
      else if (name === "text") node.textContent = value;
      else if (name === "dataset") Object.assign(node.dataset, value);
      else if (name === "style" && typeof value === "object") Object.assign(node.style, value);
      else if (name in node && !name.startsWith("aria-") && !name.startsWith("data-")) node[name] = value;
      else node.setAttribute(name, value === true ? "" : String(value));
    }
    children.forEach((child) => append(node, child));
    return node;
  }

  function button(label, action, options = {}) {
    return el("button", {
      type: "button",
      className: options.className || "btn",
      disabled: options.disabled || false,
      "data-action": action,
      "aria-label": options.ariaLabel || label,
      title: options.title || "",
    }, label);
  }

  function field(label, control) {
    const id = control.id || "control-" + Math.random().toString(36).slice(2);
    control.id = id;
    if (!control.getAttribute("aria-label")) control.setAttribute("aria-label", label);
    return el("label", { className: "field", htmlFor: id }, el("span", { className: "field-label" }, label), control);
  }

  function setText(node, value) { node.textContent = value == null ? "" : String(value); }
  function setStatus(text, state = text) {
    setText(statusNode, text);
    statusNode.dataset.state = String(state);
  }
  function toast(text) {
    setText(toastNode, text);
    toastNode.classList.add("show");
    const id = window.setTimeout(() => { if (active) toastNode.classList.remove("show"); }, 1400);
    timers.add(id);
  }
  function on(target, type, listener, options) {
    target.addEventListener(type, listener, options);
    cleanups.push(() => target.removeEventListener(type, listener, options));
    return listener;
  }
  function timeout(listener, delay) {
    const id = window.setTimeout(() => {
      timers.delete(id);
      if (active) listener();
    }, delay);
    timers.add(id);
    return id;
  }
  function cleanup() {
    active = false;
    cleanups.splice(0).reverse().forEach((dispose) => dispose());
    timers.forEach((id) => window.clearTimeout(id));
    timers.clear();
  }
  return { stage, el, button, field, setText, setStatus, toast, on, timeout, token, cleanup };
}

export const browserDomSource = createDomRuntime.toString();
