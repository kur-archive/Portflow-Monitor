<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Contracts\Queue\ShouldQueue;

class OrderShipped extends Mailable
{
    use Queueable, SerializesModels;

    /**
     * Create a new message instance.
     *
     * @return void
     */
    protected $infoArr;

    public function __construct($arr)
    {
        $this->infoArr = $arr;
    }

    /**
     * Build the message.
     *
     * @return $this
     */
    public function build()
    {
        return $this
            ->from(config('mail.from.address'),config('mail.from.name'))
            ->view('emails.index')
            ->subject('[AAAA]'.$this->infoArr['port'].'端口的用户，您本月的流量记录')
            ->with([
                'port' => $this->infoArr['port'],
                'portFlow' => $this->infoArr['portFlow'],
                'email' => $this->infoArr['email'],
                'spend' => $this->infoArr['spend'],
            ]);//这里换一种方式传值
//        return $this->view('view.name');
    }
}
