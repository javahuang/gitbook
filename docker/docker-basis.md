# docker-basis

镜像状态分为：

- 已使用镜像
- 未引用镜像
- 悬空镜像，未配置任何 tag，通常由于镜像 build 的时候没有指定 -t 参数配置 tag 导致的

```bash
# 获取镜像
docker pull ubuntu:16.04
# 列出镜像
docker image ls
# 列出所有镜像
docker image ls -a
# 删除镜像
docker image rm

# 启动一个新的 容器
# -d 后台运行  --restart=always重启策略（异常退出后自动重启）
# --privileged 使用该参数 容器的 root 才真正拥有 root 权限，可以执行 mount，可以在 docker 容器中启动 docker
# -i 保持STDIN开启 -t分配一个TTY --rm退出时自动删除容器
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]

# 启动 docker 容器，执行多个命令
docker run -it --rm -v /data/srv/jet-biobank/fe:/fe node /bin/sh -c 'cd /fe; npm install'


docker run -it --rm
# 查看容器 -a 包括停止的容器
docker ps -a
# 启动容器
docker start
# 停止容器
docker stop
# 删除
docker rm NAME/CONTAINER ID

# 查看容器映射打端口
docker port [container]

# 获取容器的 IP
# docker inspect 获取 docker 容器的详细信息
docker inspect <container id> | grep "IPAddress"
# 查看挂载点目录
docker volume inspect nexus-data
# 删除所有未使用的挂载点
docker volume prune
# 查看所有的挂载点
docker volume ls

# 进入运行的容器
# 方式1：使用 exec
docker exec -it <container-name> /bin/bash
# 方式2：使用 attach，启动容器时通过 dit 的方式
docker run -dit --name <container-name> <image-name> /bin/bash
docker attach <container-name>


# 清楚 dangling images
docker rmi $(docker images -f "dangling=true" -q)
# 清除已停止容器、清除未被任何容器使用的卷、未被任何容器关联的网络、所有的悬空镜像
docker system prune
# 清楚 exited 状态的容器
docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs sudo docker rm

# 查看 docker 容器的 linux 版本
cat /etc/issue

# 给 linux 用户添加执行 docker 命令的权限
# 给用户添加到 docker 组里面就可以了
# 找到 /etc/group 文件里面的 docker 组，将用户名添加到最后面，逗号隔开
vim /etc/group
docker:x:983:lmbx,huangrupeng
```

## docker resources

docker 默认情况下不限制容器使用的系统资源，如 cpu、内存。在 linux 主机下面，如果内核检测到没有足够的内存来运行应用，将导致 `OOME`，然后开始杀死某些进程，可能会导致系统崩溃。

```bash
# -m --memory 缩写 限制只能使用 300m 内存
# --memory-swap 必须和 -m 成对出现 memory-swap = memory + swap, --memory-swap=-1不限制交换内存使用
# --oomm-kill-disable 当系统内存不够时，默认先杀死容器进程，添加了此参数，会杀死主机进程来释放内存
# --cpus 限制 cpu 的使用 --cpus=".5"能保证容器每 s 最多使用 50% 的 cpu
docker run -m 300m --memory-swap=1g --oom-kill-disable  --cpus=1.5


```

## docker network

```bash
# 查看 docker 网络
# brider 网络适用于独立容器(standalone containers)
# 默认有三个 bridge/host/none 如果开启了 swarm 会多了 overlay
docker network ls
# 查看 bridge 网络下的容器
docker network inspect bridge
# 用户自定义 bridge 网络 --driver -> -d
docker network create --driver bridge my-net
# 删除自定义网络
docker network rm my-net
# 创建容器，通过 --network 指定网络
# 自定义网络内的容器相互之间可以通过 container-name/ip ping 通
# 默认的 bridge 网络内的容器相互之间只能通过 ip ping 通

# 直接使用主机网络
docker run --rm -d --network host --name my_nginx nginx

# 创建 overlay 网络 --attachable 允许独立容器之间互相通信
docker network create -d overlay --attachable my-attachable-overlay
```

- **bridge** 默认的 network driver，通常用于 standalone containers
- **host** 对于 standalone containers，可以直接使用主机的网络。同时适用于 swarm services（docker version 高于 17.06）
- **overlay** 连接多个 docker daemons，允许 swarm 服务互相通信，并且允许 swarm service 和独立容器通信或者独立容器之间通信
  - overlay 网络在 `docker swarm init` 之后自动创建，默认名字为 ingress
  - 可以自定义默认的 ingress 网路
