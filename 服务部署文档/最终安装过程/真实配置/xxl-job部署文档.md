# XXL-Job 部署文档

## 一、前置条件

- Kubernetes 集群正常运行（本文基于 RKE2）
- 已有 MySQL 数据库（8.0），部署在 `nms4cloud` namespace
- 私有镜像仓库：`192.168.1.119:30020`
- xxl-job 部署在 `nms4cloud` namespace，与 MySQL 同命名空间，可使用短域名 `mysql` 访问

---

## 二、推送镜像到私有仓库

在能访问外网的机器上执行：

```bash
# 1. 拉取官方镜像
docker pull xuxueli/xxl-job-admin:2.4.1

# 2. 打标签（必须带私有仓库地址）
docker tag xuxueli/xxl-job-admin:2.4.1 192.168.1.119:30020/library/xxl-job-admin:2.4.1

# 3. 推送
docker push 192.168.1.119:30020/library/xxl-job-admin:2.4.1
```

> 注意：Docker 需配置 insecure-registries，否则推送会报 TLS 错误。
> Docker Desktop → Settings → Docker Engine，添加：
> ```json
> {
>   "insecure-registries": ["192.168.1.119:30020"]
> }
> ```

---

## 三、初始化数据库

### 1. 进入 MySQL 容器

在 Rancher 控制台找到 `mysql` Pod → 远程登录，执行：

```bash
mysql -u root -p
```

### 2. 执行初始化脚本

> 每张表先删除再创建，适用于全新安装或版本升级重建。

```sql
CREATE DATABASE IF NOT EXISTS `xxl_job` DEFAULT CHARACTER SET utf8mb4;
USE `xxl_job`;

DROP TABLE IF EXISTS `xxl_job_info`;
CREATE TABLE `xxl_job_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_group` int(11) NOT NULL COMMENT '执行器主键ID',
  `job_desc` varchar(255) NOT NULL,
  `add_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `author` varchar(64) DEFAULT NULL COMMENT '负责人',
  `alarm_email` varchar(255) DEFAULT NULL COMMENT '报警邮件',
  `schedule_type` varchar(50) NOT NULL DEFAULT 'NONE' COMMENT '调度类型',
  `schedule_conf` varchar(128) DEFAULT NULL COMMENT '调度配置，值含义取决于调度类型',
  `misfire_strategy` varchar(50) NOT NULL DEFAULT 'DO_NOTHING' COMMENT '调度过期策略',
  `executor_route_strategy` varchar(50) DEFAULT NULL COMMENT '执行器路由策略',
  `executor_handler` varchar(255) DEFAULT NULL COMMENT '执行器任务handler',
  `executor_param` varchar(512) DEFAULT NULL COMMENT '执行器任务参数',
  `executor_block_strategy` varchar(50) DEFAULT NULL COMMENT '阻塞处理策略',
  `executor_timeout` int(11) NOT NULL DEFAULT '0' COMMENT '任务执行超时时间，单位秒',
  `executor_fail_retry_count` int(11) NOT NULL DEFAULT '0' COMMENT '失败重试次数',
  `glue_type` varchar(50) NOT NULL COMMENT 'GLUE类型',
  `glue_source` mediumtext COMMENT 'GLUE源代码',
  `glue_remark` varchar(128) DEFAULT NULL COMMENT 'GLUE备注',
  `glue_updatetime` datetime DEFAULT NULL COMMENT 'GLUE更新时间',
  `child_jobid` varchar(255) DEFAULT NULL COMMENT '子任务ID，多个逗号分隔',
  `trigger_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '调度状态：0-停止，1-运行',
  `trigger_last_time` bigint(13) NOT NULL DEFAULT '0' COMMENT '上次调度时间',
  `trigger_next_time` bigint(13) NOT NULL DEFAULT '0' COMMENT '下次调度时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `xxl_job_log`;
CREATE TABLE `xxl_job_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `job_group` int(11) NOT NULL COMMENT '执行器主键ID',
  `job_id` int(11) NOT NULL COMMENT '任务，主键ID',
  `executor_address` varchar(255) DEFAULT NULL COMMENT '执行器地址，本次执行的地址',
  `executor_handler` varchar(255) DEFAULT NULL COMMENT '执行器任务handler',
  `executor_param` varchar(512) DEFAULT NULL COMMENT '执行器任务参数',
  `executor_sharding_param` varchar(20) DEFAULT NULL COMMENT '执行器任务分片参数，格式如 1/2',
  `executor_fail_retry_count` int(11) NOT NULL DEFAULT '0' COMMENT '失败重试次数',
  `trigger_time` datetime DEFAULT NULL COMMENT '调度-时间',
  `trigger_code` int(11) NOT NULL COMMENT '调度-结果',
  `trigger_msg` text COMMENT '调度-日志',
  `handle_time` datetime DEFAULT NULL COMMENT '执行-时间',
  `handle_code` int(11) NOT NULL COMMENT '执行-状态',
  `handle_msg` text COMMENT '执行-日志',
  `alarm_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '告警状态：0-默认、1-无需告警、2-告警成功、3-告警失败',
  PRIMARY KEY (`id`),
  KEY `I_trigger_time` (`trigger_time`),
  KEY `I_handle_code` (`handle_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `xxl_job_log_report`;
