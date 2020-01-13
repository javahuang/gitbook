# 阿里云主机

| ip                              | 账号    | 密码       |
| ------------------------------- | ------- | ---------- |
| 39.107.234.157                  | root    | A4LP78193h |
| <https://git.xiaohuanghuang.cn> | dahuang | dota8888   |

## 安装服务

- 所有安装文件保存在 `/opt/setups` 下面
- 安装了 nginx
- 安装了 mysql-5.7，开放端口 **3306**
- 安装 python3

  ```bash
  yum install centos-release-scl
  yum install rh-python36
  scl enable rh-python36 bash
  ```

- 安装 oh-my-zsh
- 安装 [auto-jump](https://github.com/wting/autojump)

  ```bash
  yum install autojump-zsh
  ```

- 安装 [gogs](https://gogs.io/docs/installation)，开放端口 **3306**

## 配置

- 开启防火墙
- 在阿里云管理控制台里面设置安全组规则，配置允许访问的外网端口
