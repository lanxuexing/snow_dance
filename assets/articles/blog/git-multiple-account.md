# git 多账号配置

> Date: 2018-11-15
> Category: Blog

#### 1. 前言

有的时候我们肯那个会用到两个`github`账号，这个时候提交代码就出现了问题，第一个可以提交，但是第二个提交就出现了问题。

#### 2. 配置

- 生成公钥和私钥文件

```vim
// 1. 首先进入到.ssh目录
cd ~/.ssh

// 2. 查看本地是否已经有存在的公钥和私钥文件(PS: 如果存在了，则只需要生成第二个账号即可，或者全部删除重新生成)
ls

// 3.生成SSHkey
ssh-keygen -t rsa -C "你的github邮箱"

然后按下Enter(回车键)
这个时候提示：Enter file in which to save the key（xxx/xxx/.ssh/id_rsa）:
我们按照格式键入要保存的文件名即可：id_rsa_xxx   xxx是你自己定义的名字
这个时候又提示：Enter passphrase (empty for no passphrase):
直接按下Enter(回车键)
这个时候又提示：Enter same passphrase again:
继续按下Enter(回车键)
OK，成功之后会提示以下信息(PS: 说明已经成功生成SSHKey):
Your public key has been saved in xxx/xxx/.ssh/id_rsa_(你刚才定义的名字).pub
The key fingerprint is:
    SHA256:lEmncZqtuXuHgZ4XtkVMkazLaTC5XgN0VLjYi3T8Fk8 xxx@xxx.com
    The key s randomart image is:
    +---[RSA 2048]----+
    |        o o..=+o |
    |       . @. + o X|
    |        B..B o   |
    |       . oB B . E|
    |        So X = + |
    |        ..* X o .|
    |       ..+ O o   |
    |        o.* .    |
    |        .o .     |
    +----[SHA256]-----+

// 4. 再次查看.ssh目录
ls
这个时候应会看到有文件: id_rsa_(你刚才定义的名字)、id_rsa_(你刚才定义的名字).pub

// 5. 把公钥配置到GitHub
pbcopy < ~/.ssh/id_rsa_(你刚才定义的名字).pub   // 拷贝公钥到剪贴板
登录github SSH keys粘贴进去配置好

// 6. 新的密钥添加到SSH agent中
ssh-add id_rsa_(你刚才定义的名字)  // 这里是添加私钥

// 7. 创建配置文件config
vi config  // 新建并打开config文件
键入以下字符：
==============分割线(不要粘贴进去)=================
Host github.com
HostName github.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/id_rsa

Host (你刚才定义的名字).github.com
HostName github.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/id_rsa_(你刚才定义的名字)
==============分割线(不要粘贴进去)=================

// 8. 验证连接
ssh -T git@(你刚才定义的名字).github.com
这个如果成功会出现提示：Hi xxx! You've successfully authenticated, but GitHub does not provide shell access.

// 9. 设置本地全局git邮箱和用户名
git config --global user.email "你的邮箱"
git config --global user.name  "你的名字"
git config --list  //  查看设置好的内容
```
