# linux-basis

## CentOS 和 Ubuntu 区别？

- **CentOS** 是 Linux 发行版之一，通常要求高度稳定性的服务器使用，安装软件使用 yum；
- **Ubuntu** 以桌面应用为主的 Linux 操作系统，基于 Debian 发行版，使用 apt-get 来安装软件；
- **Busybox** 在单一的可执行文件中提供了精简的 Unix 工具集，适合于嵌入式环境；

## shell 设置

shell 是 linux/unix 的一个外壳，负责与 linux 内核交换。
用户登录时，会读取`/etc/profile`,`~/.profile`，如果当前 shell 是 bash，还会读取(如果存在)`~/.bash_profile`,

## 输出重定向

bash 中，0，1，2 分别代表 STDIN_FILENO（标准输入）、STDOUT_FILENO（标准输出）、STDERR_FILENO（错误信息输出）。

```bash
# 将错误消息和标准输出输出到文件a.txt,如果不加2>&1则错误消息只会输出到屏幕
find / -name 'bash'>a.txt 2>&1
# 将错误消息和标准输出输出到文件，同时输出到屏幕
find / -name 'bash'>a.txt 2>&1|tee a.txt
# 忽略错误消息
# /dev/null 表示linux的空设备文件
find / -name 'bash' 2>/dev/null
```

## xargs

> The xargs utility reads space, tab, newline and end-of-file delimited strings from the standard input and executes utility with the strings as arguments.
> −0 Change xargs to expect NUL (‘‘\0’’) characters as separators, instead of spaces and newlines.
> This is expected to be used in concert with the −print0 function in find(1).

