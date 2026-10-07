/**
 * E2E测试辅助函数导出
 */

// 页面操作辅助函数
export { default as completeCurrentStep, completeStepAndVerify } from './completeCurrentStep';
export { default as highlightSegment, highlightMultipleSegments, unhighlightSegment, verifySegmentHighlight, waitForSplitComplete } from './highlightSegment';
export { default as fillInput, clearAndFillInput, getInputValue, verifyInputValue, verifyInputEmpty, inputWithRetry, pressEnter } from './fillInput';
export {
  verifyProgressBarVisible,
  getProgressValue,
  verifyProgressIncrease,
  getStepCount,
  verifyStepCounter,
  verifyProgressComplete,
  verifyProgressSteps,
} from './verifyProgress';
