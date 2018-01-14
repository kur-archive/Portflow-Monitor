# Portflow-Monitor 
<small>linux端口流量监视</small>

[![branch](https://img.shields.io/badge/branch-shell-green.svg)](#)
[![Operating System](https://img.shields.io/badge/OperatingSystem-CentOS%207.x-red.svg)](#)
[![license](https://img.shields.io/npm/l/express.svg)](#)

项目 `实现思路` & `代码解析` 参见 [Doc](https://github.com/Kuri-su/Portflow-Monitor/blob/shell/_doc/Thinking%26CodeResolve.md "Doc" )   

## 简介
主要用于 `socks5` 传输的一种 `纯shell` 统计<b>端口流量</b>的<b>可行思路</b>，主要为了交流和学习

示例脚本可以用于正常使用，不过还是推荐之后更新的 `laravel` 版本，查看 [更新计划](https://github.com/Kuri-su/Portflow-Monitor#更新计划 "update plan")，查看 [运行效果](https://github.com/Kuri-su/Portflow-Monitor#运行效果)

<hr/>

## 安装与部署

\# 安装步骤如下：

* 修改文件
    1. 修改 `/chileNode/generate_flowlog.sh` 文件

        1. `line 5` ,默认从 `/home/ssr/mudb.json` 中获取需要监控的端口，如需要监控别的端口，请修改相关代码, 若需要监控的是`/home/ssr/mudb.json`则无需变动，点击 [此处](https://github.com/Kuri-su/Portflow-Monitor/blob/shell/_other/mudb.json) 参见 `mudb.json` 文件例示
        ```shell
        portlist=
            ` cat /home/ssr/mudb.json 
            | grep port 
            | sed -r 's/( )+\"port\": //g' 
            | sed 's/,$//g' `
        ```
    
    2. 修改 `/chileNode/dateProcessing.sh` 文件
        1. `line 15`, 因为也是从 `/home/ssr/mudb.json` 中获取需要监控的端口，如需要监控别的端口，请修改相关代码， 若需要监控的是`/home/ssr/mudb.json`则无需变动，点击 [此处](https://github.com/Kuri-su/Portflow-Monitor/blob/shell/_other/mudb.json) 参见 `mudb.json` 文件例示
        
        ```bash
            代码同上
        ```

    3. 修改 `/masterNode/flowCal_sendmail_bymaster.sh`  文件<br/>
        1. `line 13`, 填写需要收取流量资料的服务器的ssh登陆 `IP` 和 `port` 
        ```bash
            eg: 
            targetIP = '111.111.111.111'
            targetPort = '1234'
        ```
    
        2. `line 19-24`, 填写邮件的发送需要用到的各种信息
            
        ```bash
            eg:
            email_sender = "aaa@gmail.com"
            email_username = "gmail_username"
            email_password = "gmail_userpass"
            email_smtphost = "smtp.gmail.com"
        ```
        
        3. `line 80-97+`, 填写邮件的标题、内容、以及每个端口的目标邮箱
        ```bash
           eg:
           email_title = "email_title"
           email_content = "email_content"

           case $var in
               "1234")
                   email_reciver="a@gmail.cc"
           	`./sendEmail -f ${email_sender} -t ${email_reciver} -s ${email_smtphost} -u ${email_title} -xu ${email_username} -xp ${email_password} -m ${email_content} -o tls=no`
               ;;
               "1235")
                   email_reciver="b@gmail.cc"
           	`./sendEmail -f ${email_sender} -t ${email_reciver} -s ${email_smtphost} -u ${email_title} -xu ${email_username} -xp ${email_password} -m ${email_content} -o tls=no`
               ;;
               "1236")
                   email_reciver="c@gmail.cc"
           	`./sendEmail -f ${email_sender} -t ${email_reciver} -s ${email_smtphost} -u ${email_title} -xu ${email_username} -xp ${email_password} -m ${email_content} -o tls=no`
               ;;
           
               *)
                   echo -e "~~~Time:${date} ~~~~Content: ${portflow}  is not sendEmail ">> /var/log/flowCal/error.log
               ;;
               esac
        ```
        如果有更多，新增 `case` 选项，例示代码如下
        ```bash
           "1237")
               email_reciver = "d@gmail.cc"
               `./sendEmail -f ${email_sender} -t ${email_reciver} -s ${email_smtphost} -u ${email_title} -xu ${email_username} -xp ${email_password} -m ${email_content} -o tls=no`
               ;;
        ```
    
<hr/>
# 部署例示如下：<br/>

> `chileNode`文件夹内的文件放在子节点，也就是需要采集端口流量数据的服务器上<br/>
> `masterNode`文件夹内的文件放在主节点，也就是scp采集、计算流量以及发送邮件的服务器商<br/>

* 子节点 `chileNode`
    1. 将 `dateProcessing.sh` 和 `generate_flowlog.sh` 拷贝到 `/root/flowCal/` 文件夹下.
        > 可以根据自身需要放在别的文件夹下，这里只是做个例示
    2. 输入指令
        ```bash
            vim /etc/crontab 
        ```
        
        添加 两条计划任务 ，输入完成后，文件大致为这样
        
        ```bash
           SHELL=/bin/bash
           PATH=/sbin:/bin:/usr/sbin:/usr/bin
           MAILTO=root
           
           # For details see man 4 crontabs
           
           # Example of job definition:
           # .---------------- minute (0 - 59)
           # |  .------------- hour (0 - 23)
           # |  |  .---------- day of month (1 - 31)
           # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
           # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
           # |  |  |  |  |
           # *  *  *  *  * user-name  command to be executed
           
            0  */1 * * *  root  /usr/bin/sh /root/flowCal/generate_flowlog.sh   
            1  0  */1 * * root  /usr/bin/sh /root/flowCal/dateProcessing.sh
        ```
        
        使用 :wq 保存

* 主节点 `masterNode`
    1. 将 `flowCal_sendmail_bymaster.sh` 拷贝到主服务器 `/root/flowCal/` 文件夹下.
        > 可以根据自身需要放在别的文件夹下，这里只是做个例示
        > 如果只有一台服务器，主节点脚本和副节点脚本放在同一台服务器上的问题也不大
    2. 输入指令
        ```bash
            vim /etc/crontab 
        ```
        
        添加 一条计划任务 ，输入完成后，文件大致为这样
                
       ```bash
           SHELL=/bin/bash
           PATH=/sbin:/bin:/usr/sbin:/usr/bin
           MAILTO=root
           
           # For details see man 4 crontabs
           
           # Example of job definition:
           # .---------------- minute (0 - 59)
           # |  .------------- hour (0 - 23)
           # |  |  .---------- day of month (1 - 31)
           # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
           # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
           # |  |  |  |  |
           # *  *  *  *  * user-name  command to be executed
           
            11 * * */1 *  root  /usr/bin/sh /root/flowCal/flowCal_sendmail_bymaster.sh
        
        
           使用 :wq 保存
        ```

<br/>
至此，部署完成<br/>

关于项目 `实现思路` & `代码解析` 参见 [Doc](https://github.com/Kuri-su/Portflow-Monitor/blob/shell/_doc/Thinking%26CodeResolve.md "Doc" ) 



## 运行效果
日志目录截图<br/>
![image](https://github.com/Kuri-su/Portflow-Monitor/blob/shell/_img/dirImg.png "dirImg")<br/>
小时日志截图<br/>
![image](https://github.com/Kuri-su/Portflow-Monitor/blob/shell/_img/hourImg.png "hourImg")<br/>
每日目录截图<br/>
![image](https://github.com/Kuri-su/Portflow-Monitor/blob/shell/_img/dayImg.png "dayImg")<br/>



## WARNING
因为 `flowCal_sendmail_bymaster.sh` 使用了 `linux` 上的 `sendEmail` 程序，而该程序久未更新和维护， `SSL` 在新版本的perl下运行会报错，而 `Gmall`是强制 `SSL`，所以推荐使用 `Sina` 邮箱，且 `Sina` 邮箱发邮件无限制， 而 `Gmail` 如果连续发邮件会有时间间隔限制(反垃圾邮件).


## 更新计划
+ `子节点脚本`采用json格式来记录流量数据<br/>


## LICENSE
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>MIT</b>
