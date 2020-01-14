# docker-compose.yml

## 配置

- Service configruation65

  - **build** ，可以用来构建镜像
    - **context**，上下文，一个包含 Dockerfile 文件的路径后者 git repository url
    - **dockerfile**，指定 Dockerfile 的别名 -** args**，参数数组，指定构建镜像时的一些参数
    - **args**
    - **cache_from**
    - **labels**
    - **shm_size**，设置容器的 `/dev/shm` 分区大小
    - **target**，构建定义在 `Dockerfile` 里面指定的 stage
  - **command**，覆盖默认的 command
  - **configs**，
  - **deploy**，定义服务部署和运行的一些配置，只有通过 `docker stack deploy`部署到 swarm 上起作用

    - **endpoint_mode**，
      - **vip**，docker 为服务分配虚拟 IP，docker 将客户端请求路由到服务可用的 workder nodes 上面，客户端无需关心服务具体情况，如节点复制。（默认）
      - **dnsrr**，docker 为服务设置 DNS entries，如通过服务名称获取一组 IP 地址，客户端直接请求其中的一个 IP，通常在自定义负载均衡时比较有用 
    - **labels**
    - **mode**，为 `global` 或者 `replicated`
    - **placement**，根据条件来判断将服务部署到哪个 docker-worker 上
    - **replicas**，服务复制数量
    - **resouces**，设置容器运行需要的 cpu、内存等信息
    - **restart_policy**，重启策略
    - **rollback_config**
    - **update_config**
    - 还有一些配置 `docker stack deploy` 目前还不支持

  - **depends_on** 服务依赖顺序
  - **env_file**，从文件里面添加环境变量
  - **environment**，添加环境变量
  - **expose**，暴露端口，只能被 linked services 访问。只有 internal 端口可以指定
  - **network_mode**
    - `bridge`
    - `host`
    - `none`
    - `service:[service name]`
    - `container:[container name/id]`
  - **networks**，加入定义在顶级的 `networks`的网络

    - **aliases**，为服务定义别名，该网络上的其它容器可以通过 service name 或者该别名来连接网络，
    - **ipv4_address/ipv6_address**，为 service 容器定义一个静态的 ip 地址，顶级的 `network` 必须配置 `ipam`

  - **ports**，暴露的端口，格式 `HOST:CONTAINER`, `CONTAINER`
    - `3000` 容器端口，会随机映射一个主机端口
    - `3000:3005` 主机端口:容器端口
  - **volumes**
  - **restart**，`no` `always` `on-failure` `unless-stoped`，在 swarm 模式下该配置无效，使用 `restart_policy` 替代

- **Volume configuration reference**
  - **driver**，默认的驱动是 `local`
  - **driver_opts**
  - **external**，使用外部已定义的 volume
  - **labels**
  - **name**
- **Network configuration reference**
  - **driver**，single host 默认是 bridge，swarm 默认是 overlay
    - `bridge`
    - `overlay`
    - `host or none`
  - **driver_opts**
  - **attachable**
  - **ipam**
    - `driver`
    - `config`
      - `subnet`，如 172.28.0.0/16
  - **exteral**，如果设置为 true，将使用 compose 外部已定义的 network，如果该 network 不存在，则报错

## 参考

[docker-compose file](https://docs.docker.com/compose/compose-file/)
