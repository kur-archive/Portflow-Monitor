# Portflow-Monitor
linux端口流量监视<br/>

代码整理中（现在看来几个月之前写的代码也是不堪入目的。。。）<br/>
说明整理中<br/><br/>
child node是需要收集的节点使用的脚本<br/>
master node是主节点，收集子节点的流量日志，计算流量，发送邮件<br/>

<hr/>

不过我现在其实已经不用这个纯Shell的流量计算，现在是把现在用的这套用Laravel移植了的一个流量计算，理由如下<br/>

a.PHP处理起数据来会更加自由，也可以用Shell_exec使用shell的力量来处理<br/>
<br/>
b.邮件发送，Linux上的一些邮件发送程序长时间无人维护，以至于在新版的perl下ssl发送无法运行。。。使用Laravel（php）的smtp邮件发送类，搭配blade模板渲染，发送邮件更加方便，再和之后要做的后台搭配效果更佳<br/>
