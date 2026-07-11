---
title: Announcing Angular v20：响应式 API 稳定、增量水合、Zoneless 预览与 CLI 风格革新
date: 2025-05-28
category: Blog
excerpt: Angular v20 正式发布！本次更新迈出了框架底层响应式重塑的关键一步：effect、linkedSignal 和 toSignal 正式升为稳定版；httpResource 等异步 Signal API 开启实验；Zoneless 变更检测迈入开发者预览，且新项目可一键开启；增量水合与路由级渲染模式稳定；此外，Chrome 性能面板也原生集成了 Angular 性能追踪轨道。本文带您详解全部重磅升级。
---

# Announcing Angular v20：响应式 API 稳定、增量水合、Zoneless 预览与 CLI 风格革新

谷歌 Angular 团队正式发布了 **Angular v20**！

过去几年里，Angular 引入了以 Signals 为核心的响应式体系和无域（Zoneless）架构，大幅提升了开发体验与应用吞吐量。而在 Angular v20 中，团队投入了大量精力去打磨、抛光并稳定（Stabilize）那些备受瞩目的前沿特性，为开发者构建下一代 Web 应用提供坚如磐石的保障。

接下来，我们将为您深度剖析 Angular v20 的全部核心升级点与实战代码。

---

## 🏎️ 1. 响应式（Reactivity）原语全面升为稳定版

自 Angular v16 引入 Signals 以来，其优秀的细粒度更新能力在 Google 内部（如 YouTube Living Room 团队）和外部社区得到了极其广泛的采用。

在 v20 中，响应式拼图的核心 API 正式升级为 **Stable（稳定版）**：
*   **稳定原语**：`signal`、`computed`、`input` 和 `view queries`；
*   **本次新转正的原语**：`effect`（副作用）、`linkedSignal`（关联信号）和 `toSignal`（RxJS 桥接）。

### 🧪 实验性新异步 API：`resource` 与 `httpResource`
为解决异步数据流的管理，v20 增加了基于 Signals 的异步资源请求原语 `resource`、流式资源 `stream` 以及基于 HttpClient 封装的 `httpResource`：

