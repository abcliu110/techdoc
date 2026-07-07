import React from 'react';
import { Table, Button } from 'antd';

export interface SubTableComponentProps {
  value?: any[];
  onChange?: (value: any[]) => void;
  columns: any[];
  disabled?: boolean;
}

export const SubTableComponent: React.FC<SubTableComponentProps> = ({
  value = [],
  onChange,
  columns,
  disabled,
}) => {
  const handleAdd = () => {
    const newRow = {};
    onChange?.([...value, newRow]);
  };

  const handleDelete = (index: number) => {
    const newValue = value.filter((_, i) => i !== index);
    onChange?.(newValue);
  };

  return (
    <div>
      <Table
        dataSource={value}
        columns={[
          ...columns,
          {
            title: '操作',
            render: (_, __, index) => (
              <Button danger size="small" onClick={() => handleDelete(index)} disabled={disabled}>
                删除
              </Button>
            ),
          },
        ]}
        pagination={false}
      />
      <Button type="dashed" onClick={handleAdd} disabled={disabled} style={{ marginTop: 8 }}>
        + 添加行
      </Button>
    </div>
  );
};
