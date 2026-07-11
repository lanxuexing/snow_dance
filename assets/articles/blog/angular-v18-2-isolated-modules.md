---
title: 在 Angular 18.2 中启用 isolatedModules：编译速度提升达 10%
date: 2024-08-19
category: Blog
excerpt: 从 Angular 18.2 开始，官方增加了对 TypeScript isolatedModules 编译配置的全面支持。当在构建配置中激活这一模式后，生产打包构建速度能够获得高达 10% 的性能提升！本文为你讲解其背后的 esbuild 优化原理与配置方式。
---

# 在 Angular 18.2 中启用 isolatedModules：编译速度提升达 10%

Angular 官方博客宣布在 **Angular 18.2** 中正式支持 TypeScript 的 `isolatedModules` 配置。

这一看似简单的配置，在大型项目的生产构建中，能够带来高达 **10% 的打包构建速度飞跃**。

接下来，我们将为您拆解这一新特性是如何工作的，以及如何快速在您已有的 Angular 18.2+ 项目中完成配置。

---

## ⚡ 1. isolatedModules 是什么？它如何加速构建？

在传统的编译流水线中，TypeScript 编译器（`tsc`）通常需要进行完整的类型检查（Type Checking）来确定如何转换代码。这导致跨文件分析十分耗时。

而当在 `tsconfig.json` 中开启 `"isolatedModules": true` 时，TypeScript 会强制限制那些需要跨文件上下文才能进行转译的语法。这就意味着：**每个 `.ts` 文件都可以被安全地当做一个“孤立的模块”进行单文件独立转译（Transpile）**。

因此，Angular 在应用构建器（Application Builder）中可以做出以下重磅优化：
1.  **打包工具（Bundler）直接转译**：在禁用 Sourcemap 且开启该选项时，Angular 底层直接调用底层是用 Go 编写的高性能打包器 **`esbuild`** 来并行转译 TS 代码，替代原先依靠 TypeScript 逐个文件分析的处理方式。
2.  **优化常数与普通 Enum 导出**：`esbuild` 现在能够更彻底地内联（Inline）常数与普通 `enum`，大大优化转译后的 JS 体积。
3.  **干掉 Babel 的转译优化损耗**：对于常规的 TypeScript 代码，现在可以直接免去原本 Babel 所承担的转译优化处理路径（但在加载来自第三方库的 JavaScript 代码时，Babel 仍会按需参与运行）。

通过减少类型检查阻塞以及用高性能编译工具平替，大型项目能够直接斩获高达 10% 的生产构建（Production Build）编译提速。

---

## ⚙️ 2. 如何在项目中开启这一优化？

要享受这一性能红利，您只需要对项目根目录下的 **`tsconfig.json`** 进行一处小改动。

打开 `tsconfig.json` 并确保在 `compilerOptions` 段落中设置 `"isolatedModules": true`：

```json
{
  "compilerOptions": {
    "isolatedModules": true,
    "useDefineForClassFields": true
  }
}
```

> [!TIP]
> **关于 `useDefineForClassFields` 的配置建议：**
> 为了保障在该模式下转译出的类字段行为和 ECMAScript 原生标准完美契合，且最大化缩小产物体积，官方强烈建议在 `compilerOptions` 中将 `useDefineForClassFields` 设置为 `true` 或直接移除（采用默认值）。

---

## 🏁 结语

在 Angular 逐步转向 `esbuild` 与 `Vite` 作为底层打包套件的浪潮中，支持 `isolatedModules` 是完全释放底层打包引擎速度的关键拼图。

建议所有使用 Angular 18.2 及以上版本的项目立即尝试这一配置，体验更丝滑的命令行打包流程。