```typescript
import { Component, signal, httpResource } from '@angular/core';

@Component({
  selector: 'app-user-profile',
  template: `
    <!-- 直接在模板中使用 Signal 风格访问异步状态 -->
    @if (userResource.isLoading()) {
      <p>加载中...</p>
    } @else {
      <pre>{{ userResource.value() | json }}</pre>
    }
  `
})
class UserProfile {
  userId = signal(1);
  
  // 声明 httpResource，当 userId 改变时自动发起 GET 请求
  userResource = httpResource<User>(() => 
    `https://example.com/v1/users/${this.userId()}`
  );
}
```

---

## 🕊️ 2. Zoneless（无域）变更检测迈入开发者预览

传统的 Angular 应用极度依赖 `zone.js` 拦截所有的浏览器异步宏任务/微任务。但在 v20 中，**Zoneless 变更检测正式升级至开发者预览版（Developer Preview）**。

移除 Zone.js 后，您可以获得更快的首屏加载、支持原生的 `async/await` 异步编译、更小的打包体积和更轻松的排错体验。

### 开启方式：
在新项目中，可以通过 CLI 参数一键开启无域模式：
```bash
ng new my-app --zoneless
```
在已有项目中，只需在 `app.config.ts` 的 providers 中声明，并从 `angular.json` 中移除 `zone.js` 填充：
```typescript
bootstrapApplication(AppComponent, {
  providers: [
    provideZonelessChangeDetection(),
    provideBrowserGlobalErrorListeners() // 稳定捕获未处理的 Promise 拒绝与异常
  ]
});
```

---

## 🌐 3. 服务端渲染（SSR）双子星宣告稳定：增量水合与路由渲染配置

Angular v20 对现代 SSR 基础架构做出了决定性的固化：

### 增量水合（Incremental Hydration）正式稳定：
增量水合允许应用逐步、按需地下载和激活页面的不同部分，无需在首屏一次性下载整个页面的 JS 包。结合 `@defer` 延迟加载块，使用极其简单：

```html
<!-- 当包含购物车的部分进入视口时，才下载 JS 并水合激活该区域 -->
@defer (hydrate on viewport) {
  <shopping-cart />
}
```

### 路由级渲染模式配置（Route-level Render Mode）稳定：
支持在独立的 `server-route` 配置文件中声明不同页面的渲染策略（SSR、SSG、CSR）：

```typescript
export const routeConfig: ServerRoute[] = [
  { path: '/login', mode: RenderMode.Server },     // 动态 SSR
  { path: '/dashboard', mode: RenderMode.Client }, // 纯客户端 CSR
  {
    path: '/product/:id',
    mode: RenderMode.Prerender,                    // 静态预渲染 SSG
    async getPrerenderParams() {
      const ids = await inject(ProductService).getIds();
      return ids.map(id => ({ id }));
    }
  }
];
```

---

## 🛠️ 4. 强强联手：Chrome 性能面板原生集成 Angular 轨道

为了能更直观地定位性能瓶颈，Angular 团队与 Chrome DevTools 团队深度合作，在 **Chrome 浏览器控制台的 Performance 面板中原生集成了 Angular 专有的剖析数据轨道**。

开发者无需在框架专有工具与浏览器面板间来回切换，即可在时间轴中清晰地预览：
*   组件的实例化（Component Instantiation）与提供者创建；
*   变更检测周期（Change Detection Cycle）与事件监听器执行；
*   通过颜色清晰区分“开发者手写代码”与“编译器生成的底层代码”。

在 DevTools 控制台执行 `ng.enableProfiling()` 即可激活这一低开销、高精度的调优轨道。

---

## 💎 5. 框架细节抛光与 CLI 风格指南升级

### 动态组件增强：
使用 `createComponent` 动态创建组件时，支持绑定输入 Signal、注册输出回调，甚至挂载指令：
```typescript
createComponent(MyDialog, {
  bindings: [
    inputBinding('canClose', canCloseSignal),
    outputBinding('onClose', res => console.log(res)),
    twoWayBinding('title', titleSignal)
  ],
  directives: [ FocusTrap ]
});
```

### CLI 文件命名后缀变为可选：
基于对社区大型项目的调研，为了减少样板代码，**CLI 默认将不再强制生成 `.component.ts`、`.service.ts` 等文件和类名后缀**，支持更精简、意图明确的命名。旧项目升级时仍会默认保留后缀。

### 宿主绑定（Host Bindings）强类型检查：
支持在 `tsconfig.json` 的 `angularCompilerOptions` 中开启 `typeCheckHostBindings: true`，对指令中 `host` 属性里的表达式进行强类型校验和语言服务自动补全，该特性将在 v21 默认开启。

### 控制流替代废弃：
鉴于内置控制流（`@if`、`@for`、`@switch`）极高的普及率，v20 中正式将传统的结构性指令 `*ngIf`、`*ngFor` 和 `*ngSwitch` 标记为**已弃用（Deprecated）**，并计划在 v22 正式移除。

---

## 🤖 6. 拥抱生成式 AI 生态

为了帮助大语言模型（LLMs）更准确地生成符合现代规范的 Angular 代码，Angular 官方在代码库根目录维护了 `llms.txt` 声明，引导 AI 引擎优先识别 Signals 控制流和 Standalone 架构，同时在 `angular.dev/ai` 上开辟了利用 Genkit 与 Vertex AI 快速构建生成式 AI 应用的全新指南。

---

## 🐾 7. 征集官方吉祥物（Mascot）

作为一个有着超过十年历史的框架，Angular 终于决定设计自己的官方吉祥物！目前，官方已经发起了 mascot RFC（包括盾牌盾牌人、安康鱼等方案），社区成员可积极参与投票或提议命名。

---

## 🏁 结语

Angular v20 是一个将革新力量转化为稳固基石的重要版本。所有的底层设计都在向着“更轻量、更快速、对 AI 友好”的方向狂奔。建议您立刻运行以下命令完成平滑升级：

```bash
ng update @angular/core@20 @angular/cli@20
```
