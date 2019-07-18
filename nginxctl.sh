#!/bin/bash

#nginx安装目录
installDir='/usr/local/nginx'
 if [ $# -eq 1 ];then
     case $1 in 
     start)
         i=`ps -C nginx| wc -l`
         if [ $i -gt 1 ];then
             echo -e '\033[31mnginx已经启动....\033[0m'
         else        
		         echo -e '\033[32mnginx启动中....\033[0m'
		         sleep 2
		         ${installDir}/sbin/nginx
		         echo -e '\033[32mnginx启动成功\033[0m'
         fi
         ;;
     restart)
         echo -e '\033[32mnginx重起中....\033[0m'
         sleep 2
         i=`ps -C nginx| wc -l`
         if [ $i -gt 1 ];then
             killall -9 nginx
         fi      
         ${installDir}/sbin/nginx
         echo -e '\033[32mnginx重起成功\033[0m';;
     stop)
         echo -e '\033[32mnginx停止中....\033[0m'
         sleep 2
         i=`ps -C nginx| wc -l`
         if [ $i -gt 1 ];then
             killall -9 nginx
             echo -e '\033[32mnginx停止成功\033[0m'
         else
             echo -e '\033[31mnginx未启动\033[0m'
         fi 
         ;;
     reload)
         echo -e '\033[32mnginx重载中....\033[0m'
         i=`ps -C nginx| wc -l`
         if [ $i -gt 1 ];then
             ${installDir}/sbin/nginx -s reload
             sleep 2
             echo -e '\033[32mnginx重载成功\033[0m'
         else        
		         echo -e '\033[31mnginx未启动，重载失败....\033[0m'	         
         fi
         ;;
     *)
         echo -e '\033[31mstart|restart|stop|reload\033[0m'
     esac
 else
     echo -e '\033[31mstart|restart|stop|reload\033[0m'
 
 fi






