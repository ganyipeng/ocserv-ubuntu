#!/bin/bash
ocservIp="这里写你的VPS-IP"
domainName="gyp.com"

sleepInt=1
# 下载源码
echo '****进入当前用户主目录****'
cd ~
sleep $sleepInt
echo '****下载源码****'
sleep $sleepInt
wget ftp://ftp.infradead.org/pub/ocserv/ocserv-0.10.8.tar.xz
echo '****解压源码包****:'
sleep $sleepInt
tar xvf ocserv-0.10.8.tar.xz

echo '****安装依赖****'
sleep $sleepInt
apt-get update
sudo apt-get install build-essential pkg-config libgnutls28-dev libreadline-dev libseccomp-dev libwrap0-dev libnl-nf-3-dev liblz4-dev
cd ~/ocserv-0.10.8
./configure

echo '****编译安装****'
sleep $sleepInt
make
sudo make install

echo '****准备证书****'
sleep $sleepInt
apt-get install gnutls-bin
cd ~
mkdir certificates
cd certificates

echo '****创建ca证书****'
echo '''cn = "${domainName}"''' > ca.tmpl
echo '''serial = 1''' >> ca.tmpl
echo '''expiration_days = 3650''' >> ca.tmpl
echo '''ca''' >> ca.tmpl
echo '''signing_key''' >> ca.tmpl
echo '''cert_signing_key''' >> ca.tmpl
echo '''crl_signing_key''' >> ca.tmpl
echo '****生成CA密钥****'
certtool --generate-privkey --outfile ca-key.pem
echo '****生成CA证书****'
certtool --generate-self-signed --load-privkey ca-key.pem --template ca.tmpl --outfile ca-cert.pem

echo '****server.tmpl****'
echo '''cn = "这里写你的VPS-IP"''' > server.tmpl
echo '''organization = "gyp.com"''' >> server.tmpl
echo '''expiration_days = 3650''' >> server.tmpl
echo '''signing_key''' >> server.tmpl
echo '''encryption_key''' >> server.tmpl
echo '''tls_www_server''' >> server.tmpl
certtool --generate-privkey --outfile server-key.pem
certtool --generate-certificate --load-privkey server-key.pem --load-ca-certificate ca-cert.pem --load-ca-privkey ca-key.pem --template server.tmpl --outfile server-cert.pem

echo '****把证书移动到合适的地方****'
sleep $sleepInt
cp ca-cert.pem /etc/ssl/private/my-ca-cert.pem
cp server-cert.pem /etc/ssl/private/my-server-cert.pem
cp server-key.pem /etc/ssl/private/my-server-key.pem

echo '****准备配置文件****'
sleep $sleepInt
mkdir /etc/ocserv
cp ~/ocserv-gyp.conf /etc/ocserv/ocserv.conf

echo '****创建测试账号****'
ocpasswd -c /etc/ocserv/ocpasswd test

echo '****设置防火墙***'
echo '****更改 ufw 默认转发策略****'
sed -i '''s/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g''' /etc/default/ufw
echo '****开启转发****'
echo "net/ipv4/ip_forward=1" >> /etc/ufw/sysctl.conf
echo '****添加转发条目****'
echo "*nat" >> /etc/ufw/before.rules
echo ":POSTROUTING ACCEPT [0:0]" >> /etc/ufw/before.rules
echo "-A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE" >> /etc/ufw/before.rules
echo "COMMIT" >> /etc/ufw/before.rules
iptables -t filter -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -t filter -A INPUT -p udp -m udp --dport 443 -j ACCEPT
iptables -t filter -A INPUT -p udp -m udp --dport 22 -j ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE
ufw allow 80
ufw allow 443
ufw allow 22
ufw enable
ufw reload

echo '****启动服务****'
sleep $sleepInt
ocserv -f -d 1
echo '****打开你手机上的Cisco Anyconnect新建一个VPN，添加服务器IP就是你的vps的 IP:端口****'
