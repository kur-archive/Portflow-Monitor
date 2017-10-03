wait to add 
## 实现思路
* 首先使用 `iptables` 实现流量的监控，然后记录到文件中
* 通过对文件的数据截取，每小时获取一次流量值，保存到每小时流量日志中
* 每天定时读取和计算，得到日流量，保存每日流量日志中
* 每月的某一时刻，主节点通过 `scp` 指令，获取各个子节点的日流量日志，并计算出月流量，保存到月流量日志备用，并发送邮件通知用户流量信息

## 代码解析
> 其实现在看来感觉那个时候写的代码代码有点冗长了
* 文件 `generate_flowlog.sh` :
```bash
//line 5
portlist = `cat /home/ssr/mudb.json | grep port | sed -r 's/( )+\"port\": //g' | sed 's/,$//g' `

//line 7
`iptables -L -nvx > /root/flowListen/tmp.txt`

//line 9
filerows=`wc -l /root/flowListen/tmp.txt | cut -d ' ' -f 1`

//line 11
inputStartRow=`iptables -L -nvx | grep -n "Chain INPUT " | cut -d ':' -f 1 `

//line 13
outputStartRow=`iptables -L -nvx | grep -n "Chain OUTPUT " | cut -d ':' -f 1 `

//line 15
endRows=`cat /root/flowListen/tmp.txt | grep -n "^$" | cut -d ':' -f 1`
```

