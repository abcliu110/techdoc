function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
}

function action(name, label, attributes = '') {
  return `<button type="button" data-runtime-action="${name}" ${attributes}>${label}</button>`;
}

function runtimeBody(manifest, state) {
  const contract = getRuntimeContract(manifest);
  const kind = contract.controlKind;
  const readonly = state.permission === 'readonly' ? 'disabled' : '';
  if (kind === 'file' || kind === 'image-upload') return `<label>选择文件<input type="file" data-runtime-action="add-file" ${kind === 'image-upload' ? 'accept="image/*"' : ''} ${readonly}></label><div class="runtime-file-list">${state.files?.map((file) => `<span>${escapeHtml(file.name)} ${action('remove-file', '移除', `data-runtime-file="${escapeHtml(file.name)}"`)}</span>`).join('') || '尚未选择文件'}</div>`;
  if (kind === 'rich-text' || kind === 'markdown') return `<div class="runtime-editor-toolbar">${action('trigger-command', '加粗')}${action('trigger-command', kind === 'markdown' ? '预览 Markdown' : '插入链接')}</div><textarea data-runtime-action="set-value" ${readonly}>${escapeHtml(state.value)}</textarea>`;
  if (kind === 'map') return `<div class="runtime-map"><span>31.2304, 121.4737</span>${action('set-location', '选择位置')}</div>`;
  if (kind === 'qrcode') return `<div class="runtime-qrcode" aria-label="二维码预览">▦</div>${action('set-value', '更新内容', 'data-runtime-value="ORDER-001"')}`;
  if (kind === 'audio' || kind === 'video') return `<div class="runtime-media"><strong>${kind === 'audio' ? '音频播放器' : '视频播放器'}</strong>${action('toggle-play', state.playing ? '暂停' : '播放')}</div>`;
  if (kind === 'pagination') return `<nav class="runtime-pagination">${action('previous-page', '上一页')}<output>第 ${state.page || 1} 页</output>${action('next-page', '下一页')}</nav>`;
  if (kind === 'comments') return `<div class="runtime-comments">${(state.comments || []).map((item) => `<p>${escapeHtml(item)}</p>`).join('')}${action('add-comment', '添加评论')}</div>`;
  if (manifest.category === 'input') {
    if (manifest.type === 'Switch') return `<label class="runtime-switch"><input type="checkbox" data-runtime-action="toggle" ${state.value ? 'checked' : ''} ${readonly}><span>${state.value ? '开启' : '关闭'}</span></label>`;
    if (['RadioGroup', 'CheckboxGroup', 'Select', 'Cascader', 'TagSelect'].includes(manifest.type)) {
      const selected = state.selected?.[0] || '';
      return `<label>选项<select data-runtime-action="select" ${readonly}><option value="" ${selected === '' ? 'selected' : ''}>请选择</option><option value="A" ${selected === 'A' ? 'selected' : ''}>选项 A</option><option value="B" ${selected === 'B' ? 'selected' : ''}>选项 B</option></select></label>`;
    }
    const inputType = ['password','number','date','time','datetime-local'].includes(kind) ? kind : 'text';
    return `<label>${escapeHtml(state.config.label)}<input type="${inputType}" value="${escapeHtml(state.value)}" data-runtime-action="set-value" ${state.config.required ? 'required' : ''} ${readonly}></label><output>${escapeHtml(state.value || '等待输入')}</output>`;
  }
  if (manifest.category === 'reference') return `<label>基础资料<input value="${escapeHtml(state.selected[0] || '')}" readonly></label>${action('select', '选择业务对象', 'data-runtime-value="CUST-001"')}${state.selected.length ? action('select', '清除', 'data-runtime-value=""') : ''}`;
  if (manifest.category === 'data') return `<div class="runtime-commandbar">${action('add-row', '增行')}</div><table><thead><tr><th>编码</th><th>名称</th><th>数量</th><th></th></tr></thead><tbody>${state.rows.map((row) => `<tr><td>${escapeHtml(row.id)}</td><td>${escapeHtml(row.name)}</td><td>${row.quantity}</td><td>${action('remove-row', '删除', `data-runtime-row="${escapeHtml(row.id)}"`)}</td></tr>`).join('')}</tbody></table>`;
  if (manifest.category === 'hierarchy') return `<div class="runtime-tree">${action('expand', state.expanded.includes('root') ? '收起 根节点' : '展开 根节点', 'data-runtime-key="root"')}${state.expanded.includes('root') ? `<div class="runtime-tree-child">${action('select-node', '业务节点 A', 'data-runtime-key="item-a"')}</div>` : ''}<output>当前：${escapeHtml(state.activeKey)}</output></div>`;
  if (manifest.category === 'workflow') return `<nav class="runtime-actions">${action('trigger-command', '执行操作')}<output>已执行 ${state.commandCount} 次</output></nav>`;
  if (manifest.category === 'analytics') return `<div class="runtime-chart" role="img" aria-label="${escapeHtml(manifest.title)}"><span style="height:35%"></span><span style="height:72%"></span><span style="height:54%"></span></div>${action('select-node', '选择数据点', 'data-runtime-key="series-a"')}`;
  if (manifest.category === 'extension') return `<div class="runtime-extension"><strong>受控扩展沙箱</strong><span>网络与脚本按白名单隔离</span>${action('trigger-command', '刷新扩展')}</div>`;
  if (manifest.category === 'layout' || manifest.category === 'common') return `<div class="runtime-layout"><div>区域 A${state.activeKey === 'item-1' ? ' (当前)' : ''}</div><div>区域 B${state.activeKey === 'item-2' ? ' (当前)' : ''}</div>${action('select-node', '切换活动区域', 'data-runtime-key="item-2"')}</div>`;
  return `<div class="runtime-display"><strong>${escapeHtml(state.config.label)}</strong><span>${escapeHtml(state.value || '示例展示内容')}</span>${action('trigger-command', '刷新内容')}</div>`;
}

