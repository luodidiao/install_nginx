#!/bin/bash


install_dir='/usr/local/nginx'
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
    ./configure --prefix=${install_dir} `cat ../../packages/modulefile/$2 | grep -v ^$ | grep -v ^#`
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
if [ $# -eq 0 ];then
    echo -e '\033[32m安装nginx(序号从上到下：1-n)\033[0m'
    cat ./source/nginx_menu.txt
    tm=$(cat ./source/nginx_menu.txt | wc -l)
    read -p'请输入安装的软件序号(默认安装最新版本):' num
    if [ -z $num ]|| [ $num -gt $tm ]||[ $num -lt 0 ];then
        echo -e '\033[32mnginx调度器:lvs|pythonweb服务器:py|phpweb服务器:php|nginx服务器:default\033[0m'
        read -p'请输入nginx服务器类型(lvs|py|php|default):' nt
        nginx_name=$(cat source/nginx_menu.txt | awk "{if(NR==$tm){print $1}}")
        echo $nginx_name
        if [ -z "$nt" ];then
             installNginx ${nginx_name} default_nginx_module.txt
        else
		        case $nt in 
		        lvs)
		            installNginx ${nginx_name} lvs_nginx_module.txt;;
		        py)
		            installNginx ${nginx_name} python_web_nginx_module.txt;;
		        php)
		            installNginx ${nginx_name} php_web_nginx_module.txt;;
		        default)
		            installNginx ${nginx_name} default_nginx_module.txt;;
		        *)
		            installNginx ${nginx_name} default_nginx_module.txt
        esac
        fi
        
        
    else
        echo 'nginx调度器:lvs|pythonweb服务器:py|phpweb服务器:php|nginx服务器:default'
        read -p'请输入nginx服务器类型(lvs|py|php|default):' nt
        nginx_name=$(cat source/nginx_menu.txt | awk "{if(NR==$num){print $1}}")
        if [ -z "$nt" ];then
             installNginx ${nginx_name} 'default_nginx_module.txt'
        else
		        case $nt in 
		        lvs)
		            installNginx ${nginx_name} lvs_nginx_module.txt;;
		        py)
		            installNginx ${nginx_name} python_web_nginx_module.txt;;
		        php)
		            installNginx ${nginx_name} php_web_nginx_module.txt;;
		        default)
		            installNginx ${nginx_name} default_nginx_module.txt;;
		        *)
		            installNginx ${nginx_name} default_nginx_module.txt
        esac
        fi
    fi
    wait
    #拷贝nginx管理脚本到nginx安装目录下
    \cp nginxctl.sh ${install_dir}/
    #配置链接
    ln -s  /usr/local/nginx/nginxctl.sh /sbin/nginxctl

    echo -e "\033[32m软件安装成功，软件安装路径：${install_dir}\033[0m"
else
    echo -e '\033[31m请输入：软件包全称 软件安装路径\033[0m'
    echo -e '\033[31m例子：nginx-1.12.2.tar.gz /usr/local/nginx\033[0m'
    exit 2
fi
