---
title: 深度剖析 Angular Signals：解密高效响应式的底层设计与 Push/Pull 算法
date: 2026-07-11
category: Blog
excerpt: 想要彻底搞懂 Angular Signals 的运作机制吗？本文将从底层设计出发，深度解密 Reactive Context（响应式上下文）、动态依赖追踪、Glitch-Free 双阶段 Push/Pull 算法，以及 Signals 如何深度融合并重塑 Angular 变革检测（Change Detection）机制。
---

# 深度剖析 Angular Signals：解密高效响应式的底层设计与 Push/Pull 算法

在现代前端开发中，管理复杂的用户界面（UI）状态是一项极富挑战的任务。UI 状态往往不是孤立的，而是一个由复杂依赖关系交织而成的**派生状态网**。

为了简化状态同步、避免多余计算，Angular 引入了全新的响应式原语——**Signals（信号）**。这项技术的底层设计高度借鉴了正在推进的 **TC39 JavaScript Signals 标准提案**，能够实现极致的运行时细粒度更新。

本文将为您深度拆解 Angular Signals 的底层架构，带您看清它如何通过双阶段 **Push/Pull（推/拉）算法**解决经典的“钻石问题”，以及它又是如何无缝融合进 Angular 的变更检测系统（Change Detection）中的。

---

## 🏗️ 核心概念：生产者（Producers）与消费者（Consumers）

Signals 的底层是一个**有向图（Dependency Graph）**，图中的每个节点主要扮演两种角色：

1.  **生产者（Producers）**：产生数据源并能发出变更通知的节点（例如：`writable signal` 和 `computed signal`）。
2.  **消费者（Consumers）**：消费并依赖其他数据源的节点（例如：`computed signal`、`effect` 监听器、以及组件的模板视图）。

> [!NOTE]
> `computed` 信号是一个特殊的“双面人”：对于它所依赖的 Signal，它是**消费者**；对于依赖它的外部节点，它是**生产者**。

---

## 🌀 追踪机制：响应式上下文（Reactive Context）

Signals 最神奇的地方在于**隐式动态依赖追踪**——开发者不需要写类似 React 的依赖数组 `[depA, depB]`，也不需要手动退订。这一切都是通过**响应式上下文（Reactive Context）**实现的。

### 1. 它是如何工作的？
当计算发生时，Angular 内部会在执行回调前，将当前消费者（例如一个 `computed` 节点或视图节点）挂载到一个全局的“活动消费者”变量上（即 `setActiveConsumer(node)`）。

在这个回调的生命周期内，任何被读取的 Signal，都会执行其取值函数（Accessor），并顺理成章地在全局变量中读取到当前的活动消费者，从而自动建立起一条**“消费者 -> 生产者”的有向依赖边**。

### 2. 动态依赖剪枝
在每次重新计算时，依赖关系是**动态且实时调整**的。
考虑以下分支计算：

```typescript
const dynamic = computed(() => useA() ? dataA() : dataB());
```

在运行时：
*   当 `useA` 为 `true` 时，它的依赖集仅包含 `[useA, dataA]`。
*   即使 `dataB` 的值发生改变，`dynamic` 信号也**完全不会重新计算**，因为 `dataB` 此时并不在依赖链中。这就是极速响应的动态依赖剪枝。

---

## ⚡ 双阶段 Push/Pull 算法：消灭“钻石问题”与中间闪烁

在早期的“纯推送式（Push-based）”响应式框架中，当状态变动时会立即触发派生值计算，这会导致臭名昭著的**钻石问题（Diamond Problem）**：

```
    [A (State)]
    /        \
 [B (Comp)] [C (Comp)]
    \        /
    [D (Comp)]
```

当 `A` 发生变化时，如果走纯推送路线：
1.  `A` 变动 -> 触发 `B` 计算 -> 触发 `D` 计算；
2.  `A` 变动 -> 触发 `C` 计算 -> 再次触发 `D` 计算。
`D` 被重复计算了两次，并可能在中间暴露出不一致的暂态“闪烁”（Glitches）。

### Angular 的解决方案：双阶段 Push/Pull（推/拉）算法

#### 第一阶段：Push（推“脏”状态，不计算）
当源头 Writable Signal（如 `A`）的值被 `set()` 修改时，Angular **不会立刻运行任何派生计算**。
*   它仅同步地顺着依赖图的“反向通路”（`liveConsumerNode` 链条）向下广播，将所有受影响的消费者节点标记为 `dirty = true`。
*   此阶段**没有任何副作用执行，也没有任何 DOM 写入**，纯粹是状态的失效标记。

#### 第二阶段：Pull（按需拉取，缓存求值）
只有当用户代码或框架渲染流程显式读取（Pull）某个派生值（如调用 `d()`）时，计算才真正触发。
*   计算节点会向上轮询（Poll）其依赖节点的版本号（`version`）。如果发现依赖的版本未变，直接返回缓存值；
*   如果依赖的版本变了，执行同步求值并更新版本号。
*   通过这种“延迟拉取”，`D` 在渲染帧到来时只会被计算一次，完美避开了钻石拓扑多路径求值的问题。

---

## 🌐 深度结合：重塑 Angular 变更检测（Change Detection）

为了让 Signals 完美接管应用的渲染更新，Angular 将**组件模板视图（Template Expressions）**也视作了图中的一种特殊的**“活消费者”（Live Consumer）**。

### 1. `ReactiveLViewConsumer` 的引入
每一个组件的模板在底层编译成 JS 代码（即视图指令 `LView`）后，都会被包装进一个 `ReactiveLViewConsumer` 节点：

```typescript
const REACTIVE_LVIEW_CONSUMER_NODE = {
  consumerIsAlwaysLive: true,
  consumerMarkedDirty: (node: ReactiveLViewConsumer) => {
    // 核心：一旦依赖的 Signal 变脏，立即向上标记祖先视图以待遍历
    markAncestorsForTraversal(node.lView!); 
  }
};
```

### 2. 精准刷新流程
1.  在首屏变更检测运行时，组件模板执行插值 `{{ value() }}`，触发 Signal 读取；
2.  `value()` 作为生产者，在 `ReactiveLViewConsumer` 视图响应式上下文中被读取，模板视图自动注册为该 Signal 的 **Live Consumer**；
3.  当开发者调用 `value.set(newValue)` 修改值时，第一阶段的 **Push** 机制启动，立即触发 `consumerMarkedDirty`；
4.  组件及其祖先链被标记为需要刷新（类似 `markForCheck`）；
5.  在下一帧渲染调度（Change Detection Run）到来时，视图节点被遍历，执行 **Pull** 阶段，拉取最新值更新 DOM。

---

## 🚀 结语

Angular Signals 通过优雅地结合 **Reactive Context 隐式依赖追踪** 与 **双阶段 Push/Pull 惰性求值**，在逻辑层实现了干净利落的依赖追踪，在运行层实现了物理级防抖与无闪烁渲染。

这不仅是框架变更检测的一次自我迭代，更是通往前端**无 Zone 细粒度更新（Zoneless Reactivity）**时代的坚实底座！
