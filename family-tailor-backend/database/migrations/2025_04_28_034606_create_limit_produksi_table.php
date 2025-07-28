<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateLimitProduksiTable extends Migration
{
    public function up()
    {
        Schema::create('limit_produksi', function (Blueprint $table) {
            $table->id();
            $table->integer('jumlah_limit');
            $table->unsignedTinyInteger('bulan'); // 1–12
            $table->year('tahun');                // 4 digit tahun
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('limit_produksi');
    }
}
