# Rxjs6都改变了些什么？

> Date: 2019-06-05
> Category: Blog

# RxJS 6变化-概述

    RxJS 6主要用于Angular应用程序，从Angular 6开始，它是一个强制依赖。

    与RxJS版本5相比，RxJS 6（或更高版本）引入了两个重要更改：
    1. import的导入结构发生变化
    2. pipe()作为一种链接运算符的方法，旧的链接方式将不起作用
    3. 一些operator操作符被重命名
    
    特别提示： 如果你让旧的代码仍旧继续使用，你需要进行以下操作（不推荐再用旧的方法了）
    npm install --save rxjs-compat  // 安装向后兼容依赖包
    
    
#### 1. 对于import语句，变化如下：

- Observable, Subject
```typescript
// 以前：
import { Observable } from 'rxjs/Observable'
import { Subject } from 'rxjs/Subject'

// 现在：
import { Observable, Subject } from 'rxjs
```

- Operators
```typescript
// 以前：
import 'rxjs/add/operator/map'
import 'rxjs/add/operator/take'

// 现在
import { map, take } from 'rxjs/operators'
```

- Methods to Create Observables
```typescript
// 以前：
import 'rxjs/add/observable/of'
// or
import { of } from 'rxjs/observable/of'

// 现在：
import { of } from 'rxjs'
```

#### 2. 在Rxjs6中如何使用operator操作符
```typescript
// 以前：
import 'rxjs/add/operator/map'

myObservable
  .map(data => data * 2)
  .subscribe(...);
  
// 现在：
import { map } from 'rxjs/operators';

myObservable
  .pipe(map(data => data * 2))
  .subscribe(...);
```
- 特别声明：在rxjs6中引入的pipe()方法（它实际上已经在RxJS 5.5中添加）,pipe获取无限量的参数，每个参数都是您想要应用于的operator Observable, 像下边这样：(rxjs会按照你将它们传递给pipe()方法的顺序执行- 从左到右。)
```typescript
import { map, switchMap, throttle } from 'rxjs/operators';

myObservable
  .pipe(map(data => data * 2), switchMap(...), throttle(...))
  .subscribe(...);
```

#### 3. 重命名的operator操作符
```typescript
// operator相关
catch() => catchError()

do() => tap()

finally() => finalize()

switch() => switchAll()


// Observable相关
throw() => throwError()

fromPromise() => from()  // 自动检测类型
```

---

#### 后记

```
这个是YouTube的链接，如果有需要的可以看看更详细的，传送门在底下蓝色超链接！
```


[Fix your RxJS 6 Imports & Operators - What's New in RxJS 6?](https://www.youtube.com/watch?v=X9fdpGthrXA&feature=youtu.be)