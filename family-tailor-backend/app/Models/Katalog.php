<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Katalog extends Model
{
    protected $table = 'katalog';

    protected $fillable = [
        'nama_produk',
        'gambar',
        'deskripsi_produk',
        'spesifikasi',
        'harga_minimum',
        'harga_maksimum',
        'keterangan',
    ];
}
