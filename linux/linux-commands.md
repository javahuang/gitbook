# linux 命令

```bash
# 杀死指定端口的进程
# 加上 END 是如果该端口进程不存在的话，kill 会报错
lsof -ti tcp:9004|grep -v grep|awk '{print $1} END {if (!NR) print "23333"}'|xargs kill
# cd 到当前目录下面的每个子目录执行 yarn 命令
for d in ./*/ ; do (cd "$d" && yarn); done
```

## 网络

### tcpdump

```bash
# -n 不要将地址转换城名字 -i 网络接口名字 -q 快速输出 -w 将原始报文输出到 file
# host 源地址或目标地址
# src 源地址 dst 目标地址

# 列出 tcpdump 可以监听的网络接口
tcpdump -D

# 只过滤 icmp 协议
tcpdump -nni eth0 icmp
# 只过滤  icmp echo reply
tcpdump -nni vlan111 -e icmp[icmptype] == 0
# 捕获以太网地址包
tcpdump -nni eth0 ether src 2c:21:72:c6:c1:88
# 捕获 ip 地址包
tcpdump -nni en0 src host 8.8.8.8.8
# 捕获 arp 协议
tcpdump -nni en0 arp
# 捕获 ipv4 协议
tcpdump -nni en0 ip

sudo tcpdump -i lo0 -n  port 8912
```

### arp

地址解析协议，链路层协议。通过 32 位 internet 地址（IP 地址）来获取 48 位以太网地址。

```bash
# ip 地址到 mac 地址的映射
arp -a
```

### netstat

```bash
# 显示与 TCP/UDP/ICMP 协议相关的统计数据，一般用于检测本机各端口网络连接情况
# -a 显示所有连线中的 socket
# -n 不要将网络文件的网络号转化为名字
# -u 显示 udp 连接
# -t 显示 tcp 连接
# -l 显示监听中的 socket
# -p 显示使用当前端口的程序 pid 和名称
# -i 查看网卡接口
# -r 查看路由接口
netstat

# 查看端口占用进程
netstat -apn | grep 8080
# 查看进程占用端口号
netstat –nltp|grep 8080
# 查询所有的网卡接口
netstat -ni
# 查询路由接口
netstat -rn

```

### ps

-a 显示所有终端机下执行的程序
-A/-e 显示所有程序
-f 显示 UID、PPIP、C 与 STIME 栏位

```bash
# 将本地登入的 PID 与相关信息列出来
ps -l
# 列出所有的进程
ps -A
# 显示所有进程信息联通命令行
ps -ef
ps -e -o pid,uname=USERNAME,pcpu=CPU_USAGE,pmem,comm # 重定义标签
```

## 命令

