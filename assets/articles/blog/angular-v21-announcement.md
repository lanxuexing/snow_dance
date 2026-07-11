---
title: Announcing Angular v21：重磅发布！Signal Forms、无头组件库 Aria 与 Zoneless 默认时代开启
date: 2025-11-19
category: Blog
excerpt: Angular v21 正式版震撼发布！本次更新迎来了诸多里程碑式的变革：实验性 Signal Forms 问世、无头无样式可访问性组件库 Angular Aria 开启开发者预览、Vitest 成为默认测试运行器，更重要的是，Zoneless（无 Zone.js）正式成为新项目的默认配置。本文将为您深度盘点 v21 的全部核心看点与代码示例。
---

# Announcing Angular v21：重磅发布！Signal Forms、无头组件库 Aria 与 Zoneless 默认时代开启

谷歌 Angular 团队正式发布了 **Angular v21**！这是一个在框架演进史上具有里程碑意义的版本。

无论你是通过 AI 编程助手（AI Agents）进行高效研发，还是坚守 IDE 手写每一行核心逻辑，Angular v21 都为你准备了一整套强大的现代化开发工具箱。本次更新的四大亮点包括：**Signal Forms 概念库发布、无头组件库 Angular Aria 亮相、默认测试器切至 Vitest，以及 Zoneless 变更检测正式在所有新项目中默认启用**。

下面，我们将为您逐一深度盘点 Angular v21 的核心更新细节与代码示例。

---

## ⚡ 1. 实验性 Signal Forms 登场：响应式表单的全新范式

在 Angular 响应式状态管理（Signals）的宏大蓝图下，表单系统的 Signals 化一直被社区寄予厚望。在 v21 中，官方正式推出了实验性的 **Signal Forms** 库！

Signal Forms 建立在完全强类型的 Signals 基础之上，为表单模型与视图字段同步提供了一种极其自然、流畅的写法：

```typescript
import { Component, signal } from '@angular/core';
import { form, Field } from '@angular/forms/signals';

@Component({
  selector: 'app-login-form',
  standalone: true,
  imports: [Field],
  template: `
    <form>
      <!-- 使用 [field] 指令进行强类型双向绑定 -->
      Email: <input [field]="loginForm.email">
      Password: <input [field]="loginForm.password">
    </form>
  `
})
export class LoginForm {
  // 定义底层的普通 Signal 状态
  login = signal({
    email: '',
    password: ''
  });

  // 使用 form() 函数构建强类型的表单模型
  loginForm = form(this.login);
}
```

### 核心革新点：
1.  **原生类型安全**：表单数据结构在编译期直接享受强类型校验；
2.  **内置 Validation**：常见的邮箱格式、正则匹配等校验器直接支持，同时提供简单的接口自定义校验逻辑；
3.  **再见 ControlValueAccessor**：绑定自定义第三方组件无需再书写繁琐的 `ControlValueAccessor` 样板代码，可以直接利用 Signal 状态驱动。

---

## 🎨 2. Angular Aria：可访问优先的无样式（Headless）组件库

为了让开发者在享受顶级无障碍访问（a11y）设计的前提下，保留 100% 的样式主导权，官方推出了 **Angular Aria（开发者预览版）**。

这是 Angular 团队推出的第三种组件开发策略（此前有行为级 CDK 和 Material Design 规范的 Angular Material）：
*   **Aria 职责**：提供完全无样式的 HTML 交互结构，自动绑定键盘导航、ARIA 屏幕阅读器属性，您可以自由搭配 Vanilla CSS、Tailwind CSS 等进行皮肤渲染。

```bash
# 安装体验包
npm i @angular/aria
```

### 首发支持的 8 个 UI 交互模式：
*   折叠面板 (Accordion)
*   组合框 (Combobox)
*   数据网格 (Grid)
*   列表框 (Listbox)
*   菜单 (Menu)
*   选项卡 (Tabs)
*   工具栏 (Toolbar)
*   树形控件 (Tree)

