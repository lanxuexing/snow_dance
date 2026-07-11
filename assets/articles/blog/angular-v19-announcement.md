---
title: Announcing Angular v19：速度与 DX 的双重飞跃！增量水合、本地模板变量 @let 与全面信号化
date: 2024-11-19
category: Blog
excerpt: Angular v19 正式版震撼发布！本次更新再次引爆了前端性能与开发体验的双重革命：增量水合（Incremental Hydration）与事件回放（Event Replay）首次亮相、本地模板变量 @let 语法正式稳定、全新响应式原语 linkedSignal 和 resource 登场，更有期待已久的 Material 3 专属时间选择器组件。本文将为您全面拆解 v19 的硬核更新与代码示例。
---

# Announcing Angular v19：速度与 DX 的双重飞跃！增量水合、本地模板变量 \@let 与全面信号化

谷歌正式推出了 **Angular v19**！

这是 Angular 团队在过去两年里持续重注“开发体验（DX）”和“应用性能（Performance）”的集大成版本。无论是针对超高负载的 SSR 优化，还是向下一代全信号（Signals）驱动的现代响应式模型演进，v19 都交出了一份令人振奋的成绩单。

以下是 Angular v19 核心亮点、技术重构与实战代码的完整盘点。

---

## ⚡ 1. 极致性能：增量水合与默认事件回放（Event Replay）

随着应用规模增长，大量 JS 代码导致的渲染水合阻碍一直是 SSR（服务端渲染）的痛点。

### 增量水合（Incremental Hydration）进入开发者预览
在 v19 中，Angular 引入了受 `@defer` 延迟加载启发的服务端增量水合技术。通过声明触发条件，框架可以按需、异步地水合页面的特定局部：

```html
<!-- 当购物车组件进入视口时，才异步下载对应 JS 并激活水合 -->
@defer (hydrate on viewport) {
  <shopping-cart />
}
```
要在项目中体验这一特性，只需在客户端引导时加入：
```typescript
provideClientHydration(withIncrementalHydration());
```

### 事件回放（Event Replay）默认启用
当 JS 尚未加载完成，而用户已经点击了按钮，如何保证交互不丢失？
Angular v19 将源于 Google Search 亿级用户锤炼的 Event Dispatch 库融入底层，并在新 SSR 项目中**默认开启事件回放**。当页面组件尚未水合激活时，用户所有的点击、输入操作都会被框架录制，并在组件水合完毕后自动按序“重放（Replay）”，彻底消除交互白屏时间的尴尬。

---

## 🕊️ 2. Reactivity 革命：`linkedSignal` 与 `resource` 异步信号

除了将 `input`、`output`、`model`、`viewChild` 等基于 Signals 的核心 API 全部推向 **Stable（稳定版）** 之外，v19 还引入了两个全新的响应式拼图：

### 关联可写信号：`linkedSignal`（实验性）
在 UI 状态中，经常有“子状态需同步父状态的变更但又允许本地修改”的诉求（如：下拉菜单默认选中第一项，当选项列表变化时重置回第一项，但中途允许用户自由切换）。
`linkedSignal` 的诞生正是为了干掉为了这套逻辑而滥用的 `effect`：

```typescript
const options = signal(['apple', 'banana', 'fig']);

// 声明 linkedSignal，当依赖源 options() 改变时自动计算并复位默认值
const choice = linkedSignal(() => options()[0]);

console.log(choice()); // "apple"
choice.set('fig');     // 允许本地手动改写
console.log(choice()); // "fig"

// 改变 options 列表，choice 会感知到依赖变化自动重置为 "peach"
options.set(['peach', 'kiwi']);
console.log(choice()); // "peach"
```

### 异步资源响应信号：`resource`（实验性）
v19 首次迈出了 Signals 融入异步数据流的一步。`resource` 原生接入 Signal 依赖图，用于管理和触发异步网络请求，并直接返回包装了 `value`、`status`、`isLoading` 的资源信号对象：

```typescript
import { resource } from '@angular/core';

user = resource({
  // 依赖源参数
  request: () => ({ id: this.userId() }),
  // 异步加载器，支持自动中止信号
  loader: async ({ request, abortSignal }) => {
    const res = await fetch(`api/users/${request.id}`, { signal: abortSignal });
    return res.json();
  }
});
```

同时，还提供了针对 Observable 包装的 `rxResource` 互操作 API，平滑兼容 RxJS 生态。

---

## 💎 3. 模板新写法：本地临时变量 `@let` 正式稳定

在过去，想要在 Angular 模板中存储中间计算状态或缓存 `async` 管道数据，我们不得不借助 `*ngIf="value as val"` 这种别扭的写法。

Angular v19 带来了广受好评的 **`@let` 语法（正式稳定）**。你可以像在 JS 里写 `let` 一样，在模板任意位置声明局部变量：

```html
@let user = user$ | async;
@let greeting = 'Hello, ' + user.name;
@let isValidNumber = /\d+/.test(user.phone);

<div>
  <h3>{{ greeting }}</h3>
  @if (!isValidNumber) {
    <p class="error">手机号格式不正确</p>
  }
</div>
```

---

## 🛠️ 4. 极致开发体验（DX）升级

*   **热模块替换（HMR）扩展**：CSS/Sass 样式的 HMR 在 v19 中默认开启；同时支持通过环境变量 `NG_HMR_TEMPLATES=1 ng serve` 体验无刷新、无状态丢失的组件模板 HMR。
*   **Standalone 默认转正**：`standalone: true` 成为组件、指令、管道的隐式默认行为，新代码无需再书写这一冗余元数据属性。
*   **严苛模式编译器开关**：在 `tsconfig.json` 中配置 `strictStandalone: true` 后，遇到任何使用 NgModule 的传统组件都将抛出编译报错，强力保障组件 standalone 纯洁性。
*   **闲置导入自动分析**：Angular 编译器现在能自动发现 standalone 组件元数据中声明了却从未在模板使用的冗余 `imports`，并在编译时发出警告提醒清理。

---

## 🎨 5. 材质设计（Material）与 CDK 赋能

*   **官方时间选择器（Time Picker）发布**：这曾是 GitHub 上高达 1300+ 点赞的痛点诉求，Angular Material v19 现已提供了完美支持 M3 规范和无障碍标准的 `mat-timepicker` 组件。
*   **CDK 混合（2D）拖拽**：通过 `<div cdkDropList cdkDropListOrientation="mixed">` 支持了行列交错的二维卡片布局拖动排序。
*   **Tab 组件拖动重排**：支持对 Material Tab 组件的选项卡直接进行键盘及鼠标级拖拽重排序。
*   **统一主题 mat.theme 宏**：将原本繁琐的单组件样式配置，精简为一行 `@include mat.theme(...)`，支持更强大灵活的设计 Token。

---

## 🏁 结语

Angular v19 是一个在“性能提升”与“书写甜点”之间取得完美平衡的璀璨版本。Signals 的逐步成熟与 `@let` 等模板爽点的加入，让现代 Angular 散发出前所未有的轻量与快捷。

立刻在终端中开启您的升级冒险吧：

```bash
ng update @angular/core@19 @angular/cli@19
```