CREATE TABLE `xxl_job_log_report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `trigger_day` datetime DEFAULT NULL COMMENT '调度-时间',
  `running_count` int(11) NOT NULL DEFAULT '0' COMMENT '运行中-日志数量',
  `suc_count` int(11) NOT NULL DEFAULT '0' COMMENT '执行成功-日志数量',
  `fail_count` int(11) NOT NULL DEFAULT '0' COMMENT '执行失败-日志数量',
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `i_trigger_day` (`trigger_day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `xxl_job_logglue`;
CREATE TABLE `xxl_job_logglue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL COMMENT '任务，主键ID',
  `glue_type` varchar(50) DEFAULT NULL COMMENT 'GLUE类型',
  `glue_source` mediumtext COMMENT 'GLUE源代码',
  `glue_remark` varchar(128) NOT NULL COMMENT 'GLUE备注',
  `add_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `xxl_job_registry`;
CREATE TABLE `xxl_job_registry` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `registry_group` varchar(50) NOT NULL,
  `registry_key` varchar(255) NOT NULL,
  `registry_value` varchar(255) NOT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `i_g_k_v` (`registry_group`,`registry_key`,`registry_value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `xxl_job_group`;
CREATE TABLE `xxl_job_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_name` varchar(64) NOT NULL COMMENT '执行器AppName',
  `title` varchar(12) NOT NULL COMMENT '执行器名称',
  `address_type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '执行器地址类型：0=自动注册、1=手动录入',
  `address_list` text COMMENT '执行器地址列表，多地址逗号分隔',
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `xxl_job_user`;
CREATE TABLE `xxl_job_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL COMMENT '账号',
  `password` varchar(50) NOT NULL COMMENT '密码',
  `role` tinyint(4) NOT NULL COMMENT '角色：0-普通用户、1-管理员',
  `permission` varchar(255) DEFAULT NULL COMMENT '权限：执行器ID列表，多个逗号分割',
  PRIMARY KEY (`id`),
  UNIQUE KEY `i_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `xxl_job_lock`;
CREATE TABLE `xxl_job_lock` (
  `lock_name` varchar(50) NOT NULL COMMENT '锁名称',
  PRIMARY KEY (`lock_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `xxl_job_group`(`id`, `app_name`, `title`, `address_type`, `address_list`, `update_time`)
  VALUES (1, 'xxl-job-executor-sample', '示例执行器', 0, NULL, '2018-11-03 22:21:31');
INSERT INTO `xxl_job_info`(`id`, `job_group`, `job_desc`, `add_time`, `update_time`, `author`, `alarm_email`, `schedule_type`, `schedule_conf`, `misfire_strategy`, `executor_route_strategy`, `executor_handler`, `executor_param`, `executor_block_strategy`, `executor_timeout`, `executor_fail_retry_count`, `glue_type`, `glue_source`, `glue_remark`, `glue_updatetime`, `child_jobid`, `trigger_status`, `trigger_last_time`, `trigger_next_time`)
  VALUES (1, 1, '测试任务1', '2018-11-03 22:21:31', '2018-11-03 22:21:31', 'XXL', '', 'CRON', '0 0 0 * * ? *', 'DO_NOTHING', 'FIRST', 'demoJobHandler', '', 'SERIAL_EXECUTION', 0, 0, 'BEAN', '', 'GLUE代码初始化', '2018-11-03 22:21:31', '', 0, 0, 0);
INSERT INTO `xxl_job_user`(`id`, `username`, `password`, `role`, `permission`)
  VALUES (1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL);
INSERT INTO `xxl_job_lock` (`lock_name`) VALUES ('schedule_lock');
```

### 3. 验证

```sql
USE xxl_job;
SHOW TABLES;
-- 应显示 7 张表
```

---

## 四、创建 Secret

```bash
kubectl create secret generic xxl-job-secret \
  --from-literal=db-password='your_db_password' \
  --from-literal=access-token='your_access_token' \
  -n nms4cloud
```

---

## 五、部署文件

### 1. Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: xxl-job
  namespace: nms4cloud
  labels:
    app: xxl-job
spec:
  replicas: 1
  selector:
    matchLabels:
      app: xxl-job
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: xxl-job
    spec:
      imagePullSecrets:
        - name: docker-secret
      containers:
        - name: xxl-job
          image: 192.168.1.119:30020/library/xxl-job-admin:2.4.1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8080
          env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: xxl-job-secret
                  key: db-password
            - name: ACCESS_TOKEN
              valueFrom:
                secretKeyRef:
                  name: xxl-job-secret
                  key: access-token
            - name: PARAMS
              value: >-
                --spring.datasource.url=jdbc:mysql://mysql:3306/xxl_job?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true&serverTimezone=Asia/Shanghai
                --spring.datasource.username=root
                --spring.datasource.password=$(DB_PASSWORD)
                --xxl.job.accessToken=$(ACCESS_TOKEN)
          resources:
            requests:
              cpu: 250m
              memory: 512Mi
            limits:
              cpu: 500m
              memory: 1Gi
          livenessProbe:
            httpGet:
              path: /xxl-job-admin/actuator/health
              port: 8080
            initialDelaySeconds: 120
            periodSeconds: 10
            failureThreshold: 5
          readinessProbe:
            httpGet:
              path: /xxl-job-admin/actuator/health
              port: 8080
            initialDelaySeconds: 90
            periodSeconds: 10
            failureThreshold: 5
          securityContext:
            privileged: false
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
```

### 2. Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: xxl-job
  namespace: nms4cloud
  labels:
    app: xxl-job
spec:
  selector:
    app: xxl-job
  ports:
    - name: http
      port: 8080
      targetPort: 8080
  type: ClusterIP
```

### 3. Ingress（可选，外网访问）

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: xxl-job-ingress
  namespace: nms4cloud
spec:
  rules:
    - host: xxl-job.your-domain.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: xxl-job
                port:
                  number: 8080
```

---

## 六、部署执行

```bash
kubectl apply -f xxl-job-deployment.yaml
kubectl apply -f xxl-job-service.yaml
kubectl apply -f xxl-job-ingress.yaml   # 可选

# 查看部署状态
kubectl get pods -n nms4cloud | grep xxl-job
kubectl logs -f <xxl-job-pod-name> -n nms4cloud
```

---

## 七、验证部署

```bash
# 确认 Pod 正常运行
kubectl get pods -n nms4cloud | grep xxl-job

# 端口转发到本地验证
kubectl port-forward svc/xxl-job 8080:8080 -n nms4cloud
```

浏览器访问：
```
http://localhost:8080/xxl-job-admin
```

默认账号：`admin` / `123456`，**登录后立即修改密码**

---

## 八、业务服务接入

每个需要使用定时任务的业务服务，在 Nacos 或本地配置中添加：

```properties
# xxl-job 配置
xxl.job.admin.addresses=http://xxl-job:8080/xxl-job-admin
xxl.job.accessToken=your_access_token
xxl.job.executor.appname=your-app-executor
xxl.job.executor.port=9999
xxl.job.executor.logpath=/data/applogs/xxl-job/jobhandler
xxl.job.executor.logretentiondays=30
```

> 业务服务若在 `nms4cloud` namespace，直接用 `xxl-job` 短域名即可。
> 若在其他 namespace，使用完整域名：`xxl-job.nms4cloud.svc.cluster.local`

---

## 九、常见问题

| 问题 | 原因 | 解决 |
|------|------|------|
| 镜像拉取失败 ErrImagePull | 私有仓库无镜像或地址错误 | 提前 tag 并 push 镜像到私有仓库 |
| 镜像拉取失败 TLS 错误 | Docker 未信任私有仓库 | 配置 insecure-registries |
| UnknownHostException: mysql | 跨 namespace 无法解析短域名 | 部署到同一 namespace 或使用完整域名 |
| Table 'xxl_job.xxx' doesn't exist | 数据库表未初始化或版本不匹配 | 执行第三步的建表 SQL（含 DROP） |
| Unknown column 'schedule_type' | 旧版本表结构与新版程序不兼容 | 重新执行建表脚本（DROP + CREATE） |
| OOMKilled | 内存限制太小 | 将 memory limits 调整为 1Gi 以上 |
| Readiness probe failed | 启动慢或数据库连接失败 | 增大 initialDelaySeconds，查看日志确认根因 |
| 执行器注册失败 | accessToken 不一致 | 确认调度中心和执行器两端 token 相同 |
