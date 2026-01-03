# Angular如果设置Title和Meta信息

> Date: 2020-02-29
> Category: Blog

#### 1. 前言

我们在项目中有的时候想要动态设置网页的title，有的时候会根据某种需求去动态设置meta信息，那么在SPA的Angular中如何做到呢？（PS：当然你可能会想，直接写javascript脚本修改不就OK了？！，下面要讨论的是如何用Angular的方式去修改。）


#### 2. 如何修改网页的Title呢？

Angular在platform-browser包中为我们提供了一个[Title](https://angular.io/api/platform-browser/Title)服务，我们可以通过这个服务做到动态修改Title。

话不多说，直接上代码：

```
// Html

请输入你要设置的Title值：<input #titleInput>
<br>
<button (click)="dynamicSetTitle(titleInput.value)">点击我设置Title</button>

-----------------------------------------

// TS

import { Component } from '@angular/core';
import { Title } from '@angular/platform-browser'; // 引入包依赖


@Component({
  selector: 'my-app',
  templateUrl: './app.component.html',
  styleUrls: [ './app.component.css' ]
})
export class AppComponent  {

  constructor(
    private titleService: Title // 注入Title服务
  ) { }

  // 根据输入框输入的文本内容动态设置Title值
  dynamicSetTitle(title: string): void {
    this.titleService.setTitle(title);
  }

}
```

是不是很easy！


#### 3. 如何修改Meta信息？

Angular在platform-browser包中为我们提供了一个[Meta](https://angular.io/api/platform-browser/Meta)服务，我们可以通过这个服务做到动态修改Meta。

话不多说，直接上代码：

```
import { Component } from '@angular/core';
import { Meta } from '@angular/platform-browser'; // 引入包依赖


@Component({
  selector: 'my-app',
  templateUrl: './app.component.html',
  styleUrls: [ './app.component.css' ]
})
export class AppComponent  {

  constructor(
    private metaService: Meta
  ) {
    this.metaService.updateTag({
      name: 'description', content: '我动态设置的描述信息～'
    });
  }

}
```

OK，是不是也很简单呢？当然Meta服务提供的方法还有很多，具体如下：

```
class Meta {
  addTag(tag: MetaDefinition, forceCreation: boolean = false): HTMLMetaElement | null
  addTags(tags: MetaDefinition[], forceCreation: boolean = false): HTMLMetaElement[]
  getTag(attrSelector: string): HTMLMetaElement | null
  getTags(attrSelector: string): HTMLMetaElement[]
  updateTag(tag: MetaDefinition, selector?: string): HTMLMetaElement | null
  removeTag(attrSelector: string): void
  removeTagElement(meta: HTMLMetaElement): void
}
```


#### 4. stackblitz在线Demo

https://stackblitz.com/edit/angular-title-meta-demo