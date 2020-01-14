# docker-compose

## 概述

compose 是一个定义和运行多容器 docker 应用的工具。通过一个 YAML 文件来定义  应用服务。然后一个命令就能运行所有的服务。默认情况下，`docker-compose` 只能在 single docker node 上面执行，部署到 swarm 上需要使用 `docker stack deploy`。

使用 compose 通常有三个步骤需要处理：

- 定义程序的 `Dockerfile`，以便可以复制到其他地方
- 在 `docker-compose.yml` 里面定义多个服务，这些服务能在隔离环境中  一起运行
- 运行 `docker compose up` 启动运行应用

Compose 有以下命令来管理应用的整个生命周期

- 开始、运行、重构服务
- 查看运行服务的状态
- 查看运行服务的日志
- 在服务上运行一次性命令

```bash
# docker-compose 命令只能在 single docker node 上面运行
docker-compose --version
# 启动 compose -d守护进程方式运行
docker-compose up -d
# 查看 compose 进程
docker-compose ps
# 停止并删除容器、网络、镜像和卷
docker-compose down

docker-compose run web dev
```

## Docker Stacks and Distributed Application Bundles（实验性）

Dockerfile 可以构建镜像， 容器通过该镜像创建。同样的 docker-compose.yml 可以构建一个 distributed application bundle，stacks 通过该 bundle 来创建。

**stack** 是一组有关联的服务的组合，可以编排在一起，一起管理。

## 通过 swarm 使用 compose

docker compose 和 docker swarm 能很好的集成在一起。
但是也有一些限制

- **构建镜像**，swarm 可以通过 Dockerfile 构建镜像，但是镜像只会在单个 docker node 上存在。所以如果想通过 compose 将服务扩容到多个 docker node 上，需要先构建镜像，然后推到 docker hub 上，在 `docker-compose.yml`里面直接通过 `image` 引用该镜像
- **多个依赖关系**，如不同服务之间可能有网络或者卷依赖，但是分布到不同的节点上，可以通过类似 `environment` 指定 constraint 将多个服务部署到相同的 node 上

## compose 使用环境变量

- 通过 `docker-compose run -e DEBUG=1` 来设置环境变量
- 创建 `.env` 文件，`${TAG}`能获取到该文件里面定义的变量
- 在多个地方设置了环境变量，会有一个优先级
  - Compose file
  - Shell environment variables
  - Environment file
  - Dockerfile
  - Variable is not defined

## 参考

[docker-compose reference](https://docs.docker.com/compose/overview/#multiple-isolated-environments-on-a-single-host)

[常用命令](https://docs.docker.com/compose/reference/overview/#command-options-overview-and-help)
