#!/bin/bash
# Nexus 诊断脚本

echo "=== 1. 检查 Pod 详情 ==="
kubectl describe pod -n nexus -l app=nexus

echo ""
echo "=== 2. 检查 PVC 状态 ==="
kubectl get pvc -n nexus

echo ""
echo "=== 3. 检查 PV 状态 ==="
kubectl get pv | grep nexus

echo ""
echo "=== 4. 检查 Events ==="
kubectl get events -n nexus --sort-by='.lastTimestamp' | tail -20

echo ""
echo "=== 5. 检查 StorageClass ==="
kubectl get storageclass local-path
