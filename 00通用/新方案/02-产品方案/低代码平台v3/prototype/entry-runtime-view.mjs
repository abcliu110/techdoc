export const DEFAULT_ENTRY_COLUMNS = Object.freeze([
  { id: 'materialCode', label: '物料编码', visible: true, sticky: true },
  { id: 'materialName', label: '物料名称', visible: true, width: 156 },
  { id: 'qty', label: '数量', visible: true, numeric: true, total: true },
  { id: 'unit', label: '单位', visible: true },
  { id: 'warehouse', label: '仓库', visible: true },
  { id: 'taxPrice', label: '含税单价', visible: true, numeric: true },
  { id: 'amount', label: '价税合计', visible: true, numeric: true, total: true },
  { id: 'deliveryDate', label: '交货日期', visible: true },
]);

function finiteNumber(value) {
  const number = Number(value);
  return Number.isFinite(number) ? number : 0;
}

export function createEntryView(rows = [], columns = DEFAULT_ENTRY_COLUMNS) {
  const visibleColumns = columns.filter((column) => column.visible !== false);
  const projectedRows = rows.map((row, index) => ({
    id: row.id || `ROW-${index + 1}`,
    number: index + 1,
    cells: Object.fromEntries(
      visibleColumns.map((column) => [column.id, row.values?.[column.id] ?? '']),
    ),
  }));
  const totals = Object.fromEntries(
    visibleColumns
      .filter((column) => column.total)
      .map((column) => [
        column.id,
        rows.reduce((sum, row) => sum + finiteNumber(row.values?.[column.id]), 0),
      ]),
  );

  return { columns: visibleColumns, rows: projectedRows, totals };
}

export function updateColumnVisibility(columns, columnId, visible) {
  const index = columns.findIndex((column) => column.id === columnId);
  if (index < 0) return columns;
  if (!visible) {
    const visibleCount = columns.filter((column) => column.visible !== false).length;
    if (visibleCount <= 1 && columns[index].visible !== false) return columns;
  }
  return columns.map((column, columnIndex) => (
    columnIndex === index ? { ...column, visible: Boolean(visible) } : column
  ));
}
