FROM eclipse-temurin:21-jre

COPY target/*.jar app.jar
COPY src/main/resources/*   config/

# 暴露端口
EXPOSE 8080

# JVM 参数优化
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 启动命令
ENTRYPOINT ["java","-jar","/app.jar"]