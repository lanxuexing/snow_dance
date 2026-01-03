# Angular 如何将你的Angular项目变成渐进式PWA应用

> Date: 2020-04-06
> Category: Blog

#### 1. 前言

渐进式Web应用程序（PWA）是一种Web应用程序，它提供了一组功能，可以为网站提供类似App的体验。

#### 2. 安装

==特别提醒：以下是采用了angular/cli 9.1==

- 使用脚手架将pwa集成到我们的项目里
```
// 终端命令
ng add @angular/pwa


// 以下是输出信息
localhost:d1 apple$ ng add @angular/pwa
Installing packages for tooling via npm.
Installed packages for tooling via npm.
CREATE ngsw-config.json (620 bytes)
CREATE src/manifest.webmanifest (1296 bytes)
CREATE src/assets/icons/icon-128x128.png (1253 bytes)
CREATE src/assets/icons/icon-144x144.png (1394 bytes)
CREATE src/assets/icons/icon-152x152.png (1427 bytes)
CREATE src/assets/icons/icon-192x192.png (1790 bytes)
CREATE src/assets/icons/icon-384x384.png (3557 bytes)
CREATE src/assets/icons/icon-512x512.png (5008 bytes)
CREATE src/assets/icons/icon-72x72.png (792 bytes)
CREATE src/assets/icons/icon-96x96.png (958 bytes)
UPDATE angular.json (3795 bytes)
UPDATE package.json (1319 bytes)
UPDATE src/app/app.module.ts (604 bytes)
UPDATE src/index.html (470 bytes)
✔ Packages installed successfully.
localhost:d1 apple$ 
```

从输出日志我们可以看出来，命令会添加service-worker 包，并建立必要的支持文件，如果你生成的文件不全或者写入失败则需要手动创建对应的文件。


#### 3. 运行

