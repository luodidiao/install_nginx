#!/bin/bash


#软件安装目录
installDir='/usr/local/nginx'

#nginx调度器:lvs|pythonweb服务器:py|phpweb服务器:php|nginx服务器:default
#nginx服务器类型(lvs|py|php|default)
nginxType='default'

#1:nginx-1.12.2.tar.gz
#2:nginx-1.14.2.tar.gz
#3:nginx-1.16.0.tar.gz
#4:nginx-1.17.1.tar.gz
#提示：0或者不填，默认安装以上最新版本
nginxVersion='0'


#安装依赖包函数
function installPackage(){
    n=$(yum -y install `cat requestion.txt | grep -v ^$ | grep -v ^#` | grep ^'没有可用软件包' | wc -l)
    if [ $n -eq 0 ];then
        echo -e '\033[32m依赖包安装完成!\033[0m'
    else
        echo -e '\033[31m依赖包安装失败,具体信息如下:\033[0m'
        yum -y install `cat requestion.txt | grep -v ^$ | grep -v ^#` | grep ^'没有可用软件包'
        echo -e '\033[31m请配置好yum源重新安装！\033[0m'
        exit 1
    fi   
}

#生成目录清单函数
function getMenu(){
    i=$(ls -l ./packages/nginx/ | awk '{print $9}' | wc -l)
    let i--
    ls -l ./packages/nginx/ | awk '{print $9}' | tail -$i > ./source/nginx_menu.txt   
    
}

#安装nginx函数
function installNginx(){
    tar -xf ./packages/nginx/$1 -C ./source/ 
    cd ./source/nginx*
    ./configure --prefix=${installDir} `cat ../../packages/modulefile/$2 | grep -v ^$ | grep -v ^#`
    make && make install 
    rm -rf ../nginx-*
    cd ../../
    
}

#安装依赖包
installPackage

#生成清单
getMenu

#创建用户
id nginx >> /dev/null
if [ ! $? -eq 0 ];then
    useradd -s /sbin/nologin nginx   
fi


#安装程序
tm=$(cat ./source/nginx_menu.txt | wc -l)
if [ -z "${nginxVersion}" ]|| [ ${nginxVersion} -gt $tm ]||[ ${nginxVersion} -le 0 ];then
    nginxName=$(cat source/nginx_menu.txt | awk "{if(NR==$tm){print $1}}")
    echo $nginx_name
    if [ -z "${nginxType}" ];then
         installNginx ${nginxName} default_nginx_module.txt
    else
	        case ${nginxType} in 
	        lvs)
	            installNginx ${nginxName} lvs_nginx_module.txt;;
	        py)
	            installNginx ${nginxName} python_web_nginx_module.txt;;
	        php)
	            installNginx ${nginxName} php_web_nginx_module.txt;;
	        default)
	            installNginx ${nginxName} default_nginx_module.txt;;
	        *)
	            installNginx ${nginxName} default_nginx_module.txt
    esac
    fi
else
    nginx_name=$(cat source/nginx_menu.txt | awk "{if(NR==$nginxVersion){print $1}}")
    if [ -z "${nginxType}" ];then
         installNginx ${nginxName} 'default_nginx_module.txt'
    else
	        case ${nginxType} in 
	        lvs)
	            installNginx ${nginxName} lvs_nginx_module.txt;;
	        py)
	            installNginx ${nginxName} python_web_nginx_module.txt;;
	        php)
	            installNginx ${nginxName} php_web_nginx_module.txt;;
	        default)
	            installNginx ${nginxName} default_nginx_module.txt;;
	        *)
	            installNginx ${nginxName} default_nginx_module.txt
    esac
    fi
fi
wait
#拷贝nginx管理脚本到nginx安装目录下
\cp nginxctl.sh ${installDir}/
#配置链接
ln -s  /usr/local/nginx/nginxctl.sh /sbin/nginxctl

echo -e "\033[32m软件安装成功，软件安装路径：${installDir}\033[0m"
