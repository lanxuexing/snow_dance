---
title: Angular v19.2 正式发布：httpResource 与 rxResource 异步数据流增强
date: 2025-02-19
category: Blog
excerpt: Angular v19.2 带来了一系列小版本更新，核心发力点依然在 Signals 异步响应式上：推出了全新 httpResource 简化 HTTP 数据抓取，并且通过 rxResource 增强了对数据流式响应（Streaming）的支持。此外，模板中现已支持无标签模板字面量表达式。
---

# Angular v19.2 正式发布：httpResource 与 rxResource 异步数据流增强

Angular 团队推出了 **Angular v19.2** 小版本更新！

在这个版本中，官方继续深挖 **Signals 异步响应式（Asynchronous Reactivity）** 体系的潜力，推出了全新的网络请求助手，并极大地增强了流式响应的管理。同时，模板引擎在书写体验上也得到了进一步的打磨。

---

## ⚡ 1. 扩展异步响应式：httpResource 与 rxResource 升级

在 Angular v19 中，实验性的 `resource` API 开启了异步信号的新时代。而在 v19.2 中，这一生态迎来了两个极具含金量的补充：

### 极低摩擦的 `httpResource` API
为了简化在组件中基于 Signals 的数据拉取操作，v19.2 引入了 `httpResource` API。它能够自动嗅探依赖信号的变化并自动触发底层的 HTTP 请求，同时由于其底层使用的是 Angular 的 `HttpClient`，因此它能原生享受到全部配置好的 HTTP 拦截器（Interceptors）：

```typescript
import { httpResource } from '@angular/common/http';

// 获取当前登录用户 ID 信号
currentUserId = getCurrentUserId();

// 声明 httpResource，当 currentUserId 变化时自动触发 GET 请求
user = httpResource(() => `/api/user/${this.currentUserId()}`);
```

### `rxResource` 支持多值流式渲染（Streaming）
当需要连接一个返回多个渐进式数据的流端点（例如 Server-Sent Events、WebSockets 或轮询流）时，单次 Promise 加载的 `resource` 就不再适用了。

v19.2 为 `rxResource` 提供了流式监听（Stream）支持，能够持续接收 Observable 发射的流式数值并动态更新 Signal：

```typescript
import { rxResource } from '@angular/core/rxjs-interop';
import { BehaviorSubject } from 'rxjs';

readonly subject = new BehaviorSubject(1);

// 模拟每秒产生一个递增值的流
readonly intervalId = setInterval(() => {
  this.subject.next(this.subject.value + 1);
}, 1000);

// rxResource 会在值到达时源源不断地进行流式读取
readonly streamResource = rxResource({
  loader: () => this.subject,
});
```
在模板中，只需要通过 `{{ streamResource.value() }}` 即可直接绑定渲染出最新的流式推送数据。

---

## ✍️ 2. 更好的模板书写体验

除了底层的响应式革新，Angular v19.2 对模板解析器（Parser）也做出了人性化的升级。

### 支持无标签模板字面量（Untagged Template Literals）
在编写模板绑定时，进行复杂的字符串拼接或处理带有单双引号的属性常常显得极其繁琐。现在，我们可以在模板插值和属性绑定中，直接使用反引号（`` ` ``）进行字面量拼接：

```html
<!-- 更加清爽的类名拼接写法 -->
<div [class]="`layout col-${colWidth()}`"></div>
```
这让动态拼接与计算变得更加连贯，极大提升了开发体验（DX）。

---

## 🛠️ 3. 其他优化与迁移支持

1.  **自闭合标签迁移**：提供了自动化 Schematic 命令，帮助将模板中所有没有内容的 HTML 标签自动 refactor 为自闭合（Self-closing）格式（例如 `<app-sidebar />`）；
2.  **表单支持 Set 类型**：允许在响应式表单中直接选用 ES6 `Set` 作为输入值和控件状态；
3.  **新增 `skipHydration` 诊断分析**：当检测到在 SSR 页面中存在可能被跳过水合的区块时，编译器将提供更明确的静态警示。

---

## 🏁 升级建议

v19.2 的异步 Signals 特性已经稳定就绪。您可以通过以下命令快速升级到 v19.2 并开始试用新出的 `httpResource`：

```bash
ng update @angular/core@19 @angular/cli@19
```