- 由于 ng serve 对 Service Worker 无效，所以必须用一个独立的 HTTP 服务器在本地测试你的项目。这里我们选择[http-server](https://www.npmjs.com/package/http-server)，这也是官方推荐的。

```
// 1. 全局安装http-server（PS：如果你之前安装有可以跳过这一步）
npm i -g http-server

// 2. 构建生产文件
ng build --prod

// 3. 运行项目（PS：下边的文件目录是默认目录，如果你项目做了更改则调整我自己项目构建出来的生产文件目录即可）
http-server -p 4200 -c-1 dist/<项目的名字>
```

- http-server 简单介绍
    - 1. 如果你的项目是默认打包，则使用以下终端命令：-p 是 --port 的简写，-c-1是禁用浏览器cache-control max-age。
    ```
    http-server -p 4200 -c-1 dist/<项目的名字>
    ```
    - 2. 如果你的项目是使用了gzip压缩，则使用以下终端命令：-g 是 --gzip 的简写；-p 是 --port 的简写，-c-1是禁用浏览器cache-control max-age。
    ```
    http-server -g -p 4200 -c-1 dist/<项目的名字>
    ```
    - 3. 如果你的项目是使用了brotli压缩，则使用以下终端命令：-b 是 --brotli 的简写，；-p 是 --port 的简写，-c-1是禁用浏览器cache-control max-age。
    ```
    http-server -b -p 4200 -c-1 dist/<项目的名字>
    ```

![PWA标识](https://github.com/lanxuexing/assets/raw/master/pwa/install.png)

![安装提示框](https://github.com/lanxuexing/assets/raw/master/pwa/install-tip.png)

#### 4. PWA结构介绍

- manifest.webmanifest（PS：旧版本的cli生成的文件是：manifest.json）
    它是Web应用程序清单文件，json结构，主要用于浏览器识别Web应用程序。里边有很多配置项，具体可以查阅[MDN Web app manifests](https://developer.mozilla.org/en-US/docs/Web/Manifest)。


```
{
  "name": "pwa", // 应用程序安装的的名字，主要用于浏览器上的显示
  "short_name": "pwa", // 移动设备或者iPad上的安装
  "theme_color": "#1976d2",
  "background_color": "#fafafa",
  "display": "standalone",
  "scope": "./",
  "start_url": "./",
  "icons": [
    {
      "src": "assets/icons/icon-72x72.png",
      "sizes": "72x72",
      "type": "image/png"
    },
    {
      "src": "assets/icons/icon-96x96.png",
      "sizes": "96x96",
      "type": "image/png"
    },
    {
      "src": "assets/icons/icon-128x128.png",
      "sizes": "128x128",
      "type": "image/png"
    },
    {
      "src": "assets/icons/icon-144x144.png",
      "sizes": "144x144",
      "type": "image/png"
    },
    {
      "src": "assets/icons/icon-152x152.png",
      "sizes": "152x152",
      "type": "image/png"
    },
    {
      "src": "assets/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "assets/icons/icon-384x384.png",
      "sizes": "384x384",
      "type": "image/png"
    },
    {
      "src": "assets/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}

// 上边是图标配置的一些信息，但是在Apple设备上会有问题，IOS在PWA的支持上目前还有点落后，为确保你的Web应用在IOS设备上也有一个完美的图标，将将以下代码加入到你项目的index.html的head的tag中。（PS：确保这些文件要存在于你的资产目录）

<link rel="apple-touch-icon" href="/assets/icons/apple-touch-icon-iphone.png"/>
<link rel="apple-touch-icon" sizes="152x152" href="/assets/icons/apple-touch-icon-iphone.png"/>
<link rel="apple-touch-icon" sizes="167x167" href="/assets/icons/apple-touch-icon-ipad-retina.png"/>
<link rel="apple-touch-icon" sizes="180x180" href="/assets/icons/apple-touch-icon-iphone-retina.png"/>
```

- app.module.ts

    默认PWA是在生产模式才开启，如果你想在测试环境也开启的话，请手动修改这里。
    
    
    ```
    import { BrowserModule } from '@angular/platform-browser';
    import { NgModule } from '@angular/core';
    
    import { AppRoutingModule } from './app-routing.module';
    import { AppComponent } from './app.component';
    import { ServiceWorkerModule } from '@angular/service-worker';
    import { environment } from '../environments/environment';
    
    @NgModule({
      declarations: [
        AppComponent
      ],
      imports: [
        BrowserModule,
        AppRoutingModule,
        ServiceWorkerModule.register('ngsw-worker.js', { enabled: environment.production }) // <=== 手动修改这里，去掉enabled即可所有环境开启PWA
      ],
      providers: [],
      bootstrap: [AppComponent]
    })
    export class AppModule { }

    ```


- ngsw-config.json
    顾名思义，是angular工程创建pwa的配置文件。

```
{
  "$schema": "./node_modules/@angular/service-worker/config/schema.json",
  "index": "/index.html",
  "assetGroups": [ // 资产组配置
    {
      "name": "app",
      "installMode": "prefetch", // 安装策略，默认拉取所有资源，好处是脱机状态下也能使用Web APP，另一种备用策略是：lazy，即按需安装。
      "resources": {
        "files": [
          "/favicon.ico",
          "/index.html",
          "/manifest.webmanifest",
          "/*.css",
          "/*.js"
        ]
      }
    }, {
      "name": "assets",
      "installMode": "lazy", // 资产缓存，默认是用lazy策略。
      "updateMode": "prefetch", // 使用lazy策略之后需要设置更新模式为：prefetch，这样有新的更新可以主动更新。
      "resources": {
        "files": [
          "/assets/**",
          "/*.(eot|svg|cur|jpg|png|webp|gif|otf|ttf|woff|woff2|ani)"
        ]
        "urls": [ // 这里是使用外部服务器或者CDN的配置，比如这里我设置了使用Google字体
            "https://fonts.googleapis.com/**"
        ]
      }
    }
  ],
  "dataGroups": [{ // 数据组配置，与资产组配置不同的是，这里的配置没有被打包在Web APP里，比如下边这个是使用了外部API。数组组配置支持两种策略：freshness 和 performance。freshness多用于经常更新的资源，即：始终尝试获取最新的版本资源，然后再回退到缓存里。performance策略是默认策略，对于变化不大的资源有用。
      "name": "api-freshness",
      "urls": [ "https://my.apipage.com/user" ], // 这里的配置是：从/user接口拉取数据
      "cacheConfig": { // 缓存配置
        "strategy": "freshness",
        "maxSize": 5, // 最多同时支持5个相应
        "maxAge": "1h", // 最多缓存一小时
        "timeout": "3s" // 超时时间是3秒
      }
    }
  ]
}

```

![PWA面板](https://github.com/lanxuexing/assets/raw/master/pwa/console.png)

![PWA资源拉取](https://github.com/lanxuexing/assets/raw/master/pwa/pull.png)


#### 5. PWA更新

PWA @angular/service-worker 中的 SwUpdate 提供更新检测，也就是说当用户正在使用Web APP或者网页版网站时，我们刚好部署了新版本，这个时候就可以使用SwUpdate的trigger机制，通知用户更新新版本。

![PWA版本更新](https://github.com/lanxuexing/assets/raw/master/pwa/update.png)

那么如何实现这个功能呢？其实也很简单，我们创建一个服务，然后订阅这个服务就好了，当有版本更新的时候，PWA的服务会收到这个回调，我们在回调里处理我们的逻辑即可。话不多说，上代码啦～

- sw-updates.service.ts

```
import { ApplicationRef, Injectable, OnDestroy } from '@angular/core';
import { SwUpdate } from '@angular/service-worker';
import { concat, interval, NEVER, Observable, Subject } from 'rxjs';
import { first, map, takeUntil, tap } from 'rxjs/operators';


/**
 * SwUpdatesService
 *
 * @description
 * 1. 实例化后检查可用的ServiceWorker更新.
 * 2. 每6小时重新检查一次.
 * 3. 只要有可用的更新, 就会激活更新.
 *
 * @propertys
 * `updateActivated` {Observable<string>} - 每当激活更新时，发出版本哈希.
 */
@Injectable({
  providedIn: 'root'
})
export class SwUpdatesService implements OnDestroy {
  private checkInterval = 1000 * 60 * 60 * 6; // 6 小时
  private onDestroy = new Subject<void>();
  updateActivated: Observable<string>;

  constructor(
    appRef: ApplicationRef,
    private swu: SwUpdate
  ) {
    if (!swu.isEnabled) {
      this.updateActivated = NEVER.pipe(takeUntil(this.onDestroy));
      return;
    }

    // 定期检查更新(在应用稳定后).
    const appIsStable = appRef.isStable.pipe(first(v => v));
    concat(appIsStable, interval(this.checkInterval))
        .pipe(
            tap(() => this.log('Checking for update...')),
            takeUntil(this.onDestroy),
        )
        .subscribe(() => this.swu.checkForUpdate());

    // 激活可用的更新.
    this.swu.available
        .pipe(
            tap(evt => this.log(`Update available: ${JSON.stringify(evt)}`)),
            takeUntil(this.onDestroy),
        )
        .subscribe(() => this.swu.activateUpdate());

    // 通知已激活的更新.
    this.updateActivated = this.swu.activated.pipe(
        tap(evt => this.log(`Update activated: ${JSON.stringify(evt)}`)),
        map(evt => evt.current.hash),
        takeUntil(this.onDestroy),
    );
  }

  ngOnDestroy() {
    this.onDestroy.next();
  }

  private log(message: string) {
    const timestamp = new Date().toISOString();
    console.log(`[SwUpdates - ${timestamp}]: ${message}`);
  }
}
```

- app.component.ts

```
import { Component, OnInit } from '@angular/core';
import { SwUpdatesService } from './sw-updates.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
  title = 'pwa';

  constructor(
    private swUpdates: SwUpdatesService
  ) { }

  ngOnInit(): void {
    this.swUpdates.updateActivated.subscribe(_ => {
      if (confirm('检测到版本更新，是否更新到最新版本？(╯#-_-)╯~~')) {
        window.location.reload();
      }
    });
  }

}
```


#### 6. PWA消息推送

在PWA @angular/service-worker 的 SwPush 中，我们可以订阅并接收来着Service Worker的推送通知，当然我们需要借助服务器来实现这个机制，下边是简单的开发模式实现，后续有时间我再更新文章啦～

![PWA消息推送](https://github.com/lanxuexing/assets/raw/master/pwa/push.png)

- 前端代码实现

```
import { Component } from '@angular/core';
import { SwPush } from '@angular/service-worker';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  title = 'pwa';

  constructor(
    private swPush: SwPush
  ) {
    // 监听通知的点击事件
    this.swPush.notificationClicks.subscribe(event => {
      console.log('消息推送: ', event);
      const url = event.notification.data.url;
      window.open(url, '_blank'); // 这里是点击推送的通知后跳转新页面
    });

  }

}
```

