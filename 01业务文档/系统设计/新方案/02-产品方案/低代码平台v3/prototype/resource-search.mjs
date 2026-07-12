export function filterResourceItems(items, query) {
  const normalized = String(query || '').trim().toLocaleLowerCase('zh-CN');
  if (!normalized) return items;
  return items.filter((item) => [item.id, item.title, ...(item.terms || [])]
    .some((value) => String(value || '').toLocaleLowerCase('zh-CN').includes(normalized)));
}

