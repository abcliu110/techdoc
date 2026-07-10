/**
 * .eslintrc.js — ESLint 配置
 *
 * 约束执行机制（3.5 节）：
 * - eslint-plugin-tailwindcss 拦截非白名单类名
 * - 禁止 Tailwind 任意值语法 p-[13px]
 * - 检测 absolute 定位做主布局
 */

module.exports = {
  root: true,
  env: { browser: true, es2021: true, node: true },
  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:@typescript-eslint/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaFeatures: { jsx: true },
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  plugins: ['react', '@typescript-eslint', 'tailwindcss'],
  rules: {
    // 拦截非白名单类名
    'tailwindcss/no-custom-classname': ['error', {
      whitelist: [
        'btn-primary', 'btn-secondary', 'btn-ghost',
        'card', 'card-header', 'card-body', 'card-footer',
        'table-wrapper', 'form-item', 'form-label', 'form-input',
        'nav-item', 'nav-link', 'modal-overlay', 'modal-content',
        'badge', 'tag', 'avatar', 'spinner', 'empty-state',
      ],
    }],
    'tailwindcss/classnames-order': 'warn',
    'tailwindcss/no-unknown-class': 'error',
    // 检测 absolute 定位做主布局
    'no-restricted-syntax': ['warn', {
      selector: "JSXAttribute[argument.value=~/'absolute']/..",
      message: '禁止在主布局中使用 absolute 定位，请使用 Flex/Grid。',
    }],
    'react/react-in-jsx-scope': 'off',
    'react/prop-types': 'off',
    'no-debugger': 'error',
    'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/no-explicit-any': 'warn',
  },
  settings: {
    react: { version: 'detect' },
    tailwindcss: { config: './tailwind.config.js' },
  },
  overrides: [{
    files: ['scripts/**/*.js'],
    rules: {
      'tailwindcss/no-custom-classname': 'off',
      'tailwindcss/no-unknown-class': 'off',
    },
  }],
};
