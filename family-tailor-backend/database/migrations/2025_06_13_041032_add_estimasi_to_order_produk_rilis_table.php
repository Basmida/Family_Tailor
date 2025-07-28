<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('order_produk_rilis', function (Blueprint $table) {
            $table->date('estimasi_tiba_min')->nullable();
            $table->date('estimasi_tiba_max')->nullable();
        });
    }

    public function down()
    {
        Schema::table('order_produk_rilis', function (Blueprint $table) {
            $table->dropColumn(['estimasi_tiba_min', 'estimasi_tiba_max']);
        });
    }
};