xargs 默认是按照 空格，tab，换行作为分隔符来分割字符串作为命令参数
`xargs -0`将`\0'`作为默认的文件分隔符，通常配合`-print0`来使用
`find . -name "*.txt" -print0 | xargs -0 grep -n '2016'`
`-print0` 将默认的分隔符从`换行`变成了`\0`[空字符 null](https://en.wikipedia.org/wiki/Null_character)

### xargs 和管道符的区别

```bash
echo "--help" | cat  # 作为结果输出
echo "--help" | xargs cat  #作为cat的命令参数 类似于 cat --help
```

管道符 | 所传递给程序的不是你简单地在程序名后面输入的参数，它们会被程序内部的读取功能如 scanf 和 gets 等接收，而 xargs 则是将内容作为普通的参数传递给程序

## dns 设置

最近几次都是遇到 dns 相关的问题

1. 中心迁移 ip 后，应用每次启动初始化数据库连接池都得花很长时间，后来查出来是因为迁移之后，数据库服务器不能连外网，将 resolv-conf 里面配置的`nameserver:114.114.114.114`注释掉就好了
2. 使用`wget` `yum`安装软件，一直不能识别网址 url，然后发现 resolv-conf 里面没有配置`nameserver`
3. 修改 resolv-conf，不需要`service network restart`

```bash
vim /etc/resolv-conf
# nameserver 114.114.114.114
# search localdomain
nameserver 8.8.8.8
```

## hostname 设置

修改`/etc/sysconfig/network`的`HOSTNAME`，重启之后会生效
执行`hostname newname`会立即生效，但重启后失效，此命令会修改`/proc/sys/kernel/hostname`，等价于`sysctl kernel.hostname=newname`
同时执行上面两个操作，会立即生效，且重启后生效
在`/etc/rc.d/rc.sysinit`中，有如下逻辑判断，当`/etc/sysconfig/network`为 localhost 后 localhost.localdomain 时，将会使用接口 IP 地址`/etc/hosts`对应的 hostname 来重新设置系统的 hostname。

```bash
[root@rp-slave ~]# cat /proc/sys/kernel/hostname
rp-slave
[root@rp-slave ~]# hostname
rp-slave
[root@rp-slave ~]# hostname rp-slave1
[root@rp-slave ~]# hostname
rp-slave1
[root@rp-slave ~]# cat /proc/sys/kernel/hostname
rp-slave1
# 查看主机IP地址
[root@rp-master .ssh]# hostname -i
10.211.55.10
```

### /etc/hosts

hosts 格式 `IP地址 主机名(别名)/域名`
主机名在局域网使用，通过 hosts 文件，主机名（也可以是别名）被解析成相应的 IP
比如登陆 linux 输入密码后会等一段时间才能进入，是 linux 在返回信息中需要解析 IP，在主机的 hosts 文件里面加入客户端的 ip 地址，再登陆 linux 就会变得很快
参考：[深入理解 Linux 修改 hostname](http://www.cnblogs.com/kerrycode/p/3595724.html)

## centos 7 防火墙操作

参考： <https://havee.me/linux/2015-01/using-firewalls-on-centos-7.html>

mdcat

```bash
 # 安装
 yum install firewalld
 # 启动
 systemctl start firewalld
 # 开启 80 端口
 firewall-cmd --zone=public --add-port=80/tcp
 firewall-cmd --reload
 # 查看 public 级别允许进入的端口
 firewall-cmd --zone=public --list-ports

 # 关闭端口
 firewall-cmd --zone=public --remove-port=10050/tcp
 firewall-cmd --runtime-to-permanent
 firewall-cmd --reload
```

## linux 权限管理

- 创建的用户保存在 `/etc/passwd` 文件中
- 创建的组保存在 `/etc/group` 文件中

| 文件类型       | 权限       | 所属                 |
| -------------- | ---------- | -------------------- |
| `-` 二进制文件 | `r` 4 读   | `u` 所有者           |
| `d` 目录       | `w` 2 写   | `g` 所属组           |
| `l` 软连接     | `x` 1 执行 | `o` 其他人 `a`所有人 |

```bash
# 查看当前的文件属性
# 第 1 位是文件类型 d目录文件
# 第 2-4 位文件的所有者拥有的权限，r 是读，w 是写，x 是执行
# 第 5-7 位(r-x)这个文件所有者所在同一个组的用户具有的权限
# 第 8-10 位(r-x) 其他用户拥有只读和执行权限
$ ll a.txt
-rw-r--r-- 1 git git 4 Jan 23 10:55 a.txt
$ ll /srv/
drwxr-xr-x 3 root root   4096 10月 24 2018 bdcor

# 查看用户id
$ id root
uid=0(root) gid=0(root) groups=0(root)

$ cat /etc/passwd|grep root
# 用户名:密码:UID:GID:用户说明信息:用户主目录:登录使用的shell
root:x:0:0:root:/root:/bin/zsh

$ cat /etc/group|grep root
# 组名:密码:GID:组内用户列表(多个逗号隔开，这个用户组可能是用户的主组，也可能是附加组)
# 主组 用户一登录就立即拥有的组
# 附加组，用来指定用户的附加权限
root:x:0:xiaoming,xiaohong

# 用户操作
useradd 用户名
# 用户修改
usermod 用户名
# 删除用户 -a 将用户添加到组中 -d 将用户从组中删除 -r 连通用户主目录一起删除
userdel [选项] 用户名
# 添加组
groupadd 组名
# 删除组
groupdel 组名

# 权限操作
# 将文件/目录所有者修改为指定的用户名 -R 表示递归修改
chown [选项] 用户名 文件名|目录
# 将当前目录下的所有文件及子目录的拥有者都设置为 runoob，群体的使用者为 runoobgroup
chown -R runoob:runoobgroup *
# 将文件/目录所有组修改为指定的组
chgrp [选项] 组名 文件名|目录

# 修改文件目录权限
# 选项 -R 表示递归修改
# 对象 a 表示所有人 u 表示所有者 g 表示所属组 o 表示其他人
# 操作 + 表示增加权限 -表示减少权限
# r 读 w 写 x 执行
chmod [选项] {对象-操作-权限} <文件|目录>
# 对所有人赋予可执行权限
chmod a+x script.sh
# 对所有者所有权限，组内和其他人只有读的权限
chmod u=rwx,go=r script.sh

# 755 表示 u=rwx,g=rx,o=rx
chmod -R 755 目录

# 组名:密码:组id:
[huangrupeng@bogon ~]$ cat /etc/group|grep docker
docker:x:983:lmbx
```
