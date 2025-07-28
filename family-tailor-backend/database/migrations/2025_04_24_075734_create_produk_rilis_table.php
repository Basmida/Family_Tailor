<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('produk_rilis', function (Blueprint $table) {
            $table->id();
            $table->string('nama_produk', 25);
            $table->decimal('harga');
            $table->string('gambar', 255)->nullable();
            $table->enum('ukuran',['S','M','L','XL']);
            $table->string('spesifikasi', 255);
            $table->string('deskripsi_produk', 255);
            $table->string('keterangan', 255)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('produk_rilis');
    }
};
