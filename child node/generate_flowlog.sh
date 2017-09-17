#!/usr/bin/env bash
#该脚本记录每小时的流量情况，并将iptables的数据清空,并计入日流量记录中

#从mudb.json文件中获取需要监控的端口
portlist=`cat /home/ssr/mudb.json | grep port | sed -r 's/( )+\"port\": //g' | sed 's/,$//g' `
#将目前iptables的数据存入tmp.txt中
`iptables -L -nvx > /root/flowListen/tmp.txt`
#获取tmp.txt的行数
filerows=`wc -l /root/flowListen/tmp.txt | cut -d ' ' -f 1`
#获取input那一块的行数
inputStartRow=`iptables -L -nvx | grep -n "Chain INPUT " | cut -d ':' -f 1 `
#获取output这一块的行数
outputStartRow=`iptables -L -nvx | grep -n "Chain OUTPUT " | cut -d ':' -f 1 `
#获取结束的行数
endRows=`cat /root/flowListen/tmp.txt | grep -n "^$" | cut -d ':' -f 1`

thisMonth=`date +%y%m`
#thisWeek=`date +%y%V`
thisDay=`date +%y%m%d`


##根据shadowsocksR的配置文件检查和添加监听端口



#声明一个portlist的关联数组，方便之后的判断
declare -A portlistArray_INPUT_tcp
declare -A portlistArray_INPUT_udp
declare -A portlistArray_OUTPUT_tcp
declare -A portlistArray_OUTPUT_udp

#给关联数组赋初始值
for avar in $portlist
do
	portlistArray_INPUT_tcp[${avar}]=NOLISTEN	
	portlistArray_INPUT_udp[${avar}]=NOLISTEN	
	portlistArray_OUTPUT_tcp[${avar}]=NOLISTEN	
	portlistArray_OUTPUT_udp[${avar}]=NOLISTEN	
done

#获取input和output的结束的行
for var in $endRows
do
	if [ $inputStartRow -lt $var ];then
		inputEndRow=$(($var-1))
		break;
	fi
done
for var in $endRows
do
	if [ $outputStartRow -lt $var ];then
		outputEndRow=$(($var-1))
		break;
	fi
done

#一行一行的搜索，标记目前已经在监听的端口

for((i=$outputStartRow; i<=$outputEndRow ; i=i+1))
do
	
	for var in $portlist
	do
		outputTarget_tcp=`cat /root/flowListen/tmp.txt | sed -n "$i p" | grep "tcp spt:$var"`
		if [ "$outputTarget_tcp" != "" ];then
			portlistArray_OUTPUT_tcp[${var}]=LISTEN
		#	echo "port $var is LISTEN output tcp"
		fi
			
		outputTarget_udp=`cat /root/flowListen/tmp.txt | sed -n "$i p" | grep "udp spt:$var"`
		if [ "$outputTarget_udp" != "" ];then
			portlistArray_OUTPUT_udp[${var}]=LISTEN
		#	echo "port $var is LISTEN output udp"
		fi
	done
	

done

for((i=$inputStartRow; i<=$inputEndRow ; i=i+1))
do
	
	for var in $portlist
	do
		inputTarget_tcp=`cat /root/flowListen/tmp.txt | sed -n "$i p" | grep "tcp dpt:$var"`
		if [ "$inputTarget_tcp" != "" ];then
			portlistArray_INPUT_tcp[${var}]=LISTEN
		#	echo "port $var is LISTEN input tcp"
		fi
			
		inputTarget_udp=`cat /root/flowListen/tmp.txt | sed -n "$i p" | grep "udp dpt:$var"`
		if [ "$inputTarget_udp" != "" ];then
			portlistArray_INPUT_udp[${var}]=LISTEN
		#	echo "port $var is LISTEN input udp"
		fi
	done
	

done

#对未被标记的端口进行监听
for bvar in ${!portlistArray_INPUT_tcp[*]}
do
	if [ "${portlistArray_INPUT_tcp[$bvar]}" == "NOLISTEN" ];then
		`iptables -A INPUT -p tcp --dport $bvar`
	fi
done
for bvar in ${!portlistArray_INPUT_udp[*]}
do
	if [ "${portlistArray_INPUT_udp[$bvar]}" == "NOLISTEN" ];then
		`iptables -A INPUT -p udp --dport $bvar`
	fi
done
for bvar in ${!portlistArray_OUTPUT_tcp[*]}
do
	if [ "${portlistArray_OUTPUT_tcp[$bvar]}" == "NOLISTEN" ];then
		`iptables -A OUTPUT -p tcp --sport $bvar`
	fi
done
for bvar in ${!portlistArray_OUTPUT_udp[*]}
do
	if [ "${portlistArray_OUTPUT_udp[$bvar]}" == "NOLISTEN" ];then
		`iptables -A OUTPUT -p udp --sport $bvar`
	fi
done


#流量统计

`rm -f _nowlog.txt`
for var in $portlist
do
	outputFlow_tcp=`cat /root/flowListen/tmp.txt | sed -n "$outputStartRow,$outputEndRow p" | grep "tcp spt:$var" | awk '{print $2 }'`
	echo $outputFlow_tcp
	echo `date +%Y/%m/%d_%T`  port:$var  $outputFlow_tcp >> /root/flowListen/${thisDay}_daylog.txt

	echo `date +%Y/%m/%d_%T`  port:$var  $outputFlow_tcp >> /root/flowListen/_nowlog.txt
	
	`iptables -Z OUTPUT`
done

echo -e '' >>  /root/flowListen/${thisDay}_daylog.txt
