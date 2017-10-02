#!/usr/bin/env bash
#此脚本每个月一号零点3分执行
#从指定服务器拷贝上个月的流量总结，并统计，然后发送邮件


#获取上个月的日期
lastMonth=`date -d "1 month ago" +"%y%m"`
month=`date +%y%m`
year=`date +%Y`
date=`date`
onlymonth=`date +%m`
#首先复制上个月的流量总结过来
#TODO::这里填写收取的子节点服务器IP和端口
targetIP='目标服务器'
targetPort='端口'

#设定邮件配置信息
#TODO::这里需要填写邮件的发送者，smtp的用户名密码以及smtphost，有问题可以在isset提出
email_sender=""
email_username=""
email_password=""
email_smtphost="smtp.sina.com"
email_title=""


`scp -P ${targetPort} ${targetIP}:/root/flowListen/${lastMonth}_monthlog.txt /root/flowCal/loglist`

#先根据最后一列的端口决定要计算的端口
#首先获取最后一段的行数
##先输出一个行数的临时文件
`cat /root/flowCal/loglist/${lastMonth}_monthlog.txt | grep -n "^$" | cut -d ':' -f 1 > /root/flowCal/row.tmp`
lastlist_startRow=`tac /root/flowCal/row.tmp | sed -n '2p'`
lastlist_endRow=`tac /root/flowCal/row.tmp | sed -n '1p'`
##删除临时文件
`rm -f /root/flowCal/row.tmp`

#然后截取出来获得portList
portlist=`cat /root/flowCal/loglist/${lastMonth}_monthlog.txt | sed -n "${lastlist_startRow},${lastlist_endRow}p" | sed -r 's/[0-9]+( )+port://g' | sed -r 's/( )+[0-9]+//g'`

#然后根据portList循环，获取每个port的流量总值
for var in $portlist
do
    portflow=`cat /root/flowCal/loglist/${lastMonth}_monthlog.txt | grep "port:$var" | cut -d ' ' -f 3`
    sum_e=0
    for avar in $portflow
    do
        sum_e=$(($sum_e+avar))
    done
    echo ${month}  port:$var  $sum_e >> /root/flowCal/${year}_yearlog.txt
    echo ${month}  port:$var  $sum_e >> /root/flowCal/flow.tmp
done

echo -e '' >> /root/flowCal/${year}_yearlog.txt


#获取总值后用邮件报告

for var in $portlist
do
    portflow=`cat /root/flowCal/flow.tmp | grep "port:$var" `
    flow_num_original=`echo ${portflow} | cut -d ' ' -f 3 `
    flow_tmp_gb=$(($flow_num_original/1024/1024/1024 ))
    flow_tmp_mb=$(($flow_num_original/1024/1024 ))
    flow_tmp_kb=$(($flow_num_original/1024 ))
    flowUnit=''
    if [ $flow_tmp_gb -ne "0" ];then
        flow_num=$flow_tmp_gb
        flowUnit='GB'
        elif [ $flow_tmp_mb -ne "0" ];then
               flow_num=$flow_tmp_mb
               flowUnit='MB'
               elif [ $flow_tmp_kb -ne "0" ];then
               flow_num=$flow_tmp_kb
               flowUnit='KB'
               else
               flow_num=$flow_num_original
               flowUnit='B'
    fi

    #TODO::下面中文的部分都需要补充
    email_title="邮件title"

    email_content="
        邮件内容"


    case $var in
    "端口")
        email_reciver="目标邮箱"
	`./sendEmail -f ${email_sender} -t ${email_reciver} -s ${email_smtphost} -u ${email_title} -xu ${email_username} -xp ${email_password} -m ${email_content} -o tls=no`
    ;;
    "端口")
        email_reciver="目标邮箱"
	`./sendEmail -f ${email_sender} -t ${email_reciver} -s ${email_smtphost} -u ${email_title} -xu ${email_username} -xp ${email_password} -m ${email_content} -o tls=no`
    ;;"端口")
        email_reciver="目标邮箱"
	`./sendEmail -f ${email_sender} -t ${email_reciver} -s ${email_smtphost} -u ${email_title} -xu ${email_username} -xp ${email_password} -m ${email_content} -o tls=no`
    ;;

    *)
        echo -e "~~~Time:${date} ~~~~Content: ${portflow}  is not sendEmail ">> /root/flowCal/error.log
    ;;
    esac
done

`rm -f /root/flowCal/flow.tmp`