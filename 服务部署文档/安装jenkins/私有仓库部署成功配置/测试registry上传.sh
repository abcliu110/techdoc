#!/bin/bash
# 测试 Registry 上传大小限制

echo "=== 创建一个测试文件（10MB）==="
dd if=/dev/zero of=/tmp/test-10mb.bin bs=1M count=10

echo ""
echo "=== 测试直接上传到 Registry（通过 Nginx）==="
curl -v -X POST \
  -H "Content-Type: application/octet-stream" \
  --data-binary @/tmp/test-10mb.bin \
  http://192.168.80.100:30500/v2/test/blobs/uploads/ \
  2>&1 | grep -E "(HTTP|413|client_max_body_size)"

echo ""
echo "=== 清理测试文件 ==="
rm -f /tmp/test-10mb.bin

echo ""
echo "如果看到 413 错误，说明 Nginx 配置没有生效"
echo "如果看到其他错误（如 404, 401），说明 Nginx 配置已生效，是 Registry 的正常响应"
