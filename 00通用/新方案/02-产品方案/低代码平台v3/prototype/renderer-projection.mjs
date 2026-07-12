const WIDTH_COLUMNS = Object.freeze({
  '1/3': 'span 1',
  '1/2': 'span 2',
  '2/3': 'span 2',
  '整行': '1 / -1',
});

const CONTROL_TAGS = Object.freeze({
  '文本字段': 'input',
  '多行文本': 'textarea',
  '基础资料字段': 'reference',
  '日期字段': 'date',
  '金额字段': 'number',
});

function cssLength(value, fallback = '0') {
  if (typeof value !== 'string') return fallback;
  const match = value.trim().match(/^(\d+(?:\.\d+)?)\s*(px|rem|em|%)?$/i);
  return match ? `${match[1]}${match[2] || 'px'}` : fallback;
}

function cssBox(value) {
  if (typeof value !== 'string') return '0';
  const parts = value.split('/').map((part) => cssLength(part.trim(), '')).filter(Boolean);
  return parts.length === 4 ? parts.join(' ') : '0';
}

export function projectFieldRenderer(field = {}) {
  return {
    style: {
      gridColumn: WIDTH_COLUMNS[field.width] || WIDTH_COLUMNS['整行'],
      minWidth: cssLength(field.minWidth, '0'),
      margin: cssBox(field.margin),
      padding: cssBox(field.padding),
      alignSelf: { '起始': 'start', '拉伸': 'stretch' }[field.align] || 'auto',
    },
    labelPosition: field.labelPosition === '左侧' ? 'left' : 'top',
    control: CONTROL_TAGS[field.controlType || field.type] || 'input',
  };
}

export function rendererStyleAttribute(style) {
  return Object.entries(style)
    .map(([name, value]) => `${name.replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`)}:${value}`)
    .join(';');
}
