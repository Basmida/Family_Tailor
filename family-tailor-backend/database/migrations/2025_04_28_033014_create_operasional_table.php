<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateOperasionalTable extends Migration
{
    public function up()
    {
        Schema::create('operasional', function (Blueprint $table) {
            $table->id();
            $table->string('nama_item', 100);
            $table->date('tanggal');
            $table->enum('jenis_operasional', ['pemasukan', 'pengeluaran']);
            $table->decimal('nominal', 15, 2);
            $table->string('keterangan', 100)->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('operasional');
    }
}