除了通用的 `ls --help`，`man ls` 能查看某个命令的使用方法，我在 mac 下面还安装了 [cheat](https://github.com/chrisallenlane/cheat)，通过 `cheat ls` 能查看该命令一些使用例子。

```bash
# 查看 ls 文档
# 默认是 man 1
# 1表示标准命令 2系统调用 3 库函数 4 设备说明 5 文件格式
man ls
man 2 select


# 从原始目录复制文件到目标目录(排除某些文件)
# 在linux里面 `` 反引号里面的command会立即执行
cp -fr `ls | grep -E -v ".sh"` destDir

# 查看端口占用进程
netstat -apn | grep 8080
lsof -i TCP:8080


# -p 查看进程号
# -a 多个指令用且的关系(默认是或)
# -P 不要将网络文件的端口号转化为名字
# -n 不要将网络文件的网络号转化为名字
# -i 列出所有的网络连接
# -t 只列出进程号
# 列出进程 554 的所有端口号
lsof -anP -p 554 -i
# 列出端口号 80 占用的进程
lsof -i:80 -anP
# 列出进程号 554 对应的进程信息，如获取标准输入、标准输出、错误的相关 fd 信息
lsof -p 554 -anP



# 统计文件行数 -c（bytes）-l（line）-w（words）-m（characters）
wc
## 统计某个文件夹有多少文件
find . -type f | wc -l

# 查看文件夹大小 -s(-d0 只显示当前文件夹大小) -h(转化为B,K,M,G的形式)
du -sh
# 深入到第几层目录查找
du -h --max-depth=0
# 查看剩余磁盘空间
df -h

# 从远程服务器获取数据
# 递归复制(r)保留源文件属性(p)
scp -rp /usr/local/ root@192.168.1.99:/usr/local/
# -u只更新,不覆盖已经存在的文件 -r对子目录递归处理 -a递归方式拷贝文件，并保持原文件属性 --progress查看拷贝的过程 -z对数据传输压缩
rsync -auv /src/foo /dest

 # 下载文件
 curl -O
 wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u92-b14/jdk-8u92-linux-x64.tar.gz

# crontab linux执行定时任务
## -u设定某个用户cron任务 -l(列出任务内容) -r(删除任务) -e(编辑任务)
crontab -e
## 格式如下 每晚21：30重启Apache
## 30 21 * * * /usr/local/etc/rc.d/lighttpd restart

# 端口映射
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080

# 关闭防火墙
## 永久关闭
chkconfig iptables off
## 暂时关闭
service iptables stop

# 关闭防火墙
# 临时关闭防火墙
systemctl restart firewalld
# 关闭防火墙
systemctl disable firewalld
systemctl stop firewalld
systemctl status firewalld
# 开启防火墙
systemctl enable firewalld
systemctl start firewalld
systemctl status firewalld
# 开放端口
firewall-cmd --zone=public --add-port=3000/tcp --permanent
firewall-cmd --reload


# telnet 查看机器的端口是否开放
# 退出 telnet 可以使用 ctrl+] 然后执行 exit 退出
telnet ip port

# 查看 Linux 内存占用
# 空闲内存=free+buffers+cached=total-used ,linux 的思想是内存不用白不用，所以 cache+buffer 会占用比较多
free -h
# 查看当前操作系统发行版详细信息
cat /etc/redhat-release
# 查看 cpu 统计信息
lscpu
# 查看 cpu 型号
cat /proc/cpuinfo | grep name|cut -f2 -d:|uniq -c
# 查看物理 cpu 个数
cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l
# 查看物理 cpu 中 core 的个数
cat /proc/cpuinfo| grep "cpu cores"| uniq
# 查看逻辑 cpu 的个数
cat /proc/cpuinfo| grep "processor"| wc -l
# 查看每条内存多大
dmidecode|grep -A5 "Memory Device"|grep Size|grep -v Range
# 查看硬盘和分区分布
lsblk
# 查看硬盘和分区详细信息
fdisk -l


# 编译安装软件
./make.sh
./make.sh install
# 重新编译，清空之前的编译结果
./make.sh clean
# 查看软件的动态链接库
ldd /usr/local/bin/fdhtd


# 创建用户
adduser newname
# 删除用户 删除主目录
userdel [–r] newname
# 创建组
addgroup newgroup
# 删除组
delgroup newgroup

```

## yum

yum 主配置文件 `/etc/yum.conf`

```ini
[main]
# 缓存目录 存储下载 rpm 包
cachedir=/var/cache/yum/$basearch/$releasever
# 安装完后是否保留软件包 0 不保留 1 保留
keepcache=0
debuglevel=2
logfile=/var/log/yum.log
exactarch=1
obsoletes=1
gpgcheck=1
plugins=1
# 设置了多个 repository，同一软件在多个 repository 同时存在，则 yum 应该安装哪一个
# newest 表示最新的 last 服务器 id 以字母排序，选择最后的
pkgpolicy=newest
installonly_limit=5
bugtracker_url=http://bugs.centos.org/set_project.php?project_id=23&ref=http://bugs.centos.org/bug_report_page.php?category=yum
distroverpkg=centos-release
```

yum 仓库配置文件 `/etc/yum.repos.d/*.repo`，默认带的 CentOS-Base.repo 官方源，可能里面的版本比较落后，访问速度慢，可以直接删掉，然后安装国内的一些 yum 源，然后执行 makecache 生成缓存。
epel 源包含很多基本源里面没有的软件。
默认各仓库的用法

- base 库，系统发行版提供的程序包
- updates 库：存放更新包
- extra 库：存放额外包
- epel 库：epel 库文件

```ini
# #容器名字，必须是唯一的
[repositoryID]
#仓库的名字，仅作一个标识
name=Some name for this repository
#指定真正仓库所在的路径，可以指多个仓库
baseurl=url://path/to/repository/
#指是否启用这个仓库，1表示启用，0表示不启用
enabled={1|0}
#是否要检测软件包的合法性，1表示启用，0表示不启用
gpgcheck={1|0}
#软件包的公钥文件所在路径
gpgkey=URL
#是否基于组来批量管理程序包
enablegroups={1|0}
#意思是有多个url可供选择时，yum选择的次序，roundrobin是随机选择
failovermethod={roundrobin|priority}
#仓库优先级 ,默认为1000
cost=
```

```bash
# 将所有的数据删除，包括元数据和软件文件
yum clean all
# 构建缓存
yum makecache

```

## systemd

```bash

```

### grep

-v 反转查找，即不包含
-c 统计数量

```bash
# linux 中 grep 正则不能使用 \d，\d 不属于 basic regex
# https://blog.csdn.net/yufenghyc/article/details/51078107
# 输出 linux 使用百分比 -o只输出匹配 -E使用拓展正则 "+"不被basic-regex识别
df -h / | grep -o -E "[0-9]+%"

# Exclude grep from your grepped output of ps.
# Add [] to the first letter. Ex: sshd -> [s]shd
# 主要目的吗不匹配 grep 本身
ps aux | grep '[h]ttpd'

```

### top

```bash
# https://askubuntu.com/questions/274349/getting-cpu-usage-realtime
# 获取 cpu 使用率
top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'
# us用户空间占比 sy内核空间占比 id空闲cpu
Cpu(s):  0.0%us,  0.5%sy,  0.0%ni, 99.5%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
```

### awk

依次对每一行进行处理，然后输出。计算必须放在 {} 里面

```bash
###awk把文件逐行读入，以空格为默认分隔符进行切片###
# sum integers from a file or stdin, one integer per line:
printf '1\n2\n3\n' | awk '{ sum += $1} END {print sum}'

# using specific character as separator to sum integers from a file or stdin
printf '1:2:3' | awk -F ":" '{print $1+$2+$3}'

# print a multiplication table
seq 9 | sed 'H;g' | awk -v RS='' '{for(i=1;i<=NF;i++)printf("%dx%d=%d%s", i, NR, i*NR, i==NR?"\n":"\t")}'

# Specify output separator character
printf '1 2 3' | awk 'BEGIN {OFS=":"}; {print $1,$2,$3}'

# 按照:分割打印第1和第7个切片
cat /etc/passwd |awk  -F ':'  'BEGIN {print "name,shell"}  {print $1","$7} END {print "blue,/bin/nosh"}'

# 以M显示文件大小
ls -l |awk 'BEGIN {size=0;} {size=size+$5;} END{print "[end]size is ", size/1024/1024,"M"}'
```

## sed

```bash
# To replace all occurrences of "day" with "night" and write to stdout:
sed 's/day/night/g' file.txt

# To replace all occurrences of "day" with "night" within file.txt:
sed -i 's/day/night/g' file.txt

# To replace all occurrences of "day" with "night" on stdin:
echo 'It is daytime' | sed 's/day/night/g'

# To remove leading spaces
sed -i -r 's/^\s+//g' file.txt

# To remove empty lines and print results to stdout:
sed '/^$/d' file.txt

# To replace newlines in multiple lines
sed ':a;N;$!ba;s/\n//g'  file.txt

## 以行为单位对数据进行编辑，可以进行替换、新增、删除、选取等工作
## sed 不会改变文件内容，可以使用重定向输出到文件
# 将 a.txt 文件里面的所有 my 替换成 you
# g 搜索一行的所有字符 双引号可以使用转义
# -i 能直接修改文件内容
sed -i "s/my/your/g" a.txt
# 在每行前面添加 #
sed 's/^/#/g' a.txt
# 替换第3行的内容
sed '3s/my/your/g' a.txt
# 3,6s 表示3-6行 2g表示从第2个以后的
sed '3,6s/my/your/2g' a.txt
# 替换第2行到最后一行的的第2个 s 为 S
sed '2,$s/s/S/2' a.txt
# 将所有的my替换成[&] &表示被匹配的变量
sed 's/my/[&]/g' a.txt

## N 将12 34 56... 行合成一行来匹配
sed 'N;s/my/your/' a.txt

## a i 添加行
# 在第1行前插入 hello
sed '1i hello' a.txt
# 匹配到fish后就追加一行hello
sed '/fish/a hello' a.txt

## c 替换行
# 将第2行替换成 hello
sed '2c hello' a.txt
# 匹配到hi后替换为hello
sed '/hi/c hello' a.txt

## d 删除行
# 匹配到 fish 后删除该行
sed '/fish/d' a.txt
# 删除第二行
sed '2d' a.txt
# 删除2-最后一行
sed '2,$d' a.txt

## p 打印
# 匹配到 fish 后打印该行
sed -n '/fish/p' a.txt
# 打印第二行
sed -n 2p
```

## 例子

```bash
# 打印出不同的 tcp 连接
# sort 和 uniq 必须成对出现
netstat -anpt| awk '{print $6}'|sort|uniq
```
