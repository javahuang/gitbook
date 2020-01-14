# docker 实战

## 安装 docker

使用脚本安装，参考 [install-docker](https://gitee.com/kennylee/install-docker)，主要原因是 我使用上面的方式安装，访问 docker 官网，一直提示 `I/O operation timed out`

```bash
# 安装配置
curl -sSL https://gitee.com/kennylee/install-docker/raw/master/install-docker.sh | bash -s
# 更新 docker
# 先停止服务
yum update -y docker-ce
# 添加阿里云镜像加速器
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://5tr8o0ux.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

# 安装完毕之后记得关闭防火墙和 selinux
# 然后重启
# 否则可能会出现比如容器内部不能连外网的问题
```

## 集成 springboot

创建 Dockerfile

```Dockerfile
FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG JAR_FILE
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
```

```bash
# 运行命令 -e 指定参数
docker run -e "SPRING_PROFILES_ACTIVE=dev" -p 8080:8080 -t springio/gs-spring-boot-docker
```

## 搭建 nexus3

- 创建 docker repositories
  - docker-group 8085
  - docker-hosted 8083
  - docker-proxy 8084

```bash
# 修改 docker 默认配置文件
# 注释掉 --insecure
# ExecStart=/usr/bin/dockerd   --insecure-registry foo.registry.docker:5000   --graph=/home/docker/lib/
# 否则docker 不能启动，报错 unable to configure the Docker daemon with file /etc/docker/daemon.json: the following directives are specified both as a flag and in the configuration file: insecure-registries
vim /etc/systemd/system/docker.service.d/docker.conf
# 修改 daemon.json（docker 启动加载配置文件）
vim /etc/docker/daemon.json
{
    "disable-legacy-registry": true,
    "insecure-registries": [
        "10.24.209.43:8083",
        "10.24.209.43:8084"
    ],
    "registry-mirrors": [
        "https://5tr8o0ux.mirror.aliyuncs.com"
    ]
}

# 安装启动 nexus
# 端口映射 8081是nexus-web-ui端口 8083是docker-hosted端口 8084是docker-proxy端口
docker run -d --name nexus3 --restart=always -p 8081:8081 -p 8082:8082 -p 8083:8083 -p 8084:8084 --mount src=nexus-data,target=/nexus-data sonatype/nexus3


sudo sed -i "s|ExecStart=/usr/bin/docker daemon|ExecStart=/usr/bin/docker daemon --registry-mirror=https://5tr8o0ux.mirror.aliyuncs.com|g" /etc/systemd/system/docker.service
sudo sed -i "s|ExecStart=/usr/bin/dockerd|ExecStart=/usr/bin/dockerd --registry-mirror=https://5tr8o0ux.mirror.aliyuncs.com|g" /etc/systemd/system/docker.service
sudo systemctl daemon-reload
sudo service docker restart

# docker 启动脚本
/lib/systemd/system/docker.service
# 查看启动日志
journalctl -xe
# daemon.json
# https://docs.docker.com/engine/reference/commandline/dockerd/
# 重新加载 docker 配置
systemctl daemon-reload
# 启动 docker
systemctl restart docker

# 登录 需要登录 nexus 私服对应的端口
docker login 10.24.209.43:8083
#
docker tag lmbx/hbp-web 10.24.209.43:8083/lmbx/hbp-web
# push 到私服
docker push 10.24.209.43:8083/lmbx/hbp-web
# 从 nexus-proxy 上面拉取
docker pull 10.24.209.43:8084/jenkins/jenkins
```

参考

[sonatype/nexus3](https://hub.docker.com/r/sonatype/nexus3/#getting-help)

[using-nexus-3-as-your-repository-docker](https://blog.sonatype.com/using-nexus-3-as-your-repository-part-3-docker-images)

## portainer

docker 容器管理 ui 工具

```bash
docker pull portainer/portainer
docker volume create portainer_data
docker run --restart=always -d -p 9000:9000 -v /run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
```

## mysql

```bash
docker run --name mysql-5.7 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d  -v /etc/localtime:/etc/localtime -v /data/srv/mysql/5.7/datadir:/var/lib/mysql mysql:5.7
```

[通过 yum 安装 mysql](https://dev.mysql.com/doc/mysql-yum-repo-quick-guide/en/)

不能通过 navicat 连接 mysql

```bash
CREATE USER 'root'@'localhost' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
CREATE USER 'root'@'%' IDENTIFIED BY '123456';
GRANT ALL PRIVILE
-------
# ing MySQL
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'dota8888';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'dota8888';
# flush privileges;
```

## nginx

```bash
docker run --name nginx -p 8080:80 -v /srv/nginx/conf/nginx.conf:/etc/nginx/nginx.conf -v /srv/nginx/html:/usr/share/nginx/html -v /srv/nginx/log/access.log:/var/log/nginx/access.log -d nginx

# 获取 nginx 容器的配置
docker run --name tmp-nginx-container -d nginx
$ docker cp tmp-nginx-container:/etc/nginx/nginx.conf /host/path/nginx.conf
$ docker rm -f tmp-nginx-container
chmod 666 nginx.conf

docker exec -it nginx nginx -s reload
```

## [redis](https://hub.docker.com/_/redis/)

```bash
docker pull redis
docker run -v /src/redis:/data --name redis -p 6379:6379 -d redis redis-server --appendonly yes

docker exec -it redis redis-cli
```

## docker

docker 中配置时区

-v /etc/localtime:/etc/localtime:ro

## oracle

[docker-oracle-ee-11g](https://github.com/MaksymBilenko/docker-oracle-ee-11g)

```bash
docker run -d -p 8090:8080 -p 1521:1521 -v /srv/oracle/data:/u01/app/oracle --name oracle sath89/oracle-ee-11g

docker run -d -p 49161:1521 -e ORACLE_ALLOW_REMOTE=true wnameless/oracle-xe-11g
```

## [Docker Registry](https://docs.docker.com/registry/)

Registry 是一个无状态、高度可拓展服务端应用，可以用来存储和分发 docker 镜像。

> A registry is a storage and content delivery system, holding named Docker images, available in different tagged versions.

理解 docker image 的命名

- `docker pull ubuntu` 表示 docker 从官方 Docker Hub 上面拉取一个叫做 `ubuntu`的镜像，是 `docker pull docker.io/library/ubuntu` 的缩写
- `docker pull myregistrydomain:port/foo/bar` 表示 docker 从地址为 `myregistrydomain:port` 的 registry 拉取名字为 `foo/bar` 的镜像

配置 registry，有两种方式

- 通过 `-e` 指定参数，参数格式 `REGISTRY_<variable>=<value>`
- 通过 `-v config.yml:/etc/docker/registry/config.yml` 覆盖默认的配置参数

```bash
# 创建 registry 容器
docker run -d -p 5000:5000 --restart=always --name registry \
-v /srv/registry:/var/lib/registry \
registry:2
# 通过 -e 指定参数来覆盖 registry 默认参数，
# 参数参见 https://docs.docker.com/registry/configuration/

# 从 Docker Hub 上拷贝镜像到本地的 registry
# 1.从 Docker 上面拉取镜像
docker pull ubuntu:16.04
# 2.对镜像打标签 `10.24.10.82:5000/my-ubuntu`，如果镜像 tag 以 `host:port` 开头则表示这是一个 registry 地址
docker tag ubuntu:16.04 10.24.10.82:5000/my-ubuntu
# 3.将镜像推送到 registry
docker push localhost:5000/my-ubuntu
# 4.删除本地镜像
docker image remove ubuntu:16.04
docker image remove 10.24.10.82:5000/my-ubuntu
# 5.从 registry 拉取镜像
docker pull 10.24.10.82:5000/my-ubuntu

# 停止并删除 registry
docker container stop registry && docker container rm -v registry
```

## 修改 docker 主目录

```bash
# 查看 docker 目录
docker info | grep "Docker Root Dir"
# 停止 docker 服务
systemctl stop docker
# 移动 docker 目录
mv /var/lib/docker /data/
# 创建软连接
ln -s /data/docker /var/lib/docker
# 启动 docker 服务
systemctl start docker
```

## 群晖 nas docker 加速

[玩转群晖 NAS--Docker 加速](https://www.itfanr.cc/2017/11/17/playing-synology-nas-of-docker-accelerator/)

```bash
# 修改镜像加速器
vim /var/packages/Docker/etc/dockerd.json
# 重启 docker 服务
bash /var/packages/Docker/scripts/start-stop-status stop;
bash /var/packages/Docker/scripts/start-stop-status start;

mkdir /volume1/docker/srv/nexus-data
chown -R 200:200 path/to/directory
```

## 问题

### 添加 -e 解决 tomcat 时区不对的问题

`docker run -d --name csp-web -p 9007:8080 -e TZ="Asia/Shanghai" -v /home/lmbx/csp/web/ROOT:/usr/local/tomcat/webapps/ROOT -v /etc/localtime:/etc/localtime tomcat:8`

## 参考

[docker-native-kvm 性能比较](https://domino.research.ibm.com/library/cyberdig.nsf/papers/0929052195DD819C85257D2300681E7B/$File/rc25482.pdf)

[docker+marathon+mersos](http://www.cnblogs.com/kevingrace/p/5685313.html)

[应该把什么样的服务放到 docker 上](https://www.zhihu.com/question/31682393)

[Bridge、NAT、Host-Only](https://zhuanlan.zhihu.com/p/24758022)

[创业公司小团队为什么要使用 docker](https://zhuanlan.zhihu.com/p/26075109)
