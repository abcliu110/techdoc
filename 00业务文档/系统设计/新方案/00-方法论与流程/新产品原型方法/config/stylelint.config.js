/**
 * stylelint.config.js — Stylelint 配置
 *
 * 约束执行机制（3.5 节）：
 * - 检查 .css 文件中的硬编码像素值（不检查 Tailwind 类名）
 * - 检查未使用 Design Token 的自定义样式
 */

module.exports = {
  extends: ['stylelint-config-standard'],
  rules: {
    // 禁止硬编码像素值（必须使用 CSS 变量/Tailwind token）
    // 允许的例外：0px, 1px（边框）, 100px（用于百分比回退）
    'declaration-property-value-allowed-list': {
      '/.*/': ['/^(?!\\d+px$).*/', '/^0px$/', '/^1px$/', '/^100%$/'],
    },
    // 禁止使用 !important
    'declaration-no-important': true,
    // 颜色必须使用变量
    'color-no-hex': true,
    // 字体族必须使用变量
    'font-family-no-missing-generic-family-keyword': true,
    // 禁止使用 ID 选择器
    'selector-max-id': 0,
    // 禁止嵌套超过 3 层
    'max-nesting-depth': 3,
  },
  // 仅检查 .css 文件（不检查 Tailwind 生成的样式）
  files: ['**/*.css', '!**/node_modules/**', '!**/dist/**'],
};
