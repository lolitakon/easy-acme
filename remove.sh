#!/bin/bash
# 从easy_acme.sh中分割出来完善的内容
# 独立出来删除残留以及替换nginx域名信息

echo "删除acme残留"
read -p "请输入您的旧域名：" old_domain
read -p "请输入你的新域名：" domainName
acme remove $old_domain
read -p "是否需要替换nginx内的域名信息？(y/n(默认))：" is_mod
if [ "$is_mod" = "y" ]; then
        sed -i "s/$old_domain/$domainName/g" /etc/nginx/nginx.conf
        echo "替换成功！将重启机器清空旧证书缓存"
fi
