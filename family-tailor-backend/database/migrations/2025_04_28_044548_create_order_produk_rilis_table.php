<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateOrderProdukRilisTable extends Migration
{
    public function up()
    {
        Schema::create('order_produk_rilis', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('id_customer');
            $table->enum('metode_pengiriman', ['ambil di tempat', 'diantar ke alamat']);
            $table->enum('metode_pembayaran', ['bayar ditempat', 'transfer']);
            $table->enum('status', ['diantrian', 'dikirim', 'selesai'])->default('diantrian');
            $table->enum('zona', ['dalam kota', 'luar kota']);
            $table->decimal('ongkir', 10, 2);
            $table->decimal('total_harga', 10, 2);
            $table->timestamps();

            $table->foreign('id_customer')->references('id')->on('customers')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('order_produk_rilis');
    }
}
