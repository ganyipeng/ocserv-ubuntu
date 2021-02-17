# ocserv-ubuntu

## 编写目的
* 手动搭建ocserv，需要在网络上找各种教程和脚本
* 手动搭建容易出错
* 手动搭建一次大约需要1小时左右，对于我这种菜鸟来说
* 将搭建时间缩短到5分钟

## 操作步骤
* 申请服务器
  * 申请阿里云服务器：https://swas.console.aliyun.com/
  * 选择香港节点
  * 操作系统选择ubuntu
* 安装git
  ```
  apt-get update
  apt-get install git -y
  验证git是否安装成功：git --version
  ```
* 下载本仓库
  ```
  git clone https://github.com/ganyipeng/ocserv-ubuntu
  ```
* 移动配置文件
  ```
  cp ~/ocserv-ubuntu/ocserv-gyp.conf ~/ocserv-gyp.conf
  ```
* 执行安装命令
  ```
  sh ~/ocserv-ubuntu/auto-create-ocserv.sh
  ```
* mac电脑上配置并测试
  * 使用连接客户端：openconnect-gui
  * 测试用户名：test
  * gateway: https://47.242.83.234

## 参考网址
* 搭建：https://www.logcg.com/archives/1343.html
* 安全：https://www.logcg.com/archives/884.html
* NAT：https://www.logcg.com/archives/993.html
