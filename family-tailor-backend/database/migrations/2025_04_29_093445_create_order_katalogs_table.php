<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateOrderKatalogsTable extends Migration
{
    public function up()
    {
        Schema::create('order_katalog', function (Blueprint $table) {
            $table->id();

            $table->unsignedBigInteger('id_customer');
            $table->unsignedBigInteger('id_produk_katalog');
            $table->unsignedBigInteger('id_ukuran_badan');

            $table->date('jadwal_ukur_badan');
            $table->enum('metode_pembayaran', ['bayar_ditempat', 'transfer']);
            $table->enum('sumber_bahan', ['pelanggan', 'penjahit']);
            $table->integer('durasi_estimasi')->nullable(); // 2, 4, atau 7
            $table->decimal('total_harga', 10, 2)->nullable();
            $table->date('estimasi_selesai')->nullable();
            $table->enum('status', ['diantrian', 'diproses', 'diambil', 'selesai'])->default('diantrian');

            $table->timestamps();

            // Foreign keys
            $table->foreign('id_customer')->references('id')->on('customers')->onDelete('cascade');
            $table->foreign('id_produk_katalog')->references('id')->on('katalog')->onDelete('cascade');
            $table->foreign('id_ukuran_badan')->references('id')->on('ukuran_badan')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('order_katalog');
    }
}
