<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddStatusPembayaranToOrderKatalogTable extends Migration
{
    public function up()
    {
        Schema::table('order_katalog', function (Blueprint $table) {
            $table->enum('status_pembayaran', ['belum_lunas', 'lunas'])
                ->default('belum_lunas')
                ->after('total_harga'); // Menaruh setelah kolom total_harga
        });
    }

    public function down()
    {
        Schema::table('order_katalog', function (Blueprint $table) {
            $table->dropColumn('status_pembayaran');
        });
    }
}
