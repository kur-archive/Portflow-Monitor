<?php

namespace App\Console;

use App\Http\Controllers\MainController;
use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;


//use \App\Http\MailControllers\flowListenController;

class Kernel extends ConsoleKernel
{
    /**
     * The Artisan commands provided by your application.
     *
     * @var array
     */
    protected $commands = [
        //
    ];

    /**
     * Define the application's command schedule.
     *
     * @param  \Illuminate\Console\Scheduling\Schedule $schedule
     * @return void
     */
    protected function schedule( Schedule $schedule )
    {
        $schedule->call( function()
        {
            $sendMail = new MainController( config( 'mail.childNode.ip' ) , config( 'mail.childNode.port' ) ?? 22 );
            $sendMail->getNote();
            echo 'Laravel - cron start ' . date( 'Y-m-d h-i-s' , time() ) . "\n";
        } )->monthlyOn( 1 , '00:11' );
    }

    /**
     * Register the Closure based commands for the application.
     *
     * @return void
     */
    protected function commands()
    {
        require base_path( 'routes/console.php' );
    }
}
