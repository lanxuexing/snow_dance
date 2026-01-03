# 如何在小程序中优雅地使用 tailwind-merge

> Date: 2025-01-20
> Category: Guide

在传统的 Web 开发中，`tailwind-merge` 是合并组件样式的利器。但在小程序中，由于类名混淆和特殊字符转换，它往往会失效。

## 核心挑战

小程序插件会将 `.text-red-500` 转换为类似 `.text-red-500_0` 的类名。

## 解决方案

使用我们提供的专用配置适配器。

```typescript
import { createTailwindMerge } from 'tailwind-merge'
import { weappConfig } from 'weapp-tailwindcss/merge'

const twMerge = createTailwindMerge(weappConfig)
```

### 为什么选择这种方式？

- **类型安全**: 完整的 TypeScript 支持。
- **高性能**: 无需复杂的正则表达式转换。
- **标准化**: 沿用 Web 开发的最佳实践。
