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
        Schema::create('stok_bahan_bakus', function (Blueprint $table) {
            $table->id();
            $table->string('nama_bahan', 50);
            $table->date('tanggal_masuk');
            $table->integer('jumlah');
            $table->enum('satuan',['meter', 'pcs', 'lusin']);
            $table->decimal('harga_beli');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('stok_bahan_bakus');
    }
};
