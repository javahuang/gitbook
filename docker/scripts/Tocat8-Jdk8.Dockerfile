#使用的基础镜像
FROM docker.io/centos

LABEL maintainer="huang.rp@jnyl-tech.com"

# 修改时区
RUN rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# 安装中文支持
RUN yum -y install kde-l10n-Chinese
# 配置显示中文
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
# 设置环境变量
ENV LC_ALL zh_CN.utf8

#把宿主当前目录下的jdk文件夹添加到镜像
ADD jdk-8u211-linux-x64.tar.gz /usr/local/
#把宿主当前目录下的tomcat文件夹添加到镜像
ADD tomcat /usr/local/tomcat

#环境变量
ENV JAVA_HOME /usr/local/jdk1.8.0_211
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin

#8080端口
EXPOSE 8080

#启动时运行tomcat
CMD ["/usr/local/tomcat/bin/catalina.sh","run"]