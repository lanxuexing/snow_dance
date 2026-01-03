# Angular 装饰器

> Date: 2025-01-12
> Category: Blog

#### 1. @Attribute

顾名思义，是用来寻找宿主元素属性值的。

```typescript
@Directive({
  selector: '[test]'
})
export class TestDirective {
  constructor(
    @Attribute('type') type
  ) {
    console.log(type); // text
  }
}
  
@Component({
  selector: 'my-app',
  template: `
    <input type="text" test>
  `,
})
export class App {}
```


#### 2. @ViewChildren

- 装饰器可以从View DOM返回指定的元素或指令作为queryList。queryList存储的是项目列表对象，值得注意的是：**当应用程序的状态发生变化时，Angular会自动为queryList更新对象项**。
- queryList有很多API，其中：
    - getter属性：
        - first — 获取第一个item
        - last — 获取最后一个item
        - length — 返回queryList的长度
    - Method方法：
        - map()，filter()，find()，reduce()，forEach()，some()。
        - 其中toArray()，可以返回items形式的数组。
        - changes()可以进行订阅，返回items的Observable。
- queryist注意事项：
    - 只有在ngAfterViewInit生命周期方法之后才能得到。
    - 返回的item不包含ng-content标签里的item。
- 默认情况下，queryList返回的组件的实例，如果想要返回原生的Dom，则需要声明第二个参数，例如：`@ViewChildren(AlertComponent, { read: ElementRef }) alerts: QueryList<AlertComponent>`

```typescript
@Component({
  selector: 'alert',
  template: `
    {{type}}
  `,
})
export class AlertComponent {
  @Input() type: string = "success";
}

@Component({
  selector: 'my-app',
  template: `
    <alert></alert>
    <alert type="danger"></alert>
    <alert type="info"></alert>
  `,
})
export class App {
  @ViewChildren(AlertComponent) alerts: QueryList<AlertComponent>
  
  ngAfterViewInit() {
    this.alerts.forEach(alertInstance => console.log(alertInstance));
  }
}
```


#### 3. @ViewChild

和ViewChildren类似，但它只返回匹配到的第一个元素或与视图DOM中的选择器匹配的指令。

```typescript
@Component({
  selector: 'alert',
  template: `
    {{type}}
  `,
})
export class AlertComponent {
  @Input() type: string = "success";
}

@Component({
  selector: 'my-app',
  template: `
    <alert></alert>
    <div #divElement>Tada!</div>
  `,
})
export class App {
  // 返回宿主元素
  @ViewChild("divElement") div: any;
  // 返回组件实例
  @ViewChild(AlertComponent) alert: AlertComponent;
  
  ngAfterViewInit() {
    console.log(this.div);
    console.log(this.alert);
  }
}
```


#### 4. @ContentChildren

装饰器从Content DOM返回指定的元素或指令作为queryList，值得注意的是：
- 只有在ngAfterViewInit生命周期方法之后才能得到。
- ContentChildren仅包含ng-content标签内存在的元素。
- 返回的queryList和`@ViewChildren`一样。

```typescript
@Component({
  selector: 'tab',
  template: `
    <p>{{title}}</p>
  `,
})
export class TabComponent {
  @Input() title;
}

@Component({
  selector: 'tabs',
  template: `
    <ng-content></ng-content>
  `,
})
export class TabsComponent {
 @ContentChildren(TabComponent) tabs: QueryList<TabComponent>
 
 ngAfterContentInit() {
   this.tabs.forEach(tabInstance => console.log(tabInstance))
 }
}

@Component({
  selector: 'my-app',
  template: `
    <tabs>
     <tab title="One"></tab>
     <tab title="Two"></tab>
    </tabs>
  `,
})
export class App {}
```


#### 5. @ContentChild

和`@ContentChildren`类似，但仅返回与Content DOM中的选择器匹配的第一个元素或指令。

```typescript
@Component({
  selector: 'tabs',
  template: `
    <ng-content></ng-content>
  `,
})
export class TabsComponent {
 @ContentChild("divElement") div: any;
 
 ngAfterContentInit() {
   console.log(this.div);
 }
}

@Component({
  selector: 'my-app',
  template: `
    <tabs>
     <div #divElement>Tada!</div>
    </tabs>
  `,
})
export class App {}
```


#### 6. @HostBinding

声明一个属性绑定到hosts上。


```
@Directive({
  selector: '[host-binding]'
})
export class HostBindingDirective {
  @HostBinding("class.tooltip") tooltip = true;
  
  @HostBinding("class.tooltip") 
  get tooltipAsGetter() {
    // 你的逻辑
    return true;
  };
   
  @HostBinding() type = "text";
}

@Component({
  selector: 'my-app',
  template: `
    <input type="text" host-binding> // 'tooltip' class 将被添加到host元素上
  `,
})
export class App {}
```


#### 7. @HostListener

敬请期待，学习中...