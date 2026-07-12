(function () {
  'use strict';

  var liveRegion;
  var toastTimer;

  function getLiveRegion() {
    if (!liveRegion) {
      liveRegion = document.querySelector('[data-live-region]');
    }
    return liveRegion;
  }

  function announce(message) {
    var region = getLiveRegion();
    if (region) {
      region.textContent = message;
    }

    var toast = document.querySelector('[data-toast]');
    if (!toast) {
      return;
    }
    toast.textContent = message;
    toast.hidden = false;
    window.clearTimeout(toastTimer);
    toastTimer = window.setTimeout(function () {
      toast.hidden = true;
    }, 2400);
  }

  function setText(selector, value) {
    var element = document.querySelector(selector);
    if (element) {
      element.textContent = value;
    }
  }

  function setStatus(element, label, state) {
    if (!element) {
      return;
    }
    element.textContent = label;
    element.className = 'badge ' + state;
  }

  function activateTab(button) {
    var tablist = button.closest('[role="tablist"]');
    if (!tablist) {
      return;
    }
    var tabs = Array.prototype.slice.call(tablist.querySelectorAll('[role="tab"]'));
    tabs.forEach(function (tab) {
      var selected = tab === button;
      tab.setAttribute('aria-selected', selected ? 'true' : 'false');
      tab.tabIndex = selected ? 0 : -1;
      var panelId = tab.getAttribute('aria-controls');
      var panel = panelId && document.getElementById(panelId);
      if (panel) {
        panel.hidden = !selected;
      }
    });
  }

  function toggleSegment(button) {
    var group = button.closest('.segmented');
    if (!group) {
      return;
    }
    Array.prototype.forEach.call(group.querySelectorAll('button'), function (item) {
      item.setAttribute('aria-pressed', item === button ? 'true' : 'false');
    });
    var target = button.getAttribute('data-view-label');
    if (target) {
      setText('[data-current-view]', target);
      announce('已切换到' + target);
    }
  }

  function updateSelection(checkbox) {
    var row = checkbox.closest('tr');
    if (row) {
      row.classList.toggle('row-selected', checkbox.checked);
    }
    var selected = document.querySelectorAll('[data-row-select]:checked').length;
    setText('[data-selected-count]', String(selected));
    var bulkBar = document.querySelector('[data-bulk-bar]');
    if (bulkBar) {
      bulkBar.hidden = selected === 0;
    }
  }

  function toggleAll(checkbox) {
    Array.prototype.forEach.call(document.querySelectorAll('[data-row-select]'), function (item) {
      item.checked = checkbox.checked;
      updateSelection(item);
    });
  }

  function moveWizard(direction) {
    var wizard = document.querySelector('[data-wizard]');
    if (!wizard) {
      return;
    }
    var panels = Array.prototype.slice.call(wizard.querySelectorAll('[data-step-panel]'));
    var steps = Array.prototype.slice.call(wizard.querySelectorAll('[data-step]'));
    var current = Number(wizard.getAttribute('data-current-step') || '1');
    var next = Math.max(1, Math.min(panels.length, current + direction));
    wizard.setAttribute('data-current-step', String(next));
    panels.forEach(function (panel, index) {
      panel.hidden = index + 1 !== next;
    });
    steps.forEach(function (step, index) {
      step.removeAttribute('aria-current');
      step.classList.toggle('is-done', index + 1 < next);
      if (index + 1 === next) {
        step.setAttribute('aria-current', 'step');
      }
    });
    var previous = wizard.querySelector('[data-action="previous-step"]');
    var nextButton = wizard.querySelector('[data-action="next-step"]');
    if (previous) {
      previous.disabled = next === 1;
    }
    if (nextButton) {
      nextButton.textContent = next === panels.length ? '完成配置' : '下一步';
    }
    setText('[data-step-status]', '第 ' + next + ' 步，共 ' + panels.length + ' 步');
    announce(next === panels.length && direction > 0 && current === panels.length ? '配置已完成' : '已进入第 ' + next + ' 步');
  }

  function runImport(button) {
    button.disabled = true;
    setStatus(document.querySelector('[data-import-status]'), '校验中', 'warning');
    setText('[data-import-progress]', '32%');
    var bar = document.querySelector('[data-import-bar]');
    if (bar) {
      bar.style.setProperty('--progress', '32%');
    }
    window.setTimeout(function () {
      setStatus(document.querySelector('[data-import-status]'), '已完成', 'success');
      setText('[data-import-progress]', '100%');
      setText('[data-import-success]', '96');
      setText('[data-import-failed]', '3');
      setText('[data-import-skipped]', '1');
      if (bar) {
        bar.style.setProperty('--progress', '100%');
      }
      button.disabled = false;
      announce('导入完成：成功 96 条，失败 3 条，跳过 1 条');
    }, 450);
  }

  function saveDraft(button) {
    var draft = document.querySelector('[data-draft-status]');
    setStatus(draft, '保存中', 'warning');
    button.disabled = true;
    window.setTimeout(function () {
      setStatus(draft, '草稿已保存', 'success');
      setText('[data-draft-time]', new Date().toLocaleTimeString('zh-CN', { hour12: false }));
      button.disabled = false;
      document.querySelectorAll('[data-dirty]').forEach(function (field) {
        field.removeAttribute('data-dirty');
      });
      announce('草稿已保存，仅当前编辑者可继续修改');
    }, 300);
  }

  function retryImport(button) {
    var row = button.closest('tr');
    var status = row && row.querySelector('[data-job-status]');
    setStatus(status, '重试中', 'warning');
    button.disabled = true;
    window.setTimeout(function () {
      setStatus(status, '成功', 'success');
      button.disabled = false;
      announce('失败记录已重试成功，原任务审计记录已保留');
    }, 420);
  }

  function testRule(button) {
    var result = document.querySelector('[data-rule-result]');
    var title = button.getAttribute('data-result-title') || '命中规则';
    var detail = button.getAttribute('data-result-text') || '华东直营店的退款金额为 1,280 元，需要区域经理审批。';
    if (result) {
      result.hidden = false;
      result.className = 'notice success';
      result.innerHTML = '<strong>' + title + '</strong>' + detail;
    }
    button.textContent = '重新测试';
    announce(button.getAttribute('data-result-message') || '规则测试完成：1 条样本命中，审批人可解析');
  }

  function approveAi(button) {
    var status = document.querySelector('[data-ai-status]');
    setStatus(status, '人工已批准', 'success');
    var audit = document.querySelector('[data-ai-audit]');
    if (audit) {
      audit.hidden = false;
    }
    document.querySelectorAll('[data-action="approve-ai"], [data-action="reject-ai"]').forEach(function (item) {
      item.disabled = true;
    });
    announce('建议已由人工批准并写入审计记录');
  }

  function rejectAi() {
    setStatus(document.querySelector('[data-ai-status]'), '人工已驳回', 'danger');
    document.querySelectorAll('[data-action="approve-ai"], [data-action="reject-ai"]').forEach(function (item) {
      item.disabled = true;
    });
    announce('建议已驳回，业务状态未被自动修改');
  }

  function runSimulation(button) {
    var result = document.querySelector('[data-simulation-result]');
    if (result) {
      result.hidden = false;
    }
    setText('[data-simulation-total]', '¥ 300.00');
    setText('[data-simulation-discount]', '- ¥ 30.00');
    button.textContent = '重新模拟';
    announce('模拟完成：规则命中 2 项，无互斥冲突');
  }

  function retryJob(button) {
    var row = button.closest('tr');
    var status = row && row.querySelector('[data-queue-status]');
    setStatus(status, '执行中', 'warning');
    button.disabled = true;
    window.setTimeout(function () {
      setStatus(status, '已完成', 'success');
      button.disabled = false;
      announce('任务重试完成，沿用原幂等键且未重复记账');
    }, 420);
  }

  function compensateJob(button) {
    var row = button.closest('tr');
    var status = row && row.querySelector('[data-queue-status]');
    setStatus(status, '已补偿', 'info');
    button.disabled = true;
    announce('补偿动作已记录，原失败事实仍可追溯');
  }

  function openModal(button) {
    var id = button.getAttribute('aria-controls');
    var modal = id && document.getElementById(id);
    if (!modal) {
      return;
    }
    modal.hidden = false;
    modal.setAttribute('data-opener', button.id || '');
    var first = modal.querySelector('input, select, textarea, button');
    if (first) {
      first.focus();
    }
  }

  function closeModal(button) {
    var modal = button.closest('.modal-backdrop');
    if (!modal) {
      return;
    }
    modal.hidden = true;
    var openerId = modal.getAttribute('data-opener');
    var opener = openerId && document.getElementById(openerId);
    if (opener) {
      opener.focus();
    }
  }

  function restoreVersion(button) {
    var version = button.getAttribute('data-version') || '所选版本';
    setStatus(document.querySelector('[data-version-status]'), '已恢复为 ' + version, 'success');
    announce('已创建基于 ' + version + ' 的新版本，历史版本未被覆盖');
  }

  function updatePath(button, result) {
    var path = document.querySelector('[data-approval-path]');
    if (path) {
      path.querySelectorAll('li').forEach(function (item) {
        item.removeAttribute('aria-current');
      });
      var target = path.querySelector('[data-stage="' + result + '"]');
      if (target) {
        target.setAttribute('aria-current', 'step');
      }
    }
    setStatus(document.querySelector('[data-approval-status]'), result === 'approved' ? '已批准' : '已退回', result === 'approved' ? 'success' : 'danger');
    announce(result === 'approved' ? '审批已通过，承诺记录已生成' : '已退回申请人并保留审批意见');
  }

  function handleClick(event) {
    var button = event.target.closest('button[data-action]');
    if (!button) {
      return;
    }
    var action = button.getAttribute('data-action');
    if (action === 'tab') activateTab(button);
    else if (action === 'segment') toggleSegment(button);
    else if (action === 'next-step') moveWizard(1);
    else if (action === 'previous-step') moveWizard(-1);
    else if (action === 'run-import') runImport(button);
    else if (action === 'save-draft') saveDraft(button);
    else if (action === 'retry-import') retryImport(button);
    else if (action === 'test-rule') testRule(button);
    else if (action === 'approve-ai') approveAi(button);
    else if (action === 'reject-ai') rejectAi();
    else if (action === 'run-simulation') runSimulation(button);
    else if (action === 'retry-job') retryJob(button);
    else if (action === 'compensate-job') compensateJob(button);
    else if (action === 'open-modal') openModal(button);
    else if (action === 'close-modal') closeModal(button);
    else if (action === 'restore-version') restoreVersion(button);
    else if (action === 'approve-path') updatePath(button, 'approved');
    else if (action === 'reject-path') updatePath(button, 'rejected');
    else if (action === 'toast') announce(button.getAttribute('data-message') || '操作已记录');
    else if (action === 'remove-chip') {
      var chip = button.closest('.chip');
      if (chip) chip.remove();
      announce('筛选条件已移除');
    } else if (action === 'bulk-complete') {
      announce('批量任务已提交，3 条记录进入处理队列');
    }
  }

  function handleChange(event) {
    var target = event.target;
    if (target.matches('[data-select-all]')) {
      toggleAll(target);
    } else if (target.matches('[data-row-select]')) {
      updateSelection(target);
    } else if (target.matches('[data-draft-field]')) {
      target.setAttribute('data-dirty', 'true');
      setStatus(document.querySelector('[data-draft-status]'), '有未保存修改', 'warning');
    } else if (target.matches('[data-permission-toggle]')) {
      var label = target.getAttribute('aria-label') || '权限';
      announce(label + (target.checked ? '已授予' : '已撤销'));
    }
  }

  function handleKeydown(event) {
    var tab = event.target.closest('[role="tab"]');
    if (tab && (event.key === 'ArrowLeft' || event.key === 'ArrowRight')) {
      var tabs = Array.prototype.slice.call(tab.closest('[role="tablist"]').querySelectorAll('[role="tab"]'));
      var index = tabs.indexOf(tab);
      var offset = event.key === 'ArrowRight' ? 1 : -1;
      var next = tabs[(index + offset + tabs.length) % tabs.length];
      next.focus();
      activateTab(next);
      event.preventDefault();
    }
    if (event.key === 'Escape') {
      var modal = document.querySelector('.modal-backdrop:not([hidden])');
      if (modal) {
        var close = modal.querySelector('[data-action="close-modal"]');
        if (close) closeModal(close);
      }
    }
  }

  document.addEventListener('click', handleClick);
  document.addEventListener('change', handleChange);
  document.addEventListener('keydown', handleKeydown);
})();
