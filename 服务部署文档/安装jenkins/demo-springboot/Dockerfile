# 简化版 Dockerfile - 直接使用已构建的 JAR
# 适用于 Jenkins 流水线中已经完成 Maven 构建的场景

# 使用 DaoCloud 镜像源（国内访问更快，无需认证）
FROM m.daocloud.io/docker.io/eclipse-temurin:21-jre-alpine

# 设置时区
ENV TZ=Asia/Shanghai
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# 创建应用目录
WORKDIR /app

# 复制已构建的 jar 包（从 target 目录）
COPY target/*.jar app.jar

# 创建非 root 用户
RUN addgroup -S appuser && adduser -S appuser -G appuser
RUN chown -R appuser:appuser /app
USER appuser

# 暴露端口
EXPOSE 8080

# JVM 参数优化
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
