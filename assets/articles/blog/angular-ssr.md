# Angular SSR 全面指南

> Date: 2025-03-23
> Category: Blog

服务器端渲染（SSR）已经成为现代 Web 应用提升性能与 SEO 的关键技术。随着 Angular 在 SSR、混合渲染 (Hybrid Rendering) 及增量 Hydration 方面的演进，这篇文章将带你从入门到实战掌握 Angular SSR 的核心概念、配置步骤与高级实践。 ([ANGULARarchitects][1])

---

## 🚀 什么是 SSR？

**Server-Side Rendering (SSR)** 是一种让服务器预先渲染应用页面 HTML 的技术，而不是等浏览器下载 JS 再执行渲染。这样做带来：

* ⚡ 更快的首次渲染性能（用户更早看到内容）
* 🔍 更好的 SEO 和爬虫抓取支持
* 📦 更友好的社交分享预览与元数据渲染

在 Angular 中，这一能力由 `@angular/ssr`（前身 Angular Universal）实现。 ([ANGULARarchitects][1])

---

## 📦 如何启用 SSR

### 新项目

创建新项目时，Angular CLI 会提示开启 SSR：

```bash
ng new your-fancy-app-name
```

如果想手动开启：

```bash
ng new your-fancy-app-name --ssr
```

### 现有项目

在已存在项目中添加 SSR：

```bash
ng add @angular/ssr
```

⚠️ 添加后可能需要修复部分依赖或配置，特别是 CommonJS 依赖导入。 ([ANGULARarchitects][1])

---

## 🔍 静态站点生成 (SSG)

SSR 的一种特殊场景称为 **静态站点生成 (SSG)**，也叫预渲染：

* 在构建时预生成 HTML 文件
* 不需要 Node.js 运行环境
* 可直接部署到静态托管服务（如 Nginx、Netlify）

这种方式适合内容相对固定的页面。 ([ANGULARarchitects][1])

---

## 🔄 Hydration 概念

SSR 生成了静态 HTML，但浏览器还是需要让页面变得 *可交互*。
这一步称为 **Hydration**：

* 浏览器加载 SSR HTML
* Angular 加载 JS 并附加事件监听等行为

在 Angular v17 起，Hydration 功能已经稳定，并且在 v19 引入了增强型 **Incremental Hydration**。 ([ANGULARarchitects][1])

---

## 🧠 高级特性

### 🧩 混合渲染 (Hybrid Rendering)

Angular v19 引入混合渲染：

* 有些路由用 SSR
* 有些用 SSG
* 还有些保持 CSR

通过配置不同的渲染模式，可以针对业务需求优化页面体验。 ([ANGULARarchitects][1])

---

### ⏱ Incremental Hydration

增量 Hydration 是一种让页面在需要时有选择地 Hydrate 部分内容的技术，有效降低加载峰值资源。

例如：

```ts
export const appConfig: ApplicationConfig = {
  providers: [
    provideClientHydration(withIncrementalHydration()),
  ],
};
```

这样 Angular 会根据触发条件逐步附加交互行为，而不是一次性 Hydrate 全部组件。 ([ANGULARarchitects][1])

---

### 🚦 Deferrable Views

结合 `@defer` 语法，Angular 可以延迟加载某些组件或区域内容直到满足条件（如进入视口等）。这在 SSR 场景中能进一步提升页面首屏性能。 ([ANGULARarchitects][1])

---

## 🛠 常见 SSR 配置文件简介

下面是 Angular SSR 架构中关键信息文件（CLI 自动生成）：

| 文件                     | 作用                 |
| ---------------------- | ------------------ |
| `main.server.ts`       | SSR 入口 bootstrap   |
| `server.ts`            | Node/Express 服务器设置 |
| `app.config.server.ts` | 服务器专用配置            |
| `app.routes.server.ts` | SSR 与 SSG 路由策略配置   |

你可以借助这些文件对渲染行为做更精细的调整。 ([ANGULARarchitects][1])

---

## 🛠 构建与部署

### 构建

```bash
pnpm build:ssr
ng build && ng run your-fancy-app-name:server
```

### 运行 SSR

```bash
node dist/your-fancy-app-name/server/main.js
```

这将在 Node.js 环境中启动你的 Angular SSR 应用。 ([ANGULARarchitects][1])

---

## 🧩 使用 SSR 时的注意事项

### 🚫 浏览器 API

SSR 在服务器端渲染，因此不能直接访问：

* `window`
* `document`
* `localStorage`

要避免这些对象的直接使用或者通过 `isPlatformBrowser` 判断分支执行。 ([ANGULARarchitects][1])

---

## 📈 性能优化建议

* 设置好 *SEO 元标签* 以提升爬虫抓取
* 利用 *Deferrable Views* 去延迟非关键内容
* 在合适路由使用静态预渲染（SSG）
* 利用 *Incremental Hydration* 降低 Hydration 峰值 JS 加载

这些策略结合 SSR 能显著提升真实用户体验指标（如 FCP、LCP）。 ([ANGULARarchitects][1])

---

## 🧠 总结

Angular 的 SSR 支持已经成熟并不断增强：

✔️ 更快的首次内容呈现
✔️ 更友好的 SEO / 社交媒体抓取
✔️ 混合渲染策略用于不同页面需求
✔️ Hydration 与增量 Hydration 提升动态体验
✔️ 可结合静态站点生成提升部署灵活性

如果你正在构建对性能和 SEO 有高要求的 Angular 应用，SSR 绝对值得投入。 ([ANGULARarchitects][1])

---

如需进一步示例代码或实战模版，我可以继续帮助你扩展这篇博客 📚。

[1]: https://www.angulararchitects.io/blog/guide-for-ssr/ "Updated: Guide for Server-Side Rendering (SSR) in Angular - ANGULARarchitects"
