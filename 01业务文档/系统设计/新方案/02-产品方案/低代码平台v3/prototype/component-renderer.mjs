import { componentPrototype } from './component-prototype-model.mjs';

const STATES = new Set(['design', 'configure', 'preview', 'runtime', 'failure', 'permission']);

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (char) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  })[char]);
}

function partLabel(part) {
  return part.split('-').map((token) => token[0].toUpperCase() + token.slice(1)).join(' ');
}

export function renderComponentPrototype(manifest, state = 'design') {
  if (!STATES.has(state)) throw new TypeError(`Unsupported prototype state: ${state}`);
  const model = componentPrototype(manifest);
  const disabled = manifest.status === 'planned';
  const parts = model.structure.map((part, index) => `
    <div class="prototype-part prototype-part-${index + 1}" data-part="${escapeHtml(part)}">
      <span>${escapeHtml(partLabel(part))}</span><small>${escapeHtml(model.rendererKind)}</small>
    </div>`).join('');
  const notice = state === 'failure'
    ? '<div class="prototype-notice danger">绑定或运行失败，保留原值并提供重试</div>'
    : state === 'permission'
      ? '<div class="prototype-notice warning">角色裁剪：隐藏、只读或拒绝</div>'
      : disabled
        ? '<div class="prototype-notice">规划中，当前不可拖入或发布</div>'
        : '';
  return `<article class="component-prototype renderer-${escapeHtml(model.rendererKind)} state-${state}" data-prototype-component="${escapeHtml(manifest.type)}" data-prototype-state="${state}" data-renderer-kind="${escapeHtml(model.rendererKind)}">
    <header><strong>${escapeHtml(manifest.title)}</strong><span>${escapeHtml(manifest.type)}</span></header>
    <div class="prototype-structure">${parts}</div>${notice}
  </article>`;
}
