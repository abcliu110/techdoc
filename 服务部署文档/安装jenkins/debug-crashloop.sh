#!/bin/bash
# 调试 CrashLoopBackOff 问题

echo "=== 1. 查看 Pod 日志 ==="
kubectl logs deployment/demo-springboot --tail=50

echo ""
echo "=== 2. 查看 Pod 详细信息 ==="
kubectl describe pod -l app=demo-springboot | tail -30

echo ""
echo "=== 3. 验证镜像内容 - 检查 JAR 文件是否存在 ==="
kubectl run test-jar-exists \
  --image=192.168.80.100:30500/demo-springboot:latest \
  --restart=Never \
  --command -- ls -la /app/

sleep 5
kubectl logs test-jar-exists
kubectl delete pod test-jar-exists

echo ""
echo "=== 4. 验证镜像内容 - 检查 JAR 文件是否可执行 ==="
kubectl run test-jar-file \
  --image=192.168.80.100:30500/demo-springboot:latest \
  --restart=Never \
  --command -- sh -c "file /app/app.jar && ls -lh /app/app.jar"

sleep 5
kubectl logs test-jar-file
kubectl delete pod test-jar-file

echo ""
echo "=== 5. 尝试手动运行 JAR ==="
kubectl run test-jar-run \
  --image=192.168.80.100:30500/demo-springboot:latest \
  --restart=Never \
  --command -- sh -c "java -jar /app/app.jar --version 2>&1 || echo 'JAR 执行失败'"

sleep 5
kubectl logs test-jar-run
kubectl delete pod test-jar-run

echo ""
echo "=== 6. 检查镜像构建时间 ==="
kubectl run test-image-info \
  --image=192.168.80.100:30500/demo-springboot:latest \
  --restart=Never \
  --command -- sh -c "stat /app/app.jar"

sleep 5
kubectl logs test-image-info
kubectl delete pod test-image-info
