<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>mail</title>
    <style>
        * {
            font-family: 等线;
        }

        .mainPage {
            width: 800px;
            height: auto;
            padding: 25px 75px;
            background: #fdfdfd;
            position: relative;
            z-index: 999;
            box-shadow: 10px 10px 10px #ccc;
        }

        .serverName {
            margin: 0 auto;
            display: block;
            text-align: center;
            padding-bottom: 20px;
            font-size: 400%;
            letter-spacing: 10px;
        }

        .topImg {
            width: 800px;
            height: auto;

        }

        .bill {
            line-height: 50px;
            letter-spacing: 2px;

        }

        .short_sentences {
            margin-left: 50px;
        }

        .description {
            margin: 50px 0 0 10px;
            background: #fafafa;
            line-height: 50px;
        }

        .description span {
            margin-left: 50px;
        }

        .div_by_qrcode {
            width: 600px;
        }

        .qrcode {
            width: 300px;
            height: 300px;
            margin: 0 auto;
            display: block;
            margin-bottom: 30px;
        }

        .title {
            font-weight: bold;
            margin-left: 0;
            font-size: 120%;
        }

        .b {
            font-size: 120%;
            color: #444444;
            font-weight: bold;
        }
    </style>

</head>
<body>
<div class="mainPage">
    <span class="serverName">Portflow-Monitor</span>
    <!--<span class="mainPage_top_background"></span>-->
    <img src="#" alt="" class="topImg">
    <section class="bill">

        <b class="title">HI,端口 <span class="b">{{$port}}</span> 的用户:</b><br/>

        <span class="short_sentences">您本月的流量用量为 ：<span class="b">{{$portFlow}}</span></span><br/>

        <span class="short_sentences">下个月的费用为<span class="b">{{$spend}}元</span></span>

        <br/>

        <p class="description">
            <b class="title">说明：</b>
            <br/><span>代理服务采用预付费制，流量暂且不做限制，恶意行为除外，付费可以使用qq/微信/支付宝</span><br/>
            <span>其次，请勿使用本代理服务访问带有 <b>包括但不限于【邪教/反动】等内容</b>的站点，切勿使用该代理服务参与违法乱纪的活动</span><br/>

            <span>本服务仅供学习生活使用</span><br/>

            <span>祝您生活愉快，来自Portflow-Monitor</span><br/>

        </p>
        <br/>
        <b class="title">扫描下方二维码付款(支付宝)</b><br/>
        <img src="" class="qrcode">

    </section>

</div>


</body>
</html>