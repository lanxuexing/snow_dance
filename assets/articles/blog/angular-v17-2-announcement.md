---
title: Angular v17.2 正式发布：Signal 视图查询、Model 双向绑定与 M3 预览
date: 2024-02-15
category: Blog
excerpt: Angular v17.2 带来了一连串振奋人心的“小版本惊喜”：实验性支持 Material 3 规范、推出了基于 Signals 的全新视图/内容查询 API（Signal Queries）、支持双向绑定的 model() 输入属性，并在 DevTools 中加入了水合调试支持。
---

# Angular v17.2 正式发布：Signal 视图查询、Model 双向绑定与 M3 预览

虽然常规的 Minor（次要）版本更新通常只包含 bug 修复，但 **Angular v17.2** 的发布绝对算得上是个例外，它带来了许多极具重量级的新特性预览。

本次更新主要围绕 **Signals 现代响应式模型演进** 展开，并在打包工具链、图像组件和 Material Design 3 生态上迈出了扎实的一步。

---

## ⚡ 1. 信号驱动查询：Signal Queries（开发者预览）

自 2016 年 Angular 2 发布以来，传统的视图查询方式（如 `@ViewChild` 和 `@ContentChildren`）就一直存在着类型安全不足、缺乏人机工学的问题。

为了让查询机制完美契合 Signals 的细粒度数据更新模型，v17.2 推出了全新的 **Signal-based Queries**（信号查询）API：

```typescript
import { Component, ElementRef, viewChild, viewChildren } from '@angular/core';

@Component({
  standalone: true,
  template: `
    <div #containerEl>内容容器</div>
  `
})
export class App {
  // 返回 Signal<ElementRef<HTMLDivElement> | undefined>
  containerEl = viewChild<ElementRef<HTMLDivElement>>('containerEl');

  // required 形式：确保信号的值绝不为 undefined，若找不到则直接抛出编译/运行异常
  requiredEl = viewChild.required<ElementRef<HTMLDivElement>>('containerEl');

  // 返回只读的列表信号 Signal<readonly ElementRef<HTMLDivElement>[]>
  items = viewChildren('containerEl');
}
```

这套 API 不仅消除了类型安全隐患，还使得子组件的生命周期查询变得前所未有的清爽和符合直觉。

---

## 🔄 2. 信号驱动的双向绑定：Model Inputs（开发者预览）

在 v17.1 中，Angular 引入了只读的 `input()` 信号输入属性（Signal Inputs），用以推行组件间单向数据流的开发最佳实践。

但对于许多需要跨父子组件进行“状态双向同步”的场景，我们需要一个可写的 Signals 桥梁。v17.2 正式推出了 `model()` API，用以恢复信号驱动的**双向数据绑定**：

```typescript
import { Component, model } from '@angular/core';

@Component({
  selector: 'custom-checkbox',
  template: `
    <div class="checkbox-wrapper">
      <input type="checkbox" (click)="toggle()" [checked]="checked()">
    </div>
  `
})
export class CustomCheckbox {
  // 声明一个可写的 model 信号属性，默认值为 false
  checked = model(false);

  toggle() {
    // 允许在子组件内部直接改写状态，并实时向上传递给父组件的绑定源
    this.checked.set(!this.checked());
  }
}
```

有了 `model()` 之后，父组件就可以用 `[(checked)]="mySignal"` 进行经典的 Banana-in-a-box 双向绑定了。

---

## 🎨 3. 实验性支持 Material 3 (M3)

Angular 团队与谷歌 Material Design 团队深度合作，在 v17.2 中完成了对最新 Web 端 **Material 3 规范** 的实验性适配。

此次重构引入了全新的 HTML 节点结构和更细粒度的 Sass Token 混合宏，为接下来 v18 中 M3 统一主题系统的彻底稳定打下了扎实的技术底座。

---

## 🏎️ 4. 图像优化组件 NgOptimizedImage 再次增强

在性能优化方面，`NgOptimizedImage` 引入了两个重量级补充：

### 1. 自动生成模糊占位图（Automatic Placeholders）
现在只需在图片标签上添加 `placeholder` 属性，图像指令就会自动去下载一个微缩版的图片，进行高斯模糊后充当占位，直到高清大图下载完毕并自动渐进替换：
```html
<img ngSrc="hero.jpg" width="800" height="600" placeholder>
```
该特性不仅支持动态 Loader 自动生成，还支持直接内联传入 Base64 编码的占位像素。

### 2. 新增 Netlify 图片加载器
引入了 `provideNetlifyLoader`，让使用 Netlify CDN 托管静态资源的项目能一键开启源文件自动 srcset 缩放调优。

---

## 🛠️ 5. 水合调试支持与开发工具链进化

*   **Angular DevTools 支持 Hydration 调试**：引入了水合 DOM 树比对的可视化检查。当浏览器渲染的 DOM 与服务端 Node.js 吐出的 HTML 结构因数据不一致而发生不匹配时，DevTools 中会以红绿色高亮直观地指出冲突的具体节点。
*   **Bun 运行时集成**：Angular CLI 现已原生支持并识别 `Bun` 包管理器。
*   **Vite 预构建控制**：允许在配置中直接干预 Vite 开发服务器的模块依赖预打包（Pre-bundling）范围。

---

## 🏁 总结

Angular v17.2 是在 Signals 革命路线上承上启下的关键小版本。Signal Queries 和 Model Inputs 的到来，标志着 Angular 正从模板层（控制流）到逻辑层（状态输入输出）实现**全链路的信号化升级**。推荐所有使用 v17 的项目尽快运行 `ng update` 进行平稳升级！
