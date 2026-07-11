---
title: Angular 模板新特性：深度解析 @let 局部变量声明语法
date: 2024-07-10
category: Blog
excerpt: Angular 官方正式引入了全新的内建模板语法 @let。它允许开发者在 HTML 模板中直接声明局部变量来复用表达式的计算结果，包括对 Async 管道以及 DOM 元素引用的二次计算缓存。本文将为您详述 @let 的具体语法规范、作用域限制及实战场景。
---

# Angular 模板新特性：深度解析 \@let 局部变量声明语法

Angular 团队为开发者带来了备受瞩目的全新内建模板语法 —— **`@let`**。

在过去，Angular 的 HTML 模板虽然支持编写复杂的 JavaScript 表达式，但由于缺乏声明“局部变量”的机制，导致开发者在需要重复使用某个计算结果或 `async` 管道发射的值时，不得不采用一些别扭且臃肿的非原生手段（如用 `*ngIf="expr as val"` 进行包裹）。

全新的 `@let` 语法彻底解决了这一困扰社区多年的痛点。

---

## 💡 1. `@let` 语法怎么用？

`@let` 允许你在组件模板的任何地方声明一个变量，并在该模板内部重复复用它。

其核心语法定义如下：
```html
@let name = value; // value 可以是任何合法的 Angular 模板表达式
```

### 基础赋值场景
```html
@let hero = 'Frodo Baggin';

<h1>当前登录：{{ hero }}</h1>
<p>欢迎您，{{ hero }}！</p>
```

### 搭配 Async 管道（RxJS 缓存）
这可能是 `@let` 最能提效的实战场景。我们不再需要为了订阅一个 Observable 而去嵌套多层 `*ngIf`：
```html
@let user = user$ | async;

@if (user) {
  <div>姓名：{{ user.name }}</div>
  <div>邮箱：{{ user.email }}</div>
}
```

### 绑定 DOM 元素引用
通过 `@let`，你可以实时计算来自其他输入框或组件的 DOM 属性：
```html
<input #phoneInput placeholder="请输入手机号">

<!-- 实时计算带前缀的格式化文本 -->
@let formattedPhone = '+86 ' + phoneInput.value;

<p>您输入的手机号是：{{ formattedPhone }}</p>
```

---

## 🔒 2. `@let` 作用域与安全性规则

为了保证模板的性能和渲染可预测性，Angular 对 `@let` 的作用域和修改权限制定了严格的规范：

### 1. 作用域限制（Block-scoped）
`@let` 声明的变量是**块级作用域**的。它对当前视图容器及其子视图（Descendant Views）可见，但对父级视图或同级（Sibling）视图不可见：

```html
@let topLevel = 'I am top-level';

@if (condition) {
  @let nested = 'I am nested';
  <p>{{ topLevel }}</p> <!-- 正常：可以访问父级变量 -->
}

<!-- 报错！编译期异常，无法访问 @if 块内部声明的变量 -->
<p>{{ nested }}</p>
```

### 2. 严格只读（Read-only）
`@let` 定义的变量在模板中是只读的，**严禁对其重新赋值**。如果您在组件事件（如 `click`）中试图修改它，Angular 编译器会抛出类型校验错误：

```html
@let count = 10;

<!-- 报错：'count' is not assignable -->
<button (click)="count = count + 1">增加</button>
```

### 3. 反应式重算（Reactive Re-computation）
虽然不能被手动改写，但 `@let` 变量的值是完全反应式响应的。在每次变更检测周期内，若所依赖的底层信号（Signals）或数据源发生改变，Angular 会自动重新计算 `@let` 变量的值。

---

## ✍️ 3. 语法书写规范规范

要书写正确的 `@let` 表达式，需要遵循以下细节规范：
*   以 `@let` 关键字开头；
*   后面必须有一个或多个空格，不能直接换行；
*   接着是一个合法的 JavaScript 变量标识符；
*   `=` 等号的前后空格是可选的；
*   等号右侧是合法的 Angular 模板表达式（支持多行换行书写）；
*   **最后必须以分号 `;` 结尾。**

---

## 🏁 结语

`@let` 变量声明以极低的语法噪音带来了显著的开发体验提升（DX），避免了重复的模板表达式调用，同时对提高模板的可读性和应用渲染性能大有裨益。

若您的项目已升级至支持新控制流的 Angular，不妨立即尝试在您的组件模板中运用 `@let` 来重构冗余的变量别名吧！