export function renderInteractiveComponent(manifest, mode, state) {
  if (!manifest?.type || state?.componentType !== manifest.type) throw new TypeError('Component runtime state does not match manifest');
  if (manifest.status === 'planned') return `<section class="interactive-component disabled" data-runtime-component="${escapeHtml(manifest.type)}" data-runtime-disabled="true"><strong>${escapeHtml(manifest.title)}</strong><span>规划中，当前不可运行</span></section>`;
  if (mode === 'configure') {
    const contract = getRuntimeContract(manifest);
    const fields = [`<label>显示名称<input data-runtime-action="set-config" data-runtime-config="label" value="${escapeHtml(state.config.label)}"></label>`];
    if (manifest.dataBinding !== 'none') fields.push(`<label>数据绑定<input data-runtime-action="set-config" data-runtime-config="binding" value="${escapeHtml(state.config.binding)}"></label>`);
    if (manifest.category === 'input' || manifest.category === 'reference') fields.push(`<label><input type="checkbox" data-runtime-action="set-config" data-runtime-config="required" ${state.config.required ? 'checked' : ''}> 必填</label><label>选择模式<select data-runtime-action="set-config" data-runtime-config="selectionMode"><option value="single">单选</option><option value="multiple">多选</option></select></label>`);
    if (manifest.category === 'data' || manifest.category === 'hierarchy' || manifest.category === 'analytics') fields.push(`<label>数据源<input data-runtime-action="set-config" data-runtime-config="dataSource" value="${escapeHtml(state.config.dataSource)}"></label><label>分页大小<input type="number" min="1" data-runtime-action="set-config" data-runtime-config="pageSize" value="${state.config.pageSize}"></label>`);
    if (manifest.category === 'extension') fields.push(`<label><input type="checkbox" data-runtime-action="set-config" data-runtime-config="sandbox" ${state.config.sandbox ? 'checked' : ''}> 启用安全沙箱</label>`);
    fields.push(`<output>控件合同：${escapeHtml(contract.controlKind)} · ${escapeHtml(contract.actions.join(' / '))}</output>`);
    return `<section class="interactive-component" data-runtime-component="${escapeHtml(manifest.type)}">${fields.join('')}</section>`;
  }
  if (mode === 'failure' && state.recovered) return `<section class="interactive-component runtime-recovered" data-runtime-component="${escapeHtml(manifest.type)}"><strong>组件已恢复</strong><span>运行状态和原值已保留</span>${action('set-error', '再次模拟异常')}</section>`;
  if (mode === 'failure') return `<section class="interactive-component runtime-error" data-runtime-component="${escapeHtml(manifest.type)}"><strong>组件加载失败</strong><span>${escapeHtml(state.error || '模拟运行异常')}</span>${action('retry', '重试')}</section>`;
  if (mode === 'permission') return `<section class="interactive-component" data-runtime-component="${escapeHtml(manifest.type)}"><strong>角色权限</strong><div class="runtime-segments">${['allow', 'readonly', 'hidden'].map((permission) => action('set-permission', permission === 'allow' ? '允许' : permission === 'readonly' ? '只读' : '隐藏', `data-runtime-permission="${permission}" ${state.permission === permission ? 'aria-pressed="true"' : ''}`)).join('')}</div></section>`;
  if (state.permission === 'hidden') return `<section class="interactive-component" data-runtime-component="${escapeHtml(manifest.type)}"><span>当前角色无权查看此组件</span>${action('set-permission', '恢复允许', 'data-runtime-permission="allow"')}</section>`;
  return `<section class="interactive-component category-${escapeHtml(manifest.category)}" data-runtime-component="${escapeHtml(manifest.type)}" data-runtime-mode="${escapeHtml(mode)}"><header><strong>${escapeHtml(manifest.title)}</strong><span>${escapeHtml(manifest.type)}</span></header><div class="interactive-runtime-body">${runtimeBody(manifest, state)}</div></section>`;
}
import { getRuntimeContract } from './component-runtime-contracts.mjs';
