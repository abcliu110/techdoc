import { makeObservable, observable, action, computed } from 'mobx';
import { FieldModel } from './FieldModel';
import type { FormField, BOField, BORelation } from '../types';

/**
 * 子表字段模型
 * 管理一对多关系的子表数据
 */
export class SubTableFieldModel extends FieldModel {
  @observable accessor rows: Map<string, Map<string, FieldModel>> = new Map();

  private subTableDef: any; // SubTableDefinition类型
  private relation: BORelation;
  private rowIdCounter: number = 0;

  constructor(
    definition: FormField,
    boField: BOField,
    relation: BORelation,
    formModel: any
  ) {
    super(definition, boField, formModel);

    this.relation = relation;
    this.subTableDef = definition.componentProps?.subTable || {};

    // 初始化默认行
    const defaultRowCount = this.subTableDef.defaultRowCount || 0;
    for (let i = 0; i < defaultRowCount; i++) {
      this.addRow();
    }

    makeObservable(this);
  }

  /**
   * 添加新行
   * @returns 新行的ID
   */
  @action
  addRow(initialData?: any): string {
    const rowId = this.generateRowId();
    const rowFields = new Map<string, FieldModel>();

    // 为每个列创建FieldModel
    if (this.subTableDef.columns) {
      this.subTableDef.columns.forEach((colDef: any) => {
        const fieldModel = new FieldModel(
          colDef,
          colDef.boField || { fieldId: colDef.fieldId, fieldName: colDef.label, fieldType: 'string', dataType: 'varchar', required: false, unique: false },
          this.formModel
        );

        // 设置初始数据
        if (initialData && colDef.fieldId in initialData) {
          fieldModel.setValue(initialData[colDef.fieldId], { silent: true });
        }

        rowFields.set(colDef.fieldId, fieldModel);
      });
    }

    this.rows.set(rowId, rowFields);

    // 重新计算行号
    this.recomputeLineNumbers();

    // 通知变化
    this.notifyChange();

    return rowId;
  }

  /**
   * 删除行
   */
  @action
  deleteRow(rowId: string): void {
    if (this.rows.has(rowId)) {
      this.rows.delete(rowId);
      this.recomputeLineNumbers();
      this.notifyChange();
    }
  }

  /**
   * 获取行的字段
   */
  getRowField(rowId: string, fieldId: string): FieldModel | undefined {
    return this.rows.get(rowId)?.get(fieldId);
  }

  /**
   * 设置行字段的值
   */
  @action
  setRowFieldValue(rowId: string, fieldId: string, value: any): void {
    const field = this.getRowField(rowId, fieldId);
    if (field) {
      field.setValue(value);
      this.notifyChange();
    }
  }

  /**
   * 获取行数据
   */
  getRowData(rowId: string): any {
    const rowFields = this.rows.get(rowId);
    if (!rowFields) return null;

    const data: any = { _rowId: rowId };
    rowFields.forEach((field, fieldId) => {
      data[fieldId] = field.getValue();
    });
    return data;
  }

  /**
   * 获取所有行数据
   */
  override getValue(): any[] {
    const result: any[] = [];
    this.rows.forEach((rowFields, rowId) => {
      result.push(this.getRowData(rowId));
    });
    return result;
  }

  /**
   * 设置所有行数据
   */
  @action
  override setValue(value: any[], options?: { silent?: boolean }): void {
    if (!Array.isArray(value)) {
      value = [];
    }

    // 清空现有行
    this.rows.clear();

    // 创建新行
    value.forEach(rowData => {
      const rowId = rowData._rowId || this.generateRowId();
      const rowFields = new Map<string, FieldModel>();

      if (this.subTableDef.columns) {
        this.subTableDef.columns.forEach((colDef: any) => {
          const fieldModel = new FieldModel(
            colDef,
            colDef.boField || { fieldId: colDef.fieldId, fieldName: colDef.label, fieldType: 'string', dataType: 'varchar', required: false, unique: false },
            this.formModel
          );

          if (colDef.fieldId in rowData) {
            fieldModel.setValue(rowData[colDef.fieldId], { silent: true });
          }

          rowFields.set(colDef.fieldId, fieldModel);
        });
      }

      this.rows.set(rowId, rowFields);
    });

    this.recomputeLineNumbers();

    if (!options?.silent) {
      this.notifyChange();
    }
  }

  /**
   * 获取行数
   */
  @computed
  get rowCount(): number {
    return this.rows.size;
  }

  /**
   * 获取所有行ID
   */
  getRowIds(): string[] {
    return Array.from(this.rows.keys());
  }

  /**
   * 校验所有行
   */
  override async validate(): Promise<boolean> {
    const results: boolean[] = [];

    for (const rowFields of this.rows.values()) {
      for (const field of rowFields.values()) {
        const valid = await field.validate();
        results.push(valid);
      }
    }

    return results.every(r => r);
  }

  /**
   * 重置所有行
   */
  @action
  override reset(): void {
    this.rows.forEach(rowFields => {
      rowFields.forEach(field => field.reset());
    });
  }

  /**
   * 清空所有行
   */
  @action
  clear(): void {
    this.rows.clear();
    this.notifyChange();
  }

  /**
   * 移动行
   */
  @action
  moveRow(fromIndex: number, toIndex: number): void {
    const rowIds = this.getRowIds();
    if (fromIndex < 0 || fromIndex >= rowIds.length || toIndex < 0 || toIndex >= rowIds.length) {
      return;
    }

    const newRows = new Map<string, Map<string, FieldModel>>();
    const newOrder = [...rowIds];
    const [movedId] = newOrder.splice(fromIndex, 1);
    newOrder.splice(toIndex, 0, movedId);

    newOrder.forEach(rowId => {
      const rowFields = this.rows.get(rowId);
      if (rowFields) {
        newRows.set(rowId, rowFields);
      }
    });

    this.rows = newRows;
    this.recomputeLineNumbers();
    this.notifyChange();
  }

  /**
   * 生成行ID
   */
  private generateRowId(): string {
    return `row_${Date.now()}_${++this.rowIdCounter}`;
  }

  /**
   * 重新计算行号
   */
  @action
  private recomputeLineNumbers(): void {
    let lineNum = 1;
    this.rows.forEach(rowFields => {
      const lineNumField = rowFields.get('lineNum');
      if (lineNumField) {
        lineNumField.setValue(lineNum++, { silent: true });
      }
    });
  }

  /**
   * 通知表单模型数据变化
   */
  private notifyChange(): void {
    if (this.formModel?.notifyFieldChange) {
      this.formModel.notifyFieldChange(this.fieldId, null, this.getValue());
    }
  }

  /**
   * 获取所有错误
   */
  getAllErrors(): Map<string, Map<string, string[]>> {
    const errors = new Map<string, Map<string, string[]>>();

    this.rows.forEach((rowFields, rowId) => {
      const rowErrors = new Map<string, string[]>();
      rowFields.forEach((field, fieldId) => {
        if (field.errors.length > 0) {
          rowErrors.set(fieldId, field.errors);
        }
      });

      if (rowErrors.size > 0) {
        errors.set(rowId, rowErrors);
      }
    });

    return errors;
  }

  /**
   * 检查是否有错误
   */
  hasErrors(): boolean {
    for (const rowFields of this.rows.values()) {
      for (const field of rowFields.values()) {
        if (field.errors.length > 0) {
          return true;
        }
      }
    }
    return false;
  }
}
