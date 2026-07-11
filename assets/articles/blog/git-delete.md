# git删除操作

> Date: 2026-07-01
> Category: Blog

```vim
// git查看所有分支
git branch -a
// git删除远程分支
git push origin --delete branchName
// git删除本地分支
git branch -D branchName
// GitHub搜索关键字
best practices.
// git推送本地分之到远程分支
git init
git add .
git commit -m 'xxx'           //xxx是本次提交备注的内容   
git remote add origin  xxx    //xxx是git仓库的地址
git push origin master -f

// git每次push/pull要求输入用户名密码解决
git config --global credential.helper store

// git删除远程已经提交的文件
git rm -r --cached a/2.txt // 删除a目录下的2.txt文件
git commit -m "删除a目录下的2.txt文件" // commit
git push origin 分支名称
最后更新gitignore文件,将不需要提交的的文件名加入进去

// git删除远程tag
git push origin :refs/tags/tag-name
// git删除本地tag
git tag -d tag-name
```