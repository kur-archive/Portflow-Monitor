# Portflow-Monitor
<small><small><small>linux端口流量监视 with Laravel</small></small></small>

[![branch](https://img.shields.io/badge/branch-laravel-green.svg)](#)
[![Operating System](https://img.shields.io/badge/OperatingSystem-CentOS%207.x-red.svg)](#)
[![license](https://img.shields.io/npm/l/express.svg)](#)
[![php](https://img.shields.io/badge/php-%3E%3D7.0-yellow.svg)](#)

## 简介
主要用于 `socks5` 传输的一种 `纯 shell` 统计端口流量的可行思路，主要为了交流和学习<br>
该分支为 `laravel` 分支，对原本的 `shell` 脚本做了一次封装<br/>
如果需要查看 `纯Shell` 的脚本，请访问 `Shell` 分支：[Shell分支](https://github.com/Kuri-su/Portflow-Monitor/tree/shell)<br/><br/>
**如果因为某些原因无法成功安装 `php7` 和 `composer` 的话，推荐使用[Shell分支](https://github.com/Kuri-su/Portflow-Monitor/tree/shell)，纯 `Shell` 脚本**

> 安装和配置出现问题欢迎打开issue进行讨论和交流，欢迎提出各种建议和PR

## 文件结构
```
-root
 | -childNode
 |  |  -dateProcessing.sh            # 子节点每天生成日志的脚本
 |  |  -generate_flowlog.sh          # 子节点每小时收集的脚本
 | -masterNode
 |  |  -app
 |  |  |  -Console
 |  |  |  |  -Kernel.php             # 设置了计划任务
 |  |  |  -Http
 |  |  |  |  -Controllers
 |  |  |  |  |  -MainController.php  # 主要逻辑
 |  |  |  -Mail
 |  |  |  |  - OrderShipped.php      # 邮件发送类
 |  |  -config
 |  |  |  -mail.php                  # 邮件配置
 |  |  -resources
 |  |  |  -views
 |  |  |  |  -email
 |  |  |  |  |  -index.blade.php     # 邮件模板
 |  |  -.env                         # 配置信息
```

## 安装与部署

**在安装之前请确保已经安装 Composer ，若未安装请参考以下指令安装**

* 安装
  * 在linux/unix下，可以使用指令 `yum install composer -y`(Centos下,别的linux发行版请使用相应的指令) 进行安装,
  * window下参考 [composerCN](http://docs.phpcomposer.com/00-intro.html#Installation-Windows)的windows下的安装方法进行安装

* 设置使用中国Composer源
  ```shell
  $ composer config -g repo.packagist composer https://packagist.laravel-china.org
  ```
  
**在安装之前请确保已经安装 php ，且php版本大于7,若未安装请参考以下指令安装**

[ 在`CentOS7`下`yum`安装`PHP7` ](http://blog.csdn.net/liubag/article/details/53138366)

<hr/>

##### 安装步骤如下：
* MasterNode
  1. 在 `masterNode` 文件夹下，运行指令
  ```shell
  $ composer update
  ```
  若未报错，且 `masterNode` 文件夹下下出现 `vendor` 文件夹下，则基本表示成功

  2. 复制一份 `masterNode` 文件夹下的 `.env.example` 文件，更名为 `.env`

  3. 在 `masterNode` 文件夹下，运行指令
      ```shell
      php artisan key:generate
      ```
      若未报错，且 `.env` line 3 的 `APP_KEY=` 后面有值，类似于
      `APP_KEY=base64:9NJ4b06OA2GS3YAVMZ5eBu4w7EmtDuRD/u2J36ZOgG0=`，则表示成功

  4. 填写 `.env` line 25 to line 31 的信息，例如
      ```
      MAIL_DRIVER=smtp
      MAIL_HOST=smtp.gmail.com
      MAIL_PORT=587
      MAIL_USERNAME=yourUsername
      MAIL_PASSWORD=yourPassword
      MAIL_ENCRYPTION=tls
      MAIL_FROM_ADDRESS=yourEmailAddress@gmail.com  //这里是邮件发送出去显示的from Email
      MAIL_FROM_NAME=yourName                       //这里是邮件发送出去显示的from Name
      ```
      **这里如果是个人，推荐比如sina邮箱，gmail会限制连续发送频率**

  5. 填写 `masterNode/config/mail.php` line 129 to line 132 的信息,e.g.
      ```
      'childNode' => [
        'ip' => '1.2.3.4' ,
        'port'=>'22'
      ]
      ```

  6. 在 `masterNode/app/Console/Kernel.php` line 36 行设置时间频率，即多久需要统计一次，默认为 `monthlyOn( 1 , '00:11' )`，即 `每月一号的00:11`，如需调整，或者更换别的频率，可以参考[laravel 手册 任务调度](https://d.laravel-china.org/docs/5.5/scheduling#Shell-命令调度)

  7. 在 `masterNode/app/Http/Controllers/MainController.php` line 30 设置需要发送的地址
    ```php
      $userArr = [
            1234 => 'yourEmail@gmail.com' ,
      ];//用户Email地址与端口的对应
    ```

    line 37 设置需要收集的子节点的路径,在下面 `yourdir` 的位置
    ```php
    $scpResult = shell_exec( "scp -P $targetPort root@$targetIP:/yourdir/{$lastMonth}_monthlog.txt /var/log/portflowMonitor/monthLog/" );
    ```

* chileNode
    1. 修改 `/chileNode/generate_flowlog.sh` 文件

        1. `line 5` ,默认从 `/home/ssr/mudb.json` 中获取需要监控的端口，如需要监控别的端口，请修改相关代码, 若需要监控的是`/home/ssr/mudb.json`则无需变动，点击 [此处](https://github.com/Kuri-su/Portflow-Monitor/blob/master/_other/mudb.json) 参见 `mudb.json` 文件例示
        ```shell
        portlist=
            ` cat /home/ssr/mudb.json
            | grep port
            | sed -r 's/( )+\"port\": //g'
            | sed 's/,$//g' `
        ```

    2. 修改 `/chileNode/dateProcessing.sh` 文件
        1. `line 15`, 因为也是从 `/home/ssr/mudb.json` 中获取需要监控的端口，如需要监控别的端口，请修改相关代码， 若需要监控的是`/home/ssr/mudb.json`则无需变动，点击 [此处](https://github.com/Kuri-su/Portflow-Monitor/blob/master/_other/mudb.json) 参见 `mudb.json` 文件例示

        ```bash
            代码同上
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
    1. 将 `masterNode` 拷贝到主服务器 `/root/portflowMonitor/` 文件夹下.
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

            * * * * * root  /usr/bin/php /root/portflowMonitor/artisan schedule:run >> /dev/null 2>&1

           使用 :wq 保存
        ```

        3. 给 `masterNode/storage` 文件夹下的全部文件777权限
        ```shell
          chmod -R 777 /root/portflowMonitor/storage
        ```

<br/>
至此，部署完成<br/>

关于项目 `实现思路` & `代码解析` 参见 [Doc](https://github.com/Kuri-su/Portflow-Monitor/blob/laravel/_doc/Thinking%26CodeResolve.md "Doc" )

## 更新计划
无

## LICENSE
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>MIT</b>
