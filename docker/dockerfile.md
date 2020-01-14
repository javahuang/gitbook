# Dockerfile

镜像是多层存储，每层都是在之前基础上做的修改

## 命令

- Dockerfile 里面的每一个指令都会构建一层
  - ![docker 容器文件系统](./media/allen5.jpg)
- 在目录里面添加 `.dockerignore` 来忽略某些文件
- **FROM**，指定 BaseImage
- **RUN**，有两种形式，在构建时运行命令，并提交结果
  - `RUN <command>` 直接执行 bash shell
  - `RUN ["excutable", "params1" ...]`
- **CMD**，一个 dockerfile 只能有一个 `CMD`（如果有多个，只有最后一个生效），在构建时不执行任何结果，作用主要是容器启动默认执行的命令，有如下三种形式。CMD 可以在 Dockerfile 文件中配置，也可以在启动容器时 `docker run <container> ...cmd` 动态添加，后者去替换前者。
  - `CMD ["executable","param1","param2"]` (exec form, this is the preferred form),第一个命令必须是全路径
  - `CMD ["param1","param2"]` (as default parameters to ENTRYPOINT)，只有这种格式的 CMD 才能作为 ENTERYPOINT 的默认参数
  - `CMD command param1 param2` (shell form)，
- **ENDPOINT**，区别于 `CMD`
  - 如果同时配置有 ENDPOINT 和 CMD，则 CMD 将作为参数传递给 ENDPOTIT
  - 如果同时配置有 ENDPOINT 和 CMD，且 docker run 传递有参数，则该参数将取代 CMD 作为参数传递给 ENDPOINT
- **LABEL**，标签，键值对形式，可以通过 `docker inspect` 来查看
- **MAINTAINER**，指定镜像维护者，不推荐使用该命令，用 `LABEL` 取代
- **EXPOSE**，要暴露的端口，主要作用是告诉使用者哪些端口需要暴露，在创建容器时，需要通过 `-p 8080:8080` 或者 `-P`(该参数会随机开启一个 high-ordered 端口) 参数来真正的暴露该端口
- **VOLUME**，定义匿名卷，防止用户忘记指定 `-v` 参数，自动创建匿名卷，防止向容器写入数据

  ```bash
  EXPOSE 80/tcp
  EXPOSE 80/udp
  ```

- **ENV**， 环境变量，键值对形式，运行时可以通过 `docker run --env <key>=<value>` 来动态改变，可以设置 `HOME`(USER 的默认目录),`HOSTNAME`,`PATH`,`TERM`

  ```bash
    ENV <key> <value>
    ENV <key>=<value> ...
  ```

  ```bash
  FROM busybox
  ENV foo /bar
  WORKDIR ${foo}   # WORKDIR /bar
  ADD . $foo       # ADD . /bar
  COPY \$foo /quux # COPY $foo /quux
  ```

- **ARG**，构建参数，键值对形式，也是用来这是环境变量，区别于 ENV，ARG 设置的环境变量在运行时不能被容器获取
- **ADD**，将文件、目录、网络文件（URL）拷贝到 image 的文件系统，文件名可以使用通配符，dest 是绝对路径，或者相对 `workdir` 路径
- **COPY**，和 `ADD`类似，推荐使用，但是不能复制网络
- **ENTRYPOINT**，
- **WORKDIR**，指定工作目录，构建镜像时，各个层工作的默认目录
- **USER**，指定当前用户

```bash
# 使用 Dockerfile 来构建镜像
docker build .
# 指定 tag 参数
docker build -t shykes/myapp:1.0.2 -t shykes/myapp:latest .
```

## 目前已经制作的镜像包括

```Dockerfile
# oracle jdk8
# docker build -t 10.24.10.82:5000/lmbx/oracle-jdk8 .
FROM centos
# ADD 命令会自动解压 tar 包
ADD jdk8.tar.gz /usr/local/
# 设置环境变量
ENV JAVA_HOME /usr/local/jdk1.8.0_131
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV PATH $PATH:$JAVA_HOME/bin
CMD ["bash"]
```

### CMD 和 ENTRYPOINT 的区别

|                            | No ENTRYPOINT                | ENTRYPOINT exec_entry p1_entry   | ENTRYPOINT [“exec_entry”, “p1_entry”]            |
| -------------------------- | ---------------------------- | -------------------------------- | ------------------------------------------------ |
| No CMD                     | error, not allowed           | `/bin/sh -c exec_entry p1_entry` | `exec_entry p1_entry`                            |
| CMD [“exec_cmd”, “p1_cmd”] | `exec_cmd p1_cmd`            | `/bin/sh -c exec_entry p1_entry` | `exec_entry p1_entry exec_cmd p1_cmd`            |
| CMD [“p1_cmd”, “p2_cmd”]   | p1_cmd p2_cmd                | `/bin/sh -c exec_entry p1_entry` | `exec_entry p1_entry p1_cmd p2_cmd`              |
| CMD exec_cmd p1_cmd        | `/bin/sh -c exec_cmd p1_cmd` | `/bin/sh -c exec_entry p1_entry` | `exec_entry p1_entry /bin/sh -c exec_cmd p1_cmd` |

## 参考

[](https://docs.docker.com/engine/reference/builder/#usage)