- **macvlan** 允许为容器分配 MAC 地址，变成类似网络里面的一台物理设备，不通过 docker 网络直接与外界通信
- **none** 不允许网络访问

- **User-defined bridge networks** 适用于同一个 docker 主机下面的多个容器之间通信
- **Host networks**
- **Overlay networks** 多个 docker 主机下面的容器之间通信，或者多个应用使用 swarm services 来进行通信
- **Macvlan networks**
- standalone containers 下的 docker 默认使用的是 bridge network，在生产环境下推荐使用 user-defined bridge 网络，因为自定义的网络可以通过容器名和 ip 都能互通

  > This is recommended for standalone containers running in production.

[use host networking](https://docs.docker.com/network/host/)

### 使用 overlay networks

执行 `docker swarm init`之后就会初始化 overlay 网络，默认会创建两个网络

- **ingress**，swarm service 默认使用的是这个网络（或者可以使用 user-defined overlay network）
- **docker_gwbridge**，将独立的 docker deamon 与其它 swarm 的 deamons 连接

创建 overlay 网络

- 每个 docker 主机需要为 overlay 网络开启如下端口
  - TCP 2377，用于集群管理交流
  - TCP/UDP 7946 用于节点交流
  - UDP 4789 用于 overlay 网络

```bash
# 在 swarm service 里面使用 overlay 网络
# --public 参数可以加上 mode=host 使用主机模式，对应就必须得加上 --mode global 取代 --replicas=5
# host 模式，每个服务直接绑定主机端口，所以每个 node 只能开启一个服务，对应只能使用 --mode global
docker service create \
  --name my-nginx \
  --publish target=80,published=80 \
  --replicas=5 \
  --network nginx-net \
  nginx

# 在独立容器里面使用 overlay 网络
# 1.在 node-1 上面创建overlay 网络
docker network create --driver=overlay --attachable test-net
# 2. 在 node-1上面创建容器(c1)使用该 overlay 网络
docker run -it --rm --name alpine3 --network test-net alpine
# 3. 在 node-2上面创建容器(c2)使用 overlay 网络
# 3.1 node-2 自动创建该 overlay 网络
# 3.2 node-2 的 c2 可以直接 `ping c1`

#
```

## 管理应用数据

### [Volumes](https://docs.docker.com/storage/volumes/)

数据卷是一个可供一个或多个容器使用的特殊目录，生命周期独立于容器，不会再容器删除后删除;
启动容器时指定 volume，如果不存在将自动添加；

- **使用 volume 驱动**，默认情况下，创建的 volume 都是直接使用的本机的文件系统（`local`），docker 支持使用插件的方式如 [docker-volume-sshfs](https://github.com/vieux/docker-volume-sshfs)，可以通过 ssh 的方式使用远程主机目录。

  ```bash
  # 安装插件
  docker plugin install --grant-all-permissions vieux/sshfs
  # 创建 volume
  docker volume create --driver vieux/sshfs \
  -o sshcmd=test@node2:/home/test \
  -o password=testpassword \
  sshvolume
  # 使用指定的 volume 驱动
  docker run -d \
  --name sshfs-container \
  --volume-driver vieux/sshfs \
  --mount src=sshvolume,target=/app,volume-opt=sshcmd=test@node2:/home/test,volume-opt=password=testpassword \
  nginx:latest

  # 创建数据卷
  docker volume create my-vol
  # 查看数据卷信息
  docker volume inspect my-vol
  # 将数据卷挂载到容器里
  # 使用数据卷
  --mount type=volume,target=/icanwrite
  # 使用主机目录
  --mount type=bind,source=/data,destination=/data busybox
  docker run -d -P --name web --mount source=my-vol,target=/webapp
  # 删除数据卷
  docker volume rm my-vol

  docker run -d \
  --name devtest \
  --mount source=myvol2,target=/app \
  nginx:latest

  docker run -d \
  --name devtest \
  -v myvol2:/app \
  nginx:latest

  ```

## 和传统虚拟机（KVM）对比

| 特性       | 容器               | 虚拟机     |
| ---------- | ------------------ | ---------- |
| 启动       | 秒级               | 分钟级     |
| 硬盘使用   | 一般为 MB          | 一般为 GB  |
| 性能       | 接近原生           | 弱于       |
| 系统支持量 | 单机支持几千个容器 | 一般几十个 |

## 参考

[Configure networking](https://docs.docker.com/engine/reference/commandline/stack/)
