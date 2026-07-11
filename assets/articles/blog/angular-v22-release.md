---
title: Angular v22 正式发布：Signal 响应式生态与 OnPush 默认化时代开启
date: 2026-06-05
category: Blog
excerpt: Angular v22 于 2026 年 6 月 3 日正式发布！作为 Angular 历史上又一里程碑式的版本，v22 标志着 Signal 响应式生态的全面稳定与成熟。本文将深度解析 OnPush 默认化、Signal Forms、异步响应式 API（resource 等）正式毕业等核心重大变革。
---

# Angular v22 正式发布：Signal 响应式生态与 OnPush 默认化时代开启

Angular 官方团队于 **2026 年 6 月 3 日** 正式推出了 **Angular v22**。

如果说过去的几个版本是 Angular 引入 Signal 并探索“无 Zone 运行环境（Zoneless）”的试验期，那么 v22 的发布则宣告了**响应式新生态的全面收官与生产环境稳定时代**的到来。在这个版本中，多个备受瞩目的试验性 API 正式毕业，开发体验（DX）与运行时性能均迎来了质的飞跃。

接下来，我们将为您深度拆解 Angular v22 的五大核心更新亮点。

---

## 🎨 核心变革一：OnPush 默认成为新的组件更新策略

长期以来，Angular 默认使用“脏检查（Check Always）”策略进行变更检测。这种做法虽然对初学者友好，但在中大型复杂应用中，极易引起无意义的二次渲染，拖慢运行时响应速度。

在 Angular v22 中，官方做出了一个突破性的决定：**新创建的组件将默认使用 `OnPush` 变更检测策略**。

### 关键细节：
* **`ChangeDetectionStrategy.Eager`**：为了在语义上更清晰，原先的默认“Check Always（每次都检查）”策略在内部已被重命名为 `Eager` 策略。
* **渐进式迁移**：针对现有的庞大代码库，官方随 CLI 提供了功能强大的自动迁移脚本（`ng update`），能平滑地将旧有组件标记适配为全新的语义定义，而无需开发者手动逐一排查。
* **性能收益**：OnPush 策略的默认化，能强迫开发者编写更具局部可预测性的数据流，在默认情况下将整站的 CPU 开销降低 20%-40% 以上。

---

## 📝 核心变革二：Signal Forms 正式迈入稳定版（Stable）

在表单处理上，传统的 `ReactiveForms` 强依赖于 RxJS 的 Observable 流。虽然功能强大，但在复杂的数据联动和类型安全支持上，总是略显繁琐。

**Signal Forms** 作为以 Signal 响应式原语为底层构建的全新表单引擎，在 v22 中**正式宣告从 Developer Preview 毕业，成为生产环境 Stable API**。

```typescript
import { Component } from '@angular/core';
import { signalForm, signalControl } from '@angular/forms';

@Component({
  selector: 'app-user-profile',
  template: `
    <form [formGroup]="profileForm">
      <input [formControl]="profileForm.controls.username" placeholder="用户名" />
      <p>当前输入：{{ profileForm.controls.username.value() }}</p>
    </form>
  `
})
export class UserProfileComponent {
  profileForm = signalForm({
    username: signalControl('lanxuexing')
  });
}
```

### Signal Forms 的优势：
1. **天然的类型安全（Type-Safe by Design）**：得益于 Signals 的强类型推导，表单字段的值和状态拥有完美的 TypeScript 类型保障。
2. **高频响应式状态提取**：表单的值、校验状态（valid）、脏状态（dirty）等状态全部作为只读 Signal 暴露。在模板或 effect 中直接调用即可绑定，不再需要显式订阅 RxJS 订阅流并手动管理退订逻辑。
3. **更轻量级的执行上下文**：大幅度缩减了框架内部跟踪状态变动的开销，与 Zoneless 结合使用效果更佳。

---

## ⚡ 核心变革三：异步响应式资源 API（resource / rxResource）毕业

在处理异步数据获取（如发起 HTTP 网络请求或从本地读取 IndexedDB）时，如何将其优雅地衔接至 Signal 的响应式链条中，曾是社区最头疼的难题。

Angular v22 将以下三大异步响应式资源管理 API **全部毕业为 Stable**：

*   **`resource()`**：基于 Promise 的通用异步资源封装器。
*   **`rxResource()`**：为 RxJS Observable 深度定制的异步转换通道。
*   **`httpResource()`**：专为 HttpClient 设计的、开箱即用的网络资源加载利器。

### 示例代码：
```typescript
import { Component, signal } from '@angular/core';
import { httpResource } from '@angular/common/http';

@Component({
  selector: 'app-article-reader',
  template: `
    <button (click)="articleId.set('ng-pwa')">加载新文章</button>
    
    @if (article.isLoading()) {
      <p>加载中...</p>
    } @else if (article.error()) {
      <p>出错了：{{ article.error() }}</p>
    } @else {
      <div [innerHTML]="article.value()?.content"></div>
    }
  `
})
export class ArticleReaderComponent {
  articleId = signal('cdk');
  
  // 依赖的 signal 变动时，httpResource 会自动重新发起请求，完全响应式！
  article = httpResource<any>(() => `/api/articles/${this.articleId()}`);
}
```

这些 API 极大地规范化了 Angular 应用中的异步数据通信流程，使得网络请求也成了响应式依赖图谱（Dependency Graph）中自然流转的一部分。

---

## 🌐 核心变革四：无Zone环境与渐进式注水（Incremental Hydration）默认化

服务端渲染（SSR）在高性能前端网站中扮演着举足轻重的角色。

在 v22 中，**渐进式注水（Incremental Hydration）**正式成为服务端渲染的默认激活模式：
* **按需注水**：浏览器在加载页面后，不再粗暴地一次性对整张 DOM 树执行激活（Hydration），而是仅在组件进入视口（Viewport）或用户发生交互时执行局部激活；
* **极速首屏交互时间（INP & LCP）**：这使得即便在复杂的长页面或慢速移动网络环境下，用户也能瞬间进行点按与输入操作，大幅度提升了 Core Web Vitals 核心指标指标的跑分。

此外，Zoneless 架构也得到了更深层次的底层强化，逐步完成了对底层生态（包括主流第三方 UI 组件库）的完全兼容。

---

## ♿ 核心变革五：Angular Aria 步入生产级稳定支持

对于现代无障碍可访问性（Accessibility，简称 a11y）有严格要求的企业级应用来说，**Angular Aria** 在 v22 中正式毕业为稳定版：
* 自动为组件树附加恰当的 `aria-*` 属性以及辅助功能标记；
* 极大地减少了为让屏幕阅读器（Screen Reader）正确阅读页面所需的额外手工编码量。

---

## 🚀 总结与未来展望

Angular v22 并不是一个颠覆性重构的版本，但它是一个**把卓越愿景彻底落地并开花结果的里程碑**。

Signal Forms 和异步资源 API 的毕业，打通了响应式生态的最后一公里；OnPush 策略的默认化与渐进式注水，则将生产性能的基准线推到了新的高度。

对于开发者来说，现在是拥抱 Zoneless 和纯 Signal 响应式架构的**最佳黄金时期**。建议您立即运行 `ng update`，带领团队和项目踏入高效、纯粹的现代化 Angular 22 时代！
