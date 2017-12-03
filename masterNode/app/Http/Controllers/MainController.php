<?php
/**
 * Created by PhpStorm.
 * User: kurisu
 * Date: 2017/08/27
 * Time: 16:00
 */

namespace App\Http\Controllers;

use App\Mail\OrderShipped;
use Illuminate\Support\Facades\Mail;

class MainController extends Controller
{
    private $targetIP , $targetPort;

    public function __construct( $targetIP = 'yourEmail@gmail.com' , $targetPort = 22 )
    {
        $this->targetIP   = $targetIP;
        $this->targetPort = $targetPort;
    }

    public function getNote()
    {
        $targetIP   = $this->targetIP;
        $targetPort = $this->targetPort;

        $bigArr  = [];
        $userArr = [
            1234 => 'yourEmail@gmail.com' ,
        ];//用户Email地址与端口的对应


        $lastMonth = date( 'ym' , strtotime( '-1 month' ) );
        $yesr      = date( 'Y' , strtotime( '-1 month' ) );
        $scpResult = shell_exec( "scp -P $targetPort root@$targetIP:/yourdir/{$lastMonth}_monthlog.txt /var/log/portflowMonitor/monthLog/" );

        if (strpos( $scpResult , 'No such file or directory' ) != false && strpos( $scpResult , '100%' ) === false)
        {
            shell_exec( "echo '" . date( 'Y-m-d h:i:s' , time() ) . " scp copy error' >> /var/log/portflowMonitor/error.log" );
            echo "scp error \n";
            die();
            //return();
        }
        shell_exec( "cat /var/log/portflowMonitor/monthLog/{$lastMonth}_monthlog.txt | grep -n \"^$\" | cut -d ':' -f 1 > /var/log/portflowMonitor/row.tmp" );
        $lastlist_startRow = shell_exec( "tac /var/log/portflowMonitor/row.tmp | sed -n '2p'" );
        $lastlist_startRow = substr( $lastlist_startRow , 0 , strlen( $lastlist_startRow ) - 1 );
        $lastlist_endRow   = shell_exec( "tac /var/log/portflowMonitor/row.tmp | sed -n '1p'" );
        $lastlist_endRow   = substr( $lastlist_endRow , 0 , strlen( $lastlist_endRow ) - 1 );
        shell_exec( "rm -f /var/log/portflowMonitor/row.tmp" );
        $portList = shell_exec( "cat /var/log/portflowMonitor/monthLog/{$lastMonth}_monthlog.txt | sed -n '{$lastlist_startRow},{$lastlist_endRow}p' | sed -r 's/[0-9]+( )+port://g' | sed -r 's/( )+[0-9]+//g'" );
        $portList = explode( "\n" , $portList );
        foreach($portList as $port)
        {
            if ($port != '')
            {
                $portFlowList = shell_exec( "cat /var/log/portflowMonitor/monthLog/{$lastMonth}_monthlog.txt | grep 'port:$port' | cut -d ' ' -f 3" );
                $portFlowList = explode( "\n" , $portFlowList );
                $portFlows    = 0;
                foreach($portFlowList as $portFlow)
                {
                    if ($portFlow != '')
                    {
                        $portFlows += $portFlow;
                    }
                }

                $bigArr[$port] = $portFlows;
                shell_exec( "echo $lastMonth port:$port $portFlows  >> /var/log/portflowMonitor/yearLog/{$yesr}_year.log" );
            }
        }
        shell_exec( "echo -e '\n' >> /var/log/portflowMonitor/yearLog/{$yesr}_year.log" );

        foreach($bigArr as $port_ => $portFlows_)
        {
            $portFlows_C = $this->bytesToSize( $portFlows_ );
            foreach($userArr as $port_b => $email)
            {
                if ($port_ == $port_b)
                {
                    $arr = [
                        'port'     => $port_ ,
                        'portFlow' => $portFlows_C ,
                        'email'    => $email ,
                        'spend'    => 0
                    ];
                    $this->sendMail( $email , $arr );
                    break;
                }
            }
        }


    }


    public function sendMail( $mail = 'yourEmail@gmail.com' , $arr )
    {

        Mail::to( $mail )->send( new OrderShipped( $arr ) );
    }

    public function bytesToSize( $bytes )
    {
        $k     = 1024;
        $sizes = ['B' , 'KB' , 'MB' , 'GB' , 'TB' , 'PB' , 'EB' , 'ZB' , 'YB'];
        $i     = (int)floor( log( $bytes )/log( $k ) );
        return round( $bytes/pow( $k , $i ) , 3 ) . ' ' . $sizes[$i];
    }
}
