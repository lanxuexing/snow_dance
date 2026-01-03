# Flutter 常见问题及其解决方案

> Date: 2019-05-25
> Category: Blog

#### 1. Waiting for another flutter command to release the startup lock...


```vim
// 杀死dart进程
flutter packages pub build_runner watch

// 终极方案,删除flutter SDK文件夹目录下的bin/cache下边的lockfile文件
rm ./flutter/bin/cache/lockfile
```


#### 2. Could not find a file named "pubspec.yaml" in https://github.com/MarkOSullivan94/dart_config.git 7a88fbc5fd987dce78e468ec45e9e841a49f422d.


```vim
// 删除flutter SDK文件夹目录下的.pub-cache下边的git文件夹
rm ./flutter/.pub-cache/git
```


#### 3.点击任意空白处，软键盘收起


```dart
GestureDetector(
    /// 透明也响应处理
    behavior: HitTestBehavior.translucent,
    onTap: () {
      /// 触摸收起键盘
      FocusScope.of(context).requestFocus(FocusNode());
    },
    child: Container(
       /// xxx
    ),
);

```


#### 4. Oops; flutter has exited unexpectedly. Sending crash report to Google.

```dart
/// 在终端执行命令
xcode-select --install
```


#### 5. 页面返回隐藏虚拟导航条
```dart
@override
void deactivate() {
    SystemChrome.restoreSystemUIOverlays();
    super.deactivate();
}
```


#### 6. 如果没有网络连接，如何启动静态html页面而不是URL ?【webview】
```dart
Future check() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connectionStatus = true;
        print("connected $connectionStatus");
      }
    } on SocketException catch (_) {
      connectionStatus = false;
      print("not connected $connectionStatus");
    }
}

FutureBuilder(
    future: check(),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if (connectionStatus == true) {
        /// 如果网络正常连接
        return SafeArea(
            child: WebviewScaffold(
                url: "http://www.baidu.com",
            ),
        ),
      } else { 
        /// 如果网络连接失败
        return SafeArea(
            child: WebviewScaffold(
              url: Uri.dataFromString('<html><body>hello world</body></html>',
              mimeType: 'text/html').toString()
            ),
        ),
      }
    }
)
```


#### 7. 判断当前路由是否在栈顶
```dart
// ModalRoute.of(context) API可以获取当前路由对象以及当前页面的所有属性
// 如果路由active，还位于最顶层，则isCurrent为true
ModalRoute.of(context).isCurrent
```

#### 8. B widget嵌套在A Widget里（两个Widget分别在不同的Class里），如何在B Widget里获取A Widget的数据（变量、state、方法等等）并修改呢？
```dart
class A extends StatefulWidget {
  A({Key key}) : super(key: key);
  _AState createState() => _AState();
}

class _AState extends State<A> {
  /// 这个是A widget定义的一个变量
  var name = 'Jerry';

  /// 这个是B Widget里声明的方法
  void getName() {
    /// TODO
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       /// 这里嵌套了B Widget
       child: B(),
    );
  }
}

class B extends StatefulWidget {
  B({Key key}) : super(key: key);
  _BState createState() => _BState();
}

class _BState extends State<B> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        child: Text('this is B Widget!'),
        onTap: () {
          setState(() {
            /// 在B Widget里边怎么获取A Widget的变量并修改呢？, 方案如下：
            _AState aWidgetState = context.ancestorStateOfType(TypeMatcher<_AState>());
            /// 获取A里的变量
            aWidgetState.name = 'Anna';
            /// 调用A里的方法
            aWidgetState.getName();
          });
        },
      ),
    );
  }
}
```


#### 9. B widget嵌套在A Widget里（两个Widget分别在不同的Class里），如何在A Widget里获取B Widget里的数据（变量、state、方法等等）呢？
```dart
class A extends StatefulWidget {
  A({Key key}) : super(key: key);
  _AState createState() => _AState();
}

class _AState extends State<A> {
  final GlobalKey<_BState> _bStateKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    /// 获取B里边的变量
    print(_bStateKey.currentState.name);
    /// 调用B里边的方法
    _bStateKey.currentState.getName();

    return Container(
       child: B(),
    );
  }
}

class B extends StatefulWidget {
  B({Key key}) : super(key: key);
  _BState createState() => _BState();
}

class _BState extends State<B> {
  /// 这个是B Widget里声明的变量
  var name = 'Jerry';

  /// 这个是B Widget里声明的方法
  void getName() {
    /// TODO
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       child: Text('This is B Widget!'),
    );
  }
}
```


#### 10. Exception: ideviceinfo return an error: ERROR: Could not connect to lockdownd, error code -17(或者-21)

```dart
// 以下两种方式可供使用：

1. 如果你的设备上连接有真机，用的模拟器测试，拔掉手机手机的USB线，再试试运行到模拟器。

2. 断开设备，在终端窗口中，键入：sudo pkill usbmuxd（它将自动重新启动），再次连接设备
```