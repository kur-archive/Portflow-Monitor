#!/usr/bin/env bash
#此脚本每日0点1min执行
#统计前一日的流量情况，计入月流量记录中

#获取年份的后两位
year=`date +%y`
#获取月份，01-12
month=`date +%m`
#获取月份中的几号，用两位数表示，01-31
day=`date +%d`
#获取今天的昨天
yesterday=`date -d "1 day ago" +"%y%m%d"`

#获取需要统计的端口列表
portlist=`cat /home/ssr/mudb.json | grep port | sed -r 's/( )+\"port\": //g' | sed 's/,$//g' `


for var in $portlist
do
	portflow=`cat ${yesterday}_daylog.txt|grep "port:$var" | cut -d " " -f 3`
	sum=0
	for avar in $portflow
	do
		sum=$(($sum+avar))
	done
	echo ${yesterday}  port:$var  $sum >> ${year}${month}_monthlog.txt
done
	echo -e '' >> ${year}${month}_monthlog.txt




