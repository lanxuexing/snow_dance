# Angular cdk

> Date: 2020-06-03
> Category: Blog

#### 1. 起源

> CDK是Component Dev kit的简称，首次提出是在2017年（PS：2017.07推出了可用的Beta版本），是Angular Material团队在开发Library时发现组件有很多相似的地方，最后进行了抽取，提炼出了公共的逻辑，这部分即是CDK，具体可以观看[2017年Angular Mix大会上的Jeremy Elbourn的介绍。

- [youtube传送门](https://www.youtube.com/watch?v=kYDLlfpTLEA)

![image](https://github.com/lanxuexing/assets/raw/master/cdk/struct.png)

> 官方用了一个很形象的比喻：`if the component library is a rocket ship,
> the cdk is the box of engine parts.`，如果组件库是火箭飞船，
> 那么CDK就是发动机零件盒。



#### 2. 分类

###### Common Behaviors

- Accessibility
  
    > 包提供了许多提高无障碍性（可访问性）的工具，最终让屏幕阅读更容易理解。

- Bidirectionality

    > 包为组件提供了一个通用的体系，来获取和响应应用的 LTR（从左到右）/RTL（从右到左）布局方向的变化。

- Clipboard

    > 提供用于使用系统剪贴板的帮助器。



#### 3. Accessibility

###### 1. FocusTrap

FocusTrap是一个指令，它用于捕获元素中的Tab键焦点，常用于我们的表单里，可能说的比较模式，可以直接看下图的演示效果。

<video controls preload="none" poster="https://github.com/lanxuexing/assets/raw/master/cdk/demo.png">
      <source  src="https://github.com/lanxuexing/assets/raw/master/cdk/focus-trap.mov">
      <p>Your user agent does not support the HTML5 Video element.</p>
</video>

从视频演示中我们可以看到，使用指令包裹元素和不包裹元素，按下Tab键之后的效果是不同的。HTML其实很简单，如下：

![focus trap html](https://github.com/lanxuexing/assets/raw/master/cdk/focus-trap-html.png)



如果你想自己控制指令的作用范围，那么CDK还提供另外的三个指令：`cdkFocusRegionStart`、`cdkFocusRegionEnd` 和`cdkFocusInitial`，其中`cdkFocusInitial`用于指定初始化时获取焦点的元素或者区域。tab键会在该区域内自动回卷。

###### 2. ListKeyManager

ListKeyManager可以通过键盘交互来管理条目列表。要使用ListKeyManager一般需要做三件事儿。

- 为管理的条目创建一个`@ViewChildren`查询
- 初始化`ListKeyManager`，并传入条目
- 将键盘事件转发给`ListKeyManager`

原则上应该实现`ListKeyManagerOption`接口（可选），`ListKeyManagerOption`里有一个可选方法和可选属性。

![ListKeyManagerOption](https://github.com/lanxuexing/assets/raw/master/cdk/list-key-manager-option.png)		

但是必须实现`FocusableOption`接口。

![FocusableOption](https://github.com/lanxuexing/assets/raw/master/cdk/focusable-option.png)


