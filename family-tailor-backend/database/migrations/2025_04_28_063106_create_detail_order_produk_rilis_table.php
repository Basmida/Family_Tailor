<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateDetailOrderProdukRilisTable extends Migration
{
    public function up()
    {
        Schema::create('detail_order_produk_rilis', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('order_produk_rilis')->onDelete('cascade');
            $table->foreignId('produk_rilis_id')->constrained('produk_rilis')->onDelete('cascade');
            $table->integer('jumlah_item');
            $table->decimal('harga_per_item', 10, 2);
            $table->decimal('subtotal', 12, 2);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('detail_order_produk_rilis');
    }
}
