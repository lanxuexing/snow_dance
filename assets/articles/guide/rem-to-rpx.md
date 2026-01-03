# 插件内置 rem 转 rpx 功能 (推荐)

> Date: 2024-03-20
> Category: Guide

在 `^3.0.0` 版本中，所有插件都内置了 `rem2rpx` 参数，默认不开启，要启用它只需将它设置成 `true` 即可。

```javascript
// vite.config.js
import { UnifiedViteWeappTailwindcssPlugin } from 'weapp-tailwindcss/vite'
UnifiedViteWeappTailwindcssPlugin({
  // ...other-options
  rem2rpx: true
})
```

设置为 `true` 相当于 `rem2rpx` 传入下方这样一个配置对象：

```json
{
  // 32 意味着 1rem = 16px = 32rpx
  rootValue: 32,
  // 默认所有属性都转化
  propList: ['*'],
  // 转化的单位,可以变成 px / rpx
  transformUnit: 'rpx'
}
```

> **提示**
> 为什么 rootValue 默认值是 32？
> 这是因为开发微信小程序时，设计师基本都使用 iPhone6 作为视觉稿的标准，此时 1px = 2rpx。
> 然后默认情况下 1rem = 16px, 所以 1rem = 16px = 32rpx。

## 优势

这种方式 **最简单**，和插件集成度高，传入一个配置就好。

### 自动化
只需一次配置，全局生效。

### 灵活性
可根据不同项目需求调整 `rootValue`。
