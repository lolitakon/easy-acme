# 判断acme.sh是否已安装
acme_path="/root/.acme.sh/acme.sh"
if [ -e $acme_path ]; then
  echo "acme.sh已安装，跳过安装"
else
  echo "acme.sh未安装，正在安装"
  apt update
  apt-get install socat
  curl https://get.acme.sh | sh
	ln /root/.acme.sh/acme.sh /usr/local/bin/acme
fi

# acme.sh申请证书
read -p "请选择工作模式（ch（change）/new(默认)）：" work_mode
read -p "请输入证书存放路径（默认/opt/tls/）：" CA_Path
if [ "$CA_Path" = "" ]; then
  CA_Path="/opt/tls/"
fi

if [ $work_mode = "ch" ]; then
  read -p "注意！此模式会先清空您目标路径$CA_Path下的所有文件，如需退出请按ctrl+c"
  rm -rf $CA_Path"/*"
else
  mkdir $CA_Path
fi

systemctl stop nginx
echo "acme.sh证书申请"
read -p "请输入你的域名：" domainName
read -p "是否使用IPV6申请?(y/n（默认）)："  isIpv6
read -p "请选择申请模式（standalone(s 默认)/nginx(n)）：" mode
if [ $mode = "n" ]; then 
	mode="nginx"
else
	mode="standalone"
fi

acme --set-default-ca --server letsencrypt

if [ $isIpv6 = "y" ]; then 
	acme  --issue -d $domainName --$mode -k ec-256 --listen-v6
else
	acme  --issue -d $domainName --$mode -k ec-256
fi

acme --installcert -d $domainName --ecc  --key-file   /opt/tls/server.key   --fullchain-file /opt/tls/server.crt
echo "证书申请成功！"

# 删除acme残留以及更新nginx
if [ $work_mode = "ch" ]; then
	echo "删除acme残留"
	read -p "请输入您的旧域名：" old_domain
 	acme remove $old_domain
	read -p "是否需要替换nginx内的域名信息？(y/n(默认))" is_mod
 	if [ "$is_mod" = "y" ]; then
		sed -i 's/%old_domain/%domainName/g' /etc/nginx/nginx.conf
	fi
fi
 
systemctl start nginx
