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
        Schema::create('katalog', function (Blueprint $table) {
            $table->id();
            $table->string('nama_produk', 25);
            $table->string('gambar', 255)->nullable();
            $table->string('deskripsi_produk', 255);
            $table->string('spesifikasi', 255);
            $table->decimal('harga_minimum');
            $table->decimal('harga_maksimum');
            $table->string('keterangan', 255)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('katalog');
    }
};