---

## 🤖 3. Angular MCP Server 迈入 Stable：让 AI 更加懂 Angular

在 v20.2 引入后，Angular CLI 内置的 **MCP (Model Context Protocol) 协议服务器** 在 v21 中正式宣告稳定。

MCP 建立了 AI 编程助手（如 Claude, GPT）直接读取本地应用代码上下文与框架规范的通道。通过 MCP，您的 AI 助手可以无缝调用如下工具：
*   **最佳实践查询 (`get_best_practices`)**：返回当前版本的官方推荐范式；
*   **文档检索 (`search_documentation`)**：直接连线官方库实时解答语法疑惑；
*   **代码一键迁移 (`onpush_zoneless_migration`)**：自动分析您的遗留代码，量身定制出一份完整的 Zoneless 和 OnPush 升级改造方案；
*   **AI Tutor 交互辅导 (`ai_tutor`)**：手把手教新手学习最新的 Reactive 响应式概念。

这意味着 AI 大模型的“知识库截断”问题在 Angular 生态被彻底攻克，AI 助手在第 0 天就能完美地编写出最地道、最现代的 Angular v21 代码！

---

## 🧪 4. Vitest 成为官方默认且稳定的测试运行器

由于 Karma 已经在 2023 年被宣布废弃，Angular 团队经过广泛调研社区意见后，决定将 **Vitest 作为全新的默认测试套件驱动器**，并在 v21 中正式标记为 **Production-Ready (稳定版)**。

现在，新创建的项目执行 `ng test` 将会自动启动 Vitest 极速渲染测试，极大地缩短了开发回路。同时，旧项目也提供了自动化重构迁移命令：

```bash
ng g @schematics/angular:refactor-jasmine-vitest
```

> [!NOTE]
> Karma 和 Jasmine 仍将保持完全兼容，但 Jest 和 Web Test Runner 的官方实验性 CLI 包装将在 v22 中被移除，团队建议继续使用 Jest 的开发者改用社区第三方预设。

---

## 🕊️ 5. 挥别 Zone.js：Zoneless（无域）正式成为默认机制

这是 Angular 历史上最大的性能底层重塑之一。

在过去的版本中，Angular 依靠 `zone.js` 拦截所有的异步 API（setTimeout、Promise、DOM 事件）来感知数据变化并启动脏检查。然而 zone.js 会引入显著的初次加载性能损耗，且不利于原生 `async/await` 的优化。

在经过 Google 内部成百上千个应用在线测试、以及外部 1400 多个无鉴权公开网站的成功验证后，**从 v21 开始，新创建的 Angular 应用将不再默认包含 zone.js！**

应用启动后将直接采用原生的 **Zoneless 变更检测策略**，带来包括 Core Web Vitals 大幅改善、原生 async/await 支持、更小体积和更简单调试在内的诸多红利。

---

## 🌟 6. 其他高亮小优化

*   **模板中直接支持正则表达式**：可以直接写 `@let isValidNumber = /\d+/.test(someValue);`；
*   **`@defer` 视口触发器定制**：支持自定义 IntersectionObserver 参数，例如 `@defer (on viewport({rootMargin: '100px'}))`；
*   **类型安全的 `SimpleChanges`**：支持泛型参数，提升指令/组件生命周期钩子中的类型校验安全性；
*   **CDK 弹出层原生化**：优先使用浏览器内置的 `popover` 属性，解决弹出层在复杂容器中的层级和无障碍焦点管理问题。

---

## 🏁 总结与升级建议

Angular v21 证明了团队在拥抱 AI 时代与追求极致 Web 性能方面的决心。无论是 Signal Forms 的表单革命，还是 Zoneless 彻底移去 Zone.js 束缚，都让我们看到了框架前所未有的轻量与现代。

立刻执行下面的升级命令，开启全新的 Angular 21 冒险之旅吧！

```bash
ng update @angular/core @angular/cli
```
