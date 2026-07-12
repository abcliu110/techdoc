# OpenAPI HTTP 门禁自测

## 目的

这套自测夹具用于证明发布门禁不是“只校验文件存在”的占位脚本，而是会真的从 Java controller 源码里提取 HTTP 路由。

## 夹具内容

- `lowcode-app/src/test/resources/http-route-selfcheck/controllers/DirectMappingController.java`
  - 验证脚本能自动发现新增 controller 文件。
- `lowcode-app/src/test/resources/http-route-selfcheck/controllers/PrefixedMappingController.java`
  - 验证脚本能识别 class-level `@RequestMapping` 和 method-level `@PostMapping` 的简单组合。
- `docs/compliance/openapi-http-selfcheck-baseline.txt`
  - 自测期望路由清单。

## 运行方式

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-placeholder-gates.ps1 -SelfCheck
```

## 通过标准

- 输出 `OpenAPI HTTP self-check passed.`。
- 如果新增 controller 未被发现，或 class-level + method-level 路由没有被正确拼接，自测必须失败。
