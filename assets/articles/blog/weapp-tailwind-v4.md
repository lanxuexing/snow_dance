# weapp-tailwindcss v4.0.0 正式发布!

> Date: 2024-03-01
> Category: Blog

weapp-tailwindcss v4.0 正式发布，核心亮点是兼容 `tailwindcss@4` 并引入 `tailwind-merge` 运行时整合能力。

## 核心更新

1.  **支持 tailwindcss@4.x 版本**
2.  **支持 tailwind-merge**

因为 `tailwindcss@4` 策略变成了一个单体式预处理器，这在之前是相当大的。目前 `weapp-tailwindcss` 核心代码库服务 `tailwindcss 4, 3, 2` 三个版本了。

### 如何升级
只需更新包版本并修改 `postcss.config.js` 或者你的框架配置。

### 性能提升
由于采用了新的编译引擎，构建速度提升了约 30%。

想快速上手验证？欢迎访问 [weapp-tailwindcss 官网](https://weapp-tw.netlify.app/)！
