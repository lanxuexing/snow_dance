# Rxjs【combineLatest、withLatestFrom、zip】

> Date: 2020-01-11
> Category: Blog

# Rxjs学习之路

#### 1、小贴士

这篇文章是我的Angular Rxjs Series中的第六篇文章，在继续阅读本文之前，您至少应该熟悉系列中的第一篇基础文章

[Rxjs6都改变了些什么？](https://www.jianshu.com/p/ce1a15957a7f)

[Rxjs【Observable】](https://www.jianshu.com/p/fc0e30328de3)

```typescript
// 图谱
// ----- 代表一个Observable
// -----X 代表一个Observable有错误发生
// -----| 代表一个Observable结束
// (1234)| 代表一个同步Observable结束

// 以下的操作符介绍均采用rxjs6的写法！！！
```

#### 2、combineLatest

combineLatest可以接收多个Observable，但最后一个参数一定是callback function，这个回调函数接收的参数个数和前边传入Observable一一对应，最后需要注意，一定至少有2个Observable送出新值的时候才会执行回调函数。

```typescript
/**
 * 取得各个observable 最后送出的值，再输出成一个值
 * combineLatest可以接收多个observable，最后一个参数是callback function，这个callback function接收的参数数量跟合并的observable数量相同
 * callback 都会依照合并的observable 数量来传入参数，如果我们合并了三个observable，callback 就会有三个参数，而不管合并几个observable 都会只会回传一个值。
 * source:      ----0----1----2|
 * newest:      --0--1--2--3--4--5|
 *          combineLatest(newest, (x, y) => x + y);
 * example:     ----01--23-4--(56)--7|
 */
const source = interval(500).pipe(take(3));
const newest = interval(300).pipe(take(6));
const combineLatestObservable = source.pipe(combineLatest(newest, (x, y) => x + y));
this.combineLatestSubscription = combineLatestObservable.subscribe({
    next: (value) => { console.log('=====combineLatest操作符: ', value); },
    error: (err) => { console.log('=====combineLatest操作符: Error: ', err); },
    complete: () => { console.log('=====combineLatest操作符: complete!'); }
});
```
- 从上边的例子，我们可以看到，newest送出0时，source此时没有送出值，因此不执行回调函数，当source送出0时，此时newest送出的最新值是之前的0，执行回调0+0=0，以此类推...


#### 3、withLatestFrom

withLatestFrom其实和combineLatest很像，唯一不同的是他多了一个主从关系，即只有主Observable送出新值的时候，才会执行callback function，其他情况下不会触发回调。
    

```typescript
/**
 * 和combineLatest类似，但是withLatestFrom只有在主要的observable 送出新的值时，才会执行callback，附随的observable 只是在背景下运作
 * withLatestFrom 会在main 送出值的时候执行callback，但请注意如果main 送出值时some 之前没有送出过任何值callback 仍然不会执行！
 * callback 都会依照合并的observable 数量来传入参数，如果我们合并了三个observable，callback 就会有三个参数，而不管合并几个observable 都会只会回传一个值。
 * main:       ----h----e----l----l----o|
 * some:       --0--1--0--0--0--1|
 *         withLatestFrom(some, (x, y) => y === 1 ? x.toUpperCase() : x);
 * example:    ----h----e----l----L----O|
 */
const main = from('hello').pipe(zip(interval(500), (x, y) => x));
const some = from([0, 1, 0, 0, 0, 1]).pipe(zip(interval(300), (x, y) => x));
const withLatestFromObservable = main.pipe(withLatestFrom(some, (x, y) => y === 1 ? x.toUpperCase() : x));
this.withLatestFromSubscription = withLatestFromObservable.subscribe({
    next: (value) => { console.log('=====withLatestFrom操作符: ', value); },
    error: (err) => { console.log('=====withLatestFrom操作符: Error: ', err); },
    complete: () => { console.log('=====withLatestFrom操作符: complete!'); }
});
```
- 从上边的例子，我们可以观察到：main送出h时，some的最新值是上一次的0，0不等于1，所以原样输出main，即h。当main送出e时，some送出的新值是上一次0，0不等于1，所以原样输出main，即e。以此类推...


#### 4、zip

zip会取每个Observable且按顺序传入callback function回调函数的参数中，简单的理解就是一一对应，成双成对。
    

```typescript
/**
 * 取每个observable 相同顺位的元素并传入callback，也就是说每个observable 的第n 个元素会一起被传入callback
 * zip 会把各个observable 相同顺位送出的值传入callback
 * zip 必须cache 住还没处理的元素，当我们两个observable 一个很快一个很慢时，就会cache 非常多的元素，等待比较慢的那个observable。这很有可能造成记忆体相关的问题！
 * callback 都会依照合并的observable 数量来传入参数，如果我们合并了三个observable，callback 就会有三个参数，而不管合并几个observable 都会只会回传一个值。
 * source:      ----0----1----2|
 * newest:      --0--1--2--3--4--5|
 *            zip(newest, (x, y) => x + y)
 * exaple:      ----0----2----4|
 */
const source = interval(500).pipe(take(3));
const newest = interval(300).pipe(take(6));
const zipObservable = source.pipe(zip(newest, (x, y) => x + y));
this.zipSubscription = zipObservable.subscribe({
    next: (value) => { console.log('=====zip操作符: ', value); },
    error: (err) => { console.log('=====zip操作符: Error: ', err); },
    complete: () => { console.log('=====zip操作符: complete!'); }
});
```


##### 完整例子

```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subscription, interval, from } from 'rxjs';
import { take, combineLatest, zip, withLatestFrom } from 'rxjs/operators';

@Component({
    selector: 'app-rxjs-demo06',
    template: `
        <h3>Rxjs Demo06 To Study! -- Operators操作符(combineLatest, withLatestFrom, zip)</h3>
        <button (click)="combineLatestHandler()">combineLatest</button>
        <button class="mgLeft" (click)="withLatestFromHandler()">withLatestFrom</button>
        <button class="mgLeft" (click)="zipHandler()">zip</button>
        <app-back></app-back>
    `,
    styles: [`
        .mgLeft {
            margin-left: 20px;
        }
    `]
})
export class RxjsDemo06Component implements OnInit, OnDestroy {
    combineLatestSubscription: Subscription;
    withLatestFromSubscription: Subscription;
    zipSubscription: Subscription;

    constructor() { }

    ngOnInit(): void {
        // 图谱
        // ----- 代表一个Observable
        // -----X 代表一个Observable有错误发生
        // -----| 代表一个Observable结束
        // (1234)| 代表一个同步Observable结束
    }

    combineLatestHandler() {
        /**
         * 取得各个observable 最后送出的值，再输出成一个值
         * combineLatest可以接收多个observable，最后一个参数是callback function，这个callback function接收的参数数量跟合并的observable数量相同
         * callback 都会依照合并的observable 数量来传入参数，如果我们合并了三个observable，callback 就会有三个参数，而不管合并几个observable 都会只会回传一个值。
         * source:      ----0----1----2|
         * newest:      --0--1--2--3--4--5|
         *          combineLatest(newest, (x, y) => x + y);
         * example:     ----01--23-4--(56)--7|
         */
        const source = interval(500).pipe(take(3));
        const newest = interval(300).pipe(take(6));
        const combineLatestObservable = source.pipe(combineLatest(newest, (x, y) => x + y));
        this.combineLatestSubscription = combineLatestObservable.subscribe({
            next: (value) => { console.log('=====combineLatest操作符: ', value); },
            error: (err) => { console.log('=====combineLatest操作符: Error: ', err); },
            complete: () => { console.log('=====combineLatest操作符: complete!'); }
        });
    }

    withLatestFromHandler() {
        /**
         * 和combineLatest类似，但是withLatestFrom只有在主要的observable 送出新的值时，才会执行callback，附随的observable 只是在背景下运作
         * withLatestFrom 会在main 送出值的时候执行callback，但请注意如果main 送出值时some 之前没有送出过任何值callback 仍然不会执行！
         * callback 都会依照合并的observable 数量来传入参数，如果我们合并了三个observable，callback 就会有三个参数，而不管合并几个observable 都会只会回传一个值。
         * main:       ----h----e----l----l----o|
         * some:       --0--1--0--0--0--1|
         *         withLatestFrom(some, (x, y) => y === 1 ? x.toUpperCase() : x);
         * example:    ----h----e----l----L----O|
         */
        const main = from('hello').pipe(zip(interval(500), (x, y) => x));
        const some = from([0, 1, 0, 0, 0, 1]).pipe(zip(interval(300), (x, y) => x));
        const withLatestFromObservable = main.pipe(withLatestFrom(some, (x, y) => y === 1 ? x.toUpperCase() : x));
        this.withLatestFromSubscription = withLatestFromObservable.subscribe({
            next: (value) => { console.log('=====withLatestFrom操作符: ', value); },
            error: (err) => { console.log('=====withLatestFrom操作符: Error: ', err); },
            complete: () => { console.log('=====withLatestFrom操作符: complete!'); }
        });
    }

    zipHandler() {
        /**
         * 取每个observable 相同顺位的元素并传入callback，也就是说每个observable 的第n 个元素会一起被传入callback
         * zip 会把各个observable 相同顺位送出的值传入callback
         * zip 必须cache 住还没处理的元素，当我们两个observable 一个很快一个很慢时，就会cache 非常多的元素，等待比较慢的那个observable。这很有可能造成记忆体相关的问题！
         * callback 都会依照合并的observable 数量来传入参数，如果我们合并了三个observable，callback 就会有三个参数，而不管合并几个observable 都会只会回传一个值。
         * source:      ----0----1----2|
         * newest:      --0--1--2--3--4--5|
         *            zip(newest, (x, y) => x + y)
         * exaple:      ----0----2----4|
         */
        const source = interval(500).pipe(take(3));
        const newest = interval(300).pipe(take(6));
        const zipObservable = source.pipe(zip(newest, (x, y) => x + y));
        this.zipSubscription = zipObservable.subscribe({
            next: (value) => { console.log('=====zip操作符: ', value); },
            error: (err) => { console.log('=====zip操作符: Error: ', err); },
            complete: () => { console.log('=====zip操作符: complete!'); }
        });
    }

    ngOnDestroy() {
        if (this.combineLatestSubscription) {
            this.combineLatestSubscription.unsubscribe();
        }
        if (this.withLatestFromSubscription) {
            this.withLatestFromSubscription.unsubscribe();
        }
        if (this.zipSubscription) {
            this.zipSubscription.unsubscribe();
        }
    }
}
```


---

#### Marble Diagrams【宝珠图】

    1. 这个Marble Diagrams【宝珠图】可以很灵活的表现出每个操作符的使用
    2. 下面是超链接传送门
    
[Marble Diagrams【宝珠图】](https://rxmarbles.com/)


#### Angular Rxjs Series

1. [Rxjs6都改变了些什么？](https://www.jianshu.com/p/ce1a15957a7f)
2. [Rxjs【Observable】](https://www.jianshu.com/p/fc0e30328de3)
3. [Rxjs【map、mapTo、filter】](https://www.jianshu.com/p/b81a5ad72641)
4. [Rxjs【take, first, takeUntil, concatAll】](https://www.jianshu.com/p/55b6df31cc3e)
5. [Rxjs【skip, takeLast, last, concat, startWith, merge】]([https://www.jianshu.com/p/5165dc302fae](https://www.jianshu.com/p/5165dc302fae)
)

