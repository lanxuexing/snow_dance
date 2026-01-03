# iTunes 未能连接到此 iPhone。 无法分配资源。

> Date: 2019-03-28
> Category: Blog

前几天用在Mac上用同步助手給iPhone手机安装ipa应用文件，发现iTunes总是会弹出来```iTunes 未能连接到此 iPhone。 无法分配资源。```,然后一开始以为是数据线问题，然后换了3根数据线然并卵，手机显示可以充上电，但是无法连接到iTunes，同步助手也无法连接到设备。

思考了再三，然后在同事的电脑上试试，竟然3根数据线都没有问题，顺利连接上了手机，最后确认是自己的Mac pro出了问题，然后Google了一番，发现原来是之前自己不小心删除了Mac上的```/private/var/db/lockdown/``` **lockdown**文件夹（在学习Flutter的时候，配置IOS环境，不小心把lockdown文件夹删除了...<手动惊恐表情>），操作步骤如下：

1. ```cd /private/var/db/```  进入到目录
2. ```ls -la``` 查看目录下是否有**lockdown**文件夹，如果没有则执行步骤三，有则直接执行步骤四
3. ```sudo mkdir lockdown```  创建空文件夹
4. ```ls -la``` 查看**lockdown**文件夹属性
<html>
    <img src="https://upload-images.jianshu.io/upload_images/8303589-b897f7cd1d2bffa9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" referrerpolicy="no-referrer">
</html>
我们可以看到文件夹的权限属性、所属用户、所属组都和正确的不匹配。
<html>
    <img src="https://upload-images.jianshu.io/upload_images/8303589-0178e20c0ba552e8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" referrerpolicy="no-referrer">
</html>
5.  ```sudo chmod 700 /private/var/db/lockdown```  修改文件夹权限属性
6. ```chgrp _usbmuxd ./lockdown```  修改所属组
7. ```chgrp _usbmuxd ./lockdown```  修改所属用户

**重启iTunes，连接手机，Alert弹出框终于是不弹出来了，顺利识别上了iPhone手机。**

[附赠Google链接](https://blog.elcomsoft.com/2018/07/accessing-lockdown-files-on-macos/)
