<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUkuranBadansTable extends Migration
{
    public function up()
    {
        Schema::create('ukuran_badan', function (Blueprint $table) {
            $table->id();
            $table->integer('lingkar_dada');
            $table->integer('lebar_depan');
            $table->integer('lebar_pundak');
            $table->integer('panjang_depan');
            $table->integer('lingkar_panggul');
            $table->integer('tinggi_nat');
            $table->integer('lebar_nat');
            $table->integer('panjang_baju');
            $table->integer('lingkar_pinggang');
            $table->integer('panjang_lengan');
            $table->integer('lingkar_tangan');
            $table->integer('panjang_rok');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('ukuran_badan');
    }
}

