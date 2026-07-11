---
title: Announcing Angular v18：Zoneless 无域运行预览、控制流与 Defer 稳定，新官网亮相
date: 2024-05-22
category: Blog
excerpt: Angular v18 正式版现已推出！作为 Angular 底层架构现代化重塑的重要里程碑，v18 带来了实验性的 Zoneless（无 Zone.js）变更检测支持；内建控制流语法与 @defer 延迟加载块正式宣布稳定；Material 3 组件生态成熟；同时，全新官网 angular.dev 成为官方文档唯一新家。本文将为您盘点全部重磅更新。
---

# Announcing Angular v18：Zoneless 无域运行预览、控制流与 Defer 稳定，新官网亮相

Angular 团队正式发布了 **Angular v18**！

在过去的几个大版本中，Angular 推出了 Signals 响应式、控制流语法以及服务端水合等多项颠覆性的技术。而 v18 在延续这些革新的同时，将工作重心放在了特性打磨、API 转正（Stable）以及备受期待的**无域变更检测（Zoneless Change Detection）**的首次露面上。

接下来，我们将为您深度梳理 Angular v18 带来的核心跃迁。

---

## 🕊️ 1. 划时代突破：实验性支持 Zoneless（无域）变更检测

自诞生之初，Angular 就一直强依赖 `zone.js` 库来拦截浏览器的各种异步行为以自动运行变更检测。虽然这实现了“自动更新”，但也带来了打包体积大、首屏变慢、异步调用栈难以排错等历史包袱。

Angular v18 终于迈出了走向 **Zoneless** 的第一步，发布了实验性的无域运行模式。

### 开启无域运行
在新版应用中，您只需在 `app.config.ts` 的 providers 中提供 `provideExperimentalZonelessChangeDetection`，即可彻底摘掉 `zone.js`：

```typescript
import { bootstrapApplication } from '@angular/platform-browser';
import { provideExperimentalZonelessChangeDetection } from '@angular/core';
import { AppComponent } from './app.component';

bootstrapApplication(AppComponent, {
  providers: [
    provideExperimentalZonelessChangeDetection() // 宣告进入无域模式
  ]
});
```

然后，直接从 `angular.json` 的 `polyfills` 配置列表中移除 `"zone.js"` 导入。

### 无域模式下的组件写法
在 Zoneless 架构下，Signals 响应式成为了与框架交互的最佳拍档：

```typescript
import { Component, signal } from '@angular/core';

@Component({
  selector: 'app-root',
  standalone: true,
  template: `
    <h1>Hello from {{ name() }}!</h1>
    <button (click)="goToZoneless()">开启无域</button>
  `,
})
export class AppComponent {
  name = signal('Angular 传统模式');

  goToZoneless() {
    // 修改 Signal 会作为调度触发器，框架会自动 coalescing 并安排一次渲染更新
    this.name.set('Zoneless 现代模式');
  }
}
```

在 Zoneless 模式下，Angular CLI 编译时会保留原生的 `async/await` 语法，不再为了 Zone.js 的拦截而将其退化（downlevel）转译为 Promise，让现代浏览器的执行效率和调试体验更上一层楼。

---

## 🏠 2. 开发者的新家：angular.dev 正式成为官方新官网

在经历了 18 个月的悉心打磨与社区测试后，全新的 **`angular.dev`** 正式取代旧的 `angular.io`，成为了 Angular 开发者的官方唯一家园。

新官网提供了：
*   基于 WebContainers 技术的**交互式免配置新手教程**；
*   支持直接在线编码试验的 Playground 演练场；
*   由 Algolia 强力驱动的极速文档搜索；
*   全新重写、更具现代感的开发指南与 API 文档。

所有访问旧站 `angular.io` 的链接目前均已自动重定向至新站。

---

## 🏆 3. 控制流（Control Flow）与 Deferrable Views 正式宣告 Stable

在 v17 中作为开发者预览版惊艳亮相的两大模板层利器，在 v18 中正式毕业，迈向 **Stable（稳定版）**：

### 内建控制流语法（Built-in Control Flow）
用更清爽的 `@if`、`@for`、`@switch` 替换原先的 `*ngIf` 等指令，不仅编译速度更快，且内置了优秀的类型推导和防掉帧警告机制。

### 延迟加载视图（Deferrable Views）
使用简单的 `@defer` 即可将非首屏组件或重度依赖打包至独立的异步 JS 分包中，极大地改善了核心 Web 指标（Core Web Vitals）。很多社区企业实践反馈，仅通过引入 `@defer`，就直接把项目打包体积削减了 50%。

---

## 🎨 4. Angular Material 3 宣布稳定

伴随 v18 的推出，基于 **Material 3 (M3)** 设计规范的组件支持也正式从实验性毕业为 **Stable**。

*   全新的 Sass 统一配置 API：支持一键定义 M3 主题 Token，且能与组件级 Token 紧密绑定；
*   全新的 `material.angular.io` 文档站点改版，全面换装 Material 3 主题。

---

## 🌐 5. 服务端渲染（SSR）细节抛光与 Event Replay

为了让混合渲染体验更为完美，Angular v18 在 SSR 层注入了更多由 Google 搜索和 YouTube 验证的底层能力：
*   **i18n Hydration 支持**：在开发者预览中，服务端水合现在可以和 i18n 国际化区块和谐并存；
*   **Event Replay（事件回放）**：接入 Google.com 所采用的 `jsaction` 事件调度底层库，捕获页面在完全激活前用户的交互动作，并在水合结束后自动播放，杜绝操作丢失；
*   **Firebase 官方支持**：通过 Firebase App Hosting 提供了对 Angular SSR 应用一键式的云端无缝托管与扩容支持。

---

## 🛠️ 6. 其它闪光特性

1.  **`<ng-content>` 支持默认内容**：当投影槽没有匹配到传入的 DOM 时，可以使用默认占位模板：
    ```html
    <ng-content select="[icon]">
      <span class="default-icon">fallback</span>
    </ng-content>
    ```
2.  **表单控件统一状态变更流**：`AbstractControl` 新增了 `events` 属性，能够在一个 Observable 流中统一监听控件的 `valueChanges`、`statusChanges`、`touched` 等所有微观状态变更；
3.  **函数式路由重定向**：`redirectTo` 属性不仅可以填写字符串，还可以配置为**函数**，在跳转时动态解析当前路由上下文和参数：
    ```typescript
    { path: 'user/:id', redirectTo: (route) => `/profile/${route.params['id']}` }
    ```

---

## 🏁 总结

Angular v18 展示了谷歌团队对待核心架构演进的匠人精神：它既有像 Zoneless 这种打破常规的底层飞跃，也有将控制流、Defer、Material 3 稳定化的踏实落地。现在就运行 `ng update`，搭上 Angular 现代化重构的快速列车吧！
