# Angular如何代理到后端服务器

> Date: 2019-04-14
> Category: Blog

#### 1、问题

    在Angular应用程序中，我们在开发阶段经常要与后端服务器进行交互，由于前后端是分离的，这个时候我们前端要调用后端接口获取数据就会面临跨域的问题。
    
    
#### 2、代理

    1. 在解决跨域问题前，让我们先了解一下什么是代理？通常代理服务器就是充当我们应用程序和Internet之间的网关，它是客户端和服务器之间的中间服务器，通过客户端请求转发资源。
    
    2. 在Angular中，我们经常在开发环境中使用代理。Angular使用的是webpack dev server在开发模式下（development environment）为应用程序提供服务。
    
    3. 例如下图：我们前端的Angular应用程序运行在4200端口上，而后端服务器运行在3700端口，所有以/api开头的接口调用都会通过代理重定向到后端服务器，并且所有调用都reset到同一端口。

<html>
    <img src="https://upload-images.jianshu.io/upload_images/8303589-85a2bb75e9ca7710.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" referrerpolicy="no-referrer">
</html>



#### 3、proxy.conf.json

    在配置代理之前我们需要先了解一下代理相关的配置项：
    
    1. target：定义后端URL
    2. pathRewrite：重写路径
    3. changeOrigin：如果后端API没有在localhost上运行，则需要将此选项设置为true
    4. logLevel：如果要检查代理配置是否正常工作，此选项设置为debug
    5. bypass：有时我们必须绕过代理，可以用这个定义一个函数。但它应该在proxy.conf.js而不是proxy.conf.json中定义。（下面会有详细讲解）
    

#### 4、使用Angular CLI进行代理设置

- 首先需要在项目根目录下建立文件：proxy.conf.json

```json
{
    "/api/*": {
    "target": "http://localhost:3700",
    "secure": false,
    "logLevel": "debug",
    "changeOrigin": true
  }
}
```

- 然后在package.json中进行配置，让Angular找到我们配置好的`proxy.conf.json`文件【第一种方法】

```json
{
    "scripts": {
        "ng": "ng",
        "start": "ng serve --proxy-config proxy.conf.json",
        "build": "ng build",
        "test": "ng test",
        "lint": "ng lint",
        "e2e": "ng e2e"
    }
}
```

- 让Angular找到我们配置好的`proxy.conf.json`文件【第二种方法】


```json
{
    "serve": {
        "builder": "@angular-devkit/build-angular:dev-server",
        "options": {
            "browserTarget": "api:build",
            "proxyConfig": "proxy.conf.json"
        },
        "configurations": {
            "production": {
                "browserTarget": "api:build:production"
            }
        }
    },
}
```

- 最后，启动项目，访问接口啦-_-#


```vim
// 1. 终端运行命令
npm start
// 2. 访问Angular项目
http://localhost:4200
```


#### 5、思考一

    当有一天后端接口地址发生了变化，例如：/api/settings 变成了 /api/app/settings ，这个时候我们前端人员也需要进行相应的修改，可能有改很多地方，那么有没有一种简便的办法一劳永逸呢？答案是肯定的，这个时候proxy.conf.json文件的pathRewrite选项就派上用场了。
    
- proxy.conf.json修改如下：
```json
{
    "/api/*": {
    "target": "http://localhost:3700",
    "secure": false,
    "logLevel": "debug",
    "changeOrigin": true,
    "pathRewrite": {
      "^/api/settings": "/api/app/settings",
      "^/api": ""
    }
  }
}
```

- 修改完成之后重启

```vim
// 1. 终端运行命令
npm start
// 2. 访问Angular项目
http://localhost:4200
```


#### 6、思考二

    项目里有很多个模块要访问很多模块下的接口，这个时候我们的proxy.conf.json文件重复的代码就变得很多了，这个时候有没有简便一点的重构方法呢？答案仍旧是肯定的，这个时候就要用到前面我们提到过的proxy.conf.js了而不是proxy.conf.json。
    
- proxy.conf.js

```js
const PROXY_CONFIG = [
    {
        context: [
            "/api"
            "/userapi",
            "/settingsapi",
            "/productapi",
        ],
        target: "http://localhost:3700",
        secure: false
    }
]

module.exports = PROXY_CONFIG;
```

- 同样的，我们也需要在angular.json文件里进行配置，让Angular找到我们的`proxy.conf.js`配置文件

```json
{
    "serve": {
          "builder": "@angular-devkit/build-angular:dev-server",
          "options": {
            "browserTarget": "api:build",
            "proxyConfig": "proxy.conf.js"
          },
          "configurations": {
            "production": {
              "browserTarget": "api:build:production"
            }
          }
        },
}
```

- 修改完成之后重启

```vim
// 1. 终端运行命令
npm start
// 2. 访问Angular项目
http://localhost:4200
```


#### 7、思考三
    
    现实开发中我们与服务器交互的过程中可能还会涉及到跨多个服务器去请求数据，这个时候我们的项目中就需要调用好几个服务器的地址（协议、端口、IP不一样），这个时候我们该怎么办呢？机灵的小伙伴估计已经想到了，那就是在proxy.conf.json里配置多条就可以了。

<html>
    <img src="https://upload-images.jianshu.io/upload_images/8303589-fd8b3a15b32c763d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" referrerpolicy="no-referrer">
</html>

    

- proxy.conf.json

```json
{
  "/user/*": {
    "target": "http://localhost:3700",
    "secure": false,
    "logLevel": "debug"
  },
  "/product/*": {
    "target": "http://localhost:3800",
    "secure": false,
    "logLevel": "debug"
  },
  "/settings/*": {
    "target": "http://localhost:3900",
    "secure": false,
    "logLevel": "debug"
  }
}
```

#### 特别声明

文章出自medium，我进行了一下翻译和总结，如果想查看原文的，可以通过以下链接进行查看：

[Angular — How To Proxy To Backend Server](https://medium.com/bb-tutorials-and-thoughts/angular-how-to-proxy-to-backend-server-6fb37ef0d025)
