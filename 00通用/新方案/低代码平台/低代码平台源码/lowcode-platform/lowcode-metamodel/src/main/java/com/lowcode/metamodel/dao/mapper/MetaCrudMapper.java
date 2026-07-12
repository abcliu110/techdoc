package com.lowcode.metamodel.dao.mapper;

import java.util.Optional;

/**
 * T-002 元数据表的最小单表 Mapper 契约。
 *
 * <p>这里仅定义接口契约，刻意不包含动态 SQL、API DTO 和 JSON 升级逻辑。后续 MyBatis/JDBC 实现这些方法时，
 * 必须保留 tenantId 绑定和 revision 校验。
 *
 * @param <E> 映射到单张静态元数据表的实体类型
 */
public interface MetaCrudMapper<E> {

  /**
   * 插入一行元数据。
   *
   * <p>调用方必须在调用前填充 id、tenantId、审计列、revision、deleted 和 deleteToken。Mapper 不得自行发明运行时默认值，
   * 也不能掩盖缺失租户数据的问题。
   */
  int insert(E entity);

  /**
   * 按主键、租户 ID 和当前版本更新一行元数据。
   *
   * <p>方法名刻意写得明确，因为元数据编辑必须受乐观锁保护；普通 updateById 容易让后续服务代码出现丢失更新。
   */
  int updateByIdAndRevision(E entity);

  /**
   * 按租户 ID 和主键读取一行数据。
   *
   * <p>即使是主键查询也必须传 tenantId，防止后续实现出现跨租户读取捷径。
   */
  Optional<E> findById(Long tenantId, Long id);

  /**
   * 在租户隔离和乐观锁保护下软删除一行数据。
   *
   * <p>deleteToken 显式传入，是为了让唯一索引保留历史墓碑行，同时不依赖 nullable deleted_at 语义。
   */
  int softDeleteByIdAndRevision(Long tenantId, Long id, Long revision, Long deleteToken);
}
