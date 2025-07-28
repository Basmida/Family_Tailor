<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StokBahanBaku extends Model
{
    protected $table = 'stok_bahan_bakus';

    protected $fillable = [
        'nama_bahan',
        'tanggal_masuk',
        'jumlah',
        'satuan',
        'harga_beli',
    ];
}
