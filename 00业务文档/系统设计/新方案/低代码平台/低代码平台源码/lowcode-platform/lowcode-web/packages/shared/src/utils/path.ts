/**
 * 从对象中获取嵌套属性值
 *
 * @param obj - 源对象
 * @param path - 路径字符串，如 'user.address.city' 或 'items[0].name'
 * @param defaultValue - 路径不存在时的默认值
 * @returns 目标值或默认值
 *
 * @example
 * const obj = { user: { address: { city: 'Beijing' } } };
 * getIn(obj, 'user.address.city');  // 'Beijing'
 * getIn(obj, 'user.age', 18);  // 18 (默认值)
 */
export function getIn(
  obj: any,
  path: string | string[],
  defaultValue?: any
): any {
  if (!obj) return defaultValue;

  const pathArray = Array.isArray(path) ? path : parsePath(path);

  let current = obj;
  for (const key of pathArray) {
    if (current === null || current === undefined) {
      return defaultValue;
    }
    current = current[key];
  }

  return current !== undefined ? current : defaultValue;
}

/**
 * 设置对象的嵌套属性值（会修改原对象）
 *
 * @param obj - 目标对象（会被修改）
 * @param path - 路径字符串
 * @param value - 要设置的值
 *
 * @example
 * const obj = {};
 * setIn(obj, 'user.address.city', 'Shanghai');
 * // obj => { user: { address: { city: 'Shanghai' } } }
 *
 * setIn(obj, 'items[0].name', 'First');
 * // obj => { items: [{ name: 'First' }] }
 */
export function setIn(
  obj: any,
  path: string | string[],
  value: any
): void {
  if (!obj) return;

  const pathArray = Array.isArray(path) ? path : parsePath(path);
  const lastKey = pathArray[pathArray.length - 1];

  let current = obj;
  for (let i = 0; i < pathArray.length - 1; i++) {
    const key = pathArray[i];
    const nextKey = pathArray[i + 1];

    // 如果当前层级不存在，根据下一个key决定创建对象还是数组
    if (!(key in current)) {
      current[key] = /^\d+$/.test(nextKey) ? [] : {};
    }

    current = current[key];
  }

  current[lastKey] = value;
}

/**
 * 删除对象的嵌套属性
 *
 * @param obj - 目标对象
 * @param path - 路径字符串
 *
 * @example
 * const obj = { user: { name: 'John', age: 30 } };
 * deleteIn(obj, 'user.age');
 * // obj => { user: { name: 'John' } }
 */
export function deleteIn(obj: any, path: string | string[]): void {
  if (!obj) return;

  const pathArray = Array.isArray(path) ? path : parsePath(path);
  const lastKey = pathArray[pathArray.length - 1];

  let current = obj;
  for (let i = 0; i < pathArray.length - 1; i++) {
    if (!(pathArray[i] in current)) return;
    current = current[pathArray[i]];
  }

  if (Array.isArray(current)) {
    current.splice(Number(lastKey), 1);
  } else {
    delete current[lastKey];
  }
}

/**
 * 检查路径是否存在
 *
 * @param obj - 源对象
 * @param path - 路径字符串
 * @returns 是否存在
 */
export function hasIn(obj: any, path: string | string[]): boolean {
  if (!obj) return false;

  const pathArray = Array.isArray(path) ? path : parsePath(path);

  let current = obj;
  for (const key of pathArray) {
    if (current === null || current === undefined || !(key in current)) {
      return false;
    }
    current = current[key];
  }

  return true;
}

/**
 * 解析路径字符串为数组
 *
 * @param path - 路径字符串
 * @returns 路径段数组
 *
 * @example
 * parsePath('user.phones[0].number')
 * // ['user', 'phones', '0', 'number']
 *
 * parsePath('items[0][1].value')
 * // ['items', '0', '1', 'value']
 */
function parsePath(path: string): string[] {
  return path
    .replace(/\[(\d+)\]/g, '.$1')  // 'items[0]' => 'items.0'
    .split('.')
    .filter(Boolean);  // 过滤空字符串
}
