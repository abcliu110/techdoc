(async () => {
  if (!window.enterpriseQualityGate) throw new Error('quality gate runtime unavailable');
  await window.enterpriseQualityGate.ready;
  return window.enterpriseQualityGate.run();
})();
