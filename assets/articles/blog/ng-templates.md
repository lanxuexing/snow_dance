# angular templates模版内函数的最佳实践

> Date: 2020-01-11
> Category: Blog

#### 1. 前言

```
在angular中，我们应该在templates中尽可能的少写逻辑代码，保持简洁，这样页面的加载效率会更好。但是我们经常会遇到要将某某属性绑定到元素上，又或者转换、动态计算以便插入对应的字符串。当我们在templates模版（插值表达式{{}}）中调用函数进行数据绑定或者字符串插值的时候，我们会发现我们的函数会被无限次调用（含鼠标在页面上移动）！

这是个很糟糕的体验，那么究其原因是什么呢？答案是：angular变更检测机制。函数在angular生命周期钩子函数ngDoCheck之后，这个钩子函数直接链接到每个变化检测周期。虽然templates模版（插值表达式{{}}）提供了getter方法，但它只能从某个变量中访问属性，我们如果计算函数更复杂，那么就会浪费用户机器资源，因为我们必须使用资源来计算相同的结果。
```

#### 2. Angular纯管道

我们理想的是：只有在传递的任何参数发生变化时才应调用我们的函数。解决方案就是：Angular纯管道！它监视不可变类型的值更改以及对象的引用更改。如果想了解更详细的pipe管道信息可以查阅官方文档
[纯(pure)管道与非纯(impure)管道
](https://www.angular.cn/guide/pipes#pure-and-impure-pipes)。

- Angular纯管道方案：


```typescript
import {Pipe, PipeTransform} from '@angular/core';

@Pipe({
  name: 'execute'
})
export class ExecutePipe implements PipeTransform {

  transform(value: Function, context, ...args): any {
    if (value instanceof Function) {
      return value.apply(context, args);
    }
  }

}
```

- 使用方法

```
假设组件中有一个命名的函数getErrorMessage负责根据flag和用户获取某些消息role。使用方式如下：
{{getErrorMessage | execute:this:flag:role}}
```