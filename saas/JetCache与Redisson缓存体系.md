# JetCache 与 Redisson 缓存体系

> 项目路径：`D:\mywork\nms4pos`
> 使用模块：pos1starter
> 最后更新：2026-04-30

---

## 一、组件概述

nms4pos 的缓存体系分为两层：

- **JetCache**（`com.alicp.jetcache:jetcache-starter-redisson`）：分布式缓存抽象层，提供 `@Cacheable`、`@CacheUpdate`、`@CacheInvalidate` 等注解
- **Redisson**（`org.redisson:redisson-spring-boot-starter`）：Redis 客户端，提供分布式锁、布隆过滤器、Set/Map 等数据结构

两者配合：JetCache 负责缓存抽象和自动刷新，Redisson 提供底层 Redis 连接能力。

---

## 二、Maven 依赖

**pos1starter**（`nms4cloud-pos1starter/pom.xml`）：

```xml
<!-- JetCache（Redis 驱动版） -->
<dependency>
    <groupId>com.alicp.jetcache</groupId>
    <artifactId>jetcache-starter-redisson</artifactId>
    <version>2.7.6</version>
</dependency>

<!-- Redisson（分布式锁和数据结构） -->
<dependency>
    <groupId>org.redisson</groupId>
    <artifactId>redisson-spring-boot-starter</artifactId>
    <version>3.26.0</version>
</dependency>

<!-- Sa-Token Redis 存储（使用 Jackson 序列化） -->
<dependency>
    <groupId>cn.dev33</groupId>
    <artifactId>sa-token-dao-redis-jackson</artifactId>
    <version>1.34.0</version>
</dependency>
```

---

## 三、JetCache 使用方式

### 3.1 启用缓存

```java
// 启动类或配置类
@EnableMethodCache(basePackages = "com.nms4cloud.pos")
@EnableCreateCacheAnnotation
@Configuration
public class CacheConfig {
    // JetCache 会自动装配，读取 application.yml 中的 redis 配置
}
```

### 3.2 配置文件

```yaml
# application.yml
jetcache:
  statIntervalMinutes: 15          # 缓存统计间隔（分钟）
  areaInCacheName: false           # 缓存名称不包含 area 前缀
  local:
    default:
      type: linkedhashmap         # 本地缓存实现（内存 LRU）
      limit: 1000                  # 最大缓存条目数
      keyConvertor: fastjson        # Key 转换器
  remote:
    default:
      type: redis                  # 分布式缓存（Redis）
      keyConvertor: fastjson
      valueEncoder: java           # 值编码方式
      valueDecoder: java
      poolConfig:
        minIdle: 5
        maxIdle: 20
        maxTotal: 50
      host: ${REDIS_HOST:127.0.0.1}
      port: ${REDIS_PORT:6379}
```

### 3.3 方法级缓存

```java
import com.alicp.jetcache.annotation.Cache;
import com.alicp.jetcache.annotation.CacheInvalidate;
import com.alicp.jetcache.annotation.CacheUpdate;

// 查询菜品（自动缓存，TTL=10分钟）
@Cache(name = "dish:", expire = 600, cacheType = CacheType.BOTH)
public Dish getDishById(Long dishId) {
    return dishMapper.selectById(dishId);
}

// 更新菜品（同时更新本地和 Redis）
@CacheUpdate(name = "dish:", key = "#dish.id", value = "#dish")
public void updateDish(Dish dish) {
    dishMapper.updateById(dish);
}

// 删除菜品（清除缓存）
@CacheInvalidate(name = "dish:", key = "#dishId")
public void deleteDish(Long dishId) {
    dishMapper.deleteById(dishId);
}

// 批量查询（缓存未命中时批量加载）
@Cache(name = "dish:", expire = 600, cacheType = CacheType.BOTH)
public List<Dish> getDishByIds(List<Long> dishIds) {
    return dishMapper.selectBatchIds(dishIds);
}
```

### 3.4 缓存刷新

```java
// 自动刷新（缓存过期前主动刷新，避免击穿）
@CacheRefresh(
    refreshLock = 60,        // 刷新锁（防止并发刷新）
    refreshInterval = 300,  // 每 5 分钟检查一次
    stopRefreshAfterLastAccess = 3600  // 1 小时无访问后停止刷新
)
@Cache(name = "config:", expire = 3600)
public StoreConfig getStoreConfig(Long storeId) {
    return configMapper.selectByStoreId(storeId);
}
```

---

## 四、Redisson 使用方式

### 4.1 分布式锁

```java
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;

@Service
public class PrintService {

    @Autowired
    private RedissonClient redisson;

    public void printWithLock(String orderNo, Runnable printTask) {
        String lockKey = "lock:print:" + orderNo;
        RLock lock = redisson.getLock(lockKey);

        // 尝试获取锁（等待 10 秒，持有 60 秒后自动释放）
        boolean locked = lock.tryLock(10, 60, TimeUnit.SECONDS);
        if (!locked) {
            throw new BizException("打印机正忙，请稍后重试");
        }

        try {
            printTask.run();
        } finally {
            lock.unlock();
        }
    }
}
```

### 4.2 分布式计数器（库存扣减）

```java
import org.redisson.api.RAtomicLong;

public boolean decrementStock(Long dishId, int count) {
    String key = "stock:dish:" + dishId;
    RAtomicLong stock = redisson.getAtomicLong(key);

    // 乐观锁扣减（失败重试 3 次）
    for (int i = 0; i < 3; i++) {
        long current = stock.get();
        if (current < count) {
            return false; // 库存不足
        }
        if (stock.compareAndSet(current, current - count)) {
            return true; // 扣减成功
        }
    }
    return false;
}
```

### 4.3 分布式 Map（配置缓存）

```java
import org.redisson.api.RMap;

public Map<String, Object> getStoreConfigMap(Long storeId) {
    RMap<String, Object> map = redisson.getMap("config:store:" + storeId);

    // 自动从数据库加载（懒加载）
    if (map.isEmpty()) {
        StoreConfig config = storeConfigMapper.selectByStoreId(storeId);
        map.putAll(BeanUtil.beanToMap(config));
    }
    return map;
}
```

### 4.4 布隆过滤器（去重）

```java
import org.redisson.api.RBloomFilter;

// 初始化布隆过滤器（预估 100 万订单，误判率 0.01）
RBloomFilter<String> filter = redisson.getBloomFilter("order:dup-check");
filter.tryInit(1_000_000, 0.01);

public boolean checkDuplicateOrder(String orderNo) {
    if (filter.contains(orderNo)) {
        // 布隆过滤器说可能存在，需要二次确认（查库）
        return orderMapper.exists(orderNo);
    }
    // 一定不存在，加入过滤器
    filter.add(orderNo);
    return false;
}
```

---

## 五、缓存 Key 命名规范

| Key Pattern | 类型 | 用途 |
|-------------|------|------|
| `dish:{id}` | Hash | 菜品信息缓存 |
| `order:{id}` | String | 订单详情缓存 |
| `stock:dish:{id}` | AtomicLong | 菜品实时库存 |
| `lock:print:{orderNo}` | Lock | 打印分布式锁 |
| `lock:pay:{orderNo}` | Lock | 支付分布式锁 |
| `akToken` | String | 阿里云 NLS Token |
| `config:store:{id}` | Hash | 门店配置缓存 |

---

## 六、相关文档

- [nms4pos第三方组件使用详情](./nms4pos第三方组件使用详情.md)
