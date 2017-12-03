<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/
//use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('mail/send', '\App\Http\MailControllers\mainController@getNote');
//Route::get('mail/send', function () {    return new App\Mail\OrderShipped(); });
Route::get('check/template', function () {
    $arr = [
        'port' => '777',
        'email' => 'email.com',
        'portFlow' => '1GB',
    ];
    return view('emails.index', compact('arr'));
});