<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateLayananTable extends Migration
{
    public function up(): void
    {
        Schema::create('layanan', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('customer_id');
            $table->enum('jenis_layanan', ['custom', 'perbaikan', 'modifikasi', 'aksesoris']);
            $table->decimal('harga', 10, 2);
            $table->integer('waktu_layanan'); // durasi dalam hari: 1,2,3
            $table->timestamp('estimasi_selesai');
            $table->timestamps();

            $table->foreign('customer_id')->references('id')->on('customers')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('layanan');
    }
}
