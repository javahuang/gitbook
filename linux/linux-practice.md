# linux 实践

## java 环境配置

```bash
[root@oracle ~]# rpm -qa|grep jdk
java-1.7.0-openjdk-1.7.0.45-2.4.3.3.el6.x86_64
java-1.7.0-openjdk-devel-1.7.0.45-2.4.3.3.el6.x86_64
java-1.6.0-openjdk-devel-1.6.0.0-1.66.1.13.0.el6.x86_64
java-1.6.0-openjdk-1.6.0.0-1.66.1.13.0.el6.x86_64
[root@oracle ~]# rpm -e --nodeps java-1.7.0-openjdk-1.7.0.45-2.4.3.3.el6.x86_64
[root@oracle ~]# rpm -e --nodeps java-1.7.0-openjdk-devel-1.7.0.45-2.4.3.3.el6.x86_64
[root@oracle ~]# rpm -e --nodeps java-1.6.0-openjdk-devel-1.6.0.0-1.66.1.13.0.el6.x86_64
[root@oracle ~]# rpm -e --nodeps java-1.6.0-openjdk-1.6.0.0-1.66.1.13.0.el6.x86_64
[root@oracle ~]# rpm -qa|grep jdk
[root@oracle software]# wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u92-b14/jdk-8u92-linux-x64.tar.gz

[root@oracle java]# tar -zxvf jdk-8u92-linux-x64.tar.gz  -C /usr/java
```

rpm 卸载包时，如果该软件包被别的依赖，会卸载不掉，加上 `--nodeps`会强制卸载
通过`wegt`下载 jdk，添加报文头，相当于页面`Accept License Agreement`

```bash
[root@oracle java]# vim /etc/profile
[root@oracle java]# source /etc/profile
# 在文件尾设置java环境变量
JAVA_HOME=/usr/java/jdk1.8.0_92
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME CLASSPATH PATH
```

## ssh 免登陆

使用 ssh 免登陆通常有两种方式

1. **客户端公钥上传到服务器无密码登录**，在客户端上使用 `ssh-keygen -t rsa`生成公钥和私钥(**id_rsa**和**id_rsa.pub**)，让输入密码的时候跳过，将生成的 idrsa.pub scp 到需要登陆的服务器，并`>>`到 ~/.ssh/authorized_keys(没有则新建)文件

   ```bash
   scp id_rsa.pub root@192.168.1.99:~/.ssh
   ssh root@192.168.1.99
   cd ~/.ssh
   touch authorized_keys
   cat id_rsa.pub >> authorized_keys

   # 如果是非 root 用户还需要执行如下操作
   chmod 700 ~/.ssh
   chmod 600  ~/.ssh/authorized_keys
   ```

2. **客户端通过服务器私钥的方式登录**，在服务器上使用 `ssh-keygen -t rsa`生成公钥和私钥(**id_rsa**和**id_rsa.pub**)，让输入密码的时候跳过，将生成的 id_rsa.pub 添加到 ~/.ssh/authorized_keys 里面，客户端使用 `ssh -i id_rsa root@10.24.10.82` 来登录，可以通过 `-i` 参数指定私钥路径，默认路径是 `~/.ssh/id_rsa`，`~/.ssh/id_dsa`，具体参见 `man ssh` 的 `-i identity_file`参数

   ```bash
   chmod 0600 id_rsa
   ```

3. **客户端通过服务器私钥免密码方式登录**，可以和第一步来结合使用，`Host` 的配置支持通配符，可以对不同的主机使用对应的配置

   ```bash
   # 1、将服务器的私钥加入到 keycharin
   ssh-add -K ~/.ssh/[your-private-key]
   # 2. 配置 ssh 一直使用 keychain 来进行登录
   # vim ~/.ssh/config
   # 对 10.11 开头的服务器使用 id_rsa.10.11 私钥登录
    Host 10.11.*
        UseKeychain yes
        AddKeysToAgent yes
        IdentityFile ~/.ssh/id_rsa.10.11
    ServerAliveInterval 120
    TCPKeepAlive no
   ```

## 磁盘分区挂载

参考 [linux-filesystem](./linux-filesystem.md#磁盘物理结构)

```bash
# 查看是否有未使用的硬盘 一般都是 /dev/sda /dev/sdb ...
# 如磁盘 /dev/sdb 下面没有对应的分区信息，则表示该磁盘没有进行分区
fdisk -l

# 对磁盘进行分区
fdisk /dev/sdb
# 新建分区
n
# 创建主分区
p
# 输入分区号
1
# 依次输入开始扇区和结束扇区
# 一般开始扇区直接 enter 选择默认的
# 结束扇区输入当前分区的大小，如 +5G 表示当前分区大小为 5G，直接 enter 的话会使用剩余硬盘容量
# 保存操作，此时创建了 /dev/sdb1 分区
w

# 创建文件系统
mkfs.ext4 /dev/sdb1

# 挂载磁盘到指定目录
mkdir /data
mount /dev/sdb1 /data

# 上面的挂载重启系统之后就会失效
# 设置永久生效
vim /etc/fstab
/dev/sdb1 /data ext4 defaults 0 0
```

```bash
# tmpfs 是虚拟内存文件系统
# 磁盘分为两种，系统磁盘和外挂磁盘
# /dev/mapper/centos-root 挂载到 / 根分区
# /dev/mapper/centos-home 挂载到 /home 用户分区
[root@localhost ~]$ df -lh
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/centos-root   52G  2.5G   50G   5% /
/dev/mapper/centos-home    1T    1G 1022G   1% /home
devtmpfs                 7.8G     0  7.8G   0% /dev
tmpfs                    7.8G     0  7.8G   0% /dev/shm
tmpfs                    7.8G     0  7.8G   0% /sys/fs/cgroup
/dev/sda1                197M  167M   31M  85% /boot
/dev/sdb1                 99G   61M   94G   1% /data
# 查看 inode 信息
[root@localhost ~]# df -ih
Filesystem              Inodes IUsed IFree IUse% Mounted on
/dev/mapper/centos-root    26M   77K   26M    1% /
devtmpfs                  2.0M   374  2.0M    1% /dev
tmpfs                     2.0M     1  2.0M    1% /dev/shm
tmpfs                     2.0M   562  2.0M    1% /run
/dev/sda1                  62K   334   61K    1% /boot
/dev/sdb1                 6.3M    11  6.3M    1% /data
```

所有盘面上的同一磁道构成一个圆柱，通常称做**柱面(Cylinder)**，系统将数据存储到磁盘上时，按**柱面**、**磁头**、**扇区**的方式进行，即最上方 0 磁头最外围 0 磁道第一个扇区开始写入，写满一个磁道之后，接着在同一柱面的下一个磁头继续写入。同一个柱面都写满之后才推进到内层的下一个柱面。
