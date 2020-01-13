# linux-shell

## basis

```bash
# 查看目前系统有几种shell
cat /etc/shells
# 查看当前使用的shell
echo $SHELL
# 切换shell
chsh -s /bin/zsh
# 显示 shell变量
set
# 显示 用户变量(与使用哪种shell无关)
env
# shell变量导出为用户变量
export aa=bb
# 清除用户变量
unset $aa
# PATH决定了shell到哪些目录中寻找命令或者程序
echo $PATH
```

## network

## shell

### if statements

```bash
# 基本语法
# [] 里面左右必须都得有一个空格
if [ a > b ]; then ...; elif []; then ...; else ...; fi
# -gt >    -lt <    -ge >=    -le <=    -eq =    -ne !=
# 之前在操作 docker 容器的 shell 时发现不支持 > 只支持 -gt
if [ $foo -ge 3 ];then
# 和上面等价  test 用于检测某个条件是否成立
if test $foo -ge 3;
# 判断是否是文件 -f是否是文件 -r文件是否可读 -w文件是否可写 -x文件是否可执行  -L文件时symbolic link
if [ -f regularfile ]; then
# 添加 ! invert条件
if [ ! a > b ]; then
# -a and    -o or
if [ $foo -ge 3 -a $foo -lt 10]; then


## Double-bracket syntax 双 [[  ]] 语法
# 能使用通配符 并且右侧的通配符不能加引号
if [[ "$stringvar" == *[sS]tring* ]]; then
# 右侧的 foo 可以省略 ""
if [[ $stringvarwithspaces != foo ]]; then
# working directory 里面只有一个 sh 后缀的文件才返回 true，否则返回 false，单括号如果存在多个 sh 后缀的文件会报错
if [[ -a *.sh ]]; the
# 可以使用 && ||
if [[ $num -eq 3 && "$stringvar" == foo ]]; then
# 可以使用正则匹配
if [[ “$email” =~ “b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,4}b” ]]; then echo “$email contains a valid e-mail address.” fi
```

## 参考

[Conditions in bash script](https://linuxacademy.com/blog/linux/conditions-in-bash-scripting-if-statements/)
