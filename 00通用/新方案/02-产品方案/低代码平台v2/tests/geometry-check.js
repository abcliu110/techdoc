(() => {
  const viewport = { width: innerWidth, height: innerHeight };
  const selectors = [
    '[data-testid="topbar"]',
    '[data-testid="workspace-nav"]',
    '[data-testid="resource-panel"]',
    '[data-testid="design-canvas"]',
    '[data-testid="property-inspector"]',
    '[data-testid="analysis-panel"]',
  ];
  const regions = selectors.map((selector) => {
    const rect = document.querySelector(selector).getBoundingClientRect();
    return {
      selector,
      left: Math.round(rect.left),
      top: Math.round(rect.top),
      right: Math.round(rect.right),
      bottom: Math.round(rect.bottom),
      width: Math.round(rect.width),
      height: Math.round(rect.height),
      insideViewport: rect.left >= 0 && rect.top >= 0 && rect.right <= innerWidth && rect.bottom <= innerHeight,
    };
  });
  const canvasRect = document.querySelector('[data-testid="design-canvas"]').getBoundingClientRect();
  const businessActionsRect = document.querySelector('.business-actions').getBoundingClientRect();
  const businessActionsInsideCanvas =
    businessActionsRect.left >= canvasRect.left && businessActionsRect.right <= canvasRect.right;
  return JSON.stringify({
    viewport,
    body: {
      clientWidth: document.body.clientWidth,
      scrollWidth: document.body.scrollWidth,
      clientHeight: document.body.clientHeight,
      scrollHeight: document.body.scrollHeight,
    },
    rootState: document.querySelector('[data-testid="designer-root"]').dataset.state,
    regions,
    businessActions: {
      left: Math.round(businessActionsRect.left),
      right: Math.round(businessActionsRect.right),
      canvasLeft: Math.round(canvasRect.left),
      canvasRight: Math.round(canvasRect.right),
      insideCanvas: businessActionsInsideCanvas,
    },
    pass:
      document.body.scrollWidth <= document.body.clientWidth &&
      regions.every((region) => region.insideViewport) &&
      businessActionsInsideCanvas,
  });
})();
