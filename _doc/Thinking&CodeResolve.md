wait to add 
## 实现思路
* 首先使用 `iptables` 实现对端口流量的监控，然后输出到文本中
* 通过对文本的字符截取，获取每小时的流量值，保存到小时流量日志中
* 每天定时读取和计算，得到日流量，保存日流量日志中
* 每月的某一时刻，主节点通过 `scp` 指令，获取各个子节点的日流量日志，并计算出月流量，保存到月流量日志备用，并发送邮件通知用户流量信息

## 代码解析
> 其实现在看来感觉那个时候写的代码代码有点冗长了
* 文件 `generate_flowlog.sh` :
```bash
#该脚本记录每小时的流量情况，并将iptables的数据清空,并计入日流量记录中

#从mudb.json文件中获取需要监控的端口
    portlist=`cat /home/ssr/mudb.json | grep port | sed -r 's/( )+\"port\": //g' | sed 's/,$//g' `
#cat mudb.json文件, grep取出带有port关键字的行, 然后使用sed 指令逐步去掉端口号数字周围的别的字符, 最后将一列端口号赋值给portlist变量
#( mudb.json的例示在项目的 /_other/mudb.json )
#sed -r 's/( )+\"port\": //g' 表示将 1~n个空格"port": 删除掉( 替换成空 ) , -r 表示支持正则语法, 后面的sed同理 

#将目前iptables的数据存入tmp.txt中
    `iptables -L -nvx > /root/flowListen/tmp.txt`


#获取tmp.txt的行数
    filerows=`wc -l /root/flowListen/tmp.txt | cut -d ' ' -f 1`

#获取input那一块的行数
    inputStartRow=`iptables -L -nvx | grep -n "Chain INPUT " | cut -d ':' -f 1 `
#因为iptables的日志中有非常多的部分, 截取出关于input的区块
#其实input这块不用统计也行... 但是怕仓促删掉程序报错, 就先没删

#获取output这一块的行数
    outputStartRow=`iptables -L -nvx | grep -n "Chain OUTPUT " | cut -d ':' -f 1 `
#因为iptables的日志中有非常多的部分, 截取出关于output的区块


#获取结束的行数
    endRows=`cat /root/flowListen/tmp.txt | grep -n "^$" | cut -d ':' -f 1`

    thisMonth=`date +%y%m`
#获取年月 eg: 1709

    thisDay=`date +%y%m%d`
#获取年月日 eg: 170901




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
#这样一方面是为了在添加了新的端口用户以后,可以立刻更新到, 另一方面是因为 iptables 的这个配置我没有写入配置, 在重启后会还原, 所以每次启动脚本之前会检查一遍, mudb.json 中各个端口的监听情况, 如果有端口漏了,就会加上去, 这样即便丢失,也只是丢失某一个小时的流量数据

#这里是对output的端口进行判断,如果如果已经监听,则在数组中标记为LISTEN
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

#这里是对input的端口进行判断,如果如果已经监听,则在数组中标记为LISTEN
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

#输出日志文件
for var in $portlist
do

    #awk 截取端口流量信息
	outputFlow_tcp=`cat /root/flowListen/tmp.txt | sed -n "$outputStartRow,$outputEndRow p" | grep "tcp spt:$var" | awk '{print $2 }'`
	echo $outputFlow_tcp
	echo `date +%Y/%m/%d_%T`  port:$var  $outputFlow_tcp >> /root/flowListen/${thisDay}_daylog.txt

	echo `date +%Y/%m/%d_%T`  port:$var  $outputFlow_tcp >> /root/flowListen/_nowlog.txt
	
	`iptables -Z OUTPUT`
done

echo -e '' >>  /root/flowListen/${thisDay}_daylog.txt

```

