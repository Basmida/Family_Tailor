<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class limit_produksi extends Model
{
    protected $table = 'limit_produksi';

    protected $fillable = [
        'jumlah_limit',
        'bulan',
        'tahun',
    ];
}
