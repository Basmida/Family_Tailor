<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProdukRilis extends Model
{
    protected $table = 'produk_rilis';

    protected $fillable = [
        'nama_produk',
        'harga',
        'gambar',
        'ukuran',
        'spesifikasi',
        'deskripsi_produk',
        'keterangan',
    ];
}

